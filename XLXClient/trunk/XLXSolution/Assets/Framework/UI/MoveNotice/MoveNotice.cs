using UnityEngine;
using System.Collections.Generic;
using UnityEngine.UI;

/// <summary>
/// 走马灯提示UI
/// </summary>
public class MoveNotice : MonoBehaviour
{
    /// <summary>
    /// 遮挡组件
    /// </summary>
    [SerializeField]
    GameObject mMaskGameObject = null;
    /// <summary>
    /// 移动信息内容
    /// </summary>
    [SerializeField]
    Text mMoveNoticeText = null;

    /// <summary>
    /// 半视窗宽度
    /// </summary>
    float mHalfViewWidth = 0f;

    /// <summary>
    /// 通知内容的一半宽度 + 视窗一半宽度
    /// </summary>
    float mHalfNoticeWidth = 0f;

    private static int mMoveSpeed = 100;
    /// <summary>
    /// 通知文字移动速度
    /// </summary>
    public static int MoveSpeed
    {
        get { return mMoveSpeed; }
        set
        {
            if (mMoveSpeed < 1)
                mMoveSpeed = 1;
            if (mMoveSpeed > 10000)
                mMoveSpeed = 10000;

            mMoveSpeed = value;
        }
    }

    private static int mValidTime = 20;

    /// <summary>
    /// 有效的时间(s)单位--最短有效时间5s，最长100s
    /// </summary>
    public static int ValidTime
    {
        get { return mValidTime; }
        set
        {
            if (value < 5)
                value = 5;
            if (value > 100)
                value = 100;

            mValidTime = value;
        }
    }

    /// <summary>
    /// 播放消息队列
    /// </summary>
    static List<NoticeInfo> m_NoticeQueue = new List<NoticeInfo>();

    static List<NoticeInfo> m_NoticedHistory = new List<NoticeInfo>();
    /// <summary>
    /// 播放消息的历史记录
    /// </summary>
    public static List<string> NiticedHistory
    {
        get
        {
            List<string> result = new List<string>();
            for (int i = 0; i < m_NoticedHistory.Count; i++)
            {
                result.Add(m_NoticedHistory[i].Content);
            }

            return result;
        }
    }

    /// <summary>
    /// 系统广播，最大保留20条
    /// </summary>
    public static int HistoryMaxCount = 20;

    static void PushToNiticedHistory(NoticeInfo noticeInfo)
    {
        if (m_NoticedHistory.Count > 1 && noticeInfo == m_NoticedHistory[0])// 已经添加了，不需要添加
        {
            return;
        }

        if (m_NoticedHistory.Count >= HistoryMaxCount)
        {
            m_NoticedHistory.RemoveAt(HistoryMaxCount - 1);
        }

        m_NoticedHistory.Insert(0, noticeInfo);// 插入到最前面
    }

    /// <summary>
    /// 当前播放消息
    /// </summary>
    static NoticeInfo CurrentNotice = null;

    private static int m_MaxCount = 20;
    /// <summary>
    /// 最大保留的消息条目，如果大于此数，则不接受新消息
    /// </summary>
    public static int MaxCount
    {
        get { return m_MaxCount; }
        set
        {
            if (value < 1)
                value = 1;
            m_MaxCount = value;
        }
    }

    /// <summary>
    /// 开始移动标志
    /// </summary>
    static bool MoveStart = false;

    static int m_NoticeID = 1;
    /// <summary>
    /// 获取通知消息序列号
    /// </summary>
    /// <returns></returns>
    static int GetNoticeID()
    {
        if (m_NoticeID > 10000)
        {
            m_NoticeID = 1;
        }
        m_NoticeID++;
        return m_NoticeID;
    }

    int m_PlayingNoticeID = 0;

    /// <summary>
    /// 通知消息
    /// </summary>
    /// <param name="content">消息内容</param>
    /// <param name="level">消息级别</param>
    /// <param name="immediate">是否立即生效(是:播放完当前条目就播放下一条，否:播放完队列中所有才开始播放此消息）</param>
    public static void Notice(string content, int level = 1, bool immediate = false)
    {
        if (m_NoticeQueue.Count > MaxCount)
        {
            //ClearOneObsoleteNotice();
            return;
        }

        NoticeInfo notice = new NoticeInfo(GetNoticeID());
        notice.Content = content;
        notice.PushTime = Time.realtimeSinceStartup;
        notice.Level = level;

        AppendOneNotice(notice);
        MoveStart = true;
    }

    /// <summary>
    /// 清理掉一个最早添加的消息
    /// </summary>
    static void ClearOneObsoleteNotice()
    {
        NoticeInfo notice = m_NoticeQueue[0];
        for (int i = 1; i < m_NoticeQueue.Count; i++)
        {
            // 时间越小越早进入广播等待
            if (m_NoticeQueue[i].PushTime < notice.PushTime)
            {
                notice = m_NoticeQueue[i];
            }
        }
        m_NoticeQueue.Remove(notice);
    }

    static void AppendOneNotice(NoticeInfo notice)
    {
        for (int i = 0; i < m_NoticeQueue.Count; i++)
        {
            if (m_NoticeQueue[i].Level < notice.Level)
            {
                m_NoticeQueue.Insert(i, notice);
                return;
            }
        }

        m_NoticeQueue.Add(notice);
    }

    /// <summary>
    /// 清理掉未播放的消息
    /// </summary>
    public static void ClearAll()
    {
        m_NoticeQueue.Clear();
        if (CurrentNotice != null)
        {
            CurrentNotice = null;
        }
        m_NoticedHistory.Clear();
    }


    bool TryStartMove1()
    {
        bool isStartMoving = false;
        while (m_NoticeQueue.Count > 0)
        {
            NoticeInfo notice = m_NoticeQueue[0];
            //押入到已经播放的列表中
            PushToNiticedHistory(notice);

            if (notice.PushTime - Time.realtimeSinceStartup < ValidTime)// 在有效时间内，消息广播
            {
                m_NoticeQueue.RemoveAt(0);
                CurrentNotice = notice;
                isStartMoving = true;
                RefreshPlayNoticeContent1(notice);
                ResetNoticeTextPosition();
                m_PlayingNoticeID = notice.NoticeID;
                break;
            }
            else
            {
                m_NoticeQueue.RemoveAt(0);
            }
        }
        //Debug.LogFormat("IsStartMoving:{0}", isStartMoving);
        return isStartMoving;
    }

    /// <summary>
    /// 重置播放内容
    /// </summary>
    /// <param name="notice">消息内容</param>
    void RefreshPlayNoticeContent1(NoticeInfo notice)
    {
        mMaskGameObject.SetActive(true);
        mMoveNoticeText.text = notice.Content;
        mHalfNoticeWidth = mMoveNoticeText.preferredWidth * 0.5f + mHalfViewWidth;
        mMoveNoticeText.rectTransform.sizeDelta = new Vector2(mMoveNoticeText.preferredWidth, mMoveNoticeText.rectTransform.sizeDelta.y);
        if (notice.StartTime == 0)
        {
            notice.StartTime = Time.realtimeSinceStartup;
        }
    }

    /// <summary>
    /// 重置播放内容位置
    /// </summary>
    void ResetNoticeTextPosition()
    {
        float currentX = mHalfNoticeWidth - (Time.realtimeSinceStartup - CurrentNotice.StartTime) * MoveSpeed;
        mMoveNoticeText.rectTransform.localPosition = new Vector3(currentX, 0, 0);
    }

    /// <summary>
    /// 是否当前条目播放完成
    /// </summary>
    /// <returns></returns>
    bool IsNoticeComplated()
    {
        return mMoveNoticeText.rectTransform.localPosition.x < -mHalfNoticeWidth;
    }

    /// <summary>
    /// 处理播放完成所有消息后的处理
    /// </summary>
    void HandleAllNoticeComplated1()
    {
        CurrentNotice = null;
        mMaskGameObject.SetActive(false);
        MoveStart = false;
        m_PlayingNoticeID = 0;
    }

    private void Awake()
    {
        mHalfViewWidth = GetComponent<RectTransform>().rect.size.x * 0.5f;
        if (mMaskGameObject == null || mMoveNoticeText == null)
        {
            Debug.LogError("Some UI element was null in MoveNotice script, please check it!");
            GameObject.Destroy(this);
        }
    }

    void OnEnable()
    {
        if (CurrentNotice != null)// 重新设置下内容
        {
            RefreshPlayNoticeContent1(CurrentNotice);
        }
        else if (MoveStart)
        {
            Update();
        }
        else
        {
            HandleAllNoticeComplated1();
        }
    }

    /// <summary>
    /// sdfsdfsdf
    /// </summary>
    void Update()
    {
        if (CurrentNotice != null)
        {
            if (m_PlayingNoticeID != CurrentNotice.NoticeID)
            {
                RefreshPlayNoticeContent1(CurrentNotice);
                m_PlayingNoticeID = CurrentNotice.NoticeID;
            }

            ResetNoticeTextPosition();
            if (IsNoticeComplated())
            {
                CurrentNotice = null;
                if (!TryStartMove1())
                {
                    HandleAllNoticeComplated1();
                }
            }
        }
        else if (MoveStart)
        {
            if (!TryStartMove1())
            {
                HandleAllNoticeComplated1();
            }
        }
        else
        {
            if (m_PlayingNoticeID != 0)
            {
                HandleAllNoticeComplated1();
            }
        }
    }

    public class NoticeInfo
    {
        public NoticeInfo(int noticeID)
        {
            this.NoticeID = noticeID;
        }

        /// <summary>
        /// 播放消息的编号
        /// </summary>
        public int NoticeID { get; private set; }

        /// <summary>
        /// 移动文本
        /// </summary>
        public string Content { get; set; }

        /// <summary>
        /// 压入队列的时间
        /// </summary>
        public float PushTime { get; set; }

        /// <summary>
        /// 开始执行时间
        /// </summary>
        public float StartTime { get; set; }

        /// <summary>
        /// 级别
        /// </summary>
        public int Level { get; set; }
    }

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