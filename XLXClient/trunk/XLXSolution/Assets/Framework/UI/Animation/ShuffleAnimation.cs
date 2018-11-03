using UnityEngine;
using Common.Animation;

/// <summary>
/// 庄家洗牌动画
/// </summary>
[RequireComponent(typeof(AnimationControl))]
public class ShuffleAnimation : MonoBehaviour
{
    /// <summary>
    /// 洗牌时间间隔
    /// </summary>
    public float m_CardInterval = 0.03f;
    /// <summary>
    /// 扑克牌数量
    /// </summary>
    public int CardMax = 16;
    /// <summary>
    /// 上方显示时间
    /// </summary>
    public float shangDisPlayTime = 0.03f;
    /// <summary>
    /// 中间显示时间
    /// </summary>
    public float zhongDisplayTime = 0.03f;
    /// <summary>
    /// 扑克牌
    /// </summary>
    public GameObject m_OneGroupCard = null;
    /// <summary>
    /// 洗牌父节点
    /// </summary>
    public Transform m_ShuffleCardRoot = null;
    /// <summary>
    /// 飞牌时间
    /// </summary>
    public float flyCardTime = 0.05f;
    /// <summary>
    /// 飞牌组件
    /// </summary>
    public Transform m_FlyPokerCard = null;
    /// <summary>
    /// 飞牌组件父节点
    /// </summary>
    public Transform m_FlyPokerCardRoot = null;

    /// <summary>
    /// 高度间隔
    /// </summary>
    float SpaceY = 5;

    /// <summary>
    /// 荷官洗牌控制器
    /// </summary>
    AnimationControl m_AnimationControl = null;

    /// <summary>
    /// 初始化Left动画组件
    /// </summary>
    /// <param name="leftRoot"></param>
    /// <param name="index"></param>
    /// <param name="disappearOffsetTime"></param>
    void InitOneLeftAnimationPath(Transform leftRoot, int index, float disappearOffsetTime = 1f)
    {
        float startTime = m_CardInterval * index * 2;
        AnimationPath leftShangPath = new AnimationPath();
        leftShangPath.PathName = "left_shang_" + index;
        leftShangPath.HandleTransform = leftRoot.Find("Item_shang");
        leftShangPath.Frames.Add(new AnimationFrame(leftShangPath.HandleTransform) { Time = 0, Active = true });
        leftShangPath.Frames.Add(new AnimationFrame(leftShangPath.HandleTransform) { Time = startTime + shangDisPlayTime, Active = false });
        this.m_AnimationControl.AnimationPaths.Add(leftShangPath);

        AnimationPath leftZhongPath = new AnimationPath();
        leftZhongPath.PathName = "left_zhong_" + index;
        leftZhongPath.HandleTransform = leftRoot.Find("Item_zhong");
        leftZhongPath.Frames.Add(new AnimationFrame(leftZhongPath.HandleTransform) { Time = 0, Active = false });
        // 上消失，中出现
        leftZhongPath.Frames.Add(new AnimationFrame(leftZhongPath.HandleTransform) { Time = startTime + shangDisPlayTime, Active = true });
        leftZhongPath.Frames.Add(new AnimationFrame(leftZhongPath.HandleTransform) { Time = startTime + shangDisPlayTime + zhongDisplayTime, Active = false });
        this.m_AnimationControl.AnimationPaths.Add(leftZhongPath);

        AnimationPath leftXiaPath = new AnimationPath();
        leftXiaPath.PathName = "left_xia_" + index;
        leftXiaPath.HandleTransform = leftRoot.Find("Item_xia");
        leftXiaPath.Frames.Add(new AnimationFrame(leftXiaPath.HandleTransform) { Time = 0, Active = false });
        // 中消失，下出现
        leftXiaPath.Frames.Add(new AnimationFrame(leftXiaPath.HandleTransform) { Time = startTime + shangDisPlayTime + zhongDisplayTime, Active = true });
        // 下消失，飞牌开始      
        leftXiaPath.Frames.Add(new AnimationFrame(leftXiaPath.HandleTransform) { Time = disappearOffsetTime + flyCardTime * (CardMax - index) * 2, Active = false });
        this.m_AnimationControl.AnimationPaths.Add(leftXiaPath);
    }

    /// <summary>
    /// 初始化Right动画组件
    /// </summary>
    /// <param name="rightRoot"></param>
    /// <param name="index"></param>
    /// <param name="disappearOffsetTime"></param>
    void InitRightAnimationPath(Transform rightRoot, int index, float disappearOffsetTime = 1f)
    {
        float startTime = m_CardInterval * (index * 2 + 1);
        AnimationPath rightShangPath = new AnimationPath();
        rightShangPath.PathName = "right_shang_" + index;
        rightShangPath.HandleTransform = rightRoot.Find("Item_shang");
        rightShangPath.Frames.Add(new AnimationFrame(rightShangPath.HandleTransform) { Time = 0, Active = true });
        rightShangPath.Frames.Add(new AnimationFrame(rightShangPath.HandleTransform) { Time = startTime + shangDisPlayTime, Active = false });
        this.m_AnimationControl.AnimationPaths.Add(rightShangPath);

        AnimationPath rightZhongPath = new AnimationPath();
        rightZhongPath.PathName = "right_zhong_" + index;
        rightZhongPath.HandleTransform = rightRoot.Find("Item_zhong");
        rightZhongPath.Frames.Add(new AnimationFrame(rightZhongPath.HandleTransform) { Time = 0, Active = false });
        // 上消失，中出现
        rightZhongPath.Frames.Add(new AnimationFrame(rightZhongPath.HandleTransform) { Time = startTime + shangDisPlayTime, Active = true });
        rightZhongPath.Frames.Add(new AnimationFrame(rightZhongPath.HandleTransform) { Time = startTime + shangDisPlayTime + zhongDisplayTime, Active = false });
        this.m_AnimationControl.AnimationPaths.Add(rightZhongPath);

        AnimationPath rightXiaPath = new AnimationPath();
        rightXiaPath.PathName = "right_xia_" + index;
        rightXiaPath.HandleTransform = rightRoot.Find("Item_xia");
        rightXiaPath.Frames.Add(new AnimationFrame(rightXiaPath.HandleTransform) { Time = 0, Active = false });
        // 中消失，下出现
        rightXiaPath.Frames.Add(new AnimationFrame(rightXiaPath.HandleTransform) { Time = startTime + shangDisPlayTime + zhongDisplayTime, Active = true });
        // 下消失，飞牌开始
        rightXiaPath.Frames.Add(new AnimationFrame(rightXiaPath.HandleTransform) { Time = disappearOffsetTime + flyCardTime * ((CardMax - index) * 2 - 1), Active = false });
        this.m_AnimationControl.AnimationPaths.Add(rightXiaPath);
    }

    /// <summary>
    /// 初始化飞牌动画组件
    /// </summary>
    /// <param name="cardTrans"></param>
    /// <param name="index"></param>
    /// <param name="offsetTime"></param>
    void InitCardFlyAnimationPath(Transform cardTrans, int index, float offsetTime)
    {
        float startTime = offsetTime + flyCardTime * index;
        AnimationPath flyAniPath = new AnimationPath();
        flyAniPath.HandleTransform = cardTrans;
        flyAniPath.PathName = "fly_animation_" + index;
        Vector3 startScale = Vector3.one * 0.4f;
        Vector3 startPoint = new Vector3(0, -30 - index * SpaceY * 0.4f, 0);

        Vector3 endScale = Vector3.one * 1.2f;
        Vector3 endPoint = new Vector3(0, -400 + index * SpaceY, 0);

        flyAniPath.Frames.Add(new AnimationFrame() { Time = 0, Active = false, localScale = startScale, localPosition = startPoint });
        flyAniPath.Frames.Add(new AnimationFrame() { Time = startTime, Active = true, localScale = startScale, localPosition = startPoint });
        flyAniPath.Frames.Add(new AnimationFrame() { Time = startTime + flyCardTime, Active = true, localScale = endScale, localPosition = endPoint });
        this.m_AnimationControl.AnimationPaths.Add(flyAniPath);
    }

    protected void Awake()
    {
        if (m_OneGroupCard == null || m_ShuffleCardRoot == null || m_FlyPokerCard == null)
        {
            Debug.LogError("Some ui element was null in ShuffleAnimation script, please check it!");
            return;
        }

        this.m_AnimationControl = GetComponent<AnimationControl>();
        this.m_AnimationControl.AnimationName = "ShuffleAnimation";
        //this.m_AnimationControl.speed = 0.01f;
        this.m_AnimationControl.AniPlayStyle = AnimationControl.PlayStyle.Once;

        // 第二段 飞牌动画的偏移时间
        // 第一段动画总共时间：动画间隔 + 动画时长 + 0.1
        float offsetTime = m_CardInterval * CardMax * 2 + shangDisPlayTime + zhongDisplayTime + 0.1f;
        for (int index = 0; index < CardMax; index++)
        {
            GameObject go = Instantiate(m_OneGroupCard);
            go.name = string.Format("CardGroup ({0})", index + 1);
            Utility.ReSetTransform(go.transform, m_ShuffleCardRoot);
            go.transform.localPosition = new Vector3(0, index * SpaceY, 0);
            go.SetActive(true);
            InitOneLeftAnimationPath(go.transform.Find("LeftItem"), index, offsetTime);
            InitRightAnimationPath(go.transform.Find("RightItem"), index, offsetTime);
        }

        // 第二段动画，从A点飞到B点，缩放
        for (int index = 0; index < CardMax * 2; index++)
        {
            Transform cardTrans = Instantiate(m_FlyPokerCard);
            cardTrans.name = (index + 1).ToString();
            Utility.ReSetTransform(cardTrans, m_FlyPokerCardRoot);
            cardTrans.localPosition = new Vector3(0, index * SpaceY, 0);
            cardTrans.gameObject.SetActive(true);
            InitCardFlyAnimationPath(cardTrans, index, offsetTime);
        }

        this.m_AnimationControl.AnimationTime = offsetTime + (CardMax * 2 * flyCardTime) + 0.1f;
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