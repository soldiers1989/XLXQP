using System.Collections.Generic;
using UnityEngine.EventSystems;

namespace UnityEngine.UI
{
    /// <summary>
    /// ScrollRect 扩展
    /// </summary>
    public class ScrollRectExtend : UnityEngine.UI.ScrollRect
    {
        private List<float> _childrenPos = new List<float>();
        /// <summary>
        /// Left 标记
        /// </summary>
        [SerializeField]
        private Button m_LeftArrow = null;

        /// <summary>
        /// Right 标记
        /// </summary>
        [SerializeField]
        private Button m_RightArrow = null;

        /// <summary>
        /// 可见个数
        /// </summary>
        [SerializeField]
        private int m_DisplayItemCount = 5;
        /// <summary>
        /// 半遮挡数量
        /// </summary>
        private int m_HalfShowItemCount = 2;

        /// <summary>
        /// 中心点位置
        /// </summary>
        public int CenterIndex { get; private set; }

        public int MoveSpace = 1;
		public int RowCount = 0;

        /// <summary>
        /// 滑动响应灵敏度
        /// </summary>
        [SerializeField]
        private float m_SlideSensitivity = 0.2f;

        TweenPosition centerAnimation = null;
        bool isAnimation = false;

        protected override void Awake()
        {
            base.Awake();
            GridLayoutGroup grid;
            grid = content.GetComponent<GridLayoutGroup>();
            if (grid == null)
            {
                Debug.LogError("CenterOnChild: No GridLayoutGroup on the ScrollRect's content");
                return;
            }
			RowCount = m_DisplayItemCount * 2;

            //计算第一个子物体位于中心时的位置
            float childPosX = viewRect.rect.width * 0.5f - grid.cellSize.x * 0.5f - grid.spacing.x * 0.5f;
            _childrenPos.Add(childPosX);
            //缓存所有子物体位于中心时的位置
			for (int i = 0; i < RowCount - 1; i++)
            {
                childPosX -= grid.cellSize.x + grid.spacing.x;
                _childrenPos.Add(childPosX);
            }

            m_HalfShowItemCount = Mathf.CeilToInt(m_DisplayItemCount / 2);
            m_LeftArrow.onClick.AddListener(() => Move(-MoveSpace));
            m_RightArrow.onClick.AddListener(() => Move(MoveSpace));
            CenterOnChild(CenterIndex);
        }

        /// <summary>
        /// 拖拽持续时间
        /// </summary>
        private float m_DragDuration = 0f;
        /// <summary>
        /// Drag 开始
        /// </summary>
        /// <param name="eventData"></param>
        public override void OnBeginDrag(PointerEventData eventData)
        {
            base.OnBeginDrag(eventData);
            m_DragDuration = Time.time;
        }

        /// <summary>
        /// Drag结束
        /// </summary>
        /// <param name="eventData"></param>
        public override void OnEndDrag(PointerEventData eventData)
        {
            base.OnEndDrag(eventData);
            destinationX = FindClosestPos(content.localPosition.x);
            m_DragDuration = Time.time - m_DragDuration;

            bool canMove = false;
            int moveIndex = 0;

            Vector2 dragDelta = eventData.position - eventData.pressPosition;
            if (m_DragDuration < m_SlideSensitivity && Mathf.Abs(dragDelta.x) > 20)
            {
                // 快速滑动
                if (dragDelta.x > 0)
                {
                    if (CenterIndex - 1 >= 0)
                    {
                        canMove = true;
                        moveIndex = 1;
                    }
                    else
                    {
                        canMove = false;
                    }
                }
                else
                {
                    if (CenterIndex + 1 < _childrenPos.Count)
                    {
                        canMove = true;
                        moveIndex = -1;
                    }
                    else
                    {
                        canMove = false;
                    }
                }
            }
            else
            {
                // 缓慢滑动
                canMove = false;
            }

            if (canMove)
            {
                Move(moveIndex);
            }
            else
            {
                StartCenterAnimation();
            }
        }

        /// <summary>
        /// 开始中心动画
        /// </summary>
        void StartCenterAnimation()
        {
            centerAnimation = TweenPosition.Begin(content.gameObject, 0.4f, new Vector3(destinationX, 0, 0), false);
            centerAnimation.OnFinished -= StopCenterAnimation;
            centerAnimation.OnFinished += StopCenterAnimation;
            centerAnimation.enabled = true;
            centerAnimation.Play(true);
            isAnimation = true;
        }

        /// <summary>
        /// 停止中心动画
        /// </summary>
        void StopCenterAnimation()
        {
            centerAnimation.enabled = false;
            content.localPosition = centerAnimation.to;
            UpdateArrow(content.localPosition.x);
        }

        /// <summary>
        /// Drag 中
        /// </summary>
        /// <param name="eventData"></param>
        public override void OnDrag(PointerEventData eventData)
        {
            base.OnDrag(eventData);
            isAnimation = false;
        }

        /// <summary>
        /// 设置Content Anchored Position
        /// </summary>
        /// <param name="position"></param>
        protected override void SetContentAnchoredPosition(Vector2 position)
        {
            if (!isAnimation)
            {
                base.SetContentAnchoredPosition(position);
            }
            UpdateArrow(content.localPosition.x);
        }

        private float destinationX = 0f;

        /// <summary>
        /// 更新箭头是否显示
        /// </summary>
        /// <param name="currentPos"></param>
        private void UpdateArrow(float currentPos)
        {
            int childIndex = 0;
            float distance = Mathf.Infinity;
            for (int i = 0; i < _childrenPos.Count; i++)
            {
                float pos = _childrenPos[i];
                float d = Mathf.Abs(pos - currentPos);
                if (d < distance)
                {
                    distance = d;
                    childIndex = i;
                }
            }

            if (m_LeftArrow != null)
            {
                m_LeftArrow.gameObject.SetActive(childIndex < _childrenPos.Count - m_HalfShowItemCount - 1);
            }

            if (m_RightArrow != null)
            {
                m_RightArrow.gameObject.SetActive(childIndex > m_HalfShowItemCount);
            }
        }
        /// <summary>
        /// 查找停止pos
        /// </summary>
        /// <param name="currentPos"></param>
        /// <returns></returns>
        private float FindClosestPos(float currentPos)
        {
            float closest = 0;
            float distance = Mathf.Infinity;
            int childIndex = 0;
            for (int i = 0; i < _childrenPos.Count; i++)
            {
                float p = _childrenPos[i];
                float d = Mathf.Abs(p - currentPos);
                if (d < distance)
                {
                    distance = d;
                    closest = p;
                    childIndex = i;
                }
            }
            CenterIndex = childIndex;
            return closest;
        }

        /// <summary>
        /// 设置中心child
        /// </summary>
        /// <param name="index"></param>
        /// <param name="isAni"></param>
        public void CenterOnChild(int index, bool isAni = false)
        {
            if (_childrenPos.Count > 0)
            {
                if (index < m_HalfShowItemCount)
                {
                    index = m_HalfShowItemCount;
                }
                else if (index > _childrenPos.Count - m_HalfShowItemCount - 1)
                {
                    index = _childrenPos.Count - m_HalfShowItemCount - 1;
                }

                destinationX = _childrenPos[index];
                CenterIndex = index;

                if (isAni)
                {
                    StartCenterAnimation();
                }
                else
                {
                    Vector3 v = content.localPosition;
                    v.x = destinationX;
                    content.localPosition = v;
                    UpdateArrow(content.localPosition.x);
                }
            }
            else
            {
                CenterIndex = index;
            }
        }

        /// <summary>
        /// 移动
        /// </summary>
        /// <param name="moveSpace">左移动 负数， 右移动 正数</param>
        public void Move(int moveSpace)
        {
            CenterOnChild(CenterIndex - moveSpace, true);
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
}