//***************************************************************
// 脚本名称：MessageBox
// 类创建人：
// 创建日期：2016.01
// 功能描述：通用提示框
//***************************************************************

using UnityEngine;
using UnityEngine.UI;
using System.Collections;
using System.Collections.Generic;

/// <summary>
/// 通用提示框
/// </summary>
public class MessageBoxUI : WindowBase
{
    public static readonly string UIAssetName = "MessageBoxUI";
    /// <summary>
    /// 关闭按钮
    /// </summary>
    [SerializeField]
    Button m_CloseButton = null;
    /// <summary>
    /// 整个关闭区域
    /// </summary>
    [SerializeField]
    Button m_CloseAreaButton = null;
    /// <summary>
    /// 确认按钮
    /// </summary>
    [SerializeField]
    Button m_OKButton = null;
    /// <summary>
    /// 取消按钮
    /// </summary>
    [SerializeField]
    Button m_CancelButton = null;
    /// <summary>
    /// 确认按钮描述
    /// </summary>
    [SerializeField]
    Text m_OKButtonText = null;
    /// <summary>
    /// 取消按钮描述
    /// </summary>
    [SerializeField]
    Text m_CancelButtonText = null;
    /// <summary>
    /// 提示title
    /// </summary>
    [SerializeField]
    Text m_TitleText = null;
    /// <summary>
    /// 提示类容
    /// </summary>
    [SerializeField]
    Text m_ContentText = null;
    /// <summary>
    /// 提示区域
    /// </summary>
    [SerializeField]
    RectTransform m_ContentArea = null;

    /// <summary>
    /// 使用倒计时
    /// </summary>
    bool m_UseCountDown = false;
    /// <summary>
    /// 倒计时时间
    /// </summary>
    float m_CountDown = 0;
    /// <summary>
    /// 按钮相应回调
    /// </summary>
    System.Action<MessageBoxResult> CallBack = null;
    /// <summary>
    /// 确认按钮Name
    /// </summary>
    string m_OkButtonName = "OK";
    /// <summary>
    /// 关闭区域是否启用
    /// </summary>
    bool m_EnableCloseArea = false;
    /// <summary>
    /// 提示内容最小高度
    /// </summary>
    const int ContentMinHeight = 350;


    /// <summary>
    /// 刷新数据
    /// </summary>
    /// <param name="windowData"></param>
    public override void RefreshWindowData(object windowData)
    {
        base.RefreshWindowData(windowData);
        MessageBoxData uiData = windowData as MessageBoxData;
        if (uiData == null)
        {
            return;
        }
        currentCountDownSecond = -1;
        m_CountDown = uiData.LastTime;
        m_UseCountDown = uiData.LastTime > 0;

        if (m_TitleText != null)
        {
            m_TitleText.text = uiData.Title;
        }

        if (m_ContentText != null)
        {
            m_ContentText.text = uiData.Content;
            m_ContentText.rectTransform.sizeDelta = new Vector2(m_ContentText.rectTransform.sizeDelta.x, Mathf.Max(ContentMinHeight - 60, m_ContentText.preferredHeight));
            m_ContentArea.sizeDelta = new Vector2(m_ContentArea.sizeDelta.x, Mathf.Max(ContentMinHeight, m_ContentText.preferredHeight + 60));
        }

        if (m_CancelButtonText != null)
        {
            m_CancelButtonText.text = uiData.CancelButtonName;
        }

        m_OkButtonName = uiData.OKButtonName;
        if (m_OKButtonText != null)
        {
            if (m_UseCountDown)
            {
                UpdateCountDownDisplay(m_CountDown);
            }
            else
            {
                m_OKButtonText.text = m_OkButtonName;
            }
        }
        this.CallBack = uiData.CallBack;
        this.m_EnableCloseArea = uiData.EnableCloseArea;

        SetUIButtonActiveByStyle(uiData.Style);
    }

    /// <summary>
    /// 设置UI风格样式
    /// </summary>
    /// <param name="style"></param>
    void SetUIButtonActiveByStyle(MessageBoxStyle style)
    {
        switch (style)
        {
            case MessageBoxStyle.OK:
                m_OKButton.gameObject.SetActive(true);
                m_CancelButton.gameObject.SetActive(false);
                m_CloseButton.gameObject.SetActive(false);
                break;
            case MessageBoxStyle.OKCancel:
                m_OKButton.gameObject.SetActive(true);
                m_CancelButton.gameObject.SetActive(true);
                m_CloseButton.gameObject.SetActive(false);
                break;
            case MessageBoxStyle.OKCancelClose:
                m_OKButton.gameObject.SetActive(true);
                m_CancelButton.gameObject.SetActive(true);
                m_CloseButton.gameObject.SetActive(true);
                break;
            case MessageBoxStyle.OKClose:
                m_OKButton.gameObject.SetActive(true);
                m_CancelButton.gameObject.SetActive(false);
                m_CloseButton.gameObject.SetActive(true);
                break;
        }
    }

    /// <summary>
    /// 按钮回调
    /// </summary>
    /// <param name="result"></param>
    void OnHandleButtonClick(MessageBoxResult result)
    {
        if (CallBack != null)
        {
            CallBack(result);
        }

        if (WindowManager.Instance != null)
        {
            WindowManager.Instance.CloseWindow(WindowNode, true);
        }
        else
        {
            Destroy(gameObject);
        }
    }


    int currentCountDownSecond = 0;
    /// <summary>
    /// 更新显示CD
    /// </summary>
    /// <param name="m_CountDown"></param>
    void UpdateCountDownDisplay(float m_CountDown)
    {
        int number = Mathf.CeilToInt(m_CountDown);
        if (currentCountDownSecond != number)
        {
            currentCountDownSecond = number;
            if (m_OKButtonText != null)
            {
                m_OKButtonText.text = string.Format("{0}({1})", m_OkButtonName, currentCountDownSecond);
            }
        }
    }

    /// <summary>
    /// 显示提示框
    /// </summary>
    /// <param name="uiData"></param>
    /// <param name="parent"></param>
    public static void Show(MessageBoxData uiData, WindowNode parent = null)
    {
        string UIAssetName_X = "MessageBoxUI";
        Vector2 screenSize = new Vector2(Screen.width, Screen.height);
        if(screenSize.x==1125 && screenSize.y == 2436)
        {
            UIAssetName_X = "MessageBoxUI_X";
        }
        WindowNodeInitParam initParam = new WindowNodeInitParam(UIAssetName_X);

        if (uiData.LuaCallBack != null)
        {
            System.Action<MessageBoxResult> luaCallBack = (result) =>
            {
                uiData.LuaCallBack((int)result);
            };

            if (uiData.CallBack != null)
            {
                uiData.CallBack += luaCallBack;
            }
            else
            {
                uiData.CallBack = luaCallBack;
            }
        }


        if (parent != null)
        {
            initParam.ParentNode = parent;
        }
        else
        {
            initParam.NodeType = BaseNodeType.Propmt;
        }
        initParam.WindowData = uiData;
        WindowManager.Instance.OpenWindow(initParam);
    }

    protected override void Start()
    {
        base.Start();
        if (m_OKButton == null || m_CloseButton == null || m_CancelButton == null || m_CloseAreaButton == null || m_TitleText == null || m_ContentText == null)
        {
            Debug.LogError("Some ui element was null in MessageBox script, please check it!");
            return;
        }

        m_OKButton.onClick.AddListener(() => OnHandleButtonClick(MessageBoxResult.OK));
        m_CancelButton.onClick.AddListener(() => OnHandleButtonClick(MessageBoxResult.Cancel));
        m_CloseButton.onClick.AddListener(() => OnHandleButtonClick(MessageBoxResult.Close));
        m_CloseAreaButton.onClick.AddListener(() =>
        {
            if (m_EnableCloseArea)
                OnHandleButtonClick(MessageBoxResult.CloseArea);
        });
    }

    /// <summary>
    /// Update
    /// </summary>
    private void Update()
    {
        if (m_UseCountDown)
        {
            m_CountDown -= Time.deltaTime;
            UpdateCountDownDisplay(m_CountDown);
            if (m_CountDown <= 0)
            {
                m_UseCountDown = false;
                OnHandleButtonClick(MessageBoxResult.Close);
            }
        }
    }


}

/// <summary>
/// 操作返回结果
/// </summary>
public enum MessageBoxResult : int
{
    /// <summary>
    /// 返回结果
    /// </summary>
    OK = 1,
    /// <summary>
    /// 取消
    /// </summary>
    Cancel = 2,
    /// <summary>
    /// 关闭
    /// </summary>
    Close = 3,
    /// <summary>
    /// 关闭区域关闭
    /// </summary>
    CloseArea = 3,
}

/// <summary>
/// 提示框样式
/// </summary>
public enum MessageBoxStyle : int
{
    /// <summary>
    /// 确定
    /// </summary>
    OK = 1,
    /// <summary>
    /// 确定，取消
    /// </summary>
    OKCancel = 2,
    /// <summary>
    /// 确定，关闭
    /// </summary>
    OKClose = 3,
    /// <summary>
    /// 确定，取消，关闭
    /// </summary>
    OKCancelClose = 4,
}

/// <summary>
/// 提示框数据
/// </summary>
public class MessageBoxData
{
    public string Title { get; set; }

    public string Content { get; set; }

    /// <summary>
    /// 持续时间（0：不使用持续时间, 大于0 在确认按钮上显示持续时间）
    /// ex:OK(2) 每秒更新
    /// </summary>
    public int LastTime { get; set; }

    /// <summary>
    /// 对话框样式
    /// </summary>
    public MessageBoxStyle Style { get; set; }

    private string m_OKButtonName = "确定";

    /// <summary>
    /// 确定按钮名称
    /// </summary>
    public string OKButtonName
    {
        get { return m_OKButtonName; }
        set
        {
            if (!string.IsNullOrEmpty(value))
                m_OKButtonName = value;
        }
    }

    private string m_CancelButtonName = "取消";
    /// <summary>
    /// 取消按钮名称
    /// </summary>
    public string CancelButtonName
    {
        get { return m_CancelButtonName; }
        set
        {
            if (!string.IsNullOrEmpty(value))
                m_CancelButtonName = value;
        }
    }

    /// <summary>
    /// 关闭区域是否可用
    /// </summary>
    public bool EnableCloseArea { get; set; }

    /// <summary>
    /// 回掉处理
    /// </summary>
    public System.Action<MessageBoxResult> CallBack;

    /// <summary>
    /// Lua 的回调
    /// </summary>
    public System.Action<int> LuaCallBack;

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