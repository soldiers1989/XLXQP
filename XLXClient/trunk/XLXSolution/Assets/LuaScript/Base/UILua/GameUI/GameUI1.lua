local Time = CS.UnityEngine.Time

-- 菜单组件
local mReturnCaiDan = nil

-- PK模块组件
local mVSPK = nil
local mVSPKTable =
{
    PKPlayer1 = nil,
    PKPlayer2 = nil,
    PKVImage = nil,
    PKSImage = nil,
    Result1 = nil,
    Result2 = nil,
    PKPos =
    {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil,
        [5] = nil,
    },

    PKPosTargets =
    {
        [1] = nil,
        [2] = nil,
    }
}

-- 玩家组件数据
local PlayerItem =
{
    TransformRoot = nil,
    YQButton = nil,
    HeadIcon = nil,
    NameText = nil,
    HandleCD = nil,
    GoldInfo = nil,
    GoldText = nil,
    BetingInfo = nil,
    BetingText = nil,
    BankerPos = nil,
    PokerParent = nil,
    PokerPoints = { },
    PokerCards = { },
    KPImage = nil,
    QPImage = nil,
    JZImage = nil,
    GZImage = nil,
    ZBImage = nil,
    YQPImage = nil,
    BPSImage = nil,
    VSOKButtonGameObject = nil,
    WinText = nil,
    CardType = nil,
    CardTypeText = nil,
    CDTimeGameObject = nil,
    CDTimeText = nil,
}

-- 玩家UI元素集合
local mPlayersUIInfo = { }

-- 玩家下注模块组件
local mMasterXZInfo =
{
    -- 玩家看牌按钮组件
    KPButtonGameObject = nil,
    -- 下注模块组件
    XZButtonGameObject = nil,
    -- 自动下注组件
    AutoButtonGameObject = nil,
    JZButtonGameObject = nil,
    GZButtonGameObject = nil,

    -- 加注模块组件
    JZButtonInfo = nil,
    -- 加注按钮text
    JZButtonTexts =
    {
        [1] = nil,
        [2] = nil,
        [3] = nil,
        [4] = nil,
    },
    -- 玩家准备按钮组件
    ZBButtonGameObject = nil,
    -- 等待下一局开始
    WaitImageGameObject = nil,
    -- 庄家主键
    BankerImageTweenTransform = nil,

}

local CHIP_JOINTS =
{
    [1] = { JointPoint = nil, RangeX = { Min = - 100, Max = 100 }, RangeY = { Min = - 80, Max = 80 } },
    [2] = { JointPoint = nil, RangeX = { Min = - 100, Max = 100 }, RangeY = { Min = - 80, Max = 80 } },
    [3] = { JointPoint = nil, RangeX = { Min = - 100, Max = 100 }, RangeY = { Min = - 80, Max = 80 } },
    [4] = { JointPoint = nil, RangeX = { Min = - 100, Max = 100 }, RangeY = { Min = - 80, Max = 80 } },
    [5] = { JointPoint = nil, RangeX = { Min = - 100, Max = 100 }, RangeY = { Min = - 80, Max = 80 } },
    [6] = { JointPoint = nil, RangeX = { Min = - 100, Max = 100 }, RangeY = { Min = - 80, Max = 80 } },
}

-- 筹码起始点组件
local CHIP_START =
{
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
}

-- 筹码组件
local CHIP_RES =
{
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
}

-- 扑克牌发牌时挂接点
local mPokerCardPoints = { }

-- 房间基础信息(ID 下注总额 对战回合 底注下线 底注上线)
local mRoomInfo =
{
    RoomIDText = nil,
    BetAllValueText = nil,
    RoundTimesText = nil,
    BetMinText = nil,
    BetMaxText = nil,
}

-- 当前下注者CD信息
local mCurrentHandleCD = nil
local mISUpdateBetingCD = false
local mCDTimeText = nil
local mCDTimeValue = 0

-- 是否自动下注
local AutoXiaZhuState  = false
-- 庄家位置
local BankerPositionOld = 6

-- 弃牌音效随机值
local mQipaiSoundRandom = 0
local mQipaiSoundRandomFactor = 6
-- 跟注音效随机值
local mGenZhuSoundRandom = 0
local mGenZhuSoundRandomFactor = 6
-- 加注音效随机值
local mJiaZhuSoundRandom = 0
local mJiaZhuSoundRandomFactor = 4

-- 看牌音效随机值
local mKanPaiSoundRandom = 0
local mKanPaiSoundRandomFactor = 3

-- 比牌音效随机值
local mBipaiSoundRandom = 0
local mBipaiSoundRandomFactor = 4

-- 游戏房间数据详情 + 玩家数据详情
local mRoomData = { }
local mMasterData = { }

---------_________TUDOU_________---------
local window_Help = nil;
local button_Help = nil;
local button_Help_Close = nil;
local mask_Help = nil;

local QPButton_1 = nil
local QPButton_2 = nil
local KPButton = nil
--帮助页面相关
function DoHelp()
    window_Help = this.transform:Find("Canvas/Window_Help");
    button_Help = this.transform:Find("Canvas/CaidanButton/ReturnCaiDan/HelpButton");
    button_Help_Close = this.transform:Find("Canvas/Window_Help/Title/Button_Close");
    mask_Help = this.transform:Find("Canvas/Mask_Help");
    button_Help:GetComponent("Button").onClick:AddListener(Window_Help_Open);
    button_Help_Close:GetComponent("Button").onClick:AddListener(Window_Help_Close);
    mask_Help:GetComponent("Button").onClick:AddListener(Window_Help_Close);
end

--打开帮助界面
function Window_Help_Open()
    SetCaidanShow(false)
    window_Help.gameObject:SetActive(true);
    mask_Help.gameObject:SetActive(true);
end

--关闭帮助界面
function Window_Help_Close()
    window_Help.gameObject:SetActive(false);
    mask_Help.gameObject:SetActive(false);
end
---------_________TUDOU_________---------

-- 初始化UI元素
function InitUIElement()
    mRoomData = GameData.RoomInfo.CurrentRoom
    mMasterData = mRoomData.JHPlayers[JHZUJU_ROOM_PLAYER_MAX]
    
    mReturnCaiDan = this.transform:Find('Canvas/CaidanButton/ReturnCaiDan').gameObject
    -- PK模块
    mVSPK = this.transform:Find('Canvas/VSPK').gameObject
    mVSPKTable.PKPlayer1 = this.transform:Find('Canvas/VSPK/PKPlayer1')
    mVSPKTable.PKPlayer2 = this.transform:Find('Canvas/VSPK/PKPlayer2')
    mVSPKTable.PKPlayer2 = this.transform:Find('Canvas/VSPK/PKPlayer2')
    mVSPKTable.PKVImage = this.transform:Find('Canvas/VSPK/PKVImage')
    mVSPKTable.PKSImage = this.transform:Find('Canvas/VSPK/PKSImage')
    mVSPKTable.Result1 = this.transform:Find('Canvas/VSPK/Result1')
    mVSPKTable.Result2 = this.transform:Find('Canvas/VSPK/Result2')
    for index = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        mVSPKTable.PKPos[index] = this.transform:Find('Canvas/VSPK/PKPos' .. index)
    end
    mVSPKTable.PKPosTargets[1] = this.transform:Find('Canvas/VSPK/PKPosTarget1')
    mVSPKTable.PKPosTargets[2] = this.transform:Find('Canvas/VSPK/PKPosTarget2')

    InitPlayerUIElement()
    -- 玩家下注模块
    this.transform:Find('Canvas/MasterInfo').gameObject:SetActive(true)
    mMasterXZInfo.KPButtonGameObject = this.transform:Find('Canvas/MasterInfo/KPButton').gameObject
    mMasterXZInfo.XZButtonGameObject = this.transform:Find('Canvas/MasterInfo/XZButtons/').gameObject
    mMasterXZInfo.AutoButtonGameObject = this.transform:Find('Canvas/MasterInfo/AutoButtons').gameObject
    mMasterXZInfo.JZButtonGameObject = this.transform:Find('Canvas/MasterInfo/XZButtons/JZButton').gameObject
    mMasterXZInfo.GZButtonGameObject = this.transform:Find('Canvas/MasterInfo/XZButtons/GZButton').gameObject

    mMasterXZInfo.JZButtonInfo = this.transform:Find('Canvas/MasterInfo/JZInfo').gameObject
    mMasterXZInfo.ZBButtonGameObject = this.transform:Find('Canvas/MasterInfo/ZBButton').gameObject

    for index = 1, 4, 1 do
        mMasterXZInfo.JZButtonTexts[index] = this.transform:Find(string.format('Canvas/MasterInfo/JZInfo/JZButton%d/Text', index)):GetComponent('Text')
    end

    mMasterXZInfo.WaitImageGameObject = this.transform:Find('Canvas/MasterInfo/WaitImage').gameObject
    BankerImageTweenTransform = this.transform:Find('Canvas/Players/BankerImage'):GetComponent('TweenTransform')
    WaitNextGameStartShow(false)

    -- 筹码挂接组件
    local chipsJointRoot = this.transform:Find('Canvas/AllBetChips/ChipPoints')
    for index = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        local rectTrans = chipsJointRoot:Find('HandlePoint' .. index):GetComponent("RectTransform")
        CHIP_START[index] = rectTrans
        CHIP_JOINTS[index].JointPoint = this.transform:Find('Canvas/AllBetChips/ChipJoints/HandleJoint_' .. index):GetComponent("RectTransform")
    end

    for index = 1, 5, 1 do
        CHIP_RES[index] = this.transform:Find('Canvas/AllBetChips/ChipRes/ChipItem_' .. index)
    end

    -- 扑克牌挂接点
    for index = 1, 18, 1 do
        mPokerCardPoints[index] = nil
        mPokerCardPoints[index] = this.transform:Find('Canvas/Players/PokerCardPoints/CardPoint_' .. index)
    end
    -- 房间信息
    mRoomInfo.RoomIDText = this.transform:Find('Canvas/RoomInfo/RoomID/Text'):GetComponent('Text')
    mRoomInfo.BetAllValueText = this.transform:Find('Canvas/RoomInfo/BetAllValue/Text'):GetComponent('Text')
    mRoomInfo.RoundTimesText = this.transform:Find('Canvas/RoomInfo/RoundTimes/Text'):GetComponent('Text')
    mRoomInfo.BetMinText = this.transform:Find('Canvas/RoomInfo/BetMin/Text'):GetComponent('Text')
    mRoomInfo.BetMaxText = this.transform:Find('Canvas/RoomInfo/BetMax/Text'):GetComponent('Text')

    QPButton_1 = this.transform:Find('Canvas/MasterInfo/XZButtons/QPButton'):GetComponent('Button')
    QPButton_2 = this.transform:Find('Canvas/MasterInfo/AutoButtons/QPButton'):GetComponent('Button')
    KPButton = this.transform:Find('Canvas/MasterInfo/KPButton'):GetComponent('Button')

    --this.transform:Find('Canvas/LotteryButton'):GetComponent("Button").onClick:AddListener(LotteryButtonOnClick)

    if GameConfig.IsSpecial() == true then
        this.transform:Find('Canvas/StoreButton').gameObject:SetActive(false)
        --this.transform:Find('Canvas/LotteryButton').gameObject:SetActive(false)
        this.transform:Find('Canvas/Notice').gameObject:SetActive(false)
        this.transform:Find('Canvas/NotifyButtons').gameObject:SetActive(false)
    end
end

-- 时时彩界面
function LotteryButtonOnClick()
end

function InitPlayerUIElement()
    -- body
    local playerRoot = this.transform:Find('Canvas/Players')
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        local dataItem = lua_NewTable(PlayerItem)
        local childItem = playerRoot:Find('Player' .. position)
        mPlayersUIInfo[position] = dataItem
        dataItem.TransformRoot = childItem.gameObject
        dataItem.YQButton = childItem:Find('Head/YQButton')
        dataItem.HeadIcon = childItem:Find('Head/HeadIcon'):GetComponent('Image')
        dataItem.NameText = childItem:Find('Head/HeadIcon/NameText'):GetComponent('Text')
        dataItem.HandleCD = childItem:Find('Head/HeadIcon/HandleCD'):GetComponent('Image')
        dataItem.GoldInfo = childItem:Find('GoldInfo')
        dataItem.GoldText = childItem:Find('GoldInfo/GoldIcon/Text'):GetComponent('Text')
        dataItem.BetingInfo = childItem:Find('BetingInfo')
        dataItem.BetingText = childItem:Find('BetingInfo/Text'):GetComponent('Text')
        dataItem.BankerPos = childItem:Find('BankerPos')
        dataItem.PokerParent = childItem:Find('Pokers')
        dataItem.KPImage = childItem:Find('KPImage')
        dataItem.QPImage = childItem:Find('QPImage')
        dataItem.JZImage = childItem:Find('JZImage')
        dataItem.GZImage = childItem:Find('GZImage')
        dataItem.ZBImage = childItem:Find('ZBImage')
        dataItem.YQPImage = childItem:Find('YQPImage')
        dataItem.BPSImage = childItem:Find('BPSImage')
        dataItem.VSOKButtonGameObject =  this.transform:Find('Canvas/PKSelect/VSOKButton'.. position).gameObject
        dataItem.WinText = childItem:Find('WinText'):GetComponent('Text')
        dataItem.CardType = childItem:Find('CardType')
        dataItem.CardTypeText = childItem:Find('CardType/Text'):GetComponent('Text')
        dataItem.CDTimeGameObject = childItem:Find('CDTime').gameObject
        dataItem.CDTimeText = childItem:Find('CDTime/ValueText'):GetComponent('Text')
        
        -- 扑克牌挂接点
        for cardIndex = 1, 3, 1 do
            if dataItem.PokerPoints == nil then
                dataItem.PokerPoints = { }
                dataItem.PokerCards = { }
            end
            dataItem.PokerPoints[cardIndex] = nil
            dataItem.PokerCards[cardIndex] = nil
            dataItem.PokerPoints[cardIndex] = childItem:Find('Pokers/point' .. cardIndex)
            dataItem.PokerCards[cardIndex] = childItem:Find('Pokers/point' .. cardIndex .. '/PokerItem')
        end

    end

end

-- 还原玩家对应位置到初始状态
function ResetPlayerInfo2Defaul(positionParam)
    -- body
    mPlayersUIInfo[positionParam].YQButton.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].HeadIcon.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].NameText.text = ''
    mPlayersUIInfo[positionParam].WinText.text = ''
    mPlayersUIInfo[positionParam].CardTypeText.text = ''
    mPlayersUIInfo[positionParam].CardType.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].HandleCD.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].GoldInfo.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].BetingInfo.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].KPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].QPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].JZImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].GZImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].ZBImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].YQPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].BPSImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].VSOKButtonGameObject:SetActive(false)
    mPlayersUIInfo[positionParam].CDTimeGameObject:SetActive(false)
end

-- 还原玩家到准备状态
function ResetPlayerToWaitState(positionParam)
    -- body
    mPlayersUIInfo[positionParam].WinText.text = ''
    mPlayersUIInfo[positionParam].CardTypeText.text = ''
    mPlayersUIInfo[positionParam].CardType.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].HandleCD.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].BetingInfo.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].KPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].QPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].JZImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].GZImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].ZBImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].YQPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].BPSImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].VSOKButtonGameObject:SetActive(false)
    mPlayersUIInfo[positionParam].CDTimeGameObject:SetActive(false)
end

-- 处理结算时，玩家状态还原(和自己相关的玩家会处理)
function HandlePlayerGameOverStateShow(positionParam)
    mPlayersUIInfo[positionParam].KPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].QPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].JZImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].GZImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].ZBImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].YQPImage.gameObject:SetActive(false)
    mPlayersUIInfo[positionParam].BPSImage.gameObject:SetActive(false)
end

-- 处理玩家当前状态显示
function HandlePositionPlayerInfo(positionParam)
    -- body
    SetPlayerSitdownState(positionParam)
    SetPlayerBaseInfo(positionParam)
    HandlePlayerKPImageState(positionParam)
    HandlePlayerBPSImageState(positionParam)
    HandlePlayerQPImageState(positionParam)
end

-- 设置对应位置坐下状态
function SetPlayerSitdownState(positionParam)
    -- print('玩家位置:' .. positionParam)
    local PlayerState = mRoomData.JHPlayers[positionParam].PlayerState
    local _RoomType = mRoomData.RoomType
    if _RoomType == ROOM_TYPE.MenJi then
        mPlayersUIInfo[positionParam].YQButton.gameObject:SetActive(false)
    else
        mPlayersUIInfo[positionParam].YQButton.gameObject:SetActive(PlayerState == PlayerStateEnum.None)
    end
end

-- 设置对应位置玩家基础信息
function SetPlayerBaseInfo(positionParam)
    local PlayerState = mRoomData.JHPlayers[positionParam].PlayerState
    local HeadIcon = mRoomData.JHPlayers[positionParam].HeadIcon
    local PlayerInfo = mRoomData.JHPlayers[positionParam]
    mPlayersUIInfo[positionParam].HeadIcon.gameObject:SetActive(PlayerState ~= PlayerStateEnum.None)
    mPlayersUIInfo[positionParam].GoldInfo.gameObject:SetActive(PlayerState ~= PlayerStateEnum.None)
    if PlayerState ~= PlayerStateEnum.None then
        SetPlayerHeadIcon(positionParam)
        SetPlayerGoldValue(positionParam)
        SetPlayerNameText(positionParam)
    end
    
    --print(string.format('玩家:%d 状态:%d', positionParam, PlayerState))
end

-- 设置指定玩家金币值
function SetPlayerGoldValue(positionParam)
    local PlayerInfo = mRoomData.JHPlayers[positionParam]
    mPlayersUIInfo[positionParam].GoldText.text =""..tostring(lua_GetPreciseDecimal(PlayerInfo.GoldValue,2))
end

-- 设置对应位置玩家Icon
function SetPlayerHeadIcon(positionParam)
    -- body
    local playerData = mRoomData.JHPlayers[positionParam]
    if playerData.PlayerState == PlayerStateEnum.None then
        return
    end
    mPlayersUIInfo[positionParam].HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(playerData.HeadIcon))
end

-- 设置玩家名字
function SetPlayerNameText(positionParam)
    if mRoomData.JHPlayers[positionParam].PlayerState == PlayerStateEnum.None then
        return
    end
    local PlayerInfo = mRoomData.JHPlayers[positionParam]
    mPlayersUIInfo[positionParam].NameText.text = PlayerInfo.strLoginIP
end

--==============================--
--desc:玩家看牌标签处理
--time:2017-11-30 10:22:33
--@positionParam:
--@return 
--==============================--
function HandlePlayerKPImageState(positionParam)
    -- body
    local playerData = mRoomData.JHPlayers[positionParam]
    if playerData.DropCardState == 1 or playerData.CompareState == 1 then
        mPlayersUIInfo[positionParam].KPImage.gameObject:SetActive(false)
    else
        mPlayersUIInfo[positionParam].KPImage.gameObject:SetActive(playerData.LookState == 1)
    end
end

--==============================--
--desc:玩家弃牌状态处理
--time:2017-11-30 09:52:23
--@positionParam:
--@return 
--==============================--
function HandlePlayerQPImageState( positionParam )
    local playerData = mRoomData.JHPlayers[positionParam]
    local _activeOld = mPlayersUIInfo[positionParam].YQPImage.gameObject.activeSelf
    local _activeNew = (playerData.DropCardState == 1)
    if _activeOld ~= _activeNew then
        mPlayersUIInfo[positionParam].YQPImage.gameObject:SetActive(_activeNew)
    end
    if playerData.DropCardState == 1 then
        -- 弃牌状态==》需要处理 已看牌 标签隐藏
        HandlePlayerKPImageState(positionParam)
    end
end

--==============================--
--desc:玩家弃牌动画
--time:2017-11-30 02:01:14
--@positionParam:玩家位置
--@return 
--==============================--
function HandlePlayerQPAnimation(positionParam)
    mPlayersUIInfo[positionParam].QPImage.gameObject:SetActive(true)
    
    this:DelayInvoke(1.0,function() mPlayersUIInfo[positionParam].QPImage.gameObject:SetActive(false) end)
end

--==============================--
--desc:玩家比牌输状态处理
--time:2017-11-30 10:23:08
--@positionParam:
--@return 
--==============================--
function HandlePlayerBPSImageState(positionParam)
    -- body
    local playerData = mRoomData.JHPlayers[positionParam]
    local _activeOld = mPlayersUIInfo[positionParam].BPSImage.gameObject.activeSelf
    local _activeNew = (playerData.CompareState == 1)
    if _activeNew ~= _activeOld then
        mPlayersUIInfo[positionParam].BPSImage.gameObject:SetActive(_activeNew)
    end
    if playerData.CompareState == 1 then
        -- 比牌输 ==》需检查 看牌标签状态
        HandlePlayerKPImageState(positionParam)
    end
end

-- 还原UI默认基础显示状态
function RestoreUI2Default()
    -- body
    SetCaidanShow(false)
    VSPKShow(false)
    MasterKPButtonShow(false)
    MasterXZButtonShow(false)
    MasterAutoButtonShow(false)
    MasterJZInfoShow(false)
    ResetPokerCardVisible()
    -- 玩家位置信息重置
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        ResetPlayerInfo2Defaul(position)
    end
end

-- 重置扑克牌显示
function ResetPokerCardVisible()
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        ResetPlayerCardToDefault(position)
    end
end

-- 重置玩家扑克默认状态
function ResetPlayerCardToDefault(positionParam)
    for cardIndex = 1, 3, 1 do
        SetTablePokerCardVisible(mPlayersUIInfo[positionParam].PokerCards[cardIndex], false)
        SetPokerCardShow(positionParam, cardIndex, false)
    end
end


-- 设置扑克牌显示隐藏状态
function SetPokerCardShow(positionParam, cardIndexParam, showParam)
    if mPlayersUIInfo[positionParam].PokerCards[cardIndexParam].gameObject.activeSelf == showParam then
        return
    end
    mPlayersUIInfo[positionParam].PokerCards[cardIndexParam].gameObject:SetActive(showParam)
end

-- 设置玩家扑克牌是否可见
function SetTablePokerCardVisible(pokerCard, isVisible)
    if nil == pokerCard then
        error('玩家扑克牌数据异常')
        return
    end
    if pokerCard:Find('PokerBack').gameObject.activeSelf == lua_NOT_BOLEAN(isVisible) then
        return
    end
    pokerCard:Find('PokerBack').gameObject:SetActive(lua_NOT_BOLEAN(isVisible))
end

-- 按钮事件响应绑定
function AddButtonHandlers()
    this.transform:Find('Canvas/CaidanButton'):GetComponent("Button").onClick:AddListener(OnCaidanButtonClick)
    this.transform:Find('Canvas/CaidanButton/ReturnCaiDan/ReturnButton'):GetComponent("Button").onClick:AddListener(OnQuitGameButtonClick)
    this.transform:Find('Canvas/CaidanButton/ReturnCaiDan/ChangeButton'):GetComponent("Button").onClick:AddListener(ChangeButtonOnClick)
    this.transform:Find('Canvas/CaidanButton/ReturnCaiDan/RankButton'):GetComponent("Button").onClick:AddListener(RankButtonOnClick)
    this.transform:Find('Canvas/CaidanButton/ReturnCaiDan/ImageMask'):GetComponent("Button").onClick:AddListener(OnCaidanHideClick)
    this.transform:Find('Canvas/StoreButton'):GetComponent("Button").onClick:AddListener(StoreButtonOnClick)
    

    this.transform:Find('Canvas/MasterInfo/KPButton'):GetComponent('Button').onClick:AddListener(OnKPButtonClick)
    this.transform:Find('Canvas/MasterInfo/XZButtons/QPButton'):GetComponent('Button').onClick:AddListener(OnQPButtonClick)
    this.transform:Find('Canvas/MasterInfo/AutoButtons/QPButton'):GetComponent('Button').onClick:AddListener(OnQPButtonClick)
    this.transform:Find('Canvas/MasterInfo/AutoButtons/AutoButton'):GetComponent("Button").onClick:AddListener(AutoButtonOnClick)
    this.transform:Find('Canvas/MasterInfo/XZButtons/JZButton'):GetComponent('Button').onClick:AddListener(OnJZButtonClick)
    this.transform:Find('Canvas/MasterInfo/XZButtons/GZButton'):GetComponent('Button').onClick:AddListener(OnGZButtonClick)
    this.transform:Find('Canvas/MasterInfo/XZButtons/BPButton'):GetComponent('Button').onClick:AddListener(OnBPButtonClick)
    this.transform:Find('Canvas/MasterInfo/ZBButton'):GetComponent('Button').onClick:AddListener(OnZBButtonClick)

    this.transform:Find('Canvas/MasterInfo/JZInfo/MaskImage'):GetComponent('Button').onClick:AddListener(OnJZHideClick)
    this.transform:Find('Canvas/MasterInfo/JZInfo/JZButton1'):GetComponent('Button').onClick:AddListener( function() OnJZButtonOKClick(2) end)
    this.transform:Find('Canvas/MasterInfo/JZInfo/JZButton2'):GetComponent('Button').onClick:AddListener( function() OnJZButtonOKClick(3) end)
    this.transform:Find('Canvas/MasterInfo/JZInfo/JZButton3'):GetComponent('Button').onClick:AddListener( function() OnJZButtonOKClick(4) end)
    this.transform:Find('Canvas/MasterInfo/JZInfo/JZButton4'):GetComponent('Button').onClick:AddListener( function() OnJZButtonOKClick(5) end)


    -- 每个位置要求按钮call
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        -- 比牌选择按钮
        local PKItem = this.transform:Find('Canvas/PKSelect/VSOKButton' .. position):GetComponent('Button')
        PKItem.onClick:AddListener( function() OnVSOKButtonOnclick(position) end)
    end

    this.transform:Find('Canvas/PKSelect/PKSelectMask'):GetComponent('Button').onClick:AddListener(OnHidePKSelectClick)

end

-- =============================房间基础信息设置==========================================
-- 设置房间基础信息
function SetRoomBaseInfo()
    SetRoomID(mRoomData.RoomID)
    SetBetAllValueText(mRoomData.BetAllValue)
    SetRounTimesText(mRoomData.RoundTimes)
    SetBetMinText(mRoomData.BetMin)
    SetBetMaxText(mRoomData.BetMax)
    SetRoomRuleText(mRoomData.GameMode, mRoomData.MenJiRound)
end

function SetRoomID(roomIDParam)
    mRoomInfo.RoomIDText.text = tostring(roomIDParam)
end

function SetBetAllValueText(betParam)
    mRoomInfo.BetAllValueText.text = lua_NumberToStyle1String(betParam)
end

function SetRounTimesText(roundTimesParam)
    mRoomInfo.RoundTimesText.text = string.format('%d/%d', roundTimesParam, 20)
end

function SetBetMinText(betMinParam)
    mRoomInfo.BetMinText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(betMinParam))
end

function SetBetMaxText(betMaxParam)
    mRoomInfo.BetMaxText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(betMaxParam))
end
-- 设置房间规则
function SetRoomRuleText(modeTypeParam, menjiParam)
    -- body
    local RoomTypeText = data.GetString("ZUJU_GameModel_" .. modeTypeParam)
    if mRoomData.RoomType == ROOM_TYPE.MenJi then
        local _data  =  GameConfig.GetPublicRoomConfigDataByTypeLevel(1,mRoomData.SubType)
        if _data ~= nil then
            RoomTypeText = _data.Name 
        end
    end
    this.transform:Find('Canvas/RoomInfo/RoomType/Text'):GetComponent('Text').text = RoomTypeText
    local RoomRuleText = data.GetString("ZUJU_Menji_" .. menjiParam)
    this.transform:Find('Canvas/RoomInfo/Menpai/Text'):GetComponent('Text').text = RoomRuleText
end

---------------------------------------------------------------------------------
-------------------------------按钮响应 call-------------------------------------
-- 菜单按钮 call
function OnCaidanButtonClick()
    -- body
    SetCaidanShow(true)
    RefreshChangeButtonState()
    RefreshQuitGameButtonState()
end

-- 菜单组件隐藏
function OnCaidanHideClick()
    -- body
    SetCaidanShow(false)
end

-- 菜单组件显示设置
function SetCaidanShow(showParam)
    if showParam then
        this.transform:Find('Canvas/CaidanButton/true').gameObject:SetActive(false)
        this.transform:Find('Canvas/CaidanButton/false').gameObject:SetActive(true)
        
    else
        this.transform:Find('Canvas/CaidanButton/true').gameObject:SetActive(true)
        this.transform:Find('Canvas/CaidanButton/false').gameObject:SetActive(false)
    end
    -- body
    if mReturnCaiDan.activeSelf == showParam then
        return
    end
    mReturnCaiDan:SetActive(showParam)
end

-- 推出游戏按钮 call
function OnQuitGameButtonClick()
    -- body
    SetCaidanShow(false)
    local _canQuit =  CheckCanQuitGame()
    if _canQuit == true then 
        NetMsgHandler.Send_CS_JH_Exit_Room(mRoomData.RoomID)
    else
        local boxData = CS.MessageBoxData()
        boxData.Title = "温馨提示"
        boxData.Content = "退出房间将默认视为弃牌,确定退出房间吗?"
        boxData.Style = 2
        boxData.OKButtonName = "确定"
        boxData.LuaCallBack = ConfirmQuitGame
        CS.MessageBoxUI.Show(boxData)
    end
end

-- 确认提示框操作结果
function ConfirmQuitGame( resultType )
    if resultType == 1 then
        NetMsgHandler.Send_CS_JH_Exit_Room(mRoomData.RoomID)
    end
end

--==============================--
--desc:检测是否可以离开房间
--time:2017-11-30 07:58:36
--@return 
--==============================--
function CheckCanQuitGame()
    local _canQuit =  true
    if mMasterData.PlayerState == PlayerStateEnum.JoinNO then
        _canQuit = true
    else
        if mRoomData.RoomState ~= ROOM_STATE_JHWR.Wait then
            if mMasterData.DropCardState == 1 or  mMasterData.CompareState == 1 then
                _canQuit =  true
            else
                _canQuit = false
            end
        end
    end
    return _canQuit
end

--==============================--
--desc:刷新退出房间按钮
--time:2017-12-01 06:44:25
--@return 
--==============================--
function RefreshQuitGameButtonState()
    local _canQuit  = CheckCanQuitGame()
    this.transform:Find('Canvas/CaidanButton/ReturnCaiDan/ReturnButton'):GetComponent("Button").interactable = _canQuit
    if _canQuit then
        this.transform:Find('Canvas/CaidanButton/ReturnCaiDan/ReturnButton/Image'):GetComponent("Image").color=CS.UnityEngine.Color(255,255,255,1)
    else
        this.transform:Find('Canvas/CaidanButton/ReturnCaiDan/ReturnButton/Image'):GetComponent("Image").color=CS.UnityEngine.Color(200,200,200,0.5)
    end
end

-- 换房按钮 call
function ChangeButtonOnClick()
    SetCaidanShow(false)
    local _canChange =  CheckCanChangeRoom 
    if _canChange  then
        NetMsgHandler.Send_CS_JH_Change_MenJiRoom(mRoomData.RoomID)
        ChangeRoomImageShow(true)
    end
end

-- 切换房间结果通知
function OnNotifyMenJiRoomChangeEvent()
    ChangeRoomImageShow(false)
end

-- 玩家换房间遮挡显示
function ChangeRoomImageShow(showParam)
    local _maskImage = this.transform:Find('Canvas/ChangeRoomImage')
    if _maskImage.gameObject.activeSelf == showParam then
        return
    end
    _maskImage.gameObject:SetActive(showParam)
end

-- 检测能否换房
function CheckCanChangeRoom()
    local _change = false
    if mRoomData.RoomType == ROOM_TYPE.MenJi then
        if mMasterData.PlayerState == PlayerStateEnum.JoinNO then
            _change = true
        else
            if mRoomData.RoomState == ROOM_STATE_JHWR.Wait then
                _change = true
            else
               if mMasterData.CompareState == 1 or mMasterData.DropCardState == 1 then
                   -- body
                    _change = true
                else
                    _change = false
               end
            end
        end
    else
        _change = false
    end
    return _change
end

--==============================--
--desc:刷新换房按钮状态
--time:2017-12-01 06:41:19
--@return 
--==============================--
function RefreshChangeButtonState()
    -- 房间号码 焖鸡房隐藏
    local _change = CheckCanChangeRoom()
    this.transform:Find('Canvas/CaidanButton/ReturnCaiDan/ChangeButton'):GetComponent("Button").interactable = _change
end

-- 邀请按钮call
function OnYQButtonClick(positionParam)
    local _betMin = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(mRoomData.BetMin))
    local _betMax = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(mRoomData.BetMax))
    GameData.OpenIniteUI(mRoomData.RoomID, mRoomData.RoomType, _betMin, _betMax)
end

-- 商城按钮
function StoreButtonOnClick()
    GameConfig.OpenStoreUI()
end

-------------------------------按钮 call end--------------------------------------------------

function ResetGameToRoomState(currentState)
    mRoomData = GameData.RoomInfo.CurrentRoom
    mMasterData = mRoomData.JHPlayers[JHZUJU_ROOM_PLAYER_MAX]

    canPlaySoundEffect = false
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    InitRoomBaseInfos()
    RefreshGameRoomToEnterGameState(currentState, true)
    canPlaySoundEffect = true
    -- 焖鸡房间隐藏房间号
    if mRoomData.RoomType == ROOM_TYPE.MenJi then
        this.transform:Find('Canvas/RoomInfo/RoomID').gameObject:SetActive(false)
    end
    QPButton_1.enabled = true
    QPButton_2.enabled = true
    KPButton.enabled = true
    InitRoomChange()
end

-- 游戏状态切换
function RefreshGameByRoomStateSwitchTo(roomState)
    RefreshGameRoomToEnterGameState(roomState, false)
end

-- 刷新游戏房间到游戏状态
function RefreshGameRoomToEnterGameState(roomState, isInit)
    -- print(string.format('*****当前游戏状态:%d 初始化:%s', roomState, lua_BOLEAN_String(isInit)))
    
    if isInit or roomState == ROOM_STATE_JHWR.Wait then
        -- 调用下GC回收
        this:StopAllDelayInvoke()
        lua_Call_GC()
        ChangeRoomImageShow(false)
    end
    RefreshWaitPartOfGameByRoomState(roomState, isInit)
    RefreshSubduceBetPartOfGameByRoomState(roomState, isInit)
    RefreshDealPartOfGameByRoomState(roomState, isInit)
    RefreshBettingPartOfGameByRoomState(roomState, isInit)
    RefreshCardVSPartOfGameByRoomState(roomState, isInit)
    RefreshSettlementPartOfGameByRoomState(roomState, isInit)
end

-- 初始化房间到初始状态
function InitRoomBaseInfos(roomStateParam)
    -- 座位信息设置
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        ResetPlayerInfo2Defaul(position)
        HandlePositionPlayerInfo(position)
    end
    SetRoomBaseInfo()
end

-- 游戏状态变化音效播放接口
function PlaySoundEffect(musicid)
    if true == canPlaySoundEffect then
        MusicMgr:PlaySoundEffect(musicid)
    end
end

-- ===============【等待准备】【1】 ROOM_STATE_JHWR.Wait===============--

function RefreshWaitPartOfGameByRoomState(roomStateParam, initParam)
    -- body
    if roomStateParam == ROOM_STATE_JHWR.Wait then
        -- body
        for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
            ResetPlayerInfo2Defaul(position)
            HandlePositionPlayerInfo(position)
            ResetPlayerToWaitState(position)
            -- 玩家准备状态
            local PlayerData = mRoomData.JHPlayers[position]
            if PlayerData.PlayerState ~= PlayerStateEnum.None then
                mPlayersUIInfo[position].ZBImage.gameObject:SetActive(PlayerData.ReadyState == 1)
            end
        end

        RefreshZBButtonShow()
        SetRoomBaseInfo()
        ResetPokerCardVisible()
        MasterKPButtonShow(false)
        WaitNextGameStartShow(false)
        ClearChips()
        ResetAutoXiaZhuState()
    else

        -- 准备状态还原
        for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
            mPlayersUIInfo[position].ZBImage.gameObject:SetActive(false)
        end
        SetZBButtonShow(false)

        if initParam then
            for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
                ResetPlayerInfo2Defaul(position)
                HandlePositionPlayerInfo(position)
            end
            ResetPokerCardVisible()
        end
    end
    
    RefreshBankerPosition()
end

-- 刷新庄家位置
function RefreshBankerPosition()
    -- body
    local bankerPos = mRoomData.BankerPosition
    if bankerPos ~= 0 then
        if BankerPositionOld ~= bankerPos then
            BankerImageTweenTransform.from = mPlayersUIInfo[BankerPositionOld].BankerPos
            BankerImageTweenTransform.to = mPlayersUIInfo[bankerPos].BankerPos
            BankerImageTweenTransform:ResetToBeginning()
            BankerImageTweenTransform:Play(true)
            BankerPositionOld = bankerPos
        end
    end
end

-- 玩家准备按钮call
function OnZBButtonClick()
    NetMsgHandler.Send_CS_JH_Ready(1)
end

-- 准备按钮显示设置
function SetZBButtonShow(showParam)
    if mMasterXZInfo.ZBButtonGameObject.activeSelf == showParam then
        return
    end
    mMasterXZInfo.ZBButtonGameObject:SetActive(showParam)
end

-- 刷新准备按钮显示
function RefreshZBButtonShow()
    if mMasterData.PlayerState ~= PlayerStateEnum.None then
        SetZBButtonShow(true)
    else
        SetZBButtonShow(false)
    end
end

-- 通知玩家准备状态
function OnNotifyZUJUPlayerReadyStateEvent(positionParam)
    if positionParam == JHZUJU_ROOM_PLAYER_MAX then
        SetZBButtonShow(false)
    end
    local ReadyState = mRoomData.JHPlayers[positionParam].ReadyState
    --print(string.format('玩家：%d 准备状态:%d', positionParam, ReadyState))

    mPlayersUIInfo[positionParam].ZBImage.gameObject:SetActive(ReadyState == 1)
end

-- 清理筹码
function ClearChips()
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        local _child = CHIP_JOINTS[position].JointPoint
        lua_Transform_ClearChildren(_child,false)
    end
end


-- ===============【收取底注】【2】 ROOM_STATE_JHWR.SubduceBet===============--

function RefreshSubduceBetPartOfGameByRoomState(roomStateParam, initParam)
    -- body
    if roomStateParam == ROOM_STATE_JHWR.SubduceBet then
        RefreshBankerPosition()
        HandleWaitForNextGame()
        SetBetAllValueText(mRoomData.BetAllValue)
    elseif roomStateParam > ROOM_STATE_JHWR.SubduceBet and initParam == true then
        -- 收取底注状态之后进入游戏
        HandleWaitForNextGame()
        ClearChips()
        HandleOhterChip()
    else

    end
end

-- 押注筹码到桌子上
function BetChipToDesk(betValueParam, positionParam)
    local startPoint = nil
    startPoint = CHIP_START[positionParam]
    local betType = mRoomData:GetBetType(betValueParam)
    CastChipToBetArea(betType, betValueParam, tostring(positionParam), true, startPoint.position)

    -- 押注筹码音效
    PlaySoundEffect('5')
end

-- 向押注区域投掷筹码
function CastChipToBetArea(areaType, chipValue, chipName, isAnimation, fromWorldPoint)
    local model = CHIP_RES[areaType]
    if model ~= nil then
        local betChip = CS.UnityEngine.Object.Instantiate(model)
        betChip.gameObject.name = chipName
        betChip:Find('Text'):GetComponent('Text').text = lua_NumberToStyle1String(chipValue)
        local areaInfo = CHIP_JOINTS[areaType]
        CS.Utility.ReSetTransform(betChip, areaInfo.JointPoint)
        local toLocalPoint = lua_RandomXYOfVector3(areaInfo.RangeX.Min, areaInfo.RangeX.Max, areaInfo.RangeY.Min, areaInfo.RangeY.Max)
        betChip.gameObject:SetActive(true)
        if isAnimation then
            betChip.position = fromWorldPoint
            local script = betChip:GetComponent("TweenPosition")
            script.from = betChip.localPosition
            script.to = toLocalPoint
            script.worldSpace = false
            script:ResetToBeginning()
            script:Play(true)
        else
            betChip.localPosition = toLocalPoint
        end
    end
end

-- 玩家下注通知call
function OnNotifyZUJUBettingEvent(eventArgs)

    BetChipToDesk(eventArgs.BetValue, eventArgs.PositionValue)
    SetBetAllValueText(mRoomData.BetAllValue)
    SetPlayerBetValueText(eventArgs.PositionValue)
    SetPlayerGoldValue(eventArgs.PositionValue)

    if eventArgs.BetType == 1 then
        -- 跟注
        mPlayersUIInfo[eventArgs.PositionValue].GZImage.gameObject:SetActive(true)
        this:DelayInvoke(1.0, function() mPlayersUIInfo[eventArgs.PositionValue].GZImage.gameObject:SetActive(false) end)
        RandomPlayGenZhuSound(eventArgs.PositionValue)
    elseif eventArgs.BetType == 2 then
        -- 加注
        mPlayersUIInfo[eventArgs.PositionValue].JZImage.gameObject:SetActive(true)
        this:DelayInvoke(1.0, function() mPlayersUIInfo[eventArgs.PositionValue].JZImage.gameObject:SetActive(false) end)
        -- 63~66
        RandomPlayJiaZhuSound(eventArgs.PositionValue)
    end
end

-- 跟注音效
function RandomPlayGenZhuSound(position)
    local IsMan = false
    for k=1,#data.PublicConfig.HeadIconMan,1 do
        if mRoomData.JHPlayers[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
            IsMan = true
            break
        end
    end
    local Index =math.random(2)
    local MusicidName="JH_gen_man_"..Index
    if IsMan == false then
        MusicidName = "JH_gen_woman_"..Index
    end
    PlaySoundEffect(MusicidName)
    --[[local _random = mGenZhuSoundRandom % mGenZhuSoundRandomFactor + 1
    PlaySoundEffect('JH_genzhu_' .. _random)
    mGenZhuSoundRandom = mGenZhuSoundRandom + 1--]]
end

-- 加注音效
function RandomPlayJiaZhuSound(position)
    local IsMan = false
    for k=1,#data.PublicConfig.HeadIconMan,1 do
        if mRoomData.JHPlayers[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
            IsMan = true
            break
        end
    end
    local Index =math.random(2)
    local MusicidName="JH_jiazhu_man"
    if IsMan == false then
        MusicidName = "JH_jiazhu_woman"
    end
    PlaySoundEffect(MusicidName)
    --[[local _random = mJiaZhuSoundRandom % mJiaZhuSoundRandomFactor + 1
    PlaySoundEffect('JH_jiazhu_' .. _random)
    mJiaZhuSoundRandom = mJiaZhuSoundRandom + 1--]]
end


-- 设置玩家下注金额
function SetPlayerBetValueText(positionParam)
    if positionParam == 0 then
        return
    end
    if mPlayersUIInfo[positionParam].BetingInfo.gameObject.activeSelf == false then
        mPlayersUIInfo[positionParam].BetingInfo.gameObject:SetActive(true)
    end
    local playerData = mRoomData.JHPlayers[positionParam]
    mPlayersUIInfo[positionParam].BetingText.text = lua_NumberToStyle1String(playerData.BetChipValue)
    if playerData.BetChipValue <= 0 then
        mPlayersUIInfo[positionParam].BetingInfo.gameObject:SetActive(false)
    end
end

-- 处理自己是否处于旁观状态
function HandleWaitForNextGame()
    if mMasterData.PlayerState == PlayerStateEnum.JoinNO then
        WaitNextGameStartShow(true)
    else
        WaitNextGameStartShow(false)
    end
end

--==============================--
--desc:处理玩家自己进入阶段为后续阶段他人已经下注筹码
--time:2017-11-30 05:55:30
--@return 
--==============================--
function HandleOhterChip()
    local _AllBetInfo = mRoomData.AllBetInfo
    local _allbetCount = #_AllBetInfo
    local _haveCount = 0
    -- 将未处理数据继续添加上去
    for key, betInfo in pairs(_AllBetInfo) do
        if key > _haveCount then 
            OnNotifyZUJUBettingEvent(betInfo)
        end
    end
    -- 已经下注玩家筹码值设置
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        local _playerData = mRoomData.JHPlayers[position]
        if _playerData.BetChipValue > 0 then
            SetPlayerBetValueText(position)
        end
    end

end


-- ===============【洗牌发牌】【3】 ROOM_STATE_JHWR.Deal===============--

function RefreshDealPartOfGameByRoomState(roomStateParam, initParam)
    -- body
    if roomStateParam == ROOM_STATE_JHWR.Deal then
        PlayDealAnimation()
    elseif roomStateParam > ROOM_STATE_JHWR.Deal then
        if initParam then
            -- 需要将参与者牌瞬间补齐
            HandlePlayerDealNoAnimation()
            HandleMasterLookState()
        end
    end
end

-- 发牌动画
function PlayDealAnimation()
    -- 可以播放发牌动画的玩家
    local JHPlayers = mRoomData.JHPlayers
    local tResetPosition = { }
    for index = JHZUJU_ROOM_PLAYER_MAX, 1, -1 do
        if PlayerStateEnum.JoinOK == JHPlayers[index].PlayerState then
            table.insert(tResetPosition, index)
        end
    end

    -- 顺序3张牌排列
    local cardIndex = 18
    for pos = 1, 3, 1 do
        for k1, v1 in pairs(tResetPosition) do
            -- 位置重置中心
            CS.Utility.ReSetTransform(mPlayersUIInfo[v1].PokerCards[pos], mPokerCardPoints[cardIndex])
            cardIndex = cardIndex - 1
        end
    end

    -- 发牌顺序位置
    local tcanPlayAnimationPosition = { }
    for index = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        if PlayerStateEnum.JoinOK == JHPlayers[index].PlayerState then
            table.insert(tcanPlayAnimationPosition, index)
        end
    end
    -- 按序发牌
    local delayTime = 0
    local cardPointIndex = 18
    for pokerIndex = 1, 3, 1 do

        for k1, v1 in pairs(tcanPlayAnimationPosition) do
            -- print(string.format('发牌序列:%d_%d', v1, pokerIndex))
            SetPokerCardShow(v1, pokerIndex, true)
            SetTablePokerCardVisible(mPlayersUIInfo[v1].PokerCards[pokerIndex], false)

            delayTime = delayTime + 0.1
            this:DelayInvoke(delayTime,
            function()
                local cardItem = mPlayersUIInfo[v1].PokerCards[pokerIndex]
                lua_Clear_AllUITweener(cardItem)

                if cardItem.gameObject.activeSelf == false then
                    cardItem.gameObject:SetActive(true)
                end

                local pokerCard = JHPlayers[v1].PokerList[pokerIndex]
                local script = cardItem.gameObject:AddComponent(typeof(CS.TweenTransform))
                script.from = mPokerCardPoints[cardPointIndex]
                script.to = mPlayersUIInfo[v1].PokerPoints[pokerIndex]
                script.duration = 0.4
                script:OnFinished("+",
                ( function()
                    CS.UnityEngine.Object.Destroy(script)
                    if pokerCard.PokerNumber > 0 then
                        cardItem:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(pokerCard))
                    end
                    -- TODO 测试 明牌
                    --SetTablePokerCardVisible(cardItem, true)
                    CS.Utility.ReSetTransform(cardItem, mPlayersUIInfo[v1].PokerPoints[pokerIndex])
                end ))
                script:Play(true)
                -- 音效发牌音效
                PlaySoundEffect('3')
            end )

            cardPointIndex = cardPointIndex - 1

        end

    end
end

-- 处理玩家发牌结果 无动画
function HandlePlayerDealNoAnimation()
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        if PlayerStateEnum.JoinOK == mRoomData.JHPlayers[position].PlayerState then
            for pokerIndex = 1, 3, 1 do
                -- 位置重置中心
                CS.Utility.ReSetTransform(mPlayersUIInfo[position].PokerCards[pokerIndex], mPlayersUIInfo[position].PokerPoints[pokerIndex])
                SetTablePokerCardVisible(mPlayersUIInfo[position].PokerCards[pokerIndex], false)
                SetPokerCardShow(position, pokerIndex, true)
            end
        end
    end
end

-- 检测玩家自己看牌状态
function HandleMasterLookState()
    if mMasterData.PlayerState == PlayerStateEnum.JoinOK and mMasterData.LookState == 1 then
        PlayerFlipPokerAnimation(JHZUJU_ROOM_PLAYER_MAX)
    end
end

-- ===============【下注阶段】【4】 ROOM_STATE_JHWR.Betting===============--


function RefreshBettingPartOfGameByRoomState(roomStateParam, initParam)
    -- body
    if roomStateParam == ROOM_STATE_JHWR.Betting then
        SetRounTimesText(mRoomData.RoundTimes)
        RefreshMasterBetState()
        RefreshCurrentBetingCD()
        SetBetAllValueText(mRoomData.BetAllValue)
        SetRounTimesText(mRoomData.RoundTimes)
        RefreshMasterKPButtonState()
        
    else
        mISUpdateBetingCD = false
        ResetCurrentBettingCDShow()
        MasterXZButtonShow(false)
        MasterAutoButtonShow(false)
        MasterJZInfoShow(false)

    end
end

-- 刷新玩家下注状态
function RefreshMasterBetState()
    MasterXZButtonShow(false)
    MasterAutoButtonShow(false)
    MasterJZInfoShow(false)
    if mMasterData.PlayerState ~= PlayerStateEnum.JoinOK then
        -- body
        return
    end
    -- 玩家是否已经弃牌
    if mMasterData.DropCardState == 1 then
        return
    end
    -- 玩家比牌输
    if mMasterData.CompareState == 1 then
        return
    end

    if mRoomData.BettingPosition == JHZUJU_ROOM_PLAYER_MAX then

        if AutoXiaZhuState == true then
            -- 自动跟注
            MasterAutoButtonShow(true)
            if CanFollowBet() then
               this:DelayInvoke(1, function() TrySend_CS_JH_Betting(1, GetMasterFollowBetValue()) end)
            else
                MasterXZButtonShow(true)
                MasterAutoButtonShow(false)
            end
            return
        end

        MasterXZButtonShow(true)
        -- 自己下注处理
        local bettingValue = GetMasterFollowBetValue()
        if GameData.RoleInfo.GoldCount < bettingValue then
            -- body
            mMasterXZInfo.JZButtonGameObject.transform:GetComponent("Button").interactable = false
            mMasterXZInfo.GZButtonGameObject.transform:GetComponent("Button").interactable = false
        else
            mMasterXZInfo.JZButtonGameObject.transform:GetComponent("Button").interactable = true
            mMasterXZInfo.GZButtonGameObject.transform:GetComponent("Button").interactable = true
        end
    else
        -- 他人下注处理
        MasterAutoButtonShow(true)
    end
end

-- 刷新玩家下注倒计时CD
function RefreshCurrentBetingCD()
    local BettingPosition = mRoomData.BettingPosition
    if BettingPosition > 0 then
        mCurrentHandleCD = mPlayersUIInfo[BettingPosition].HandleCD
        mCDTimeText = mPlayersUIInfo[BettingPosition].CDTimeText
        mISUpdateBetingCD = true
        for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
            mPlayersUIInfo[position].HandleCD.gameObject:SetActive(position == BettingPosition)
            mPlayersUIInfo[position].CDTimeGameObject:SetActive(position == BettingPosition)
        end
        -- 玩家自身不需要显示时钟
        if BettingPosition == JHZUJU_ROOM_PLAYER_MAX then
            mPlayersUIInfo[JHZUJU_ROOM_PLAYER_MAX].CDTimeGameObject:SetActive(false)
        end
    else
        error('当前下注玩家位置:0有误')
    end
end

-- 刷新当前玩家下注CD
function UpdateCurrentBettingCD()
    if false == mISUpdateBetingCD then
        return
    end
    if mCurrentHandleCD == nil then
        return
    end

    if mCurrentHandleCD.gameObject.activeSelf == false then
        mCurrentHandleCD.gameObject:SetActive(true)
    end
    local countDown = mRoomData.CountDown
    local maxValue = ROOM_TIME_JHWR[ROOM_STATE_JHWR.Betting]
    if countDown < 0 then
        countDown = 0
    end
    local fillAmount = countDown / maxValue
    mCurrentHandleCD.fillAmount = fillAmount

    local tCD  = math.ceil(countDown)
    if mCDTimeValue ~= tCD then
        mCDTimeValue = tCD
        mCDTimeText.text = lua_FormatToCountdownStyle(mCDTimeValue)
    end

    -- 颜色设置
    --[[
    if fillAmount > 0.63 then
        mCurrentHandleCD.color = m_CheckColorOf1
    elseif fillAmount > 0.38 then
        mCurrentHandleCD.color = m_CheckColorOf2
    else
        mCurrentHandleCD.color = m_CheckColorOf3
    end
    ]]
end

-- CD显示还原
function ResetCurrentBettingCDShow()
    local BettingPosition = mRoomData.BettingPosition
    if BettingPosition > 0 then
        mPlayersUIInfo[BettingPosition].HandleCD.gameObject:SetActive(false)
        mPlayersUIInfo[BettingPosition].CDTimeGameObject:SetActive(false)
    end
end

-- ===============弃牌、加注、跟注、比牌===============--

-- 玩家弃牌按钮call
function OnQPButtonClick()
    -- body
    NetMsgHandler.Send_CS_JH_Drop_Card()
    QPButton_1.enabled = false
    QPButton_2.enabled = false
    this:DelayInvoke(1,function ()
        QPButton_1.enabled = true
        QPButton_2.enabled = true
    end)
end

-- 玩家弃牌通知
function OnNotifyZUJUDropCardEvent(positionParam)
    HandlePlayerQPImageState(positionParam)
    HandlePlayerQPAnimation(positionParam)
    if positionParam == JHZUJU_ROOM_PLAYER_MAX then
        -- body
        MasterXZButtonShow(false)
        MasterAutoButtonShow(false)
        PKSelectShow(false)
    end
    RandomQipaiSound(positionParam)
end

-- 弃牌音效随机
function RandomQipaiSound(positionParam)
    local IsMan = false
    for k=1,#data.PublicConfig.HeadIconMan,1 do
        if mRoomData.JHPlayers[positionParam].HeadIcon == data.PublicConfig.HeadIconMan[k] then
            IsMan = true
            break
        end
    end
    local Index =math.random(2)
    local MusicidName="JH_fangqi_man_"..Index
    if IsMan == false then
        MusicidName = "JH_fangqi_woman_"..Index
    end
    PlaySoundEffect(MusicidName)
    --[[local _random = mQipaiSoundRandom % mQipaiSoundRandomFactor + 1
    PlaySoundEffect('JH_qipai_' .. _random)
    mQipaiSoundRandom = mQipaiSoundRandom + 1--]]
end

--==============================--
--desc:自动加注按钮call
--time:2017-11-30 08:55:30
--@changeValue:
--@return 
--==============================--
function AutoButtonOnClick()
    -- body
    AutoXiaZhuState = lua_NOT_BOLEAN(AutoXiaZhuState)
    RefreshAutoXiaZhuButtonState()
    if AutoXiaZhuState then
    end
    if AutoXiaZhuState == true  and mRoomData.BettingPosition == JHZUJU_ROOM_PLAYER_MAX  then
        MasterXZButtonShow(true)
        MasterAutoButtonShow(false)
    end
end


-- 重置自动下注状态
function ResetAutoXiaZhuState()
    -- 重置自动下注按钮
    AutoXiaZhuState = false
    RefreshAutoXiaZhuButtonState()
end
-- 刷新自动按钮状态
function RefreshAutoXiaZhuButtonState()
    this.transform:Find('Canvas/MasterInfo/AutoButtons/AutoButton/Tag1').gameObject:SetActive(lua_NOT_BOLEAN(AutoXiaZhuState))
    this.transform:Find('Canvas/MasterInfo/AutoButtons/AutoButton/Tag2').gameObject:SetActive(AutoXiaZhuState)
    if AutoXiaZhuState then
        this.transform:Find('Canvas/MasterInfo/AutoButtons/QPButton'):GetComponent('Button').interactable = false
    else
        this.transform:Find('Canvas/MasterInfo/AutoButtons/QPButton'):GetComponent('Button').interactable = true
    end
end

-- ===============加注    ===============--
-- 玩家加注按钮call
function OnJZButtonClick()
    -- body
    MasterJZInfoShow(true)
    -- 加注筹码刷新
    local mingBet = 0
    local darkBet = 0

    for index = 1, 4, 1 do
        mingBet, darkBet = mRoomData:GetBettingValueByLevel(index + 1)
        local _genzhuBet = GetMasterFollowBetValue()
        local buttonCanClick = true
        if mMasterData.LookState == 0 then
            mMasterXZInfo.JZButtonTexts[index].text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(darkBet))
            if darkBet <= _genzhuBet  then
                buttonCanClick = false
            end
        else
            mMasterXZInfo.JZButtonTexts[index].text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(mingBet))
            if mingBet <= _genzhuBet  then
                buttonCanClick = false
            end
        end
        this.transform:Find('Canvas/MasterInfo/JZInfo/JZButton'..index):GetComponent('Button').interactable = buttonCanClick
    end
end

-- ===============跟注===============--

-- 玩家跟注按钮call
function OnGZButtonClick()
    TrySend_CS_JH_Betting(1, GetMasterFollowBetValue())
    MasterJZInfoShow(false)
end

-- ==============================--
-- desc:获取玩家当前跟注筹码
-- time:2017-11-14 08:33:28
-- @return
-- ==============================--
function GetMasterFollowBetValue()
    -- body
    local bettingValue = 0
    if mMasterData.LookState == 0 then
        bettingValue = mRoomData.DarkCardBetMin
    else
        bettingValue = mRoomData.MingCardBetMin
    end
    return bettingValue
end

-- 尝试下注请求
function TrySend_CS_JH_Betting(betType, betValue)
    if GameData.RoleInfo.GoldCount < betValue then
        -- 金币不足
        CS.BubblePrompt.Show(data.GetString("金币不足,无法下注"), "GameUI1")
        return
    end
    NetMsgHandler.Send_CS_JH_Betting(mRoomData.RoomID, betType, betValue)
end

-- 检测玩家当前能否下注
function CanFollowBet()
    local _canbet = true
    local _betvalue = GetMasterFollowBetValue()
    if GameData.RoleInfo.GoldCount < _betvalue then
        _canbet = false
    end
    return _canbet
end

-- 玩家加注隐藏按钮call
function OnJZHideClick()
    -- body
    MasterJZInfoShow(false)
end

-- 加注筹码选择call
function OnJZButtonOKClick(jiazhuParam)
    -- body
    local _genzhubetValue = GetMasterFollowBetValue()

    local mingBet, darkBet = mRoomData:GetBettingValueByLevel(jiazhuParam)
    local _betValue = 0
    local canJiaZhu = false

    if mMasterData.LookState == 0 then
        -- 焖牌
        _betValue = darkBet
    else
        _betValue = mingBet
    end
    
    if _betValue > _genzhubetValue then
        TrySend_CS_JH_Betting(2, _betValue)
    else
        TrySend_CS_JH_Betting(1, _betValue)
    end
    MasterJZInfoShow(false)
end

--==============================--
--desc:玩家下注阶段按钮显示
--time:2017-11-30 08:49:19
--@showParam:
--@return 
--==============================--
function MasterXZButtonShow(showParam)
    -- body
    if mMasterXZInfo.XZButtonGameObject.activeSelf == showParam then
        return
    end
    mMasterXZInfo.XZButtonGameObject:SetActive(showParam)
end

--==============================--
--desc:非玩家下注阶段 按钮显示
--time:2017-11-30 08:49:00
--@showParam:
--@return 
--==============================--
function MasterAutoButtonShow(showParam)
    -- body
    if mMasterXZInfo.AutoButtonGameObject.activeSelf == showParam then
        return
    end
    mMasterXZInfo.AutoButtonGameObject:SetActive(showParam)
end

-- 加注模块显示设置
function MasterJZInfoShow(showParam)
    if mMasterXZInfo.JZButtonInfo.activeSelf == showParam then
        return
    end
    mMasterXZInfo.JZButtonInfo:SetActive(showParam)
end

-- 玩家等待下一局开始
function WaitNextGameStartShow(showParam)
    if mMasterXZInfo.WaitImageGameObject.activeSelf == showParam then
        return
    end
    mMasterXZInfo.WaitImageGameObject:SetActive(showParam)
end

-- =============================看牌    ====================================

-- 刷新玩家自己看牌按钮显示状态
function RefreshMasterKPButtonState()
    if mMasterData.PlayerState ~= PlayerStateEnum.JoinOK then
        MasterKPButtonShow(false)
        return
    end
    if mRoomData.RoundTimes <= mRoomData.MenJiRound then
        MasterKPButtonShow(false)
        return
    end

    if mMasterData.LookState == 0 then
        MasterKPButtonShow(true)
    else
        MasterKPButtonShow(false)
    end
end

-- 看牌按钮call
function OnKPButtonClick()
    if mMasterData.PlayerState ~= PlayerStateEnum.JoinOK then
        MasterKPButtonShow(false)
        return
    end
    if mMasterData.LookState == 0 then
        -- body
        NetMsgHandler.Send_CS_JH_Look_Card()
        KPButton.enabled = false
        this:DelayInvoke(1,function ()
            KPButton.enabled = true
        end)
    else
        MasterKPButtonShow(false)
    end

end

-- 看牌按钮显示设置
function MasterKPButtonShow(showParam)
    -- body
    if mMasterXZInfo.KPButtonGameObject.activeSelf == showParam then
        return
    end
    mMasterXZInfo.KPButtonGameObject:SetActive(showParam)
end

-- 通知玩家已经看牌
function OnNotifyZUJULookCardEvent(positionParam)
    --print('看牌玩家:', positionParam)
    HandlePlayerKPImageState(positionParam)
    if positionParam == JHZUJU_ROOM_PLAYER_MAX then
        MasterKPButtonShow(false)
        -- 自己看牌 需要显示牌面
        PlayerFlipPokerAnimation(positionParam)
    end
    -- 看牌音效
    RandomPlayKanpaiSound(positionParam)
end

-- 看牌音效随机播放
function RandomPlayKanpaiSound(positionParam)
    local IsMan = false
    for k=1,#data.PublicConfig.HeadIconMan,1 do
        if mRoomData.JHPlayers[positionParam].HeadIcon == data.PublicConfig.HeadIconMan[k] then
            IsMan = true
            break
        end
    end
    local Index =math.random(2)
    local MusicidName="JH_kanpai_man"
    if IsMan == false then
        MusicidName = "JH_kanpai_woman"
    end
    PlaySoundEffect(MusicidName)
    --[[local _random = mKanPaiSoundRandom % mKanPaiSoundRandomFactor + 1
    PlaySoundEffect('JH_kanpai_'.._random)
    mKanPaiSoundRandom = mKanPaiSoundRandom + 1--]]
end

-- 玩家翻牌动画
function PlayerFlipPokerAnimation(positionParam)
    local _playerData  = mRoomData.JHPlayers[positionParam]
    -- 设置扑克牌面信息
    for index = 1, 3, 1 do
        local pokerCard = _playerData.PokerList[index]
        mPlayersUIInfo[positionParam].PokerCards[index]:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(pokerCard))
    end
    -- 显示扑克牌
    local delayTime = 0
    for cardIndex = 1, 3, 1 do
        SetTablePokerCardVisible(mPlayersUIInfo[positionParam].PokerCards[cardIndex], true)
        delayTime = delayTime + 0.5
    end
    mPlayersUIInfo[positionParam].CardType.gameObject:SetActive(true)
    mPlayersUIInfo[positionParam].CardType:Find('Image1').gameObject:SetActive(_playerData.IsWinner)
    mPlayersUIInfo[positionParam].CardType:Find('Image2').gameObject:SetActive(lua_NOT_BOLEAN(_playerData.IsWinner))
    mPlayersUIInfo[positionParam].CardTypeText.text = GameData.GetPokerTypeDisplayName(_playerData.PokerList[1],_playerData.PokerList[2],_playerData.PokerList[3])    
end

-- ===============【比牌阶段】【5】 ROOM_STATE_JHWR.CardVS===============--


function RefreshCardVSPartOfGameByRoomState(roomStateParam, initParam)
    -- body
    if roomStateParam == ROOM_STATE_JHWR.CardVS then
        if initParam == true then
            VSPKShow(false)
            HandlePlayerPositionShowState()
        else
            VSPKShow(true)
            PlayCardVSAnimation()
            SetBetAllValueText(mRoomData.BetAllValue)
            MasterKPButtonShow(false)
        end
    else
        if initParam == true then
            -- 下注阶段 结算阶段 需要检查是否位置显示正确
            HandlePlayerPositionShowState()
        end
        VSPKShow(false)
    end
end

-- 检查玩家位置是否因为比牌被隐藏了
function HandlePlayerPositionShowState()
    local _players = mRoomData.JHPlayers
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        -- 被隐藏的玩家显示出来
        local _activeOld = mPlayersUIInfo[position].TransformRoot.activeSelf
        if _activeOld == false then
            mPlayersUIInfo[position].TransformRoot:SetActive(true)
        end
    end
end


-- 设置VSPK显示
function VSPKShow(showParam)
    -- body
    if mVSPK.activeSelf == showParam then
        return
    end
    mVSPK:SetActive(showParam)
    if showParam == false then
        mVSPKTable.Result1.gameObject:SetActive(false)
        mVSPKTable.Result2.gameObject:SetActive(false)
    end
end

-- 播放比牌动画
function PlayCardVSAnimation()
    local position1,position2, winPosition = HandleVSShowPosition()
    this:DelayInvoke(0, function() PlayCardVSAnimationStep1(position1,position2, winPosition) end)
    this:DelayInvoke(0.25, function() PlayCardVSAnimationStep2() end)
    this:DelayInvoke(1.5, function() PlayCardVSAnimationStep3(position1,position2, winPosition) end)
    this:DelayInvoke(2.5, function() PlayCardVSAnimationStep4(position1,position2, winPosition) end)
    this:DelayInvoke(3, function() PlayCardVSAnimationStep5(position1,position2, winPosition) end)
end

-- 比牌位置区分
function HandleVSShowPosition()
    local ChallengerPosition = mRoomData.ChallengerPosition
    local ActorPosition = mRoomData.ActorPosition
    local position1, position2 = 1,2
    local winPosition = mRoomData.PKVSWinnerPosition
    -- 区分比牌参与者位置方向
    local _directionPos1Left = true
    local _directionPos2Left = true
    if ChallengerPosition <= 2 then
        _directionPos1Left = false
    end
    if ActorPosition <= 2 then
        _directionPos2Left = false
    end

    if _directionPos1Left == _directionPos2Left then
        if _directionPos1Left == true then
            -- 3、4、5互比
            if ChallengerPosition == 4 then
                position1 = 4
                position2 = ActorPosition
            elseif ActorPosition == 4 then
                position1 = 4
                position2 = ChallengerPosition
            else
                if ChallengerPosition == 5 then
                    position1 = ChallengerPosition
                    position2 = ActorPosition
                else
                    position1 = ActorPosition
                    position2 = ChallengerPosition
                end
            end
        else
            -- 1、2互比
            position1 = 1
            position2 = 2
        end
    else
        -- 1、2与3、4、5比牌
        if _directionPos1Left == true then
            position1 = ChallengerPosition
            position2 = ActorPosition
        else
            position1 = ActorPosition
            position2 = ChallengerPosition
        end
    end
    return position1,position2,winPosition
end

-- PK动画第一步(参与玩家飞向比牌布告)
function PlayCardVSAnimationStep1(position1,position2, winPosition)
    this.transform:Find('Canvas/VSPK/Image').gameObject:SetActive(true)
    mPlayersUIInfo[position1].TransformRoot:SetActive(false)
    mPlayersUIInfo[position2].TransformRoot:SetActive(false)

    -- 玩家1
    SetChallengerInfo(mVSPKTable.PKPlayer1, position1)
    -- 玩家2
    SetChallengerInfo(mVSPKTable.PKPlayer2, position2)
    -- 还原默认状态
    mVSPKTable.Result1.gameObject:SetActive(false)
    mVSPKTable.Result2.gameObject:SetActive(false)

    local tweenScript1 = mVSPKTable.PKPlayer1:GetComponent('TweenTransform')
    tweenScript1:ResetToBeginning()
    tweenScript1.from = mVSPKTable.PKPos[position1]
    tweenScript1.to = mVSPKTable.PKPosTargets[1]
    tweenScript1:Play(true)

    local tweenScript2 = mVSPKTable.PKPlayer2:GetComponent('TweenTransform')
    tweenScript2:ResetToBeginning()
    tweenScript2.from = mVSPKTable.PKPos[position2]
    tweenScript2.to = mVSPKTable.PKPosTargets[2]
    tweenScript2:Play(true)

    mVSPKTable.PKVImage.gameObject:SetActive(false)
    mVSPKTable.PKSImage.gameObject:SetActive(false)

    RandomPlayBipaiSound(position2)
end

-- 比牌开始音效
function RandomPlayBipaiSound(positionParam)
    local IsMan = false
    for k=1,#data.PublicConfig.HeadIconMan,1 do
        if mRoomData.JHPlayers[positionParam].HeadIcon == data.PublicConfig.HeadIconMan[k] then
            IsMan = true
            break
        end
    end
    local Index =math.random(2)
    local MusicidName="JH_bipai_man_"..Index
    if IsMan == false then
        MusicidName = "JH_bipai_woman_"..Index
    end
    PlaySoundEffect(MusicidName)
    --[[local _random = mBipaiSoundRandom % mBipaiSoundRandomFactor + 1
    PlaySoundEffect('JH_bipai_' .. _random)
    mBipaiSoundRandom = mBipaiSoundRandom + 1--]]
end

-- 设置挑战者基础信息
function SetChallengerInfo(target, positionParam)
    local playerData = mRoomData.JHPlayers[positionParam]
    local head1 = target:Find('HeadIcon'):GetComponent('Image')
    head1:ResetSpriteByName(GameData.GetRoleIconSpriteName(playerData.HeadIcon))
    target:Find('Text'):GetComponent('Text').text = playerData.Name
end

-- VS 2字飞向中间
function PlayCardVSAnimationStep2()
    mVSPKTable.PKVImage.gameObject:SetActive(true)
    mVSPKTable.PKSImage.gameObject:SetActive(true)
    local tweenPosition1 = mVSPKTable.PKVImage:GetComponent('TweenPosition')
    tweenPosition1:ResetToBeginning()
    tweenPosition1:Play(true)
    local tweenPosition2 = mVSPKTable.PKSImage:GetComponent('TweenPosition')
    tweenPosition2:ResetToBeginning()
    tweenPosition2:Play(true)
    -- VS音效
    PlaySoundEffect('JH_vs_1')
end

-- 设置比牌结果
function PlayCardVSAnimationStep3(positionParam1,positionParam2, winPosParam)
    this.transform:Find('Canvas/VSPK/PKVImage').gameObject:SetActive(true)
    this.transform:Find('Canvas/VSPK/PKSImage').gameObject:SetActive(true)
    local ResultWin1 = mVSPKTable.Result1:Find("WinImage"):GetComponent('TweenScale')
    local ResultFail1 = mVSPKTable.Result1:Find("FailImage"):GetComponent('TweenScale')
    local ResultWin2 = mVSPKTable.Result2:Find("WinImage"):GetComponent('TweenScale')
    local ResultFail2 = mVSPKTable.Result2:Find("FailImage"):GetComponent('TweenScale')
    ResultWin1:ResetToBeginning()
    ResultFail1:ResetToBeginning()
    ResultWin2:ResetToBeginning()
    ResultFail2:ResetToBeginning()
    if positionParam1 == winPosParam then
        mVSPKTable.Result1.gameObject:SetActive(true)
        mVSPKTable.Result2.gameObject:SetActive(false)
        ResultWin1:Play(true)
        ResultFail1:Play(true)
    else
        mVSPKTable.Result1.gameObject:SetActive(false)
        mVSPKTable.Result2.gameObject:SetActive(true)
        ResultWin2:Play(true)
        ResultFail2:Play(true)
    end
    -- 比牌结果音效
    PlaySoundEffect('JH_vs_2')
end

-- 比牌玩家位置还原飞回去
function PlayCardVSAnimationStep4(positionParam1,positionParam2, winPosParam)
    mVSPKTable.Result1.gameObject:SetActive(false)
    mVSPKTable.Result2.gameObject:SetActive(false)
    local ChallengerPosition = mRoomData.ChallengerPosition
    local ActorPosition = mRoomData.ActorPosition

    local tweenScript1 = mVSPKTable.PKPlayer1:GetComponent('TweenTransform')
    tweenScript1:ResetToBeginning()
    tweenScript1.from = mVSPKTable.PKPosTargets[1] 
    tweenScript1.to =   mVSPKTable.PKPos[positionParam1]
    tweenScript1:Play(true)

    local tweenScript2 = mVSPKTable.PKPlayer2:GetComponent('TweenTransform')
    tweenScript2:ResetToBeginning()
    tweenScript2.from = mVSPKTable.PKPosTargets[2]
    tweenScript2.to =  mVSPKTable.PKPos[positionParam2]
    tweenScript2:Play(true)
end

-- 比牌玩家显示状态还原
function PlayCardVSAnimationStep5(positionParam1,positionParam2, winPosParam)
    mPlayersUIInfo[positionParam1].TransformRoot:SetActive(true)
    mPlayersUIInfo[positionParam2].TransformRoot:SetActive(true)
    VSPKShow(false)
    local _failPos = 1
    if positionParam1 == winPosParam then
        _failPos = positionParam2
    else
        _failPos = positionParam1
    end
    HandlePlayerBPSImageState(_failPos)
end

-- ==============================--
-- desc:比牌模块
-- time:2017-11-15 10:27:36
-- @return
-- ==============================--

-- 玩家比牌按钮call
function OnBPButtonClick()
    -- body
    local vsCount, positionParam = CheckVSCard()
    if vsCount > 1 then
        for index = 1, JHZUJU_ROOM_PLAYER_MAX - 1, 1 do
            local playerData = mRoomData.JHPlayers[index]
            if playerData.PlayerState == PlayerStateEnum.JoinOK then
                if playerData.CompareState == 1 or playerData.DropCardState == 1 then
                    -- 玩家比牌输或者已经弃牌
                else
                    mPlayersUIInfo[index].VSOKButtonGameObject:SetActive(true)
                end
            end
        end
        PKSelectShow(true)
    elseif vsCount == 1 then
        TrySend_CS_JH_VS_Card(positionParam)
    else
        -- TODO
    end
end

-- 选择比牌玩家call
function OnVSOKButtonOnclick(positionParam)
    -- 还原状态
    for index = 1, JHZUJU_ROOM_PLAYER_MAX - 1, 1 do
        mPlayersUIInfo[index].VSOKButtonGameObject:SetActive(false)
    end
    PKSelectShow(false)
    TrySend_CS_JH_VS_Card(positionParam)
end

-- 请求比牌
function TrySend_CS_JH_VS_Card(positionParam)
    local playerData = mRoomData.JHPlayers[positionParam]
    if playerData.PlayerState == PlayerStateEnum.JoinOK then
        if playerData.CompareState == 1 or playerData.DropCardState == 1 then
            -- 玩家已经弃牌
            CS.BubblePrompt.Show('玩家状态有误，请重新选择.', "GameUI1")
        else
            NetMsgHandler.Send_CS_JH_VS_Card(playerData.AccountID, 1)
        end
    end
end

--==============================--
--desc:隐藏比牌选择
--time:2017-12-01 09:06:47
--@return 
--==============================--
function OnHidePKSelectClick()
    PKSelectShow(false)
end

function PKSelectShow(showParam)
    this.transform:Find('Canvas/PKSelect').gameObject:SetActive(showParam)
end


-- 检查可以参与比牌的玩家数量
function CheckVSCard()
    local count = 0
    local positionParam = 0
    for index = 1, JHZUJU_ROOM_PLAYER_MAX - 1, 1 do
        local playerData = mRoomData.JHPlayers[index]
        if playerData.PlayerState == PlayerStateEnum.JoinOK then
            if playerData.CompareState == 1 or playerData.DropCardState == 1 then
                -- TODO 玩家已经比牌输或者弃牌
            else
                count = count + 1
                positionParam = index
            end
        end
    end
    return count, positionParam
end


-- ===============【结算阶段】【6】 ROOM_STATE_JHWR.Settlement===============--

function RefreshSettlementPartOfGameByRoomState(roomStateParam, initParam)
    -- body
    if roomStateParam == ROOM_STATE_JHWR.Settlement then
        MasterKPButtonShow(false)
        this:DelayInvoke(0, function() ShowPlayerMingCard() end)
        this:DelayInvoke(2, function() PlayWinerCollectChipsAnimation() end)
        this:DelayInvoke(2.5, function() PlayWinnerWinText() end)
    else
        -- 玩家赢取金币数值还原
        ResetPlayerWinText(roomStateParam)
    end
end

-- 展示翻牌玩家数据
function ShowPlayerMingCard()
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        if mRoomData.JHPlayers[position].IsShowPokerCard == true then
            PlayerFlipPokerAnimation(position)
            HandlePlayerGameOverStateShow(position)
        end
    end
end

-- 展示赢加收取筹码
function PlayWinerCollectChipsAnimation()
    if mRoomData.WinnerCount == 1 then
        -- 一人是赢家
        local _chipCount = 0
        local posTable = GetWinnerPositions()
        for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
            local childCount = CHIP_JOINTS[position].JointPoint.childCount
            if childCount ~= 0 then
                for index = childCount - 1, 0, -1 do
                    local chipItem = CHIP_JOINTS[position].JointPoint:GetChild(index)
                    local lastTime = 0.5
                    local endPoint = CHIP_START[posTable[1]].position
                    local script = CS.TweenPosition.Begin(chipItem.gameObject, lastTime, endPoint, true)
                    script.delay = CS.UnityEngine.Random.Range(0, 0.5)
                    script:OnFinished('+',( function() 
                        CS.UnityEngine.Object.Destroy(chipItem.gameObject)
                    end))
                    script:Play(true)
                    if _chipCount < 5 then
                        -- 收筹码音效
                        PlaySoundEffect('7')
                    end
                    _chipCount = _chipCount + 1
                end
            end
        end
    elseif mRoomData.WinnerCount > 1 then
        -- 多人是赢家
        -- 整理所有筹码
        local chipsTable = { }
        for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
            local childCount = CHIP_JOINTS[position].JointPoint.childCount
            if childCount ~= 0 then
                for index = childCount - 1, 0, -1 do
                    local chipItem = CHIP_JOINTS[position].JointPoint:GetChild(index)
                    table.insert(chipsTable, chipItem)
                end
            end
        end

        local posTable = GetWinnerPositions()
        local chipsCount = #chipsTable
        local _chipCount = 0
        for index = 1, chipsCount, 1 do
            local chipItem = chipsTable[index]
            local lastTime = 0.5
            -- 结束点位
            local posTableCount = #posTable
            local endPosIndex = index % posTableCount
            if endPosIndex == 0 then
                endPosIndex = posTableCount
            end
            local endPoint = CHIP_START[posTable[endPosIndex]].position

            local script = CS.TweenPosition.Begin(chipItem.gameObject, lastTime, endPoint, true)
            script.delay = CS.UnityEngine.Random.Range(0, 0.5)
            script:OnFinished('+',( function() CS.UnityEngine.Object.Destroy(chipItem.gameObject) end))
            script:Play(true)
            if _chipCount < 5 then
                -- 收筹码音效
                PlaySoundEffect('7')
            end
            _chipCount = _chipCount + 1
        end
    end
    -- 自己是赢家有音效表现
    if mMasterData.IsWinner == true then
        PlaySoundEffect('game_win')
    end

end

-- 获取赢家位置集合
function GetWinnerPositions()
    local posTable = { }
    for index = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        if mRoomData.JHPlayers[index].IsWinner then
            table.insert(posTable, index)
        end
    end
    return posTable
end

-- 赢家获取金币变化
function PlayWinnerWinText()
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        local playerData = mRoomData.JHPlayers[position]
        mPlayersUIInfo[position].WinText.text = ''
        if playerData.IsWinner then
            SetPlayerGoldValue(position)
            -- 赢家
            mPlayersUIInfo[position].WinText.text = lua_CommaSeperate(playerData.WinGoldValue)
            local script = mPlayersUIInfo[position].WinText.transform:GetComponent('TweenPosition')
            script:ResetToBeginning()
            script:Play(true)
            local script2 = mPlayersUIInfo[position].WinText.transform:GetComponent('TweenAlpha')
            script2:ResetToBeginning()
            script2:Play(true)
        end
    end
end

-- 玩家赢取金币数值还原
function ResetPlayerWinText(roomStateParam)
    if roomStateParam == ROOM_STATE_JHWR.Wait then
        for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
            mPlayersUIInfo[position].WinText.text = ''
        end
    end
end


-- ==============================================================================

-- 添加一个玩家
function OnNotifyZUJUAddPlayerEvent(positionParam)
    ResetPlayerInfo2Defaul(positionParam)
    HandlePositionPlayerInfo(positionParam)
end

-- 删除某个玩家
function OnNotifyZUJUDeletePlayerEvent(positionParam)
    ResetPlayerInfo2Defaul(positionParam)
    HandlePositionPlayerInfo(positionParam)
    ResetPlayerCardToDefault(positionParam)
end
-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.JhRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.JhRankTime >= 60 then
        return true
    end
    return false
end

-- 响应排行榜按钮点击事件
function RankButtonOnClick()
    SetCaidanShow(false)
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = GAME_RANK_TYPE.JH_MONEY
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(GAME_RANK_TYPE.JH_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.JH_MONEY)
    end
end

--=================3局切换房间黑屏表现=====================

local mRoomChangeGameObject = nil

function InitRoomChange()
    mRoomChangeGameObject = this.transform:Find('Canvas/RoomChange').gameObject
    GameObjectSetActive(mRoomChangeGameObject, false)
end

function OnNotifyRoomChangeEvent()
    mRoomChangeGameObject = this.transform:Find('Canvas/RoomChange').gameObject
    GameObjectSetActive(mRoomChangeGameObject, true)
    this:DelayInvoke(1.0, function ()
        GameObjectSetActive(mRoomChangeGameObject, false)
        CS.BubblePrompt.Show(data.GetString("T_430_1"), "HallUI")
    end)
end

function Awake()
    DoHelp();
    InitUIElement()
    AddButtonHandlers()
    RestoreUI2Default()
    -- body
    if mRoomData.RoomID > 0 then
        ResetGameToRoomState(mRoomData.RoomState)
    end
    ChangeRoomImageShow(false)
    InitRoomChange()
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
end

function Start()
    CS.MatchLoadingUI.Hide()
end

-- UI 开启
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, ResetGameToRoomState)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoomState, RefreshGameByRoomStateSwitchTo)

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZUJUPlayerReadyStateEvent, OnNotifyZUJUPlayerReadyStateEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZUJUAddPlayerEvent, OnNotifyZUJUAddPlayerEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZUJUDeletePlayerEvent, OnNotifyZUJUDeletePlayerEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZUJUBettingEvent, OnNotifyZUJUBettingEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZUJUDropCardEvent, OnNotifyZUJUDropCardEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZUJULookCardEvent, OnNotifyZUJULookCardEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyMenJiRoomChangeEvent, OnNotifyMenJiRoomChangeEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotZUJU_Gold_Update, HandlePositionPlayerInfo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyRoomChangeEvent, OnNotifyRoomChangeEvent)
    MusicMgr:PlayBackMusic("BG_YSZ")
end

-- UI 关闭
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, ResetGameToRoomState)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoomState, RefreshGameByRoomStateSwitchTo)

    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZUJUPlayerReadyStateEvent, OnNotifyZUJUPlayerReadyStateEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZUJUAddPlayerEvent, OnNotifyZUJUAddPlayerEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZUJUDeletePlayerEvent, OnNotifyZUJUDeletePlayerEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZUJUBettingEvent, OnNotifyZUJUBettingEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZUJUDropCardEvent, OnNotifyZUJUDropCardEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZUJULookCardEvent, OnNotifyZUJULookCardEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyMenJiRoomChangeEvent, OnNotifyMenJiRoomChangeEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotZUJU_Gold_Update, HandlePositionPlayerInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyRoomChangeEvent, OnNotifyRoomChangeEvent)
end

-- 每一帧更新
function Update()
    GameData.ReduceRoomCountDownValue(Time.deltaTime)
    UpdateCurrentBettingCD()
end

function OnDestroy()
    -- body
    lua_Call_GC()
end