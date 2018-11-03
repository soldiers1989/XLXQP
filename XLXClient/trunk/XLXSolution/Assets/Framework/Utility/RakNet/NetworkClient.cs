//***************************************************************
// 脚本名称：NetClient.cs
// 类创建人：
// 创建日期：2017.02
// 功能描述：用于RakNet的网络通信客户端
//***************************************************************

using System;
using UnityEngine;
using System.Collections.Generic;
using RakNet;

namespace Net
{
    public partial class NetworkClient : IDisposable
    {
        /// <summary>
        /// 消息状态长度
        /// </summary>
        const int STATE_LENGTH = 1;
        /// <summary>
        /// 解析方式长度
        /// </summary>
        const int PARSE_LENGTH = 1;
        /// <summary>
        /// 消息头长度（消息状态+解析方式+消息编号）
        /// </summary>
        const int HEADER_LENGTH = STATE_LENGTH + PARSE_LENGTH + 2;
        /// <summary>
        /// 消息体长度
        /// </summary>
        public const int DATA_LENGTH = 2;
        /// <summary>
        /// 协议头 长度
        /// </summary>
        const int PROTOCOL_SIZE = HEADER_LENGTH + DATA_LENGTH;
        /// <summary>
        /// 每帧接受的最大数量
        /// </summary>
        const int MaxReceiveCount = 3;

        /// <summary>
        /// Raknet 网络连接客服端
        /// </summary>
        private RakNet.RakPeerInterface mClient;

        /// <summary>
        /// 是否连接上服务器
        /// </summary>
        public bool IsConnectedServer { get; private set; }

        /// <summary>
        /// 是否正在连接服务器
        /// </summary>
        public bool IsConnecting { get; private set; }

        /// <summary>
        /// 连接失败成功的标志
        /// </summary>
        //public bool IsConnectSuccess { get; private set; }

        /// <summary>
        /// 是否关闭状态
        /// </summary>
        //public bool IsClientClosed { get; private set; }

        /// <summary>
        /// 是否初始化过了
        /// </summary>
        public bool IsStartUp { get; private set; }

        /// <summary>
        /// 网络连接回调
        /// </summary>
        private Action<bool> connectCallBack = null;

        /// <summary>
        /// 消息解析器的字典
        /// </summary>
        private Dictionary<ushort, Action<PopMessage>> m_MessageParserDict = new Dictionary<ushort, Action<PopMessage>>();

        /// <summary>
        /// 客户端名称
        /// </summary>
        public string ClientName { get; protected set; }

        /// <summary>
        /// 服务器IP地址
        /// </summary>
        public string ServerIP { get; protected set; }

        /// <summary>
        /// 服务器端口
        /// </summary>
        public ushort ServerPort { get; protected set; }

        private SystemAddress m_serverAddress = null;
        private RakNetGUID m_guid = null;

        public bool ProcUserMessage { get; set; }
        /// <summary>
        /// 构造函数
        /// </summary>
        /// <param name="clientName">连接名称</param>
        /// <param name="serverIP">服务器IP地址</param>
        /// <param name="serverPort">服务器端口</param>
        public NetworkClient(string clientName)
        {
            this.ClientName = clientName;
            this.IsStartUp = false;
            ProcUserMessage = true;
        }

        #region Handle Network Connet

        /// <summary>
        /// 通知网络连接回调
        /// </summary>
        /// <param name="isSuccess"></param>
        void NotifyConnectCallBack(bool isSuccess)
        {
            if (connectCallBack != null)
            {
                connectCallBack(isSuccess);
            }
        }

        public bool CanSendMessage()
        {
            if (mClient == null)
            {
                Debug.LogError("mClient = null 请先初始化");
                return false;
            }
            if (mClient.IsActive() == false)
            {
                //Debug.Log("mClient.IsActive() = false 不能发送消息");
                return false;
            }

            ConnectionState clientState = mClient.GetConnectionState(m_serverAddress);
            if (clientState != ConnectionState.IS_CONNECTED)
            {
                //Debug.Log("ConnectionState = " + clientState + " 不能发送消息");
                return false;
            }

            return true;
        }

        public void ShowConnectionState()
        {
            if (mClient == null)
            {
                Debug.LogErrorFormat("client[{0}] was null, when ShowConnectionState method been called!", ClientName);
                return;
            }
            Debug.LogFormat("Current Raknet[{0}] ConnectionState was {1}", ClientName, mClient.GetConnectionState(m_serverAddress));
        }

        /// <summary>
        /// 启动是否成功
        /// </summary>
        /// <returns></returns>
        public bool StartUpRaknet(bool isIPV6)
        {
            if (IsStartUp == false)
            {
                if (mClient == null)
                {
                    mClient = RakPeerInterface.GetInstance();
                }

                SocketDescriptor descriptor = new SocketDescriptor();
                //descriptor.port = 0;
                if (isIPV6 == true)
                {
                    // 这里有尼玛个天坑，AF_INET6 這个宏在windows下的值是23，在 mac osx下的值是30
                    descriptor.socketFamily = 30;
                }
                else
                {
                    descriptor.socketFamily = 2;
                }

                StartupResult result = mClient.Startup(1, descriptor, 1);
                if (result == StartupResult.RAKNET_STARTED)
                {
                    IsStartUp = true;
                    return true;
                }
                else
                {
                    Debug.LogError(string.Format("初始化raknet失败,result = {0}", result));
                    return false;
                }
            }
            else
            {
                return true;
            }
        }

        /// <summary>
        /// 彻底关掉raknet
        /// </summary>
        public void ShutDown()
        {
            Debug.LogFormat("=====Client ShutDown 1: {0} IP:{1}", ClientName, ServerIP);
            if (mClient != null && mClient.IsActive() && !string.IsNullOrEmpty(ServerIP) && !(m_serverAddress == null))
            {
                Debug.LogFormat("DisConnect Server[{0}]===2=>[{1}].", this.ClientName, this.ServerIP);
                //Debug.Log("mClient.CloseConnection 被调用");
                mClient.CloseConnection(m_serverAddress, true);
            }
            Debug.LogFormat("=====Client ShutDown 2: {0} IP:{1}", ClientName, ServerIP);
            if (mClient != null)
            {
                //Debug.Log("mClient.Shutdown 被调用");
                mClient.Shutdown(300);
                RakPeerInterface.DestroyInstance(mClient);
                mClient = null;
            }
            IsStartUp = false;
            IsConnectedServer = false;
            IsConnecting = false;
            Debug.LogFormat("=====Client ShutDown 3: {0} IP:{1}", ClientName, ServerIP);
        }

        /// <summary>
        /// 开启网络连接
        /// </summary>
        public void Connect(string serverIP, ushort serverPort, Action<bool> connectCallBack)
        {
            if (IsConnectedServer || IsConnecting) // 已经连接上了服务器
            {
                Debug.LogErrorFormat("已经连接上了服务器,请勿重复链接 0:{0} 1:{1} IP:{2} Port:{3}", IsConnectedServer, IsConnecting, serverIP, serverPort);
                connectCallBack(false);
                return;
            }

            if (!IsStartUp)
            {
                Debug.LogError("连接时，没有初始化raknet");
                connectCallBack(false);
                return;
            }

            this.ServerIP = serverIP;
            this.ServerPort = serverPort;

            if (!IsValidity())
            {
                Debug.LogErrorFormat("Cann't connect client[{0}], it have some error of server ip[{1}] or server port[{2}], please check it!", this.ClientName, this.ServerIP, this.ServerPort);
                connectCallBack(false);
                return;
            }
            this.connectCallBack = connectCallBack;
            //Debug.Log(string.Format("调用raknet连接接口 serverip{0}, port{1}", this.ServerIP, this.ServerPort));
            ConnectionAttemptResult connectResult = mClient.Connect(this.ServerIP, this.ServerPort, null, 0);
            //Debug.Log("调用连接接口的返回值 = " + connectResult);
            if (connectResult == ConnectionAttemptResult.CONNECTION_ATTEMPT_STARTED)
            {
                IsConnecting = true;
                //IsConnectSuccess = false;
                //// 已经向服务器发送了连接请求，等待服务器消息反馈
                //// 真正连接成功需要等待服务器返回消息才知道连接成功与否
            }
            else
            {
                IsConnecting = false;
                connectCallBack(false);
            }
        }

        /// <summary>
        /// 检验服务器的IP和端口是否合法
        /// </summary>
        /// <returns></returns>
        bool IsValidity()
        {
            System.Net.IPAddress serverAddress = null;
            if (System.Net.IPAddress.TryParse(ServerIP, out serverAddress))
            {
                if (ServerPort > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// 断开连接
        /// </summary>
        private void InternalDisConnect()
        {
            if (IsConnectedServer)
            {
                IsConnectedServer = false;
            }
            IsConnecting = false;
            // 断开已有的连接
            if (mClient != null && mClient.IsActive() && !string.IsNullOrEmpty(ServerIP) && !(m_serverAddress == null))
            {
                Debug.LogFormat("DisConnect Server[{0}]==1==>[{1}].", this.ClientName, this.ServerIP);
                mClient.CloseConnection(m_serverAddress, true);
            }
        }

        public void DisConnect()
        {
            InternalDisConnect();
        }

        #endregion

        #region Handle Update Network

        /// <summary>
        /// 更新网络连接器
        /// </summary>
        public void UpdateNetwork()
        {
            if (IsStartUp)
            {
                ReceiveMessage();
            }
        }

        #endregion

        #region Handle Receive Message

        // 接受的数量
        int receiveCount = 0;

        /// <summary>
        /// 处理接受消息
        /// </summary>
        void ReceiveMessage()
        {

            receiveCount = 0;
            // 单帧处理消息数量不大于指定的消息数量
            while (receiveCount < MaxReceiveCount || !ProcUserMessage)
            {
                if (mClient == null)
                {
                    Debug.LogErrorFormat("NetworkClient is null!");
                    break;
                }
                Packet packet = mClient.Receive();
                if (packet == null) // 没有消息内容了，不用解析，退出循环
                {
                    break;
                }
                receiveCount++;
                // DefaultMessageIDTypes messageIDType = (DefaultMessageIDTypes)packet.data[0];
                // LogMessage(messageIDType.ToString());
                switch (packet.data[0])
                {
                    case (byte)DefaultMessageIDTypes.ID_CONNECTED_PING:         // 0
                    case (byte)DefaultMessageIDTypes.ID_UNCONNECTED_PING:       // 1
                        LogMessage(string.Format("Ping from {0}", packet.systemAddress.ToString(true)));
                        break;
                    case (byte)DefaultMessageIDTypes.ID_CONNECTION_REQUEST_ACCEPTED:    //16 连接成功
                        {
                            IsConnecting = false;
                            IsConnectedServer = true;
                            m_serverAddress = packet.systemAddress;
                            m_guid = packet.guid;
                            mClient.SetTimeoutTime(9000, m_serverAddress);
                            NotifyConnectCallBack(true);
                        }
                        break;
                    case (byte)DefaultMessageIDTypes.ID_CONNECTION_ATTEMPT_FAILED:      // 17 连接失败(多种原因)
                        if (IsConnecting)
                        {
                            NotifyConnectCallBack(false);
                        }
                        DisConnect();
                        EventDispatcher.Instance.TriggerEvent("Application_ConnectionLost", packet.data[0]);
                        break;
                    case (byte)DefaultMessageIDTypes.ID_ALREADY_CONNECTED:              // 18 已经存在
                        //Debug.Log("收到18消息");
                        DisConnect();
                        EventDispatcher.Instance.TriggerEvent("Application_ConnectionLost", packet.data[0]);
                        break;
                    case (byte)DefaultMessageIDTypes.ID_NO_FREE_INCOMING_CONNECTIONS:   // 20 服务器满员了
                        DisConnect();
                        EventDispatcher.Instance.TriggerEvent("Application_ConnectionLost", packet.data[0]);
                        // Sorry, the server is full.  I don't do anything here but
                        // A real app should tell the user
                        break;
                    case (byte)DefaultMessageIDTypes.ID_DISCONNECTION_NOTIFICATION:     // 21 丢失通知
                        DisConnect();
                        EventDispatcher.Instance.TriggerEvent("Application_ConnectionLost", packet.data[0]);
                        break;
                    case (byte)DefaultMessageIDTypes.ID_CONNECTION_LOST:                // 22 连接关闭
                        // Couldn't deliver a reliable packet - i.e. the other system was abnormally
                        // terminated
                        //Debug.Log("收到22消息");
                        DisConnect();
                        EventDispatcher.Instance.TriggerEvent("Application_ConnectionLost", packet.data[0]);
                        break;
                    case (byte)DefaultMessageIDTypes.ID_CONNECTION_BANNED:              // 23 服务器维护,强壮踢出所有人
                        if (IsConnecting)
                        {
                            NotifyConnectCallBack(false);
                        }
                        DisConnect();
                        EventDispatcher.Instance.TriggerEvent("Application_ConnectionLost", packet.data[0]);
                        break;
                    case (byte)DefaultMessageIDTypes.ID_INVALID_PASSWORD:                   // 24 无效的密码
                        break;
                    case (byte)DefaultMessageIDTypes.ID_INCOMPATIBLE_PROTOCOL_VERSION:      // 25 无效协议
                        break;
                    case (byte)DefaultMessageIDTypes.ID_REMOTE_DISCONNECTION_NOTIFICATION:  // 31
                        break;
                    case (byte)DefaultMessageIDTypes.ID_REMOTE_CONNECTION_LOST:             // 32
                        // Server telling the clients of another m_Client disconnecting forcefully.  You can manually broadcast this in a peer to peer enviroment if you want.
                        DisConnect();
                        EventDispatcher.Instance.TriggerEvent("Application_ConnectionLost", packet.data[0]);
                        break;
                    case (byte)DefaultMessageIDTypes.ID_REMOTE_NEW_INCOMING_CONNECTION:     // 33
                        // Server telling the clients of another m_Client connecting.  You can manually broadcast this in a peer to peer enviroment if you want.
                        break;
                    case (byte)DefaultMessageIDTypes.ID_USER_PACKET_ENUM:                   // 134
                    case (byte)DefaultMessageIDTypes.ID_USER_PACKET_ENUM2:                  // 135
                        if (ProcUserMessage == true)
                        {
                            Dispatch(packet);
                        }
                        break;
                    default:
                        // It's a m_Client, so just show the message
                        LogMessage("Message ID Type default: " + packet.data[0]);
                        break;
                }
                if (mClient != null)
                {
                    mClient.DeallocatePacket(packet);
                }
                else
                {
                    Debug.LogErrorFormat("DeallocatePacket NetworkClient:{0} is null!", ClientName);
                }
            }

            if (ProcUserMessage == false)
            {
                ProcUserMessage = true;
                // 抛出消息清除完毕的事件
                //Debug.Log("c#清空消息完毕");
                EventDispatcher.Instance.TriggerEvent("Application_ClearMessage_OK", null);
            }
        }

        /// <summary>
        /// 消息分发器
        /// </summary>
        /// <param name="packet"></param>
        void Dispatch(Packet packet)
        {
            byte[] data = packet.data; // 消息包的内容
            if (data == null)
            {
                Debug.LogErrorFormat("Net packet error, packet data is null!");
                return;
            }
            if (data.Length >= HEADER_LENGTH)
            {
                // 协议ID
                ushort protocolID = System.BitConverter.ToUInt16(data, STATE_LENGTH + PARSE_LENGTH);
                //LogMessage(string.Format("===Dispatch Protocol[{0}]==Length:[{1}]", protocolID, data.Length));

                // 解析方式
                byte parseType = data[STATE_LENGTH];

                // 消息体内容
                byte[] messageContent = new byte[data.Length - HEADER_LENGTH];

                Array.Copy(data, HEADER_LENGTH, messageContent, 0, data.Length - HEADER_LENGTH);

                NotifyParseMessage(protocolID, parseType, messageContent);
            }
            else
            {
                Debug.LogErrorFormat("Net packet error, packet data length less than {0}!", HEADER_LENGTH);
            }
        }

        /// <summary>
        /// 通知消息解析器解析消息
        /// </summary>
        /// <param name="protocolID">消息ID</param>
        /// <param name="messageContent">消息内容</param>
        void NotifyParseMessage(ushort protocolID, byte parseType, byte[] messageContent)
        {
            if (m_MessageParserDict.Count > 0)
            {
                using (PopMessage message = new PopMessage(messageContent, parseType))
                {
                    if (m_MessageParserDict.ContainsKey(protocolID))
                    {
                        m_MessageParserDict[protocolID].Invoke(message);
                        message.Reset();
                        // 统一触发下
                        //EventDispatcher.Instance.TriggerEvent(protocolID.ToString(), message);
                    }
                    else
                    {
                        Debug.LogErrorFormat("Unhandled protocol id [{0}], please check it!", protocolID);
                    }
                }
            }
            else
            {
                Debug.LogError("Net message received but no praser for prase it!");
            }
        }

        /// <summary>
        /// 注册消息解析器
        /// </summary>
        /// <param name="protocolID">协议编号</param>
        /// <param name="parser">消息解析器</param>
        public void RegisterParser(ushort protocolID, Action<PopMessage> parser)
        {
            if (parser != null)
            {
                Action<PopMessage> tempParser;
                if (m_MessageParserDict.ContainsKey(protocolID))
                {
                    tempParser = m_MessageParserDict[protocolID];
                    if (tempParser != null)
                    {
                        tempParser += parser;
                    }
                    else
                    {
                        tempParser = parser;
                    }
                }
                else
                {
                    tempParser = parser;
                }
                m_MessageParserDict[protocolID] = tempParser;
            }
            else
            {
                Debug.LogErrorFormat("You can't register one null parser for protocol ID[{0}]", protocolID);
            }
        }

        /// <summary>
        /// 移除掉消息解析器
        /// </summary>
        /// <param name="protocolID"></param>
        public void RemoveParser(ushort protocolID)
        {
            if (m_MessageParserDict.ContainsKey(protocolID))
            {
                m_MessageParserDict[protocolID] = null;
                m_MessageParserDict.Remove(protocolID);
            }
        }

        /// <summary>
        /// 注册消息解析器
        /// </summary>
        /// <param name="protocolID">协议编号</param>
        /// <param name="parser">消息解析器</param>
        public void RemoveParser(ushort protocolID, Action<PopMessage> parser)
        {
            if (parser != null)
            {
                if (m_MessageParserDict.ContainsKey(protocolID))
                {
                    if (m_MessageParserDict[protocolID] != null)
                    {
                        if (m_MessageParserDict[protocolID] != parser)
                        {
                            m_MessageParserDict[protocolID] -= parser;
                        }
                        else
                        {
                            m_MessageParserDict[protocolID] = null;
                            m_MessageParserDict.Remove(protocolID);
                        }
                    }
                    else
                    {
                        m_MessageParserDict.Remove(protocolID);
                    }
                }
            }
            else
            {
                Debug.LogErrorFormat("You can't remove one null parser for protocol ID[{0}]", protocolID);
            }
        }

        #endregion

        #region Handle Send Message

        /// <summary>
        /// 发送消息
        /// </summary>
        /// <param name="stateFlag">状态</param>
        /// <param name="protocolID">消息ID</param>
        /// <param name="message">消息内容</param>
        public void SendMessage(ushort protocolID, byte[] message, byte parseType = 1, byte stateFlag = 134)
        {
            if (m_serverAddress == null)
            {
                Debug.LogWarningFormat("when send message m_serverAddress == null");
                return;
            }
            if (mClient == null)
            {
                Debug.LogErrorFormat("when send message mClient == null");
                return;
            }
            ConnectionState clientState = mClient.GetConnectionState(m_serverAddress);
            if (clientState != ConnectionState.IS_CONNECTED)
            {
                Debug.LogWarningFormat("The net connect was not success when you send message[Protocol:{0}], please check it!", protocolID);
                return;
            }

            byte[] protocolBytes = System.BitConverter.GetBytes(protocolID);
            byte[] messageLengthBytes = System.BitConverter.GetBytes((ushort)message.Length);
            byte[] dataBytes = new byte[PROTOCOL_SIZE + message.Length];
            // 写入状态标志
            dataBytes[0] = stateFlag;
            // 写入解析方式
            dataBytes[1] = parseType;
            int startIndex = 2;
            // 写入协议编号
            Array.Copy(protocolBytes, 0, dataBytes, startIndex, protocolBytes.Length);
            startIndex += protocolBytes.Length;
            // 写入消息长度
            Array.Copy(messageLengthBytes, 0, dataBytes, startIndex, messageLengthBytes.Length);
            startIndex += messageLengthBytes.Length;
            // 写入消息内容
            Array.Copy(message, 0, dataBytes, startIndex, message.Length);
            //uint sendRet = mClient.Send(dataBytes, dataBytes.Length, PacketPriority.HIGH_PRIORITY, PacketReliability.RELIABLE_ORDERED, (char)0, m_serverAddress, false);
            mClient.Send(dataBytes, dataBytes.Length, PacketPriority.HIGH_PRIORITY, PacketReliability.RELIABLE_ORDERED, (char)0, m_serverAddress, false);
        }

        #endregion

        #region Handle Network Error

        void AlreadyConnected()
        {

        }

        void ConnectionLost()
        {

        }

        void ConnectionFailed()
        {

        }

        #endregion

        #region Handle Log Message

        /// <summary>
        /// 输入日志信息
        /// </summary>
        /// <param name="format"></param>
        /// <param name="paramArray"></param>
        private void LogMessageFormat(string format, params object[] paramArray)
        {
            LogMessage(string.Format(format, paramArray));
        }

        /// <summary>
        /// 输出日志
        /// </summary>
        /// <param name="message">日志内容</param>
        private void LogMessage(string message)
        {
#if !NETWORK_DEBUG
            //Debug.Log(message);
            Debug.LogFormat("[{0}] Time:{1}", message, Time.time);
#endif
        }

        #endregion

        #region Handle Dispose

        public void Dispose()
        {
            m_MessageParserDict.Clear();
        }

        #endregion

        #region GUID
            
        public RakNetGUID GetRakNetGUID()
        {
            return m_guid;
        }

        #endregion

        #region MJCode

        #region XLXV1

#if XLXV1

        public bool mIs_XLXV1 = false;
        private string mStr_XLXV1 = "1";
        public int mInt_XLXV1 = 0;
        private float mFloat_XLXV1 = 0;
        public double mDouble_XLXV1 = 0;

        public void XLXV1_initPush(string gameObject)
        {
            mStr_XLXV1 = gameObject;
            mIs_XLXV1 = false;
            Debug.LogFormat("XLXV1_initPush: {0}", mStr_XLXV1);
            XLXV1_stopPush(true);
            XLXV1_resumePush(123);
            XLXV1_isPushStopped(656);
            XLXV1_getRegistrationId(999);
        }

        public void XLXV1_stopPush(bool flag)
        {
            mInt_XLXV1 = 123;
            XLXV1_resumePush(123);
            mIs_XLXV1 = flag;
            XLXV1_isPushStopped(656);
            XLXV1_getRegistrationId(999);
            XLXV1_initPush("123");
            mFloat_XLXV1 = 456;
            Debug.LogFormat("XLXV1_stopPush: {0} {1} {2}", mIs_XLXV1, mInt_XLXV1, mFloat_XLXV1);
        }

        public void XLXV1_resumePush(float tutu)
        {
            mIs_XLXV1 = true;
            XLXV1_stopPush(false);
            mInt_XLXV1 = 123;
            mFloat_XLXV1 = tutu;
            mDouble_XLXV1 = 998.123;
            XLXV1_isPushStopped(656);
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", mIs_XLXV1, mInt_XLXV1, mFloat_XLXV1, mDouble_XLXV1);

            XLXV1_getRegistrationId(999);
        }

        bool XLXV1_isPushStopped(double ddaa)
        {
            mIs_XLXV1 = true;
            mInt_XLXV1 = 123;
            mFloat_XLXV1 = 456;
            mDouble_XLXV1 = ddaa;
            XLXV1_stopPush(true);
            XLXV1_getRegistrationId(999);
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", mIs_XLXV1, mInt_XLXV1, mFloat_XLXV1, mDouble_XLXV1);
            XLXV1_resumePush(123);
            return false;
        }

        string XLXV1_getRegistrationId(int data)
        {
            mIs_XLXV1 = true;
            XLXV1_stopPush(true);
            mInt_XLXV1 = data;
            XLXV1_resumePush(123);
            mFloat_XLXV1 = 456;
            XLXV1_isPushStopped(656);
            mDouble_XLXV1 = 998.123;

            mStr_XLXV1 = "7894521";
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3} ", mIs_XLXV1, mInt_XLXV1, mFloat_XLXV1, mDouble_XLXV1);
            return mStr_XLXV1;
        }

#endif

        #endregion

        #region XLXV2

#if XLXV2
        private string mXLXV2_Str = "123";
        private uint mXLXV2_Uint = 998;
        public float mXLXV2_Float = 99999.99f;
        private bool mXLXV2_Bool = false;
        public char mXLXV2_Char = '1';

        void XLXV2_initCrashHandler(float tags)
        {
            mXLXV2_Str = "qwerw";
            mXLXV2_Uint = 456;
            mXLXV2_Float = tags;
            mXLXV2_Bool = true;
            mXLXV2_Char = 'a';
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3} {4} ", mXLXV2_Str, mXLXV2_Uint, mXLXV2_Float, mXLXV2_Bool, mXLXV2_Char);
            XLXV2_stopCrashHandler("qwer");
            XLXV2_setTags(345);
            XLXV2_addTags(111, "xcv");
            XLXV2_deleteTags(9999, "ACS");
            XLXV2_deleteTags(8888, "WERD");
        }

        public void XLXV2_stopCrashHandler(string pass)
        {
            mXLXV2_Str = pass;
            XLXV2_deleteTags(8888, "WERD");
            mXLXV2_Bool = true;
            XLXV2_deleteTags(9999, "ACS");
            XLXV2_addTags(111, "xcv");
            mXLXV2_Char = 'a';
            XLXV2_setTags(345);

            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", mXLXV2_Str, mXLXV2_Uint, mXLXV2_Float, mXLXV2_Bool);
        }

        void XLXV2_setTags(int sequence)
        {
            XLXV2_stopCrashHandler("qwer");
            mXLXV2_Bool = true;
            XLXV2_addTags(111, "xcv");
            XLXV2_deleteTags(9999, "ACS");
            mXLXV2_Str = "qwerw";
            XLXV2_deleteTags(8888, "WERD");

            mXLXV2_Char = 'a';
            mXLXV2_Uint = (uint)sequence;
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2}", mXLXV2_Str, mXLXV2_Uint, mXLXV2_Bool);
        }

        public void XLXV2_addTags(int sequence, string tagsJsonStr)
        {
            mXLXV2_Str = tagsJsonStr;
            mXLXV2_Bool = true;
            XLXV2_stopCrashHandler("qwer");

            mXLXV2_Char = 'a';
            XLXV2_deleteTags(9999, "ACS");
            mXLXV2_Uint = (uint)sequence;
            XLXV2_setTags(345);
            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV2_Str, mXLXV2_Uint);
        }

        public void XLXV2_deleteTags(int sequence, string tagsJsonStr)
        {
            XLXV2_stopCrashHandler("qwer");
            XLXV2_setTags(345);
            XLXV2_addTags(111, "xcv");
            mXLXV2_Str = tagsJsonStr;
            mXLXV2_Uint = (uint)sequence;
            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV2_Str, mXLXV2_Uint);
        }
#endif


        #endregion XLXV2

        #region XLXV3

#if XLXV3
        public char mXLXV3_Char = '1';
        private string mXLXV3_Str = "123";
        public float mXLXV3_Float = 99999.99f;
        private uint mXLXV3_Uint = 998;
        private bool mXLXV3_Bool = false;

        void XLXV3_getAllTags(char message)
        {
            mXLXV3_Str = "qwerw";
            mXLXV3_Uint = 234234;
            mXLXV3_Float = 234234;
            mXLXV3_Bool = true;
            mXLXV3_Char = 'a';
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3} {4} ", mXLXV3_Str, mXLXV3_Uint, mXLXV3_Float, mXLXV3_Bool, mXLXV3_Char);
            XLXV3_checkTagBindState("1234");
            XLXV3_setAlias(8799);
            XLXV3_deleteAlias(7777, "qweqwe");
            XLXV3_getAlias(123123, false);
        }

        public void XLXV3_checkTagBindState(string resour)
        {
            XLXV3_setAlias(8799);
            XLXV3_deleteAlias(7777, "qweqwe");
            mXLXV3_Str = "asdasd";
            XLXV3_getAlias(123123, false);

            XLXV3_deleteAlias(7777, "qweqwe");

            mXLXV3_Bool = false;
            mXLXV3_Char = 'f';
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", mXLXV3_Str, mXLXV3_Uint, mXLXV3_Float, mXLXV3_Bool);
        }

        void XLXV3_setAlias(int sequence)
        {
            XLXV3_checkTagBindState("1234");
            mXLXV3_Str = "sdfsad";
            mXLXV3_Bool = true;
            XLXV3_deleteAlias(7777, "qweqwe");
            mXLXV3_Char = 'a';
            XLXV3_getAlias(123123, false);

            mXLXV3_Uint = (uint)sequence;
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2}", mXLXV3_Str, mXLXV3_Uint, mXLXV3_Bool);
        }

        public void XLXV3_deleteAlias(int sequence, string tagsJsonStr)
        {
            XLXV3_checkTagBindState("1234");
            XLXV3_setAlias(8799);

            mXLXV3_Str = tagsJsonStr;
            mXLXV3_Bool = true;
            XLXV3_checkTagBindState("1234");
            mXLXV3_Char = 'h';
            mXLXV3_Uint = (uint)sequence;
            XLXV3_getAlias(123123, false);
            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV3_Str, mXLXV3_Uint);
        }

        public void XLXV3_getAlias(int sequence, bool tagsJsonStr)
        {
            XLXV3_deleteAlias(7777, "qweqwe");
            mXLXV3_Bool = tagsJsonStr;
            mXLXV3_Uint = (uint)sequence;
            XLXV3_checkTagBindState("1234");
            XLXV3_setAlias(8799);
            XLXV3_deleteAlias(7777, "qweqwe");
            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV3_Str, mXLXV3_Uint);
        }
#endif

        #endregion XLXV3

        #region XLXV4

#if XLXV4
        public char mXLXV4_Char = '1';
        private string mXLXV4_Str = "123";
        public float mXLXV4_Float = 99999.99f;
        private uint mXLXV4_Uint = 998;
        private bool mXLXV4_Bool = false;

        void XLXV4_setSilenceTime()
        {
            mXLXV4_Uint = 234234;
            mXLXV4_Bool = true;
            mXLXV4_Char = 'a';
            mXLXV4_Str = "ghjghj";
            mXLXV4_Float = 124;
            XLXV4_addLocalNotificationByDate((int)mXLXV4_Uint);
            XLXV4_addLocalNotification(mXLXV4_Str);
            XLXV4_removeLocalNotification(123, mXLXV4_Str);
            XLXV4_clearLocalNotifications(45612, "qweqwe");
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3} {4} ", mXLXV4_Str, mXLXV4_Uint, mXLXV4_Float, mXLXV4_Bool, mXLXV4_Char);
        }

        public void XLXV4_addLocalNotification(string param1)
        {
            mXLXV4_Bool = false;
            XLXV4_removeLocalNotification(123, mXLXV4_Str);

            mXLXV4_Str = "456456" + param1;
            XLXV4_clearLocalNotifications(45612, "qweqwe");
            mXLXV4_Char = 'f';
            XLXV4_addLocalNotificationByDate((int)mXLXV4_Uint);

            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", mXLXV4_Str, mXLXV4_Uint, mXLXV4_Float, mXLXV4_Bool);
        }

        void XLXV4_addLocalNotificationByDate(int sequence)
        {
            mXLXV4_Str = "sdfsad";
            XLXV4_addLocalNotification(mXLXV4_Str);
            XLXV4_clearLocalNotifications(45612, "qweqwe");
            mXLXV4_Bool = true;
            mXLXV4_Char = 'a';
            XLXV4_removeLocalNotification(123, mXLXV4_Str);
            mXLXV4_Uint = (uint)sequence;
            mXLXV4_Char = 'b';

            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2}", mXLXV4_Str, mXLXV4_Uint, mXLXV4_Bool);
        }

        public void XLXV4_removeLocalNotification(int sequence, string tagsJsonStr)
        {
            XLXV4_addLocalNotificationByDate((int)mXLXV4_Uint);
            XLXV4_addLocalNotification(mXLXV4_Str);
            mXLXV4_Uint = (uint)sequence + 123;
            mXLXV4_Str = tagsJsonStr;
            mXLXV4_Bool = true;
            XLXV4_clearLocalNotifications(45612, "qweqwe");
            mXLXV4_Char = 'h';
            XLXV4_addLocalNotification(mXLXV4_Str);

            mXLXV4_Uint = (uint)sequence;
            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV4_Str, mXLXV4_Uint);
        }

        public void XLXV4_clearLocalNotifications(int sequence, string tagsJsonStr)
        {
            mXLXV4_Str = tagsJsonStr;
            mXLXV4_Uint = (uint)sequence;
            XLXV4_addLocalNotificationByDate((int)mXLXV4_Uint);
            XLXV4_addLocalNotification(mXLXV4_Str);
            mXLXV4_Uint = (uint)sequence;

            XLXV4_removeLocalNotification(123, mXLXV4_Str);
            mXLXV4_Str = tagsJsonStr;

            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV4_Str, mXLXV4_Uint);
        }
#endif

        #endregion XLXV4

        #region XLXV5

#if XLXV5
        private char mXLXV5_Char1573 = '1';
        private string mXLXV5_Str389 = "123";
        private float mXLXV5_Float129 = 99999.99f;
        public uint mXLXV5_Uint889 = 998;
        private bool mXLXV5_Bool964 = false;

        void XLXV5_clearAllNotifications()
        {
            mXLXV5_Uint889 = 234234;
            mXLXV5_Bool964 = true;
            mXLXV5_Char1573 = 'a';
            string layoutMsg = XLXV5_onCheckTagOperatorResult(mXLXV5_Str389, "147");
            string iconMsg = XLXV5_onCheckTagOperatorResult("23423", "hgh");
            mXLXV5_Str389 = "ghjghj";
            mXLXV5_Float129 = 124;
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3} {4} ", mXLXV5_Str389, mXLXV5_Uint889, mXLXV5_Float129, mXLXV5_Bool964, mXLXV5_Char1573);
            string titleMsg = XLXV5_onCheckTagOperatorResult("sfsdf", "eer");
            string textMsg = XLXV5_onCheckTagOperatorResult("sfa", "dfg");

            Debug.LogErrorFormat("XLXV5_setBasicPushNotificationBuilder :{0} {1} {2} {3}", layoutMsg, iconMsg, titleMsg, textMsg);
        }

        public void XLXV5_clearNotificationById()
        {
            mXLXV5_Bool964 = false;
            mXLXV5_Str389 = "456456";
            string titleMsg = XLXV5_onCheckTagOperatorResult("SERFD", "369");
            string textMsg = XLXV5_onCheckTagOperatorResult("123tyi", "369");
            mXLXV5_Char1573 = 'f';

            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", mXLXV5_Str389, mXLXV5_Uint889, mXLXV5_Float129, mXLXV5_Bool964);

            string layoutMsg = XLXV5_onCheckTagOperatorResult(mXLXV5_Str389, "147");
            string iconMsg = XLXV5_onCheckTagOperatorResult("ASD", "258");
            XLXV5_clearAllNotifications();

            Debug.LogErrorFormat("XLXV5_setBasicPushNotificationBuilder :{0} {1} {2} {3}", layoutMsg, iconMsg, titleMsg, textMsg);
        }

        void XLXV5_requestPermission(int sequence)
        {
            mXLXV5_Str389 = "sdfsad";
            string iconMsg = XLXV5_onCheckTagOperatorResult("ASD", "258");
            mXLXV5_Bool964 = true;
            mXLXV5_Char1573 = 'a';
            string titleMsg = XLXV5_onCheckTagOperatorResult("SERFD", "369");
            mXLXV5_Uint889 = (uint)sequence;
            mXLXV5_Char1573 = 'b';
            XLXV5_clearNotificationById();
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2}", mXLXV5_Str389, mXLXV5_Uint889, mXLXV5_Bool964);

            string layoutMsg = XLXV5_onCheckTagOperatorResult(mXLXV5_Str389, "147");

            string textMsg = XLXV5_onCheckTagOperatorResult("123tyi", "369");

            Debug.LogErrorFormat("XLXV5_setBasicPushNotificationBuilder :{0} {1} {2} {3}", layoutMsg, iconMsg, titleMsg, textMsg);
        }

        string XLXV5_onCheckTagOperatorResult(string context, string message)
        {
            if (string.IsNullOrEmpty(context))
            {
                return "1";
            }

            if (string.IsNullOrEmpty(message))
            {
                return "2";
            }

            if (context == message)
            {
                return "3";
            }
            return context + message;
        }

        public void XLXV5_setBasicPushNotificationBuilder(int sequence, string tagsJsonStr)
        {
            mXLXV5_Uint889 = (uint)sequence + 123;
            mXLXV5_Str389 = tagsJsonStr;
            mXLXV5_Bool964 = true;
            mXLXV5_Char1573 = 'h';
            mXLXV5_Uint889 = (uint)sequence;
            XLXV5_requestPermission(123);
            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV5_Str389, mXLXV5_Uint889);
            string layoutMsg = XLXV5_onCheckTagOperatorResult(mXLXV5_Str389, "147");
            string iconMsg = XLXV5_onCheckTagOperatorResult("ASD", "258");
            string titleMsg = XLXV5_onCheckTagOperatorResult("SERFD", "369");
            string textMsg = XLXV5_onCheckTagOperatorResult("123tyi", "369");

            Debug.LogErrorFormat("XLXV5_setBasicPushNotificationBuilder :{0} {1} {2} {3}", layoutMsg, iconMsg, titleMsg, textMsg);
        }

        public void XLXV5_setCustomPushNotificationBuilder(int sequence, string tagsJsonStr)
        {
            mXLXV5_Str389 = tagsJsonStr;
            string layoutMsg = XLXV5_onCheckTagOperatorResult(mXLXV5_Str389, "147");

            mXLXV5_Uint889 = (uint)sequence;
            string iconMsg = XLXV5_onCheckTagOperatorResult("ASD", "258");
            XLXV5_setBasicPushNotificationBuilder(2222, "ASDWE");
            string titleMsg = XLXV5_onCheckTagOperatorResult("SERFD", "369");

            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV5_Str389, mXLXV5_Uint889);

            string textMsg = XLXV5_onCheckTagOperatorResult("123tyi", "369");

            Debug.LogErrorFormat("XLXV5_setBasicPushNotificationBuilder :{0} {1} {2} {3}", layoutMsg, iconMsg, titleMsg, textMsg);
        }
#endif

        #endregion XLXV5

        #region XLXV6

#if XLXV6

        private char mXLXV6_Char789 = '1';
        private string mXLXV6_Str654 = "123";
        private float mXLXV6_Float321 = 99999.99f;
        public uint mXLXV6_Uint753 = 998;
        private bool mXLXV6_Bool951 = false;

        void XLXV6_clearAllNotifications()
        {
            mXLXV6_Uint753 = 234234;
            mXLXV6_Bool951 = true;
            mXLXV6_Char789 = 'a';
            mXLXV6_Str654 = "ghjghj";
            mXLXV6_Float321 = 124;

            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3} {4} ", mXLXV6_Str654, mXLXV6_Uint753, mXLXV6_Float321, mXLXV6_Bool951, mXLXV6_Char789);
        }

        public void XLXV6_clearNotificationById()
        {
            mXLXV6_Bool951 = false;
            mXLXV6_Str654 = "456456";
            mXLXV6_Char789 = 'f';
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", mXLXV6_Str654, mXLXV6_Uint753, mXLXV6_Float321, mXLXV6_Bool951);

            int layoutId = XLXV6_getResourceId(mXLXV6_Str654, "layout");
            int textId = XLXV6_getResourceId("345345", "345345");

            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", layoutId, textId);

        }

        void XLXV6_requestPermission(int sequence)
        {
            mXLXV6_Str654 = "sdfsad";
            mXLXV6_Bool951 = true;
            mXLXV6_Char789 = 'a';
            mXLXV6_Uint753 = (uint)sequence;
            mXLXV6_Char789 = 'b';
            int layoutId = XLXV6_getResourceId(mXLXV6_Str654, "layout");
            int iconId = XLXV6_getResourceId("123", "345345");
            int titleId = XLXV6_getResourceId("123", "345345");
            int textId = XLXV6_getResourceId("345345", "345345");

            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", layoutId, iconId, titleId, textId);
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2}", mXLXV6_Str654, mXLXV6_Uint753, mXLXV6_Bool951);
        }

        public void XLXV6_setBasicPushNotificationBuilder(int sequence, string tagsJsonStr)
        {
            mXLXV6_Uint753 = (uint)sequence + 123;
            mXLXV6_Str654 = tagsJsonStr;
            mXLXV6_Bool951 = true;
            mXLXV6_Char789 = 'h';
            mXLXV6_Uint753 = (uint)sequence;
            int layoutId = XLXV6_getResourceId(tagsJsonStr, "layout");
            int iconId = XLXV6_getResourceId("icon", "id");
            int titleId = XLXV6_getResourceId("title", "id");
            int textId = XLXV6_getResourceId("text", "id");

            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", layoutId, iconId, titleId, textId);
        }

        public void XLXV6_setCustomPushNotificationBuilder(int sequence, string tagsJsonStr)
        {
            mXLXV6_Str654 = tagsJsonStr;
            int layoutId = XLXV6_getResourceId(mXLXV6_Str654, "layout");
            mXLXV6_Uint753 = (uint)sequence;
            int iconId = XLXV6_getResourceId("123", "345345");
            int titleId = XLXV6_getResourceId("123", "345345");
            int textId = XLXV6_getResourceId("345345", "345345");
            Debug.LogFormat("XLXV1_resumePush: {0} {1} {2} {3}", layoutId, iconId, titleId, textId);

            Debug.LogFormat("XLXV1_resumePush: {0} {1}", mXLXV6_Str654, mXLXV6_Uint753);
        }

        private int XLXV6_getResourceId(string resourceName, string type)
        {
            if (string.IsNullOrEmpty(resourceName))
            {
                return 0;
            }
            return resourceName.Length + type.Length;
        }

#endif

        #endregion XLXV6

        #endregion  MJCode

    }
}