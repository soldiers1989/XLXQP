local Time = CS.UnityEngine.Time

-- 小红点标记 (客服 推广 公告)
local mGMRed, mAgencyRed = nil

--官网 复制 分享
local mShareNode = nil;
local window_OfficialWebsite = nil;
local button_officialWebsite_Close = nil;
local text_officialWebsite_Url = nil;
local button_officialWebsite_Copy = nil;

local mGameContentDisableParent = nil           -- 子游戏隐藏父节点
local mGameContentEnableParent = nil            -- 子游戏显示父节点
local mGameScrollRect = nil
local mGameIconTable = {}                       -- 子游戏节点
local mGameDragonBonesAni = {}                  -- 动画子节点
local mGameHotPositions = {}                    -- 火热标签坐标
local mHotAnimation = nil
local mNewAnimation = nil

local mMasterInfo = {}                          -- 主角数据

local mActivityTable = {}                       -- 活动页面table(1绑定 2公告)
local mActivityScrollPage = nil

--region 暂时不用管系列

-- 自动刷新活动区域
local mActivityCD = 5
local mActivityPassTime = 0
local mActivityMaxPage = 4                      -- 当前功能总共4个
local mActivityForward = true
local mCurrentShowPage = 0


local mShopAnimation = nil                      -- 商城按钮动画
local btnPre = nil
local btnNext = nil

--=================官网复制分享 Start ===================
--打开官网
function OpenWindowOfficialWebsite()
    window_OfficialWebsite.transform:Find("Text_Url"):GetComponent("Text").text = data.PublicConfig.URL_OfficialWebsite;
    mShareNode:SetActive(true);
    window_OfficialWebsite:SetActive(true);
end

--关闭官网
function CloseWindowOfficialWebsite()
    mShareNode:SetActive(false);
    window_OfficialWebsite:SetActive(false);
end

--复制官网
function OfficialWebsiteCopy()
    local urlString = data.PublicConfig.URL_OfficialWebsite;
    local currentPlatform = CS.Utility.GetCurrentPlatform();
    PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, urlString)
	CS.BubblePrompt.Show(data.GetString("Text_CopyFinish"), "HallUI");
end

-- 打开分享选项
function OpenSahreOption( )
    local tNode= CS.WindowManager.Instance:FindWindowNodeByName("ShareUI")
    if tNode == nil then
        CS.WindowManager.Instance:OpenWindow("ShareUI")
    end
end

-- 复制并分享官网
function ShareOfficialNetwork()
    NetMsgHandler.Send_CS_HALL_SHARE_URL()
end

--打开链接
function GoToOfficialWebsite()
    local url = data.PublicConfig.URL_OfficialWebsite
    local currentPlatform = CS.Utility.GetCurrentPlatform()
    local openURL = "http://"..url
    if currentPlatform == 3 then
        --ios 平台
        CS.UnityEngine.Application.OpenURL(openURL)
    elseif currentPlatform == 2 then
        --android 平台
        CS.Utility.OpenURL(openURL)
    else
        --window
        CS.Utility.OpenURL(openURL)
    end
end

--=================官网复制分享 End ===================

-- 提现功能
function OnBtnCashClick()
    if CS.WindowManager.Instance:FindWindowNodeByName("UIPutForward")==nil then
        CS.WindowManager.Instance:OpenWindow("UIPutForward")
    end
end

--代理  跳转到代理界面 
function OnBtnAgencyClick()
    CS.WindowManager.Instance:OpenWindow("AgencyUI")
    if GameData.AgencyInfo.RedFlag then
        local tFormatTime = GetTimeToTable(os.time())
        CS.UnityEngine.PlayerPrefs.SetInt("Agency_Red_Time_Day", tFormatTime.day)
    end
    GameData.AgencyInfo.RedFlag = false
    GameObjectSetActive(mAgencyRed, GameData.AgencyInfo.RedFlag)
end

-- 推广员小红点标签读取
function AgencyRedFlagLoad()
    local tRedDayFlag = CS.UnityEngine.PlayerPrefs.GetInt("Agency_Red_Time_Day", 0)
    local tFormatTime = GetTimeToTable(os.time())
    if tRedDayFlag ~= tFormatTime.day then
        GameData.AgencyInfo.RedFlag = true
    else
        GameData.AgencyInfo.RedFlag = false
    end
end

--推送新的公告 红点显示
function NoticeNewRed()
    print("变更红点提示")
    if GameData.kefuIsRed == 1 or GameData.NoticeRed == 1 or GameData.MailRed == 1 then
        mGMRed:SetActive(true)
    else
        mGMRed:SetActive(false)
    end
end

--客服中心 服务器发送消息给玩家
function ServerSendInfo()
    if GameData.KFZX.ServerIsSendToPlayer==true then
        HandlerUpdateKFZXRed(1)
    else
        HandlerUpdateKFZXRed(0)
    end
end

--endregion

-- 请求选中游戏配置
function SendRoomTypeInfp(roomType)
    print("=====选择的游戏:", roomType)
    -- 随机播放音效
    local musicidIndex = math.random(4)
    local musicid = "OpenRoomList"..musicidIndex
    MusicMgr:PlaySoundEffect(musicid)

    if roomType == ROOM_TYPE.SSC then
        HandleRoomTypeChangedToRoomList(roomType)
    else
    NetMsgHandler.Send_CS_RoomListRoommTypeInfo(RoomTypeIndex[roomType])
    end
end

-- 进入选中大厅
function EnterSelectedRoom(roomType)
    GameData.HallData.SelectType = HALL_ROOM_TYPE[roomType]
    HandleRoomTypeChanged(GameData.HallData.SelectType)
end

-- 房间类型改变刷新
function HandleRoomTypeChanged(roomType)
    if roomType == ROOM_TYPE.None then
        -- 大厅中心
    elseif roomType == ROOM_TYPE.BRJH or roomType == ROOM_TYPE.LHDRoom or roomType == ROOM_TYPE.BJLRoom then
        -- 百人金花 龙虎斗 百家乐
        HandleRoomTypeChangedToBaiRenTing(roomType)
    else
        -- 其他多人房间
        HandleRoomTypeChangedToRoomList(roomType)
    end
end

-- 向服务器请求数据
function RequestRoomListData()
    local currentRoomType = GameData.RoomInfo.RoomList_Type;
    if currentRoomType == ROOM_TYPE.MenJi then
        NetMsgHandler.Send_CS_JH_ZuJuRoomList();
        NetMsgHandler.Send_CS_JH_MenJiRoomOnlineCount(1, 2, 3, 4);
    elseif currentRoomType == ROOM_TYPE.PiPeiNN then
        NetMsgHandler.Send_CS_NNRoom_RoomList();
        Send_CS_NNPP_Room_OnLine();
    elseif currentRoomType == ROOM_TYPE.PPHongBao then
        NetMsgHandler.Send_CS_HB_Room_List();
        NetMsgHandler.Send_CS_PP_HongBaoRoomOnlineCount(1, 2, 3, 4);
    elseif currentRoomType == ROOM_TYPE.PiPeiTTZ then
        NetMsgHandler.Send_CS_TTZRoom_RoomList();
        NetMsgHandler.Send_CS_TTZPP_Room_OnLine();
    elseif currentRoomType == ROOM_TYPE.LuckyWheel then
        NetMsgHandler.Send_CS_JH_XYZPRoomList();
    elseif currentRoomType == ROOM_TYPE.BMWBENZ then
        NetMsgHandler.Send_CS_JH_BMBCRoomList();
    elseif currentRoomType == ROOM_TYPE.PiPeiPDK then
        NetMsgHandler.Send_CS_PDKPP_Room_OnLine();
    end
end
-- 百人厅游戏类型 TODO
function HandleRoomTypeChangedToBaiRenTing(roomType)
    -- 开启对应 百人游戏房间列表
    --CS.BubblePrompt.Show("请开启百人房间列表UI:".. roomType,"HallUI")
    --CS.MatchLoadingUI.Show();
    GameData.RoomInfo.RoomList_Type = roomType;
    local tempWindow = CS.WindowManager.Instance:FindWindowNodeByName("BRHallUI");
    if tempWindow ~= nil then
        GameObjectSetActive(tempWindow.WindowGameObject, true);
    else
        tempWindow = CS.WindowNodeInitParam("BRHallUI")
        tempWindow.NodeType = 0
        CS.WindowManager.Instance:OpenWindow(tempWindow);
    end
 end

 -- 多人厅房间 TODO
 function HandleRoomTypeChangedToRoomList(roomType)
     -- 开启对应 其他多人房间列表
     --CS.BubblePrompt.Show("请开启多人房间列表UI:".. roomType,"HallUI")
     --CS.MatchLoadingUI.Show();
     GameData.RoomInfo.RoomList_Type = roomType;
     local tempWindow = CS.WindowManager.Instance:FindWindowNodeByName("DZHallUI");
     if tempWindow ~= nil then
         GameObjectSetActive(tempWindow.WindowGameObject, true);
     else
         tempWindow = CS.WindowNodeInitParam("DZHallUI");
         tempWindow.NodeType = 0
         CS.WindowManager.Instance:OpenWindow(tempWindow);
     end
 end

-------------------------------------------------------------------------------
-------------------------------功能响应模块-------------------------------------
-- 响应商场按钮点击事件
function OnBtnShopClick()
    GameData.Exit_MoneyNotEnough = true
    CS.WindowManager.Instance:OpenWindow("UIExtract")
end

-- 邮件数据刷新处理小红点提示
function HandleUpdateUnHandleFlagEvent(eventArg)
    -- body
    if eventArg ~= nil then
        this.transform:Find('Canvas/Bottom/ButtonMail/ButtonMail/Flag').gameObject:SetActive(eventArg.ContainsUnHandle)
    end
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.CaiFuRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.CaiFuRankTime >= 60 then
        return true
    end
    return false
end

function OnBtnYuebaoClick()
    CS.WindowManager.Instance:OpenWindow("UIYuebao")
end

-- 响应排行榜按钮点击事件
function OnBtnRankClick()
    local initParam = CS.WindowNodeInitParam("UIRank")
    initParam.WindowData = GAME_RANK_TYPE.WEALTH
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(1) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.WEALTH)
    end
end

-- 响应设置按钮点击事件
function OnBtnGMClick()
    CS.WindowManager.Instance:OpenWindow("CustomerServiceUI")
    --强制性的关闭客服的红点
    GameData.kefuIsRed = 0
    NoticeNewRed()
    --发送给服务器进入到 客服中心页面
    NetMsgHandler.Send_CS_PlayerOpenUI()
end

-- 时时彩界面
function SSCBtnOnClick()
    local  _canEnter = true
    local  _config  = {}
    _config.EnterLimit = data.ShishicaiConfig.ENTER_LIMIT
    _config.OutLimit = data.PublicConfig.PLAYER_GOLD_ALERT
    local tGoldCount =  GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount)
    if _config ~= nil then
        if tGoldCount < _config.EnterLimit then
            _canEnter = false
            local boxData = CS.MessageBoxData()
            boxData.Title = "温馨提示"
            boxData.Content = string.format(data.GetString("JH_Enter_MJRoom_Tips"),lua_NumberToStyle1String(_config.EnterLimit),"")
            boxData.Style = 1
            boxData.OKButtonName = "确定"
            GameData.Exit_MoneyNotEnough = true;
            boxData.LuaCallBack = RoomList_GoldNotEnoughConfirmOnClick
            CS.MessageBoxUI.Show(boxData)
        elseif tGoldCount > _config.OutLimit then
            _canEnter = false
            local desc = string.format(data.GetString("JH_Enter_MJRoom_Tips2"),lua_NumberToStyle1String(_config.OutLimit))
            CS.BubblePrompt.Show(desc ,"HallUI")
        end
    end

    if _canEnter then
        NetMsgHandler.ProcessingLottery()
    end
end

-- 奔驰宝马界面
function BcbmButtonOnClick()
    NetMsgHandler.Send_CS_CarInfo()
end

-- 点击绑定按钮
function BindingButtonOnClick()
    HandleRegisterRewardUI(true)
end

-- 关闭绑定功能
function CloseBindingButton()
    GameObjectSetActive(mActivityTable[1].gameObject, false)
    mActivityForward = 3
    print("=====100000=====")
end

-- 等待开发
function WaitingfordevelopmentOnClick()
    CS.BubblePrompt.Show("敬请期待", "HallUI")
end

-------------------------------------------------------------------------------
-------------------------------角色详细信息模块----------------------------------
-- 更新角色信息
function UpdateRoleInfos(param)
    mMasterInfo.NameText.text = GameData.RoleInfo.AccountName
    mMasterInfo.RoleIDText.text = "ID:"..tostring(GameData.RoleInfo.AccountID)
    mMasterInfo.GoldText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))
    mMasterInfo.VIPText.text = tostring(GameData.RoleInfo.VipLevel)
    if not GameData.RoleInfo.IsBindAccount then
        GameObjectSetActive(mActivityTable[1].gameObject,true)
    else
        CloseBindingButton()
    end
end

-- 玩家头像变化
function NotifyHeadIconChange(icon)
    -- body
    this.transform:Find('Canvas/RoleInfo/RoleIcon'):GetComponent("Image"):ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.RoleInfo.AccountIcon))
end

-- 刷新主界面上的角色昵称
function HandleNotifyChangeAccountName()
    mMasterInfo.NameText.text = GameData.RoleInfo.AccountName
end

-- 响应 头像按钮点击事件
function HallUI_HeadIconOnClick()
    if not GameData.RoleInfo.IsBindAccount then
        HandleRegisterRewardUI(true)
    else
        local openParam = CS.WindowNodeInitParam("PersonalUI")
        openParam.WindowData = 0
        CS.WindowManager.Instance:OpenWindow(openParam)
    end
end

--=================OpenInstall SDK Start  ===================

-- 请求OpenInstallData
function ReqOpenInstallData()
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_TOURISTS, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKINVITE, '参数:请求OpenInstall数据')
end

-- 处理 自动绑定代理上线
function HandleAutoSend_CS_Invite_CodeByOpenInstall()
    if GameData.OpenInstallReferralsID ~= -1 and GameData.OpenInstallReferralsID ~= nil then
        if GameData.RoleInfo.InviteCode == 0 and GameData.AgencyInfo.IsAgent == 0 and GameData.OpenInstallReferralsID ~= GameData.RoleInfo.AccountID then
            if not GameData.RoleInfo.IsBindAccount then
                -- 非正式账号才能被绑定上级
                NetMsgHandler.Send_CS_Invite_Code(GameData.OpenInstallReferralsID)
                print('===1==OpenSDK 绑定邀请码 :', GameData.OpenInstallReferralsID, GameData.OpenInstallReferralsGameID, CS.AppDefine.GameID)
            end
            PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_TOURISTS, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_SDKCLEAR, '参数:反馈清理邀请码')
        else

        end
        print(string.format("===2==OpenSDK 邀请者:%d InviteCode:%d IsAgent:%d", GameData.OpenInstallReferralsID, GameData.RoleInfo.InviteCode, GameData.AgencyInfo.IsAgent))
        GameData.OpenInstallReferralsID = -1
    end
end

--=================OpenInstall SDK End  ===================

-- 处理大厅游戏类型显示布局
function GameTypeLayerDisplay()
    if GameData.RoleInfo.HallRoomTypeUpdateTime == 0 then
        HallRoomTypeUpdate()
        return
    end
    local NowTime = os.time()
    if NowTime - GameData.RoleInfo.HallRoomTypeUpdateTime >= data.PublicConfig.HallRoomTypeUpdateTime then
        HallRoomTypeUpdate()
        return
    end
end

-- 刷新大厅按钮布局
function HallRoomTypeUpdate()
    -- 游戏布局重置
    for Index = 2, 13, 1 do
        if mGameIconTable[Index] ~= nil then
            CS.Utility.ReSetTransform(mGameIconTable[Index],mGameContentDisableParent)
        end
    end
    mGameScrollRect.content = mGameContentEnableParent
    -- 子游戏合理布局
    local Count = #GameData.GameTypeDisplay
    for Index= 1, Count, 1 do
        local tIndex = GameData.GameTypeDisplay[Index].GameType
        local tNode = mGameIconTable[tIndex]
        if tNode ~= nil then
            CS.Utility.ReSetTransform(tNode,mGameContentEnableParent)
            UpdateGameHotFlag(GameData.GameTypeDisplay[Index].GameTypeLable, mGameHotPositions[tIndex])
        end
    end
    GameData.RoleInfo.HallRoomTypeUpdateTime = os.time()
end

-- 更新游戏火热程度
function UpdateGameHotFlag(hotFlag,hotPosition)
    lua_Transform_ClearChildren(hotPosition, true)
    local tAnimationNode = nil
    if hotFlag == 1 then
        -- 火爆
        tAnimationNode = CS.UnityEngine.Object.Instantiate(mNewAnimation)
    elseif hotFlag == 2 then
        -- NEW
        tAnimationNode = CS.UnityEngine.Object.Instantiate(mHotAnimation)
    else
        -- 其他
    end
    if tAnimationNode ~= nil then
        CS.Utility.ReSetTransform(tAnimationNode.transform, hotPosition)
        GameObjectSetActive(tAnimationNode.gameObject , true)
    end
end

function InitActivityInfo()
    mActivityScrollPage = this.transform:Find('Canvas/HorizontalScrollSnap'):GetComponent("ScrollPage")
    for i = 1, 4 do
        mActivityTable[i] = this.transform:Find('Canvas/HorizontalScrollSnap/Content/ActivityItem'.. i)
    end
    for i = 1, 4 do
        mActivityTable[i]:GetComponent("Button").onClick:AddListener( function () OnActivityClick(i) end )
    end
end

function OnActivityClick(index)
    print("=====活动点击:", index)
    if index == 1 then
        -- 绑定账号功能
        BindingButtonOnClick()
    elseif index == 2 then
        -- 余额宝
        CS.WindowManager.Instance:OpenWindow("UIYuebao")
    elseif index == 3 then
        -- 官网复制
        OfficialWebsiteCopy()
    elseif index == 4 then
        -- 推广无限代
        OnBtnAgencyClick()
    end
end

-- 自动刷新活动区域显示
function AutoRefreshActivity(deltaTime)
    if GameData.GameState ~= GAME_STATE.HALL then
        return
    end
    mActivityPassTime = mActivityPassTime + deltaTime
    if mActivityPassTime >= mActivityCD then
        mActivityPassTime = 0
        if mActivityForward then
            mCurrentShowPage = mActivityScrollPage.CurrentPageIndex + 1
            if mCurrentShowPage >= mActivityMaxPage then
                mActivityForward = false
                mCurrentShowPage = mActivityScrollPage.CurrentPageIndex - 1
            end
        else
            mCurrentShowPage = mActivityScrollPage.CurrentPageIndex - 1
            if mCurrentShowPage < 0 then
                mActivityForward = true
                mCurrentShowPage = 0
            end
        end
        mActivityScrollPage:ChangePage(mCurrentShowPage)
    end
end

function preHandler()
    mGameScrollRect.horizontalNormalizedPosition = 0;
    btnPre:SetActive(false);
    btnNext:SetActive(true);
end

function nextHandler()
    mGameScrollRect.horizontalNormalizedPosition = 1;
    btnPre:SetActive(true);
    btnNext:SetActive(false);
end

function onScrollHandler()
    if mGameScrollRect.horizontalNormalizedPosition == 1 then
        btnPre:SetActive(true);
        btnNext:SetActive(false);
    elseif mGameScrollRect.horizontalNormalizedPosition == 0 then
        btnPre:SetActive(false);
        btnNext:SetActive(true);
    end
end

function Awake()
    GameData.GameState = GAME_STATE.HALL
    AgencyRedFlagLoad()

--    btnPre = this.transform:Find("Canvas/ButtonPre").gameObject
--    btnNext = this.transform:Find("Canvas/ButtonNext").gameObject
--    btnPre:GetComponent("Button").onClick:AddListener(preHandler)
--    btnNext:GetComponent("Button").onClick:AddListener(nextHandler)
--    btnPre:SetActive(false);

    mMasterInfo.NameText = this.transform:Find('Canvas/RoleInfo/RoleName'):GetComponent("Text")
    mMasterInfo.RoleIDText = this.transform:Find('Canvas/RoleInfo/RoleID'):GetComponent("Text")
    mMasterInfo.GoldText = this.transform:Find('Canvas/RoleInfo/Gold/Number'):GetComponent("Text")
    mMasterInfo.VIPText = this.transform:Find('Canvas/RoleInfo/Vip/Value'):GetComponent("Text")

    --TUDOU  官网复制 分享
    mShareNode = this.transform:Find("Canvas/ShareNode").gameObject;
    window_OfficialWebsite = this.transform:Find("Canvas/ShareNode/Window_OfficialWebsite").gameObject;
    button_officialWebsite_Close = this.transform:Find("Canvas/ShareNode/Window_OfficialWebsite/Title/Button_Close"):GetComponent("Button");
    text_officialWebsite_Url = this.transform:Find("Canvas/ShareNode/Window_OfficialWebsite/Text_Url");
    button_officialWebsite_Copy = this.transform:Find("Canvas/ShareNode/Window_OfficialWebsite/Buttons/Button_Copy1"):GetComponent("Button");
    this.transform:Find("Canvas/ShareNode/Window_OfficialWebsite/Buttons/Button_Copy2"):GetComponent('Button').onClick:AddListener(ShareOfficialNetwork)
    mShareNode.gameObject:SetActive(false);
    window_OfficialWebsite.gameObject:SetActive(false);
    button_officialWebsite_Close.onClick:AddListener(function()
        CloseWindowOfficialWebsite();
    end)
    button_officialWebsite_Copy.onClick:AddListener(function()
        OfficialWebsiteCopy();
    end)
    text_officialWebsite_Url:GetComponent("Button").onClick:AddListener(function()
        GoToOfficialWebsite();
    end)

    mShopAnimation = this.transform:Find('Canvas/Bottom/BtnShop/shangcheng_ani'):GetComponent("UnityArmatureComponent")
    -- 玩家信息响应
    this.transform:Find('Canvas/RoleInfo/Gold'):GetComponent("Button").onClick:AddListener(OnBtnShopClick)
    this.transform:Find('Canvas/RoleInfo/RoleIcon'):GetComponent("Button").onClick:AddListener(HallUI_HeadIconOnClick)
    -- 底部区域功能区域按钮
    this.transform:Find('Canvas/Bottom/ButtonYuebao'):GetComponent("Button").onClick:AddListener(OnBtnYuebaoClick)
    this.transform:Find('Canvas/Bottom/BtnRank'):GetComponent("Button").onClick:AddListener(OnBtnRankClick)
    this.transform:Find('Canvas/Bottom/BtnShop'):GetComponent("Button").onClick:AddListener(OnBtnShopClick)
    this.transform:Find('Canvas/RoleInfo/BtnAgency'):GetComponent("Button").onClick:AddListener(OnBtnAgencyClick)
    this.transform:Find('Canvas/Bottom/BtnCash'):GetComponent('Button').onClick:AddListener(OnBtnCashClick)
    this.transform:Find('Canvas/Bottom/BtnGM'):GetComponent("Button").onClick:AddListener(OnBtnGMClick)
    this.transform:Find('Canvas/RoleInfo/ShareButton'):GetComponent('Button').onClick:AddListener(OpenWindowOfficialWebsite)

    -- 子游戏节点相关
    mGameScrollRect = this.transform:Find('Canvas/ScrollViewGame'):GetComponent("ScrollRectHall")
    mGameScrollRect.MoveSpace = 6;
    mGameContentDisableParent = this.transform:Find('Canvas/ScrollViewGame/Viewport/ContentDisable')
    mGameContentEnableParent = this.transform:Find('Canvas/ScrollViewGame/Viewport/ContentEnable')
    for posIndex = 2, 13, 1 do
        mGameIconTable[posIndex] = mGameContentEnableParent:Find('GameIcon_'..posIndex)
        if mGameIconTable[posIndex] ~= nil then
            mGameIconTable[posIndex]:GetComponent("Button").onClick:AddListener(function()
                SendRoomTypeInfp(HALL_ROOM_TYPE[posIndex])
            end)
            mGameHotPositions[posIndex] = mGameIconTable[posIndex]:Find('FlagPosition')
        end
    end

    mHotAnimation = this.transform:Find('Canvas/ScrollViewGame/Viewport/hot_ani')
    mNewAnimation = this.transform:Find('Canvas/ScrollViewGame/Viewport/new_ani')

    GameObjectSetActive(mHotAnimation.gameObject, false)
    GameObjectSetActive(mNewAnimation.gameObject, false)

    -- UI龙骨动画
    mGameDragonBonesAni[2] = mGameIconTable[2]:Find("hongheidazhan_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[3] = mGameIconTable[3]:Find("longhudou_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[4] = mGameIconTable[4]:Find("baijiale_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[5] = mGameIconTable[5]:Find("fengkuangsanzhang_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[6] = mGameIconTable[6]:Find("benchibaoma_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[7] = mGameIconTable[7]:Find("xingyunzhuangpan_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[8] = mGameIconTable[8]:Find("zhajinhua_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[9] = mGameIconTable[9]:Find("qiangzhuangniuniu_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[10] = mGameIconTable[10]:Find("hongbaojielong_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[11] = mGameIconTable[11]:Find("tuitongzi_ani"):GetComponent('UnityArmatureComponent')
    mGameDragonBonesAni[13] = mGameIconTable[13]:Find("paodekuai_ani"):GetComponent('UnityArmatureComponent')

    mAgencyRed = this.transform:Find('Canvas/RoleInfo/BtnAgency/Red').gameObject
    GameObjectSetActive(mAgencyRed, GameData.AgencyInfo.RedFlag)
    
    --新增加的红点 联系客服 公告
    mGMRed = this.transform:Find('Canvas/Bottom/BtnGM/Red').gameObject

    InitActivityInfo()

    if GameConfig.IsSpecial() == true then 
        this.transform:Find('Canvas/Notice').gameObject:SetActive(false)
        this.transform:Find('Canvas/NotifyButtons').gameObject:SetActive(false)
        this.transform:Find('Canvas/Bottom').gameObject:SetActive(false)
        this.transform:Find('Canvas/RoleInfo/RoleIcon/Vip').gameObject:SetActive(false)
        this.transform:Find('Canvas/RoleInfo/RoleIcon'):GetComponent("Button").enabled = false
    end
end

local mShopAnimationTime = 5                    -- 播放间隔
local mShopAnimationPlayTime = 0

--function AutoPlayShopAnimation()
--    if Time.time - mShopAnimationPlayTime > mShopAnimationTime then
--        mShopAnimation.animation:Play("newAnimation", 1)
--        mShopAnimationPlayTime = Time.time
--    end
--end

function RefreshWindowData(windowData)
    -- body
    if windowData ~= nil then
        -- 进入大厅需要请求OpenInstall 数据
        ReqOpenInstallData()
        UpdateRoleInfos(0)
        NotifyHeadIconChange(0)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHallUpdateEvent, nil)
        MusicMgr:PlayBackMusic("BG_HALL")
    end
end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyUpdateDiamondEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyUpdateRoomCardEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyUpdateChargeEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHistoryRoomJHZUJUEvent, UpdateRelationRoomList)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHeadIconChange, NotifyHeadIconChange)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyChangeAccountName, HandleNotifyChangeAccountName)

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZUJURoomListUpdateEvent, HandleNotifyZUJURoomListUpdateEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMenJiRoomOnlineEvent, HandleNotifyMenJiRoomOnlineEvent)
    --CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHongBaoRoomOnlineEvent, RefreshHongBaoRoomOnlineCount)
    --1009 服务器发送消息给玩家
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyKFZXSendInfo, ServerSendInfo)
    --增加 客服小红点
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateKFZXRed, NoticeNewRed)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyNoticeNew, NoticeNewRed)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMailNew, NoticeNewRed)
    -- 更新大厅布局
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyUpdateHallLayout, GameTypeLayerDisplay)
    -- 更新玩家绑定状态
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyUpdateIsBindAccount, CloseBindingButton)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyShareURL, OpenSahreOption)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifRoomListRoomTyleInfo, EnterSelectedRoom)
    HandleRoomTypeChanged(GameData.HallData.SelectType)
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyUpdateDiamondEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyUpdateRoomCardEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyUpdateChargeEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHistoryRoomJHZUJUEvent, UpdateRelationRoomList)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHeadIconChange, NotifyHeadIconChange)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyChangeAccountName, HandleNotifyChangeAccountName)
    --增加 客服中心未读的小红点
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateKFZXRed, HandlerUpdateKFZXRed)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZUJURoomListUpdateEvent, HandleNotifyZUJURoomListUpdateEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMenJiRoomOnlineEvent, HandleNotifyMenJiRoomOnlineEvent)
    --CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHongBaoRoomOnlineEvent, RefreshHongBaoRoomOnlineCount)
    
    --1008 服务器发送消息给玩家
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyKFZXSendInfo, ServerSendInfo)
    --1019 服务器 推送新的公告
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyNoticeNew, NoticeNewRed)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMailNew, NoticeNewRed)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyUpdateHallLayout, GameTypeLayerDisplay)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyUpdateIsBindAccount, CloseBindingButton)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyShareURL, OpenSahreOption)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifRoomListRoomTyleInfo, EnterSelectedRoom)
end

function Update()
--    AutoRefreshActivity(Time.deltaTime)
--    AutoPlayShopAnimation()
    HandleAutoSend_CS_Invite_CodeByOpenInstall()
end