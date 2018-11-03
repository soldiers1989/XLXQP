//***************************************************************
// 脚本名称：WindowManager
// 类创建人：
// 创建日期：2015.12
// 功能描述：管理窗体界面
//***************************************************************
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using Common.AssetSystem;

public enum BaseNodeType
{
    /// <summary>
    /// 登陆，大厅，游戏等ui用此等级
    /// </summary>
    Main = 0,

    /// <summary>
    /// 跑马灯专用
    /// </summary>
    AboveMain = 1,

    /// <summary>
    /// 普通的界面，如Hall UI，Game UI，商城UI等等
    /// </summary>
    Normal = 2,
    /// <summary>
    /// Normal 界面层之上的一层
    /// </summary>
    AboveNormal = 3,
    /// <summary>
    /// 界面浮出提示信息
    /// </summary>
    Tips = 4,
    /// <summary>
    /// 进度条界面
    /// </summary>
    Loading = 5,
    /// <summary>
    /// 错误提示界面，，如断网提示等
    /// </summary>
    Propmt = 6,
}

public class WindowManager : MonoBehaviour
{
    [Tooltip("是否跨场景销毁")]
    public bool makePersistent = true;
    public static bool matchIphoneX = true;
    #region 常量

    public static readonly Vector3 UIPositionDelta = new Vector3(100, 100, 0);

    /// <summary>
    /// 画布开始排序的序号
    /// </summary>
    public const int CanvasStartSortOrder = 5;
    /// <summary>
    /// UI 相机开始的层级
    /// </summary>
    public const int UICameraStartDepth = 10;

    public const string UIRootAsset = "[UIRoot]";

    public static void InitWindowManager()
    {
        if (m_Instance == null)
        {
            GameObject go = Resources.Load<GameObject>(UIRootAsset);
            GameObject uiroot = Instantiate(go);
            uiroot.name = UIRootAsset;
            Utility.ReSetTransform(uiroot.transform, null);
        }
    }

    #endregion

    #region 定义根节点

    // 所有的界面挂的根节点
    [SerializeField]
    Transform m_UIParentTransform = null;

    // 隐藏界面的挂结点
    [SerializeField]
    Transform m_HideNodeTransform = null;

    // 根节点信息
    WindowNode[] m_RootWindowNodes = null;

    [SerializeField]
    Transform m_UILightTransform = null;

    #endregion

    private int m_UILightCount = 0;

    public void AddUILight()
    {
        m_UILightCount++;
        if (m_UILightCount > 0)
        {
            if (m_UILightTransform != null)
            {
                m_UILightTransform.gameObject.SetActive(true);
            }
        }
    }

    public void RemoveUILight()
    {
        m_UILightCount--;
        if (m_UILightCount < 0)
        {
            Debug.LogError("UILightCount less than 0, please check it!");
            m_UILightCount = 0;
        }
        if (m_UILightCount == 0)
        {
            if (m_UILightTransform != null)
            {
                m_UILightTransform.gameObject.SetActive(false);
            }
        }
    }

    #region Manager Private Data

    /// <summary>
    /// 所有的窗体界面信息界面
    /// </summary>
    List<WindowNode> m_WindowNodeList = new List<WindowNode>();

    /// <summary>
    /// 缓存资源界面池
    /// </summary>
    WindowPool m_WindowPool = new WindowPool();

    #endregion

    private static WindowManager m_Instance = null;

    #region Engine Callbacks

    void Awake()
    {
        CheckInstance();
        Init();
    }

    void Start()
    {
        if (makePersistent)
            DontDestroyOnLoad(this.gameObject);
    }

    // this is called after Awake() OR after the script is recompiled (Recompile > Disable > Enable)
    void OnEnable()
    {
        CheckInstance();
    }

    bool CheckInstance()
    {
        if (m_Instance == null)
        {
            m_Instance = this;
        }
        else if (m_Instance != this)
        {
            Debug.LogWarning("There is already an instance of WindowManager created (" + m_Instance.name + "). Destroying new one.");
            Destroy(this.gameObject);
            return false;
        }
        return true;
    }

    #endregion

    public static WindowManager Instance
    {
        get
        {
            if (m_Instance == null)
            {
                Debug.LogError("The instance was null of WindowManager, When you get it instance, please check it!");
            }
            return m_Instance;
        }
    }

    #region Init Base Window Node

    public void Init()
    {
        int max = (int)BaseNodeType.Propmt;
        m_RootWindowNodes = new WindowNode[max + 1];
        for (int i = 0; i <= max; i++)
        {
            WindowNode node = new WindowNode((BaseNodeType)i);
            m_WindowNodeList.Add(node);
            m_RootWindowNodes[i] = node;
        }
    }

    #endregion

    #region OpenWindow
    /// <summary>
    /// 开启UI
    /// </summary>
    /// <param name="windowName"></param>
    /// <param name="nodeType"></param>
    /// <returns></returns>
    public WindowNode OpenWindow(string windowName, BaseNodeType nodeType = BaseNodeType.Normal, bool matchIphoneX = true)
    {
        return OpenWindow(new WindowNodeInitParam(windowName, matchIphoneX) { NodeType = nodeType });
    }

    /// <summary>
    /// 开启UI
    /// </summary>
    /// <param name="windowName"></param>
    /// <param name="parentNode"></param>
    /// <returns></returns>
    public WindowNode OpenWindow(string windowName, WindowNode parentNode,bool matchIphoneX = true)
    {
        return OpenWindow(new WindowNodeInitParam(windowName, matchIphoneX) { ParentNode = parentNode });
    }
    /// <summary>
    /// 开启UI
    /// </summary>
    /// <param name="initParam"></param>
    /// <returns></returns>
    public WindowNode OpenWindow(WindowNodeInitParam initParam)
    {
        if (initParam == null)
            return null;
        if (initParam.ParentNode == null)
        {
            initParam.ParentNode = GetBaseWindowNodeByNodeType(initParam.NodeType);
        }
        WindowNode windowNode = new WindowNode(initParam);
        windowNode.ParentWindow = initParam.ParentNode;
        SetWindowNodeInfo(windowNode, initParam.NearNode, initParam.NearNodeIsPreNode);
        ResetAllWindowIndex();
        // 统计SDK
        EventDispatcher.Instance.TriggerEvent("OpenWindowEvent", initParam.WindowName);
        return windowNode;
    }
    /// <summary>
    /// 重置UI的WindowIndex
    /// </summary>
    void ResetAllWindowIndex()
    {
        for (int i = 0; i < m_WindowNodeList.Count; i++)
        {
            m_WindowNodeList[i].WindowIndex = i;
        }
    }

    /// <summary>
    /// 设置UI节点数据
    /// </summary>
    /// <param name="windowNode"></param>
    /// <param name="nearNode"></param>
    /// <param name="nearNodeIsPreNode"></param>
    void SetWindowNodeInfo(WindowNode windowNode, WindowNode nearNode, bool nearNodeIsPreNode)
    {
        WindowNode preNearNode = null;
        // 附近节点为空或者父节点不包括此附近节点
        if (nearNode == null || !windowNode.ParentWindow.ChildWindows.Contains(nearNode))
        {
            preNearNode = windowNode.ParentWindow.ChildWindows.Count == 0 ? windowNode.ParentWindow : windowNode.ParentWindow.ChildWindows[windowNode.ParentWindow.ChildWindows.Count - 1];
            while (preNearNode.ChildWindows.Count > 0)
            {
                preNearNode = preNearNode.ChildWindows[preNearNode.ChildWindows.Count - 1];
            }
            windowNode.ParentWindow.ChildWindows.Add(windowNode);
        }
        else
        {
            int index = windowNode.ParentWindow.ChildWindows.IndexOf(nearNode);
            if (!nearNodeIsPreNode)// 新节点在 靠近节点的后面
            {
                preNearNode = nearNode;
                index += 1;
            }
            else // 新的节点在靠近节点的前面
            {
                preNearNode = index == 0 ? windowNode.ParentWindow : windowNode.ParentWindow.ChildWindows[index - 1];
            }

            while (preNearNode.ChildWindows.Count > 0)
            {
                preNearNode = preNearNode.ChildWindows[preNearNode.ChildWindows.Count - 1];
            }
            windowNode.ParentWindow.ChildWindows.Insert(index, windowNode);
        }
        m_WindowNodeList.Insert(m_WindowNodeList.IndexOf(preNearNode) + 1, windowNode);
        SetWindowNodeGameObject(windowNode);
    }

    /// <summary>
    /// 获取WindowNode
    /// </summary>
    /// <param name="nodeType"></param>
    /// <returns></returns>
    WindowNode GetBaseWindowNodeByNodeType(BaseNodeType nodeType)
    {
        int value = (int)nodeType;
        if (value < m_RootWindowNodes.Length && value > -1)
            return m_RootWindowNodes[value];
        else
            return null;
    }

    /// <summary>
    /// 设置WindowNode数据
    /// </summary>
    /// <param name="windowNode"></param>
    void SetWindowNodeGameObject(WindowNode windowNode)
    {
        GameObject poolGameObject = m_WindowPool.GetWindowGameObject(windowNode.WindowName);
        if (poolGameObject != null)
        {
            SetWindowNodeGameObject(windowNode, poolGameObject);
        }
        else
        {
            StartCoroutine(LoadWindowGameObjectByWindowNode(windowNode));
        }
    }
    /// <summary>
    /// 加载WindowNode
    /// 
    /// </summary>
    /// <param name="windowNode"></param>
    /// <returns></returns>
    IEnumerator LoadWindowGameObjectByWindowNode(WindowNode windowNode)
    {
        AssetBundleManager assetBundleManager = AssetBundleManager.Instance;
        if (assetBundleManager == null)
        {
            Debug.LogErrorFormat("Load window asset[{0}] error[AssetBundleManager is null when window been loading]. windowNode[ID:{1}] be clear!", windowNode.WindowAssetName, windowNode.WindowName);
            CloseWindow(windowNode.WindowName, false, false);
            yield break;
        }
        LoadAssetAsyncOperation operation = assetBundleManager.LoadAssetAsync<GameObject>(windowNode.WindowAssetName, false);
        if (operation != null && !operation.IsDone)
        {
            yield return operation;
        }
        if (m_WindowNodeList.Contains(windowNode))
        {
            if (operation != null && operation.IsDone)
            {
                UnityEngine.Object resource = operation.GetAsset<UnityEngine.Object>();
                if (resource != null)
                {
                    GameObject windowGameObject = Instantiate(resource) as GameObject;
                    if (windowGameObject != null)
                    {
                        SetWindowNodeGameObject(windowNode, windowGameObject);
                    }
                    else
                    {
                        Debug.LogErrorFormat("Load window asset[{0}] error[Asset was not a gameObject]. windowNode[ID:{1}] be clear!", windowNode.WindowAssetName, windowNode.WindowName);
                        CloseWindow(windowNode.WindowName, false, false);
                    }
                }
                else
                {
                    Debug.LogErrorFormat("Load window asset[{0}] error[Asset was null]. windowNode[ID:{1}] be clear!", windowNode.WindowAssetName, windowNode.WindowName);
                    CloseWindow(windowNode.WindowName, false, false);
                }
            }
            else
            {
                Debug.LogErrorFormat("Load window asset[{0}] error. windowNode[ID:{1}] be clear!", windowNode.WindowAssetName, windowNode.WindowName);
                CloseWindow(windowNode.WindowName, false, false);
            }
        }
        else
        {
            // 在加载的过程中，本窗体已经被删除掉了
        }
    }

    /// <summary>
    /// 设置WindowNode父节点
    /// </summary>
    /// <param name="windowNode"></param>
    /// <param name="windowGameObject"></param>
    private void SetWindowNodeGameObject(WindowNode windowNode, GameObject windowGameObject)
    {
        Transform windowTransform = windowGameObject.transform;
        windowTransform.SetParent(m_UIParentTransform, false);
        //windowTransform.name = windowNode.WindowName;
        windowTransform.name = windowNode.WindowAssetName;
        windowNode.WindowGameObject = windowGameObject;
        //SetTransformSiblingIndex(windowNode, windowTransform);
        windowNode.WindowMonoBehaviour = windowTransform.GetComponent<WindowBase>();
        windowNode.ShowWindow();
    }

    /// <summary>
    /// 设置
    /// </summary>
    /// <param name="windowNode"></param>
    /// <param name="transform"></param>
    void SetTransformSiblingIndex(WindowNode windowNode, Transform transform)
    {
        int index = 0;
        for (int i = 0; i < m_WindowNodeList.Count; i++)
        {
            if (m_WindowNodeList[i].IsRootNode)
                continue;
            if (m_WindowNodeList[i] == windowNode)
            {
                break;
            }
            index++;
        }
        transform.SetSiblingIndex(index);
    }

    #endregion

    #region FindWindowNode

    /// <summary>
    /// 通过名称查找WindowNode
    /// </summary>
    /// <param name="windowName">窗口名称</param>
    /// <returns>返回同名窗体列表中，最后一个窗体ID的WindowNode，如果未找到则返回Null</returns>
    public WindowNode FindWindowNodeByName(string windowName)
    {
        return m_WindowNodeList.Find(temp => temp.WindowName == windowName);
    }

    /// <summary>
    /// 泛型查找
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <returns></returns>
    public T FindWindowBaseByType<T>() where T : WindowBase
    {
        WindowNode node = m_WindowNodeList.Find(temp => temp.WindowMonoBehaviour is T);

        if (node != null)
            return node.WindowMonoBehaviour as T;
        else
            return null;
    }

    #endregion

    #region CloseWindow
    /// <summary>
    /// 关闭UI
    /// </summary>
    /// <param name="windowName"></param>
    /// <param name="isReleaseToPool"></param>
    /// <param name="isRemoveParentNode"></param>
    public void CloseWindow(string windowName, bool isReleaseToPool, bool isRemoveParentNode = false)
    {
        // 统计SDK
        WindowNode findNode = m_WindowNodeList.Find(temp => temp.WindowName == windowName);
        if (findNode == null)
            return;
        if (isRemoveParentNode)
        {
            while (!findNode.ParentWindow.IsRootNode)// 循环找父节点
            {
                findNode = findNode.ParentWindow;
            }
        }
        RemoveWindowNode(findNode, isReleaseToPool);
        ResetAllWindowIndex();
        EventDispatcher.Instance.TriggerEvent("CloseWindowEvent", windowName);
    }

    /// <summary>
    /// 清理Window Node 信息
    /// </summary>
    /// <param name="windowNode">窗体节点信息</param>
    void RemoveWindowNode(WindowNode windowNode, bool isReleaseToPool)
    {
        for (int index = windowNode.ChildWindows.Count - 1; index >= 0; index--)
        {
            RemoveWindowNode(windowNode.ChildWindows[index], isReleaseToPool);
        }

        windowNode.CloseWindow();
        if (windowNode.WindowGameObject != null)
        {
            if (isReleaseToPool)
            {
                windowNode.WindowGameObject.transform.SetParent(m_HideNodeTransform, false);
                m_WindowPool.ReleaseGameObject(windowNode.WindowName, windowNode.WindowGameObject);
            }
            else
            {
                Destroy(windowNode.WindowGameObject);
            }
        }

        windowNode.ParentWindow.ChildWindows.Remove(windowNode);// 从父节点删除当前结点
        windowNode.ParentWindow = null;
        m_WindowNodeList.Remove(windowNode);
        windowNode.ChildWindows.Clear();
        windowNode.WindowData = null;
        windowNode.WindowGameObject = null;
        windowNode = null;
    }

    /// <summary>
    /// 关闭窗体
    /// </summary>
    /// <param name="windowNode">窗体节点信息</param>
    /// <param name="isRemoveParentNode">是否关闭父节点</param>
    public void CloseWindow(WindowNode windowNode, bool isReleaseToPool = true, bool isRemoveParentNode = false)
    {
        if (windowNode == null)
            return;
        CloseWindow(windowNode.WindowName, isReleaseToPool, isRemoveParentNode);
    }

    /// <summary>
    /// 清除掉所有打开的界面
    /// </summary>
    /// <param name="unCloseWindowNames">不关闭的窗体</param>
    public void CloseAllWindows(List<string> unCloseWindowNames = null)
    {
        for (int i = 0; i < m_RootWindowNodes.Length; i++)
        {
            for (int j = m_RootWindowNodes[i].ChildWindows.Count - 1; j >= 0; j--)
            {
                if (unCloseWindowNames != null && unCloseWindowNames.Contains(m_RootWindowNodes[i].ChildWindows[j].WindowName))
                {
                    continue;
                }
                RemoveWindowNode(m_RootWindowNodes[i].ChildWindows[j], false);
            }
        }
        ResetAllWindowIndex();
    }

    #endregion

    #region WindowPool

    public class WindowPool
    {
        public WindowPool()
        {
        }

        private Dictionary<string, GameObject> resourceDict = new Dictionary<string, GameObject>();

        public GameObject GetWindowGameObject(string windowName)
        {
            GameObject windowGameObject = null;
            if (resourceDict.ContainsKey(windowName))
            {
                windowGameObject = resourceDict[windowName];
                resourceDict.Remove(windowName);
            }
            return windowGameObject;
        }

        public bool ReleaseGameObject(string windowName, GameObject saveGameObject)
        {
            if (saveGameObject == null || string.IsNullOrEmpty(windowName)) return false;

            if (resourceDict.ContainsKey(windowName))
            {
                GameObject.Destroy(saveGameObject);
                return false;
            }
            else
            {
                resourceDict.Add(windowName, saveGameObject);
                return true;
            }
        }
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

/// <summary>
/// 窗体初始化参数
/// </summary>
public class WindowNodeInitParam
{
    /// <summary>
    /// 初始化
    /// </summary>
    /// <param name="windowName">窗体名称</param>
    public WindowNodeInitParam(string windowName, bool matchIphoneX = true)
    {
        this.WindowName = windowName;
        IsMatchIphoneX = matchIphoneX;
        string tmpAssetName = windowName;
        if (IsMatchIphoneX)
        {
            Vector2 screenSize = new Vector2(Screen.width, Screen.height);
            if ((screenSize.x >= 1125f && screenSize.y >= 2436f) || (screenSize.x >= 2436f && screenSize.y >= 1125f))
            {
                string _x = windowName.Substring(windowName.Length - 2, 2);
                if (_x != "_X")
                {
                    tmpAssetName += "_X";
                }
            }
        }

        this.WindowAssetName = tmpAssetName;
        NodeType = BaseNodeType.Normal;
        WindowData = null;
        LoadComplatedCallBack = null;
        ParentNode = null;
        NearNode = null;
        NearNodeIsPreNode = true;
    }

    

    /// <summary>
    /// 窗体名称
    /// </summary>
    public string WindowName { get; private set; }
    /// <summary>
    /// 窗体资源名称
    /// </summary>
    public string WindowAssetName { get; private set; }
    /// <summary>
    /// 所在的根节点类型
    /// </summary>
    public BaseNodeType NodeType { get; set; }
    /// <summary>
    /// 窗体数据
    /// </summary>
    public object WindowData { get; set; }
    /// <summary>
    /// 加载完成回调
    /// </summary>
    public System.Action<WindowNode> LoadComplatedCallBack { get; set; }
    /// <summary>
    /// 父节点
    /// </summary>
    public WindowNode ParentNode { get; set; }
    /// <summary>
    /// 靠近的节点
    /// </summary>
    public WindowNode NearNode { get; set; }
    /// <summary>
    /// 靠近的节点是否在当前结点之前
    /// </summary>
    public bool NearNodeIsPreNode { get; set; }
    /// <summary>
    /// 是否适配IphoneX分辨率(1125*2436)
    /// </summary>
    public bool IsMatchIphoneX { get; set; }
}
