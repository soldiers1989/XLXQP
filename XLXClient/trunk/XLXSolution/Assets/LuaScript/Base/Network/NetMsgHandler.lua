require 'Base/GameConfig'
require 'Base/GameData'
require 'Base/Network/Protrocol'

NetMsgHandler = { };


-- 登陆Hub服务器
local hubNetClient = nil

-- 游戏服务器
local gameNetClient = nil

local CutOutTime = 0 -- 用于记录切出时间，以及再次切入时，记录切入切出的间隔时间
local IsAutoConnect = false-- 用于自动重连的判定
local AutoConnectCount = 0-- 用于自动重连次数的统计
local IsProactiveDisconnect = false -- 如果是主动断开链接则为true，在此状态值下，不走断线重连流程
local SaveMsgList = CustomList:new()

local isConnectingHub = true

-- 初始化，注册消息解析函数
function NetMsgHandler.Init()
    CS.EventDispatcher.Instance:AddEventListener("Application_CutOut", NetMsgHandler.OnCutOut)
    CS.EventDispatcher.Instance:AddEventListener("Application_ClearMessage_OK", NetMsgHandler.OnClearMessageOK)
    CS.EventDispatcher.Instance:AddEventListener("Application_ConnectionLost", NetMsgHandler.OnConnectionLost)
end

function NetMsgHandler.InitHubNetClient()
    hubNetClient:RegisterParser(ProtrocolID.CS_Request_Game_Server, NetMsgHandler.Received_CS_Request_Game_Server)
    hubNetClient:RegisterParser(ProtrocolID.CS_Visitor_Check, NetMsgHandler.Received_CS_Visitor_Check)
end

-- 尝试连接hub服务器(islogin: true 走登录流程 false 走游客开关验证流程)
function NetMsgHandler.TryConnectHubServer(islogin)
    isConnectingHub = true
    
    if hubNetClient == nil then
        hubNetClient = CS.Net.ConnectManager:Instance():FindNetworkClient("HubServer")
        if hubNetClient == nil then
            hubNetClient = CS.Net.ConnectManager:Instance():CreateNetworkClient("HubServer")
            if hubNetClient == nil then
                print("==========HubServer 连接失败 111:")
                CS.BubblePrompt.Show("网络连接失败，请检查你的网络.", "XLX")
                return
            end
            NetMsgHandler.InitHubNetClient()
        end
    end
    print("connect HubServer：", GameConfig.HubServerURL, CS.UnityEngine.Time.time)

    if hubNetClient.IsConnectedServer then
        -- 登录流程
        NetMsgHandler.Send_CS_Request_Game_Server()
    else
        -- 还未连接 尝试开启连接
        if GameData.IsFirstLogin then
            CS.LoadingDataUI.ShowTips(30,"正在登录...")
        else
            CS.LoadingDataUI.ShowTips(30,"努力加载中...")
        end

        CS.TimeManager.Instance():StartCoroutine(CS.Utility.ConvertURLToIPAddress(GameConfig.HubServerURL, function(hubServerIP)
            hubNetClient:DisConnect()
            hubNetClient:StartUpRaknet(string.find(hubServerIP, ":") ~= nil)
            hubNetClient:Connect(hubServerIP, GameConfig.HubServerPort, function(success)
                CS.LoadingDataUI.Hide()
                if success then
                    -- 登录流程
                    NetMsgHandler.Send_CS_Request_Game_Server()
                else
                    -- 连接失败，显示日志信息
                    print("==========HubServer 连接失败 222:")
                    CS.LoadingDataUI.Hide()
                    CS.BubblePrompt.Show("网络连接失败，请检查你的网络..", "XLX")
                    hubNetClient:DisConnect()
                    NetMsgHandler.ReturnLogin(1)
                end
            end)
        end ))
    end

end

-------------------------------------------------------------------
----------------------NetMsgHandler.Received_CS_Visitor_Check 198
-- 请求游客登录开关
function NetMsgHandler.Send_CS_Visitor_Check()
    local message = CS.Net.PushMessage()
    hubNetClient:SendMessage(ProtrocolID.CS_Visitor_Check, message.Message)
end

-- 游客登录开关
function NetMsgHandler.Received_CS_Visitor_Check(message)
    CS.LoadingDataUI.Hide()
    -- 0 游客不能登录 1游客可以登录
    local resultType = message:PopByte()
    print('服务器反馈 游客是否登录:' .. resultType)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyVisitorCheckEvent, resultType)
end

----------------------CS_Request_Game_Server  199--------------------------
----------------------------请求登陆服务器----------------------------------
-- 请求游戏服务器URL 
function NetMsgHandler.Send_CS_Request_Game_Server()
    local message = CS.Net.PushMessage()
    message:PushString(GameData.LoginInfo.Account)      -- 账号
    message:PushString("")                              -- 密码保留，填空字符
    
    hubNetClient:SendMessage(ProtrocolID.CS_Request_Game_Server, message.Message)

    CS.LoadingDataUI.ShowTips(10,"努力加载中...", function ()
        -- 网络超时处理
        -- CS.BubblePrompt.Show("网络连接失败，请检查！", "LoginUI")
        hubNetClient:DisConnect()
    end)
end

function NetMsgHandler.Received_CS_Request_Game_Server(message)
    isConnectingHub = false
    CS.LoadingDataUI.Hide()

    GameConfig.GameServerURL = message:PopString()      -- GameServer 的 Host
    GameConfig.GameServerPort = message:PopUInt16()     -- GameServer 的 Port
    GameData.ServerID = message:PopUInt16()             -- GameServer 的 ServerID

    print("game server url: " .. GameConfig.GameServerURL)

    --增加 游戏状态 
    GameData.GameServerStatus = message:PopByte()       -- GameServer 的状态 0 服务器关闭 1 正常(包含了白名单维护时期)
    
    --有无公告 0无1有
    GameData.ISHasNotice = message:PopByte()        -- 是否有公告( 0:无 1:有 )
    
    if GameData.ISHasNotice == 1 then
        GameData.NoticeTitle = message:PopString()  -- 标题
        GameData.NoticeContent = message:PopString()-- 内容
        OpenLoginNoticeUI()
    end
    print("=====199=====", GameData.ISHasNotice, GameData.GameServerStatus)

    GameConfig.GameServerIP = CS.Utility.GetGameServerIP(GameConfig.GameServerURL)
    if GameData.GameServerStatus ~= 0 then
        NetMsgHandler.TryConnectGameServer()--连到游戏服
    end
   
    -- 关闭掉 HubServer
    if not GameConfig.IsDebug then
        CS.Net.ConnectManager:Instance():CloseNetworkClient("HubServer")
        hubNetClient = nil
    end
end

-- 开启登录公告
function  OpenLoginNoticeUI()
    if CS.WindowManager.Instance:FindWindowNodeByName("Notice") == nil then
        local openparam = CS.WindowNodeInitParam("Notice")
        CS.WindowManager.Instance:OpenWindow(openparam)
    end
end

-- 初始化登陆服务器连接
function NetMsgHandler.InitLoginNetClient()
    -- 200-209
    print("注册网络消息处理11111111111111111111")
    gameNetClient:RegisterParser(ProtrocolID.S_SFT_PAY_RESULT, NetMsgHandler.HandleSFTPayResult)
    gameNetClient:RegisterParser(ProtrocolID.CS_Login, NetMsgHandler.HandleReceivedLogin)
    gameNetClient:RegisterParser(ProtrocolID.S_Disconnect, NetMsgHandler.HandleReceivedDisconnect)
    gameNetClient:RegisterParser(ProtrocolID.CS_User_Return, NetMsgHandler.Handle_CS_User_Return)
    gameNetClient:RegisterParser(ProtrocolID.S_Update_Diamond, NetMsgHandler.HandleReceivedUpdateDiamond)
    gameNetClient:RegisterParser(ProtrocolID.S_Update_Gold, NetMsgHandler.HandleReceivedUpdateGold)
    gameNetClient:RegisterParser(ProtrocolID.CS_Update_FreeGold, NetMsgHandler.HandleReceivedUpdateFreeGold)
    gameNetClient:RegisterParser(ProtrocolID.S_Update_RoomCard, NetMsgHandler.HandleReceivedUpdateRoomCard)
    gameNetClient:RegisterParser(ProtrocolID.S_Update_Charge, NetMsgHandler.HandleReceivedUpdateCharge)
    gameNetClient:RegisterParser(ProtrocolID.CS_Convert_Gold, NetMsgHandler.HandleReceivedConvertGoldResult)
    gameNetClient:RegisterParser(ProtrocolID.CS_Convert_RoomCard, NetMsgHandler.HandleReceivedConvertRoomCardResult)
    gameNetClient:RegisterParser(ProtrocolID.CS_BIND_ACCOUNT, NetMsgHandler.OnServerBindAccountResult)

    --214 商店玩家再充值多少钱可达到VIP什么等级
    gameNetClient:RegisterParser(ProtrocolID.CS_Store_Upgrade_Vip, NetMsgHandler.Received_CS_Store_VIP_Info)
    --215~218 玩家反馈意见
    gameNetClient:RegisterParser(ProtrocolID.CS_Contact_CustomerService, NetMsgHandler.Received_CS_Contact_CustomerService)
    gameNetClient:RegisterParser(ProtrocolID.CS_YYIM_REQUEST, NetMsgHandler.Received_CS_YYIM_REQUEST)
    gameNetClient:RegisterParser(ProtrocolID.CS_YYIM_FORWARDING, NetMsgHandler.Received_CS_YYIM_FORWARDING)
    -- 234~236
    gameNetClient:RegisterParser(ProtrocolID.CS_INVITE_FREE_MEMBER, NetMsgHandler.Received_CS_INVITE_FREE_MEMBER)
    gameNetClient:RegisterParser(ProtrocolID.CS_INVITE_FREE_GAME, NetMsgHandler.Received_CS_INVITE_FREE_GAME)
    gameNetClient:RegisterParser(ProtrocolID.S_INVITE_PLAY, NetMsgHandler.Received_S_INVITE_PLAY)
    -- 240-241
    gameNetClient:RegisterParser(ProtrocolID.CS_NEW_REWARD, NetMsgHandler.Received_CS_NEW_REWARD)
    gameNetClient:RegisterParser(ProtrocolID.CS_IP_LOCATION, NetMsgHandler.Received_CS_IP_LOCATION)
    -- 242 玩家分享微信成功
    gameNetClient:RegisterParser(ProtrocolID.CS_WECHAT_SHARE, NetMsgHandler.Received_CS_WECHAT_SHARE)
    -- 243 玩家请求分享链接
    gameNetClient:RegisterParser(ProtrocolID.CS_HALL_SHARE_URL, NetMsgHandler.Received_CS_HALL_SHARE_URL)

    -- 244 公告内容
    gameNetClient:RegisterParser(ProtrocolID.CS_ADVERTISE_INFO, NetMsgHandler.Received_CS_ADVERTISE_INFO)
    -- 1156 公告标签
    gameNetClient:RegisterParser(ProtrocolID.CS_ADVERTISE_NAME, NetMsgHandler.Received_CS_ADVERTISE_NAME)

    --218~233 (茶馆相关)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_JOIN, NetMsgHandler.Received_CS_TEA_JOIN)
    gameNetClient:RegisterParser(ProtrocolID.S_TEA_JOIN_NOTIFY, NetMsgHandler.Received_S_TEA_JOIN_NOTIFY)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_CREATE, NetMsgHandler.Received_CS_TEA_CREATE)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_INFO, NetMsgHandler.Received_CS_TEA_INFO)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_MEMBER, NetMsgHandler.Received_CS_TEA_MEMBER)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_UPGRADE, NetMsgHandler.Received_CS_TEA_UPGRADE)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_APPLY, NetMsgHandler.Received_CS_TEA_APPLY)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_APPLY_HANDLE, NetMsgHandler.Received_CS_TEA_APPLY_HANDLE)
    gameNetClient:RegisterParser(ProtrocolID.S_TEA_APPLY_FEEDBACK, NetMsgHandler.Received_S_TEA_APPLY_FEEDBACK)
    gameNetClient:RegisterParser(ProtrocolID.S_TEA_NEW_MEMBER, NetMsgHandler.Received_S_TEA_NEW_MEMBER)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_APPLY_ALL, NetMsgHandler.Received_CS_TEA_APPLY_ALL)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_DEL_MEMBER, NetMsgHandler.Received_CS_TEA_DEL_MEMBER)
    gameNetClient:RegisterParser(ProtrocolID.S_TEA_KICKOUT, NetMsgHandler.Received_S_TEA_KICKOUT)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_QUIT, NetMsgHandler.Received_CS_TEA_QUIT)
    gameNetClient:RegisterParser(ProtrocolID.CS_TEA_ROOMLIST, NetMsgHandler.Received_CS_TEA_ROOMLIST)
    gameNetClient:RegisterParser(ProtrocolID.S_TEA_QUIT_MEMBER, NetMsgHandler.Received_S_TEA_QUIT_MEMBER)

    --251~261 直充直兑相关
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_Recharge, NetMsgHandler.Received_CS_Player_Recharge)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_Extract, NetMsgHandler.Received_CS_Player_Extract)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_BindingBankCard, NetMsgHandler.Received_CS_Player_BindingBankCardOK)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_BankInformation, NetMsgHandler.Received_CS_Player_BindingBankCard)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_BillDetailed, NetMsgHandler.Received_CS_Player_BillDetailed)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_ExtractInfo, NetMsgHandler.Received_CS_Player_ExtractInfo)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_BankiCardInfo, NetMsgHandler.Received_CS_Player_BankiCardInfo)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_ZFBInfo, NetMsgHandler.Received_CS_Player_ZFBInfo)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_BindingZhiFuBao, NetMsgHandler.Received_CS_Player_BindingZhiFuBao)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_RechargeInterfaceInfo, NetMsgHandler.Received_CS_Player_RechargeInterfaceInfo)
    gameNetClient:RegisterParser(ProtrocolID.CS_Official_Recharge, NetMsgHandler.Received_CS_Official_Recharge)
    gameNetClient:RegisterParser(ProtrocolID.CS_Official_OrderInformation, NetMsgHandler.Received_CS_Official_OrderInformation)

    -- 271~275代理人相关
    gameNetClient:RegisterParser(ProtrocolID.S_Player_BecomeAgent, NetMsgHandler.Received_S_Player_BecomeAgent)
    gameNetClient:RegisterParser(ProtrocolID.CS_Open_MyAgency, NetMsgHandler.Received_CS_OpenMyAgency)
    gameNetClient:RegisterParser(ProtrocolID.CS_Get_AgencyCommission, NetMsgHandler.Received_CS_Get_AgencyCommission)
    gameNetClient:RegisterParser(ProtrocolID.CS_Agency_Extract_Data, NetMsgHandler.Received_CS_Agency_Extract_Data)
    gameNetClient:RegisterParser(ProtrocolID.CS_Open_MenberDetail, NetMsgHandler.Received_CS_MemberDetails)
    
    -- 237 玩家请求代理充值相关
    gameNetClient:RegisterParser(ProtrocolID.CS_DaiLiRechargeInfo, NetMsgHandler.Received_CS_DaiLiRechargeInfo)
    -- 238 玩家投诉代理充值
    gameNetClient:RegisterParser(ProtrocolID.CS_ComplaintAgent, NetMsgHandler.Received_CS_ComplaintAgent)
    
    
    -- 352~360
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_FalseDeal_Start, NetMsgHandler.Received_S_Notify_FalseDeal_Start)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Wait_State, NetMsgHandler.Received_S_Notify_Wait_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Shuffle_State, NetMsgHandler.Received_S_Notify_Shuffle_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Cut_State, NetMsgHandler.Received_S_Notify_Cut_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Play_Cut_State, NetMsgHandler.Received_S_Notify_Play_Cut_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Bet_State, NetMsgHandler.Received_S_Notify_Bet_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Deal_State, NetMsgHandler.Received_S_Notify_Deal_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Long_Check_State, NetMsgHandler.Received_S_Notify_Long_Check_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Hu_Check_State, NetMsgHandler.Received_S_Notify_Hu_Check_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Settlement_State, NetMsgHandler.Received_S_Notify_Settlement_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Check1_Over, NetMsgHandler.Received_S_Notify_Check1_Over)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Check2_Over, NetMsgHandler.Received_S_Notify_Check2_Over)

    -- 400~404
    gameNetClient:RegisterParser(ProtrocolID.CS_Enter_Room, NetMsgHandler.Received_CS_Enter_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_Exit_Room, NetMsgHandler.Received_CS_Exit_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_Create_Room, NetMsgHandler.Received_CS_Create_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_Bet, NetMsgHandler.Received_CS_Bet)
    gameNetClient:RegisterParser(ProtrocolID.CS_Check_Card_Process, NetMsgHandler.Received_CS_Check_Card_Process)

    -- 405~409
    gameNetClient:RegisterParser(ProtrocolID.CS_Checked_Card, NetMsgHandler.Received_CS_Checked_Card)
    gameNetClient:RegisterParser(ProtrocolID.S_Bet_Rank_List, NetMsgHandler.Received_S_Bet_Rank_List)
    gameNetClient:RegisterParser(ProtrocolID.CS_BRJH_Hall_Request_Statistics, NetMsgHandler.Received_CS_BRJH_Hall_Request_Statistics)
    gameNetClient:RegisterParser(ProtrocolID.S_BRJH_Game_Statistics, NetMsgHandler.Received_S_BRJH_Game_Statistics)
    gameNetClient:RegisterParser(ProtrocolID.S_BRJH_Game_Append_Statistics, NetMsgHandler.Received_S_BRJH_Game_Append_Statistics)

    -- 410~418
    gameNetClient:RegisterParser(ProtrocolID.CS_Request_Relative_Room, NetMsgHandler.Received_CS_Request_Relative_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_Set_Bet_First, NetMsgHandler.Received_S_Set_Bet_First)
    gameNetClient:RegisterParser(ProtrocolID.S_Set_Game_Data, NetMsgHandler.Received_S_Set_Game_Data)
    gameNetClient:RegisterParser(ProtrocolID.CS_Vip_Start_Game, NetMsgHandler.Received_CS_Vip_Start_Game)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Game_End, NetMsgHandler.Received_S_Notify_Game_End)
    gameNetClient:RegisterParser(ProtrocolID.CS_Request_Continue_Game, NetMsgHandler.Received_CS_Request_Continue_Game)
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Game_Player_Count, NetMsgHandler.Received_S_Notify_Game_Player_Count)
    gameNetClient:RegisterParser(ProtrocolID.CS_Up_Banker, NetMsgHandler.Received_CS_Up_Banker)
    gameNetClient:RegisterParser(ProtrocolID.CS_Up_Banker_List, NetMsgHandler.Received_CS_Up_Banker_List)

    -- 420~430
    gameNetClient:RegisterParser(ProtrocolID.S_Notify_Win_Gold, NetMsgHandler.Received_S_Notify_Win_Gold)
    gameNetClient:RegisterParser(ProtrocolID.S_Update_Banker, NetMsgHandler.Received_S_Update_Banker)
    gameNetClient:RegisterParser(ProtrocolID.S_Update_Banker_Gold, NetMsgHandler.Received_S_Update_Banker_Gold)
    gameNetClient:RegisterParser(ProtrocolID.CS_Cut_Card, NetMsgHandler.Received_CS_Cut_Card)
    gameNetClient:RegisterParser(ProtrocolID.CS_Request_Role_List, NetMsgHandler.Received_CS_Request_Role_List)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_Cut_Type, NetMsgHandler.Received_CS_Player_Cut_Type)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_Icon_Change, NetMsgHandler.Received_CS_Player_Icon_Change)
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_YuYinChat, NetMsgHandler.Received_CS_Player_YuYinChat)
    gameNetClient:RegisterParser(ProtrocolID.CS_Apply_Down_Banker, NetMsgHandler.Received_CS_Apply_Down_Banker)
    gameNetClient:RegisterParser(ProtrocolID.CS_Apply_Banker_State, NetMsgHandler.Received_CS_Apply_Banker_State)
    gameNetClient:RegisterParser(ProtrocolID.S_Room_Change, NetMsgHandler.Received_S_Room_Change)
    -- 431~432
    gameNetClient:RegisterParser(ProtrocolID.CS_Player_BeneFit, NetMsgHandler.Accept_CS_Player_BeneFit)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_XYZPRoomList,NetMsgHandler.Accept_CS_JH_XYZPInfo)



    -- 433~434
    gameNetClient:RegisterParser(ProtrocolID.CS_Daily_Wheel_Info,NetMsgHandler.Received_CS_Daily_Wheel_Info)
    gameNetClient:RegisterParser(ProtrocolID.CS_Daily_Wheel_Reward,NetMsgHandler.Received_CS_Daily_Wheel_Reward)
    gameNetClient:RegisterParser(ProtrocolID.CS_CDK_Reward,NetMsgHandler.Received_CS_CDK_Reward)

    gameNetClient:RegisterParser(ProtrocolID.CS_Wheel_Record, NetMsgHandler.Received_CS_Wheel_Record)

    -- 436~437 代理抽iPhone相关
    gameNetClient:RegisterParser(ProtrocolID.CS_IPHONE_INFO,NetMsgHandler.Received_CS_iPhone_Info)
    gameNetClient:RegisterParser(ProtrocolID.CS_IPHONE_Reward,NetMsgHandler.Received_CS_iPhone_LuckDraw)

    -- 438 轮盘分享朋友圈
    --gameNetClient:RegisterParser(ProtrocolID.CS_Wheel_Record,NetMsgHandler.Received_CS_BonusWhell_Share_OK)

    -- 439~440 轮盘相关
    gameNetClient:RegisterParser(ProtrocolID.CS_Exit_Wheel,NetMsgHandler.Received_CS_Exit_Wheel)
    gameNetClient:RegisterParser(ProtrocolID.S_Wheel_WinningInfo,NetMsgHandler.Received_S_Wheel_WinningInfo)

    -- 441 奔驰宝马中奖玩家信息
    gameNetClient:RegisterParser(ProtrocolID.S_Car_WinningInfo,NetMsgHandler.Received_S_Car_WinningInfo)
    -- 442 时时彩中奖玩家信息
    gameNetClient:RegisterParser(ProtrocolID.S_SSC_WinningInfo,NetMsgHandler.Received_S_SSC_WinningInfo)
    -- 443
    gameNetClient:RegisterParser(ProtrocolID.CS_BRJH_Hall_Request_Statistics_New8, NetMsgHandler.Received_CS_BRJH_Hall_Request_Statistics_New8)
    -- 500
    gameNetClient:RegisterParser(ProtrocolID.S_Add_MoveNotice, NetMsgHandler.HandleAddMoveNotice);
    -- 501
    gameNetClient:RegisterParser(ProtrocolID.CS_SmallHorn, NetMsgHandler.HandleSmallHorn);
    -- 502
    gameNetClient:RegisterParser(ProtrocolID.CS_SEND_EMAIL, NetMsgHandler.HandleSendEmailResult);
    -- 503
    gameNetClient:RegisterParser(ProtrocolID.CS_CHECK_ACCOUNTID, NetMsgHandler.HandleCheckAccountIDResult);
    -- 504
    gameNetClient:RegisterParser(ProtrocolID.CS_OTHER_PLAYER_INFO, NetMsgHandler.HandleOtherPlayerInfoResult);
    -- 506
    gameNetClient:RegisterParser(ProtrocolID.CS_GET_EMAIL_REWARD, NetMsgHandler.HandleGetEmailRewardResult);
    -- 507
    gameNetClient:RegisterParser(ProtrocolID.CS_ADD_EMAILS, NetMsgHandler.HandleReceiveEmail);
    -- 508
    gameNetClient:RegisterParser(ProtrocolID.CS_DELETE_EMAIL, NetMsgHandler.HandleDeleteEmail);
    -- 509
    gameNetClient:RegisterParser(ProtrocolID.CS_MODIFY_NAME, NetMsgHandler.HandleModifyName);
    -- 510
    gameNetClient:RegisterParser(ProtrocolID.CS_ALL_RANK, NetMsgHandler.HandleAllRankInfo)
    -- 512 - 513
    gameNetClient:RegisterParser(ProtrocolID.CS_PAOPAO_CHAT, NetMsgHandler.HandleChatPaoPao)
    gameNetClient:RegisterParser(ProtrocolID.CS_Request_Game_History, NetMsgHandler.Received_CS_Request_Game_History)
    -- 601 - 603
    gameNetClient:RegisterParser(ProtrocolID.CS_Invite_Code, NetMsgHandler.Received_CS_Invite_Code)
    gameNetClient:RegisterParser(ProtrocolID.S_Update_Promoter, NetMsgHandler.Receivde_S_Update_Pomoter)
    gameNetClient:RegisterParser(ProtrocolID.CS_SALESMAN_INFO, NetMsgHandler.Received_CS_SALESMAN_INFO)

    -- 红包接龙相关协议 711 -- 725
    gameNetClient:RegisterParser(ProtrocolID.CS_HB_RoomList, NetMsgHandler.Received_CS_HBRoomList)
    gameNetClient:RegisterParser(ProtrocolID.CS_HB_Create_Room, NetMsgHandler.Received_CS_HB_Create_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_HB_Enter_Room, NetMsgHandler.Received_CS_HB_Enter_Room1)
    gameNetClient:RegisterParser(ProtrocolID.CS_HB_Room_History, NetMsgHandler.Received_CS_HB_Room_History)
    gameNetClient:RegisterParser(ProtrocolID.S_HB_Set_Game_Date, NetMsgHandler.Received_S_HB_Set_Game_Data)
    gameNetClient:RegisterParser(ProtrocolID.CS_HB_Leave_Room, NetMsgHandler.Received_CS_HB_Leave_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_HB_Next_State, NetMsgHandler.Received_S_HB_Next_State)
    gameNetClient:RegisterParser(ProtrocolID.CS_HB_Banker_FaHongBao, NetMsgHandler.Received_CS_HB_Banker_FaHongBao)
    gameNetClient:RegisterParser(ProtrocolID.CS_HB_Player_QiangHongBao, NetMsgHandler.Received_CS_HB_Player_QiangHongBao)
    gameNetClient:RegisterParser(ProtrocolID.S_HB_Add_Player, NetMsgHandler.Received_S_HB_AddPlayer)
    gameNetClient:RegisterParser(ProtrocolID.S_HB_Delete_Player, NetMsgHandler.Received_S_HB_DeletePlayer)

    -- 匹配红包请求房间在线人数 729
    gameNetClient:RegisterParser(ProtrocolID.CS_PPHB_OnlineNumber, NetMsgHandler.Received_CS_PP_HongBaoRoomOnlineCount)

    --===============【推筒子协议】[740~753]=============
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_PIPEI_ONLINE, NetMsgHandler.Received_CS_TTZPP_Room_OnLine)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_ZUJU_ROOM_LIST, NetMsgHandler.Received_CS_TTZRoom_RoomList)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_ZUJU_CREATE,  NetMsgHandler.Received_CS_TTZ_Room_Create)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_ZUJU_ENTER_ROOM, Received_CS_TTZ_ZUJU_ENTER_ROOM)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_PIPEI_ENTER_ROOM, Received_CS_TTZ_PIPEI_ENTER_ROOM)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_LEAVE_ROOM, Received_CS_TTZ_LEAVE_ROOM)
    gameNetClient:RegisterParser(ProtrocolID.S_TTZ_ROOM_DATA, Received_S_TTZ_ROOM_DATA)
    gameNetClient:RegisterParser(ProtrocolID.S_TTZ_NEXT_STATE, Received_S_TTZ_NEXT_STATE)
    gameNetClient:RegisterParser(ProtrocolID.S_TTZ_ADD_PLAYER, Received_S_TTZ_ADD_PLAYER)
    gameNetClient:RegisterParser(ProtrocolID.S_TTZ_REMOVE_PLAYER, Received_S_TTZ_REMOVE_PLAYER)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_READY, Received_CS_TTZ_READY)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_QIANG_ZHUANG, Received_CS_TTZ_QIANG_ZHUANG)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_BETTING, Received_CS_TTZ_BETTING)
    gameNetClient:RegisterParser(ProtrocolID.CS_TTZ_KANPAI, Received_CS_TTZ_KANPAI)

    --===============【麻将协议】[761~779]=============
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_ZUJU_ROOM_LIST, NetMsgHandler.Received_CS_MJRoom_RoomList)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_ZUJU_CREATE, NetMsgHandler.Received_CS_MJ_Room_Create)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_ZUJU_ENTER_ROOM, NetMsgHandler.Received_CS_MJ_ZUJU_ENTER_ROOM)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_LEAVE_ROOM, NetMsgHandler.Received_CS_MJ_LEAVE_ROOM)
    gameNetClient:RegisterParser(ProtrocolID.S_MJ_ROOM_DATA, NetMsgHandler.Received_S_MJ_ROOM_DATA)
    gameNetClient:RegisterParser(ProtrocolID.S_MJ_NEXT_STATE, NetMsgHandler.Received_S_MJ_NEXT_STATE)
    gameNetClient:RegisterParser(ProtrocolID.S_MJ_ADD_PLAYER, NetMsgHandler.Received_S_MJ_ADD_PLAYER)
    gameNetClient:RegisterParser(ProtrocolID.S_MJ_REMOVE_PLAYER, NetMsgHandler.Received_S_MJ_REMOVE_PLAYER)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_Prepare_Game, NetMsgHandler.Received_CS_Prepare_Game)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_DingQue, NetMsgHandler.Received_CS_DingQue)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_PlayerChuPai, NetMsgHandler.Received_CS_MJ_PlayerChuPai)
    gameNetClient:RegisterParser(ProtrocolID.S_MJ_MoPai, NetMsgHandler.Received_CS_MJ_MoPai)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_PengGangHu, NetMsgHandler.Received_CS_MJ_PengGangHu)
    gameNetClient:RegisterParser(ProtrocolID.S_MJ_UpdateGold, NetMsgHandler.Received_CS_MJ_PlayerUpdateGold)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_TheBureauGameWater, NetMsgHandler.Received_CS_MJ_TheBureauGameWater)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_GameWater, NetMsgHandler.Received_CS_MJ_GameWater)
    gameNetClient:RegisterParser(ProtrocolID.CS_MJ_GameRank, NetMsgHandler.Received_CS_MJ_GameRank)
    gameNetClient:RegisterParser(ProtrocolID.S_MJ_PLAYERTRANSPORT, NetMsgHandler.Received_S_MJ_PLAYERTRANSPORT)
    gameNetClient:RegisterParser(ProtrocolID.S_MJ_QIANGGANGHU, NetMsgHandler.ReceivedS_MJ_QIANGGANGHU)

    -- 800
    gameNetClient:RegisterParser(ProtrocolID.CS_Enter_JZ_RoomID, NetMsgHandler.Received_CS_ZJ_RoomID)

    -- 801--814
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Create_Room, NetMsgHandler.Received_CS_JH_Create_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Enter_Room1, NetMsgHandler.Received_CS_JH_Enter_Room1)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Enter_Room2, NetMsgHandler.Received_CS_JH_Enter_Room2)
    gameNetClient:RegisterParser(ProtrocolID.S_JH_Set_Game_Data, NetMsgHandler.Received_S_JH_Set_Game_Data)
    gameNetClient:RegisterParser(ProtrocolID.S_JH_Next_State, NetMsgHandler.Received_S_JH_Next_State)
    gameNetClient:RegisterParser(ProtrocolID.S_JH_Add_Player, NetMsgHandler.Received_S_JH_Add_Player)
    gameNetClient:RegisterParser(ProtrocolID.S_JH_Delete_Player, NetMsgHandler.Received_S_JH_Delete_Player)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Exit_Room, NetMsgHandler.Received_CS_JH_Exit_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Ready, NetMsgHandler.Received_CS_JH_Ready)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Betting, NetMsgHandler.Received_CS_JH_Betting)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_VS_Card, NetMsgHandler.Received_CS_JH_VS_Card)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Drop_Card, NetMsgHandler.Received_CS_JH_Drop_Card)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Look_Card, NetMsgHandler.Received_CS_JH_Look_Card)
    gameNetClient:RegisterParser(ProtrocolID.S_JH_Notify_Look_Card, NetMsgHandler.Received_S_JH_Notify_Look_Card)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_ZuJuRoomList, NetMsgHandler.Received_CS_JH_ZuJuRoomList)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_MenJiRoomOnlineCount, NetMsgHandler.Received_CS_JH_MenJiRoomOnlineCount)
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_Change_MenJiRoom, NetMsgHandler.Received_CS_JH_Change_MenJiRoom)
    gameNetClient:RegisterParser(ProtrocolID.S_JH_Kick_Out, NetMsgHandler.Received_S_JH_Kick_Out)
    gameNetClient:RegisterParser(ProtrocolID.S_JH_Gold_Update, NetMsgHandler.ZUJU_Gold_Update)

    -- 时时彩相关 831 -- 833
    gameNetClient:RegisterParser(ProtrocolID.CS_Lottery_Info, NetMsgHandler.Accept_CS_ProcessingLottery)
    gameNetClient:RegisterParser(ProtrocolID.CS_Lottery_Bet,NetMsgHandler.Accept_CS_LotteryForBet)
    gameNetClient:RegisterParser(ProtrocolID.S_Bet_Victory,NetMsgHandler.Accept_S_BetVictory)
    gameNetClient:RegisterParser(ProtrocolID.C_QuitLottery,NetMsgHandler.Send_CS_QuitLottery)
    --TUDOU
    gameNetClient:RegisterParser(ProtrocolID.CS_ShiShiCaiInRoom, NetMsgHandler.Receive_CS_ShiShiCaiInRoom);
    gameNetClient:RegisterParser(ProtrocolID.CS_SSCRoomPlayerList, NetMsgHandler.Received_CS_SSC_Request_Role_List);

    -- 奔驰宝马相关 837~849
    gameNetClient:RegisterParser(ProtrocolID.CS_CarPrizeDraw_BankerListInfo,NetMsgHandler.Received_CS_BankerListInfo)
    gameNetClient:RegisterParser(ProtrocolID.CS_CarPrizeDraw_Info,NetMsgHandler.Received_CS_CarInfo)
    --TUDOU
    gameNetClient:RegisterParser(ProtrocolID.CS_BCBMRoomPlayerList, NetMsgHandler.Received_CS_BCBM_Request_Role_List);

    gameNetClient:RegisterParser(ProtrocolID.CS_CarInfoInRoom,NetMsgHandler.Receive_CS_CarInfoInRoom)
    gameNetClient:RegisterParser(ProtrocolID.CS_CarPrizeDraw_Bet,NetMsgHandler.Received_CS_Car_Bet)
    gameNetClient:RegisterParser(ProtrocolID.CS_CarPrizeDraw_DoBanker,NetMsgHandler.Received_CS_Car_UpperDealer)
    gameNetClient:RegisterParser(ProtrocolID.CS_CarPrizeDraw_NotDoBanker,NetMsgHandler.Received_CS_Car_LowerDealer)
    gameNetClient:RegisterParser(ProtrocolID.S_CarPrizeDraw_Winning,NetMsgHandler.Received_CS_Car_BetWinner)
    gameNetClient:RegisterParser(ProtrocolID.S_CarPrizeDraw_ChangeBanker,NetMsgHandler.Received_CS_Car_ReplaceDealer)
    gameNetClient:RegisterParser(ProtrocolID.S_CarPrizeDraw_BankerSettlement,NetMsgHandler.Received_CS_Car_Dealer_Settlement)
    gameNetClient:RegisterParser(ProtrocolID.C_CarPrizeDraw_Quit,NetMsgHandler.Received_CS_QuitCar)

    -- 组局牛牛相关 850~862
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_RoomList, Received_CS_ZJRoom_RoomList)
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_Room_Create, Received_CS_NN_Room_Create)
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_Enter_Room, Received_CS_NN_Enter_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_Leave_Room, Received_CS_NN_Leave_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_Ready, Received_CS_NN_Ready)
    gameNetClient:RegisterParser(ProtrocolID.S_NN_AddPlayer, Received_S_ZJRoom_AddPlayer)
    gameNetClient:RegisterParser(ProtrocolID.S_NN_DeletePlayer, Received_S_ZJRoom_DeletePlayer)
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_QiangZhuang, Received_CS_ZJRoom_QiangZhuang)
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_JiaBei, Received_CS_ZJRoom_XuanDouble)
    gameNetClient:RegisterParser(ProtrocolID.S_NN_Get_Game_Data, Received_S_NN_Get_Game_Data)
    gameNetClient:RegisterParser(ProtrocolID.S_NN_Enter_Next_State, Received_S_NN_Enter_Next_State)
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_CuoPai, Received_CS_ZJRoom_CuoPai)
    gameNetClient:RegisterParser(ProtrocolID.CS_NN_Room_History, Received_CS_NN_Room_History)
    gameNetClient:RegisterParser(ProtrocolID.CS_NNPP_Room_OnLine, Received_CS_NNPP_Room_OnLine)
    gameNetClient:RegisterParser(ProtrocolID.CS_NNPP_Enter_Room, Received_CS_NNPP_Enter_Room)

    -- 玩牌抽话费相关 880~887
    gameNetClient:RegisterParser(ProtrocolID.S_Task_Fail, NetMsgHandler.Received_S_Task_Fail)
    gameNetClient:RegisterParser(ProtrocolID.S_Task_Info, NetMsgHandler.Received_S_Task_Info)
    gameNetClient:RegisterParser(ProtrocolID.S_Task_Success, NetMsgHandler.Received_S_Task_Success)
    gameNetClient:RegisterParser(ProtrocolID.S_Update_TaskCompleteNumber, NetMsgHandler.Received_S_TaskCompleteNumber)
    gameNetClient:RegisterParser(ProtrocolID.CS_LuckDraw_Bill, NetMsgHandler.Received_CS_LuckDraw_Bill)
    gameNetClient:RegisterParser(ProtrocolID.CS_Bill_Exchange, NetMsgHandler.Received_CS_Exchange_Bill)
    gameNetClient:RegisterParser(ProtrocolID.CS_Bill_Exchange_Info, NetMsgHandler.Received_CS_Exchange_Bill_Info)
    gameNetClient:RegisterParser(ProtrocolID.S_PrizeInfo, NetMsgHandler.Received_S_PrizeInfo)

    --客服咨询相关 1008-1011
    gameNetClient:RegisterParser(ProtrocolID.CS_PlayerSendInfo, NetMsgHandler.Received_CS_BackSendInfo)
    gameNetClient:RegisterParser(ProtrocolID.S_SendToPlayer, NetMsgHandler.Received_S_KFZXBackSendInfo)
    gameNetClient:RegisterParser(ProtrocolID.CS_PlayerPullInfo, NetMsgHandler.Received_CS_BackPlayerPullInfo)
    gameNetClient:RegisterParser(ProtrocolID.CS_PlayerOpenUI, NetMsgHandler.Received_CS_PlayerOpenUI)
    
    --推送新的公告
    gameNetClient:RegisterParser(ProtrocolID.S_NoticeNew, NetMsgHandler.Received_S_NoticeNew)

    --1152 宝马奔驰
    gameNetClient:RegisterParser(ProtrocolID.CS_JH_BMBCRoomList,NetMsgHandler.Accept_CS_JH_BMBCInfo)
    gameNetClient:RegisterParser(ProtrocolID.S_Playing_Room,NetMsgHandler.Received_S_Playing_Room)

    

    -- ===========================  1154 玩家被踢出上庄列表 ================================ -- 
    gameNetClient:RegisterParser(ProtrocolID.S_KickOutBankerList,NetMsgHandler.Received_S_KickOutBankerList)


    --===============【跑的快协议】[1200~1219]=============
    gameNetClient:RegisterParser(ProtrocolID.CS_PDKPP_Room_OnLine,NetMsgHandler.Received_CS_PDKPP_Room_OnLine)
    gameNetClient:RegisterParser(ProtrocolID.CS_PDK_Ready,NetMsgHandler.Received_CS_PDK_Ready)
    gameNetClient:RegisterParser(ProtrocolID.CS_PDK_PlayerChuPai,NetMsgHandler.Received_CS_PDK_PlayerOutPoker)
    gameNetClient:RegisterParser(ProtrocolID.CS_PDK_Leave_Room,NetMsgHandler.Received_CS_PDK_Leave_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_PDK_Enter_Next_State,NetMsgHandler.Received_S_PDK_Enter_Next_State)
    gameNetClient:RegisterParser(ProtrocolID.S_PDK_DeletePlayer,NetMsgHandler.Received_S_ZJRoom_DeletePlayer)
    gameNetClient:RegisterParser(ProtrocolID.CS_PDKPP_Enter_Room,NetMsgHandler.Received_CS_PDKPP_Enter_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_PDK_AddPlayer,NetMsgHandler.Received_S_ZJPDKRoom_AddPlayer)
    gameNetClient:RegisterParser(ProtrocolID.S_PDK_GAME_DATA,NetMsgHandler.Received_S_PDK_Get_Game_Data)
    gameNetClient:RegisterParser(ProtrocolID.CS_PDK_ROBOT,NetMsgHandler.Received_CS_PDK_ROBOT)
    gameNetClient:RegisterParser(ProtrocolID.CS_PDK_Prompt,NetMsgHandler.Received_CS_PDK_Prompt)
    gameNetClient:RegisterParser(ProtrocolID.S_PDK_BombChangeGold,NetMsgHandler.Received_S_PDK_BombChangeGold)


    --===============[龙虎斗]相关协议[1251~1266]==================================
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Hall_Room, NetMsgHandler.Received_CS_LHD_Hall_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Hall_Room_New8, NetMsgHandler.Received_CS_LHD_Hall_Room_New8)--1267
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Enter_Room, NetMsgHandler.Received_CS_LHD_Enter_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_LHD_GameData, NetMsgHandler.Received_S_LHD_GameData)
    gameNetClient:RegisterParser(ProtrocolID.S_LHD_Game_Statistics, NetMsgHandler.Received_S_LHD_Game_Statistics)
    gameNetClient:RegisterParser(ProtrocolID.S_LHD_Game_Append_Statistics, NetMsgHandler.Received_S_LHD_Game_Append_Statistics)
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Exit_Room, NetMsgHandler.Received_CS_LHD_Exit_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_LHD_Kick_Room, NetMsgHandler.Received_S_LHD_Kick_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_LHD_Next_State, NetMsgHandler.Received_S_LHD_Next_State)
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Bet, NetMsgHandler.Received_CS_LHD_Bet)
    gameNetClient:RegisterParser(ProtrocolID.S_LHD_Game_Player_Count, NetMsgHandler.Received_S_LHD_Game_Player_Count)
    gameNetClient:RegisterParser(ProtrocolID.S_LHD_Update_Banker, NetMsgHandler.Received_S_LHD_Update_Banker)
    gameNetClient:RegisterParser(ProtrocolID.S_LHD_Update_Banker_Gold, NetMsgHandler.Received_S_LHD_Update_Banker_Gold)
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Request_Role_List, NetMsgHandler.Received_CS_LHD_Request_Role_List)
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Up_Banker_List, NetMsgHandler.Received_CS_LHD_Up_Banker_List)
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Up_Banker, NetMsgHandler.Received_CS_LHD_Up_Banker)
    gameNetClient:RegisterParser(ProtrocolID.CS_LHD_Down_Banker, NetMsgHandler.Received_CS_LHD_Down_Banker)

    --===============[百家乐]相关协议[1271~1280]==================================
    gameNetClient:RegisterParser(ProtrocolID.CS_BJL_Hall_Room, BJLGameMgr.Received_CS_BJL_Hall_Room)
    gameNetClient:RegisterParser(ProtrocolID.CS_BJL_Hall_Room_New8, BJLGameMgr.Received_CS_BJL_Hall_Room_New8)
    gameNetClient:RegisterParser(ProtrocolID.CS_BJL_Enter_Room, BJLGameMgr.Received_CS_BJL_Enter_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_BJL_GameData, BJLGameMgr.Received_S_BJL_GameData)
    gameNetClient:RegisterParser(ProtrocolID.S_BJL_Game_Statistics, BJLGameMgr.Received_S_BJL_Game_Statistics)
    gameNetClient:RegisterParser(ProtrocolID.S_BJL_Game_Append_Statistics, BJLGameMgr.Received_S_BJL_Game_Append_Statistics)
    gameNetClient:RegisterParser(ProtrocolID.CS_BJL_Exit_Room, BJLGameMgr.Received_CS_BJL_Exit_Room)
    gameNetClient:RegisterParser(ProtrocolID.S_BJL_Next_State, BJLGameMgr.Received_S_BJL_Next_State)
    gameNetClient:RegisterParser(ProtrocolID.CS_BJL_Bet, BJLGameMgr.Received_CS_BJL_Bet)
    gameNetClient:RegisterParser(ProtrocolID.S_BJL_Game_Player_Count, BJLGameMgr.Received_S_BJL_Game_Player_Count)
    gameNetClient:RegisterParser(ProtrocolID.CS_BJL_Request_Role_List, BJLGameMgr.Received_CS_BJL_Request_Role_List)

    -- =====================房间维护消息通知 1504==========================
    gameNetClient:RegisterParser(ProtrocolID.S_RoomMaintainNews, NetMsgHandler.Received_S_RoomMaintainNews)
    -- =====================请求房间列表配置 1505===========================
    gameNetClient:RegisterParser(ProtrocolID.CS_RoomListRoommTypeInfo, NetMsgHandler.Received_CS_RoomListRoommTypeInfo)

    -- ========================= 余额宝相关 1601 ========================
    gameNetClient:RegisterParser(ProtrocolID.CS_YueBaoPassWord, NetMsgHandler.Receivde_CS_YueBaoPassWord)
    gameNetClient:RegisterParser(ProtrocolID.CS_PassWordYanZheng, NetMsgHandler.Received_CS_PassWordYanZheng)
    gameNetClient:RegisterParser(ProtrocolID.CS_ChangeYueBaoPassWord, NetMsgHandler.Received_CS_ChangeYueBaoPassWord)
    gameNetClient:RegisterParser(ProtrocolID.CS_YueBaoTurnOutValue, NetMsgHandler.Received_CS_YueBaoTurnOutValue)
    gameNetClient:RegisterParser(ProtrocolID.CS_YueBaoIntoValue, NetMsgHandler.Received_CS_YueBaoIntoValue)
    gameNetClient:RegisterParser(ProtrocolID.CS_YueBaoInvestmentType, NetMsgHandler.Received_CS_YueBaoInvestmentType)
    gameNetClient:RegisterParser(ProtrocolID.CS_YueBaoLineTime, NetMsgHandler.Received_CS_YueBaoLineTime)
    gameNetClient:RegisterParser(ProtrocolID.CS_YueBaoDetailed, NetMsgHandler.Received_CS_YueBaoDetailed)
    gameNetClient:RegisterParser(ProtrocolID.CS_YueBaoMyBuyInfo, NetMsgHandler.Received_CS_YueBaoMyBuyInfo)
    gameNetClient:RegisterParser(ProtrocolID.CS_YueBaoSellOut, NetMsgHandler.Received_CS_YueBaoSellOut)
    gameNetClient:RegisterParser(ProtrocolID.CS_YuEBao_Info, NetMsgHandler.Received_CS_YuEBao_Info)

end

function NetMsgHandler.RegisterGameParser(protrocolID, handler)
    gameNetClient:RegisterParser(protrocolID, handler)
end

function NetMsgHandler.RemoveGameParser(protrocolID, handler)
    if gameNetClient ~= nil then
        gameNetClient:RemoveParser(protrocolID, handler)
    end
end

function NetMsgHandler.CloseConnect()
    if gameNetClient ~= nil then
        -- print("调用raknet的disconnect接口")
        gameNetClient:DisConnect()
    end
end

-- 向GameServer 发送消息
-- protrocolID : ushort 消息编号
-- message ：CS.Net.PushMessage 类型消息
-- openLoadingDataUI: bool 是否开启数据加载界面
function NetMsgHandler.SendMessageToGame(protrocolID, message, openLoadingDataUI)

    if gameNetClient ~= nil then
        if openLoadingDataUI then
            CS.LoadingDataUI.Show()
        end

        gameNetClient:SendMessage(protrocolID, message.Message)
    else
        print('LoginNetClient was null when you want send message[' .. protrocolID .. '] to server, please check and fix this!')
    end
end

-- 可否发送消息
function NetMsgHandler.CanSendMessage()
    if gameNetClient == nil then
        return false
    else
        return gameNetClient:CanSendMessage()
    end
end

function NetMsgHandler.OnCutOut(isCutOut)
    print("===1==切入切出：", isCutOut, GameData.GameState)
    if isConnectingHub then
        print("===3==切入切出：正在连接HubServer")
        return
    end
    
    if GameData.GameState < GAME_STATE.LOGIN then
        print("===4==切入切出：处于登陆状态之前，不做其他处理")
        return
    end

    -- ***** 开发测试可开启 正式版本一定要记住关闭该功能****
    if true == GameConfig.IsDebug then
        return
    end
    
    print("===2==切入切出继续")

    -- 切出游戏 OpenInstall 数据还原
    GameData.OpenInstallReferralsChannel = -1
    GameData.OpenInstallReferralsGameID = 0
    GameData.OpenInstallReferralsID = -1

    if isCutOut == true then
        -- 切出 记录下切出时刻
        CutOutTime = os.time()
        print("切出游戏, 切出时间:",CutOutTime)
        -- 关闭raknet
        if gameNetClient ~= nil then
            print('===111==ShutDown')
            gameNetClient:ShutDown()
        end
    else
        -- 切回 计算出切出的总时长
        CutOutTime = os.time() - CutOutTime
        print("切回游戏，切出总时长:", CutOutTime)

        -- 如果切出超过10分钟，直接返回登陆界面
        if CutOutTime > data.PublicConfig.CUT_OUT_RETURN_LOGIN_TIME then
            print("切出超过5分钟，直接重走登陆流程")
            CS.Utility.LoadScene("Start")
            return
        end
        if GameData.GameState == GAME_STATE.LOGIN then
            NetMsgHandler.ReturnLogin(2)
        else
            -- 已经登陆游戏进行玩耍 悄悄地自动走一遍连接
            print("创建新的连接，悄悄地走一遍登陆流程 lastLoginType = " .. LoginMgr.mLastLoginType)
            IsAutoConnect = true
            NetMsgHandler.TryConnectGameServer()
        end
    end
end

function NetMsgHandler.OnClearMessageOK(param)
    -- print('清除缓存消息完毕，给服务器发送切回通知')
    CS.LoadingDataUI.Show(5);
end

function NetMsgHandler.OnConnectionLost(param)
    print('底层发现连接中断 id =:', param, isConnectingHub)

    if isConnectingHub then
        NetMsgHandler.ReturnLogin(3)
        return
    end
    -- 按照策划需求 网络异常提示调整
    -- 只在回到登陆页面时给与玩家提示网络异常
    -- 其他情况均不提示,旨在连接网络时做一定的表现

    if param == 17 then
        -- 切回登陆界面 连接请求无法完成时收到此消息
        --CS.BubblePrompt.Show("连接超时.", "NB")
    elseif  param == 18 then
        -- (切换网络,与服务器的连接还保持)服务器已经关闭处于维护状态
        --CS.BubblePrompt.Show("网络异常..", "NB")
    elseif param == 21 then
        -- 尝试自动重连 (服务器关闭)
        --CS.BubblePrompt.Show("网络异常...", "NB")
    elseif param == 22 then
        -- 尝试自动重连 (数据包不能发送到指定系统，与该系统的连接已经关闭)
        --CS.BubblePrompt.Show("网络异常....", "NB")
    elseif  param == 23 then
        -- (服务器强踢客户端)服务器已经关闭处于维护状态
        CS.BubblePrompt.Show("服务器维护中.....", "NB")
        NetMsgHandler.ReturnLogin(4)
        return
    else
        --CS.BubblePrompt.Show("网络异常......", "NB")
    end
    
    AutoConnectCount = AutoConnectCount + 1
    print('断线重连次数:', AutoConnectCount)
    if IsProactiveDisconnect then
        print("主动断开连接，不走自动重连流程1")
        IsProactiveDisconnect = false
        return
    end

    if AutoConnectCount > 5 then
        
        NetMsgHandler.ReturnLogin(5)
        return
    end

    -- print("创建新的连接，悄悄地走一遍登陆流程")
    IsAutoConnect = true
    CS.TimeManager.Instance():DelayInvoke(AutoConnectCount,function()
        NetMsgHandler.TryConnectGameServer()
    end)
end

-- 连接GameServer
function NetMsgHandler.TryConnectGameServer()
    print('=====Connect GameServer')
    if GameData.IsFirstLogin then
        CS.LoadingDataUI.ShowTips(30,"正在登录...")
    else
        CS.LoadingDataUI.ShowTips(30,"努力加载中...")
    end
    if gameNetClient == nil then
        gameNetClient = CS.Net.ConnectManager:Instance():FindNetworkClient("GameServer")
        if gameNetClient == nil then
            gameNetClient = CS.Net.ConnectManager:Instance():CreateNetworkClient("GameServer")
            if gameNetClient == nil then
                print("==========GameServer 连接失败=111")
                CS.BubblePrompt.Show("网络连接失败，请检查你的网络...", "XLX")
                return
            end
            NetMsgHandler.InitLoginNetClient()
        end
    end

    if GameConfig.GameServerIP == "" then
        print("GameServerIP = 为空")
        -- 尝试获取一次ip地址，如果还是获取不到，则提示玩家，链接服务器失败
        GameConfig.GameServerIP = CS.Utility.GetGameServerIP(GameConfig.GameServerURL)
        if GameConfig.GameServerIP == "" then
            print("==========GameServer 连接失败=222")
            CS.BubblePrompt.Show("网络连接失败，请检查你的网络....", "XLX")
            return
        end
    end

    local realConnectIP
    if string.find(GameConfig.GameServerIP, ":") ~= nil then
        -- 当前网络环境为ipv6
        realConnectIP = GameConfig.GameServerIP
        gameNetClient:StartUpRaknet(true)
        print("当前处于ipv6网络")
    else
        realConnectIP = GameConfig.GameServerIP
        gameNetClient:StartUpRaknet(false)
        print("当前处于ipv4网络")
    end

    print("=====即将连接 GameServerIP: = " .. realConnectIP .. "  platformType = " .. GameData.LoginInfo.PlatformType)
    print("=====即将连接 GameServer Connected:", gameNetClient.IsConnectedServer)

    if gameNetClient.IsConnectedServer then
        -- 处于连接成功状态
        NetMsgHandler.Try_CS_Login()
    else
        gameNetClient:Connect(realConnectIP, GameConfig.GameServerPort, function(success)
            print("==========GameServer 连接回调返回值=", success)
            if success then
                IsProactiveDisconnect = false
                AutoConnectCount = 0
                NetMsgHandler.Try_CS_Login()
            else
                -- 连接失败，显示日志信息
                print("==========GameServer 连接失败=333")
                CS.LoadingDataUI.Hide()
            end
        end )
    end
end

function NetMsgHandler.ReturnLogin(nType)
    print('=====Return Login Type:', nType)
    IsAutoConnect = false
    AutoConnectCount = 0

    IsProactiveDisconnect = true
    if gameNetClient ~= nil then
        print('===222==ShutDown')
        gameNetClient:ShutDown()
    end
    -- 大厅保持常开状态
    CS.WindowManager.Instance:CloseAllWindows( { "HallUI", "BubblePrompt","JPushUI", "WXLogin"})

    OpenLoginUI(true)

    EmailMgr:ClearAll()
    GameData.RoleInfo.UnreadMailCount = 0
    CS.MoveNotice.ClearAll()
    GameData.GameState = GAME_STATE.LOGIN
end

function NetMsgHandler.CheckAppVersionCallBack(result)
    GameData.AppVersionCheckResult = result
end

-- 开启登录UI
--==============================--
--desc:开启登录UI
--time:
--@isAutomatic: true 自动开启(断网 账号异常导致) false: 玩家手动点击开启
--@return 
--==============================--
function OpenLoginUI(isAutomatic)
    local uiNode  = CS.WindowManager.Instance:FindWindowNodeByName("WXLogin")
    if uiNode~=nil then
        uiNode.WindowData = isAutomatic and 1 or 2
    else
        local openparam = CS.WindowNodeInitParam("WXLogin")
        openparam.NodeType = 0
        openparam.WindowData = isAutomatic and 1 or 2
        CS.WindowManager.Instance:OpenWindow(openparam)
    end
end

---------------------------------------------------------------------------
----------------------------S_SFT_PAY_RESULT  113--------------------------
function NetMsgHandler.HandleSFTPayResult(message)
    -- print('服务器通知 盛付通 支付成功！')
    CS.LoadingDataUI.Hide()
end


-- 链接超时
function ConnectTimeOut()
    -- print('Connect server time out');
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.ConnectGameServerTimeOut, 1)
end

-------------------------------CS_Login  [200]-----------------------------
------------------------------------登陆-----------------------------------
-- 请求登录游戏服务器
function NetMsgHandler.Try_CS_Login()
    if GameData.IsFirstLogin then
        CS.LoadingDataUI.ShowTips(10,"正在登录...")
    else
        CS.LoadingDataUI.ShowTips(10,"努力加载中...")
    end
    
    local longType = LoginMgr.mCacheLoginType
    local loginAccount = LoginMgr.mCacheLoginAccount
    local loginPassword = LoginMgr.mCacheLoginPassword
    
    NetMsgHandler.Send_CS_Login(longType, loginAccount, loginPassword)
end

function NetMsgHandler.Send_CS_Login(longType, accountParam, passwordParam)
    local message = CS.Net.PushMessage()
    local gameId = CS.AppDefine.GameID
    message:PushUInt16(longType)                    -- 登陆方式
    message:PushString(accountParam)                -- 账号
    message:PushString(passwordParam)               -- 密码
    message:PushUInt32(GameData.ChannelCode)        -- 渠道ID
    message:PushByte(LoginMgr.RunningPlatformID)    -- 设备类型 (1:windows 2:android 3:ios 4:macos)
    local UUID = CS.UnityEngine.SystemInfo.deviceUniqueIdentifier
    message:PushString(UUID)                        -- 设备码
    message:PushUInt32(gameId)                      -- 包ID
    message:PushString(GameConfig.IPAddress)        -- 玩家IP地址
    message:PushString(GameData.LoginInfo.NickName) -- 微信名称
    GameData.LoginInfo.PlatformType = LoginMgr.RunningPlatformID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Login, message, false)
    print('=====200--=登陆GameServer LoginInfo :', longType, accountParam, passwordParam)
end

local function HallGameTypeSort( tA, tB)
    return tA.GameTypeWeight > tB.GameTypeWeight
end
-- 处理收到服务器 登陆结果 消息
function NetMsgHandler.HandleReceivedLogin(message)
    -- 设置登陆标签
    GameData.IsFirstLogin = false

    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()                        -- 结果(0: 登陆成功)
    if resultType == 0 then
        GameData.RoleInfo.AccountID = message:PopUInt32()       -- 账号ID
        GameData.RoleInfo.AccountName = message:PopString()     -- 名字
        GameData.RoleInfo.DiamondCount = 0
        local goldCount = message:PopInt64()                    -- 金币数量
        GameData.RoleInfo.VipLevel = message:PopByte()          -- Vip等级
        local unreademailNum = message:PopUInt16()              -- 未读邮件数量
        GameData.AgencyInfo.IsAgent = message:PopByte()         -- 是否为推广员
        local tBindAccount = message:PopByte()                  -- 是否绑定手机号码(0:否 1:是)
        local tBindBank = message:PopByte()                     -- 是否绑定银行卡(0:否 1:是)
        local tUserReturn = message:PopByte()                   -- 老玩家绑定按钮开关(0:关 1:开)
        GameData.RoleInfo.IsBindAccount =(tBindAccount == 1)
        GameData.RoleInfo.IsBindBank =(tBindBank == 1)
        GameData.RoleInfo.IsUserReturn =(tUserReturn == 1)
        GameData.RoleInfo.InviteCode = message:PopUInt32()      -- 邀请码
        GameData.RoleInfo.AccountIcon = message:PopByte()       -- 头像ID
        GameData.IsOpenApplePay = message:PopByte()             -- 是否开启苹果支付
        GameData.ChannelCode = message:PopUInt32()              -- 注册时初始渠道

        -- 充值获得金币提示(由于H5方式充值 导致通知不及时)
        local _recharge_gold = message:PopInt64()               -- 充值金币提示
        GameData.NewRewardFlag = message:PopByte()              -- 新人登陆奖励是否领取(1:已领取 0:未领取)
        local ipAddress = message:PopString()                   -- 本次登陆IP
        GameConfig.UpdateIPAddress(ipAddress)
        --增加 公告 0无 1有
        GameData.ISHasNotice = message:PopByte()                -- 是否有公告
        if  GameData.ISHasNotice == 1 then
            GameData.NoticeTitle = message:PopString()          -- 标题
            GameData.NoticeContent = message:PopString()        -- 内容
            GameData.NoticeImageID = message:PopUInt32()
            GameData.NoticeGotoID = message:PopString()
        end
        GameData.kefuIsRed = message:PopByte()                  -- 客户提示小红点(0:无 1:有)
        -- 增加 玩家正在游戏的房间信息
        GameData.RoleInfo.PlayRoomID = message:PopUInt32()      -- 玩家正处于的房间ID(大于0有效)
        GameData.RoleInfo.PlayRoomType = message:PopByte()      -- 玩家正处于的房间类型

        -- 本包游戏玩法数量
        local GameTypeNumber = message:PopUInt16()              -- 游戏玩法数量
        GameData.GameTypeDisplay = {}
        GameData.GameTypeListInfo = {}
        for Index = 1, GameTypeNumber, 1 do
            -- 初级房房间状态 （0未选择 1敬请期待 2上架  3下架 4无本档次）
            local PrimaryRoomState = message:PopByte()
            -- 初级房间标签 （0未选择 1无 2流畅 3火爆 4无本档次 5维护）
            local PrimaryRoomLabel = message:PopByte()
            -- 中级房房间状态 （0未选择 1敬请期待 2上架  3下架 4无本档次）
            local IntermediateRoomState = message:PopByte()
            -- 中级房间标签 （0未选择 1无 2流畅 3火爆 4无本档次 5维护）
            local IntermediateRoomLabel = message:PopByte()
            -- 高级房房间状态 （0未选择 1敬请期待 2上架  3下架 4无本档次）
            local SeniorRoomState = message:PopByte()
            -- 高级房间标签 （0未选择 1无 2流畅 3火爆 4无本档次 5维护）
            local SeniorRoomLabel = message:PopByte()
            -- 土豪房房间状态  （0未选择 1敬请期待 2上架  3下架 4无本档次）
            local TycoonRoomState = message:PopByte()
            -- 土豪房间标签 （0未选择 1无 2流畅 3火爆 4无本档次 5维护）
            local TycoonRoomLabel = message:PopByte()
            -- 游戏类型权重
            local GameTypeWeight = message:PopByte()
            -- 游戏类型
            local GameType = message:PopByte()
            -- 游戏类型状态 (0下架 1 上架)
            local GameTypeState = message:PopByte()
            -- 游戏类型标签（0无 1New 2Hot）
            local GameTypeLable = message:PopByte()
            if GameTypeState == 1 then
                table.insert(GameData.GameTypeDisplay,{PrimaryRoomState=PrimaryRoomState,PrimaryRoomLabel=PrimaryRoomLabel,IntermediateRoomState=IntermediateRoomState,IntermediateRoomLabel=IntermediateRoomLabel,
                SeniorRoomState=SeniorRoomState,SeniorRoomLabel=SeniorRoomLabel,TycoonRoomState=TycoonRoomState ,TycoonRoomLabel=TycoonRoomLabel,GameTypeWeight=GameTypeWeight,GameType=GameType,GameTypeState=GameTypeState,GameTypeLable=GameTypeLable})
                GameData.GameTypeListInfo[GameType] = {PrimaryRoomState=PrimaryRoomState,PrimaryRoomLabel=PrimaryRoomLabel,IntermediateRoomState=IntermediateRoomState,IntermediateRoomLabel=IntermediateRoomLabel,
                                                    SeniorRoomState=SeniorRoomState,SeniorRoomLabel=SeniorRoomLabel,TycoonRoomState=TycoonRoomState ,TycoonRoomLabel=TycoonRoomLabel}
            end
            --print("初级房房间状态%d,初级房间标签%d,中级房房间状态%d,中级房间标签%d",GameType,Index,PrimaryRoomLabel,IntermediateRoomLabel,SeniorRoomLabel,TycoonRoomLabel)
        end
        -- 是否绑定支付宝(0:否 1:是)
        local tBindZhifubao = message:PopByte()
        GameData.RoleInfo.IsBindZhifubao = (tBindZhifubao == 1)

        print("=====200===== Notice Game:", GameData.ISHasNotice, GameTypeNumber)
        if GameTypeNumber > 0 then
            table.sort(GameData.GameTypeDisplay,HallGameTypeSort)
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateHallLayout,nil)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateKFZXRed)
        GameData.UpdateGoldCount(goldCount, 0)
        GameData.ResetUnreadMailCount(unreademailNum)

        if _recharge_gold > 0 then
            CS.BubblePrompt.Show(string.format(data.GetString("Rechare_Gold_Tips"), GameConfig.GetFormatColdNumber(_recharge_gold)), "UIStore")
        end
        GameData.ConfirmChannelCode = true
        print('服务器反馈[PG][YQ][OP][CZ]结果:', GameData.IsOpenApplePay, GameData.RoleInfo.InviteCode, GameData.ChannelCode, _recharge_gold)

        -- 登录成功处理
        CS.WindowManager.Instance:CloseWindow('WXLogin', false)
        CS.WindowManager.Instance:CloseWindow('PhoneLogin', false)
        GameConfig.HandleMoblieIPLocation()

        -- 朋友圈分享反馈处理
        if GameData.RoleInfo.IsSharePYQ == 1 then
            NetMsgHandler.Send_CS_WECHAT_SHARE()
        end

        if GameConfig.IsSpecial() then
            -- 审核 + IP 分流机制
            EnterSpiderPokerGame()
            -- 切换状态为大厅
            GameData.GameState = GAME_STATE.HALL
        else
            if IsAutoConnect then
                IsAutoConnect = false
                -- 如果房间号不为0，并且切出时间符合要求，发送请求进入房间协议
                -- print("悄悄登陆")
                if GameData.GameState == GAME_STATE.ROOM and  GameData.RoomInfo.CurrentRoom.RoomID ~= 0 and CutOutTime <= data.PublicConfig.CUT_OUT_CAN_ENTER_ROOM_TIME then
                    local tRroomID =  GameData.RoomInfo.CurrentRoom.RoomID
                    local tRoomType  = GameData.RoomInfo.CurrentRoom.RoomType
                    NetMsgHandler.TryAutoEnterRoom(tRroomID, tRoomType)
                else
                    NetMsgHandler.ExitRoomToHall(3)
                end
                -- 若是在大厅UI则刷新UI
                HandleRefreshHallUIShowState(GameData.GameState == GAME_STATE.HALL)
                -- 断线重连之后 发现有未读邮件 主动请求一次邮件数据
                if unreademailNum > 0 then
                    --处理红点
                end
            else
                -- 显示HallUI，关闭登陆界面
                HandleRefreshHallUIShowState(true)
                -- 初次登陆进入
                MusicMgr:PlaySoundEffect('44')
                -- 切换状态为大厅
                GameData.GameState = GAME_STATE.HALL
                if GameData.NewRewardFlag == 0  then
                    HandleLoginRewardUI(true)
                elseif not GameData.RoleInfo.IsBindAccount then
                    HandleRegisterRewardUI(true)
                end
                -- 检查是否有公告需要开启
                if  GameData.ISHasNotice == 1 then
                    if GameData.GameState == GAME_STATE.HALL or GameData.GameState == GAME_STATE.LOGIN  then
                        -- 启动游戏后 有公告只主动提示一次
                        GameData.AutoOpenNoticeTimes = GameData.AutoOpenNoticeTimes + 1
                        OpenLoginNoticeUI()
                    end
                end

            end
        end

        -- 处理本地缓存的待发送消息
        print("处理本地缓存的待发送消息 个数为 = " .. SaveMsgList:length())
        while (SaveMsgList:length() > 0) do
            local msgStruct = SaveMsgList:pop()
            NetMsgHandler.SendMessageToGame(msgStruct.pretocalID, msgStruct.message, msgStruct.pretocalID)
        end
        LoginMgr:UpdateLoginData(LoginMgr.mCacheLoginType, LoginMgr.mCacheLoginAccount, LoginMgr.mCacheLoginPassword)
        LoginMgr:SaveToLocal()
        -- 登陆成功
        PlatformBridge:CallFunc(LoginMgr.RunningPlatformID, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKREG, tostring(GameData.RoleInfo.AccountID))
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyLoginSuccessEvent, nil)

        NetMsgHandler.Send_CS_IP_LOCATION()

    else
        if resultType == 1 then
            -- 在线人数达到上限
        elseif resultType == 2 then
            -- 账号被冻结
            CS.BubblePrompt.Show(data.GetString("T_200_2"),"WXLogin")
        elseif resultType == 3 then
            -- 账号密码错误
        elseif resultType == 4 then
            -- 账号未注册,请输入正确账号
        elseif resultType == 5 then
            -- IP地址限制注册 50个账户
        elseif resultType == 6 then
            -- 设备限制注册 5个账号
        elseif resultType == 7 then
            -- 使用WX登录授权失败，设备号未找到有账号
            HandlePhoneLoginUI()
            return
        elseif resultType == 100 then
            OpenLoginNoticeUI()
            return 
        else
            -- 未处理的失败原因
            CS.BubblePrompt.Show("未知错误:" .. resultType, "WXLogin")
        end
        if resultType ~= 2 then
            CS.BubblePrompt.Show(data.GetString("T_200_" .. resultType), "WXLogin")
        end
        
        NetMsgHandler.ReturnLogin(20 + resultType)
    end
end



-- 大厅UI显示状态刷新
function HandleRefreshHallUIShowState(showParam)
    -- body
    if GameConfig.IsSpecial() then
        local hallUI = CS.WindowManager.Instance:FindWindowNodeByName("HallUI")
        if hallUI ~= nil then
            CS.BubblePrompt.ClearPrompt("HallUI")
            CS.WindowManager.Instance:CloseWindow("HallUI", false)
        end
        -- 审核 + IP 分流机制
        if CS.AppDefine.GameID == 2 then
            -- 马甲包显示处理
            local ZMaJiaGame = CS.WindowManager.Instance:FindWindowNodeByName("ZMaJiaGameUI")
            if ZMaJiaGame ~= nil then
                ZMaJiaGame.WindowGameObject:SetActive(showParam)
            else
                local openparam = CS.WindowNodeInitParam("ZMaJiaGameUI")
                openparam.NodeType = 0
                openparam.LoadComplatedCallBack = function(windowNode)
                end
                CS.WindowManager.Instance:OpenWindow(openparam)
                GameData.GameState = GAME_STATE.HALL
            end
        else
            print("=====大厅UI显示异常,请检查*****")
        end

        if showParam then
            GameData.GameState = GAME_STATE.HALL
        end
    else
        local hallUI = CS.WindowManager.Instance:FindWindowNodeByName("HallUI")
        if hallUI ~= nil then
            hallUI.WindowGameObject:SetActive(showParam)
            if showParam then
                hallUI.WindowData = 1
            end
        else
            print('*********大厅UI查找失败，请请检查!')
        end
    end
    
    
end

-- 进入蜘蛛纸牌
function EnterSpiderPokerGame()
    if CS.AppDefine.GameID == 1 then
        HandleRefreshHallUIShowState(false)
        local SpiderPoker = CS.WindowManager.Instance:FindWindowNodeByName("SpiderPokerHallUI")
        if SpiderPoker ~= nil then
            SpiderPoker.WindowGameObject:SetActive(true)
        else
            CS.WindowManager.Instance:OpenWindow("SpiderPokerHallUI")
        end
    elseif CS.AppDefine.GameID == 2 then
        HandleRefreshHallUIShowState(true)
    elseif CS.AppDefine.GameID == 3 then
        -- 审核 + IP 分流机制
        HandleRefreshHallUIShowState(true)
    end
end

-- 登录奖励UI显示处理
function HandleLoginRewardUI(showParam)
    if showParam then
        local uiNode = CS.WindowManager.Instance:FindWindowNodeByName("LoginRewardUI")
        if uiNode ~= nil then
            if showParam then
                uiNode.WindowData = 1
            end
            uiNode.WindowGameObject:SetActive(showParam)
        else
            local openparam = CS.WindowNodeInitParam("LoginRewardUI")
            CS.WindowManager.Instance:OpenWindow(openparam)
        end
    else
        CS.WindowManager.Instance:CloseWindow('LoginRewardUI', false)
    end
end

-- 注册奖励UI显示处理
function HandleRegisterRewardUI(showParam)
    if showParam then
        local uiNode = CS.WindowManager.Instance:FindWindowNodeByName("RegisterRewardUI")
        if uiNode ~= nil then
            if showParam then
                uiNode.WindowData = 1
            end
            uiNode.WindowGameObject:SetActive(showParam)
        else
            local openparam = CS.WindowNodeInitParam("RegisterRewardUI")
            CS.WindowManager.Instance:OpenWindow(openparam)
        end
    else
        CS.WindowManager.Instance:CloseWindow('RegisterRewardUI', false)
    end
end

function HandlePhoneLoginUI()
    local tUINode = CS.WindowManager.Instance:FindWindowNodeByName("PhoneLogin")
    if tUINode ~= nil then
        tUINode.WindowGameObject:SetActive(true)
    else
        CS.WindowManager.Instance:OpenWindow("PhoneLogin")
    end
end

--==============================--
--desc:断线重连情况尝试自动进入游戏房间
--time:2017-11-27 10:41:25
--@return 
--==============================---
function NetMsgHandler.TryAutoEnterRoom(roomIDParam, roomTypeParam)
    local _roomType  = roomTypeParam
    local _roomID =  roomIDParam
    print('*****123自动进入房间',_roomType,_roomID)
    if _roomType == ROOM_TYPE.BRJH then
        --print("房间ID".._roomID)
        NetMsgHandler.Send_CS_Enter_Room(_roomID,0)
    elseif _roomType == ROOM_TYPE.ZuJu then
        NetMsgHandler.Send_CS_JH_Enter_Room1(_roomID)
    elseif _roomType == ROOM_TYPE.MenJi then
        NetMsgHandler.Send_CS_JH_Enter_Room2(GameData.RoomInfo.CurrentRoom.SubType,_roomID)
    elseif _roomType == ROOM_TYPE.ZuJuNN then
        NetMsgHandler.Send_CS_NN_Enter_Room(_roomID)
    elseif  _roomType == ROOM_TYPE.PiPeiNN then
        Send_CS_NNPP_Enter_Room(0,_roomID)
    elseif _roomType == ROOM_TYPE.HongBao then
        NetMsgHandler.Send_CS_HB_Enter_Room1(_roomID,0)
    elseif _roomType == ROOM_TYPE.PPHongBao then
        NetMsgHandler.Send_CS_HB_Enter_Room1(_roomID,GameData.HBJL.RoomLevel)
    elseif _roomType == ROOM_TYPE.ZuJuTTZ then
        NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(_roomID,0)
    elseif _roomType == ROOM_TYPE.PiPeiTTZ then
        NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(_roomID,0)
    elseif _roomType == ROOM_TYPE.ZuJuMaJiang then
        NetMsgHandler.Send_CS_MJ_ZUJU_ENTER_ROOM(_roomID)
    elseif _roomType == ROOM_TYPE.PiPeiPDK then
        if GameData.RoomInfo.CurrentRoom.RoomLevel == nil then
            GameData.RoomInfo.CurrentRoom.RoomLevel = 0
        end
        NetMsgHandler.Send_CS_PDKPP_Enter_Room(GameData.RoomInfo.CurrentRoom.RoomLevel,_roomID)
    elseif _roomType == ROOM_TYPE.BMWBENZ then
        NetMsgHandler.Send_CS_CarInfo(_roomID)
    elseif _roomType == ROOM_TYPE.LuckyWheel then
        NetMsgHandler.Send_CS_Daily_Wheel_Info(_roomID)
    elseif _roomType == ROOM_TYPE.SSC then
        NetMsgHandler.ProcessingLottery()
    elseif _roomType == ROOM_TYPE.PiPeiPDK then
        NetMsgHandler.Send_CS_PDKPP_Enter_Room(0,_roomID)
    elseif _roomType == ROOM_TYPE.LHDRoom then
        NetMsgHandler.Send_CS_LHD_Enter_Room(_roomID, 0)
    elseif _roomType == ROOM_TYPE.BJLRoom then
        BJLGameMgr.Send_CS_BJL_Enter_Room(_roomID, 0)
    end

end

-- 玩家正处于其他房间游戏
function NetMsgHandler.TryAutoEnterRoomMessageBos()
    local boxData = CS.MessageBoxData()
    boxData.Title = "温馨提示"
    boxData.Content = '你存在已开牌局，是否回到牌局'
    boxData.Style = 2
    boxData.OKButtonName = "确定"
    boxData.LuaCallBack = NetMsgHandler.EnterRoomConfirmOnClick
    CS.MessageBoxUI.Show(boxData)
end

-- 自动进入已经开局房间
function NetMsgHandler.EnterRoomConfirmOnClick(resultType)
    print("------999 Click:", resultType)
    if resultType == 1 then
        local tRoomID = GameData.RoleInfo.PlayRoomID
        local tRoomType = GameData.RoleInfo.PlayRoomType
        NetMsgHandler.TryAutoEnterRoom(tRoomID,tRoomType)
    end
end

------------------------------S_Disconnect  201----------------------------
---------------------------------断开连接----------------------------------

-- 处理收到服务器 断开连接 消息
function NetMsgHandler.HandleReceivedDisconnect(message)
    local reason = message:PopByte()        -- 结果(1:顶号 2:封号)
    CS.BubblePrompt.Show(data.GetString("DISCONNECT_ERROR_" .. reason), "WXLogin")
    NetMsgHandler.CloseConnect()
    -- 顶号处理
    NetMsgHandler.ReturnLogin(6)
end


------------------------------CS_User_Return  202--------------------------
----------------------------------老玩家回归--------------------------------
-- 请求注册账号
function NetMsgHandler.Send_CS_User_Return(mobileParam)
    --local UUID = CS.UnityEngine.SystemInfo.deviceUniqueIdentifier
    --local GameID = CS.AppDefine.GameID
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 账号ID
    message:PushString(mobileParam)                     -- 手机号码
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_User_Return, message, true)
    print("-----202=====注册账号:", mobileParam)
end


-- 账号注册
function NetMsgHandler.Handle_CS_User_Return(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()        -- 结果(0:成功)
    print("=====202=====注册账号:", result)
    if result == 0 then
        -- local accountOpenid = message:PopString()
        -- local password = message:PopString()
        -- LoginMgr:HandleCacheLoginData(LOGIN_TYPE.MobilePassword, accountOpenid, password)
        -- LoginMgr:UpdateLoginData(LOGIN_TYPE.MobilePassword, accountOpenid, password)
        -- LoginMgr:SaveToLocal()
        CS.BubblePrompt.Show(data.GetString("T_202_0"),"UserReturn")
        CS.WindowManager.Instance:CloseWindow('UserReturn', false)
        -- 主动重新登录一次
        NetMsgHandler.Try_CS_Login()
    else
        CS.BubblePrompt.Show(data.GetString("T_202_" .. result), "UserReturn")
    end
end

----------------------------S_Update_Diamond  203--------------------------
--------------------------------更新钻石数量--------------------------------
-- 处理收到服务器 更新钻石 消息
function NetMsgHandler.HandleReceivedUpdateDiamond(message)
    local diamondCount = message:PopInt64()     -- 钻石数量
    local reason = message:PopByte()            -- 原因
    local changedValue = diamondCount - GameData.RoleInfo.DiamondCount
    if changedValue > 0 then
        if reason == 3 then
            -- 充值成功获得钻石
            CS.BubblePrompt.Show(string.format(data.GetString("Rechare_Diamond_Tips"), changedValue), "UIStore")
        else
            -- 其他原因获得钻石
            CS.BubblePrompt.Show(string.format(data.GetString("Get_Diamond_Tips"), changedValue), "UIStore")
        end
    end
    GameData.RoleInfo.DiamondCount = diamondCount
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateDiamondEvent, nil)
end

------------------------------S_Update_Gold  204---------------------------
---------------------------------更新金币数量-------------------------------
-- 处理收到服务器 更新金币 消息
function NetMsgHandler.HandleReceivedUpdateGold(message)
    local GoldCount = message:PopInt64()        -- 数量
    local reason = message:PopByte()            -- 原因
    local changedValue = GoldCount - GameData.RoleInfo.GoldCount
    if changedValue > 0 then
        if reason == 1 or reason == 0 or reason == 66 or reason == 67 then
            -- 充值成功获得金币 
            CS.BubblePrompt.Show(string.format(data.GetString("Rechare_Gold_Tips"), GameConfig.GetFormatColdNumber(changedValue)), "UIStore")
        end
    end
    GameData.UpdateGoldCount(GoldCount, reason)
end

----------------------------CS_Update_FreeGold  205------------------------
--------------------更新免费金币(马甲小游戏金币扣除增加协议)-----------------
function NetMsgHandler.Send_CS_Update_FreeGold(freeGoldParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 账号ID
    message:PushUInt64(freeGoldParam)                   -- 改变金币
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Update_FreeGold, message, false)
end

-- 处理收到服务器 更新免费金币 消息
function NetMsgHandler.HandleReceivedUpdateFreeGold(message)
    local reason = message:PopByte()                    -- 结果
end

----------------------------S_Update_RoomCard  206-------------------------
---------------------------------更新房卡数量-------------------------------
-- 处理收到服务器 更新房卡 消息
function NetMsgHandler.HandleReceivedUpdateRoomCard(message)
    local roomCardCount = message:PopUInt32()           -- 房卡数量
    GameData.RoleInfo.RoomCardCount = roomCardCount

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateRoomCardEvent, nil)
end

-----------------------------S_Update_Charge  207--------------------------
--------------------------------更新充值人名币------------------------------
-- 处理收到服务器 更新充值人民币 消息
function NetMsgHandler.HandleReceivedUpdateCharge(message)
    GameData.RoleInfo.ChargeCount = message:PopUInt32()     -- 充值人民币数量
    GameData.RoleInfo.VipLevel = message:PopByte()          -- Vip等级

    local masterInfoUI = CS.WindowManager.Instance:FindWindowNodeByName("PersonalUI")
    if masterInfoUI ~= nil then
        masterInfoUI.WindowData = 2
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateChargeEvent, nil)
end

---------------------------CS_Convert_Gold  208----------------------------
---------------------------------兑换金币-----------------------------------
-- 发送兑换金币消息
function NetMsgHandler.SendConvertGoldMessage(diamondNumber)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 账号ID
    message:PushUInt64(diamondNumber)                   -- 兑换钻石数量

    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Convert_Gold, message, true)
end

-- 处理收到服务器 兑换金币 消息
function NetMsgHandler.HandleReceivedConvertGoldResult(message)
    local resultType = message:PopByte()        -- 结果(0:成功)

    if resultType == 0 then
        local gold = message:PopUInt64()
        CS.BubblePrompt.Show(string.format(data.GetString("Convert_Gold_Success"), lua_CommaSeperate(GameConfig.GetFormatColdNumber(gold))), "UIConvert")
    end
    CS.LoadingDataUI.Hide()
end

-------------------------CS_Convert_RoomCard  209--------------------------
---------------------------------兑换房卡-----------------------------------
-- 发送兑换房卡消息
function NetMsgHandler.SendConvertRoomCardMessage(roomCardNumber)
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID);    -- 账号ID
    message:PushUInt32(roomCardNumber);                 -- 房卡数量
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Convert_RoomCard, message, true);
end

-- 处理收到服务器 兑换房卡 消息
function NetMsgHandler.HandleReceivedConvertRoomCardResult(message)
    local resultType = message:PopByte();       -- 结果
    if resultType == 0 then
        local fangka = message:PopUInt32()      -- 房卡
        CS.BubblePrompt.Show(string.format(data.GetString("Convert_FangKa_Success"), fangka), "UIConvert")
    end
    CS.LoadingDataUI.Hide();
end

-------------------------CS_BIND_ACCOUNT  213------------------------------
------------------------------绑定账号-------------------------------------
-- 手机账号绑定
function NetMsgHandler.SendBindAccount(openidParam, passwordParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 账户ID
    -- 玩家账号
    message:PushString(openidParam)                     -- 手机
    message:PushString(passwordParam)                   -- 账号密码
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BIND_ACCOUNT, message, false)
end

-- 绑定微信账号时使用(切出游戏 断网操作 缓存游戏)
-- function NetMsgHandler.SaveBindAccountMsg(openid, name)
--     local saveMsgStruct = { }
--     local message = CS.Net.PushMessage()
--     message:PushUInt32(GameData.RoleInfo.AccountID)
--     -- 玩家账号
--     message:PushString(openid)
--     message:PushString(name)
--     saveMsgStruct.message = message
--     saveMsgStruct.pretocalID = ProtrocolID.CS_BIND_ACCOUNT
--     saveMsgStruct.isShowLoadingUI = false
--     SaveMsgList:push(saveMsgStruct)
-- end

function NetMsgHandler.OnServerBindAccountResult(message)
    CS.LoadingDataUI.Hide()
    local nType = message:PopByte()                 -- 结果
    print("=====213=====:", nType)
    if nType == 0 then
        local strOpenid = message:PopString()       -- 账号(手机)
        local strPassword = message:PopString()     -- 账号密码
        local rewardGold = message:PopUInt32()      -- 奖励的金币
        LoginMgr:HandleCacheLoginData(LOGIN_TYPE.MobilePassword, strOpenid, strPassword)
        LoginMgr:UpdateLoginData(LOGIN_TYPE.MobilePassword, strOpenid, strPassword)
        LoginMgr:SaveToLocal()
        CS.WindowManager.Instance:CloseWindow("RegisterUI", false)
        CS.BubblePrompt.Show(string.format(data.GetString("T_213_0"),lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(rewardGold))),"RegisterUI")
        GameData.RoleInfo.IsBindAccount = true
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateIsBindAccount,nil)
    else
        CS.BubblePrompt.Show(string.format(data.GetString("T_213_"..nType)),"RegisterUI")
    end
end
-- ================= CS_Store_Upgrade_Vip =========================== --
-- =====================请求vip信息 214 ============================= -- 
function NetMsgHandler.Send_CS_Store_VIP_Info()
    CS.LoadingDataUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 账户ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Store_Upgrade_Vip, message, true)
end

function NetMsgHandler.Received_CS_Store_VIP_Info(message)
    local resultType = message:PopByte()                                    -- 结果
    if resultType == 0 then
        GameData.RoleInfo.PlayerUpgradeVip_LV=message:PopByte()             -- Vip等级
        if GameData.RoleInfo.PlayerUpgradeVip_LV < 8 then
            GameData.RoleInfo.PlayerNeedRechargeGold=message:PopUInt32()    -- 到下一vip等级还需要充值的金额
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptStoreVIP_Lv)
    else
        CS.BubblePrompt.Show(string.format(data.GetString("Check_Card_Error_1")),"CarRotationUI")
    end
    CS.LoadingDataUI.Hide()
end
-- ======================== CS_Contact_CustomerService  ============================== --
-- =========================== 玩家请求联系客服 215  ================================== --
function NetMsgHandler.Send_CS_Contact_CustomerService(mtype,connect,contact)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 账号ID
    message:PushByte(mtype)                             -- 咨询类型
    message:PushString(connect)                         -- 内容描述
    message:PushString(contact)                         -- 联系电话
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Contact_CustomerService,message,false)
end

function NetMsgHandler.Received_CS_Contact_CustomerService(message)
    local resultType=message:PopByte()      -- 结果(0:成功)
    if resultType == 0 then
        GameData.Opinion_OK()
        CS.BubblePrompt.Show(data.GetString("Player_Opinion1"),"CustomerServiceUI")
    end
end
-- =========================== CS_YYIM_REQUEST ============================ --
-- ============================= 语音请求 216 ============================= --

function NetMsgHandler.Send_CS_YYIM_REQUEST()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 账户ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YYIM_REQUEST, message, false)
end

function NetMsgHandler.Received_CS_YYIM_REQUEST(message)
    local result = message:PopByte()            -- 结果
    if result == 0 then
       local YYData = {}
       YYData.AccountID = message:PopUInt32()   -- 账户ID
       YYData.strName = message:PopString()     -- 昵称
       CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYYIMChatRequestEvent, YYData)
    else
        CS.BubblePrompt.Show(data.GetString("YYIM_Error_1_" .. result), "HallUI")
    end
end
-- ========================= CS_YYIM_FORWARDING =========================== --
-- ============================= 语音转发 217 ============================= --

function NetMsgHandler.Send_CS_YYIM_FORWARDING( fileTime, fileUrl, fileExt)
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 账户ID
    message:PushUInt32(fileTime)                        -- 语音时长
    message:PushString(fileUrl)                         -- 语音URL
    message:PushString(fileExt)                         -- 语音唯一标识符
    --print('语音聊天发送:',fileUrl, fileExt, fileTime)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YYIM_FORWARDING, message, false)
end

--服务器反馈语音聊天发送结果
function NetMsgHandler.Received_CS_YYIM_FORWARDING(message)
    -- body
    local result = message:PopByte()                -- 结果
    if result == 0 then
        local chatData = { }
        chatData.AccountID = message:PopUInt32()    -- 账户ID
        chatData.name = message:PopString()         -- 玩家名称
        chatData.filePath = ""
        chatData.fileTime = message:PopUInt32()     -- 语音时长(毫秒)
        chatData.fileUrl = message:PopString()      -- 语音URL
        chatData.fileExt = message:PopString()      -- 语音唯一标识符
        -- print('YYIM2:',chatData.AccountID, chatData.fileTime, chatData.fileUrl, chatData.fileExt)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYYIMChatEvent, chatData)
    else
        -- 有误1账号不存在 2房间不存在 3 CD超时 4 他人说话中...
        CS.BubblePrompt.Show(data.GetString("YYIM_Error_2_" .. result), "HallUI")
    end
end


----------------------------------------------------------------------
-----------------CS_INVITE_FREE_MEMBER  234---------------------------------

--==============================--
--desc:获取空闲玩家列表
--time:
--@roomParam: 房间ID 
--@typeParam：房间类型 
--@return 
--==============================--
function NetMsgHandler.Send_CS_INVITE_FREE_MEMBER(roomParam, typeParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomParam)
    message:PushByte(typeParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_INVITE_FREE_MEMBER, message, true)
end


function NetMsgHandler.Received_CS_INVITE_FREE_MEMBER(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()
    if result == 0 then
        local tFreeMember = {}
        local memberCount = message:PopUInt16()
        for i = 1, memberCount do
            local tData = {}
            tData.AccountID = message:PopUInt32()
            tData.HeadIcon = message:PopByte()
            tData.strName = message:PopString()
            tData.strLoginIP = message:PopString()
            table.insert(tFreeMember, tData)
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyInviteListEvent, tFreeMember)
    else
        CS.BubblePrompt.Show(data.GetString('T_234_' .. result), "InviteGameUI")
    end
end

----------------------------------------------------------------------
-----------------CS_INVITE_FREE_GAME  235---------------------------------

--==============================--
--desc:邀请空闲玩家一起游戏
--time:
--@roomParam: 房间ID 
--@typeParam：房间类型
--@playerList: 玩家列表 
--@return 
--==============================--
function NetMsgHandler.Send_CS_INVITE_FREE_GAME(roomParam, typeParam, playerList)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomParam)
    message:PushByte(typeParam)
    local tCount = #playerList
    message:PushUInt16(tCount)
    for i = 1, tCount do
        message:PushUInt32(playerList[i])
    end
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_INVITE_FREE_GAME, message, true)
end


function NetMsgHandler.Received_CS_INVITE_FREE_GAME(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()
    if result == 0 then
        local tFreeMember = {}
        local memberCount = message:PopUInt16()
        for i = 1, memberCount do
            local tData = message:PopUInt32()
            table.insert(tFreeMember, tData)
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyInviteSuccessEvent, tFreeMember)
    else
        CS.BubblePrompt.Show(data.GetString('T_235_' .. result), "InviteGameUI")
    end
end

----------------------------------------------------------------------
-----------------S_INVITE_PLAY  236-----------------------------

function NetMsgHandler.Received_S_INVITE_PLAY(message)

    local tData = {}
    tData.InviterName = message:PopString()
    tData.RoomID = message:PopUInt32()
    tData.RoomType = message:PopByte()
    tData.SubType = message:PopByte()
    tData.Bet = message:PopInt64()
    tData.BetEnter = message:PopInt64()
    tData.BetLeave = message:PopInt64()

    -- 邀请一起游戏UI节点
    local tUINode = CS.WindowManager.Instance:FindWindowNodeByName("LookupInviteUI")
    if tUINode ~= nil then
        tUINode.WindowData = tData
    else
        local openparam = CS.WindowNodeInitParam("LookupInviteUI")
        openparam.NodeType = 0
        openparam.WindowData = tData
        CS.WindowManager.Instance:OpenWindow(openparam)
    end
    
end

-----------------CS_NEW_REWARD  240-----------------------------------
------------------玩家领取新人奖励-------------------------------------

-- 新人登陆奖励领取
function NetMsgHandler.Send_CS_NEW_REWARD()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     -- 玩家账号ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NEW_REWARD, message, true)
end

function NetMsgHandler.Received_CS_NEW_REWARD(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0  then
        local rewardGold = message:PopUInt32()
        CS.BubblePrompt.Show(string.format(data.GetString("T_240_0"),lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(rewardGold))),"LoginRewardUI")
    else
        CS.BubblePrompt.Show(string.format(data.GetString("T_240_"..resultType)),"LoginRewardUI")
    end

    HandleLoginRewardUI(false)
    

    if GameData.RoleInfo.IsBindAccount == false then
        HandleRegisterRewardUI(true)
    end
end

----------------------------------------------------------------------
-----------------CS_IP_LOCATION  241-----------------------------------

-- 玩家最近登陆IP位置信息更新
function NetMsgHandler.Send_CS_IP_LOCATION()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushString(GameData.RoleInfo.IPLocation)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_IP_LOCATION, message, false)
end

function NetMsgHandler.Received_CS_IP_LOCATION(message)
    local resultType = message:PopByte()
    GameData.RoleInfo.IPSend2Server = GameData.RoleInfo.IPSend2Server + 1
end

----------------------------------------------------------------------
-----------------CS_WECHAT_SHARE  242-----------------------------------
function NetMsgHandler.Send_CS_WECHAT_SHARE()
    GameData.RoleInfo.IsSharePYQ = 0
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_WECHAT_SHARE, message, false)
end

function NetMsgHandler.Received_CS_WECHAT_SHARE(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        CS.BubblePrompt.Show(data.GetString("WECHAT_SHARE_" .. resultType), "HallUI")
    end
end

----------------------------------------------------------------------
-----------------CS_HALL_SHARE_URL  243-----------------------------------
function NetMsgHandler.Send_CS_HALL_SHARE_URL()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_HALL_SHARE_URL, message, false)
end

function NetMsgHandler.Received_CS_HALL_SHARE_URL(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        GameConfig.TGSharedUrl = message:PopString()
        GameConfig.WXSharedUrl = message:PopString()
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyShareURL, nil)
    else
        CS.BubblePrompt.Show(data.GetString("Hall_Share_Url_" .. resultType), "HallUI")
    end
end

function NetMsgHandler.Send_CS_ADVERTISE_INFO()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_ADVERTISE_INFO, message, false)
end

function NetMsgHandler.Received_CS_ADVERTISE_INFO(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()
    if result ~= 0 then
        return
    end

    local advertiseNum = message:PopUInt16()
    local advertiseInfoList = {}

    if advertiseNum > 0 then
        for index = 1, advertiseNum, 1 do
            local advertiseInfo = {}
            advertiseInfo["priority"] = message:PopUInt32()
            advertiseInfo["advertiseType"] = message:PopByte()
            advertiseInfo["title"] = message:PopString()
            advertiseInfo["content"] = message:PopString()
            advertiseInfo["flag"] = message:PopByte()
            advertiseInfo["imageID"] = message:PopUInt32()
            advertiseInfo["gotoID"] = message:PopString()
            table.insert(advertiseInfoList, advertiseInfo)
        end

        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UPDATE_ADVERTISE_LIST, advertiseInfoList)
    end
end

function NetMsgHandler.Send_CS_ADVERTISE_NAME()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_ADVERTISE_NAME, message, false)
end

function NetMsgHandler.Received_CS_ADVERTISE_NAME(message)
    local result = message:PopByte()
    if result ~= 0 then
        return
    end

    local advertiseName = message.PopString()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UPDATE_ADVERTISE_NAME, advertiseName)
end

---------------------------------------------------------------------------
-----------------S_Notify_FalseDeal_Start  331-----------------------------
function NetMsgHandler.Received_S_Notify_FalseDeal_Start(message)
    GameData.SetRoomState(ROOM_STATE.FALSEDEAL)
end

---------------------------------------------------------------------------
-----------------S_Notify_Wait_State  352----------------------------------
function NetMsgHandler.Received_S_Notify_Wait_State(message)
    GameData.ClearCurrentRoundData()
    GameData.SetRoomState(ROOM_STATE.WAIT)
end


---------------------------------------------------------------------------
-----------------S_Notify_Shuffle_State  353-------------------------------
function NetMsgHandler.Received_S_Notify_Shuffle_State(message)
    GameData.SetRoomState(ROOM_STATE.SHUFFLE)
end

---------------------------------------------------------------------------
-----------------S_Notify_Cut_State  354-----------------------------------
function NetMsgHandler.Received_S_Notify_Cut_State(message)
    -- print('354')
    GameData.SetRoomState(ROOM_STATE.CUT)
end

---------------------------------------------------------------------------
-----------------S_Notify_Wait_State  355----------------------------------
function NetMsgHandler.Received_S_Notify_Play_Cut_State(message)
    -- print('355')
    local cutResult = message:PopByte()
    -- print('服务器通知切牌结果', cutResult)
    if cutResult > 32 then
        cutResult = 32
    end

    GameData.RoomInfo.CurrentRoom.CutAniIndex = cutResult

    GameData.SetRoomState(ROOM_STATE.CUTANI)
end

---------------------------------------------------------------------------
-----------------S_Notify_Bet_State  356-----------------------------------
function NetMsgHandler.Received_S_Notify_Bet_State(message)
    GameData.SetRoomState(ROOM_STATE.BET)
end

---------------------------------------------------------------------------
-----------------S_Notify_Deal_State  357----------------------------------
function NetMsgHandler.Received_S_Notify_Deal_State(message)
    NetMsgHandler.ParseAndSetPokerCards(message, 6)

    GameData.SetRoomState(ROOM_STATE.DEAL)
end

---------------------------------------------------------------------------
-----------------S_Notify_Long_Check_State  358----------------------------
function NetMsgHandler.Received_S_Notify_Long_Check_State(message)
    GameData.SetRoomState(ROOM_STATE.CHECK1)
end

---------------------------------------------------------------------------
-----------------S_Notify_Hu_Check_State  359------------------------------
function NetMsgHandler.Received_S_Notify_Hu_Check_State(message)
    GameData.SetRoomState(ROOM_STATE.CHECK2)
end

---------------------------------------------------------------------------
-----------------S_Notify_Settlement_State  360----------------------------
function NetMsgHandler.Received_S_Notify_Settlement_State(message)
    GameData.RoomInfo.CurrentRoom.GameResult = message:PopByte()
    GameData.SetRoomState(ROOM_STATE.SETTLEMENT)
    -- print("***BRJH** 结算:", GameData.RoomInfo.CurrentRoom.GameResult)
end

---------------------------------------------------------------------------
-----------------S_Notify_Check1_Over  361---------------------------------
function NetMsgHandler.Received_S_Notify_Check1_Over(message)
    NetMsgHandler.SetRoleCardCurrentState(1, 4, GameData.RoomInfo.CurrentRoom.CheckRole1.ID > 0)
    GameData.SetRoomState(ROOM_STATE.CHECK1OVER)
end

---------------------------------------------------------------------------
-----------------S_Notify_Check2_Over  362---------------------------------
function NetMsgHandler.Received_S_Notify_Check2_Over(message)
    NetMsgHandler.SetRoleCardCurrentState(2, 4, GameData.RoomInfo.CurrentRoom.CheckRole2.ID > 0)
    GameData.SetRoomState(ROOM_STATE.CHECK2OVER)
end

---------------------------------------------------------------------------
-----------------CS_Enter_Room  400----------------------------------------
function NetMsgHandler.Send_CS_Enter_Room(roomID,roomLevel)
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    --修改进入房间世的几个参数
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomLevel)
    message:PushUInt32(roomID)
    
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Enter_Room, message, false)
    --print("**********************百人房间进入:".."账号:"..GameData.RoleInfo.AccountID.."房间等级："..roomID.."房间ID：".."0")
end

function NetMsgHandler.Received_CS_Enter_Room(message)
    
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 成功需要在发送消息结束后关闭数据加载框
        local tRoomID = message:PopUInt32()
        local tTemplateID = message:PopByte()

        GameData.InitCurrentRoomInfo(ROOM_TYPE.BRJH, tRoomID)
        GameData.RoomInfo.CurrentRoom.TemplateID = tTemplateID

        local gameNode = CS.WindowManager.Instance:FindWindowNodeByName('GameUI2')
        if gameNode == nil then
            local openparam = CS.WindowNodeInitParam("GameUI2")
            openparam.NodeType = 0
            openparam.LoadComplatedCallBack = function(windowNode)
            --local BRHallUI = CS.WindowManager.Instance:FindWindowNodeByName("BRHallUI")
            --if BRHallUI ~= nil then
            --    BRHallUI.WindowGameObject:SetActive(false)
            --else
            --    print('*********BRHallUI查找失败，请请检查!')
            --end
            NetMsgHandler.ShowFreeRoomEnterMessageBox()
            CS.MatchLoadingUI.Hide()
            end
            CS.WindowManager.Instance:OpenWindow(openparam)
        else
            CS.MatchLoadingUI.Hide()
        end
        -- 切换状态为房间
        GameData.GameState = GAME_STATE.ROOM
        
    else
        if resultType == 9 then
            -- GameData.Exit_MoneyNotEnough = true;
        end
        CS.LoadingDataUI.Hide()
        CS.MatchLoadingUI.Hide()
        if resultType == 5 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType == 12 then
                local GoldValue = message:PopInt64()
            end
            CS.BubblePrompt.Show(data.GetString("Enter_Room_Error_" .. resultType), "HallUI")
        end
        NetMsgHandler.ExitRoomToHall(0)
    end
end

function NetMsgHandler.ShowFreeRoomEnterMessageBox()
    local roomConfig = data.RoomConfig[GameData.RoomInfo.CurrentRoom.TemplateID]
    if roomConfig ~= nil then
        if roomConfig.Type == 2 then
            local boxData = CS.MessageBoxData()
            boxData.Title = "提示"
            boxData.Content = data.GetString("Tip_Enter_Free_Room")
            boxData.Style = 1
            CS.MessageBoxUI.Show(boxData)
        end
    end
end

---------------------------------------------------------------------------
-----------------CS_Exit_Room  401-----------------------------------------
function NetMsgHandler.Send_CS_Exit_Room(handleType)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(handleType)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Exit_Room, message, false)
end

function NetMsgHandler.Received_CS_Exit_Room(message)
    local resultType = message:PopByte()
    local handleType = message:PopByte()
    if resultType == 0 then
        NetMsgHandler.ExitRoomToHall(handleType)
    else
        -- CS.BubblePrompt.Show(data.GetString("Exit_Room_Error_".. resultType), "GameUI2")
    end
end

function NetMsgHandler.ExitRoomToHall(handleType)
    if GameData.GameState == GAME_STATE.HALL then
        -- 如果当前已经是房间状态，直接返回
        return
    end
    local roomType = GameData.RoomInfo.RoomList_Type;
    if roomType == ROOM_TYPE.None then
        -- 大厅中心
    elseif roomType == ROOM_TYPE.BRJH or roomType == ROOM_TYPE.LHDRoom or roomType == ROOM_TYPE.BJLRoom then
        -- 百人金花 龙虎斗 百家乐
        local tempWindow = CS.WindowManager.Instance:FindWindowNodeByName("BRHallUI");
        if tempWindow ~= nil then
            GameObjectSetActive(tempWindow.WindowGameObject, true);
        else
            tempWindow = CS.WindowNodeInitParam("BRHallUI");
            tempWindow.NodeType = 0
            CS.WindowManager.Instance:OpenWindow(tempWindow);
        end

        CS.WindowManager.Instance:CloseWindow("LHDGameUI", false)
        CS.WindowManager.Instance:CloseWindow("BJLGameUI", false)
        CS.WindowManager.Instance:CloseWindow("GameUI2", false)
    else
        local openparam = CS.WindowNodeInitParam("DZHallUI")
        openparam.NodeType = 2
        openparam.LoadComplatedCallBack = function(windowNode)
            CS.WindowManager.Instance:CloseWindow("GameUI1", false)
            CS.WindowManager.Instance:CloseWindow("NNGameUI1", false)
            CS.WindowManager.Instance:CloseWindow("HBGameUI1", false)
            CS.WindowManager.Instance:CloseWindow("TTZGameUI", false)
            CS.WindowManager.Instance:CloseWindow("MJGameUI", false)
            CS.WindowManager.Instance:CloseWindow("PDKGameUI", false)
            CS.WindowManager.Instance:CloseWindow("CarRotationUI", false)
            CS.WindowManager.Instance:CloseWindow("BonusWheelUI", false)
            CS.WindowManager.Instance:CloseWindow("TimeTimeColor", false)
        end
        CS.WindowManager.Instance:OpenWindow(openparam)
    end
    -- 打开大厅界面，关闭游戏界面
    --HandleRefreshHallUIShowState(true)
    -- 清理掉GameUI 里的提示信息
    CS.BubblePrompt.ClearPrompt("GameUI2")
    CS.BubblePrompt.ClearPrompt("GameUI1")
    CS.BubblePrompt.ClearPrompt("NNGameUI1")
    CS.BubblePrompt.ClearPrompt("HBGameUI1")
    CS.BubblePrompt.ClearPrompt("TTZGameUI")
    CS.BubblePrompt.ClearPrompt("MJGameUI")
    CS.BubblePrompt.ClearPrompt("PDKGameUI")
    CS.BubblePrompt.ClearPrompt("CarRotationUI")
    CS.BubblePrompt.ClearPrompt("BonusWheelUI")
    CS.BubblePrompt.ClearPrompt("TimeTimeColor")

    CS.WindowManager.Instance:CloseWindow("UIHelp", false)
    CS.WindowManager.Instance:CloseWindow("UIRank", false)
    CS.WindowManager.Instance:CloseWindow("UIRoomRank", false)
    CS.WindowManager.Instance:CloseWindow("UIRoomPlayers", false)
    CS.WindowManager.Instance:CloseWindow("InviteGameUI", false)
    if handleType == 2 then
        CS.BubblePrompt.Show(data.GetString("Tip_Exit_Room_2"), "HallUI")
    end
    -- 切换状态为大厅
    GameData.GameState = GAME_STATE.HALL
end
---------------------------------------------------------------------------
-----------------CS_Create_Room  402---------------------------------------
function NetMsgHandler.Send_CS_Create_Room(roomType, roomCount)
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID);
    message:PushByte(roomType);
    message:PushByte(roomCount);
    print('send create room :' .. roomType .. '  ' .. roomCount);
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Create_Room, message, true);
end

function NetMsgHandler.Received_CS_Create_Room(message)
    local resultType = message:PopByte();
    if resultType == 0 then
        local roomID = message:PopUInt32();
        -- 关闭创建房间界面，发送进入房间消息
        CS.WindowManager.Instance:CloseWindow("UICreateRoom", false)
        NetMsgHandler.Send_CS_Enter_Room(roomID,1);
    else
        CS.LoadingDataUI.Hide();
        CS.BubblePrompt.Show(data.GetString("Create_Room_Error_" .. resultType), "UICreateRoom")
    end
end

---------------------------------------------------------------------------
------------------------------CS_Bet  403----------------------------------
-- 押注区域被点击了
function NetMsgHandler.Send_CS_Bet(areaType, betValue)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(areaType)
    message:PushUInt32(betValue)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Bet, message, false)
end

-- 处理收到服务器 押注结果 消息
function NetMsgHandler.Received_CS_Bet(message)
    local resultType = message:PopByte()
    local roleID = message:PopUInt32()
    local areaType = message:PopByte()
    local betValue = message:PopUInt32()

    local ErrorValue = 0

    if resultType == 0 then
        local eventArg = 1
        if (roleID == GameData.RoleInfo.AccountID) then
            if GameData.RoomInfo.CurrentRoom.BetValues[areaType] == nil then
                GameData.RoomInfo.CurrentRoom.BetValues[areaType] = 0
            end
            GameData.RoomInfo.CurrentRoom.BetValues[areaType] = GameData.RoomInfo.CurrentRoom.BetValues[areaType] + betValue
            eventArg = 2
        end

        if GameData.RoomInfo.CurrentRoom.TotalBetValues[areaType] == nil then
            GameData.RoomInfo.CurrentRoom.TotalBetValues[areaType] = 0
        end
        
        GameData.RoomInfo.CurrentRoom.TotalBetValues[areaType] = GameData.RoomInfo.CurrentRoom.TotalBetValues[areaType] + betValue
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetValue, eventArg)
    end
    if resultType == 8 or resultType == 13 or (resultType >= 101 and resultType <= 105) then
        ErrorValue = message:PopInt64() / 10000
    end
    local betChipEventArg = { RoleID = roleID, AreaType = areaType, BetValue = betValue, ResultType = resultType, ErrorValue = ErrorValue }
    -- 调用下注结果
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyBetResult, betChipEventArg)

end

---------------------------------------------------------------------------
-----------------CS_Check_Card_Process  404--------------------------------
function NetMsgHandler.Send_CS_Check_Card_Process(pokerIndex, isRotate, flipMode, moveX, moveY)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(pokerIndex)
    if isRotate then
        message:PushByte(1)
    else
        message:PushByte(0)
    end
    message:PushByte(flipMode)
    message:PushFloat(moveX)
    message:PushFloat(moveY)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Check_Card_Process, message, false)
end

function NetMsgHandler.Received_CS_Check_Card_Process(message)
    local eventArg = lua_NewTable(HandlePokerEventArgs)

    eventArg.HandlerID = message:PopUInt32()
    eventArg.PokerIndex = message:PopByte()
    eventArg.IsRotate = message:PopByte() == 1
    eventArg.FlipMode = message:PopByte()
    eventArg.MoveX = message:PopFloat()
    eventArg.MoveY = message:PopFloat()
    -- print('MoveX: ' .. eventArg.MoveX .. 'MoveY: ' .. eventArg.MoveY)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateHandlePoker, eventArg)
end

---------------------------------------------------------------------------
-----------------CS_Checked_Card  405--------------------------------------
-- cardIndex : 2,3 表示第几张牌，如果 4，表示
function NetMsgHandler.Send_CS_Checked_Card(cardIndex)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(cardIndex)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Checked_Card, message, false)
end

function NetMsgHandler.Received_CS_Checked_Card(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local roleType = message:PopByte()
        local cardIndex = message:PopByte()
        NetMsgHandler.SetRoleCardCurrentState(roleType, cardIndex, true)
    else
        CS.BubblePrompt.Show(data.GetString("Checked_Card_Error_" .. resultType), "GameUI2")
    end

end

---------------------------------------------------------------------------
-----------------S_Bet_Rank_List  406--------------------------------------
-- 处理收到服务器 押注 排行榜
function NetMsgHandler.Received_S_Bet_Rank_List(message)
    local area4 = { }
    -- 押龙排行榜
    local area5 = { }
    -- 押虎排行榜
    local area4RankCount = message:PopUInt16()
    for i = 1, area4RankCount, 1 do
        area4[i] = { }
        area4[i].ID = message:PopUInt32()
        --area4[i].Name = message:PopString()
        area4[i].Value = message:PopInt64()
        area4[i].HeadIcon = message:PopByte()
        --area4[i].HeadUrl = message:PopString()
        area4[i].strLoginIP = message:PopString()
    end

    local area5RankCount = message:PopUInt16()
    for i = 1, area5RankCount, 1 do
        area5[i] = { }
        area5[i].ID = message:PopUInt32()
        --area5[i].Name = message:PopString()
        area5[i].Value = message:PopInt64()
        area5[i].HeadIcon = message:PopByte()
        --area5[i].HeadUrl = message:PopString()
        area5[i].strLoginIP = message:PopString()
    end

    GameData.RoomInfo.CurrentRoom.BetRankList[4] = area4
    GameData.RoomInfo.CurrentRoom.BetRankList[5] = area5

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetRankList, nil)
end

---------------------------------------------------------------------------
-----------------CS_BRJH_Hall_Request_Statistics  407--------------------------------
-- BRJH 大厅路单信息请求
function NetMsgHandler.Send_CS_BRJH_Hall_Request_Statistics(...)
    local length = select('#', ...)
    if length > 0 then
        local message = CS.Net.PushMessage()
        message:PushUInt16(length)
        -- 写入长度
        for i = 1, length do
            local roomID = select(i, ...)
            message:PushUInt32(roomID)
        end
        NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BRJH_Hall_Request_Statistics, message, false)
    end
end

-- BRJH 大厅路单信息请求反馈
function NetMsgHandler.Received_CS_BRJH_Hall_Request_Statistics(message)
    local count = message:PopUInt16()
    GameData.RoleInfo.BRTRoomAmount = count;
    local currentTime = CS.UnityEngine.Time.realtimeSinceStartup
    local eventArgs = {};
    for i = 1, count, 1 do
        -- 解析统计信息
        local statistics = NetMsgHandler.ParseOneRoomStatisticsInfo(message, false)
        -- 设置其他信息 房间最大局数，房间内的人数，数据请求的时间
        statistics.Round.MaxRound = message:PopByte()
        statistics.Counts.RoleCount = message:PopUInt16()
        statistics.Time = currentTime
        GameData.RoomInfo.StatisticsInfo[statistics.RoomID] = statistics
        local tempEventArgs = { RoomType = 2, Index=statistics.Index, RoomID = statistics.RoomID, OperationType = 0 }
        -- print("=====BRJH 407 Round:", statistics.RoomID, statistics.Round.CurrentRound)
        eventArgs[i] = statistics;
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics, eventArgs)
end

---------------------------------------------------------------------------
-----------------CS_BRJH_Hall_Request_Statistics_New8  443-----------------

-- BRJH 大厅路单信息请求
function NetMsgHandler.Send_CS_BRJH_Hall_Request_Statistics_New8(...)
    local length = select('#', ...)
    if length > 0 then
        local message = CS.Net.PushMessage()
        message:PushUInt16(length)
        -- 写入长度
        for i = 1, length do
            local roomID = select(i, ...)
            message:PushUInt32(roomID)
        end
        NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BRJH_Hall_Request_Statistics_New8, message, false)
    end
end

function NetMsgHandler.Received_CS_BRJH_Hall_Request_Statistics_New8(message)
    print("__________________NEW8")
    local count = message:PopUInt16()
    GameData.RoleInfo.BRTRoomAmount = count;
    print("____________________count =", count);
    local currentTime = CS.UnityEngine.Time.realtimeSinceStartup
    local eventArgs = {};
    for i = 1, count, 1 do
        -- 解析统计信息
        local statistics = NetMsgHandler.ParseOneRoomStatisticsInfo(message, false)
        -- 设置其他信息 房间最大局数，房间内的人数，数据请求的时间
        statistics.Round.MaxRound = message:PopByte()
        statistics.Counts.RoleCount = message:PopUInt16()
        statistics.Time = currentTime
        GameData.RoomInfo.StatisticsInfo[statistics.RoomID] = statistics
        local tempEventArgs = { RoomType = 2, Index=statistics.Index, RoomID = statistics.RoomID, OperationType = 0 }
        -- print("=====BRJH 407 Round:", statistics.RoomID, statistics.Round.CurrentRound)
        eventArgs[i] = statistics;
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics_New8, eventArgs)
end

-- 解析房间路单信息 (是否处于游戏房间中)
function NetMsgHandler.ParseOneRoomStatisticsInfo(message, isInGame)

    local statistics = NetMsgHandler.NewStatisticsInfo()
    statistics.Index = message:PopByte()
    statistics.RoomID = message:PopUInt32()
    local roundCount = message:PopUInt16()
    for round = 1, roundCount, 1 do
        table.insert(statistics.Trend, message:PopByte())
    end
    -- 右侧路单解析
    NetMsgHandler.ParseRightTrend(statistics, roundCount)
    if isInGame then
        BJLGameMgr.MatrixTrendParse(statistics)
        BJLGameMgr.BigEyeTrendParse(statistics)
        BJLGameMgr.SmallTrendParse(statistics)
        BJLGameMgr.YueYouTrendParse(statistics)
    end

    NetMsgHandler.ParseOneRoomStatisticsCounts(message, statistics.Counts)
    statistics.Round.CurrentRound = message:PopByte()
    return statistics
end

-- 返回一个房间的牌型数量统计
function NetMsgHandler.ParseOneRoomStatisticsCounts(message, counts)
    counts.LongWin = message:PopByte()
    counts.HuWin = message:PopByte()
    counts.HeJu = message:PopByte()

    counts.LongJinHua = message:PopByte()
    counts.HuJinHua = message:PopByte()
    counts.LongHuBaoZi = message:PopByte()
end

-- 右侧路单解析
function NetMsgHandler.ParseRightTrend(statisticParam, roundCount)
    if roundCount > 0 then
        -- 本局已有路单信息
        local tHeValue = WIN_CODE.HE
        local tLJinHua = WIN_CODE.LONGJINHUA
        local tHJinHua = WIN_CODE.HUJINHUA
        local tLHBaoZi = WIN_CODE.LONGHUBAOZI

        local tHeadValue = statisticParam.Trend[1]
        local tHeadIsXDui = CS.Utility.GetLogicAndValue(tHeadValue, tLJinHua) == tLJinHua
        local tHeadIsZDui = CS.Utility.GetLogicAndValue(tHeadValue, tHJinHua) == tHJinHua
        local tHeadIsBaoZi = CS.Utility.GetLogicAndValue(tHeadValue, tLHBaoZi) == tLHBaoZi
        
        local tIsHe = CS.Utility.GetLogicAndValue(tHeadValue, tHeValue) == tHeValue
        local tRounRBeginIndex = 0
        -- 排除头部和局信息
        if tIsHe then
            -- 第一次就出现和局
            statisticParam.Trend_RHeadHeCount = 1
            statisticParam.Trend_RHeadValue = tHeadValue
            -- 找到首次非heju
            for roundR = 2, roundCount do
                local newValue = statisticParam.Trend[roundR]
                local tIsHe2 = CS.Utility.GetLogicAndValue(newValue, tHeValue) == tHeValue
                local tXDui = CS.Utility.GetLogicAndValue(newValue, tLJinHua) == tLJinHua
                local tZDui = CS.Utility.GetLogicAndValue(newValue, tHJinHua) == tHJinHua
                local tBaoZi = CS.Utility.GetLogicAndValue(newValue, tLHBaoZi) == tLHBaoZi

                if not tIsHe2  then
                    tRounRBeginIndex = roundR
                    break
                else
                    statisticParam.Trend_RHeadHeCount = statisticParam.Trend_RHeadHeCount + 1
                    if not tHeadIsXDui and tXDui then
                        statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tLJinHua
                        tHeadIsXDui = true
                    end
                    if not tHeadIsZDui and  tZDui then
                        statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tHJinHua
                        tHeadIsZDui = true
                    end
                    if not tHeadIsBaoZi and  tBaoZi then
                        statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tLHBaoZi
                        tHeadIsBaoZi = true
                    end
                end
            end
            if tRounRBeginIndex > 0 then
                -- 找到非和局开始标签
            else
                -- 目前全部是和局
            end
        else
            statisticParam.Trend_RHeadHeCount = 0
            statisticParam.Trend_RHeadValue = 0
            tRounRBeginIndex = 1
        end

        if tRounRBeginIndex > 0 then
            -- 当前存在非和局路单
            local tTrendRValue = statisticParam.Trend[tRounRBeginIndex]
            local tTrendRHeCount = statisticParam.Trend_RHeadHeCount
            local tLastValue = {TrendRValue = tTrendRValue, TrendRHeCount = tTrendRHeCount}

            local tLastXDui = CS.Utility.GetLogicAndValue(tTrendRValue, tLJinHua) == tLJinHua
            local tLastZDui = CS.Utility.GetLogicAndValue(tTrendRValue, tHJinHua) == tHJinHua
            local tLastBaoZi = CS.Utility.GetLogicAndValue(tTrendRValue, tLHBaoZi) == tLHBaoZi

            if statisticParam.Trend_RHeadHeCount > 0 then
                -- 整合头部和局信息
                local tHeadXDui = CS.Utility.GetLogicAndValue(statisticParam.Trend_RHeadValue, tLJinHua) == tLJinHua
                local tHeadZDui = CS.Utility.GetLogicAndValue(statisticParam.Trend_RHeadValue, tHJinHua) == tHJinHua
                local tHeadBaoZi = CS.Utility.GetLogicAndValue(statisticParam.Trend_RHeadValue, tLHBaoZi) == tLHBaoZi
                if not tLastXDui and tHeadXDui then
                    tLastValue.TrendRValue = tLastValue.TrendRValue + tLJinHua
                    tLastXDui = true
                end
                if not tLastZDui and tHeadZDui then
                    tLastValue.TrendRValue = tLastValue.TrendRValue + tHJinHua
                    tLastZDui = true
                end
                if not tLastBaoZi and tHeadBaoZi then
                    tLastValue.TrendRValue = tLastValue.TrendRValue + tLHBaoZi
                    tLastBaoZi = true
                end
            else
                -- 头部无和局信息
            end
            table.insert(statisticParam.Trend_R, tLastValue)
            -- 过滤和局信息
            for i = tRounRBeginIndex + 1, roundCount do
                local tTrend = statisticParam.Trend[i]
                local tIsHe = CS.Utility.GetLogicAndValue(tTrend, tHeValue) == tHeValue
                if tIsHe then
                    tLastValue.TrendRHeCount = tLastValue.TrendRHeCount + 1
                    local tXDui = CS.Utility.GetLogicAndValue(tTrend, tLJinHua) == tLJinHua
                    local tZDui = CS.Utility.GetLogicAndValue(tTrend, tHJinHua) == tHJinHua
                    local tBaoZi  = CS.Utility.GetLogicAndValue(tTrend, tLHBaoZi) == tLHBaoZi
                    if not tLastXDui and  tXDui then
                        tLastValue.TrendRValue = tLastValue.TrendRValue + tLJinHua
                        tLastXDui = true
                    end
                    if not tLastZDui and tZDui  then
                        tLastValue.TrendRValue = tLastValue.TrendRValue + tHJinHua
                        tLastZDui = true
                    end
                    if not tLastBaoZi and tZDui  then
                        tLastValue.TrendRValue = tLastValue.TrendRValue + tLHBaoZi
                        tLastBaoZi = true
                    end
                else
                    tLastValue = {TrendRValue = tTrend, TrendRHeCount = 0}
                    tLastXDui = CS.Utility.GetLogicAndValue(tTrend, tLJinHua) == tLJinHua
                    tLastZDui = CS.Utility.GetLogicAndValue(tTrend, tHJinHua) == tHJinHua
                    tLastBaoZi = CS.Utility.GetLogicAndValue(tTrend, tLHBaoZi) == tLHBaoZi
                    table.insert(statisticParam.Trend_R, tLastValue)
                end
            end
        else
            -- 当前无非和局路单
        end
    else
        -- 目前无路单信息
    end
end

-- 更新右侧统计数据
function NetMsgHandler.AppendRightStatistic(statisticParam, trendParam)
    local tHeValue = WIN_CODE.HE
    local tLJinHua = WIN_CODE.LONGJINHUA
    local tHJinHua = WIN_CODE.HUJINHUA
    local tLHBaoZi = WIN_CODE.LONGHUBAOZI
    local tNewIsHe = CS.Utility.GetLogicAndValue(trendParam, tHeValue) == tHeValue
    local tNewIsLJinHua = CS.Utility.GetLogicAndValue(trendParam, tLJinHua) == tLJinHua
    local tNewIsHJinHua = CS.Utility.GetLogicAndValue(trendParam, tHJinHua) == tHJinHua
    local tNewIsBaoZi = CS.Utility.GetLogicAndValue(trendParam, tLHBaoZi) == tLHBaoZi

    local tRightCount = #statisticParam.Trend_R

    if tNewIsHe then
        if tRightCount > 0 then
            -- 已经有路单信息 追加和局信息
            local tRightLast = statisticParam.Trend_R[tRightCount]
            tRightLast.TrendRHeCount = tRightLast.TrendRHeCount + 1
            local tXDui = CS.Utility.GetLogicAndValue(tRightLast.TrendRValue, tLJinHua) == tLJinHua
            local tZDui = CS.Utility.GetLogicAndValue(tRightLast.TrendRValue, tHJinHua) == tHJinHua
            local tBaoZi = CS.Utility.GetLogicAndValue(tRightLast.TrendRValue, tLHBaoZi) == tLHBaoZi
            if not tXDui and  tNewIsLJinHua then
                tRightLast.TrendRValue = tRightLast.TrendRValue + tLJinHua
            end
            if not tZDui and tNewIsHJinHua  then
                tRightLast.TrendRValue = tRightLast.TrendRValue + tHJinHua
            end
            if not tBaoZi and tNewIsBaoZi  then
                tRightLast.TrendRValue = tRightLast.TrendRValue + tLHBaoZi
            end
            statisticParam.Trend_R[tRightCount] = tRightLast
        else
            -- 还没有路单信息 追加和局信息
            if statisticParam.Trend_RHeadHeCount > 0 then
                -- 已经有和局累计
                local tTrendHe = statisticParam.Trend_RHeadValue
                local tXDui = CS.Utility.GetLogicAndValue(tTrendHe, tLJinHua) == tLJinHua
                local tZDui = CS.Utility.GetLogicAndValue(tTrendHe, tHJinHua) == tHJinHua
                local tBaoZi = CS.Utility.GetLogicAndValue(tTrendHe, tLHBaoZi) == tLHBaoZi
                if not tXDui and  tNewIsLJinHua then
                    statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tLJinHua
                end
                if not tZDui and tNewIsHJinHua  then
                    statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tHJinHua
                end
                if not tBaoZi and tNewIsBaoZi  then
                    statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tLHBaoZi
                end
                statisticParam.Trend_RHeadHeCount = statisticParam.Trend_RHeadHeCount + 1
            else
                -- 无和局信息
                statisticParam.Trend_RHeadHeCount = 1
                statisticParam.Trend_RHeadValue = trendParam
            end
        end
    else
        local tAppendData = {TrendRValue = trendParam, TrendRHeCount = 0}
        if tRightCount > 0 then
            -- 已经有路单信息 ==>直接追加一条新的信息
            table.insert(statisticParam.Trend_R, tAppendData)
        else
            -- 还没有路单信息
            if statisticParam.Trend_RHeadHeCount > 0 then
                -- 之前已经有和局累计
                local tTrendHe = statisticParam.Trend_RHeadValue
                local tXDui = CS.Utility.GetLogicAndValue(tTrendHe, tLJinHua) == tLJinHua
                local tZDui = CS.Utility.GetLogicAndValue(tTrendHe, tHJinHua) == tHJinHua
                local tBaoZi = CS.Utility.GetLogicAndValue(tTrendHe, tLHBaoZi) == tLHBaoZi
                if not tNewIsLJinHua and  tXDui then
                    tAppendData.TrendRValue = tAppendData.TrendRValue + tLJinHua
                end
                if not tNewIsHJinHua and tZDui  then
                    tAppendData.TrendRValue = tAppendData.TrendRValue + tHJinHua
                end
                if not tNewIsHJinHua and tBaoZi  then
                    tAppendData.TrendRValue = tAppendData.TrendRValue + tLHBaoZi
                end
                tAppendData.TrendRHeCount = statisticParam.Trend_RHeadHeCount
                table.insert(statisticParam.Trend_R, tAppendData)
            else
                -- 之前无任何信息
                table.insert(statisticParam.Trend_R, tAppendData)
            end
        end
    end
    -- 结果返回
    local tCount = #statisticParam.Trend_R
    return tNewIsHe, statisticParam.Trend_R[tCount]
end

---------------------------------------------------------------------------
-----------------S_BRJH_Game_Statistics  408------------------------------------
-- 返回全部统计信息
function NetMsgHandler.Received_S_BRJH_Game_Statistics(message)
    local statistics = NetMsgHandler.ParseOneRoomStatisticsInfo(message, true)
    statistics.Round.MaxRound = GameData.RoomInfo.CurrentRoom.MaxRound
    if statistics.Round.CurrentRound == statistics.Round.MaxRound then
        statistics.ClearFlag = true
    end
    statistics.Time = CS.UnityEngine.Time.realtimeSinceStartup
    GameData.RoomInfo.StatisticsInfo[statistics.RoomID] = statistics
    local eventArgs = { RoomID = statistics.RoomID, OperationType = 0 }
    print("=====BRJH 408 Round:", statistics.Round.CurrentRound)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics, eventArgs)
end

---------------------------------------------------------------------------
-----------------S_BRJH_Game_Append_Statistics  409-----------------------------
function NetMsgHandler.Received_S_BRJH_Game_Append_Statistics(message)
    local roomID = message:PopUInt32()
    local currentRoomID = GameData.RoomInfo.CurrentRoom.RoomID
    print("=====BRJH 409 Round:",roomID, GameData.RoomInfo.CurrentRoom.RoomID)
    if roomID ~= currentRoomID then
        return
    end

    local statistics = GameData.RoomInfo.StatisticsInfo[currentRoomID]
    local eventArgs = { RoomID = roomID, OperationType = 1 }
    if statistics.ClearFlag == true then
        statistics = NetMsgHandler.NewStatisticsInfo()
        statistics.RoomID = currentRoomID
        GameData.RoomInfo.StatisticsInfo[currentRoomID] = statistics
        eventArgs.OperationType = 0
    end

    statistics.Time = CS.UnityEngine.Time.realtimeSinceStartup
    local tTrend = message:PopByte()
    table.insert(statistics.Trend, tTrend)
    -- 右侧路单解析
    local tIsHe, tNewTrend = NetMsgHandler.AppendRightStatistic(statistics, tTrend)
    if not tIsHe then
        BJLGameMgr.AppendMatrixTrendValue(tNewTrend, statistics)

        BJLGameMgr.TryAppendBigEyeTrend(statistics)
        BJLGameMgr.TryAppendSmallTrend(statistics)
        BJLGameMgr.TryAppendYueYouTrend(statistics)
    end

    NetMsgHandler.ParseOneRoomStatisticsCounts(message, statistics.Counts)
    statistics.Round.CurrentRound = message:PopByte()

    if statistics.Round.CurrentRound == statistics.Round.MaxRound then
        statistics.ClearFlag = true
    end
    print("=====BRJH 409 Round:", statistics.Round.CurrentRound)
    GameData.RoomInfo.CurrentRoom.AppendStatisticsEventArgs = eventArgs
end

function NetMsgHandler.NewStatisticsInfo()
    local statistics = { }
    statistics.Index = 0
    statistics.RoomID = 0
    statistics.Trend = { }
    statistics.Trend_R = { }    --右侧路单信息(结果+和局数量):{TrendRValue = tTrend, TrendRHeCount = 0}
    statistics.Trend_RHeadHeCount = 0
    statistics.Trend_RHeadValue = 0
    statistics.Counts = { LongWin = 0, HuWin = 0, HeJu = 0, LongJinHua = 0, HuJinHua = 0, LongHuBaoZi = 0, RoleCount = 0 }
    statistics.Round = { CurrentRound = 0, MaxRound = 0 }
    statistics.ClearFlag = false

    statistics.Trend_Matrix = {}        -- 右侧路单矩阵信息 { value = tValue, x = posX, y = posY, pos = tLastPos}
    statistics.Trend_List = {}          -- 右侧路单列表信息(便于通过下标查找下一个数据或者上一个数据)
    statistics.Trend_LastPos = 0        -- 右侧路单记录的最后一个路单pos
    statistics.Trend_LastUpdateValue = 0  -- 右侧路单记录的最后一个路单值
    statistics.posX = 0  -- 起始坐标
    statistics.posY = 0  -- 
    statistics.Trend_BigEye = {}        -- 右侧[大眼仔]路单
    statistics.Trend_Small = {}         -- 右侧[小  路]路单
    statistics.Trend_YueYou = {}        -- 右侧[曱  甴]路单

    return statistics
end

---------------------------------------------------------------------------
-----------------CS_Request_Relative_Room  410-----------------------------
function NetMsgHandler.Send_CS_Request_Relative_Room()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Request_Relative_Room, message, true)
end

function NetMsgHandler.Received_CS_Request_Relative_Room(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 成功
        local count = message:PopUInt16()
        GameData.RoomInfo.RelationRooms = { }
        for i = 1, count, 1 do
            local roomID = message:PopUInt32()
            local masterName = message:PopString()
            GameData.RoomInfo.RelationRooms[roomID] = masterName
        end
    else
        print('--账号不存在--')
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHistoryRoomJHZUJUEvent, nil)
end

---------------------------------------------------------------------------
-----------------S_Set_Bet_First  411--------------------------------------
function NetMsgHandler.Received_S_Set_Bet_First(message)
    NetMsgHandler.ParseAndSetBetRankFirst(message)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyBetEnd, nil)
end

---------------------------------------------------------------------------
-----------------S_Set_Game_Data  412--------------------------------------
function NetMsgHandler.Received_S_Set_Game_Data(message)
    -- Home 出去 再切换回来时也会调用此接口，重新初始化房间信息
    -- 解析房间的基本信息
    -- 房间ID
    GameData.RoomInfo.CurrentRoom.RoomID = message:PopUInt32()
    -- 房间模板ID
    GameData.RoomInfo.CurrentRoom.TemplateID = message:PopByte()
    -- 房主账号ID
    GameData.RoomInfo.CurrentRoom.MasterID = message:PopUInt32()
    -- 房间最大局数
    GameData.RoomInfo.CurrentRoom.MaxRound = message:PopByte()
    -- 以进行局数
    GameData.RoomInfo.CurrentRoom.CurrentRound = message:PopByte()
    -- 房间状态
    GameData.RoomInfo.CurrentRoom.RoomState = message:PopByte()
    -- 房间倒计时
    GameData.RoomInfo.CurrentRoom.CountDown = message:PopUInt32() / 1000.0
    -- 金花下注下限
    GameData.RoomInfo.CurrentRoom.BetJinHuaMin = message:PopInt64()
    -- 金花下注上限
    GameData.RoomInfo.CurrentRoom.BetJinHuaMax = message:PopInt64()
    -- 豹子下注下限
    GameData.RoomInfo.CurrentRoom.BetBaoZiMin = message:PopInt64()
    -- 豹子下注上限
    GameData.RoomInfo.CurrentRoom.BetBaoZiMax = message:PopInt64()
    -- 龙虎下注下限
    GameData.RoomInfo.CurrentRoom.BetLongHuMin = message:PopInt64()
    -- 龙虎下注上限
    GameData.RoomInfo.CurrentRoom.BetLongHuMax = message:PopInt64()
    -- print("百人厅房间模板:", GameData.RoomInfo.CurrentRoom.TemplateID)
    local roomConfig = data.RoomConfig[GameData.RoomInfo.CurrentRoom.TemplateID]
    if roomConfig ~= nil then
        GameData.RoomInfo.CurrentRoom.IsFreeRoom = roomConfig.Type == 2
        GameData.RoomInfo.CurrentRoom.IsVipRoom = roomConfig.Type == 3
    end

    -- 解压个人押注信息
    NetMsgHandler.ParseAndSetBetValue(message)
    -- 解压总押注信息
    NetMsgHandler.ParseAndSetTotalBetValue(message)

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetValue, 3)

    -- 解析已押注到押注区域的筹码信息
    NetMsgHandler.ParseAndSetChipsOnBetAreas(message)

    -- 解析庄家信息
    NetMsgHandler.ParseAndSetBankerInfo(message)

    -- 解析扑克牌
    local cardCount = message:PopUInt16()
    NetMsgHandler.ParseAndSetPokerCards(message, cardCount)
    -- 解析扑克牌状态
    NetMsgHandler.SetRoleCardCurrentState(1, message:PopByte(), false)
    NetMsgHandler.SetRoleCardCurrentState(2, message:PopByte(), false)
    -- 解析游戏结果
    GameData.RoomInfo.CurrentRoom.GameResult = message:PopByte()
    -- 押注排行榜第一名信息
    NetMsgHandler.ParseAndSetBetRankFirst(message)

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, GameData.RoomInfo.CurrentRoom.RoomState)

end

-- 解析自身押注信息
function NetMsgHandler.ParseAndSetBetValue(message)
    local betCount = message:PopUInt16()
    if betCount > 0 then
        for index = 1, betCount, 1 do
            local betArea = message:PopByte()
            local betValue = message:PopInt64()
            GameData.RoomInfo.CurrentRoom.BetValues[betArea] = betValue
        end
    end
end

-- 解析总押注信息
function NetMsgHandler.ParseAndSetTotalBetValue(message)
    local totalBetCount = message:PopUInt16()
    if totalBetCount > 0 then
        for index = 1, totalBetCount, 1 do
            local totalBetArea = message:PopByte()
            local totalBetValue = message:PopInt64()
            GameData.RoomInfo.CurrentRoom.TotalBetValues[totalBetArea] = totalBetValue
        end
    end
end

-- 解析押注区域已经存在的筹码信息
function NetMsgHandler.ParseAndSetChipsOnBetAreas(message)
    -- 解析桌面上已有的筹码面值和数量
    local count = message:PopUInt16()
    local currentRoomChips = { }
    for index = 1, count, 1 do
        local betArea = message:PopByte()
        local chipValue = message:PopUInt32()
        local chipCount = message:PopUInt32()
        local betAreaInfo = currentRoomChips[betArea]
        if betAreaInfo == nil then
            betAreaInfo = { }
            currentRoomChips[betArea] = betAreaInfo
        end

        local chipInfo = betAreaInfo[chipValue]
        if chipInfo == nil then
            chipInfo = { }
            betAreaInfo[chipValue] = chipInfo
        end
        chipInfo.Count = chipCount
    end
    GameData.RoomInfo.CurrentRoomChips = currentRoomChips
end

-- 解析设置庄家信息
function NetMsgHandler.ParseAndSetBankerInfo(message)
    if GameData.RoomInfo.CurrentRoom.BankerInfo == nil then
        GameData.RoomInfo.CurrentRoom.BankerInfo = { }
    end
    GameData.RoomInfo.CurrentRoom.BankerInfo.ID = message:PopUInt32()
    GameData.RoomInfo.CurrentRoom.BankerInfo.Name = message:PopString()
    GameData.RoomInfo.CurrentRoom.BankerInfo.Gold = message:PopInt64()
    -- 庄家剩余局数
    GameData.RoomInfo.CurrentRoom.BankerInfo.LeftCount = message:PopByte()
    -- 头像ID
    GameData.RoomInfo.CurrentRoom.BankerInfo.HeadIcon = message:PopByte()
    -- 上一个庄家是否被强制下庄
    GameData.RoomInfo.CurrentRoom.BankerInfo.IsLastForceDownBanker = message:PopByte() == 1
    GameData.RoomInfo.CurrentRoom.BankerInfo.strLoginIP = message:PopString()
end

-- 解析收到的扑克牌
function NetMsgHandler.ParseAndSetPokerCards(message, count)
    for index = 1, count, 1 do
        GameData.RoomInfo.CurrentRoom.Pokers[index] = { }
        local pokerType = message:PopByte()
        local pokerNumber = message:PopByte()
        GameData.RoomInfo.CurrentRoom.Pokers[index].PokerType = pokerType
        GameData.RoomInfo.CurrentRoom.Pokers[index].PokerNumber = pokerNumber
        GameData.RoomInfo.CurrentRoom.Pokers[index].Visible =(index % 3 == 1)
        -- 第一张可见其它不可见
    end
end

-- 设置角色扑克牌的当前状态标志
function NetMsgHandler.SetRoleCardCurrentState(roleType, cardState, isNotify)
    local cardIndex1 = 1
    local cardIndex2 = 2
    local cardIndex3 = 3
    if roleType == 2 then
        cardIndex1 = 4
        cardIndex2 = 5
        cardIndex3 = 6
    end
    if GameData.RoomInfo.CurrentRoom.Pokers ~= nil and #GameData.RoomInfo.CurrentRoom.Pokers > 0 then
        NetMsgHandler.ResetPokerCardVisible(cardIndex1, true, isNotify)
        NetMsgHandler.ResetPokerCardVisible(cardIndex2,(cardState == 2 or cardState == 4), isNotify)
        NetMsgHandler.ResetPokerCardVisible(cardIndex3,(cardState == 3 or cardState == 4), isNotify)
    end
end

function NetMsgHandler.ResetPokerCardVisible(cardIndex, visible, isNotify)
    if GameData.RoomInfo.CurrentRoom.Pokers[cardIndex].Visible ~= visible then
        GameData.RoomInfo.CurrentRoom.Pokers[cardIndex].Visible = visible
        if isNotify then
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.PokerVisibleChanged, cardIndex)
        end
    end
end

-- 解析设置押注排行第一信息
function NetMsgHandler.ParseAndSetBetRankFirst(message)
    GameData.RoomInfo.CurrentRoom.CheckRole1.ID = message:PopUInt32()
    --GameData.RoomInfo.CurrentRoom.CheckRole1.Name = message:PopString()
    
    local longIcon = message:PopByte()
    --GameData.RoomInfo.CurrentRoom.CheckRole1.HeadUrl = message:PopString()
    GameData.RoomInfo.CurrentRoom.CheckRole1.strLoginIP = message:PopString()


    GameData.RoomInfo.CurrentRoom.CheckRole2.ID = message:PopUInt32()
    --GameData.RoomInfo.CurrentRoom.CheckRole2.Name = message:PopString()
    local huIcon = message:PopByte()
    --GameData.RoomInfo.CurrentRoom.CheckRole2.HeadUrl = message:PopString()
    GameData.RoomInfo.CurrentRoom.CheckRole2.strLoginIP = message:PopString()
    -- 龙头像
    GameData.RoomInfo.CurrentRoom.CheckRole1.Icon = longIcon
    -- 虎头像
    GameData.RoomInfo.CurrentRoom.CheckRole2.Icon = huIcon
end

---------------------------------------------------------------------------
-----------------CS_Vip_Start_Game  413------------------------------------
function NetMsgHandler.Send_CS_Vip_Start_Game()
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID);
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Vip_Start_Game, message, false);
end

function NetMsgHandler.Received_CS_Vip_Start_Game(message)
    local resultType = message:PopByte()
    -- 策划新需求 #58 【提示优化】
    if resultType ~= 3 and resultType ~= 4 then
        CS.BubblePrompt.Show(data.GetString("Start_Game_Error_" .. resultType), "GameUI2");
    end
end

---------------------------------------------------------------------------
-----------------S_Notify_Game_End  414------------------------------------
function NetMsgHandler.Received_S_Notify_Game_End(message)
    GameData.SetRoomState(ROOM_STATE.WAIT)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyEndGame, true)
end

---------------------------------------------------------------------------
-----------------CS_Request_Continue_Game  415-----------------------------
function NetMsgHandler.Send_CS_Request_Continue_Game(message)
    print("CS_Request_Continue_Game");
end

function NetMsgHandler.Received_CS_Request_Continue_Game(message)
    print("CS_Request_Continue_Game");
end

---------------------------------------------------------------------------
-----------------S_Notify_Game_Player_Count  416---------------------------
function NetMsgHandler.Received_S_Notify_Game_Player_Count(message)
    GameData.RoomInfo.CurrentRoom.RoleCount = message:PopUInt16()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoleCount, GameData.RoomInfo.CurrentRoom.RoleCount)
end

---------------------------------------------------------------------------
-----------------CS_Up_Banker  417-----------------------------------------
function NetMsgHandler.Send_CS_Up_Banker()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Up_Banker, message, false)
end

function NetMsgHandler.Received_CS_Up_Banker(message)
    local resultType = message:PopByte();
    local showMsg = data.GetString("Up_Bank_Error_" .. resultType)
    if resultType == 4 then
        local roomConfig = data.RoomConfig[GameData.RoomInfo.CurrentRoom.TemplateID]
        if roomConfig ~= nil then
            showMsg = string.format(showMsg, lua_NumberToStyle1String(roomConfig.UpBankerGold))
        end
    end
    CS.BubblePrompt.Show(showMsg, "GameUI2");
end

---------------------------------------------------------------------------
-----------------CS_Up_Banker_List  418------------------------------------
function NetMsgHandler.Send_CS_Up_Banker_List()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Up_Banker_List, message, false)
end

function NetMsgHandler.Received_CS_Up_Banker_List(message)
    local resultType = message:PopByte()
    local count = message:PopUInt16()
    GameData.RoomInfo.CurrentRoom.BankerList = { }
    for index = 1, count, 1 do
        local bankerInfo = { }
        bankerInfo.ID = message:PopUInt32()
        bankerInfo.Name = message:PopString()
        bankerInfo.GoldCount = message:PopInt64()
        bankerInfo.VipLevel = message:PopByte()
        bankerInfo.strLoginIP = message:PopString()
        GameData.RoomInfo.CurrentRoom.BankerList[index] = bankerInfo
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBankerList, nil)
end

---------------------------------------------------------------------------
-----------------S_Notify_Win_Gold  420------------------------------------
function NetMsgHandler.Received_S_Notify_Win_Gold(message)
    local count = message:PopUInt16()
    GameData.RoomInfo.CurrentRoom.WinGold.NoPayAll = false
    for index = 1, count, 1 do
        local winCode = message:PopByte()
        local betValue = message:PopInt64()
        local winValue = message:PopInt64()
        local isPayOff = message:PopByte()
        GameData.RoomInfo.CurrentRoom.WinGold[WIN_AREA_CODE[winCode]] = { BetValue = betValue, WinGold = winValue, IsPayOff = isPayOff }
        if isPayOff == 1 then
            -- 有未赔付的情况
            GameData.RoomInfo.CurrentRoom.WinGold.NoPayAll = true
        end
    end

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyWinGold, nil)
end

---------------------------------------------------------------------------
-----------------S_Update_Banker  421--------------------------------------
function NetMsgHandler.Received_S_Update_Banker(message)
    local lastBankerName = GameData.RoomInfo.CurrentRoom.BankerInfo.strLoginIP
    NetMsgHandler.ParseAndSetBankerInfo(message)

    if GameData.RoomInfo.CurrentRoom.BankerInfo.IsLastForceDownBanker then
        CS.BubblePrompt.Show(string.format(data.GetString("Down_Banker_Tips_Force"), lastBankerName), "GameUI2")
    end

    CS.BubblePrompt.Show(string.format(data.GetString("Update_Banker_Tips"), GameData.RoomInfo.CurrentRoom.BankerInfo.strLoginIP), "GameUI2")

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBankerInfo, 1)
end

---------------------------------------------------------------------------
-----------------S_Update_Banker_Gold  422---------------------------------
function NetMsgHandler.Received_S_Update_Banker_Gold(message)
    GameData.RoomInfo.CurrentRoom.BankerInfo.Gold = message:PopInt64()
    GameData.RoomInfo.CurrentRoom.BankerInfo.LeftCount = message:PopByte()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBankerInfo, 1)

    -- print("***BRJH** 333:", GameData.RoomInfo.CurrentRoom.BankerInfo.Gold, GameData.RoomInfo.CurrentRoom.BankerInfo.LeftCount)
end

---------------------------------------------------------------------------
-----------------CS_Cut_Card  423------------------------------------------
function NetMsgHandler.Send_CS_Cut_Card(index)
    -- print('给服务器发切的第几张牌', index)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(index)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Cut_Card, message, false)
end

function NetMsgHandler.Received_CS_Cut_Card(message)
    local resultType = message:PopByte()
    -- print('服务器返回切牌结果', resultType)
    if resultType ~= 0 then
    end
end

---------------------------------------------------------------------------
-----------------CS_Request_Role_List  424---------------------------------
function NetMsgHandler.Send_CS_Request_Role_List()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Request_Role_List, message, true)
end

function NetMsgHandler.Received_CS_Request_Role_List(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local count = message:PopUInt16()
        local playerList = { }
        for index = 1, count, 1 do
            local player = { }
            player.AccountID = message:PopUInt32()
            --player.AccountName = message:PopString()
            player.GoldCount = message:PopInt64()
            player.HeadIcon = message:PopByte()
            playerList[index] = player
            player.strLoginIP = message:PopString()
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateRoomPlayerList, playerList)
    else
        CS.BubblePrompt.Show(data.GetString("Role_List_Error" .. resultType), "GameUI2")
    end
end

---------------------------------------------------------------------------
------------------------CS_Player_Cut_Type  425----------------------------
function NetMsgHandler.CS_Player_Cut_Type(pokerType)
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(pokerType)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_Cut_Type, message, false)
end

function NetMsgHandler.Received_CS_Player_Cut_Type(message)
    -- body
    local result = message:PopByte()
    if result == 0 then
        local pokerType = message:PopByte()
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyCutPokerType, pokerType)
    else
        -- 有误1账号不存在 2房间不存在 3不是搓牌状态
    end

end

--------------------------------------------------------------------------
------------------------CS_Player_Icon_Change  426------------------------

-- 请求切换玩家头像icon
function NetMsgHandler.CS_Player_Icon_Change(iconid)
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(iconid)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_Icon_Change, message, false)
end

-- Sever反馈头像修改结果
function NetMsgHandler.Received_CS_Player_Icon_Change(message)
    -- body
    local result = message:PopByte()
    if result == 0 then
        local headIcon = message:PopByte()
        GameData.RoleInfo.AccountIcon = headIcon
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHeadIconChange, headIcon)
    else
        -- 有误1账号不存在 2头像ID不存在
    end
end

--------------------------------------------------------------------------
------------------------------CS_Player_YuYinChat 427---------------------

function NetMsgHandler.CS_Player_YuYinChat( fileTime, fileUrl, fileExt)
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(fileTime)
    message:PushString(fileUrl)
    message:PushString(fileExt)
    print('语音聊天发送:',fileUrl, fileExt, fileTime)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_YuYinChat, message, false)
end

-- 服务器反馈语音聊天发送结果
function NetMsgHandler.Received_CS_Player_YuYinChat(message)
    -- body
    local result = message:PopByte()
    if result == 0 then
        local chatData = { }
        chatData.AccountID = message:PopUInt32()
        chatData.name = message:PopString()
        chatData.headIcon = message:PopByte()
        chatData.headUrl = message:PopString()
        chatData.filePath = ""
        chatData.fileTime = message:PopUInt32()
        chatData.fileUrl = message:PopString()
        chatData.fileExt = message:PopString()
        

        print(string.format("=====[%s] send chat icon[%d]", chatData.name, chatData.headIcon))
    else
        -- 有误1账号不存在 2房间不存在 3 房间不是VIP房 4 冷却中...
        error("player YuYin chat error" .. result)
    end
end

---------------------------------------------------------------------------
-----------------CS_Apply_Down_Banker  428---------------------------------
function NetMsgHandler.Send_CS_Apply_Down_Banker()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Apply_Down_Banker, message, false)
end

function NetMsgHandler.Received_CS_Apply_Down_Banker(message)
    local resultType = message:PopByte()
    CS.BubblePrompt.Show(data.GetString("Down_Banker_Error_" .. resultType), "GameUI2")
end

---------------------------------------------------------------------------
-----------------CS_Apply_Banker_State  429--------------------------------
function NetMsgHandler.Send_CS_Apply_Banker_State()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Apply_Banker_State, message, false)
end

function NetMsgHandler.Received_CS_Apply_Banker_State(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local state = message:PopByte()
        if state == 0 then
            if GameData.RoleInfo.AccountID == GameData.RoomInfo.CurrentRoom.BankerInfo.ID then
                local boxData = CS.MessageBoxData()
                boxData.Title = "提示"
                boxData.Content = data.GetString("Down_Banker_Tips")
                boxData.Style = 2
                boxData.OKButtonName = "放弃"
                boxData.CancelButtonName = "确定"
                boxData.LuaCallBack = DownBankerButtonMessageBoxCallBack
                local parentWindow = CS.WindowManager.Instance:FindWindowNodeByName("GameUI2")
                CS.MessageBoxUI.Show(boxData, parentWindow)
            end
        elseif state == 1 then
            CS.BubblePrompt.Show(data.GetString("Down_Banker_Error_4"), "GameUI2")
        end
    end
end

function DownBankerButtonMessageBoxCallBack(result)
    if result == 2 then
        -- 取消和确定位置反向了的
        if GameData.RoleInfo.AccountID == GameData.RoomInfo.CurrentRoom.BankerInfo.ID then
            NetMsgHandler.Send_CS_Apply_Down_Banker()
        end
    end
end

-------------------------------------------------------------------------------
------------------------------S_Room_Change  430-------------------------------
-- 对战类游戏3局，系统自动重新匹配一次
function NetMsgHandler.Received_S_Room_Change(message)
    local resultType = message:PopByte()
    print("=====430 result:", resultType)
    if resultType == 0 then
        CS.BubblePrompt.Show(data.GetString("T_430_0"), "HallUI")
    else
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyRoomChangeEvent, nil)
    end
end

-------------------------------------------------------------------------------
------------------------------CS_Player_BeneFit  431---------------------------

-- 踢出百人金花
function NetMsgHandler.Accept_CS_Player_BeneFit(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    local boxData = CS.MessageBoxData()
    boxData.Title = "提示"
    boxData.Content = data.GetString("OUT_ROOM_" .. resultType)
    boxData.Style = 1
    if resultType == 1 then
        boxData.LuaCallBack = NetMsgHandler.GoldNotEnoughConfirmOnClick
    end
    if resultType == 4 then
        local GoldValue = mess:PopInt64()
    end
    -- 直接提出房间并弹出提示
    CS.MessageBoxUI.Show(boxData)
    NetMsgHandler.ExitRoomToHall(0)
end

---------------------------------------------------------------------------
-----------------Send_CS_JH_XYZPRoomList  432--------------------------------
-- 玩家请求幸运转盘房间列表
function NetMsgHandler.Send_CS_JH_XYZPRoomList()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_XYZPRoomList, message,false)
end
-- 返回转盘人数信息
function NetMsgHandler.Accept_CS_JH_XYZPInfo(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        --0 领取成功  1账号不存在
        local  Level = { }
        local count=message:PopUInt16()
        for i = 1, count do
            local info={ }
            local OnlineCount = message:PopUInt16()
            info.OnlineCount=OnlineCount
            Level[i]=info
        end
        GameData.OnlineCount=Level
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomOnlineEvent)
       
    else
      
    end
end

---------------------------------------------------------------------------
-----------------SendCS_JH_BMBCRoomList  1152--------------------------------
-- 玩家请求宝马奔驰房间列表
function NetMsgHandler.Send_CS_JH_BMBCRoomList()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_BMBCRoomList, message,false)
end
-- 返回转盘人数信息
function NetMsgHandler.Accept_CS_JH_BMBCInfo(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        --0 领取成功  1账号不存在
        local  Level = { }
        local count=message:PopUInt16()
        for i = 1, count do
            local info={ }
            local OnlineCount = message:PopUInt16()
            info.OnlineCount=OnlineCount
            Level[i]=info
        end
        GameData.BMBCOnlineCount=Level
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomOnlineEvent)
       
    else
      
    end
end


---------------------------------------------------------------------------
-----------------CS_Daily_Wheel_Info  433--------------------------------
-- 每日轮盘信息请求
function NetMsgHandler.Send_CS_Daily_Wheel_Info(level)
    CS.MatchLoadingUI.Show();
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(level)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Daily_Wheel_Info,message,false)
end

-- 轮盘信息请求反馈
function NetMsgHandler.Received_CS_Daily_Wheel_Info(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        --CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
        --获取房间等级
        local  level=message:PopByte()
        GameData.XYZPChooseRoomLevel=level
        GameData.RoomInfo.CurrentRoom.RoomID = level
        -- 转动一次花费
        GameData.FortunateInfo.RotateOnceGold = message:PopInt64()
        GameData.FortunateInfo.RotateOnceGold = GameConfig.GetFormatColdNumber(GameData.FortunateInfo.RotateOnceGold)
        -- 档次一奖励
        GameData.FortunateInfo.WinningGradegOLD[1] = message:PopInt64()
        -- 档次二奖励
        GameData.FortunateInfo.WinningGradegOLD[2] = message:PopInt64()
        -- 档次三奖励
        GameData.FortunateInfo.WinningGradegOLD[3] = message:PopInt64()
        -- 档次四奖励
        GameData.FortunateInfo.WinningGradegOLD[4] = message:PopInt64()
        -- 档次五奖励
        GameData.FortunateInfo.WinningGradegOLD[5] = message:PopInt64()
        -- 档次六奖励
        GameData.FortunateInfo.WinningGradegOLD[6] = message:PopInt64()
        -- 档次七奖励
        GameData.FortunateInfo.WinningGradegOLD[7] = message:PopInt64()
        -- 档次八奖励
        GameData.FortunateInfo.WinningGradegOLD[8] = message:PopInt64()
        for Index = 1, 8, 1 do
            GameData.FortunateInfo.WinningGradegOLD[Index] = GameConfig.GetFormatColdNumber(GameData.FortunateInfo.WinningGradegOLD[Index])
        end

        -- 获奖玩家数量
        local count = message:PopUInt16()
        GameData.WheelWinInfo={}
        for Index=1,count,1 do
            -- 获奖玩家名字
            local playerName = message:PopString()
            -- 获奖玩家金币
            local playerGold = message:PopInt64()
            -- 玩家地址
            local strLoginIP = message:PopString()
            playerGold=lua_CommaSeperate(GameConfig.GetFormatColdNumber(playerGold))
            table.insert( GameData.WheelWinInfo,{PlayerName=playerName,PlayerGold=playerGold,StrLoginIP=strLoginIP} )
        end
        local tWheelUI = CS.WindowManager.Instance:FindWindowNodeByName("BonusWheelUI")
        local gold = GameData.RoleInfo.GoldCount/10000
        local enterLimit = lua_CommaSeperate(data.TurnTableConfig[level*8-8+1].EnterLimit[1])
        if tWheelUI ~= nil then
            tWheelUI.WindowData = 1
            CS.MatchLoadingUI.Hide();
        else   
            print("gold > enterLimit")
            print(tonumber(gold)  >tonumber(enterLimit))
            if tonumber(gold)  >= tonumber(enterLimit)  then
                CS.WindowManager.Instance:OpenWindow("BonusWheelUI")
            else
                -- GameData.Exit_MoneyNotEnough = true;
                CS.BubblePrompt.Show("您的金币不足，请充值", "HallUI")
            end
        end
       
    else
        CS.MatchLoadingUI.Hide()
        if resultType == 4 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType ~= 5 then
                CS.BubblePrompt.Show(data.GetString("T_433_"..resultType),"BonusWheelUI")
            else
                local GoldValue = message:PopInt64()
                CS.BubblePrompt.Show(data.GetString("T_433_"..resultType),"BonusWheelUI")
            end
        end
    end
end

---------------------------------------------------------------------------
-----------------CS_Daily_Wheel_Reward  434--------------------------------
-- 每日轮盘信息请求     --TUDOU
function NetMsgHandler.Send_CS_Daily_Wheel_Reward(level, time_Lottery)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(level)
    --TUDOU  旋转次数
    message:PushUInt16(time_Lottery);
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Daily_Wheel_Reward,message, false)
end
---------------------TUDOU
-- 轮盘信息请求反馈
function NetMsgHandler.Received_CS_Daily_Wheel_Reward(message)
    CS.LoadingDataUI.Hide();
    local tempIndex = 0;
    local tempMoney = 0;
    local tempLotteryTime = 0;
    local money = 0;
    local resultType = message:PopByte();
    GameData.FortunateInfo.table_RewardMoney = {};
    if resultType == 0 then
        GameData.FortunateInfo.allMoney = message:PopInt64();
        tempLotteryTime = message:PopUInt16();
        GameData.FortunateInfo.time_Lottery = tempLotteryTime;
        for k = 1, tempLotteryTime do
            tempIndex = message:PopByte();
            tempMoney = message:PopInt64();
            table.insert(GameData.FortunateInfo.table_RewardMoney, {index=tempIndex, money = tempMoney});
        end
        GameData.FortunateInfo.level_LastLottery = message:PopByte();
        money = message:PopInt64();
        GameData.FortunateInfo.playerMoney = money;
        GameData.RoleInfo.GoldCount = money;
    else
        if resultType >= 3 then
            local Value = message:PopInt64()
            Value=GameConfig.GetFormatColdNumber(Value)
            CS.BubblePrompt.Show(string.format(data.GetString("JH_Wheel_Tips_"..resultType),Value),"BonusWheelUI")
        else
            CS.BubblePrompt.Show(data.GetString("JH_Wheel_Tips_"..resultType),"BonusWheelUI")
        end
        
    end
    table.sort(GameData.FortunateInfo.table_RewardMoney, function(a, b)
        return a.money > b.money;
    end)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyWheelRewardEvent, resultType);
end

---------------------------------------------------------------------------
-----------------CS_CDK_Reward  435--------------------------------
-- 每日轮盘信息请求
function NetMsgHandler.Send_CS_CDK_Reward(_cdk)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushString(_cdk)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_CDK_Reward,message,true)
end

-- 轮盘信息请求反馈
function NetMsgHandler.Received_CS_CDK_Reward(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRewardValue = message:PopInt64()
        local tReward = lua_CommaSeperate(GameConfig.GetFormatColdNumber(tRewardValue))
        CS.BubblePrompt.Show(string.format(data.GetString("JH_CDK_Error_0"), tReward),"CDKUI")
    else
        CS.BubblePrompt.Show(data.GetString("JH_CDK_Error_"..resultType),"CDKUI")
    end
end

---------------------------------------------------------------------------
-----------------CS_Exit_Wheel  439--------------------------------
-- 关闭每日轮盘信息请求
function NetMsgHandler.Send_CS_Exit_Wheel(level)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(level)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Exit_Wheel,message,true)
end

-- 关闭轮盘请求反馈
function NetMsgHandler.Received_CS_Exit_Wheel(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        NetMsgHandler.ExitRoomToHall(0)
        --CS.WindowManager.Instance:CloseWindow("BonusWheelUI",false)
        HandleRefreshHallUIShowState(true)
    else
        CS.BubblePrompt.Show(data.GetString("JH_Exit_Wheel_"..resultType),"BonusWheelUI")
    end
end

---------------------------------------------------------------------------
-----------------S_Wheel_WinningInfo  440--------------------------------
-- 幸运转盘中奖玩家信息
function NetMsgHandler.Received_S_Wheel_WinningInfo(message)
    local BonusWheelUI = CS.WindowManager.Instance:FindWindowNodeByName("BonusWheelUI")
    local playerName = message:PopString()
    local playerGold = message:PopInt64()
    local strLoginIP = message:PopString()
    playerGold=lua_CommaSeperate(GameConfig.GetFormatColdNumber(playerGold))
    table.insert( GameData.WheelWinInfo,{PlayerName=playerName,PlayerGold=playerGold,StrLoginIP=strLoginIP} )
    if #GameData.WheelWinInfo>5 then
        local count = #GameData.WheelWinInfo-5
        for Index=1,count,1 do
            table.remove(GameData.WheelWinInfo,1)
        end
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyWheelUpdateWinInfo)
end

---------------------------------------------------------------------------
-----------------S_Car_WinningInfo  441--------------------------------
-- 奔驰宝马中奖玩家信息
function NetMsgHandler.Received_S_Car_WinningInfo(message)
    local BonusWheelUI = CS.WindowManager.Instance:FindWindowNodeByName("CarRotationUI")
    local Count = message:PopUInt16()
    for Index=1,Count,1 do
        local playerName = message:PopString()
        local playerGold = message:PopInt64()
        local strLoginIP = message:PopString()
        playerGold=lua_CommaSeperate(GameConfig.GetFormatColdNumber(playerGold))
        table.insert( GameData.CarWinnInfo,{PlayerName=playerName,PlayerGold=playerGold,StrLoginIP=strLoginIP} )
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyCarUpdateWinInfo,nil)
end

---------------------------------------------------------------------------
-----------------S_SSC_WinningInfo  442--------------------------------
-- 时时彩中奖玩家信息
function NetMsgHandler.Received_S_SSC_WinningInfo(message)
    local BonusWheelUI = CS.WindowManager.Instance:FindWindowNodeByName("TimeTimeColor")
    local Count = message:PopUInt16()
    for Index=1,Count,1 do
        local playerName = message:PopString()
        local playerGold = message:PopInt64()
        local strLoginIP = message:PopString()
        playerGold=lua_CommaSeperate(GameConfig.GetFormatColdNumber(playerGold))
        table.insert( GameData.SscWinnInfo,{PlayerName=playerName,PlayerGold=playerGold,StrLoginIP=strLoginIP} )
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifySscUpdateWinInfo,nil)
end

---------------------------------------------------------------------------
-----------------S_Add_MoveNotice  500-------------------------------------
-- 处理收到服务器播放跑马灯消息
function NetMsgHandler.HandleAddMoveNotice(message)
    --local level = message:PopByte()
    --local enumType = message:PopByte()
    local strNotice = message:PopString()
    -- 跑马灯管理器添加数据
    --if enumType == 255 then
        --CS.MoveNotice.Notice(name, level)
    --else
    
        CS.MoveNotice.Notice(strNotice, 1)
    --end
    --print('=====500*****Time:', CS.UnityEngine.Time.time)
end

---------------------------------------------------------------------------
-----------------CS_SmallHorn  501-----------------------------------------
-- 发送 小喇叭 协议
function NetMsgHandler.SendSmallHorn(contentString)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushString(contentString)
    -- 小喇叭字符串信息压入消息结构体
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_SmallHorn, message, true);
end

function NetMsgHandler.HandleSmallHorn(message)
    -- print('收到小喇叭返回协议')
    CS.LoadingDataUI.Hide();
    local result = message:PopByte()
    if result == 0 then
        -- 通知界面发送小喇叭消息成功
        return
    else
        CS.BubblePrompt.Show(data.GetString("SmallHorn_Error_" .. result), "NBNotice")
        return
    end
end

---------------------------------------------------------------------------
-----------------CS_SEND_EMAIL  502----------------------------------------
-- 发送邮件
function NetMsgHandler.SendEmail(title, content, receiverID, gold)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushByte(2)
    -- 邮件发送者类型
    message:PushString(title)
    -- 邮件标题
    message:PushString(content)
    -- 邮件内容
    message:PushUInt32(receiverID)
    -- 接收者id
    message:PushUInt64(gold)
    -- 邮件附带金币数
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_SEND_EMAIL, message, true);
end

-- 服务器回复发送结果
function NetMsgHandler.HandleSendEmailResult(message)
    -- print('收到邮件发送结果')
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()
    if result == 0 then
        local sendTo = message:PopUInt32()
        local goldCount = message:PopInt64()
        local feeCount = message:PopInt64()
        if goldCount > 0 then
            -- 金币邮件，提示
            local boxData = CS.MessageBoxData()
            boxData.Title = "提示"
            local formatStr = data.GetString("Tips_Send_Mail_Success")
            boxData.Content = string.format(formatStr, lua_CommaSeperate(GameConfig.GetFormatColdNumber(goldCount)), tostring(sendTo), lua_CommaSeperate(GameConfig.GetFormatColdNumber(feeCount)))
            boxData.Style = 1
            CS.MessageBoxUI.Show(boxData)
        else
            CS.BubblePrompt.Show(EmailMgr:GetSendMailError(result), "UIEmail")
        end
    else
        CS.BubblePrompt.Show(EmailMgr:GetSendMailError(result), "UIEmail")
    end

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifySendMailResult, result)
end

---------------------------------------------------------------------------
-----------------CS_CHECK_ACCOUNTID  503-----------------------------------
-- 检查账号有效性
function NetMsgHandler.SendCheckAccountID(accountID)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushUInt32(accountID)
    -- 待检测账号
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_CHECK_ACCOUNTID, message, true)
end

-- 账号检测结果
function NetMsgHandler.HandleCheckAccountIDResult(message)
    CS.LoadingDataUI.Hide();
    local result = message:PopByte()
    local vipLevel = 0
    local canSendGold = 0
    if result == 0 then
        vipLevel = message:PopByte()
        canSendGold = message:PopByte()
    elseif result == 1 then
        CS.BubblePrompt.Show("账号无效", "UIEmail")
    end
    --print('发红包标记:' .. canSendGold)
    local eventArg = { ResultType = result, VipLevel = vipLevel, CanSendGold = canSendGold }
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyEmailRoleInfo, eventArg)
end

---------------------------------------------------------------------------
-----------------CS_OTHER_PLAYER_INFO  504---------------------------------
-- 请求邮件发送者信息
function NetMsgHandler.SendOtherPlayerInfoRequest(accountID)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushUInt32(accountID)
    -- 对方账号
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_OTHER_PLAYER_INFO, message, true);
end

-- 返回邮件发送者信息
function NetMsgHandler.HandleOtherPlayerInfoResult(message)
    -- print('收到服务器发来的其他玩家信息')
    CS.LoadingDataUI.Hide();
    local result = message:PopByte()
    if result == 0 then
        --print('服务器说账号有效')
        local name = message:PopString()
        local nGold = message:PopUInt64()
        local nRoomCard = message:PopUInt32()
        local nRank = message:PopByte()
        local headIconUrl = message:PopString()
        return
    elseif result == 1 then
        --print('服务器说账号无效')
        CS.BubblePrompt.Show("账号无效", "UIEmail");
        return
    end
end

---------------------------------------------------------------------------
-----------------C_CHANGE_EMAIL_TO_READED  505-----------------------------
-- 标记邮件为已读，此协议无需服务器返回结果
function NetMsgHandler.SendReadEmail(emailID)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushUInt32(emailID)
    -- 邮件id
    NetMsgHandler.SendMessageToGame(ProtrocolID.C_CHANGE_EMAIL_TO_READED, message, false);
end

---------------------------------------------------------------------------
-----------------CS_GET_EMAIL_REWARD  506----------------------------------
-- 请求获取邮件内奖励
function NetMsgHandler.SendGetEmailReward(emailID)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushUInt32(emailID)
    -- 邮件id
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_GET_EMAIL_REWARD, message, true);
end

-- 返回获取邮件奖励结果
function NetMsgHandler.HandleGetEmailRewardResult(message)
    local result = message:PopByte()
    if result == 0 then
        -- 领取成功
        CS.BubblePrompt.Show("领取成功", "UIEmail");
        local mailID = message:PopUInt32()
        EmailMgr:GetMailReward(mailID)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateEmailInfo)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.updateEmailAttachment)
        return
    elseif result == 1 then
        --print('服务器说邮件无效')
        CS.BubblePrompt.Show("邮件无效", "UIEmail");
        return
    elseif result == 2 then
        -- print('服务器说已领取了该邮件')
        CS.BubblePrompt.Show("已领取了该邮件", "UIEmail");
        return
    end
end


---------------------------------------------------------------------------
-----------------CS_ADD_EMAILS  507----------------------------------------
-- 向服务器请求邮件列表
function NetMsgHandler.SendRequestEmails(mailID)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushUInt32(mailID)
    -- 客户端最大的邮件id
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_ADD_EMAILS, message, false);
end

function NetMsgHandler.HandleReceiveEmail(message)
    local number = message:PopUInt16()
    if EmailMgr:GetMailList() == nil then
        -- 如果邮件管理器的邮件table为nil，初始化为{}
        EmailMgr:InitList()
    end

    if number > 0 then
        for index = 1, number, 1 do
            local emailID = message:PopUInt32()
            local emailType = message:PopByte()
            local title = message:PopString()
            local content = message:PopString()
            local senderID = message:PopUInt32()
            local senderName = message:PopString()
            local date = message:PopUInt32()
            local nGold = message:PopUInt64()
            local bIsRead = message:PopByte()
            local hasAttachment = message:PopByte()
            local gold = GameConfig.GetFormatColdNumber(nGold)
            -- 添加到邮件管理器 nMailID, nSendType, sTitle, sContent, nSenderID, sSenderName, sSendDate, nGold, nRoomCard, bIsRead
            EmailMgr:AddMail(emailID, emailType, title, content, senderID, senderName, date, gold, bIsRead, hasAttachment)
        end

        print("-----------收到邮件，数量为"..number)
        EmailMgr:SortMail()

        local customerUI = CS.WindowManager.Instance:FindWindowNodeByName("CustomerServiceUI")
        if customerUI == nil then
            print("收到邮件")
            GameData.MailRed = 1
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMailNew)
        end
        -- 刷新一下邮件ID排列
        --EmailMgr:RefreshSortMailIDList()
        -- 刷新一下未读邮件数
        --EmailMgr:RefreshUnreadMailCount()
    else
        --local isRead
        --local hasAttachment
        --for index = 1, 20, 1 do
        --    if index % 2 == 0 then
        --        isRead = 1
        --        hasAttachment = 0
        --    else
        --        isRead = 0
        --        hasAttachment = 1
        --    end
        --    EmailMgr:AddMail(index, index, "title"..index, "content"..index,
        --            index, "senderName"..index, index, index, isRead, hasAttachment)
        --end
    end

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateEmailInfo)

    -- 如果当前正在显示邮件界面，刷新邮件列表
    --local emailUI = CS.WindowManager.Instance:FindWindowNodeByName("UIEmail")
    --if emailUI ~= nil then
    --    emailUI.WindowData = 1
    --end
end

---------------------------------------------------------------------------
-----------------CS_DELETE_EMAIL  508--------------------------------------
function NetMsgHandler.SendDeleteEmail(emailID)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushUInt32(emailID)
    -- 邮件id
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_DELETE_EMAIL, message, true);
end

function NetMsgHandler.HandleDeleteEmail(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()
    if result == 0 or 2 then
        CS.BubblePrompt.Show("删除成功", "UIEmail")
        -- 邮件管理器删除邮件
        local mailID = message:PopUInt32()
        EmailMgr:DelMail(mailID)

    elseif result == 1 then
        CS.BubblePrompt.Show("删除失败,账号不存在", "UIEmail")
    end
end

---------------------------------------------------------------------------
-----------------CS_MODIFY_NAME  509---------------------------------------
function NetMsgHandler.SendModifyName(newName)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushString(newName)
    -- 新昵称
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MODIFY_NAME, message, true);
end

function NetMsgHandler.HandleModifyName(message)
    CS.LoadingDataUI.Hide();
    local resultType = message:PopByte()
    if resultType == 0 then
        GameData.RoleInfo.AccountName = message:PopString()
    end

    CS.BubblePrompt.Show(data.GetString('Change_Name_Error_' .. resultType), "PersonalUI")

    local masterInfoUI = CS.WindowManager.Instance:FindWindowNodeByName("PersonalUI")
    if masterInfoUI ~= nil then
        masterInfoUI.WindowData = 1
    end
 

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyChangeAccountName, nil)
end

---------------------------------------------------------------------------
-----------------CS_ALL_RANK  510------------------------------------------
function NetMsgHandler.SendRequestRanks(nType)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushByte(nType)
    -- 排行榜类型(1,财富榜，2充值榜，3日赚榜 4提现榜 5龙虎厅收益榜   6金花收益榜  7牛牛收益榜  8推筒子收益榜  9红包收益榜 10龙虎斗收益榜 11百家乐收益榜 12时时彩收益榜 13奔驰宝马收益榜 14跑得快收益榜 21代理提取佣金日榜 22代理提取佣金周榜 23代理提取佣金月榜)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_ALL_RANK, message, true);
end


function NetMsgHandler.HandleAllRankInfo(message)
    CS.LoadingDataUI.Hide();
    local nType = message:PopByte()
    if nType >= 1 then
        local count = message:PopUInt16()
        local richList = { }
        for index = 1, count, 1 do
            local rankItem = { }
            rankItem.RankID = index
            rankItem.HeadIcon = message:PopByte()
            rankItem.AccountName = message:PopString()
            rankItem.RichValue = message:PopInt64()
            rankItem.AccountID = message:PopUInt32()
            rankItem.VipLevel = message:PopByte()
            if nType == 1 and rankItem.VipLevel >= 9 then
                rankItem.wechat = message:PopString();
                rankItem.qq = message:PopString();
            end
            richList[index] = rankItem
        end
        if nType == 1 then
            GameData.RankInfo.CaiFuRank = {}
            GameData.RankInfo.CaiFuRank = richList
            GameData.RankInfo.CaiFuRankTime = os.time()
        elseif nType == 2 then
            GameData.RankInfo.ChongZhiRank = {}
            GameData.RankInfo.ChongZhiRank = richList
            GameData.RankInfo.ChongZhiRankTime = os.time()
        elseif nType == 3 then
            GameData.RankInfo.RiZhuanRank = {}
            GameData.RankInfo.RiZhuanRank = richList
            GameData.RankInfo.RiZhuanRankTime = os.time()
        elseif nType == 4 then
            GameData.RankInfo.TiXianRank = {}
            GameData.RankInfo.TiXianRank = richList
            GameData.RankInfo.TiXianRankTime = os.time()
        elseif nType == 5 then
            GameData.RankInfo.LhtRank = {}
            GameData.RankInfo.LhtRank = richList
            GameData.RankInfo.LhtRankTime = os.time()
        elseif nType == 6 then
            GameData.RankInfo.JhRank = {}
            GameData.RankInfo.JhRank = richList
            GameData.RankInfo.JhRankTime = os.time()
        elseif nType == 7 then
            GameData.RankInfo.NnRank = {}
            GameData.RankInfo.NnRank = richList
            GameData.RankInfo.NnRankTime = os.time()
        elseif nType == 8 then
            GameData.RankInfo.TtzRank = {}
            GameData.RankInfo.TtzRank = richList
            GameData.RankInfo.TtzRankTime = os.time()
        elseif nType == 9 then
            GameData.RankInfo.HbRank = {}
            GameData.RankInfo.HbRank = richList
            GameData.RankInfo.HbRankTime = os.time()
        elseif nType == 10 then
            GameData.RankInfo.LhdRank = {}
            GameData.RankInfo.LhdRank = richList
            GameData.RankInfo.LhdRankTime = os.time()
        elseif nType == 11 then
            GameData.RankInfo.BjlRank = {}
            GameData.RankInfo.BjlRank = richList
            GameData.RankInfo.BjlRankTime = os.time()
        elseif nType == 12 then
            GameData.RankInfo.SscRank = {}
            GameData.RankInfo.SscRank = richList
            GameData.RankInfo.SscRankTime = os.time()
        elseif nType == 13 then
            GameData.RankInfo.BcbmRank = {}
            GameData.RankInfo.BcbmRank = richList
            GameData.RankInfo.BcbmRankTime = os.time()
        elseif nType == 14 then
            GameData.RankInfo.PdkRank = {}
            GameData.RankInfo.PdkRank = richList
            GameData.RankInfo.PdkRankTime = os.time()
        elseif nType == 21 then
            GameData.RankInfo.DaiLiRiBang = {}
            GameData.RankInfo.DaiLiRiBang = richList
            GameData.RankInfo.DaiLiRiBangTime = os.time()
        elseif nType == 22 then
            GameData.RankInfo.DaiLiZhouBang = {}
            GameData.RankInfo.DaiLiZhouBang = richList
            GameData.RankInfo.DaiLiZhouBangTime = os.time()
        elseif nType == 23 then
            GameData.RankInfo.DaiLiYueBang = {}
            GameData.RankInfo.DaiLiYueBang = richList
            GameData.RankInfo.DaiLiYueBangTime = os.time()
        end
        GameData.RankInfo.RichList = richList
        GameData.RankInfo.DayOfYear = lua_GetTimeToYearDay()
        -- 如果排行榜界面还是打开的，刷新界面
        local rankUI = nil
        if nType <= 3 then
            rankUI = CS.WindowManager.Instance:FindWindowNodeByName("UIRank")
        elseif nType >= 5 and nType<21 then
            if nType == 14 then
                rankUI = CS.WindowManager.Instance:FindWindowNodeByName("PDKRank")
            else
                rankUI = CS.WindowManager.Instance:FindWindowNodeByName("UIRoomRank")
            end
            
        elseif nType>21 then
        
        end
        if rankUI ~= nil then
            if nType<21 then
                rankUI.WindowData = nType
            end
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyRankEvent,nType)
    end
end

---------------------------------------------------------------------------
-----------------CS_PAOPAO_CHAT  512---------------------------------------
function NetMsgHandler.SendChatPaoPao(position,roomType,senderEnum, sendIndex,roleType)
    -- print('发送聊天泡泡senderEnum = '..senderEnum..' chatEnum = '..chatEnum)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushByte(position)
    message:PushByte(roomType)
    message:PushByte(senderEnum)
    message:PushByte(sendIndex)
    message:PushByte(roleType)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PAOPAO_CHAT, message, false)
end

function NetMsgHandler.HandleChatPaoPao(message)
    local position =message:PopByte()
    local roomType = message:PopByte()
    local senderEnum = message:PopByte()
    local sendIndex = message:PopByte()
    local roleType = message:PopByte()

    if roomType == ROOM_TYPE.HongBao or roomType == ROOM_TYPE.PPHongBao then
        position = GameData.PlayerPositionConvert8ShowPosition(position)
    elseif roomType == ROOM_TYPE.ZuJuNN or roomType == ROOM_TYPE.PiPeiNN then
        position = NNRoomPositionConvert(position)
    elseif roomType == ROOM_TYPE.MenJi or roomType == ROOM_TYPE.ZuJu then
        position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
    elseif roomType == ROOM_TYPE.ZuJuTTZ or roomType == ROOM_TYPE.PiPeiTTZ then
        position = TTZGameMgr.TTZRoomPositionConvert(position)
    elseif roomType == ROOM_TYPE.ZuJuMaJiang then
        position = MJGameMgr.MJRoomPositionConvert(position)
    elseif roomType == ROOM_TYPE.PiPeiPDK then
        position = PDKRoomPositionConvert(position)
    end
    local eventArg = { position = position, roomType = roomType, senderEnum = senderEnum, sendIndex = sendIndex,roleType = roleType }
    -- 通知界面显示
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyChatPaoPao, eventArg)
end

---------------------------------------------------------------------------
-----------------CS_Request_Game_History  513------------------------------
function NetMsgHandler.Send_CS_Request_Game_History(startNum, requestCount)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家账号
    message:PushUInt16(startNum)
    message:PushUInt16(requestCount)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Request_Game_History, message, true)
end

function NetMsgHandler.Received_CS_Request_Game_History(message)
    CS.LoadingDataUI.Hide()
    -- 如果历史记录界面已关闭，则不需要再解析数据
    local gameHistoryUI = CS.WindowManager.Instance:FindWindowNodeByName("UIGameHistory")
    if gameHistoryUI ~= nil then
        local maxCount = message:PopUInt16()
        if maxCount > 0 then
            local count = message:PopUInt16()
            for index = 1, count, 1 do
                local historyData = { }
                historyData.Time = message:PopUInt32()
                historyData.RoomID = message:PopUInt32()
                historyData.Pokers = { }
                -- 解析扑克牌
                for i = 1, 6, 1 do
                    historyData.Pokers[i] = { }
                    historyData.Pokers[i].PokerType = message:PopByte()
                    historyData.Pokers[i].PokerNumber = message:PopByte()
                end
                -- 游戏结果
                historyData.GameResult = message:PopUInt32()
                -- 解析押注信息
                historyData.BetValues = { }
                local betAreaCount = message:PopUInt16()
                for j = 1, betAreaCount, 1 do
                    local betArea = message:PopByte()
                    local betValue = message:PopUInt64()
                    historyData.BetValues[betArea] = betValue
                end
                -- 解析金币相关内容
                historyData.BeforeGoldCount = message:PopInt64()
                historyData.ChangeGoldCount = message:PopInt64()
                historyData.LaterGoldCount = message:PopInt64()
                historyData.PayAll = message:PopByte()
                table.insert(GameData.GameHistory.Datas, historyData)
            end
        end
        GameData.GameHistory.MaxCount = maxCount
        gameHistoryUI.WindowData = nil
    end
end

---------------------------------------------------------------------------
-----------------CS_Invite_Code  601---------------------------------------
function NetMsgHandler.Send_CS_Invite_Code(inviteCode)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(inviteCode)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Invite_Code, message, true)
end

function NetMsgHandler.Received_CS_Invite_Code(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        GameData.RoleInfo.InviteCode = message:PopUInt32()
    else
        CS.BubblePrompt.Show(data.GetString("Invite_Code_Error_" .. resultType), "UISetting")
    end
end

---------------------------------------------------------------------------
-----------------S_Update_Promoter  602[废弃]------------------------------------
function NetMsgHandler.Receivde_S_Update_Pomoter(message)

end

-------------------------------------------------------------------------------
---------------------------CS_SALESMAN_INFO  603[废弃]------------------------------------

function NetMsgHandler.Receive_CS_SALESMAN_INFO()
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_SALESMAN_INFO, message, true)
end

function NetMsgHandler.Received_CS_SALESMAN_INFO(message)

end

--  ==============================请求时时彩信息 830 ==================================  --
function NetMsgHandler.ProcessingLottery()
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_ShiShiCaiInRoom,message,false)
end


-- ===============================进入时时彩房间时反馈信息 830 =============================
function NetMsgHandler.Receive_CS_ShiShiCaiInRoom(message)

    local resultType = message:PopByte();
    --0:成功_1:账号不存在_2:金币不足_3:金币超出上限_4:已在其他房间内_5:金币超过玩家携带警戒值
    if resultType == 0 then
        --CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
        GameData.RoomInfo.CurrentRoom.RoomID = 1
        GameData.LotteryInfo.GoldPool = message:PopInt64()         -- 奖金池数量
        if GameData.LotteryInfo.GoldPool/10000>999999999.99 then
            GameData.LotteryInfo.GoldPool=999999999.99*10000
        end
        GameData.LotteryInfo.NowState = message:PopByte()          -- 当前状态
        --房间内玩家数量
        GameData.LotteryInfo.PlayerCount = message:PopUInt16();
        GameData.LotteryInfo.CountDown = message:PopUInt32()       -- 倒计时
        if GameData.LotteryInfo.NowState == 1 then
            GameData.LotteryInfo.Victory_Card_Type=message:PopByte()
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyOpenCard)
        end
        local pokerNumber = message:PopByte()       -- 牌数量
        GameData.LotteryInfo.PokersNum=pokerNumber
        for index =1,pokerNumber do
            local pokerType = message:PopByte()                  -- 牌花色
            local pokerNumber = message:PopByte()                -- 牌大小
            GameData.LotteryInfo.PokerColor[index] = pokerType
            GameData.LotteryInfo.PokerSize[index] = pokerNumber
        end
        GameData.LotteryInfo.LastBaoziTime = message:PopUInt32()   -- 上一次豹子距离现在时间
        GameData.LotteryInfo.WinnerID = message:PopUInt32()       -- 上次赢家ID
        GameData.LotteryInfo.WinnerName = message:PopString()     -- 上次赢家名字
        GameData.LotteryInfo.Winner_Gold = message:PopInt64()      -- 上次赢家获利数
        GameData.LotteryInfo.WinnerVipLevel = message:PopByte()      -- 上次赢家VIP等级
        GameData.LotteryInfo.WinnerStrLoginIP = message:PopString()   -- 上次赢家地址
        -- 本轮押注信息
        for i=1,6 do
            GameData.LotteryInfo.Bet[i]=message:PopInt64()
        end
        -- 玩家本身押注信息
        for i=1,6 do
            GameData.LotteryInfo.myBet[i]=message:PopInt64()
        end

        -- 近30轮开牌记录
        local CS_History_Count=message:PopUInt16()
        GameData.LotteryInfo.OpenCardNum=CS_History_Count
        for index=1,CS_History_Count do
            GameData.LotteryInfo.OpenCardHistory[index]=message:PopByte()
        end
        -- 标志
        -- local BiaoZhi = message:PopByte()
        -- if BiaoZhi == 1 then
        --     GameData.SscWinnInfo={}
        --     local WinnCount = message:PopUInt16()
        --     for Index = 1, WinnCount, 1 do
        --         local WinnName = message:PopString()
        --         local WinnGold = message:PopInt64()
        --         local strLoginIP = message:PopString()
        --         WinnGold=lua_CommaSeperate(GameConfig.GetFormatColdNumber(WinnGold))
        --         table.insert( GameData.SscWinnInfo,{PlayerName=WinnName,PlayerGold=WinnGold,StrLoginIP=strLoginIP} )
        --     end
        -- end
        local shishicai= CS.WindowManager.Instance:FindWindowNodeByName("TimeTimeColor")
        if shishicai == nil then
            CS.WindowManager.Instance:OpenWindow("TimeTimeColor")
        else
            shishicai.WindowGameObject:SetActive(true)
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState)
            CS.MatchLoadingUI.Hide()
        end

        --local TimeTimeColor = CS.WindowManager.Instance:FindWindowNodeByName("TimeTimeColor")
        --if TimeTimeColor == nil then
        --    CS.WindowManager.Instance:OpenWindow("TimeTimeColor")
        --    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState)
        --else
        --    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState)
        --end
    else
        NetMsgHandler.ExitRoomToHall(0)
        CS.MatchLoadingUI.Hide()

        if resultType == 3 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType == 2 then
                local  GoldValue = message:PopInt64()
                GoldValue=GameConfig.GetFormatColdNumber(GoldValue)
                local boxData = CS.MessageBoxData()
                boxData.Title = "温馨提示"
                boxData.Content = string.format(data.GetString("Processing_CarInfo_2"),lua_CommaSeperate(GoldValue))
                boxData.Style = 1
                boxData.OKButtonName = "确定"
                boxData.LuaCallBack = NetMsgHandler.GoldNotEnoughConfirmOnClick
                CS.MessageBoxUI.Show(boxData)
            else
                if resultType == 4 then
                    local GoldValue = message:PopInt64()
                    CS.BubblePrompt.Show(data.GetString("ProcessingLottery_"..resultType    ),"TimeTimeColor")
                elseif resultType == 5 then
                    CS.BubblePrompt.Show(data.GetString("ProcessingLottery_"..resultType    ),"TimeTimeColor")
                else
                    CS.BubblePrompt.Show(data.GetString("ProcessingLottery_"..resultType    ),"TimeTimeColor")
                end

            end
        end
    end
end

--  =================================================================================  --


function NetMsgHandler.Accept_CS_ProcessingLottery(message)

    local resultType = message:PopByte()
    if resultType == 0 then
        GameData.RoomInfo.CurrentRoom.RoomID = 1
        -- GameData.LotteryInfo.GoldPool = message:PopInt64()         -- 奖金池数量
        -- if GameData.LotteryInfo.GoldPool/10000>999999999.99 then
        --     GameData.LotteryInfo.GoldPool=999999999.99*10000
        -- end
        GameData.LotteryInfo.NowState = message:PopByte()          -- 当前状态
        --房间玩家信息
        GameData.LotteryInfo.PlayerCount = message:PopUInt16();
        GameData.LotteryInfo.CountDown = message:PopUInt32()       -- 倒计时
        if GameData.LotteryInfo.NowState == 1 then
            GameData.LotteryInfo.Victory_Card_Type=message:PopByte()
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyOpenCard)
        end
        if GameData.LotteryInfo.NowState == 1 then
            GameData.LotteryInfo.LastBaoziTime = message:PopUInt32()   -- 上一次豹子距离现在时间
            GameData.LotteryInfo.WinnerID = message:PopUInt32()       -- 上次赢家ID
            GameData.LotteryInfo.WinnerName = message:PopString()     -- 上次赢家名字
            GameData.LotteryInfo.Winner_Gold = message:PopInt64()      -- 上次赢家获利数
            GameData.LotteryInfo.WinnerVipLevel = message:PopByte()      -- 上次赢家VIP等级
            GameData.LotteryInfo.WinnerStrLoginIP = message:PopString()   -- 上次赢家地址
            GameData.LotteryInfo.GoldPool = message:PopInt64()         -- 奖金池数量
            if GameData.LotteryInfo.GoldPool/10000>999999999.99 then
                GameData.LotteryInfo.GoldPool=999999999.99*10000
            end
            local pokerNumber = message:PopByte()       -- 牌数量
            GameData.LotteryInfo.PokersNum=pokerNumber
            for index =1,pokerNumber do
                local pokerType = message:PopByte()                  -- 牌花色
                local pokerNumber = message:PopByte()                -- 牌大小
                GameData.LotteryInfo.PokerColor[index] = pokerType
                GameData.LotteryInfo.PokerSize[index] = pokerNumber
            end
            local CS_History_Count=message:PopUInt16()
            GameData.LotteryInfo.OpenCardNum=CS_History_Count
            for index=1,CS_History_Count do
                GameData.LotteryInfo.OpenCardHistory[index]=message:PopByte()
            end
        end
        -- local pokerNumber = message:PopByte()       -- 牌数量
        -- GameData.LotteryInfo.PokersNum=pokerNumber
        -- for index =1,pokerNumber do
        --     local pokerType = message:PopByte()                  -- 牌花色
        --     local pokerNumber = message:PopByte()                -- 牌大小
        --     GameData.LotteryInfo.PokerColor[index] = pokerType
        --     GameData.LotteryInfo.PokerSize[index] = pokerNumber
        -- end
        -- GameData.LotteryInfo.LastBaoziTime = message:PopUInt32()   -- 上一次豹子距离现在时间
        -- GameData.LotteryInfo.WinnerID = message:PopUInt32()       -- 上次赢家ID
        -- GameData.LotteryInfo.WinnerName = message:PopString()     -- 上次赢家名字
        -- GameData.LotteryInfo.Winner_Gold = message:PopInt64()      -- 上次赢家获利数
        -- GameData.LotteryInfo.WinnerVipLevel = message:PopByte()      -- 上次赢家VIP等级
        -- GameData.LotteryInfo.WinnerStrLoginIP = message:PopString()   -- 上次赢家地址
        -- 本轮押注信息
        -- for i=1,6 do
        --     GameData.LotteryInfo.Bet[i]=message:PopInt64()
        -- end
        -- 玩家本身押注信息
        -- for i=1,6 do
        --     GameData.LotteryInfo.myBet[i]=message:PopInt64()
        -- end

        -- 近30轮开牌记录
        -- local CS_History_Count=message:PopUInt16()
        -- GameData.LotteryInfo.OpenCardNum=CS_History_Count
        -- for index=1,CS_History_Count do
        --     GameData.LotteryInfo.OpenCardHistory[index]=message:PopByte()
        -- end
        -- 标志
        -- local BiaoZhi = message:PopByte()
        -- if BiaoZhi == 1 then
        --     GameData.SscWinnInfo={}
        --     local WinnCount = message:PopUInt16()
        --     for Index = 1, WinnCount, 1 do
        --         local WinnName = message:PopString()
        --         local WinnGold = message:PopInt64()
        --         local strLoginIP = message:PopString()
        --         WinnGold=lua_CommaSeperate(GameConfig.GetFormatColdNumber(WinnGold))
        --         table.insert( GameData.SscWinnInfo,{PlayerName=WinnName,PlayerGold=WinnGold,StrLoginIP=strLoginIP} )
        --     end
        -- end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptLotteryInfo)

    else
        NetMsgHandler.ExitRoomToHall(0)
        CS.MatchLoadingUI.Hide()

        if resultType == 3 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType == 2 then
                local  GoldValue = message:PopInt64()
                GoldValue=GameConfig.GetFormatColdNumber(GoldValue)
                local boxData = CS.MessageBoxData()
                boxData.Title = "温馨提示"
                boxData.Content = string.format(data.GetString("Processing_CarInfo_2"),lua_CommaSeperate(GoldValue))
                boxData.Style = 1
                boxData.OKButtonName = "确定"
                boxData.LuaCallBack = NetMsgHandler.GoldNotEnoughConfirmOnClick
                CS.MessageBoxUI.Show(boxData)
            else
                if resultType == 4 then
                    local GoldValue = message:PopInt64()
                    CS.BubblePrompt.Show(data.GetString("ProcessingLottery_"..resultType    ),"TimeTimeColor")
                elseif resultType == 5 then
                    CS.BubblePrompt.Show(data.GetString("ProcessingLottery_"..resultType    ),"TimeTimeColor")
                else
                    CS.BubblePrompt.Show(data.GetString("ProcessingLottery_"..resultType    ),"TimeTimeColor")
                end

            end
        end
    end
end

--  ==============================玩家请求时时彩下注 832 ================================  --
function NetMsgHandler.LotteryForBet()
    local message =CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(GameData.LotteryInfo.Bet_Button_Type)
    message:PushInt64(GameData.LotteryInfo.MyBet_Gold)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Lottery_Bet,message,false)
end

--  =============================服务器反馈时时彩下注 832 ================================  --
function NetMsgHandler.Accept_CS_LotteryForBet(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        GameData.LotteryInfo.Bet_Button_Type = message:PopByte()
        local Account = message:PopUInt32()
        local MyBet_Gold = message:PopInt64()
        if Account == GameData.RoleInfo.AccountID then
            GameData.LotteryInfo.myBet[GameData.LotteryInfo.Bet_Button_Type] = MyBet_Gold
        end
        local Bet_Gold = message:PopInt64()
        GameData.LotteryInfo.Bet[GameData.LotteryInfo.Bet_Button_Type]=Bet_Gold
        GameData.LotteryInfo.GoldPool = message:PopInt64()
        -- 调整为不在校验时间
        local tCountDown  = message:PopUInt32()       -- 倒计时
        -- GameData.LotteryInfo.CountDown 
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.SendTheMessageToBeSuccessful)

    else
        if resultType == 5 or resultType == 6 or resultType == 7 then
            local  GoldValue = message:PopInt64()
            GoldValue=GameConfig.GetFormatColdNumber(GoldValue)
            if resultType == 6 then
                GoldValue = lua_NumberToStyle1String(GoldValue);
            end
            CS.BubblePrompt.Show(string.format(data.GetString("Bets_Fail_"..resultType),GoldValue),"TimeTimeColor")
        else
            CS.BubblePrompt.Show(data.GetString("Bets_Fail_"..resultType),"TimeTimeColor")
        end
        
    end
end

--  =============================服务器发送玩家下注胜利消息 833 ==========================  --
function NetMsgHandler.Accept_S_BetVictory(message)
    local resultType = message:PopByte()
    GameData.LotteryInfo.Victory_Card_Type=resultType
    GameData.LotteryInfo.Bet_Victory_Gold=message:PopInt64()
    GameData.LotteryInfo.is_Bet_Victory=1
    if GameData.LotteryInfo.ssc_isOpen == 0 then
        local BetWinner_Gold = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.LotteryInfo.Bet_Victory_Gold))
        local CardType=data.ShishicaiConfig.HISTORY_TYPE[GameData.LotteryInfo.Victory_Card_Type]
        CS.BubblePrompt.Show(string.format(data.GetString("SSC_Bet_Info"),CardType,BetWinner_Gold),"TimeTimeColor")
    end
end

--  ============================= 退出时时彩界面 834 =================================  --
function NetMsgHandler.QuitLottery()
    CS.LoadingDataUI.Show();
    local  message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.C_QuitLottery,message,false)
end

function NetMsgHandler.Send_CS_QuitLottery(message)
    CS.LoadingDataUI.Hide();
    local resultType = message:PopByte()
    if resultType == 0 then
        --local tempWindow = CS.WindowManager.Instance:FindWindowNodeByName("DZHallUI");
        --if tempWindow ~= nil then
        --    GameObjectSetActive(tempWindow.WindowGameObject, true);
        --else
        --    tempWindow = CS.WindowNodeInitParam("DZHallUI");
        --    tempWindow.NodeType = 0
        --    CS.WindowManager.Instance:OpenWindow(tempWindow);
        --end
        NetMsgHandler.ExitRoomToHall(0)
    end
end
--  ============================== 时时彩请求房间玩家列表 836 ============================  --
function NetMsgHandler.Send_CS_SSC_Request_Role_List()
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID);
    message:PushByte(GameData.RoleInfo.Level);
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_SSCRoomPlayerList, message, true)
end

function NetMsgHandler.Received_CS_SSC_Request_Role_List(message)
    CS.LoadingDataUI.Hide();
    local resultType = message:PopByte()
    if resultType == 0 then
        local count = message:PopUInt16()
        local playerList = { }
        for index = 1, count, 1 do
            local player = { }
            --账号
            player.AccountID = message:PopUInt32()
            --定位
            player.strLoginIP = message:PopString()
            --金币
            player.GoldCount = message:PopInt64()
            --头像ID
            player.HeadIcon = message:PopByte()
            playerList[index] = player
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateRoomPlayerList, playerList)
    else
        CS.BubblePrompt.Show(data.GetString("Role_List_Error" .. resultType), "GameUI2")
    end
end
--  ================================================================================== --
--  ============================请求奔驰宝马界面庄家列表信息 837 ======================== -- 
function NetMsgHandler.Send_CS_BankerListInfo(level)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(level)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_CarPrizeDraw_BankerListInfo,message,false)
end

--  =============================反馈奔驰宝马界面庄家列表信息 837 ======================== -- 
function NetMsgHandler.Received_CS_BankerListInfo(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local num = message:PopByte()
        GameData.CarInfo.BankerNumber = num
        GameData.CarInfo.BankerListVIP = {};
        GameData.CarInfo.BankersName = {};
        GameData.CarInfo.BankersGold = {};
        GameData.CarInfo.BankersStrLoginIP = {};
        for index=1,num do
            GameData.CarInfo.BankerListVIP[index]=message:PopByte()
            GameData.CarInfo.BankersName[index]=message:PopString()
            GameData.CarInfo.BankersGold[index]=message:PopInt64()
            GameData.CarInfo.BankersStrLoginIP[index]=message:PopString()
        end
        GameData.CarInfo.BankerRemainder=message:PopUInt32()
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptCarBankerListInfo)
    end
end


--  ============================= 退出奔驰宝马界面 838 =================================  --
function NetMsgHandler.QuitCar(level)
    CS.LoadingDataUI.Show();
    local  message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(level)
    NetMsgHandler.SendMessageToGame(ProtrocolID.C_CarPrizeDraw_Quit,message,false)
end

function NetMsgHandler.Received_CS_QuitCar(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        NetMsgHandler.ExitRoomToHall(0)
    end
    CS.LoadingDataUI.Hide();
end

-- ===========================奔驰宝马请求玩家列表 840 ===============================  --
function NetMsgHandler.Send_CS_BCBM_Request_Role_List()
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(GameData.CarInfo.Level);
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BCBMRoomPlayerList, message, true)
end

function NetMsgHandler.Received_CS_BCBM_Request_Role_List(message)
    CS.LoadingDataUI.Hide();
    local resultType = message:PopByte()
    if resultType == 0 then
        local count = message:PopUInt16()
        local playerList = { }
        for index = 1, count, 1 do
            local player = { }
            --账号
            player.AccountID = message:PopUInt32()
            --定位
            player.strLoginIP = message:PopString()
            --金币
            player.GoldCount = message:PopInt64()
            --头像ID
            player.HeadIcon = message:PopByte()
            playerList[index] = player
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateRoomPlayerList, playerList)
    else
        CS.BubblePrompt.Show(data.GetString("Role_List_Error" .. resultType), "GameUI2")
    end
end

-- ===========================请求奔驰宝马信息 842 ===================================  --
function NetMsgHandler.Send_CS_CarInfo(level)
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(level%10)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_CarInfoInRoom,message,false)
end

---TUDOU
-- ===========================进入奔驰宝马时请求信息 842 =============================

function NetMsgHandler.Receive_CS_CarInfoInRoom(message)
    
    local resultType = message:PopByte();
    --0:成功_1:账号不存在_2:金币不足_3:金币超出上限_4:已在其他房间内_5:金币超过玩家携带警戒值
    if resultType == 0 then
        --CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
        GameData.CarInfo.Level=message:PopByte()
        GameData.RoomInfo.CurrentRoom.RoomID = GameData.CarInfo.Level
        --上轮的结果
        GameData.CarInfo.LastLotteryTarget = message:PopByte();
        GameData.CarInfo.PlayerCount = message:PopUInt16();
        -- 当前状态
        GameData.CarInfo.NowState=message:PopByte()
        -- 各阶段剩余时间
        GameData.CarInfo.ResidualTimeOfEachStage = message:PopUInt32()
        
        -- 如果当前状态为 3 或 4
        if GameData.CarInfo.NowState == 3 or GameData.CarInfo.NowState == 4 then
            -- 命中目标
            GameData.CarInfo.LotteryTarget=message:PopByte()
        end
        -- 上次法拉利距离现在时间
        GameData.CarInfo.LastFerrariTime=message:PopUInt32()
        -- 上次兰博基尼距离现在时间
        GameData.CarInfo.LastLamborghiniTime=message:PopUInt32()
        -- 庄家上庄最低金额
        GameData.CarInfo.UpperBankersGold = message:PopInt64()
        --GameData.CarInfo.UpperBankersGold = GameConfig.GetFormatColdNumber(GameData.CarInfo.UpperBankersGold)
        -- 筹码1值
        GameData.CarInfo.ChipsValue[1] = message:PopInt64()
        --GameData.CarInfo.ChipsValue[1] = GameConfig.GetFormatColdNumber(GameData.CarInfo.ChipsValue[1])
        -- 筹码2值
        GameData.CarInfo.ChipsValue[2] = message:PopInt64()
        --GameData.CarInfo.ChipsValue[2] = GameConfig.GetFormatColdNumber(GameData.CarInfo.ChipsValue[2])
        -- 筹码3值
        GameData.CarInfo.ChipsValue[3] = message:PopInt64()
        --GameData.CarInfo.ChipsValue[3] = GameConfig.GetFormatColdNumber(GameData.CarInfo.ChipsValue[2])
        -- 筹码4值
        GameData.CarInfo.ChipsValue[4] = message:PopInt64()
        --GameData.CarInfo.ChipsValue[4] = GameConfig.GetFormatColdNumber(GameData.CarInfo.ChipsValue[4])
        -- 庄家信息
        GameData.CarInfo.BankerID=message:PopUInt32()       -- 庄家头像ID
        GameData.CarInfo.BankerName=message:PopString()     -- 庄家名字
        GameData.CarInfo.BankerGold=message:PopInt64()      -- 庄家金币
        GameData.CarInfo.BankerVipLevel=message:PopByte()    -- 庄家等级
        GameData.CarInfo.BankerAccountID=message:PopUInt32() -- 庄家账号ID
        GameData.CarInfo.BankerStrLoginIP = message:PopString() -- 庄家地址
        if GameData.RoleInfo.AccountID ~= GameData.CarInfo.BankerAccountID then
            GameData.CarInfo.isBanker=0
        else
            GameData.CarInfo.isBanker=1
        end
        -- 上轮赢家信息
        GameData.CarInfo.WinnerID=message:PopUInt32()       -- 上轮赢家头像ID
        GameData.CarInfo.WinnerName=message:PopString()     -- 上轮赢家名字
        GameData.CarInfo.WinnerGold=message:PopInt64()      -- 上轮赢家获得金币
        GameData.CarInfo.WinnerVipLevel=message:PopByte()   -- 上轮赢家等级
        GameData.CarInfo.WinnerStrLoginIP = message:PopString() -- 上轮赢家地址
        -- 所有玩家下注总金额
        GameData.CarInfo.AllBet = {};
        for index=1,8 do
            GameData.CarInfo.AllBet[index]=message:PopInt64()
        end
        -- 玩家下注金额
        GameData.CarInfo.myBet = {};
        for index =1,8 do
            GameData.CarInfo.myBet[index]=message:PopInt64()
            if GameData.CarInfo.myBet[index] > 0 then
                GameData.CarInfo.IsBet = true
            end
        end
       
        -- 历史抽奖次数
        local num=message:PopUInt16()
        GameData.CarInfo.LastBetNum=num
        -- 历史抽奖结果
        GameData.CarInfo.LastBetResult = {};
        for index=1,num do
            GameData.CarInfo.LastBetResult[index]=message:PopByte()
        end

        -- 标志
        local BiaoZhi = message:PopByte()
        if BiaoZhi == 1 then
            GameData.CarWinnInfo={}
            local WinnCount = message:PopUInt16()
            for Index = 1, WinnCount, 1 do
                local WinnName = message:PopString()
                local WinnGold = message:PopInt64()
                local strLoginIP = message:PopString()
                WinnGold=lua_CommaSeperate(GameConfig.GetFormatColdNumber(WinnGold))
                table.insert( GameData.CarWinnInfo,{PlayerName=WinnName,PlayerGold=WinnGold,StrLoginIP=strLoginIP} )
            end
        end

        local carRotation = CS.WindowManager.Instance:FindWindowNodeByName("CarRotationUI")
        if carRotation == nil then
            CS.WindowManager.Instance:OpenWindow("CarRotationUI")
            --CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptCarInfo)
        else
            CS.MatchLoadingUI.Hide()
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptCarInfo)
        end
        
        GameData.CarInfo.isNewOpen=1
    else
        CS.MatchLoadingUI.Hide();
        CS.WindowManager.Instance:CloseWindow("CarRotation", false);

        if resultType == 4 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType == 2 or resultType == 3 then
                local  GoldValue = message:PopInt64()
                GoldValue=GameConfig.GetFormatColdNumber(GoldValue)
                if resultType == 2 then
                    local boxData = CS.MessageBoxData()
                    boxData.Title = "温馨提示"
                    boxData.Content = string.format(data.GetString("Processing_CarInfo_2"),lua_CommaSeperate(GoldValue))
                    boxData.Style = 1
                    boxData.OKButtonName = "确定"
                    boxData.LuaCallBack = NetMsgHandler.GoldNotEnoughConfirmOnClick
                    CS.MessageBoxUI.Show(boxData)
                else
                    CS.BubblePrompt.Show(string.format(data.GetString("Processing_CarInfo_3"),math.ceil(GoldValue)),"HallUI")
                end
            else
                if resultType == 5 then
                    local GoldValue = message:PopInt64()
                    CS.BubblePrompt.Show(data.GetString("Processing_CarInfo_"..resultType),"HallUI")
                else
                    CS.BubblePrompt.Show(data.GetString("Processing_CarInfo_"..resultType),"HallUI")
                end
                
            end
        end
        NetMsgHandler.ExitRoomToHall(0)
        NetMsgHandler.QuitCar()

    end
end

--  ============================反馈奔驰宝马信息 843 ================================  --
function NetMsgHandler.Received_CS_CarInfo(message)
    local resultType = message:PopByte()
    --0 成功 1账号不存在 2 金币不足
    if resultType == 0 then
        --玩家数量
        GameData.CarInfo.PlayerCount = message:PopUInt16();
        -- 当前状态
        GameData.CarInfo.NowState=message:PopByte()
        -- 各阶段剩余时间
        GameData.CarInfo.ResidualTimeOfEachStage = message:PopUInt32()
        -- 如果当前状态为 3 或 4
        if GameData.CarInfo.NowState == BenChiBaoMa_State.XUANZHUAN or GameData.CarInfo.NowState == BenChiBaoMa_State.JIESUAN then
            -- 命中目标
            GameData.CarInfo.LotteryTarget=message:PopByte()
        end
        if GameData.CarInfo.NowState == BenChiBaoMa_State.BET then
            --上轮的结果
            GameData.CarInfo.LastLotteryTarget = message:PopByte();
            -- 上次法拉利距离现在时间
            GameData.CarInfo.LastFerrariTime = message:PopUInt32()
            -- 上次兰博基尼距离现在时间
            GameData.CarInfo.LastLamborghiniTime = message:PopUInt32()
        end

        if GameData.CarInfo.NowState == BenChiBaoMa_State.WAIT then
                    -- 庄家信息
            GameData.CarInfo.BankerID=message:PopUInt32()       -- 庄家头像ID
            GameData.CarInfo.BankerName=message:PopString()     -- 庄家名字
            GameData.CarInfo.BankerGold=message:PopInt64()      -- 庄家金币
            GameData.CarInfo.BankerVipLevel=message:PopByte()    -- 庄家等级
            GameData.CarInfo.BankerAccountID=message:PopUInt32() -- 庄家账号ID
            GameData.CarInfo.BankerStrLoginIP = message:PopString() -- 庄家地址
            if GameData.RoleInfo.AccountID ~= GameData.CarInfo.BankerAccountID then
                GameData.CarInfo.isBanker=0
            else
                GameData.CarInfo.isBanker=1
            end
            -- 上轮赢家信息
            GameData.CarInfo.WinnerID=message:PopUInt32()       -- 上轮赢家头像ID
            GameData.CarInfo.WinnerName=message:PopString()     -- 上轮赢家名字
            GameData.CarInfo.WinnerGold=message:PopInt64()      -- 上轮赢家获得金币
            GameData.CarInfo.WinnerVipLevel=message:PopByte()   -- 上轮赢家等级
            GameData.CarInfo.WinnerStrLoginIP = message:PopString() -- 上轮赢家地址
        end
        if GameData.CarInfo.NowState == BenChiBaoMa_State.JIESUAN then
                    -- 历史抽奖次数
            local num=message:PopUInt16()
            GameData.CarInfo.LastBetNum=num
            -- 历史抽奖结果
            GameData.CarInfo.LastBetResult = {};
            for index=1,num do
                GameData.CarInfo.LastBetResult[index]=message:PopByte()
            end
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyNextRoomState,true)
    else
        CS.WindowManager.Instance:CloseWindow("CarRotationUI",false)
    end
end


-- 金币不足提示按钮操作call
function NetMsgHandler.GoldNotEnoughConfirmOnClick( resultType )
    if resultType == 1 then
        GameData.Exit_MoneyNotEnough = true;
        GameConfig.OpenStoreUI()
    end
end


-- ============================== 奔驰宝马请求下注 844 ========================= --
function NetMsgHandler.Send_CS_Car_Bet(level)
    local message = CS.Net.PushMessage()

    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(GameData.CarInfo.BetType)
    message:PushInt64(GameData.CarInfo.myBetGold)
    message:PushByte(level)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_CarPrizeDraw_Bet,message,false)
end

-- ===============================反馈奔驰宝马下注信息 844 ======================  --
function NetMsgHandler.Received_CS_Car_Bet(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        GameData.CarInfo.BetType = message:PopByte()
        local Account = message:PopUInt32()
        --本人押注金额
        local myBet=message:PopInt64()
        --总押注金额
        local allBet=message:PopInt64()
        if Account == GameData.RoleInfo.AccountID then
            GameData.CarInfo.myBet[GameData.CarInfo.BetType]=myBet
            if myBet > 0 then
                GameData.CarInfo.IsBet = true
            end
        end
        GameData.CarInfo.AllBet[GameData.CarInfo.BetType]=allBet
        -- 各阶段剩余时间
        -- 调整不需要时间校验
        local CDTime = message:PopUInt32()
        -- GameData.CarInfo.ResidualTimeOfEachStage
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptCarBankerBetInfo,GameData.CarInfo.BetType)
    else
        if resultType == 9 or resultType == 5 or resultType == 6 then
           local GoldValue = message:PopInt64()
           GoldValue=GameConfig.GetFormatColdNumber(GoldValue)
            CS.BubblePrompt.Show(string.format(data.GetString("Processing_CarBet_"..resultType),lua_NumberToStyle1String(GoldValue) ) ,"CarRotationUI")
        else
            CS.BubblePrompt.Show(data.GetString("Processing_CarBet_"..resultType),"CarRotationUI")
        end
        
    end
end

--  ============================奔驰宝马请求上庄 845 =========================  --
function NetMsgHandler.Send_CS_Car_UpperDealer(level)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(level)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_CarPrizeDraw_DoBanker,message,false)
end

--  ===========================反馈奔驰宝马上庄 845 ==========================  --
function NetMsgHandler.Received_CS_Car_UpperDealer(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        CS.BubblePrompt.Show(data.GetString("UpperDealer_Fail_"..resultType),"CarRotationUI")
    else
        CS.BubblePrompt.Show(data.GetString("UpperDealer_Fail_"..resultType),"CarRotationUI")
    end
end

--  ===========================奔驰宝马请求下庄 846 ==========================  --
function NetMsgHandler.Send_CS_Car_LowerDealer(level)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(level)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_CarPrizeDraw_NotDoBanker,message,false)
end

--  ============================ 反馈奔驰宝马下庄 846 =========================  --
function NetMsgHandler.Received_CS_Car_LowerDealer(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        CS.BubblePrompt.Show(data.GetString("LowerDealer_Fail_"..resultType),"CarRotationUI")
    else
        CS.BubblePrompt.Show(data.GetString("LowerDealer_Fail_"..resultType),"CarRotationUI")
    end
end

-- ==========================反馈奔驰宝马押中得奖 847 ===========================  --
function NetMsgHandler.Received_CS_Car_BetWinner(message)
    --中奖坐标
    local BetWinner_Position = message:PopByte()
    --中奖类型
    local BetType=message:PopByte()
    --中奖金额
    local BetWinner_Gold = message:PopInt64()
    GameData.CarInfo.BetWinner_Gold=BetWinner_Gold
    --local Betname=GameData.CarNmae[BetType]
    local Betname=data.BenchibaomaConfig.LOGO_NAME[BetType]
    if GameData.CarInfo.isNewOpen == 0 then
        BetWinner_Gold = lua_CommaSeperate(GameConfig.GetFormatColdNumber(BetWinner_Gold))
        CS.BubblePrompt.Show(string.format(data.GetString("Car_Bet_Info"),Betname,BetWinner_Gold),"CarRotationUI")
    else
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptCarInterfacePlayerBetVictory)
    end
end

--  =========================反馈奔驰宝马庄家更换 848 ============================  --
function NetMsgHandler.Received_CS_Car_ReplaceDealer(message)
    GameData.CarInfo.BankerAccountID=message:PopUInt32()-- 庄家账号ID
    GameData.CarInfo.BankerID=message:PopUInt32()       -- 庄家头像ID
    GameData.CarInfo.BankerName=message:PopString()     -- 庄家名字
    GameData.CarInfo.BankerGold=message:PopInt64()      -- 庄家金币
    GameData.CarInfo.BankerVipLevel=message:PopByte()    -- 庄家等级
    GameData.CarInfo.BankerStrLoginIP = message:PopString() -- 庄家地址
    if GameData.CarInfo.BankerAccountID == GameData.RoleInfo.AccountID then
        GameData.CarInfo.isBanker=1
        CS.BubblePrompt.Show(data.GetString("GamePlayerIsBanker_1"),"CarRotation")
    else
        GameData.CarInfo.isBanker=0
        CS.BubblePrompt.Show(string.format(data.GetString("GamePlayerIsBanker_2"),GameData.CarInfo.BankerName),"CarRotationUI")
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptCarBankerInfo)
end

-- =======================反馈奔驰宝马庄家结算 849 ================================ -- 
function NetMsgHandler.Received_CS_Car_Dealer_Settlement(message)
    local resultType = message:PopByte()
    GameData.CarInfo.BankerSettlement_Gold=message:PopInt64()
    GameData.CarInfo.isBankerWinner=resultType
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptCarInterfaceBankerBetVictory)
end

-- =======================请求代理抽iPhone信息 436 ============================== --
function NetMsgHandler.Send_CS_iPhone_Info()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_IPHONE_INFO,message,true)
end

-- ======================反馈代理抽iPhone信息 436 ============================== -- 
function NetMsgHandler.Received_CS_iPhone_Info(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 当前状态
        local nowState= message:PopByte()
        GameData.iPoneLotteryInfo.NowState=nowState
        if nowState == 1 then
            -- 距离活动开始时间
            local startTime=message:PopUInt32()
            GameData.iPoneLotteryInfo.StartTime=startTime
        end
        -- 剩余抽奖次数
        local number=message:PopUInt32()
        GameData.iPoneLotteryInfo.LotteryNumberOfTimes=number
        local iphone= CS.WindowManager.Instance:FindWindowNodeByName("iphoneLuckDraw")
        if iphone == nil then
            CS.WindowManager.Instance:OpenWindow("iphoneLuckDraw")
        else
            iphone.WindowGameObject:SetActive(true)
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptIPHONE_Info)
        end
    else
        CS.BubblePrompt.Show(data.GetString("LowerDealer_Fail_1"),"iphoneLuckDraw")
    end
    CS.LoadingDataUI.Hide()
end

-- ======================客户端请求代理抽iphone抽奖 437 ========================= --
function NetMsgHandler.Send_CS_iPhone_LuckDraw()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_IPHONE_Reward,message,false)
end

-- ======================服务器反馈代理抽iphone抽奖 437 ======================== --
function NetMsgHandler.Received_CS_iPhone_LuckDraw(message)
    local resultType=message:PopByte()
    if resultType == 0 then
        -- 中奖目标
        local LotteryTarget=message:PopByte()
        GameData.iPoneLotteryInfo.LotteryTarget=LotteryTarget
        if GameData.iPoneLotteryInfo.NowState == 2 then
            --剩余抽奖次数
            local number= message:PopUInt16()
            GameData.iPoneLotteryInfo.LotteryNumberOfTimes=number
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptIPHONE_LotteryInfo)
    else
        CS.BubblePrompt.Show(data.GetString("iPhoneLuckDraw_"..resultType),"iphoneLuckDraw")
    end
end

--  =============================服务器反馈失败 880 ============================= --
function NetMsgHandler.Received_S_Task_Fail(message)
    GameData.ExchangeTelephoneFareInfo.TaskState=2
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptTaskInfo)
end
--  =============================服务器反馈任务信息  881   ======================= --
function NetMsgHandler.Received_S_Task_Info(message)
    --任务状态
    local state=message:PopByte()
    GameData.ExchangeTelephoneFareInfo.TaskState=state
    -- 任务进行中
    if state == 0 then
        --任务ID
        local TaskId=message:PopByte()
        GameData.ExchangeTelephoneFareInfo.TaskIndex=TaskId
        --任务倒计时
        local TaskCount=message:PopUInt32()
        GameData.ExchangeTelephoneFareInfo.TaskCountDown=TaskCount
        --当前任务已完成次数
        local TaskCompleteNumber=message:PopUInt16()
        GameData.ExchangeTelephoneFareInfo.TaskCompleteNumber=TaskCompleteNumber
        --当前任务完成所需总次数
        local TaskNeedNumber=message:PopUInt16()
        GameData.ExchangeTelephoneFareInfo.TaskNeedNumber=TaskNeedNumber
    elseif state == 1 then
        --转盘次数
        local LuckDrawNum=message:PopByte()
        GameData.ExchangeTelephoneFareInfo.WheelNumber=LuckDrawNum
        if LuckDrawNum == 0 then
            -- 接取下一任务间隔时间
            local TaskLastTime= message:PopUInt32()
            GameData.ExchangeTelephoneFareInfo.TaskCountDown=TaskLastTime
        end
    -- 无任务状态
    elseif state == 2 then
        --失败倒计时
        local TaskCount=message:PopUInt32()
        GameData.ExchangeTelephoneFareInfo.TaskFailCountDown=TaskCount
        --如果TaskCount=0当前所有任务已完成
    end
    
end

--  ========================== 服务器反馈任务完成 882 ======================= --
function NetMsgHandler.Received_S_Task_Success(message)
    local TaskId=message:PopUInt16()
    GameData.ExchangeTelephoneFareInfo.TaskState=1
    GameData.ExchangeTelephoneFareInfo.WheelNumber=1
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptTaskInfo)
end

--  ========================== 服务器反馈任务完成次数 883 =================== -- 
function NetMsgHandler.Received_S_TaskCompleteNumber(message)
    local TaskCompleteNumber=message:PopUInt16()
    local TaskCountDown=message:PopUInt32()
    GameData.ExchangeTelephoneFareInfo.TaskCompleteNumber=TaskCompleteNumber
    GameData.ExchangeTelephoneFareInfo.TaskCountDown=TaskCountDown
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptTaskInfo)
    CS.LoadingDataUI.Hide()
end

--  =========================请求抽话费 884 =============================== --
function NetMsgHandler.Send_CS_LuckDraw_Bill()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LuckDraw_Bill,message,false)
end

--  =========================反馈抽话费 884 =============================== --
function NetMsgHandler.Received_CS_LuckDraw_Bill(message)
    local resultType=message:PopByte()
    if resultType == 0 then
        -- 中奖位置
        local position = message:PopByte()
        GameData.ExchangeTelephoneFareInfo.WinningPosition=position
        --获得多少话费
        local Bill=message:PopUInt32()
        GameData.ExchangeTelephoneFareInfo.WinnerBill=Bill
        --玩家拥有话费
        local PlayerBill=message:PopUInt32()
        GameData.ExchangeTelephoneFareInfo.PlayerTelephoneRate=PlayerBill
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAccept_LuckDraw_Bill)
    else
        CS.BubblePrompt.Show(data.GetString("Extract_Bill_"..resultType),"UITask")
    end
end

-- ======================== 请求兑换话费 885 =============================== --
function NetMsgHandler.Send_CS_Exchange_Bill()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(GameData.ExchangeTelephoneFareInfo.ButtonIndex)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Bill_Exchange,message,false)
end

--  ===========================反馈兑换话费 885 ============================= --
function NetMsgHandler.Received_CS_Exchange_Bill(message)
    local resultType=message:PopByte()
    if resultType == 0 then
        local bill=message:PopUInt32()
        GameData.ExchangeTelephoneFareInfo.PlayerTelephoneRate=bill
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAccept_Exchange_Bill)
    else
        CS.BubblePrompt.Show(data.GetString("Exchange_Bill_"..resultType),"UIExchangeTelephoneFare")
    end
end

-- ======================== 请求兑换话费信息 886 =============================== --
function NetMsgHandler.Send_CS_Exchange_Bill_Info()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Bill_Exchange_Info,message,true)
end

--  ===========================反馈兑换话费信息 886 ============================= --
function NetMsgHandler.Received_CS_Exchange_Bill_Info(message)
    CS.LoadingDataUI.Hide()
        local bill=message:PopUInt32()
        GameData.ExchangeTelephoneFareInfo.PlayerTelephoneRate=bill
        local Exchange= CS.WindowManager.Instance:FindWindowNodeByName("UIExchangeTelephoneFare")
        if Exchange == nil then
            CS.WindowManager.Instance:OpenWindow("UIExchangeTelephoneFare")
        else
            Exchange.WindowGameObject:SetActive(true)
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptCarInfo)
        end
end

--  ============================服务器请求打开领奖啦界面  887 =================== --
function NetMsgHandler.Received_S_PrizeInfo(message)
        --玩家话费数量
        GameData.ExchangeTelephoneFareInfo.PlayerTelephoneRate = message:PopUInt32()
        --可兑换物名称
        GameData.ExchangeTelephoneFareInfo.Convertible = message:PopString()
        --够买下一物品还差多少话费
        GameData.ExchangeTelephoneFareInfo.LackBill = message:PopUInt32()
        --下一物品名称
        GameData.ExchangeTelephoneFareInfo.CannotConvertibility = message:PopString()
        if GameData.ExchangeTelephoneFareInfo.Convertible == "" then
            GameData.ExchangeTelephoneFareInfo.ConvertibilityState=1
        elseif GameData.ExchangeTelephoneFareInfo.CannotConvertibility == "" then
            GameData.ExchangeTelephoneFareInfo.ConvertibilityState=3
        elseif GameData.ExchangeTelephoneFareInfo.Convertible ~= "" and GameData.ExchangeTelephoneFareInfo.CannotConvertibility ~= "" then
            GameData.ExchangeTelephoneFareInfo.ConvertibilityState=2
        end

end

--  =========================== 客户咨询 玩家发送消息 1008 =================================== -- 
function NetMsgHandler.Send_CS_PlayerSendInfo(info)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushString(info)
    GameData.Player.Sender=1
    GameData.Player.Content=info
    
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PlayerSendInfo,message,false)
end

-- =========================== 服务器返回发送消息 1008 ==================================== --
function NetMsgHandler.Received_CS_BackSendInfo(message)
    --0 成功 1账号不存在 2内容为空
    local resultType = message:PopByte()
    if resultType == 0 then
        local Player={}
        Player.Sender=GameData.Player.Sender
        Player.Content=GameData.Player.Content
        Player.Time = message:PopString()
        GameData.Player.Time = Player.Time
        GameData.KFZX.InfoTotalNumber = GameData.KFZX.InfoTotalNumber+1
        GameData.KFZX.Info[GameData.KFZX.InfoTotalNumber]=Player
        
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyKFZXBackInfo)
    end
    print("=====1008=====")
end

-- =========================== 返回客服咨询 发送的信息  1009 ==================================== --
function NetMsgHandler.Received_S_KFZXBackSendInfo(message)

    local Server={}
    Server.Sender=2
    Server.Content= message:PopString()
    Server.Time = message:PopString()
   
    GameData.Server.Sender=Server.Sender
    GameData.Server.Content=Server.Content
    GameData.Server.Time=Server.Time
    GameData.KFZX.InfoTotalNumber=GameData.KFZX.InfoTotalNumber+1
    GameData.KFZX.Info[GameData.KFZX.InfoTotalNumber]=Server
    GameData.KFZX.ServerIsSendToPlayer=true
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyKFZXSendInfo)
    print("=====1009=====")
end

--  =========================== 客户咨询 玩家拉取历史信息 1010 =================================== -- 
function NetMsgHandler.Send_CS_PlayerPullInfo()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PlayerPullInfo,message,false)
end

-- =========================== 服务器返回发送消息 1010 ==================================== --
function NetMsgHandler.Received_CS_BackPlayerPullInfo(message)
    --0 成功 1账号不存在
    local resultType = message:PopByte()
    if resultType == 0 then
        local messageCount = message:PopUInt16()
        GameData.KFZX.InfoTotalNumber = messageCount
        local dataInfo={}
        for i = 1,messageCount  do
            local info={}
            info.Sender=message:PopByte()
            info.Content=message:PopString()
            info.Time=message:PopString()
            dataInfo[i]=info
        end

        if messageCount == 0 or dataInfo[messageCount].Sender ~= 2 then
            messageCount = messageCount + 1
            local info={}
            info.Sender = 2
            info.Content = data.GetString("GM_Answer")
            info.Time = ""
            dataInfo[messageCount] = info
        end
        GameData.KFZX.Info = dataInfo
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyKFZXPlayerPullInfo)
    end
    print("======1010=====")
end

--  =========================== 客户咨询 玩家打开界面 1011 =================================== -- 
function NetMsgHandler.Send_CS_PlayerOpenUI()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PlayerOpenUI,message,false)
end

function NetMsgHandler.Received_CS_PlayerOpenUI(message)
    GameData.RoleInfo.OfficialWX = message:PopString()
    GameData.RoleInfo.OfficialQQ = message:PopString()
    GameData.RoleInfo.OfficialUrl = message:PopString()
	local questionCount = message:PopUInt16();
    GameData.KFZX.BasicQuestionCount = questionCount;
    GameData.basicQuestion = {};
    GameData.basicAnswer = {};
    for index = 1, questionCount do
        GameData.basicQuestion[index] = message:PopString();
        GameData.basicAnswer[index] = message:PopString();
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyKFZXOfficialInfo)
end

--  =========================== 客户咨询 玩家关闭界面 1012 =================================== -- 
function NetMsgHandler.Send_CS_PlayerCloseUI()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PlayerCloseUI,message,false)
    
end

-- =========================== 推送新的公告  1019 ==================================== --
function NetMsgHandler.Received_S_NoticeNew(message)
    print("收到公告")
    GameData.NoticeRed = 1
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyNoticeNew)
end


--TUDOU
--  =========================== 获取玩家转盘抽奖纪录 438 =================================== -- 
-- function NetMsgHandler.Send_CS_BonusWhell_Share_OK()
--     local message = CS.Net.PushMessage()
--     message:PushUInt32(GameData.RoleInfo.AccountID)
--     NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Share_OK,message,false)
-- end
--TUDOU
function NetMsgHandler.Send_CS_Wheel_Record()
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Wheel_Record, message, false)
end
-- =========================== 服务器发聩 438 ==================================== --
-- function NetMsgHandler.Received_CS_BonusWhell_Share_OK(message)
--     -- 1 玩家不存在  2.转盘异常
--     local resultType=message:PopByte()
--     if resultType == 0 then
--         -- NetMsgHandler.Send_CS_Wheel_Record()
--     else
--         CS.BubblePrompt.Show(data.GetString("BW_Share_Error_"..resultType),"BonusWheelUI")
--     end
--     CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyWheelWinRecord);
-- end
--TUDOU
function NetMsgHandler.Received_CS_Wheel_Record(message)
    CS.LoadingDataUI.Hide();
    local resultType = 0;
    local tempCount = 0;
    local tempDate = 0;
    local tempTime = 0;
    local tempCount = 0;
    local tempMoney = 0;
    resultType = message:PopByte();
    local count = message:PopUInt16();
    GameData.FortunateInfo.recordCount = count;
    GameData.FortunateInfo.table_Record = {};
    if resultType == 0 then
        for k = 1, count do
            tempDate = message:PopString();
            tempTime = message:PopString();
            tempCount = message:PopByte();
            tempMoney = message:PopInt64();
            table.insert(GameData.FortunateInfo.table_Record, {date = tempDate, time = tempTime, count = tempCount, money = tempMoney});
        end
        
    end
    -- table.sort(GameData.FortunateInfo.table_Record, )
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyWheelWinRecord,resultType);
end
-- =================================================================================== -- 
-- ================================ 请求匹配场在线人数 729 =============================== --
--desc:请求匹配红包房间在线人数
--time:2018-01-30 10:38:34
--@message:
--@return 
--==============================--
function NetMsgHandler.Send_CS_PP_HongBaoRoomOnlineCount()
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PPHB_OnlineNumber, message, false)
end


function NetMsgHandler.Received_CS_PP_HongBaoRoomOnlineCount(message)
    local count  = message:PopByte()
    GameData.PPHBRoomOnlineCount = {}
    for index = 1, count, 1 do
        local OnlineData  =  {}
        OnlineData.roomIndex  = message:PopByte()
        OnlineData.OnlineCount  = message:PopUInt32()
        GameData.PPHBRoomOnlineCount[index] = OnlineData
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomOnlineEvent, nil)
end

-- ===================================== 请求进入房间 800 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_ZJ_RoomID(roomID)
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    message:PushUInt32(roomID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Enter_JZ_RoomID, message, false)
end

function NetMsgHandler.Received_CS_ZJ_RoomID(message)
    local resultType  = message:PopByte()
    if resultType == 0 then
        local type = message:PopByte()
        local roomID = message:PopUInt32()
        if type == ROOM_TYPE.ZuJu then
            NetMsgHandler.Send_CS_JH_Enter_Room1(roomID)
        elseif type == ROOM_TYPE.ZuJuNN then
            NetMsgHandler.Send_CS_NN_Enter_Room(roomID)
        elseif type == ROOM_TYPE.HongBao then
            NetMsgHandler.Send_CS_HB_Enter_Room1(roomID,0)
        elseif type == ROOM_TYPE.ZuJuTTZ then
            NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(roomID,0)
        elseif type == ROOM_TYPE.ZuJuMaJiang then
            NetMsgHandler.Send_CS_MJ_ZUJU_ENTER_ROOM(roomID)
        end
    else
        CS.BubblePrompt.Show(data.GetString("Enter_RoomID_"..resultType),"UIJoinRoom")
    end
    --CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomOnlineEvent, nil)
end

-- ==================================== CS_DaiLiRechargeInfo 237 玩家请求代理充值 ====================== --
function NetMsgHandler.Send_CS_DaiLiRechargeInfo()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_DaiLiRechargeInfo , message, true)
end

local function HallDaiLiInfoSort( tA, tB)
    return tA.Weight > tB.Weight
end

function NetMsgHandler.Received_CS_DaiLiRechargeInfo(message)
    local resultType  = message:PopByte()
    if resultType == 0 then
        -- 区域一文字
        local RegionalOneText = message:PopString() 
        -- 区域二文字
        local RegionalTwoText = message:PopString() 
        -- 代理数量
        local Count = message:PopUInt16()
        GameData.BankInformation.RegionalOneText = RegionalOneText
        GameData.BankInformation.RegionalTwoText = RegionalTwoText
        GameData.BankInformation.DaiLiCount = Count
        GameData.BankInformation.DaiLiInfo = {}
        GameData.BankInformation.HotDaiLiInfo = {}
        GameData.BankInformation.NoHotDaiLiInfo = {}
        for Index=1,Count,1 do
            -- 代理账号ID
            local DaiLiId = message:PopUInt32()
            -- 标签(0无 1人气)
            local Lable = message:PopByte()
            -- 权重
            local Weight = message:PopUInt32()
            -- 店铺名称
            local ShopName = message:PopString()
            -- QQ
            local QQ = message:PopString()
            -- 微信
            local WeiXin = message:PopString()
            -- 电话
            local Telephone = message:PopString()
            if Lable == 0 then
                table.insert(GameData.BankInformation.NoHotDaiLiInfo,{DaiLiId=DaiLiId,Lable=Lable,Weight=Weight,ShopName=ShopName,QQ=QQ,WeiXin=WeiXin,Telephone=Telephone})
            else
                table.insert(GameData.BankInformation.HotDaiLiInfo,{DaiLiId=DaiLiId,Lable=Lable,Weight=Weight,ShopName=ShopName,QQ=QQ,WeiXin=WeiXin,Telephone=Telephone})
            end
            --table.insert(GameData.BankInformation.DaiLiInfo,{DaiLiId=DaiLiId,Lable=Lable,Weight=Weight,ShopName=ShopName,QQ=QQ,WeiXin=WeiXin,Telephone=Telephone})
        end
        table.sort(GameData.BankInformation.NoHotDaiLiInfo,HallDaiLiInfoSort)
        table.sort(GameData.BankInformation.HotDaiLiInfo,HallDaiLiInfoSort)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyDaiLiRechargeInfo)
    else
        CS.BubblePrompt.Show(data.GetString("账号不存在"),"UIExtract")
    end
    CS.LoadingDataUI.Hide()
end

-- ==================================== CS_ComplaintAgent 238 玩家请求投诉客服 ====================== --
function NetMsgHandler.Send_CS_ComplaintAgent(textInfo)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    message:PushString(textInfo)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_ComplaintAgent , message, true)
end

function NetMsgHandler.Received_CS_ComplaintAgent(message)
    local resultType  = message:PopByte()
    if resultType == 0 then
        CS.BubblePrompt.Show(data.GetString("提交成功"),"UIExtract")
    else
        CS.BubblePrompt.Show(data.GetString("账号不存在"),"UIExtract")
    end
    CS.LoadingDataUI.Hide()
end


-- ===================================== 玩家请求充值 251 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Player_Recharge(tType,tGold)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    -- 充值方式（1支付宝 2微信 3QQ 4银行卡 5网银）
    message:PushByte(tType)
    -- 充值金额
    message:PushInt64(tGold)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_Recharge, message, true)
end

function NetMsgHandler.Received_CS_Player_Recharge(message)
    local resultType  = message:PopByte()
    if resultType == 0 then
        -- 玩家增加金币
        local tGold = message:PopInt64()
        -- 可用额度
        local AvailableCredit = message:PopInt64()
        -- 可提现额度
        local AmountExtraction = message:PopInt64()
        GameData.BankInformation.AvailableCredit = GameConfig.GetFormatColdNumber(AvailableCredit)
        GameData.BankInformation.AmountExtraction = GameConfig.GetFormatColdNumber(AmountExtraction)
    end
end

-- ===================================== 玩家请求提现 252 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Player_Extract(tType,tGold, ifSure)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    -- 提现方式（1银行卡 2支付宝）
    message:PushByte(tType)
    -- 提现金额
    message:PushInt64(tGold)
    --是否确定提现(1：表示请求提现信息，2：表示确定提现)
    message:PushByte(ifSure);
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_Extract, message, true)
end

function NetMsgHandler.Received_CS_Player_Extract(message)
    CS.LoadingDataUI.Hide()
    local resultType  = message:PopByte()
    if resultType == 0 then
        --可提现额度
        local tempData = message:PopInt64();
        -- 提现后的金币数量(玩家金币值)
        --local PlayerGoldAmount = message:PopInt64();
        -- 提现的手续费
        local ChargeOfWithdraw = message:PopInt64();
        -- 本次提现金额
        local AmountOfWithdraw = message:PopInt64()
        --是请求提现还是确定提现(1：请求提现信息，2：确定提现)
        local isGetData = message:PopByte();
        GameData.BankInformation.isGetData = isGetData;
        GameData.BankInformation.ChargeOfWithdraw = GameConfig.GetFormatColdNumber(ChargeOfWithdraw);
        GameData.BankInformation.AmountOfWithdraw = GameConfig.GetFormatColdNumber(AmountOfWithdraw);

        if isGetData == 1 then
            --GameData.BankInformation.AmountExtraction = GameConfig.GetFormatColdNumber(tempData);
        elseif isGetData == 2 then
            --GameData.RoleInfo.GoldCount = GameConfig.GetFormatColdNumber(tempData);
            GameData.BankInformation.AmountExtraction = GameConfig.GetFormatColdNumber(tempData);
            GameData.BankInformation.AvailableCredit = GameData.BankInformation.AvailableCredit - GameConfig.GetFormatColdNumber(AmountOfWithdraw)
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerRequestPutForward)
    else
		CS.BubblePrompt.Show(data.GetString("Player_Extract_Erro_"..resultType),"UIExtract")
    end
     
end

-- ===================================== 玩家请求绑定银行卡 253 ====================================--
-- ============================================================================================
--@tName:持卡人姓名
--@tBankCardNumber:银行卡号
--@tBankName:银行名称
--@tBankProvince:开户银行省份
--@tBankCity:开户银行城市
--@tBankSubbranch:开户银行支行
function NetMsgHandler.Send_CS_Player_BindingBankCardok(tName,tBankCardNumber,tBankName,tBankProvince,tBankCity,tBankSubbranch,MobilePhone)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushString(tName)
    message:PushString(tBankCardNumber)
    message:PushString(tBankName)
    message:PushString(tBankProvince)
    message:PushString(tBankCity)
    message:PushString(tBankSubbranch)
    message:PushString(MobilePhone)--手机号码(已绑定过发空字符串)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_BindingBankCard, message, true)
end

function NetMsgHandler.Received_CS_Player_BindingBankCardOK(message)
    CS.LoadingDataUI.Hide()
    local resultType  = message:PopByte()
    if resultType == 0 then
        GameData.RoleInfo.IsBindBank = true
        GameData.RoleInfo.IsBindAccount = true
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateIsBindAccount,nil)
    end

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerBindingBankCardOK,resultType)
end

-- ===================================== 玩家请求银行信息 254 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Player_BindingBankCard()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_BankInformation, message, true)
end

function NetMsgHandler.Received_CS_Player_BindingBankCard(message)
    CS.LoadingDataUI.Hide()
    local resultType  = message:PopByte()
    if resultType == 0 then
        -- 可用额度
        local AvailableCredit = message:PopInt64()
        -- 可提现额度
        local AmountExtraction = message:PopInt64()
        -- 银行卡是否绑定(1已绑定 0 未绑定)
        local IsBankCardBinding = message:PopByte()
        -- 支付宝是否绑定（1已绑定 0未绑定）
        GameData.BankInformation.ZhiFuBaoIsBinding = message:PopByte()
        GameData.BankInformation.ChangeBindFlag = message:PopByte()
        GameData.BankInformation.AvailableCredit = GameConfig.GetFormatColdNumber(AvailableCredit)
        GameData.BankInformation.AmountExtraction = GameConfig.GetFormatColdNumber(AmountExtraction)
        GameData.RoleInfo.IsBindBank = (IsBankCardBinding == 1)
        GameData.RoleInfo.IsBindZhifubao = (GameData.BankInformation.ZhiFuBaoIsBinding == 1)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerBindingBankCard)
    end
end

-- ===================================== 玩家账单信息 255 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Player_BillDetailed()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_BillDetailed, message, true)
end

function NetMsgHandler.Received_CS_Player_BillDetailed(message)
    CS.LoadingDataUI.Hide()
    local resultType  = message:PopByte()
    if resultType == 0 then
        -- 账单明细数量
        local BillCount = message:PopUInt16()
        GameData.BankInformation.BillCount = BillCount
        GameData.BankInformation.BillInfo = {}
        for Index=1,BillCount,1 do
            -- 明细类型（0充值 1提现）
            local tType = message:PopByte()
            -- 明细方式（1支付宝 2微信 3QQ 4银行卡 5网银）
            local tMode = message:PopByte()
            -- 日期
            --local tDate = message:PopByte()
            -- 时间
            local tTime = message:PopString()
            -- 金额
            local tGold = message:PopInt64()
            --tGold=GameConfig.GetFormatColdNumber(tGold)
            table.insert(GameData.BankInformation.BillInfo,{BillType=tType,BillMode=tMode,BillTime=tTime,BillGold=tGold})
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerBillDetailed)
    end
end

-- ===================================== 玩家点击提现按钮 256 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Player_ExtractInfo()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_ExtractInfo, message, true)
end

function NetMsgHandler.Received_CS_Player_ExtractInfo(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 银行卡是否绑定(1已绑定 0 未绑定)
        local IsBankCardBinding = message:PopByte()
        GameData.RoleInfo.IsBindBank = (IsBankCardBinding == 1 )
        if IsBankCardBinding == 1 then
            -- 银行名字
            local BankName = message:PopString()
            -- 卡号
            local BankNumber = message:PopString()
            GameData.BankInformation.BankName=BankName
        end
        -- 支付宝是否绑定(1已绑定 0未绑定)
        local ZhiFuBaoIsBinding = message:PopByte()
        GameData.BankInformation.ZhiFuBaoIsBinding = ZhiFuBaoIsBinding
        GameData.RoleInfo.IsBindZhifubao = (ZhiFuBaoIsBinding == 1)

        if ZhiFuBaoIsBinding == 1 then
            -- 支付宝实名制姓名
            local Name = message:PopString()
            -- 支付宝账号
            local Account = message:PopString()
            GameData.BankInformation.ZhiFuBaoName=Name
            GameData.BankInformation.ZhiFuBaoAccount=Account
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerPutForwardInfo,true)
    else
        CS.BubblePrompt.Show(data.GetString("Player_ExtractInfo_Erro_"..resultType),"UIExtract")
    end
end

-- ===================================== 玩家请求绑定银行卡信息 257 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Player_BankiCardInfo()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_BankiCardInfo, message, true)
end

function NetMsgHandler.Received_CS_Player_BankiCardInfo(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 银行名称
        local BankName = message:PopString()
        -- 卡号
        local CardName = message:PopString()
        -- 持卡人姓名
        local Name = message:PopString()

        GameData.BankInformation.BankPlayerName=Name
        GameData.BankInformation.BankName=BankName
        GameData.BankInformation.BankCardNumber=CardName
    end

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerBankiCardInfo, 1)
end

-- ===================================== 玩家请求绑定支付宝信息 258 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Player_ZFBInfo()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_ZFBInfo, message, true)
end

function NetMsgHandler.Received_CS_Player_ZFBInfo(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 支付宝实名制姓名
        local Name = message:PopString()
        -- 支付宝账号
        local Account = message:PopString()

        GameData.BankInformation.ZhiFuBaoName=Name
        GameData.BankInformation.ZhiFuBaoAccount=Account
    end

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerBankiCardInfo, 2)
end

-- ===================================== 玩家请求绑定支付宝 259 ====================================--
-- ============================================================================================
--@tName:支付宝实名制姓名
--@tBankCardNumber:支付宝账号
function NetMsgHandler.Send_CS_Player_BindingZhiFuBao(tName,tBankCardNumber,MobilePhone)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    message:PushString(tName)
    message:PushString(tBankCardNumber)
    message:PushString(MobilePhone)--手机号码(已绑定过发空字符串)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_BindingZhiFuBao, message, true)
end

function NetMsgHandler.Received_CS_Player_BindingZhiFuBao(message)
    CS.LoadingDataUI.Hide()
    local resultType  = message:PopByte()
    if resultType == 0 then
        GameData.BankInformation.ZhiFuBaoIsBinding = 1
        GameData.RoleInfo.IsBindAccount = true
        GameData.RoleInfo.IsBindZhifubao = true
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateIsBindAccount,nil)
        CS.BubblePrompt.Show(data.GetString("绑定成功"),"UIExtract")
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPlayerBindingBankCardOK, resultType)
end

-- ==================================== CS_Player_RechargeInterfaceInfo 260 玩家请求代理充值 ====================== --
function NetMsgHandler.Send_CS_Player_RechargeInterfaceInfo()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Player_RechargeInterfaceInfo , message, true)
end

local function RechargeDaiLiInfoSort( tA, tB)
    return tA.Weight > tB.Weight
end

function NetMsgHandler.Received_CS_Player_RechargeInterfaceInfo(message)
    local resultType  = message:PopByte()
    if resultType == 0 then
        -- 充值方式数量
        local RechargeNumber = message:PopUInt16()
        GameData.BankInformation.RechargeTypeInfo = {}
        for Index = 1, RechargeNumber, 1 do
            -- 充值方式类型
            local RechargeType = message:PopByte()
            -- 最低金额
            local MinValue =  message:PopUInt32()
            -- 最大金额
            local MaxValue = message:PopUInt32()
            -- 权重
            local RechargeTypeWeight = message:PopByte()
            -- 推荐金额
            local GoldValue = message:PopString()
            -- 人气 （0无 1 人气）
            local Lable = message:PopByte()
        
            if RechargeType == 11 then
                GameData.BankInformation.RechargeTypeInfo.QRCodeInfo = {}
                local QRCodeTypeIndex = {1,1,1,1}
                -- 二维码条数
                local QRCodeCount = message:PopUInt16()
                for i = 1, QRCodeCount do
                    -- Url索引
                    local UrlIndex = message:PopUInt32()
                    -- 二维码类型（1支付宝 2QQ 3微信 4微信）
                    local QRCodeType = message:PopByte()
                    -- 充值最小金额
                    local QRCodeMinValue =  message:PopUInt32()
                    -- 充值最大金额
                    local QRCodeMaxValue =  message:PopUInt32()
                    -- 权重
                    local QRCodeRechargeTypeWeight = message:PopByte()
                    -- url
                    local QRCodeURL = message:PopString()
                    -- 推荐金额
                    local QRCodeGoldValue = message:PopString()
                    -- 详细内容
                    local UrlInfo = message:PopString()
                    -- 备注提示
                    local Prompt = message:PopString()

                    table.insert(GameData.BankInformation.RechargeTypeInfo.QRCodeInfo,{UrlIndex = UrlIndex, RechargeType = QRCodeType, RechargeTypeIndex = QRCodeTypeIndex[QRCodeType], MinValue = QRCodeMinValue, MaxValue = QRCodeMaxValue, Weight = QRCodeRechargeTypeWeight, Url = QRCodeURL, Prompt = Prompt} )
                    QRCodeTypeIndex[QRCodeType] = QRCodeTypeIndex[QRCodeType] + 1
                    GameData.BankInformation.RechargeTypeInfo.QRCodeInfo[i].RecommendedValue = {}
                    GameData.BankInformation.RechargeTypeInfo.QRCodeInfo[i].UrlInfo = {}
                    for w in string.gmatch(QRCodeGoldValue,"([^',']+)") do     --按照“,”分割字符串
                        table.insert(GameData.BankInformation.RechargeTypeInfo.QRCodeInfo[i].RecommendedValue,w) 
                    end
                    for e in string.gmatch(UrlInfo,"([^',']+)") do     --按照“,”分割字符串
                        table.insert(GameData.BankInformation.RechargeTypeInfo.QRCodeInfo[i].UrlInfo,e) 
                    end

                end

                table.sort(GameData.BankInformation.RechargeTypeInfo.QRCodeInfo,RechargeDaiLiInfoSort)
            end
            table.insert(GameData.BankInformation.RechargeTypeInfo,{RechargeType = RechargeType, MinValue = MinValue, MaxValue = MaxValue, Weight = RechargeTypeWeight, Lable = Lable} )
            GameData.BankInformation.RechargeTypeInfo[Index].RecommendedValue = {}
            for w in string.gmatch(GoldValue,"([^',']+)") do     --按照“,”分割字符串
                table.insert(GameData.BankInformation.RechargeTypeInfo[Index].RecommendedValue,w) 
            end
        end
        table.sort(GameData.BankInformation.RechargeTypeInfo,RechargeDaiLiInfoSort)
        -- 区域一文字
        local RegionalOneText = message:PopString() 
        -- 区域二文字
        local RegionalTwoText = message:PopString() 
        -- 代理数量
        local Count = message:PopUInt16()
        GameData.BankInformation.RegionalOneText = RegionalOneText
        GameData.BankInformation.RegionalTwoText = RegionalTwoText
        GameData.BankInformation.DaiLiCount = Count
        GameData.BankInformation.DaiLiInfo = {}
        GameData.BankInformation.HotDaiLiInfo = {}
        GameData.BankInformation.NoHotDaiLiInfo = {}
        for Index=1,Count,1 do
            -- 代理账号ID
            local DaiLiId = message:PopUInt32()
            -- 标签(0无 1人气)
            local Lable = message:PopByte()
            -- 权重
            local Weight = message:PopUInt32()
            -- 店铺名称
            local ShopName = message:PopString()
            -- QQ
            local QQ = message:PopString()
            -- 微信
            local WeiXin = message:PopString()
            -- 电话
            local Telephone = message:PopString()
            if Lable == 0 then
                table.insert(GameData.BankInformation.NoHotDaiLiInfo,{DaiLiId=DaiLiId,Lable=Lable,Weight=Weight,ShopName=ShopName,QQ=QQ,WeiXin=WeiXin,Telephone=Telephone})
            else
                table.insert(GameData.BankInformation.HotDaiLiInfo,{DaiLiId=DaiLiId,Lable=Lable,Weight=Weight,ShopName=ShopName,QQ=QQ,WeiXin=WeiXin,Telephone=Telephone})
            end
            --table.insert(GameData.BankInformation.DaiLiInfo,{DaiLiId=DaiLiId,Lable=Lable,Weight=Weight,ShopName=ShopName,QQ=QQ,WeiXin=WeiXin,Telephone=Telephone})
        end
        table.sort(GameData.BankInformation.NoHotDaiLiInfo,RechargeDaiLiInfoSort)
        table.sort(GameData.BankInformation.HotDaiLiInfo,RechargeDaiLiInfoSort)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyRechargeInterfaceInfo)
    else
        CS.BubblePrompt.Show(data.GetString("账号不存在"),"UIExtract")
    end
    CS.LoadingDataUI.Hide()
end

-- ===================================== 玩家提交官方充值订单 CS_Official_Recharge 261 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Official_Recharge(tType,tGold,tUrlIndex,OrderNumber,Name,Type)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(tType) --(1支付宝 2 QQ 3 微信)
    message:PushUInt32(tonumber(tGold))
    message:PushUInt32(tUrlIndex)
    message:PushString(OrderNumber)
    message:PushString(Name)
    message:PushByte(Type)
    print("玩家提交官方充值订单",GameData.RoleInfo.AccountID,tType,tGold,tUrlIndex,OrderNumber,Name,Type)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Official_Recharge, message, false)
end
function NetMsgHandler.Received_CS_Official_Recharge(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        CS.BubblePrompt.Show(data.GetString("提交订单成功"),"UIExtract")
    else
        CS.BubblePrompt.Show(data.GetString("账号不存在"),"UIExtract")
    end
end

-- ================================== 玩家请求充值订单信息 CS_Official_OrderInformation 262 ==============================--
-- ==================================================================================================================== --
function NetMsgHandler.Send_CS_Official_OrderInformation()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Official_OrderInformation, message, true)
end

function NetMsgHandler.Received_CS_Official_OrderInformation(message)
    local resultType = message:PopByte()
    CS.LoadingDataUI.Hide()
    if resultType == 0 then
        -- 订单号
        GameData.BankInformation.OrderInformation = message:PopString()
        -- 时间
        GameData.BankInformation.Time = message:PopString()
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyOrderInformation, nil)
    else
        CS.BubblePrompt.Show(data.GetString("账号不存在"),"UIExtract")
    end
end

-- ===================================== 玩家成为代理 271 ====================================--
-- ============================================================================================
function NetMsgHandler.Received_S_Player_BecomeAgent(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        CS.WindowManager.Instance:OpenWindow("AgencyV8UI")
    end
end

-- ===================================== 玩家请求代理人信息 272 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_OpenMyAgency()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Open_MyAgency, message, true)
end

function NetMsgHandler.Received_CS_OpenMyAgency(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        --是否是代理(0不是 1是)
        local IsAgent = message:PopByte()
        GameData.AgencyInfo.IsAgent = IsAgent
        if IsAgent == 1 then
            -- 昨日总业绩
            local  ZRTotalCommission = message:PopInt64()
            -- 昨日直属会员业绩
            local ZRZSCommission = message:PopInt64()
            -- 昨日其他会员业绩
            local  ZRQTCommission = message:PopInt64()
            -- 总佣金
            local  TotalCommission = message:PopInt64()
            -- 可提取总佣金
            local PayableCommission = message:PopInt64()
            -- 我的直属会员
            local  ZSTotalMember = message:PopUInt32()
            -- 直属本周更新
            local  ZSWeekMember = message:PopUInt32()
            -- 直属本月更新
            local  ZSMonthMember = message:PopUInt32()
            -- 我的其他会员
            local QTTotalMember = message:PopUInt32()
            -- 其他本周更新
            local  QTWeekMember = message:PopUInt32()
            -- 其他本周更新
            local  QTMonthMember = message:PopUInt32()
            -- 推广员链接
            GameConfig.TGSharedUrl = message:PopString()
            -- 非推广员链接
            GameConfig.WXSharedUrl = message:PopString()
            GameData.AgencyInfo.ZRTotalCommission = ZRTotalCommission
            GameData.AgencyInfo.ZRZSCommission = ZRZSCommission
            GameData.AgencyInfo.ZRQTCommission = ZRQTCommission
            GameData.AgencyInfo.TotalCommission = TotalCommission
            GameData.AgencyInfo.PayableCommission = PayableCommission
            GameData.AgencyInfo.ZSTotalMember = ZSTotalMember
            GameData.AgencyInfo.ZSWeekMember = ZSWeekMember
            GameData.AgencyInfo.ZSMonthMember = ZSMonthMember
            GameData.AgencyInfo.QTTotalMember = QTTotalMember
            GameData.AgencyInfo.QTWeekMember = QTWeekMember
            GameData.AgencyInfo.QTMonthMember = QTMonthMember
        else
            -- 推广员链接
            GameConfig.TGSharedUrl = message:PopString()
            -- 非推广员链接
            GameConfig.WXSharedUrl = message:PopString()
        end
        
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAgencyEvent, nil)
    else
        CS.BubblePrompt.Show(data.GetString("T_272_"..resultType),"AgencyUI")
    end
    
end

-- =====================================玩家提取佣金提示 273 ====================================--
-- ============================================================================================
-- 领取代理佣金
function NetMsgHandler.Send_CS_Get_AgencyCommission(tempNumber,type)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(type);
    message:PushByte(tempNumber);
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Get_AgencyCommission, message, true)
end

function NetMsgHandler.Received_CS_Get_AgencyCommission(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    --是否提取成功(0成功 1账号不存在 2不是代理 3没有可提取佣金)
    if resultType == 0 then
        --提取金额
        local  tCommission = message:PopInt64()
        local  tempShouXuFei = message:PopInt64();
        local tempNumber = message:PopByte();
        GameData.AgencyInfo.isGetData = tempNumber;
        -- GameData.AgencyInfo.PayableCommission = 0
        -- if tempNumber == 1 then
            GameData.AgencyInfo.PayableCommission = tCommission;
            GameData.AgencyInfo.ChargeCount = GameConfig.GetFormatColdNumber(tempShouXuFei);
        -- elseif tempNumber == 2 then
            -- GameData.AgencyInfo.PayableCommission = GameConfig.GetFormatColdNumber(tCommission);
            -- GameData.AgencyInfo.ChargeCount = GameConfig.GetFormatColdNumber(tempShouXuFei);
        -- end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAgencyCommissionEvent, tCommission)
    else
        CS.BubblePrompt.Show(data.GetString("T_273_"..resultType),"AgencyUI")
    end
    
end

-- ===================================== 玩家提取详情 274 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_Agency_Extract_Data()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Agency_Extract_Data, message, true)
end

function NetMsgHandler.Received_CS_Agency_Extract_Data(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        GameData.AgencyInfo.ExtractData = {}
        local dataTable  = { }
        local tDataCount = message:PopUInt16()
        -- print("=====提取详情:", tDataCount)
        for i = 1, tDataCount do
            local dataInfo = { }
            dataInfo.Time  = message:PopString()
            dataInfo.Money = message:PopInt64()
            dataTable[i] = dataInfo
        end
        GameData.AgencyInfo.ExtractData = dataTable
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAgencyExtractEvent,nil)
    else
        CS.BubblePrompt.Show(data.GetString("T_274_"..resultType),"AgencyExtractUI")
    end
end


-- ===================================== 代理会员详情 275 ====================================--
-- ============================================================================================
function NetMsgHandler.Send_CS_MemberDetails()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Open_MenberDetail, message, true)
end

function NetMsgHandler.Received_CS_MemberDetails(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    -- 返回状况 0成功 1账号不存在 2不是代理
    if resultType == 0 then
        GameData.AgencyInfo.ZSMemberDetails = {}
        local count = message:PopUInt16()
        local dataTable = { }
        for i = 1, count do
            local tData = { }
            tData.Name  = message:PopString()
            tData.TotalBet = message:PopInt64()
            tData.TotalCommission = message:PopInt64()
            tData.LoginTime = message:PopUInt32()
            dataTable[i] = tData
        end
        GameData.AgencyInfo.ServerTime = message:PopUInt32()
        
        GameData.AgencyInfo.ZSMemberDetails = dataTable
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAgencyMemberEvent,nil)
    else
        CS.BubblePrompt.Show(data.GetString("T_275_"..resultType),"AgencyExtractUI")
    end
end


-- =========================== 1154 ====================
function NetMsgHandler.Received_S_KickOutBankerList(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        CS.BubblePrompt.Show(data.GetString("KickOutBankerList"),"HallUI")
    end
end

-- =========================== 1154 ====================

function NetMsgHandler.Received_S_Playing_Room(message)
    -- 增加 玩家正在游戏的房间信息
    GameData.RoleInfo.PlayRoomID = message:PopUInt32()
    GameData.RoleInfo.PlayRoomType = message:PopByte()
    print("=====1154 玩家正在玩的房间:",GameData.RoleInfo.PlayRoomID, GameData.RoleInfo.PlayRoomType)
end

-- ============================== 1504 S_RoomMaintainNews 房间维护推送协议 ==============================
function NetMsgHandler.Received_S_RoomMaintainNews(message)
    -- 本包游戏玩法数量
    local GameTypeNumber = message:PopUInt16()
    GameData.GameTypeDisplay = {}
    GameData.GameTypeListInfo = {}
    for Index = 1, GameTypeNumber, 1 do
        -- 初级房房间状态 （0未选择 1敬请期待 2上架  3下架 4无本档次）
        local PrimaryRoomState = message:PopByte()
        -- 初级房间标签 （0未选择 1无 2流畅 3火爆 4无本档次 5维护）
        local PrimaryRoomLabel = message:PopByte()
        -- 中级房房间状态 （0未选择 1敬请期待 2上架  3下架 4无本档次）
        local IntermediateRoomState = message:PopByte()
        -- 中级房间标签 （0未选择 1无 2流畅 3火爆 4无本档次 5维护）
        local IntermediateRoomLabel = message:PopByte()
        -- 高级房房间状态 （0未选择 1敬请期待 2上架  3下架 4无本档次）
        local SeniorRoomState = message:PopByte()
        -- 高级房间标签 （0未选择 1无 2流畅 3火爆 4无本档次 5维护）
        local SeniorRoomLabel = message:PopByte()
        -- 土豪房房间状态  （0未选择 1敬请期待 2上架  3下架 4无本档次）
        local TycoonRoomState = message:PopByte()
        -- 土豪房间标签 （0未选择 1无 2流畅 3火爆 4无本档次 5维护）
        local TycoonRoomLabel = message:PopByte()
        -- 游戏类型权重
        local GameTypeWeight = message:PopByte()
        -- 游戏类型
        local GameType = message:PopByte()
        -- 游戏类型状态 (0下架 1 上架)
        local GameTypeState = message:PopByte()
        -- 游戏类型标签（0无 1New 2Hot）
        local GameTypeLable = message:PopByte()
        if GameTypeState == 1 then
            table.insert(GameData.GameTypeDisplay,{PrimaryRoomState=PrimaryRoomState,PrimaryRoomLabel=PrimaryRoomLabel,IntermediateRoomState=IntermediateRoomState,IntermediateRoomLabel=IntermediateRoomLabel,
            SeniorRoomState=SeniorRoomState,SeniorRoomLabel=SeniorRoomLabel,TycoonRoomState=TycoonRoomState ,TycoonRoomLabel=TycoonRoomLabel,GameTypeWeight=GameTypeWeight,GameType=GameType,GameTypeState=GameTypeState,GameTypeLable=GameTypeLable})
            GameData.GameTypeListInfo[GameType] = {PrimaryRoomState=PrimaryRoomState,PrimaryRoomLabel=PrimaryRoomLabel,IntermediateRoomState=IntermediateRoomState,IntermediateRoomLabel=IntermediateRoomLabel,
                                                SeniorRoomState=SeniorRoomState,SeniorRoomLabel=SeniorRoomLabel,TycoonRoomState=TycoonRoomState ,TycoonRoomLabel=TycoonRoomLabel}
        end
        --print("初级房房间状态%d,初级房间标签%d,中级房房间状态%d,中级房间标签%d",GameType,Index,PrimaryRoomLabel,IntermediateRoomLabel,SeniorRoomLabel,TycoonRoomLabel)
    end
    if GameTypeNumber > 0 then
        table.sort(GameData.GameTypeDisplay,HallGameTypeSort)
        GameData.RoleInfo.HallRoomTypeUpdateTime = 0
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateHallLayout,nil)
end

-- ============================== 1505 CS_RoomListRoommTypeInfo 请求房间列表配置 ==============================
function NetMsgHandler.Send_CS_RoomListRoommTypeInfo(tRoomType)
    local message = CS.Net.PushMessage()
    message:PushByte(tRoomType)
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_RoomListRoommTypeInfo, message, true)
end

function NetMsgHandler.Received_CS_RoomListRoommTypeInfo(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 游戏类型
        local GameType = message:PopByte()
        -- 房间数量
        local RoomNumber = message:PopByte()
        GameData.RoleInfo.RoomAmount = RoomNumber;
            -- 百人金花
        if GameType == 2 then
            GameData.RoleInfo.BRTRoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注上限
                local BetValueMax = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                table.insert(GameData.RoleInfo.BRTRoomConfiguration,{RoomLevel = RoomLevel, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin, BetValueMax = BetValueMax})
            end

            -- 龙虎斗
        elseif GameType == 3 then
            GameData.RoleInfo.BRTRoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注上限
                local BetValueMax = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                table.insert(GameData.RoleInfo.BRTRoomConfiguration,{RoomLevel = RoomLevel, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin, BetValueMax = BetValueMax})
            end

            -- 百家乐
        elseif GameType == 4 then
            GameData.RoleInfo.BRTRoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注上限
                local BetValueMax = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                table.insert(GameData.RoleInfo.BRTRoomConfiguration,{RoomLevel = RoomLevel, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin, BetValueMax = BetValueMax})
            end

            -- 奔驰宝马
        elseif GameType == 6 then
            GameData.RoleInfo.RoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                local RoomName = ""
                table.insert(GameData.RoleInfo.RoomConfiguration,{RoomLevel = RoomLevel, RoomName = RoomName, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin})
            end

            -- 幸运转盘
        elseif GameType == 7 then
            GameData.RoleInfo.RoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                local RoomName = ""
                table.insert(GameData.RoleInfo.RoomConfiguration,{RoomLevel = RoomLevel, RoomName = RoomName, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin})
            end

            -- 炸金花
        elseif GameType == 8 then
            GameData.RoleInfo.RoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 房间名字
                local RoomName = message:PopString()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                table.insert(GameData.RoleInfo.RoomConfiguration,{RoomLevel = RoomLevel, RoomName = RoomName, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin})
            end

            -- 抢庄牛牛
        elseif GameType == 9 then
            GameData.RoleInfo.RoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 房间名字
                local RoomName = message:PopString()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                table.insert(GameData.RoleInfo.RoomConfiguration,{RoomLevel = RoomLevel, RoomName = RoomName, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin})
            end

            -- 红包接龙
        elseif GameType == 10 then
            GameData.RoleInfo.RoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 房间名字
                local RoomName = message:PopString()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                table.insert(GameData.RoleInfo.RoomConfiguration,{RoomLevel = RoomLevel, RoomName = RoomName, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin})
            end
            
            -- 推筒子
        elseif GameType == 11 then
            GameData.RoleInfo.RoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 房间名字
                local RoomName = message:PopString()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                table.insert(GameData.RoleInfo.RoomConfiguration,{RoomLevel = RoomLevel, RoomName = RoomName, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin})
            end
            -- 跑得快
        elseif GameType == 13 then
            GameData.RoleInfo.RoomConfiguration = {}
            for Index = 1, RoomNumber, 1 do
                -- 房间等级
                local RoomLevel = message:PopByte()
                -- 房间名字
                local RoomName = message:PopString()
                -- 进入金币上限
                local EnterGoldMax = message:PopInt64()/10000
                -- 进入金币下限
                local EnterGoldMin = message:PopInt64()/10000
                -- 投注下限
                local BetValueMin = message:PopInt64()/10000
                table.insert(GameData.RoleInfo.RoomConfiguration,{RoomLevel = RoomLevel, RoomName = RoomName, EnterGoldMax = EnterGoldMax, EnterGoldMin = EnterGoldMin, BetValueMin = BetValueMin})
            end
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifRoomListRoomTyleInfo,GameType)
    end
    CS.LoadingDataUI.Hide()
end

--===============================================================================================
--===========================================余额宝相关=========================================--

-- ============================== 1601 CS_YueBaoPassWord 余额宝首次设置密码 =====================
function NetMsgHandler.Send_CS_YueBaoPassWord(PassWord1,PassWord2)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushString(PassWord1)
    message:PushString(PassWord2)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YueBaoPassWord, message, false)
end

function NetMsgHandler.Receivde_CS_YueBaoPassWord(message)
    -- body
    local resultType = message:PopByte()
    if resultType == 0 then
        local PassWord = message:PopString()
        GameData.YueBaoInfo.Homepage.PassWord = PassWord
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoFirstPassWord,nil)
    end
    CS.LoadingDataUI.Hide()
    CS.BubblePrompt.Show(data.GetString("YueBaoSetPassWord_"..resultType),"UIYuebao")
end

-- ============================== 1602 CS_PassWordYanZheng 余额宝身份验证 ========================--
function NetMsgHandler.Send_CS_PassWordYanZheng(PassWord)
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushString(PassWord)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PassWordYanZheng, message, false)
end

function NetMsgHandler.Received_CS_PassWordYanZheng(message)
    -- body
    local resultType = message:PopByte()
    if resultType == 0 then
        local PassWord = message:PopString()
        GameData.YueBaoInfo.Homepage.PassWord = PassWord
    end
    CS.LoadingDataUI.Hide()
    CS.BubblePrompt.Show(data.GetString("YueBaoPassWordYanZheng_"..resultType),"UIYuebao")
end

-- ============================= 1604 CS_ChangeYueBaoPassWord 余额宝修改密码 ===========================
function NetMsgHandler.Send_CS_ChangeYueBaoPassWord(Password1,Password2,CellphoneNumber)
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushString(Password1)
    message:PushString(Password2)
    message:PushString(tostring(CellphoneNumber))
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_ChangeYueBaoPassWord, message, true)
end

function NetMsgHandler.Received_CS_ChangeYueBaoPassWord(message)
    -- body
    local resultType = message:PopByte()
    if resultType == 0 then
        local PassWord = message:PopString()
        GameData.YueBaoInfo.Homepage.BindingPassword = PassWord
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoChangePassword,nil)
    end
    CS.LoadingDataUI.Hide()
    CS.BubblePrompt.Show(data.GetString("ChangeYueBaoPassWord_"..resultType),"UIYuebao")
end

-- ============================= 1605 CS_YueBaoTurnOutValue 余额宝转出金额 ===========================
function NetMsgHandler.Send_CS_YueBaoTurnOutValue(GoldValue)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushInt64(GoldValue)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YueBaoTurnOutValue, message, true)
end

function NetMsgHandler.Received_CS_YueBaoTurnOutValue(message)
    local resultType = message:PopByte()
    print('余额宝转入金额',resultType)
    CS.LoadingDataUI.Hide()
    if resultType == 0 then
        -- 转出金额
        GameData.YueBaoInfo.Homepage.TurnOutValue = message:PopInt64() / 10000
        -- 余额宝金额
        GameData.YueBaoInfo.Homepage.AllGoldValue = message:PopInt64() / 10000
        -- 可存入金额
        GameData.YueBaoInfo.Homepage.IntoAllValue = message:PopInt64() / 10000
        -- 日化收益
        GameData.YueBaoInfo.Homepage.DayProfit = message:PopInt64() / 10000
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoIntoGoldValue,2)
    else
        CS.BubblePrompt.Show(data.GetString("YueBaoTurnOutValue_"..resultType),"UIYuebao")
    end  
end

-- ============================= 1606 CS_YueBaoIntoValue 余额宝转入金额 ===========================
function NetMsgHandler.Send_CS_YueBaoIntoValue(GoldValue)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushInt64(GoldValue*10000)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YueBaoIntoValue, message, true)
end

function NetMsgHandler.Received_CS_YueBaoIntoValue(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 转入金额
        GameData.YueBaoInfo.Homepage.IntoValue = message:PopInt64() / 10000
        -- 余额宝金额
        GameData.YueBaoInfo.Homepage.AllGoldValue = message:PopInt64() / 10000
        -- 可存入金额
        GameData.YueBaoInfo.Homepage.IntoAllValue = message:PopInt64() / 10000
        local timer = message:PopInt64()
        GameData.YueBaoInfo.Homepage.ShouYiTime = GetTimeToTable(timer)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoIntoGoldValue,1)
    else
        if resultType == 3 then
            local carRotation = CS.WindowManager.Instance:FindWindowNodeByName("UIBndingBankCard")
            if carRotation == nil then
                CS.WindowManager.Instance:OpenWindow("UIBndingBankCard")
            end
            return 
        elseif resultType == 2 then
            local carRotation = CS.WindowManager.Instance:FindWindowNodeByName("UITwoCipher")
            if carRotation == nil then
                CS.WindowManager.Instance:OpenWindow("UITwoCipher")
            end
            return
        else
            CS.BubblePrompt.Show(data.GetString("YueBaoIntoValue_"..resultType),"UIYuebao")
        end
    end
    CS.LoadingDataUI.Hide()
end

-- ============================= 1607 CS_YueBaoInvestmentType 余额宝投资买入类型 ===========================
function NetMsgHandler.Send_CS_YueBaoInvestmentType(tType,Number)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(tType)
    message:PushUInt32(Number)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YueBaoInvestmentType, message, true)
end

function NetMsgHandler.Received_CS_YueBaoInvestmentType(message)
    local resultType = message:PopByte()
    CS.LoadingDataUI.Hide()
    if resultType == 0 then
        local ResultTable = {}
        -- 买入类型
        ResultTable.tType = message:PopByte()
        -- 买入份数
        ResultTable.Number = message:PopUInt32()
        -- 花费金币
        ResultTable.SpendGold = message:PopInt64() / 10000
        -- 当前剩余份数
        ResultTable.SpareNumber = message:PopUInt32()
        -- 当日总分数
        ResultTable.AllNumber = message:PopUInt32()
        -- 余额宝当前金额
        GameData.YueBaoInfo.Homepage.AllGoldValue = message:PopInt64() / 10000
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoBuy,ResultTable)
    else
        CS.BubblePrompt.Show(data.GetString("YueBaoInvestmentType_"..resultType),"UIYuebao")
    end
end

-- =========================== 1608 CS_YueBaoLineTime 余额宝投资买入界面信息 =========================
function NetMsgHandler.Send_CS_YueBaoLineTime(tType,IsHomepage)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(tType)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YueBaoLineTime, message, true)
end

function NetMsgHandler.Received_CS_YueBaoLineTime(message)
    local resultType = message:PopByte()
    CS.LoadingDataUI.Hide()
    if resultType == 0 then
        -- 买入时间
        local BuyingTime = message:PopUInt32()
        -- 预计成交
        local BuyOkTime = message:PopUInt32()
        -- 产生收益
        local YieldTime = message:PopUInt32()
        -- 到期
        local ExpiryTime = message:PopUInt32()
        -- 剩余次数
        local SurplusBuyValue = message:PopUInt32()
        -- 总共次数
        local AllBuyValue = message:PopUInt32()
        GameData.YueBaoInfo.Investment.BuyingTime = GetTimeToTable(BuyingTime)
        GameData.YueBaoInfo.Investment.BuyOkTime = GetTimeToTable(BuyOkTime)
        GameData.YueBaoInfo.Investment.YieldTime = GetTimeToTable(YieldTime)
        GameData.YueBaoInfo.Investment.ExpiryTime = GetTimeToTable(ExpiryTime)
        GameData.YueBaoInfo.Investment.SurplusBuyValue = SurplusBuyValue
        GameData.YueBaoInfo.Investment.AllBuyValue = AllBuyValue
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoLineTime,nil)
    else
        CS.BubblePrompt.Show(data.GetString("YueBaoLineTime_"..resultType),"UIYuebao")
    end
end

-- ============================== 1610 CS_YueBaoDetailed 余额宝明细 =========================
function NetMsgHandler.Send_CS_YueBaoDetailed()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(4)
    message:PushUInt32(1)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YueBaoDetailed, message, true)
end

function NetMsgHandler.Received_CS_YueBaoDetailed(message)
    local resultType = message:PopByte()
    CS.LoadingDataUI.Hide()
    if resultType == 0 then
        -- 总共条数
        local AllCount = message:PopUInt32()
        -- 当前页码
        local PageNumber = message:PopUInt32()
        -- 数量
        local Count = message:PopUInt32()
        GameData.YueBaoInfo.DetailedInfo = {}
        for i = 1, Count do

            local InfoTable = {}
            -- 类型（1：转出 2：收益 3：转出）
            local tType = message:PopByte()
            -- 变动数据
            local ChangeValue = message:PopInt64() / 10000
            -- 变动后余额
            local AfterChangeValue = message:PopInt64() / 10000
            -- 时间戳
            local ChangeTime = message:PopUInt32()
            if tType == 1 then
                -- 转入类型
                local tMode = message:PopByte()
                if tMode == 1 then
                    -- 理财类型
                    local BuyType = message:PopByte()
                    InfoTable =  { Mode = tMode, BuyType = BuyType}
                elseif tMode == 2 then
                    -- N日
                    local NDay = message:PopByte()
                    InfoTable = { Mode = tMode, NDay = NDay}
                else
                    InfoTable = { Mode = tMode }
                end
            elseif tType == 2 then
                -- 收益类型
                local tMode = message:PopByte()
                if tMode == 1 then
                    -- 买入时间
                    local BuyTime1 = message:PopUInt32()
                    -- 买入类型
                    local BuyType =  message:PopByte()

                    local BuyTime = GetTimeToTable(BuyTime1)
                    InfoTable = { Mode = tMode, BuyTime = BuyTime, BuyType = BuyType}
                else
                    InfoTable = { Mode = tMode }
                end
                
            elseif tType == 3 then
                -- 转出类型
                local tMode = message:PopByte()
                if tMode == 1 then
                    -- 购买时间戳
                    local BuyTime1 = message:PopUInt32()
                    -- 购买类型
                    local BuyType = message:PopByte()

                    local BuyTime = GetTimeToTable(BuyTime1)
                    InfoTable = { Mode = tMode, BuyTime = BuyTime, BuyType = BuyType}
                else
                    InfoTable = { Mode = tMode }
                end
            end
            ChangeTime = GetTimeToString(ChangeTime)
            table.insert( GameData.YueBaoInfo.DetailedInfo, {Type = tType, ChangeValue = ChangeValue, AfterChangeValue = AfterChangeValue, ChangeTime = ChangeTime, InfoTable = InfoTable} )
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoDetailed,nil)
    else
        CS.BubblePrompt.Show(data.GetString("YueBaoDetailed_"..resultType),"UIYuebao")
    end
end

-- ============================== 1611 CS_YueBaoMyBuyInfo 余额宝我的买入 =========================
function NetMsgHandler.Send_CS_YueBaoMyBuyInfo()
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    message:PushByte(4)
    message:PushUInt32(1)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YueBaoMyBuyInfo, message, true)
end

function NetMsgHandler.Received_CS_YueBaoMyBuyInfo(message)
    local resultType = message:PopByte()
    CS.LoadingDataUI.Hide()
    if resultType == 0 then
        -- 总共条数
        local AllCount = message:PopUInt32()
        -- 当前页码
        local PageNumber = message:PopUInt32()
        -- 数量
        local Count = message:PopUInt32()
        GameData.YueBaoInfo.MyBuyInfo = {}
        for i = 1, Count do
            -- 理财ID
            local Id = message:PopUInt32()
            -- 理财类型
            local tType = message:PopByte()
            -- 购买时间戳
            local BuyTimeTable = message:PopUInt32()
            -- 起算时间戳
            local StartTimeTable = message:PopUInt32()
            -- 购买花费
            local BuyGold = message:PopInt64() / 10000
            -- 单份金额
            local OnlyGold = message:PopUInt32() / 10000
            -- 购买份数
            local BuyNumber = message:PopUInt32()
            -- 万元利率
            local LiLv = message:PopInt64() / 10000
            local BuyTime = GetTimeToString(BuyTimeTable)
            local StartTime = GetTimeToTable(StartTimeTable)
            table.insert(GameData.YueBaoInfo.MyBuyInfo,{ID = Id, Type = tType, BuyTime = BuyTime, StartTime = StartTime, BuyGold = BuyGold, OnlyGold = OnlyGold, BuyNumber = BuyNumber, LiLv = LiLv} )
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoMyBuyInfo,nil)
    else
        CS.BubblePrompt.Show(data.GetString("YueBaoMyBuyInfo_"..resultType),"UIYuebao")
    end
end

-- ============================== 1612 CS_YueBaoSellOut 余额宝卖出 ==============================
function NetMsgHandler.Send_CS_YueBaoSellOut(ID)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    message:PushUInt32(ID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YueBaoSellOut, message, true)
end

function NetMsgHandler.Received_CS_YueBaoSellOut(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 余额宝总金额
        GameData.YueBaoInfo.Homepage.AllGoldValue = message:PopInt64() / 10000
        -- 累计收益
        GameData.YueBaoInfo.Homepage.AllProfit = message:PopInt64() / 10000
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyYueBaoSellOut,nil)
    end
    CS.LoadingDataUI.Hide()
    CS.BubblePrompt.Show(data.GetString("YueBaoSellOut_"..resultType),"UIYuebao")
end

-- ============================== 1613 CS_YuEBao_Info 余额宝主页信息 ==============================
function NetMsgHandler.Send_CS_YuEBao_Info()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_YuEBao_Info, message, false)
end

function NetMsgHandler.Received_CS_YuEBao_Info(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 总金额
        local AllGoldValue = message:PopInt64()
        -- 昨日收益
        local YesterdayProfit = message:PopInt64()
        -- 累计收益
        local AllProfit = message:PopInt64()
        -- 日化利率
        local DayInterestRate = message:PopUInt32()
        -- 日化收益
        local DayProfit = message:PopUInt32()
        -- 七日利率
        local QiDayInterestRate = message:PopUInt32()
        -- 十五日利率
        local ShiWuDayInterestRate = message:PopUInt32()
        -- 三十日利率
        local SanShiDayInterestRate = message:PopUInt32()
        -- 七日价格
        local QiDayPrice = message:PopUInt32()
        -- 七日份数起买
        local QiDayNumber = message:PopByte()
        -- 十五日价格
        local ShiWuDayPrice = message:PopUInt32()
        -- 十五日份数起买
        local ShiWuDayNumber = message:PopByte()
        -- 三十日价格
        local SanShiDayPrice = message:PopUInt32()
        -- 三十日份数起买
        local SanShiDayNumber = message:PopByte()
        -- 可转入额度
        local IntoAllValue = message:PopInt64()
        -- 是否绑定过余额宝密码（0：绑定过 1没绑定过）
        local Binding = message:PopByte()
        -- 余额宝密码
        local BindingPassword = message:PopString()
        -- 产品1名字
        GameData.YueBaoInfo.Homepage.Name1 = message:PopString()
        -- 产品2名字
        GameData.YueBaoInfo.Homepage.Name2 = message:PopString()
        -- 产品3名字
        GameData.YueBaoInfo.Homepage.Name3 = message:PopString()
        --table.insert(GameData.YueBaoInfo.Homepage ,{AllGoldValue = AllGoldValue, YesterdayProfit = YesterdayProfit, AllProfit = AllProfit, DayInterestRate = DayInterestRate, DayProfit = DayProfit, QiDayInterestRate = QiDayInterestRate, ShiWuDayInterestRate = ShiWuDayInterestRate, SanShiDayInterestRate = SanShiDayInterestRate})
        GameData.YueBaoInfo.Homepage.AllGoldValue=AllGoldValue / 10000
        GameData.YueBaoInfo.Homepage.YesterdayProfit=YesterdayProfit / 10000
        GameData.YueBaoInfo.Homepage.AllProfit=AllProfit / 10000
        GameData.YueBaoInfo.Homepage.DayInterestRate=DayInterestRate / 10000
        GameData.YueBaoInfo.Homepage.DayProfit=DayProfit / 10000
        GameData.YueBaoInfo.Homepage.QiDayInterestRate=QiDayInterestRate / 10000
        GameData.YueBaoInfo.Homepage.ShiWuDayInterestRate=ShiWuDayInterestRate / 10000
        GameData.YueBaoInfo.Homepage.SanShiDayInterestRate=SanShiDayInterestRate / 10000
        GameData.YueBaoInfo.Homepage.IntoAllValue = IntoAllValue / 10000

        GameData.YueBaoInfo.Homepage.QiDayPrice=QiDayPrice / 10000
        GameData.YueBaoInfo.Homepage.QiDayNumber=QiDayNumber
        GameData.YueBaoInfo.Homepage.ShiWuDayPrice=ShiWuDayPrice / 10000
        GameData.YueBaoInfo.Homepage.ShiWuDayNumber=ShiWuDayNumber
        GameData.YueBaoInfo.Homepage.SanShiDayPrice=SanShiDayPrice / 10000
        GameData.YueBaoInfo.Homepage.SanShiDayNumber = SanShiDayNumber

        GameData.YueBaoInfo.Homepage.Binding = (Binding == 0 )
        GameData.YueBaoInfo.Homepage.BindingPassword = BindingPassword

        --[[print("============== A",GameData.YueBaoInfo.Homepage.AllGoldValue,AllGoldValue)
        print("============== B",GameData.YueBaoInfo.Homepage.YesterdayProfit,YesterdayProfit)
        print("============== C",GameData.YueBaoInfo.Homepage.AllProfit,AllProfit)
        print("============== D",GameData.YueBaoInfo.Homepage.DayInterestRate,DayInterestRate)
        print("============== E",GameData.YueBaoInfo.Homepage.DayProfit,DayProfit)
        print("============== F",GameData.YueBaoInfo.Homepage.QiDayInterestRate,QiDayInterestRate)
        print("============== G",GameData.YueBaoInfo.Homepage.ShiWuDayInterestRate,ShiWuDayInterestRate)
        print("============== H",GameData.YueBaoInfo.Homepage.SanShiDayInterestRate,SanShiDayInterestRate)--]]
        local carRotation = CS.WindowManager.Instance:FindWindowNodeByName("UIYuebao")
        if carRotation == nil then
            CS.WindowManager.Instance:OpenWindow("UIYuebao")
        end
    else
        CS.BubblePrompt.Show(data.GetString("YuEBao_Info_"..resultType),"UIYuebao")
    end
    CS.LoadingDataUI.Hide()
end