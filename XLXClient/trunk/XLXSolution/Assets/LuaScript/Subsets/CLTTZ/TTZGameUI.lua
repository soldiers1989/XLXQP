

local mTime = CS.UnityEngine.Time
-- 当前房间信息数据
local mRoomData = { }
-- 主角数据
local mMasterData = {}
-- UI组件根节点
local mMyTransform = nil

local mReturnGameObject = nil                   -- 返回菜单组件
local mGameRuleGameObject = nil                 -- 游戏规则组件
local mZBButtonGameObject = nil                 -- 准备按钮组件
local mQZButtonGameObject = nil                 -- 抢庄按钮组件
local mQZTipsGameObject = nil                   -- 抢庄提示组件
local mQZWaitTipsGameObject = nil               -- 抢庄等待组件
local mJBButtonsGameObject = nil                -- 下注按钮组件
local mBettingWaitTipsGameObject = nil          -- 下注等待组件
local mKanPaiButtonGameObject = nil             -- 看牌按钮组件
local mKanPaiWaitTipsGameObject = nil           -- 看牌等待组件
local mWaitTips1GameObject = nil                -- 房主开始游戏Tips
local mWaitTips2GameObject = nil                -- 等待下一局开始Tips
local mWaitTips3GameObject = nil                -- 结束等待Tips
local mRoomNumberGameObject = nil               -- 房间密码组件
local mRoomNumberText = nil                     -- 房间密码Text
local mCountDownGameObject = nil                -- CD组件
local mCountDownText = nil                      -- CD组件Text
local mExitButtonScript = nil                   -- 退出房间按钮组件Script

-- 玩家UI节点
local PlayerUINode = 
{
    RootGameObject = nil,
    HeadRoot = nil,
    HeadIcon = nil,
    NameText = nil,
    GoldText = nil,
    WaitTipsGameObject = nil,
    DoubleTipsGameObject = nil,
    DoubleTipsText = nil,
    QZGameObject = nil,
    QZOKGameObject = nil,
    QZNOGameObject = nil,
    PokerTypeGameObject = nil,                  -- 牌型组件
    PokerTypeImage = nil,
    PokerTypeXText = nil,                       -- 牌型赔率
    ZBImage = nil,
    BankerTips1GameObject = nil,
    BankerTips2GameObject = nil,
    BankerTips3GameObject = nil,
    BankerTipsFlyAnimation = nil,
    CardRoot = nil,
    Cards = { },
    Points = { },
    WinText = nil,                              -- 赢钱Text
    LoseText = nil,                             -- 输钱Text
    ChipPoint = nil,                            -- 筹码移动组件
}

local mPlayerUINodes = {}
local mPointsCenter = nil                       -- 牌型中心点
local mBankerTipsGameObject = nil               -- 庄家标识组件
local mResultGameObject = nil                   -- 结算组件
local mChipRoot = nil                           -- 筹码挂接组件
local mChipItems = {}                           -- 筹码Items

local mMasterPosition = MAX_TTZZUJU_ROOM_PLAYER
local canPlaySoundEffect = false                            -- 能开始播放音效(进入房间时有很多东西需要筹备 筹备完毕才能开始播放)
-- 本局玩家可以下注倍率
local mTTZ_ZUJU_JIABEI = 
{
    [1] = 2,
    [2] = 3,
    [3] = 4,
    [4] = 5,
}

local isUpdateQiangZhuangCountDown = false      -- 是否计时抢庄CD
local isUpdateDoubleCountDown = false           -- 是否计时 玩家加倍CD
local isUpdateCuoPokerCountDown = false         -- 是否计时搓牌等待CD
local isUpdateGameOverWaitCountDown = false     -- 是否计时结算等待CD
local mPlayAudioRandom = 1                      -- 随机音效因子

function InitUIElement()
    mReturnGameObject = mMyTransform:Find('Canvas/ReturnButton/ReturnButton1').gameObject
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/MaskButton').gameObject:SetActive(true)
    mGameRuleGameObject = mMyTransform:Find('Canvas/GameRule').gameObject
    mZBButtonGameObject = mMyTransform:Find('Canvas/MasterInfo/ZBButton').gameObject
    mQZButtonGameObject = mMyTransform:Find('Canvas/MasterInfo/QZButton').gameObject
    mQZTipsGameObject = mMyTransform:Find('Canvas/MasterInfo/QZTips').gameObject
    mQZWaitTipsGameObject = mMyTransform:Find('Canvas/MasterInfo/QZWaitTips').gameObject
    
    mJBButtonsGameObject = mMyTransform:Find('Canvas/MasterInfo/JBButtons').gameObject
    mBettingWaitTipsGameObject = mMyTransform:Find('Canvas/MasterInfo/BettingWaitTips').gameObject
    mKanPaiButtonGameObject = mMyTransform:Find('Canvas/MasterInfo/KanPaiButton').gameObject
    mKanPaiWaitTipsGameObject = mMyTransform:Find('Canvas/MasterInfo/KanPaiWaitTips').gameObject

    mWaitTips1GameObject = mMyTransform:Find('Canvas/WaitTips1').gameObject
    mWaitTips2GameObject = mMyTransform:Find('Canvas/WaitTips2').gameObject
    mWaitTips3GameObject = mMyTransform:Find('Canvas/WaitTips3').gameObject
    mWaitTips3Text = mMyTransform:Find('Canvas/WaitTips3/TipsText'):GetComponent("Text")

    mRoomNumberGameObject = mMyTransform:Find('Canvas/RoomNumber').gameObject
    mRoomNumberText = mMyTransform:Find('Canvas/RoomNumber/Text'):GetComponent("Text")
    mCountDownGameObject = mMyTransform:Find('Canvas/CountDown').gameObject
    mCountDownText = mMyTransform:Find('Canvas/CountDown/ValueText'):GetComponent("Text")
    mPointsCenter = mMyTransform:Find('Canvas/Players/PokerPoints/Points1')
    mBankerTipsGameObject = mMyTransform:Find('Canvas/BankerTips').gameObject
    mResultGameObject = mMyTransform:Find('Canvas/Result').gameObject
    mChipRoot = mMyTransform:Find('Canvas/Result/ChipRoot')
    mExitButtonScript = mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/ExitButton'):GetComponent('Button')
    -- 筹码组件
    for index = 1, 5, 1 do
        mChipItems[index] = nil
        mChipItems[index] = mMyTransform:Find('Canvas/Result/ChipJoint/ChipItems/Chip'..index)
    end
    mChipRoot = mMyTransform:Find('Canvas/Result/ChipRoot')

    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        local childItem = mMyTransform:Find('Canvas/Players/Player'..position)
        mPlayerUINodes[position] = lua_NewTable(PlayerUINode)
        mPlayerUINodes[position].RootGameObject = childItem.gameObject
        mPlayerUINodes[position].HeadRoot = childItem:Find('Head').gameObject
        mPlayerUINodes[position].HeadIcon = childItem:Find('Head/HeadIcon/Icon'):GetComponent('Image')
        mPlayerUINodes[position].NameText = childItem:Find('Head/NameText'):GetComponent('Text')
        mPlayerUINodes[position].GoldText = childItem:Find('Head/GoldText'):GetComponent('Text')
        mPlayerUINodes[position].WaitTipsGameObject = childItem:Find('Head/WaitTips').gameObject
        mPlayerUINodes[position].DoubleTipsGameObject = childItem:Find('DoubleTips').gameObject
        mPlayerUINodes[position].DoubleTipsText = childItem:Find('DoubleTips/TipsOK/Text'):GetComponent('Text')
        mPlayerUINodes[position].QZGameObject = childItem:Find('QZ').gameObject
        mPlayerUINodes[position].QZOKGameObject = childItem:Find('QZ/OK').gameObject
        mPlayerUINodes[position].QZNOGameObject = childItem:Find('QZ/NO').gameObject
        mPlayerUINodes[position].PokerTypeGameObject = childItem:Find('PokerType').gameObject
        mPlayerUINodes[position].PokerTypeImage = childItem:Find('PokerType/TypeIcon'):GetComponent('Image')
        mPlayerUINodes[position].PokerTypeXText = childItem:Find('PokerType/TypeIcon/XText'):GetComponent('Text')
        mPlayerUINodes[position].ZBImage = childItem:Find('ZBImage').gameObject
        mPlayerUINodes[position].BankerTips1GameObject = childItem:Find('Head/BankerTips1').gameObject
        mPlayerUINodes[position].BankerTips2GameObject = childItem:Find('Head/BankerTips2').gameObject
        mPlayerUINodes[position].BankerTipsFlyAnimation = childItem:Find('Head/BankerTips2/BankerTips'):GetComponent('TweenTransform')
        mPlayerUINodes[position].BankerTips3GameObject = childItem:Find('Head/BankerTips3').gameObject
        mPlayerUINodes[position].CardRoot = childItem:Find('Cards').gameObject
        mPlayerUINodes[position].Cards = {} 
        mPlayerUINodes[position].Cards[1] = childItem:Find('Cards/Card1')
        mPlayerUINodes[position].Cards[2] = childItem:Find('Cards/Card2')
        mPlayerUINodes[position].Points = {}
        mPlayerUINodes[position].Points[1] = childItem:Find('Cards/Points1')
        mPlayerUINodes[position].Points[2] = childItem:Find('Cards/Points2')
        mPlayerUINodes[position].WinText = mMyTransform:Find('Canvas/Result/Player'..position..'/WinText'):GetComponent('Text')
        mPlayerUINodes[position].LoseText = mMyTransform:Find('Canvas/Result/Player'..position..'/LoseText'):GetComponent('Text')
        mPlayerUINodes[position].ChipPoint = mMyTransform:Find('Canvas/Result/ChipJoint/Point'..position)
        ResetTTZPlayerUINode(mPlayerUINodes[position])
    end

    mReturnGameObject:SetActive(false)
    mGameRuleGameObject:SetActive(false)
    mZBButtonGameObject:SetActive(false)
    mQZButtonGameObject:SetActive(false)
    mQZTipsGameObject:SetActive(false)
    mQZWaitTipsGameObject:SetActive(false)
    mJBButtonsGameObject:SetActive(false)
    mBettingWaitTipsGameObject:SetActive(false)
    mKanPaiButtonGameObject:SetActive(false)
    mKanPaiWaitTipsGameObject:SetActive(false)
    mWaitTips1GameObject:SetActive(false)
    mWaitTips2GameObject:SetActive(false)
    mWaitTips3GameObject:SetActive(false)
    mCountDownGameObject:SetActive(false)
    mBankerTipsGameObject:SetActive(false)

    if GameConfig.IsSpecial() == true then
        mMyTransform:Find('Canvas/StoreButton').gameObject:SetActive(false)
        mMyTransform:Find('Canvas/Notice').gameObject:SetActive(false)
        mMyTransform:Find('Canvas/NotifyButtons').gameObject:SetActive(false)
    end
end

function AddButtonHandlers()
    mMyTransform:Find('Canvas/ReturnButton'):GetComponent("Button").onClick:AddListener( function() ReturnTransformSetActive(true) end )
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1'):GetComponent("Button").onClick:AddListener(function() ReturnTransformSetActive(false) end)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/MaskButton'):GetComponent("Button").onClick:AddListener(function() ReturnTransformSetActive(false) end)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/ExitButton'):GetComponent("Button").onClick:AddListener(ExitButton_OnClick)

    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/GameRuleButton'):GetComponent("Button").onClick:AddListener(function() GameRuleSetActive(true) end)
    mMyTransform:Find('Canvas/GameRule/CloseBtn'):GetComponent("Button").onClick:AddListener(function() GameRuleSetActive(false) end)
    mMyTransform:Find('Canvas/StoreButton'):GetComponent("Button").onClick:AddListener(StoreButton_OnClick)
    mMyTransform:Find('Canvas/ReturnButton/ReturnButton1/RankButton'):GetComponent("Button").onClick:AddListener(RankButtonOnClick)
    mMyTransform:Find('Canvas/MasterInfo/ZBButton'):GetComponent("Button").onClick:AddListener(ZBButtonOnClick)
    mMyTransform:Find('Canvas/MasterInfo/QZButton/OK'):GetComponent("Button").onClick:AddListener(function() QZButtonOK_OnClick(true) end)
    mMyTransform:Find('Canvas/MasterInfo/QZButton/NO'):GetComponent("Button").onClick:AddListener(function() QZButtonOK_OnClick(false) end)

    mMyTransform:Find('Canvas/MasterInfo/JBButtons/JBButton1'):GetComponent("Button").onClick:AddListener(function() JBButton_OnClick(1) end)
    mMyTransform:Find('Canvas/MasterInfo/JBButtons/JBButton2'):GetComponent("Button").onClick:AddListener(function() JBButton_OnClick(2) end)
    mMyTransform:Find('Canvas/MasterInfo/JBButtons/JBButton3'):GetComponent("Button").onClick:AddListener(function() JBButton_OnClick(3) end)
    mMyTransform:Find('Canvas/MasterInfo/JBButtons/JBButton4'):GetComponent("Button").onClick:AddListener(function() JBButton_OnClick(4) end)
    mMyTransform:Find('Canvas/MasterInfo/KanPaiButton'):GetComponent("Button").onClick:AddListener(KanPaiButton_OnClick)
end

--==============================--
--desc:返回菜单显示状态
--time:2018-03-01 09:46:42
--@isShow:
--@return 
--==============================--
function ReturnTransformSetActive(isShow)
    GameObjectSetActive(mReturnGameObject, isShow)
    if isShow then
        this.transform:Find('Canvas/ReturnButton/true').gameObject:SetActive(false)
        this.transform:Find('Canvas/ReturnButton/false').gameObject:SetActive(true)
    else
        this.transform:Find('Canvas/ReturnButton/true').gameObject:SetActive(true)
        this.transform:Find('Canvas/ReturnButton/false').gameObject:SetActive(false)
    end
    if isShow then
        mExitButtonScript.interactable = TTZCheckQuitGame()
    end
end

-- 玩家能否离开游戏检测
function TTZCheckQuitGame( )
    local quit = true
    if mMasterData.PlayerState < PlayerStateEnumTTZ.JoinOK then
        quit = true
    else
        quit = false
    end
    return quit
end


function GameRuleSetActive( isActive )
    GameObjectSetActive(mGameRuleGameObject, isActive)
end

function ExitButton_OnClick()
    ReturnTransformSetActive(false)
    if TTZCheckQuitGame() then
        NetMsgHandler.Send_CS_TTZ_LEAVE_ROOM()
    end
end

--==============================--
--desc:邀请按钮call
--time:2018-02-27 08:18:26
--@return 
--==============================--
function InviteButton_OnClick()
    local tRoomID = mRoomData.RoomID
    local tRoomType = mRoomData.RoomType
    local tBet = mRoomData.MinBet
    local tEnterLimit = mRoomData.MinBet * 200
    local tBet = lua_NumberToStyle1String(tBet)
    local tEnterLimit = lua_NumberToStyle1String(tEnterLimit)
    GameData.OpenIniteUI(tRoomID, tRoomType, tBet, tEnterLimit)
end

--==============================--
--desc:商城按钮call
--time:2018-02-27 08:20:43
--@return 
--==============================--
function StoreButton_OnClick()
    GameConfig.OpenStoreUI()
end

--==============================--
--desc:音效播放接口
--time:2018-02-28 09:14:54
--@musicid:
--@return 
--==============================--
function PlayAudioClip(musicid)
    if true == canPlaySoundEffect then
        MusicMgr:PlaySoundEffect(musicid)
    end
end

-- 初始化房间到初始状态
function InitTTZRoomBaseInfos()

    SetTTZRoomBaseInfo()
    GameObjectSetActive(mReturnGameObject, false)
    GameObjectSetActive(mCountDownGameObject,false)
    GameObjectSetActive(mWaitTips1GameObject,false)
    GameObjectSetActive(mWaitTips2GameObject,false)
    GameObjectSetActive(mWaitTips3GameObject,false)
    ResetTTZGamePositionInfo()
    -- 各个位置动画清理
    for pokerIndex = 1, 2, 1 do
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            local cardItem = mPlayerUINodes[position].Cards[pokerIndex]
            lua_Clear_AllUITweener(cardItem)
            CS.Utility.ReSetTransform(cardItem, mPlayerUINodes[position].CardRoot.transform)
        end
    end 
end

-- 设置房间基础信息
function SetTTZRoomBaseInfo()

    mRoomNumberText.text = tostring(mRoomData.RoomID)
    this.transform:Find('Canvas/RoomRule'):GetComponent('Text').text = TTZGetRoomRuleTips(mRoomData.MinBet)
    GameObjectSetActive(mRoomNumberGameObject,mRoomData.RoomType == ROOM_TYPE.ZuJuTTZ) 
end

-- 获取房间规则显示描述1
function TTZGetRoomRuleTips(nBet)
    local ruleTips = string.format( data.GetString(string.format( "TTZ_Rule_Tip_%d_%d",mRoomData.LightPoker,mRoomData.CompensateType )),lua_NumberToStyle1String(mRoomData.MinBet))
        if mRoomData.RoomType == ROOM_TYPE.PiPeiTTZ then
            ruleTips = string.format( data.GetString("TTZ_Rule_Tip"),lua_NumberToStyle1String(mRoomData.MinBet))
        end
    return ruleTips
end

-- 重置游戏座位信息
function ResetTTZGamePositionInfo()
    -- 重置座位信息
    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        ResetTTZPlayerUINode(mPlayerUINodes[position])
        SetTTZPlayerSitdownState(position)
        SetTTZPlayerBaseInfo(position)
    end
end

-- 重置玩家信息归零
function ResetTTZPlayerUINode(tPlayer)
    if nil == tPlayer then
        return
    end
    tPlayer.NameText.text = ""
    tPlayer.GoldText.text = ""
    tPlayer.HeadRoot:SetActive(true)
    
    tPlayer.WaitTipsGameObject:SetActive(false)
    tPlayer.DoubleTipsGameObject:SetActive(false)
    
    tPlayer.ZBImage:SetActive(false)
    tPlayer.PokerTypeGameObject:SetActive(false)
    tPlayer.QZGameObject:SetActive(false)
    tPlayer.BankerTips1GameObject:SetActive(false)
    tPlayer.BankerTips2GameObject:SetActive(false)
    tPlayer.BankerTips3GameObject:SetActive(false)
    tPlayer.Cards[1].gameObject:SetActive(false)
    tPlayer.Cards[2].gameObject:SetActive(false)
end


local mCurrentCDTime = 0
-- 刷新倒计时CD显示
function RefreshCountDownText()
    if nil == mCountDownText then
        return
    end
    local countDown = math.ceil(mRoomData.CountDown)
    if countDown <= 0 then
        countDown = 0
    end
    if mCurrentCDTime ~= countDown then
        mCurrentCDTime = countDown
        mCountDownText.text = lua_FormatToCountdownStyle(mCurrentCDTime)
        ShowCountDown(true)
    end
end

-- 显示倒计时组件
function ShowCountDown(showParam)
    GameObjectSetActive(mCountDownGameObject,showParam)
end

--==============================--
--desc:重置房间到指定状态
--time:2018-02-28 08:02:35
--@roomState:
--@return 
--==============================--
function ResetTTZGameRoomToRoomState(roomState)
    mRoomData = GameData.RoomInfo.CurrentRoom
    mMasterData = mRoomData.TTZPlayerList[MAX_TTZZUJU_ROOM_PLAYER]
    canPlaySoundEffect = false
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    InitTTZRoomBaseInfos()
    RefreshTTZGameRoomToGameState(roomState,true)
    canPlaySoundEffect = true
    InitRoomChange()
end

-- 房间状态刷新
function RefreshTTZGameRoomByRoomStateSwitchTo( roomState )
    -- body
    RefreshTTZGameRoomToGameState(roomState,false)
end

--==============================--
--desc:刷新房间到指定状态
--time:2018-02-28 08:13:07
--@roomState:
--@isInit:
--@return 
--==============================--
function RefreshTTZGameRoomToGameState( roomState, isInit )
    print("========================",roomState,isInit)
    RefreshTTZReadyPartOfGameRoomByState(roomState, isInit)
    RefreshTTZDealPartOfGameRoomByState(roomState, isInit)
    RefreshTTZQiangZhuangPartOfGameRoomByState(roomState, isInit)
    RefreshTTZQiangZhuangOverPartOfGameRoomByState(roomState, isInit)
    RefreshTTZSetZhuangPartOfGameRoomByState(roomState, isInit)
    RefreshTTZXuanDoublePartOfGameRoomByState(roomState, isInit)
    RefreshTTZKanPaiPartOfGameRoomByState(roomState, isInit)
    RefreshSettlementPartOfGameRoomByState(roomState, isInit)
end


-- 重置房间信息到可以重新开局
function ResetGameRoomForReStart()
    -- 重置扑克牌显示
    ResetPokerCardVisible()
end

-- 重置扑克牌显示
function ResetPokerCardVisible()
    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        for cardIndex = 1, 2, 1 do
            SetTTZPokerCardVisible(mPlayerUINodes[position].Cards[cardIndex], false)
        end
    end
end

-------------------------------------------------------------------------------
------------------------【玩家准备阶段】[READY] [1]-----------------------------
function RefreshTTZReadyPartOfGameRoomByState( roomState, isInit )
    print("阶段")
    if roomState == ROOM_STATE_TTZ.READY or true == isInit then
        -- 调用下GC回收
        lua_Call_GC()
        this:StopAllDelayInvoke()
        ResetGameRoomForReStart()
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            GameObjectSetActive(mPlayerUINodes[position].ZBImage, mRoomData.TTZPlayerList[position].PlayerState == PlayerStateEnumTTZ.Ready)
        end

        if roomState == ROOM_STATE_TTZ.READY then
            GameObjectSetActive(mZBButtonGameObject,mMasterData.PlayerState ~= PlayerStateEnumTTZ.Ready)
        else
            GameObjectSetActive(mZBButtonGameObject,false)
        end
    else
        GameObjectSetActive(mZBButtonGameObject,false)
        -- 准备标记还原
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            GameObjectSetActive(mPlayerUINodes[position].ZBImage,false)
        end
    end
    -- 庄家标识显示状态
    if roomState >= ROOM_STATE_TTZ.READY and roomState <= ROOM_STATE_TTZ.QIANG_ZHUANG_OVER then
        GameObjectSetActive(mBankerTipsGameObject, true)
    else
        GameObjectSetActive(mBankerTipsGameObject, false)
    end

    if roomState <= ROOM_STATE_TTZ.DEAL then
        RefreshTTZAllPlayerWaitTips(true)
    else
        if roomState ~= ROOM_STATE_TTZ.SETTLEMENT then
            RefreshTTZAllPlayerWaitTips(false)
        end
    end

end

--==============================--
--desc:准备按钮call
--time:2018-02-27 08:26:07
--@return 
--==============================--
function ZBButtonOnClick()
    NetMsgHandler.Send_CS_TTZ_Ready()
end

--==============================--
--desc:玩家准备游戏
--time:2018-02-28 08:45:59
--@positionParam:
--@return 
--==============================--
function OnNotifyTTZPlayerReadyEvent( positionParam )
    if positionParam == mMasterPosition then
        GameObjectSetActive(mZBButtonGameObject,false)
    end
    GameObjectSetActive(mPlayerUINodes[positionParam].ZBImage,true)
end

-- 刷新所有玩家等待下一局标签
function RefreshTTZAllPlayerWaitTips(forceHideParam)
    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        RefreshTTZPlayerWaitTipsAndGoldText(position, forceHideParam)
    end
end

-- 刷新玩家等待下一局标记+金币显示
function RefreshTTZPlayerWaitTipsAndGoldText(positionParam, forceHideParam)
    local showObj = mPlayerUINodes[positionParam]
    local showData = mRoomData.TTZPlayerList[positionParam]
    if showData.PlayerState == PlayerStateEnumTTZ.NULL then
        showObj.WaitTipsGameObject:SetActive(false)
        showObj.GoldText.text = ""
        return
    end

    local isShow  = showData.PlayerState <= PlayerStateEnumTTZ.LookOn
    if forceHideParam then
        isShow = false
    end
    showObj.WaitTipsGameObject:SetActive(isShow)
    if isShow then
        showObj.GoldText.text = ""
    else
        showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.Gold,2))
    end
end

-------------------------------------------------------------------------------
------------------------【发牌阶段】[DEAL] [2]----------------------------------
function RefreshTTZDealPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_TTZ.DEAL then
        -- body
        if isInit == true then
            -- 直接将牌摆好
            for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
                if mRoomData.TTZPlayerList[position].PlayerState >= PlayerStateEnumTTZ.JoinOK then
                    for cardIndex = 1, 2, 1 do
                        GameObjectSetActive(mPlayerUINodes[position].Cards[cardIndex].gameObject,true)
                        lua_Paste_Transform_Value(mPlayerUINodes[position].Cards[cardIndex], mPlayerUINodes[position].Points[cardIndex])
                    end
                end
            end
            CheckSelfBefore1PokerLight(false)
        else
            PlayTTZDealAnimation()
        end
    else
        if isInit == true then
            -- 直接将牌摆好
            for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
                if mRoomData.TTZPlayerList[position].PlayerState >= PlayerStateEnumTTZ.JoinOK then
                    for cardIndex = 1, 2, 1 do
                        GameObjectSetActive(mPlayerUINodes[position].Cards[cardIndex].gameObject,true)
                        lua_Paste_Transform_Value(mPlayerUINodes[position].Cards[cardIndex], mPlayerUINodes[position].Points[cardIndex])
                    end
                end
            end
            CheckSelfBefore1PokerLight(false)
        end
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            if mRoomData.TTZPlayerList[position].PlayerState >= PlayerStateEnumTTZ.JoinOK then
                GameObjectSetActive(mPlayerUINodes[position].Cards[1].gameObject,roomState > ROOM_STATE_TTZ.DEAL)
                GameObjectSetActive(mPlayerUINodes[position].Cards[2].gameObject,roomState > ROOM_STATE_TTZ.DEAL)
            else
                GameObjectSetActive(mPlayerUINodes[position].Cards[1].gameObject,false)
                GameObjectSetActive(mPlayerUINodes[position].Cards[2].gameObject,false)
            end
        end
    end
end

-- 检测自己前3张是否需要名牌(参数:是否强制亮牌)
function CheckSelfBefore1PokerLight(isForceParam)
    if mMasterData.PlayerState >= PlayerStateEnumTTZ.JoinOK then
        if mRoomData.LightPoker == 1 or isForceParam == true then
            -- 前1张亮牌
            for index = 1, 1, 1 do
                local cardItem = mPlayerUINodes[mMasterPosition].Cards[index]
                local pokerCard = mMasterData.Pokers[index]
                SetTTZPokerCardVisible(cardItem, true)
                cardItem:GetComponent("Image"):ResetSpriteByName(TTZGameMgr.GetPokerCardSpriteName(pokerCard.PokerNumber))
            end
        end
    end
end

-- 发牌动画
function PlayTTZDealAnimation()
    -- 可以播放发牌动画的玩家
    local tresetPosition = { }
    for position = MAX_TTZZUJU_ROOM_PLAYER, 1, -1 do
        if mRoomData.TTZPlayerList[position].PlayerState == PlayerStateEnumTTZ.JoinOK then
            table.insert(tresetPosition, position)
        end
    end

    -- 发牌动画播放-
    for cardIndex = 2, 1, -1 do
        for k1, v1 in pairs(tresetPosition) do
            -- 位置重置中心
            CS.Utility.ReSetTransform(mPlayerUINodes[v1].Cards[cardIndex], mPointsCenter)
        end
    end
    local tcanPlayAnimationPosition = { }
    for index = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        if mRoomData.TTZPlayerList[index].PlayerState == PlayerStateEnumTTZ.JoinOK then
            table.insert(tcanPlayAnimationPosition, index)
        end
    end
    local delayTime = 0
    for pokerIndex = 1, 2, 1 do

        for k1, v1 in pairs(tcanPlayAnimationPosition) do
            SetTTZPokerCardVisible(mPlayerUINodes[v1].Cards[pokerIndex], false)

            local pokerCard1 = mRoomData.TTZPlayerList[v1].Pokers[pokerIndex]

            delayTime = delayTime + 0.1
            this:DelayInvoke(delayTime,
            function()
                mPlayerUINodes[v1].CardRoot:SetActive(true)
                local cardItem = mPlayerUINodes[v1].Cards[pokerIndex]
                lua_Clear_AllUITweener(cardItem)

                if cardItem.gameObject.activeSelf == false then
                    cardItem.gameObject:SetActive(true)
                end

                local pokerCard = mRoomData.TTZPlayerList[v1].Pokers[pokerIndex]
                local script = cardItem.gameObject:AddComponent(typeof(CS.TweenTransform))
                script.from = mPointsCenter
                script.to = mPlayerUINodes[v1].Points[pokerIndex]
                script.duration = 0.4
                script:OnFinished("+",
                ( function()
                    CS.UnityEngine.Object.Destroy(script)
                    if pokerCard.PokerNumber > 0 then
                        cardItem:GetComponent("Image"):ResetSpriteByName(TTZGameMgr.GetPokerCardSpriteName(pokerCard.PokerNumber))
                    end
                    SetTTZPokerCardVisible(cardItem, pokerCard.Visible)
                    CS.Utility.ReSetTransform(cardItem, mPlayerUINodes[v1].CardRoot.transform)
                    lua_Paste_Transform_Value(cardItem, script.to)
                end ))
                script:Play(true)
                -- 音效发牌音效
                PlayAudioClip('NN_fapai')
            end )

        end

    end
    
end

-- 设置玩家扑克牌是否可见
function SetTTZPokerCardVisible(pokerCard, isVisible)
    if nil == pokerCard then
        error('玩家扑克牌数据异常')
        return
    end
    if pokerCard:Find('back').gameObject.activeSelf == lua_NOT_BOLEAN(isVisible) then
        return
    end
    pokerCard:Find('back').gameObject:SetActive(lua_NOT_BOLEAN(isVisible))
end

-------------------------------------------------------------------------------
------------------------【抢庄阶段】[QIANG_ZHUANG] [3]--------------------------
function RefreshTTZQiangZhuangPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_TTZ.QIANG_ZHUANG then
        for index = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            local tPlayerState = mRoomData.TTZPlayerList[index].PlayerState
            if tPlayerState >= PlayerStateEnumTTZ.JoinOK then
                if tPlayerState >= PlayerStateEnumTTZ.QZOK then
                    RefreshPlayerQZState(index, true)
                else
                    RefreshPlayerQZState(index, false)
                    if index == mMasterPosition then
                        GameObjectSetActive(mQZButtonGameObject,true)
                    end
                end
            else
                mPlayerUINodes[index].QZGameObject:SetActive(false)
            end
        end
        RefreshQiangZhuangCountDownState(true)
        -- 自己未参与
        GameObjectSetActive(mQZWaitTipsGameObject, mMasterData.PlayerState < PlayerStateEnumTTZ.JoinOK)
    else
        GameObjectSetActive(mQZButtonGameObject,false)
        GameObjectSetActive(mQZWaitTipsGameObject,false)
        RefreshQiangZhuangCountDownState(false)
    end
end

function RefreshPlayerQZState(positionParam, showParam)
    if mPlayerUINodes[positionParam].QZGameObject.activeSelf == showParam then
        return
    end

    mPlayerUINodes[positionParam].QZGameObject:SetActive(showParam)
    local tPlayerState = mRoomData.TTZPlayerList[positionParam].PlayerState
    if showParam == true then
        mPlayerUINodes[positionParam].QZOKGameObject:SetActive(tPlayerState == PlayerStateEnumTTZ.QZOK)
        mPlayerUINodes[positionParam].QZNOGameObject:SetActive(tPlayerState == PlayerStateEnumTTZ.QZNO)
        local tweenScale = mPlayerUINodes[positionParam].QZGameObject.transform:GetComponent('TweenScale')
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)
        -- 延迟隐藏
        this:DelayInvoke(0.4,
        function()
            mPlayerUINodes[positionParam].QZGameObject.transform:GetComponent('TweenScale').enabled = false
        end )
        PlaySelfQZStateSound(positionParam)
    end
end

-- 刷新抢庄CD显示
function RefreshQiangZhuangCountDownState(isActive)
    ShowCountDown(isActive)
    isUpdateQiangZhuangCountDown = isActive
end

-- 更新抢庄CD
function UpdateQiangZhuangDown()
    if isUpdateQiangZhuangCountDown == true then
        RefreshCountDownText()
    end
end

--==============================--
--desc:抢庄按钮call
--time:2018-02-27 08:28:10
--@isOK:
--@return 
--==============================--
function QZButtonOK_OnClick( isOK )
    local qiangzhuang = PlayerStateEnumTTZ.QZOK
    if isOK == false then
        qiangzhuang = PlayerStateEnumTTZ.QZNO
    end
    NetMsgHandler.Send_CS_TTZ_QiangZhuang(qiangzhuang)
end

--==============================--
--desc:玩家抢庄
--time:2018-02-28 08:47:14
--@positionParam:
--@return 
--==============================--
function OnNotifyTTZPlayerQiangZhuangEvent( positionParam )
    RefreshPlayerQZState(positionParam, true)
    if positionParam == mMasterPosition then
        GameObjectSetActive(mQZButtonGameObject,false)
        GameObjectSetActive(mQZWaitTipsGameObject,true)
    end
end

-- 播放玩家自己抢庄表示语音
function PlaySelfQZStateSound(positionParam)
    if positionParam == mMasterPosition then
        if mMasterData.PlayerState == PlayerStateEnumNN.QiangZhuangOK then
            PlayAudioClip('NN_qiang_1')
        else
            PlayAudioClip('NN_qiang_2')
        end
    end
end

-------------------------------------------------------------------------------
------------------------【抢庄结束阶段】[QIANG_ZHUANG_OVER] [4]-----------------
function RefreshTTZQiangZhuangOverPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_TTZ.QIANG_ZHUANG_OVER then
        for index = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            if mRoomData.TTZPlayerList[index].PlayerState >= PlayerStateEnumTTZ.JoinOK then
                RefreshPlayerQZState(index, true)
            end
        end
    else
        for index = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            RefreshPlayerQZState(index, false)
        end
    end
end

-------------------------------------------------------------------------------
------------------------【定庄阶段】[SET_ZHUANG] [5]----------------------------
function RefreshTTZSetZhuangPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_TTZ.SET_ZHUANG then
        if initParam == true then
            RefreshBankerTagActive(mRoomData.BankerID, true)
            return
        end

        local tBankerJoin = { }
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            if mRoomData.TTZPlayerList[position].PlayerState >= PlayerStateEnumTTZ.JoinOK then
                if mRoomData.TTZPlayerList[position].PlayerState == PlayerStateEnumTTZ.QZOK then
                    table.insert(tBankerJoin, position)
                end
            else
                mPlayerUINodes[position].BankerTips1GameObject:SetActive(false)
            end
        end

        local bankerCount = #tBankerJoin
        if bankerCount > 1 then

            local tRoundResult = { }
            local circleCount = 3

            if bankerCount > 3 then
                circleCount = 2
            end

            -- 转2,3圈
            for index = 1, circleCount, 1 do
                for k1, v1 in pairs(tBankerJoin) do
                    table.insert(tRoundResult, v1)
                end
            end
            -- TODO 最后添加庄家进来
            local bankerPos = mRoomData.BankerID
            for index = 1, bankerPos, 1 do
                if mRoomData.TTZPlayerList[index].PlayerState >= PlayerStateEnumTTZ.JoinOK then
                    if mRoomData.TTZPlayerList[index].PlayerState == PlayerStateEnumTTZ.QZOK then
                        table.insert(tRoundResult, index)
                    end
                end
            end
            -- 每次停留时间
            local onceTime = 0.2
            for k2, v2 in pairs(tRoundResult) do
                this:DelayInvoke((k2 - 1) * onceTime,
                function()
                    mPlayerUINodes[v2].BankerTips1GameObject:SetActive(true)
                    this:DelayInvoke(onceTime,
                    function() mPlayerUINodes[v2].BankerTips1GameObject:SetActive(false) end )
                end )
            end
            -- 最后定庄显示
            this:DelayInvoke(#tRoundResult * onceTime,
            function()
                -- 定庄特效
                ShowTTZBankerEffect(bankerPos, true) 
            end )

            this:DelayInvoke(#tRoundResult * onceTime + 1,
            function()
                -- 飞庄特效
                RefreshBankerTagActive(bankerPos, true)
            end )


        elseif bankerCount == 1 then
            local bankerPos = mRoomData.BankerID
            RefreshBankerTagActive(bankerPos, true)
        else
            -- 无庄家
            print('本局无庄家*****')
        end
    elseif roomState > ROOM_STATE_TTZ.SET_ZHUANG then
        -- 处于选庄阶段之后
        local bankerPos = mRoomData.BankerID
        RefreshBankerTagActive(bankerPos, true)
    else
        -- TODO其他阶段
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            mPlayerUINodes[position].BankerTips1GameObject:SetActive(false)
            RefreshBankerTagActive(position, false)
            ShowTTZBankerEffect(position, false)
        end
    end
end

-- 庄家定庄标记显示
function RefreshBankerTagActive(positionParam, showParam)

    if mPlayerUINodes[positionParam].BankerTips2GameObject.activeSelf == showParam then
        return
    end
    mPlayerUINodes[positionParam].BankerTips2GameObject:SetActive(showParam)
    if true == showParam then
        mPlayerUINodes[positionParam].BankerTipsFlyAnimation:ResetToBeginning()
        mPlayerUINodes[positionParam].BankerTipsFlyAnimation:Play(true)
        GameObjectSetActive(mBankerTipsGameObject,false)
        PlayAudioClip('NN_zhuang')
    end
end

-- 显示定庄特效
function ShowTTZBankerEffect(positionParam, showParam)
    -- 定庄特效
    mPlayerUINodes[positionParam].BankerTips3GameObject:SetActive(showParam)
    if true == showParam then
        local spriteAnimation = mPlayerUINodes[positionParam].BankerTips3GameObject.transform:GetComponent('UGUISpriteAnimation')
        spriteAnimation:RePlay()
        -- 延迟隐藏
        this:DelayInvoke(1.2,
        function()
            mPlayerUINodes[positionParam].BankerTips3GameObject:SetActive(false)
        end )
    end
end

-------------------------------------------------------------------------------
------------------------【下注阶段】[XUAN_DOUBLE-OVER_DOUBLE] [6-7]-------------
function RefreshTTZXuanDoublePartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_TTZ.XUAN_DOUBLE then
        RefreshDoubleCountDownState(true)
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            RefreshPlayerBettingValue(position)
        end
        -- 检测自己加倍按钮是否开启
        if mMasterData.PlayerState > PlayerStateEnumTTZ.JoinOK and mRoomData.BankerID ~= mMasterPosition then
            -- 自己参与本局游戏 并且不是庄家 状态属于为确认抢庄
            if mMasterData.PlayerState < PlayerStateEnumTTZ.JiaBeiOK then
                JBButtonSetActive(true)
            else
                JBButtonSetActive(false)
            end
        else
            JBButtonSetActive(false)
        end

        if mRoomData.BankerID == mMasterPosition or mMasterData.PlayerState < PlayerStateEnumTTZ.JoinOK then
            -- 自己是庄家 或者未参与本局游戏
            GameObjectSetActive(mBettingWaitTipsGameObject, true)
        end
    elseif roomState >= ROOM_STATE_TTZ.OVER_DOUBLE then
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            RefreshPlayerBettingValue(position)
        end
        JBButtonSetActive(false)
        GameObjectSetActive(mBettingWaitTipsGameObject, false)
        RefreshDoubleCountDownState(false)
    else
        JBButtonSetActive(false)
        GameObjectSetActive(mBettingWaitTipsGameObject, false)
        RefreshDoubleCountDownState(false)

        for position =1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            GameObjectSetActive(mPlayerUINodes[position].DoubleTipsGameObject, false)
        end
    end
end

-- 刷新加倍CD显示
function RefreshDoubleCountDownState(isActive)

    ShowCountDown(isActive)
    isUpdateDoubleCountDown = isActive
end

-- 更新加倍CD
function UpdateTTZDoubleCountDown()
    if isUpdateDoubleCountDown == true then
        RefreshCountDownText()
    end
end

-- 下注按钮显示设置
function JBButtonSetActive( isActive )
    GameObjectSetActive(mJBButtonsGameObject, isActive)
    if isActive == true then
        RefreshJiaBeiValues()
    end
end

--==============================--
--desc:更新玩家可以下注倍率
--time:2018-01-06 11:16:06
--@return 
--==============================--
function RefreshJiaBeiValues()
    
    if mRoomData.CompensateType == 1 then
        -- 浮动倍率
        local tPlayerCompensate = mMasterData.nCanCompensate
        local tBankerCompensate = mRoomData.nBankerCompensate
        local tCompensateMin = data.PublicConfig.NN_ZUJU_BET_MIN
        tPlayerCompensate = math.min( tPlayerCompensate, tBankerCompensate )
        tPlayerCompensate = math.max( tPlayerCompensate, tCompensateMin)
        mTTZ_ZUJU_JIABEI[1] = tCompensateMin
        mTTZ_ZUJU_JIABEI[4] = tPlayerCompensate
        local tCompensate3 = math.floor( tPlayerCompensate * 0.5)
        tCompensate3 = math.min( tCompensate3, tPlayerCompensate)
        mTTZ_ZUJU_JIABEI[3] = math.max( tCompensate3, tCompensateMin)
        local tCompensate2 = math.floor( tPlayerCompensate * 0.3)
        local tCompensate2 = math.min( tCompensate2, tCompensate3 )
        tCompensate2 = math.max( tCompensate2, tCompensateMin )
        mTTZ_ZUJU_JIABEI[2] = tCompensate2
    else
        -- 固定倍率
        for index = 1, 4, 1 do
            mTTZ_ZUJU_JIABEI[index] = data.PublicConfig.TTZ_BET_GUDING[index]
        end
    end
    

    this.transform:Find('Canvas/MasterInfo/JBButtons/JBButton1/Text'):GetComponent("Text").text = string.format( "x%d", mTTZ_ZUJU_JIABEI[1])
    this.transform:Find('Canvas/MasterInfo/JBButtons/JBButton2/Text'):GetComponent("Text").text = string.format( "x%d", mTTZ_ZUJU_JIABEI[2])
    this.transform:Find('Canvas/MasterInfo/JBButtons/JBButton3/Text'):GetComponent("Text").text = string.format( "x%d", mTTZ_ZUJU_JIABEI[3])
    this.transform:Find('Canvas/MasterInfo/JBButtons/JBButton4/Text'):GetComponent("Text").text = string.format( "x%d", mTTZ_ZUJU_JIABEI[4])
    local BetMaxValue = math.min(GameData.RoomInfo.CurrentRoom.nBankerCompensate,GameData.RoomInfo.CurrentRoom.TTZPlayerList[6].nCanCompensate)
    for Index=1,4,1 do
        if mTTZ_ZUJU_JIABEI[Index] > BetMaxValue then
            this.transform:Find('Canvas/MasterInfo/JBButtons/JBButton'..Index):GetComponent("Button").enabled=false
            this.transform:Find('Canvas/MasterInfo/JBButtons/JBButton'..Index):GetComponent("Image").color=CS.UnityEngine.Color.grey
        else
            this.transform:Find('Canvas/MasterInfo/JBButtons/JBButton'..Index):GetComponent("Button").enabled=true
            this.transform:Find('Canvas/MasterInfo/JBButtons/JBButton'..Index):GetComponent("Image").color=CS.UnityEngine.Color.white
        end
    end
end

--==============================--
--desc:加倍按钮call
--time:2018-02-27 08:31:01
--@index:
--@return 
--==============================--
function JBButton_OnClick( index )
    local tJiaBei = mTTZ_ZUJU_JIABEI[index]
    if tJiaBei == nil then
        tJiaBei = 2
    end
    NetMsgHandler.Send_CS_TTZ_Betting(tJiaBei)
    JBButtonSetActive(false)
end

--==============================--
--desc:玩家下注
--time:2018-02-28 08:48:08
--@positionParam:
--@return 
--==============================--
function OnNotifyTTZPlayerDoubleEvent( positionParam )
    if positionParam == mMasterPosition then
        -- 自己加倍按钮
        JBButtonSetActive(false)
        GameObjectSetActive(mBettingWaitTipsGameObject, false)
    end
    RefreshPlayerBettingValue(positionParam)
end

-- 刷新指定玩家下注倍率
function RefreshPlayerBettingValue(positionParam)

    local tPlayerData = mRoomData.TTZPlayerList[positionParam]
    local tPlayerState = tPlayerData.PlayerState
    if tPlayerState >= PlayerStateEnumTTZ.JoinOK and positionParam ~= mRoomData.BankerID then
        if tPlayerState == PlayerStateEnumTTZ.JiaBeiOK or tPlayerState >= PlayerStateEnumTTZ.JiaBeiNO then
            if mPlayerUINodes[positionParam].DoubleTipsGameObject.activeSelf == false then
                mPlayerUINodes[positionParam].DoubleTipsGameObject:SetActive(true)
                local tweenScale = mPlayerUINodes[positionParam].DoubleTipsGameObject.transform:GetComponent('TweenScale')
                tweenScale:ResetToBeginning()
                tweenScale:Play(true)
                -- 延迟隐藏
                this:DelayInvoke(0.4,
                function() mPlayerUINodes[positionParam].DoubleTipsGameObject.transform:GetComponent('TweenScale').enabled = false    end )

                mPlayerUINodes[positionParam].DoubleTipsText.text = string.format( "X%d", tPlayerData.nBetCompensate)
                PlaySelfDoubleStateSound(positionParam)
            end
        else
            mPlayerUINodes[positionParam].DoubleTipsGameObject:SetActive(false)
        end
    else
        mPlayerUINodes[positionParam].DoubleTipsGameObject:SetActive(false)
    end

end

-- 播放自己加倍状态音效
function PlaySelfDoubleStateSound(positionParam)
    if positionParam == mMasterPosition then
        if mMasterData.PlayerState == PlayerStateEnumTTZ.JiaBeiOK then
            PlayAudioClip('NN_jiabei_1')
        else
            PlayAudioClip('NN_jiabei_2')
        end
    end
end

-------------------------------------------------------------------------------
------------------------【看牌阶段-结束】[KANPAI-OVER_KANPAI] [8-9]--------------------------------
function RefreshTTZKanPaiPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_TTZ.KANPAI then
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            local tPlayerState  = mRoomData.TTZPlayerList[position].PlayerState
            if tPlayerState > PlayerStateEnumTTZ.JoinOK then
                RefreshTTZPokerType(position, tPlayerState == PlayerStateEnumTTZ.KanPai)
                if position == mMasterPosition then
                    RefreshTTZPokerType(mMasterPosition, true)
                end
            else
                RefreshTTZPokerType(position, false)
            end
        end
        GameObjectSetActive(mKanPaiButtonGameObject, (mMasterData.PlayerState >PlayerStateEnumTTZ.JoinOK and mMasterData.PlayerState ~= PlayerStateEnumTTZ.KanPai) or false)
        ShowTTZKanPaiWaitTips(true)
    elseif roomState >= ROOM_STATE_TTZ.OVER_KANPAI then
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            local tPlayerState  = mRoomData.TTZPlayerList[position].PlayerState
            if tPlayerState > PlayerStateEnumTTZ.JoinOK then
                RefreshTTZPokerType(position, true)
            else
                RefreshTTZPokerType(position, false)
            end
        end
        GameObjectSetActive(mKanPaiButtonGameObject,false)
        ShowTTZKanPaiWaitTips(false)
    else
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            RefreshTTZPokerType(position, false)
        end
        GameObjectSetActive(mKanPaiButtonGameObject,false)
        ShowTTZKanPaiWaitTips(false)
    end
end

-- 等待他人搓牌显示
function ShowTTZKanPaiWaitTips(showParam)
    ShowCountDown(showParam)
    isUpdateCuoPokerCountDown = showParam
    GameObjectSetActive(mKanPaiWaitTipsGameObject, showParam )
end

-- 更新等待他人搓牌倒计时
function UpdateCuoPokerCountDown()
    if isUpdateCuoPokerCountDown == true then
        RefreshCountDownText()
    end
end

--==============================--
--desc:看牌按钮
--time:2018-02-27 08:32:44
--@return 
--==============================--
function KanPaiButton_OnClick()
    NetMsgHandler.Send_CS_TTZ_KANPAI()
end

--==============================--
--desc:玩家看牌
--time:2018-02-28 08:49:07
--@positionParam:
--@return 
--==============================--
function OnNotifyTTZPlayerKanPaiEvent( positionParam )
    if positionParam == mMasterPosition then
        GameObjectSetActive(mKanPaiButtonGameObject,false)
    end
    RefreshTTZPokerType(positionParam, true)
end

-- 牌型显示
function RefreshTTZPokerType( position, isActive )
    if isActive then
        if mPlayerUINodes[position].PokerTypeGameObject.activeSelf ~= isActive then
            SetTTZPokerCardVisible(mPlayerUINodes[position].Cards[1], true)
            SetTTZPokerCardVisible(mPlayerUINodes[position].Cards[2], true)
            local tPokerCard  = mRoomData.TTZPlayerList[position].Pokers
            mPlayerUINodes[position].Cards[1]:GetComponent("Image"):ResetSpriteByName(TTZGameMgr.GetPokerCardSpriteName(tPokerCard[1].PokerNumber))
            mPlayerUINodes[position].Cards[2]:GetComponent("Image"):ResetSpriteByName(TTZGameMgr.GetPokerCardSpriteName(tPokerCard[2].PokerNumber))
            local pokerType, pokerNumber = TTZGameMgr.GetPokerCardTypeByPokerCards(tPokerCard[1], tPokerCard[2])
            local TTZ_COMPENSATE = data.PublicConfig.TTZ_COMPENSATE
            local tCompensate = TTZ_COMPENSATE[pokerType]
            mPlayerUINodes[position].PokerTypeImage:ResetSpriteByName(TTZGameMgr.GetPokerCardTypeSpriteName(pokerType, pokerNumber))
            mPlayerUINodes[position].PokerTypeXText.text = tostring(tCompensate)
            PlayPokerTypeAudioClip(pokerType, pokerNumber,position)
        end
    end
    
    GameObjectSetActive(mPlayerUINodes[position].PokerTypeGameObject, isActive)
end

-- 播放牌型音效
function PlayPokerTypeAudioClip( pokerType, pokerNumber, position )
    local audioKey = 'TTZ_px_m_'
    --[[if mPlayAudioRandom % 2 == 1 then
        audioKey = 'TTZ_px_w_'
    end--]]
    local IsMan = false
    for k=1, #data.PublicConfig.HeadIconMan, 1 do
        if mRoomData.TTZPlayerList[position].HeadIcon == data.PublicConfig.HeadIconMan[k] then
            IsMan = true
            break
        end
    end
    if IsMan == false then
        audioKey = 'TTZ_px_w_'
    end
    if pokerType == TTZ_Card_Type.ZHIZUN then
        audioKey = audioKey .. 'tzz'
    elseif pokerType == TTZ_Card_Type.BAOZI then
        audioKey = audioKey .. 'tbz'
    elseif pokerType == TTZ_Card_Type.GANG28 then
        audioKey = audioKey .. 'g28'
    else
        audioKey = audioKey .. pokerNumber
    end
    PlayAudioClip(audioKey)
    mPlayAudioRandom = mPlayAudioRandom + 1
end

-------------------------------------------------------------------------------
------------------------【结算阶段】[SETTLEMENT] [10]---------------------------
-- 本局输家+赢家 数量计数
local mLoserCount = 0
local mWinnerCount = 0
local mNeedDelayTime = 0
-- 赢家筹码显示延迟时间
local mWinnerAnimationDelayTime = 0

--TUDOU
function RefreshSettlementPartOfGameRoomByState( roomState, isInit )
    if roomState == ROOM_STATE_TTZ.SETTLEMENT then
        GameObjectSetActive(mResultGameObject,true)
        lua_Transform_ClearChildren(mChipRoot, false)
        ResetTTZWinGold()
        -- RefreshTTZPlayerGoldValue()
        ResetTTZSettleDelayTime()
        this:DelayInvoke(3, function()
            RefreshTTZPlayerGoldValue();
        end)
        --print('延迟时间:' .. mNeedDelayTime .. '结算进入状态:' .. lua_BOLEAN_String(initParam))
        if initParam == true then
            if mRoomData.CountDown > mNeedDelayTime then
                PlayTTZWinGoldChipAnimation(true)
                this:DelayInvoke(mNeedDelayTime, function() PlayTTZWinGoldValueAnimation() end)
            else
                PlayTTZWinGoldChipAnimation(false)
                this:DelayInvoke(0.5, function() PlayTTZWinGoldValueAnimation() end)
            end
        else
            PlayTTZWinGoldChipAnimation(true)
            this:DelayInvoke(mNeedDelayTime, function() PlayTTZWinGoldValueAnimation() end)
        end
    else
        GameObjectSetActive(mResultGameObject,false)

        RefreshTTZGameOverTipsShowState(false)
    end
end

-- 重置玩家输赢金币值
function ResetTTZWinGold()
    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        mPlayerUINodes[position].WinText.text = ''
        mPlayerUINodes[position].LoseText.text = ''
    end
end

-- 刷新玩家金币
function RefreshTTZPlayerGoldValue()
    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        local showObj = mPlayerUINodes[position]
        local showData = mRoomData.TTZPlayerList[position]
        if showData.PlayerState > PlayerStateEnumTTZ.JoinOK then
            showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.Gold,2))
        else
            showObj.GoldText.text = ""
        end
    end
end

-- 重置结算延迟时间
function ResetTTZSettleDelayTime()
    mLoserCount = 0
    mWinnerCount = 0
    mNeedDelayTime = 0

    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        if mRoomData.TTZPlayerList[position].PlayerState > PlayerStateEnumTTZ.JoinOK and position ~= mRoomData.BankerID then
            if mRoomData.TTZPlayerList[position].WinGold < 0 then
                -- 输家计数
                mLoserCount = mLoserCount + 1
            else
                -- 赢家计数
                mWinnerCount = mWinnerCount + 1
            end
        end
    end

    -- 计算金币数值显示延迟时间
    if mLoserCount > 0 then
        mNeedDelayTime = mNeedDelayTime + 2.0
    end

    if mWinnerCount > 0 then
        mNeedDelayTime = mNeedDelayTime + 1.5
    end

end

-- 玩家输赢金币筹码动画
function PlayTTZWinGoldChipAnimation(isAni)

    ShowTTZPlayerToBankerAnimation(isAni)
    if mLoserCount > 0 then
        -- 有输家 先飞筹码到庄家
        this:DelayInvoke(2.0, function() ShowTTZBankerToPlayerAnimation(isAni) end)
    else
        ShowTTZBankerToPlayerAnimation(isAni)
    end

end

-- 筹码从玩家飞入到庄家
function ShowTTZPlayerToBankerAnimation(isAni)
    if isAni then
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            if mRoomData.TTZPlayerList[position].PlayerState > PlayerStateEnumTTZ.JoinOK and mRoomData.TTZPlayerList[position].WinGold < 0 then
                if position ~= mRoomData.BankerID then
--                    local showObj = mPlayerUINodes[position];
--                    local showData = mRoomData.TTZPlayerList[position];
--                    this:DelayInvoke(1, function()
                        -- showObj.GoldText.text = lua_NumberToStyle1String(showData.Gold);
--                    end)
                    PlayTTZGoldFlyAnimation(position, mRoomData.BankerID, position)
                end
            end
        end
    end
end

-- 筹码从庄家飞入到玩家
function ShowTTZBankerToPlayerAnimation(isAni)
    if isAni then
        for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            if mRoomData.TTZPlayerList[position].PlayerState > PlayerStateEnumTTZ.JoinOK and mRoomData.TTZPlayerList[position].WinGold > 0 then
                if position ~= mRoomData.BankerID then
--                    local showObj = mPlayerUINodes[position];
--                    local showData = mRoomData.TTZPlayerList[position];
--                    this:DelayInvoke(1, function()
                        -- showObj.GoldText.text = lua_NumberToStyle1String(showData.Gold);
--                    end)
                    PlayTTZGoldFlyAnimation(mRoomData.BankerID, position, position)
                end
            end
        end
    end
    this:DelayInvoke(1, function()
        local showObj = mPlayerUINodes[mRoomData.BankerID];
        local showData = mRoomData.TTZPlayerList[mRoomData.BankerID];
        -- showObj.GoldText.text = lua_NumberToStyle1String(showData.Gold);
    end)
end

-- 播放筹码飞入动画(参数1:开始点 参数2:结束点,参数3:筹码来源点)
function PlayTTZGoldFlyAnimation(positionForm, positionTo, positionSource)

    --print(string.format('筹码飞入[%d]==>[%d] 来源:[%d]', positionForm, positionTo, positionSource))
    -- 牌型倍率
    local pokerCards = mRoomData.TTZPlayerList[positionTo].Pokers
    local pokerType, pokerNumber = TTZGameMgr.GetPokerCardTypeByPokerCards(pokerCards[1], pokerCards[2])
    local TTZ_COMPENSATE = data.PublicConfig.TTZ_COMPENSATE
    local tCompensate = TTZ_COMPENSATE[pokerType]

    for i = 1, tCompensate, 1 do
        -- 丢入筹码
        local newChip = CS.UnityEngine.Object.Instantiate(mChipItems[tCompensate])
        CS.Utility.ReSetTransform(newChip, mChipRoot)
        newChip.gameObject.name = 'Chips_' .. i
        newChip.position = mPlayerUINodes[positionForm].ChipPoint.position
        newChip.gameObject:SetActive(true)
        local script = newChip.gameObject:AddComponent(typeof(CS.TweenTransform))
        script.from = mPlayerUINodes[positionForm].ChipPoint
        script.to = mPlayerUINodes[positionTo].ChipPoint
        script.duration = 0.65
        script.delay = i * 0.1
        if script.delay > 1 then
            script.delay = 1
        end
        script:Play(true)
        script:OnFinished("+",( function()
            CS.UnityEngine.Object.Destroy(script.gameObject)
            -- 获取筹码音效
            PlayAudioClip('7')
        end ))
    end

end

-- 玩家输赢金币特性显示
function PlayTTZWinGoldValueAnimation()
    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        ShowTTZPlayerWinGoldValue(position)
        local WinGold = mRoomData.TTZPlayerList[position].WinGold
        if mRoomData.TTZPlayerList[position].PlayerState > PlayerStateEnumTTZ.JoinOK then
            -- 赢钱特效
            ShowTTZBankerEffect(position, WinGold > 0)
            if position == mMasterPosition then
                PlayTTZGameResultSoundEffect()
            end
        end
    end
    this:DelayInvoke(1.5,
    function()
        ResetTTZWinGold()
        RefreshTTZGameOverTipsShowState(true)
    end )
end

-- 游戏结算音效
function PlayTTZGameResultSoundEffect()
    if mMasterData.PlayerState > PlayerStateEnumTTZ.JoinOK then
        -- 玩家输赢音效
        if mMasterData.WinGold > 0 then
            PlayAudioClip('NN_win')
        else
            PlayAudioClip('NN_lost')
        end
    end

end

-- 显示玩家金币结算
function ShowTTZPlayerWinGoldValue(positionParam)
    local WinGold = mRoomData.TTZPlayerList[positionParam].WinGold
    if mRoomData.TTZPlayerList[positionParam].PlayerState > PlayerStateEnumTTZ.JoinOK then
        if WinGold > 0 then
            mPlayerUINodes[positionParam].WinText.text = '+' .. lua_CommaSeperate(WinGold)
            local tweenposition = mPlayerUINodes[positionParam].WinText.transform:GetComponent('TweenPosition')
            tweenposition:ResetToBeginning()
            tweenposition:Play(true)
            local tweenalpha = mPlayerUINodes[positionParam].WinText.transform:GetComponent('TweenAlpha')
            tweenalpha:ResetToBeginning()
            tweenalpha:Play(true)
        elseif WinGold < 0 then
            mPlayerUINodes[positionParam].LoseText.text = lua_CommaSeperate(WinGold)
            local tweenposition = mPlayerUINodes[positionParam].LoseText.transform:GetComponent('TweenPosition')
            tweenposition:ResetToBeginning()
            tweenposition:Play(true)
            local tweenalpha = mPlayerUINodes[positionParam].LoseText.transform:GetComponent('TweenAlpha')
            tweenalpha:ResetToBeginning()
            tweenalpha:Play(true)
        end
    end
end

-- 刷新游戏结束等待tips显示
function RefreshTTZGameOverTipsShowState(showParam)
    isUpdateGameOverWaitCountDown = showParam
    GameObjectSetActive(mWaitTips3GameObject, showParam)
end

local mGameOverCD = 0
-- 刷新游戏结束等待CD
function RefreshTTZGameOverTipsCountDown()
    if isUpdateGameOverWaitCountDown == true then
        if nil == mWaitTips3Text then
            return
        end
        local tCountDown = math.ceil(mRoomData.CountDown) 
        if tCountDown < 0 then
            tCountDown = 0
        end
        if mGameOverCD ~= tCountDown then
            mGameOverCD = tCountDown
            mWaitTips3Text.text = string.format(data.GetString('NN_Game_Over_Tips'), lua_FormatToCountdownStyle(mGameOverCD))
        end
    end
end

---------------------------------------------------------------------------------

--==============================--
--desc:进入一个玩家
--time:2018-02-28 08:43:11
--@args:
--@return 
--==============================--
function OnNotifyTTZAddPlayerEvent( positionParam )
    SetTTZPlayerSitdownState(positionParam)
    SetTTZPlayerBaseInfo(positionParam)
    RefreshTTZPlayerWaitTipsAndGoldText(positionParam, mRoomData.RoomState <= ROOM_STATE_TTZ.DEAL)
    -- 进入音效
    PlayAudioClip('NN_enter')
end

-- 设置玩家坐下状态
function SetTTZPlayerSitdownState(positionParam)
    if mPlayerUINodes[positionParam] == nil then
        return
    end
    if mRoomData.TTZPlayerList[positionParam].PlayerState == PlayerStateEnumTTZ.NULL then
        mPlayerUINodes[positionParam].HeadRoot.gameObject:SetActive(false)
        mPlayerUINodes[positionParam].ZBImage:SetActive(false)
    else
        mPlayerUINodes[positionParam].HeadRoot.gameObject:SetActive(true)
    end
end

-- 设置玩家名称 头像 金币
function SetTTZPlayerBaseInfo(positionParam)
    local showObj = mPlayerUINodes[positionParam]
    local showData = mRoomData.TTZPlayerList[positionParam]
    if showData.PlayerState >= PlayerStateEnumTTZ.LookOn then
        -- print(string.format('Name:[%s] Gold:[%f] HeadIcon:[%d]', showData.Name, showData.Gold, showData.HeadIcon))
        showObj.NameText.text = showData.strLoginIP
        showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.Gold,2))
        showObj.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(showData.HeadIcon))
    else
        showObj.NameText.text = ""
        showObj.GoldText.text = ""
    end
end



--==============================--
--desc:离开一个玩家
--time:2018-02-28 08:44:55
--@positionParam:
--@return 
--==============================--
function OnNotifyTTZDeletePlayerEvent( positionParam )
    SetTTZPlayerSitdownState(positionParam)
    SetTTZPlayerBaseInfo(positionParam)
    RefreshTTZPlayerWaitTipsAndGoldText(positionParam, true)
    -- 扑克隐藏还原
    GameObjectSetActive(mPlayerUINodes[positionParam].Cards[1].gameObject,false)
    GameObjectSetActive(mPlayerUINodes[positionParam].Cards[2].gameObject,false)
end

--==============================--
--desc:邀请按钮1显示状态更新
--time:2018-01-25 02:30:13
--@return 
--==============================--
function UpdateButtonInvite1ShowState()
    local showParam = true
    if mRoomData:PlayerCount() > 1 then
        showParam = false
    end
    if mRoomData.RoomType ~= ROOM_TYPE.ZuJuTTZ then
       showParam = false 
    end
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.TtzRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.TtzRankTime >= 60 then
        return true
    end
    return false
end

-- 响应排行榜按钮点击事件
function RankButtonOnClick()
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = GAME_RANK_TYPE.TTZ_MONEY
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(GAME_RANK_TYPE.TTZ_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.TTZ_MONEY)
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

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    mMyTransform = this.transform
    mRoomData = GameData.RoomInfo.CurrentRoom
    mMasterData = mRoomData.TTZPlayerList[MAX_TTZZUJU_ROOM_PLAYER]
    InitUIElement()
    AddButtonHandlers()
    InitRoomChange()
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened( )
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, ResetTTZGameRoomToRoomState)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoomState, RefreshTTZGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTTZAddPlayerEvent, OnNotifyTTZAddPlayerEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTTZDeletePlayerEvent, OnNotifyTTZDeletePlayerEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTTZPlayerReadyEvent, OnNotifyTTZPlayerReadyEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTTZPlayerQiangZhuangEvent, OnNotifyTTZPlayerQiangZhuangEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTTZPlayerDoubleEvent, OnNotifyTTZPlayerDoubleEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTTZPlayerKanPaiEvent, OnNotifyTTZPlayerKanPaiEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyRoomChangeEvent, OnNotifyRoomChangeEvent)
    MusicMgr:PlayBackMusic("BG_TTZ")
    if mRoomData.RoomID > 0 then 
        ResetTTZGameRoomToRoomState(mRoomData.RoomState)
    end
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, ResetTTZGameRoomToRoomState)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoomState, RefreshTTZGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTTZAddPlayerEvent, OnNotifyTTZAddPlayerEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTTZDeletePlayerEvent, OnNotifyTTZDeletePlayerEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTTZPlayerReadyEvent, OnNotifyTTZPlayerReadyEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTTZPlayerQiangZhuangEvent, OnNotifyTTZPlayerQiangZhuangEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTTZPlayerDoubleEvent, OnNotifyTTZPlayerDoubleEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTTZPlayerKanPaiEvent, OnNotifyTTZPlayerKanPaiEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyRoomChangeEvent, OnNotifyRoomChangeEvent)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    CS.MatchLoadingUI.Hide()
end

-- Unity MonoBehavior Update 时调用此方法
function Update()
    TTZGameMgr:UpdateRoomCountDown(mTime.deltaTime)
    UpdateQiangZhuangDown()
    UpdateTTZDoubleCountDown()
    UpdateCuoPokerCountDown()
    RefreshTTZGameOverTipsCountDown()
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    lua_Call_GC()
end