using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

/// <summary>
/// 浏览模式
/// </summary>
public enum FlipMode : int
{
    /// <summary>
    /// 无
    /// </summary>
    None = 0,
    /// <summary>
    /// 左侧开始
    /// </summary>
    Left = 1,

    /// <summary>
    /// 中间开始
    /// </summary>
    Middle = 2,
}

/// <summary>
/// 搓牌控制脚本
/// </summary>
[XLua.LuaCallCSharp]
public class PageCurl : MonoBehaviour, IBeginDragHandler, IEndDragHandler, IDragHandler
{
    /// <summary>
    /// 页签的根结点
    /// </summary>
    [SerializeField]
    RectTransform m_PagePlane = null;

    /// <summary>
    /// 裁剪平面
    /// </summary>
    [SerializeField]
    RectTransform m_ClippingPlane = null;

    /// <summary>
    /// 页1
    /// </summary>
    [SerializeField]
    RectTransform m_PageOne = null;

    /// <summary>
    /// 页2
    /// </summary>
    [SerializeField]
    RectTransform m_PageTwo = null;
    /// <summary>
    /// 
    /// </summary>
    [SerializeField]
    RectTransform m_Shadow = null;
    /// <summary>
    /// 
    /// </summary>
    [SerializeField]
    RectTransform m_RotateFlag1 = null;
    /// <summary>
    /// 
    /// </summary>
    [SerializeField]
    RectTransform m_RotateFlag2 = null;
    /// <summary>
    /// 
    /// </summary>
    [SerializeField]
    Image m_PageOneSprite = null;
    /// <summary>
    /// 
    /// </summary>
    [SerializeField]
    Image m_PageTwoSprite = null;
    /// <summary>
    /// 
    /// </summary>
    [SerializeField]
    GameObject m_ClipModeGo = null;
    /// <summary>
    /// 
    /// </summary>
    [SerializeField]
    Button m_RotateButton = null;
    /// <summary>
    /// 
    /// </summary>
    Vector3 spineBottom;
    /// <summary>
    /// 
    /// </summary>
    Vector3 edgeLeftBottom;

    bool isStarted = false;

    const float m_MinDistance = 0.01f;

    float m_Radius = 100f;

    public FlipMode FlipMode
    {
        get; private set;
    }

    /// <summary>
    /// for lua
    /// </summary>
    public int FlipModeValue
    {
        get { return (int)this.FlipMode; }
    }

    [SerializeField]
    bool isSpriteRotate = false;
    public bool IsSpriteRotated
    {
        get { return isSpriteRotate; }
        private set { isSpriteRotate = value; }
    }

    /// <summary>
    /// 当前拐角点
    /// </summary>
    public Vector3 MoveSpace;

    bool interactable = true;

    /// <summary>
    /// 是否已经开启状态
    /// </summary>
    public bool IsOpened { get; private set; }

    public bool CanHandle { get; private set; }

    private string m_Sprite2Name = string.Empty;

    public void ResetSprites(string sprite1Name, string sprite2Name)
    {
        m_PageOneSprite.ResetSpriteByName(sprite1Name);
        m_PageTwoSprite.ResetSpriteByName(sprite2Name);
        m_Sprite2Name = sprite2Name;
    }

    public void ResetPageCurl(float pageWidth, float pageHeight, bool spriteRotate = false, bool canHandle = false)
    {
        FlipMode = FlipMode.Middle;
        this.MoveSpace = new Vector3(0, m_MinDistance, 0);
        float max = Mathf.Max(pageHeight, pageWidth);
        m_Radius = Mathf.Sqrt(pageWidth * pageWidth + pageHeight * pageHeight) / 2;

        Vector2 planeSize = new Vector2(pageWidth, pageHeight);

        m_PagePlane.sizeDelta = planeSize;
        // 重置定位点坐标
        spineBottom = new Vector3(0, -pageHeight / 2, 0);
        edgeLeftBottom = new Vector3(-pageWidth / 2, -pageHeight / 2);

        ResetRectTransform(m_ClippingPlane, m_PagePlane, true, new Vector2(max * 2, max * 3));
        ResetRectTransform(m_PageOne, m_PagePlane, true, planeSize);
        ResetRectTransform(m_PageTwo, m_PagePlane, true, planeSize);
        ResetRectTransform(m_Shadow, m_PageTwo, true, new Vector2(pageWidth, max * 3));

        isStarted = false;
        interactable = false;
        IsOpened = false;
        CanHandle = canHandle;
        this.IsSpriteRotated = spriteRotate;
        lastDragSpace = Vector3.zero;
        Vector2 pivot = new Vector2(0.5f, 0.5f);
        Vector2 size = spriteRotate ? new Vector2(pageHeight, pageWidth) : new Vector2(pageWidth, pageHeight);
        Vector3 angle = spriteRotate ? new Vector3(0, 0, -90) : Vector3.zero;
        SetRectTransform(m_PageOneSprite.rectTransform, m_PagePlane, true, size, pivot, Vector3.zero, angle);
        SetRectTransform(m_PageTwoSprite.rectTransform, m_PagePlane, true, size, pivot, Vector3.zero, angle);

        m_PageOneSprite.transform.SetParent(m_PageOne, true);
        m_PageTwoSprite.transform.SetParent(m_PageTwo, true);
        m_ClipModeGo.SetActive(canHandle);
        m_RotateButton.gameObject.SetActive(canHandle);
        RefreshDirectionFlagByRotate(pageWidth);
        UpdatePage(this.MoveSpace, this.FlipMode);
    }
    /// <summary>
    /// 重置
    /// </summary>
    /// <param name="trans"></param>
    /// <param name="baseTrans"></param>
    /// <param name="active"></param>
    /// <param name="size"></param>
    void ResetRectTransform(RectTransform trans, RectTransform baseTrans, bool active, Vector2 size)
    {
        SetRectTransform(trans, baseTrans, active, size, new Vector2(0.5f, 0.5f), Vector3.zero, Vector3.zero);
    }

    /// <summary>
    /// 设置data
    /// </summary>
    /// <param name="trans"></param>
    /// <param name="baseTrans"></param>
    /// <param name="active"></param>
    /// <param name="size"></param>
    /// <param name="pivot"></param>
    /// <param name="localPoint"></param>
    /// <param name="angle"></param>
    void SetRectTransform(RectTransform trans, RectTransform baseTrans, bool active, Vector2 size, Vector2 pivot, Vector3 localPoint, Vector3 angle)
    {
        trans.SetParent(baseTrans, true);
        trans.gameObject.SetActive(active);
        trans.sizeDelta = size;
        trans.pivot = pivot;
        trans.localPosition = localPoint;
        trans.localEulerAngles = angle;
    }

    /// <summary>
    /// 选择页面上的按钮
    /// </summary>
    void RotateButton_OnClick()
    {
        RotatePage();
        NotifyPageChanged();
    }
    /// <summary>
    /// 选择页面
    /// </summary>
    public void RotatePage()
    {
        IsSpriteRotated = !IsSpriteRotated;
        RefreshDirectionFlagByRotate(m_PagePlane.sizeDelta.y);
        ResetPageCurl(m_PagePlane.sizeDelta.y, m_PagePlane.sizeDelta.x, IsSpriteRotated, CanHandle);
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="width"></param>
    public void RefreshDirectionFlagByRotate(float width)
    {
        m_RotateFlag1.gameObject.SetActive(IsSpriteRotated);
        m_RotateFlag2.gameObject.SetActive(!IsSpriteRotated);
    }

    Vector3 m_StartDragLocalPoint = Vector3.zero;

    /// <summary>
    /// 拖拽开始
    /// </summary>
    /// <param name="eventData"></param>
    public void OnBeginDrag(PointerEventData eventData)
    {
        if (IsOpened || !CanHandle)
            return;
        m_StartDragLocalPoint = ScreenToLocal(eventData) - lastDragSpace;
        if (isStarted)
        {
            interactable = true;
            return;
        }

        if (RectTransformUtility.RectangleContainsScreenPoint(m_PagePlane, eventData.position, eventData.pressEventCamera))
        {
            isStarted = true;
            m_LastMoveSpace = MoveSpace;
            m_LastUpdateTime = Time.realtimeSinceStartup;
        }
        else
        {
            isStarted = false;
        }
    }

    /// <summary>
    /// 拖拽结束
    /// </summary>
    /// <param name="eventData"></param>
    public void OnEndDrag(PointerEventData eventData)
    {
        if (CanHandle)
        {
            if (!interactable)
            {
                isStarted = false;
            }
            interactable = false;
        }
    }

    Vector3 m_LastMoveSpace;
    float m_LastUpdateTime;

    float m_NofityInterval = 0.2f;

    /// <summary>
    /// 刷新浏览
    /// </summary>
    /// <param name="movedSpace"></param>
    void RefreshFlipMode(Vector2 movedSpace)
    {
        if (movedSpace.magnitude > 10f)// 最小滑动10个像素才开始启动
        {
            float angle = CalcVector2Angle(movedSpace);
            if (angle < 40 || angle > 320)// 响应左下角点
            {
                interactable = true;
                FlipMode = FlipMode.Left;
            }
            else if (angle >= 40 && angle < 145)
            {
                interactable = true;
                FlipMode = FlipMode.Middle;
            }

            if (interactable)
            {
                m_ClipModeGo.SetActive(false);
                m_RotateButton.gameObject.SetActive(false);
            }
        }
    }

    Vector3 lastDragSpace = Vector3.zero;
    /// <summary>
    /// 拖拽中
    /// </summary>
    /// <param name="eventData"></param>
    public void OnDrag(PointerEventData eventData)
    {
        Vector3 m_CurrentDragPoint = ScreenToLocal(eventData);
        if (isStarted && CanHandle && !IsOpened && !interactable)
        {
            RefreshFlipMode(m_CurrentDragPoint - m_StartDragLocalPoint);
        }

        if (CanHandle && interactable && !IsOpened)
        {
            lastDragSpace = m_CurrentDragPoint - m_StartDragLocalPoint;
            switch (this.FlipMode)
            {
                case FlipMode.Left:
                    InternalUpdateLeftMode(edgeLeftBottom + lastDragSpace);
                    break;
                case FlipMode.Middle:
                default:
                    InternalUpdateMiddlePoint(spineBottom + lastDragSpace);
                    break;
            }

            if ((m_LastMoveSpace - MoveSpace).magnitude > 5 && (Time.realtimeSinceStartup - m_LastUpdateTime) > m_NofityInterval)
            {
                NotifyPageChanged();
            }
        }
    }

    /// <summary>
    /// 初始化中心点
    /// </summary>
    /// <param name="followPoint"></param>
    void InternalUpdateMiddlePoint(Vector3 followPoint)
    {
        const float angleMinLimit = 80;
        const float angleMaxLimit = 100;
        Vector3 moveSpace = followPoint - spineBottom;
        float angle = CalcVector2Angle(moveSpace);

        if (angle < angleMinLimit || angle > angleMaxLimit)
        {
            if (moveSpace.x > 0)
            {
                if (moveSpace.y > 0)
                {
                    moveSpace.x = moveSpace.y / Mathf.Tan(angleMinLimit * Mathf.Deg2Rad);
                }
                else
                {
                    moveSpace = Vector2.up * m_MinDistance;
                }
            }
            else if (moveSpace.x < 0)
            {
                if (moveSpace.y > 0)
                {
                    moveSpace.x = moveSpace.y / Mathf.Tan(angleMaxLimit * Mathf.Deg2Rad);
                }
                else
                {
                    moveSpace = Vector2.up * m_MinDistance;
                }
            }
            else
            {
                moveSpace = Vector2.up * m_MinDistance;
            }
        }
        this.UpdatePage(moveSpace, FlipMode.Middle);
        CaclVisibleRange();
    }

    /// <summary>
    /// 初始化Left点
    /// </summary>
    /// <param name="followPoint"></param>
    void InternalUpdateLeftMode(Vector3 followPoint)
    {
        const float angleMinLimit = 1;
        const float angleMaxLimit = 100;
        Vector3 moveSpace = followPoint - edgeLeftBottom;
        float angle = CalcVector2Angle(moveSpace);
        if (angle < angleMinLimit || angle > angleMaxLimit)
        {
            if (moveSpace.x > 0)
            {
                moveSpace.y = Mathf.Tan(angleMinLimit * Mathf.Deg2Rad) * moveSpace.x;
            }
            else if (moveSpace.x < 0)
            {
                if (moveSpace.y > 0)
                {
                    moveSpace.x = moveSpace.y / Mathf.Tan(angleMaxLimit * Mathf.Deg2Rad);
                }
                else
                {
                    moveSpace = Vector2.right * m_MinDistance;
                }
            }
            else
            {
                moveSpace = Vector2.right * m_MinDistance;
            }
        }

        this.UpdatePage(moveSpace, FlipMode.Left);
        CaclVisibleRange();
    }

    #region 更新不同的模式

    /// <summary>
    /// 更新页面
    /// </summary>
    /// <param name="moveSpace"></param>
    /// <param name="mode"></param>
    public void UpdatePage(Vector3 moveSpace, FlipMode mode)
    {
        this.MoveSpace = moveSpace;
        this.FlipMode = mode;
        if (IsOpened)
            return;
        switch (mode)
        {
            case FlipMode.Left:
                UpdateLeftMode(moveSpace);
                break;
            case FlipMode.Middle:
            default:
                UpdateMiddleMode(moveSpace);
                break;
        }
    }

    /// <summary>
    /// 更新坐标点，起始点
    /// </summary>
    /// <param name="moveSpace"></param>
    void UpdateMiddleMode(Vector3 moveSpace)
    {
        float angle = CalcVector2Angle(moveSpace);
        Vector3 clipingPlanePoint = spineBottom + moveSpace / 2;
        m_PageOne.SetParent(m_PagePlane, true);
        m_PageTwo.SetParent(m_PagePlane, true);
        m_Shadow.SetParent(m_ClippingPlane, true);

        m_Shadow.pivot = new Vector2(0, 0.5f);
        m_ClippingPlane.pivot = new Vector2(0, 0.5f);

        m_Shadow.localEulerAngles = new Vector3(0, 0, 0);
        m_Shadow.localPosition = new Vector3(0, 0, 0);

        m_ClippingPlane.eulerAngles = new Vector3(0, 0, angle);
        m_ClippingPlane.position = m_PagePlane.TransformPoint(clipingPlanePoint);

        m_PageTwo.pivot = new Vector2(0.5f, 0f);
        m_PageTwo.position = m_PagePlane.TransformPoint(spineBottom + moveSpace);
        m_PageTwo.eulerAngles = new Vector3(0, 0, angle * 2);

        m_PageTwo.SetParent(m_ClippingPlane, true);
        m_PageOne.SetParent(m_ClippingPlane, true);
        m_PageOne.SetAsFirstSibling();
        m_Shadow.SetParent(m_PageTwo, true);
    }

    /// <summary>
    /// 更新左侧点为起点模式
    /// </summary>
    /// <param name="moveSpace"></param>
    void UpdateLeftMode(Vector3 moveSpace)
    {
        float angle = CalcVector2Angle(moveSpace);
        Vector3 clipingPlanePoint = edgeLeftBottom + moveSpace / 2;
        m_PageOne.SetParent(m_PagePlane, true);
        m_PageTwo.SetParent(m_PagePlane, true);
        m_Shadow.SetParent(m_ClippingPlane, true);
        if (angle < 90)
        {
            m_ClippingPlane.pivot = new Vector2(0, 0.35f);
            m_Shadow.pivot = new Vector2(0, 0.35f);
        }
        else
        {
            m_ClippingPlane.pivot = new Vector2(0, 0.65f);
            m_Shadow.pivot = new Vector2(0, 0.65f);
        }

        m_Shadow.localEulerAngles = new Vector3(0, 0, 0);
        m_Shadow.localPosition = new Vector3(0, 0, 0);

        m_ClippingPlane.eulerAngles = new Vector3(0, 0, angle);
        m_ClippingPlane.position = m_PagePlane.TransformPoint(clipingPlanePoint);

        m_PageTwo.pivot = new Vector2(1f, 0f);
        m_PageTwo.position = m_PagePlane.TransformPoint(edgeLeftBottom + moveSpace);
        m_PageTwo.eulerAngles = new Vector3(0, 0, angle * 2);

        m_PageTwo.SetParent(m_ClippingPlane, true);
        m_PageOne.SetParent(m_ClippingPlane, true);
        m_PageOne.SetAsFirstSibling();
        m_Shadow.SetParent(m_PageTwo, true);
    }

    #endregion

    /// <summary>
    /// 屏幕坐标到本地坐标
    /// </summary>
    /// <param name="eventData"></param>
    /// <returns></returns>
    public Vector3 ScreenToLocal(PointerEventData eventData)
    {
        Vector2 local;
        RectTransformUtility.ScreenPointToLocalPointInRectangle(m_PagePlane, eventData.position, eventData.pressEventCamera, out local);
        return local;
    }

    /// <summary>
    /// 计算向量的角度 与 (1,0)向量的夹角
    /// </summary>
    /// <param name="v">向量</param>
    /// <returns>返回 [0,360)</returns>
    float CalcVector2Angle(Vector2 v)
    {
        float angle = Mathf.Atan2(v.y, v.x) * Mathf.Rad2Deg;
        return (angle + 360) % 360;
    }

    /// <summary>
    /// 开牌回调
    /// </summary>
    public event Action<object> OpenCardCallBack;

    /// <summary>
    /// 通知界面打开了
    /// </summary>
    public void OpenCard()
    {
        if (IsOpened)
            return;
        IsOpened = true;
        m_PageOneSprite.ResetSpriteByName(m_Sprite2Name);
        m_PageOne.SetParent(m_PagePlane, true);
        m_PageTwo.SetParent(m_PagePlane, true);
        m_PageTwo.gameObject.SetActive(false);
        m_ClippingPlane.gameObject.SetActive(false);
        m_ClipModeGo.SetActive(false);
        m_RotateButton.gameObject.SetActive(false);
    }

    /// <summary>
    /// 通知页面打开事件
    /// </summary>
    void NotifyOpenCard()
    {
        IsOpened = true;
        m_PageOneSprite.sprite = m_PageTwoSprite.sprite;
        m_PageOne.SetParent(m_PagePlane, true);
        m_PageTwo.SetParent(m_PagePlane, true);
        m_PageTwo.gameObject.SetActive(false);
        m_ClippingPlane.gameObject.SetActive(false);
        m_ClipModeGo.SetActive(false);
        m_RotateButton.gameObject.SetActive(false);
        if (OpenCardCallBack != null)
        {
            OpenCardCallBack(UserData);
        }
    }

    /// <summary>
    /// 可见区域裁决
    /// </summary>
    void CaclVisibleRange()
    {
        if (MoveSpace.magnitude > m_Radius * 1.2f)
        {
            NotifyOpenCard();
            return;
        }
    }

    /// <summary>
    /// 用户数据
    /// </summary>
    public object UserData { get; set; }

    /// <summary>
    /// 页面改变事件
    /// </summary>
    public event Action<object> PageChangedEvent;

    /// <summary>
    /// 通知页面改变事件
    /// </summary>
    void NotifyPageChanged()
    {
        if (PageChangedEvent != null)
        {
            PageChangedEvent(UserData);
        }
    }

    private void Awake()
    {
        IsSpriteRotated = true;
        IsOpened = false;
        ResetPageCurl(m_PagePlane.sizeDelta.x, m_PagePlane.sizeDelta.y, false);
        m_RotateButton.onClick.AddListener(RotateButton_OnClick);
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