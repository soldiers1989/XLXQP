using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using JPush;

public class JPushManager : Kernel<JPushManager>
{
    public static bool IsOpen = true;

    void Start()
    {
        #if !UNITY_EDITOR
        IsOpen = true;
        #else
        IsOpen = false;
        #endif

        Init(gameObject.name);
    }

    void OnDestroy()
    {
        
    }


    /// <summary>
    /// 初始化 JPush。
    /// </summary>
    /// <param name="gameObject">游戏对象名。</param>
    public static void Init(string gameObject)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.Init(gameObject);

    }
    /// <summary>
    /// 设置是否开启 Debug 模式。
    /// <para>Debug 模式将会输出更多的日志信息，建议在发布时关闭。</para>
    /// </summary>
    /// <param name="enable">true: 开启；false: 关闭。</param>
    public static void SetDebug(bool enable)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.SetDebug(enable);
    }

    /// <summary>
    /// 获取当前设备的 Registration Id。
    /// </summary>
    /// <returns>设备的 Registration Id。</returns>
    public static string GetRegistrationId()
    {
        if (!IsOpen)
        {
            return "";
        }
        return JPushBinding.GetRegistrationId();
    }
    
    #region Common API

    /// <summary>
    /// 为设备设置标签（tag）。
    /// <para>注意：这个接口是覆盖逻辑，而不是增量逻辑。即新的调用会覆盖之前的设置。</para>
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    /// <param name="tags">
    ///     标签列表。
    ///     <para>每次调用至少设置一个 tag，覆盖之前的设置，不是新增。</para>
    ///     <para>有效的标签组成：字母（区分大小写）、数字、下划线、汉字、特殊字符 @!#$&*+=.|。</para>
    ///     <para>限制：每个 tag 命名长度限制为 40 字节，最多支持设置 1000 个 tag，且单次操作总长度不得超过 5000 字节（判断长度需采用 UTF-8 编码）。</para>
    /// </param>
    public static void SetTags(int sequence, List<string> tags)
    {
        if (!IsOpen)
        {
            return ;
        }
        JPushBinding.SetTags(sequence, tags);
    }

    /// <summary>
    /// 为设备新增标签（tag）。
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    /// <param name="tags">
    ///     标签列表。
    ///     <para>每次调用至少设置一个 tag，覆盖之前的设置，不是新增。</para>
    ///     <para>有效的标签组成：字母（区分大小写）、数字、下划线、汉字、特殊字符 @!#$&*+=.|。</para>
    ///     <para>限制：每个 tag 命名长度限制为 40 字节，最多支持设置 1000 个 tag，且单次操作总长度不得超过 5000 字节（判断长度需采用 UTF-8 编码）。</para>
    /// </param>
    public static void AddTags(int sequence, List<string> tags)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.AddTags(sequence, tags);
    }

    /// <summary>
    /// 删除标签（tag）。
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    /// <param name="tags">
    ///     标签列表。
    ///     <para>每次调用至少设置一个 tag，覆盖之前的设置，不是新增。</para>
    ///     <para>有效的标签组成：字母（区分大小写）、数字、下划线、汉字、特殊字符 @!#$&*+=.|。</para>
    ///     <para>限制：每个 tag 命名长度限制为 40 字节，最多支持设置 1000 个 tag，且单次操作总长度不得超过 5000 字节（判断长度需采用 UTF-8 编码）。</para>
    /// </param>
    public static void DeleteTags(int sequence, List<string> tags)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.DeleteTags(sequence, tags);
    }

    /// <summary>
    /// 清空当前设备设置的标签（tag）。
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    public static void CleanTags(int sequence)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.CleanTags(sequence);
    }

    /// <summary>
    /// 获取当前设备设置的所有标签（tag）。
    /// <para>需要实现 OnJPushTagOperateResult 方法获得操作结果。</para>
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    public static void GetAllTags(int sequence)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.GetAllTags(sequence);
    }

    /// <summary>
    /// 查询指定标签的绑定状态。
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    /// <param name="tag">待查询的标签。</param>
    public static void CheckTagBindState(int sequence, string tag)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.CheckTagBindState(sequence, tag);
    }

    /// <summary>
    /// 设置别名。
    /// <para>注意：这个接口是覆盖逻辑，而不是增量逻辑。即新的调用会覆盖之前的设置。</para>
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    /// <param name="alias">
    ///     别名。
    ///     <para>有效的别名组成：字母（区分大小写）、数字、下划线、汉字、特殊字符@!#$&*+=.|。</para>
    ///     <para>限制：alias 命名长度限制为 40 字节（判断长度需采用 UTF-8 编码）。</para>
    /// </param>
    public static void SetAlias(int sequence, string alias)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.SetAlias(sequence, alias);
    }

    /// <summary>
    /// 删除别名。
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    public static void DeleteAlias(int sequence)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.DeleteAlias(sequence);
    }

    /// <summary>
    /// 获取当前设备设置的别名。
    /// </summary>
    /// <param name="sequence">用户自定义的操作序列号。同操作结果一起返回，用来标识一次操作的唯一性。</param>
    public static void GetAlias(int sequence)
    {
        if (!IsOpen)
        {
            return;
        }
        JPushBinding.GetAlias(sequence);
    }


    #endregion  Common API

    #region ANDROID API

    /// <summary>
    /// 停止 JPush 推送服务。 
    /// </summary>
    public static void StopPush()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.StopPush();
        #endif
    }

    /// <summary>
    /// 唤醒 JPush 推送服务，使用了 StopPush 必须调用此方法才能恢复。
    /// </summary>
    public static void ResumePush()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.ResumePush();
        #endif
    }

    /// <summary>
    /// 判断当前 JPush 服务是否停止。
    /// </summary>
    /// <returns>true: 已停止；false: 未停止。</returns>
    public static bool IsPushStopped()
    {
        if (!IsOpen)
        {
            return true;
        }
        #if UNITY_ANDROID
        return JPushBinding.IsPushStopped();
        #else
        return true;
        #endif
    }

    /// <summary>
    /// 设置允许推送时间。
    /// </summary>
    /// <parm name="days">为 0~6 之间由","连接而成的字符串。</parm>
    /// <parm name="startHour">0~23</parm>
    /// <parm name="endHour">0~23</parm>
    public static void SetPushTime(string days, int startHour, int endHour)
    {
        if (!IsOpen)
        {
            return ;
        }
        #if UNITY_ANDROID
        JPushBinding.SetPushTime(days, startHour, endHour);
        #else
        
        #endif
    }

    /// <summary>
    /// 设置通知静默时间。
    /// </summary>
    /// <parm name="startHour">0~23</parm>
    /// <parm name="startMinute">0~59</parm>
    /// <parm name="endHour">0~23</parm>
    /// <parm name="endMinute">0~23</parm>
    public static void SetSilenceTime(int startHour, int startMinute, int endHour, int endMinute)
    {
        if (!IsOpen)
        {
            return;
        }
#if UNITY_ANDROID
        JPushBinding.SetSilenceTime(startHour, startMinute, endHour, endMinute);
#else

#endif

    }

    /// <summary>
    /// 设置保留最近通知条数。
    /// </summary>
    /// <param name="num">要保留的最近通知条数。</param>
    public static void SetLatestNotificationNumber(int num)
    {
        if (!IsOpen)
        {
            return;
        }
#if UNITY_ANDROID
        JPushBinding.SetLatestNotificationNumber(num);
#else

#endif

    }

    public static void AddLocalNotification(int builderId, string content, string title, int nId,
            int broadcastTime, string extrasStr)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.AddLocalNotification(builderId, content, title, nId, broadcastTime, extrasStr);
        #else

        #endif
    }

    public static void AddLocalNotificationByDate(int builderId, string content, string title, int nId,
            int year, int month, int day, int hour, int minute, int second, string extrasStr)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.AddLocalNotificationByDate(builderId, content, title, nId,
            year, month, day, hour, minute, second, extrasStr);
        #else

        #endif
    }

    public static void RemoveLocalNotification(int notificationId)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.RemoveLocalNotification(notificationId);
        #else

        #endif
    }

    public static void ClearLocalNotifications()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.ClearLocalNotifications();
        #else

        #endif
    }

    public static void ClearAllNotifications()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.ClearAllNotifications();
        #else

        #endif

    }

    public static void ClearNotificationById(int notificationId)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.ClearNotificationById(notificationId);
        #else

        #endif
    }

    /// <summary>
    /// 用于 Android 6.0 及以上系统申请权限。
    /// </summary>
    public static void RequestPermission()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.RequestPermission();
        #else

        #endif
    }

    public static void SetBasicPushNotificationBuilder()
    {
        // 需要根据自己业务情况修改后再调用。
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.SetBasicPushNotificationBuilder();
        #else

        #endif
    }

    public static void SetCustomPushNotificationBuilder(int builderId, string layoutName, string statusBarDrawableName, string layoutIconDrawableName)
    {
        // 需要根据自己业务情况修改后再调用。
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.SetCustomPushNotificationBuilder();
        #else

        #endif
    }

    public static void InitCrashHandler()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.InitCrashHandler();
        #else

        #endif
    }

    public static void StopCrashHandler()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_ANDROID
        JPushBinding.StopCrashHandler();
        #else

        #endif
    }
    #endregion ANDROID API

    #region iOS API

    public static void SetBadge(int badge)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_IOS
        JPushBinding.SetBadge(badge);
        #else

        #endif
    }

    public static void ResetBadge()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_IOS
        JPushBinding.ResetBadge();
        #else

        #endif
    }

    public static void SetApplicationIconBadgeNumber(int badge)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_IOS
        JPushBinding.SetApplicationIconBadgeNumber(badge);
        #else
        
        #endif
    }

    public static int GetApplicationIconBadgeNumber()
    {
        if (!IsOpen)
        {
            return 0;
        }
        #if UNITY_IOS
        return JPushBinding.GetApplicationIconBadgeNumber();
        #else
        return 0;
        #endif
    }

    public static void StartLogPageView(string pageName)
    {
        if (!IsOpen)
        {
            return ;
        }
        #if UNITY_IOS
        JPushBinding.StartLogPageView(pageName);
        #else
        
        #endif
    }

    public static void StopLogPageView(string pageName)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_IOS
        JPushBinding.StopLogPageView(pageName);
        #else

        #endif
    }

    public static void BeginLogPageView(string pageName, int duration)
    {
        if (!IsOpen)
        {
            return;
        }
#if UNITY_IOS
        JPushBinding.BeginLogPageView(pageName, duration);
#else

#endif

    }

    #region iOS 本地通知 -start

    public static void SendLocalNotification(string localParams)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_IOS
        JPushBinding.SendLocalNotification(localParams);
        #else

        #endif
    }

    public static void SetLocalNotification(int delay, string content, int badge, string idKey)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_IOS
        JPushBinding.SetLocalNotification(delay, content, badge, idKey);
        #else

        #endif
    }

    public static void DeleteLocalNotificationWithIdentifierKey(string idKey)
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_IOS
        JPushBinding.DeleteLocalNotificationWithIdentifierKey(idKey);
        #else

        #endif
    }

    public static void ClearAllLocalNotifications()
    {
        if (!IsOpen)
        {
            return;
        }
        #if UNITY_IOS
        JPushBinding.ClearAllLocalNotifications();
        #else

        #endif
    }

    #endregion iOS 本地通知 end

    #endregion iOS API

    #region 事件监听相关

    /// <summary>
    /// 收到自定义消息。
    /// *****开发者自己处理由 JPush 推送下来的消息。*****
    /// </summary>
    /// <param name="jsonStr"></param>
    void OnReceiveMessage(string jsonStr)
    {
        /*
         * 
         * Android 的通知内容格式为：
            {
              "message": "自定义消息内容",
              "extras": {   // 自定义键值对
                "key1": "value1",
                "key2": "value2"
              }
            }
            iOS 的自定义消息内容格式为：

            {
              "content": "自定义消息内容",
              "extras": {  // 自定义键值对
                "key1": "value1",
                "key2": "value2"
              }
            }
         * 
         */
        EventDispatcher.Instance.TriggerEvent("JPushReceiveMessageEvent", jsonStr);
    }


    // 
    /// <summary>
    /// 收到通知。
    /// *****获取的是 json 格式数据，开发者根据自己的需要进行处理。*****
    /// </summary>
    /// <param name="jsonStr"></param>
    void OnReceiveNotification(string jsonStr)
    {
        /*
         * Android 的通知内容格式为：
            {
              "title": "通知标题",
              "content": "通知内容",
              "extras": {   // 自定义键值对
                "key1": "value1",
                "key2": "value2"
            }
            iOS 的通知内容格式为：
            {
              "aps":{
                "alert":"通知内容",
                "badge":1,
                "sound":"default"
              },
              "key1":"value1",
              "key2":"value2",
              "_j_uid":11433016635,
              "_j_msgid":20266199577754012,
              "_j_business":1
            }
         * 
         */
        EventDispatcher.Instance.TriggerEvent("JPushReceiveNotificationEvent", jsonStr);
    }

    /// <summary>
    /// 点击通知栏通知事件
    /// *****开发者自己处理点击通知栏中的通知*****
    /// </summary>
    /// <param name="jsonStr">通知内容的 Json 字符串。</param>
    void OnOpenNotification(string jsonStr)
    {
        /* Android 的通知内容格式为：
        {
            "title": "通知标题",
            "content": "通知内容",
            "extras": {   // 自定义键值对
            "key1": "value1",
            "key2": "value2"
        }
        */

        /* iOS 的通知内容格式为：
        {
          "aps":{
            "alert":"通知内容",
            "badge":1,
            "sound":"default"
          },
          "key1":"value1",
          "key2":"value2",
          "_j_uid":11433016635,
          "_j_msgid":20266199577754012,
          "_j_business":1
        }
        */
        EventDispatcher.Instance.TriggerEvent("JPushOpenNotificationEvent", jsonStr);
    }

    /// <summary>
    /// JPush 的 tag 操作回调。
    /// </summary>
    /// <param name="result">操作结果，为 json 字符串。</param>
    void OnJPushTagOperateResult(string result)
    {
        /*
        result: Json 格式字符串。格式为：
        {
            "sequence": 1,            // 调用标签或别名方法时传入的。
            "code": 0,                // 结果码。0：成功；其他：失败（详细说明可参见官网文档）。
            "tag": ["tag1", "tag2"],  // 传入或查询得到的标签，当没有标签时，没有该字段。
            "isBind": true            // 是否已绑定。只有调用 CheckTagBindState 方法时才有该字段。
        }
        */
        EventDispatcher.Instance.TriggerEvent("JPushTagOperateResultEvent", result);
    }

    /// <summary>
    /// JPush 的 alias(别名) 操作回调。
    /// </summary>
    /// <param name="result">操作结果，为 json 字符串。</param>
    void OnJPushAliasOperateResult(string result)
    {
        /*
         * result: Json 格式字符串。格式为：
         * {
         *   "sequence": 1, // 调用标签或别名方法时传入的。
         *   "code": 0,     // 结果码。0：成功；其他：失败（详细说明可参见官网文档）。
         *   "alias": "查询或传入的 alias"
         * }
         */
        EventDispatcher.Instance.TriggerEvent("JPushAliasOperateResultEvent", result);
    }

    void OnGetRegistrationId(string result)
    {
        EventDispatcher.Instance.TriggerEvent("JPushGetRegistrationIdEvent", result);
    }

    #endregion  事件监听相关

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
