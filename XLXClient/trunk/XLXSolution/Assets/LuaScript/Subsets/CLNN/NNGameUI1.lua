
local Time = CS.UnityEngine.Time
-- 当前房间信息数据
local mRoomData = { }
-- 主角数据
local mMasterData = {}

-- 玩家UI信息
local PlayerUIInfo =
{
    PlayerRoot,
    Name,
    WinText,
    LoseText,
    DoubleTips,
    HeadIcon,
    HeadBack,
    Sitdown,
    GoldText,
    WaitTips,
    ZBImage,
    PokerType,
    PokerTypeBack,
    PokerTypeXText,
    QiangZhuang,
    BankerTips1,
    BankerTips2,
    BankerTips3,
    WinTips1,
    WinTips2,
    CardRoot,
    Cards = { },
    Points = { },
}

-- 玩家槽位信息
local mPLAYERS_SLOT = { }
-- 推出菜单组件
local mReturnCaiDan = nil
-- 游戏规则组件
local mGameRule = nil

-- 搓牌组件
local mPokerHandle = nil
-- 倒计时组件
local mCountDown = nil
local mCountDownText = nil
-- 加倍按钮组件
local mDoubleButtons = nil
-- 等待下一局开始提示
local mRoomWaitTips2 = nil
-- 等待他人搓牌结束提示
local mCuoPaiWaitTips = nil
-- 开牌按钮
local mButtonOpen = nil
-- 开牌CD组件
local mButtonOpenText = nil
-- 游戏结束tips
local mGameOverWaitTips = nil
-- 游戏结束tips Text
local mGameOverWaitTipsText = nil

-- 游戏结算组件
local mGameResult = nil
-- 洗牌动画组件
local mShuffleAni = nil

-- 筹码挂接点
local mChipRoot = nil

-- 筹码挂节点
local CHIP_JOINTS =
{
    [1] = { JointPoint = nil, },
    [2] = { JointPoint = nil, },
    [3] = { JointPoint = nil, },
    [4] = { JointPoint = nil, },
    [5] = { JointPoint = nil, },
    [6] = { JointPoint = nil, },
}

-- 筹码Item节点组件
local ChipItemTransform =
{
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
    [7] = nil,
    [8] = nil,
    [9] = nil,
    [10] = nil,
    [11] = nil,
    [12] = nil,
    [13] = nil,
    [14] = nil,
    [15] = nil,
    [16] = nil,
}

-- 庄家标签
mBankerTips = nil
-- 准备按钮
local ZBButtonGameObject = nil

-- 是否计时 玩家加倍CD
local isUpdateDoubleCountDown = false

-- 是否计时扑克牌开牌CD
local isUpdateOpenPokerCountDown = false

-- 是否计时搓牌等待CD
local isUpdateCuoPokerCountDown = false
-- 是否计时结算等待CD
local isUpdateGameOverWaitCountDown = false

local canPlaySoundEffect = false                            -- 能开始播放音效(进入房间时有很多东西需要筹备 筹备完毕才能开始播放)

-- 扑克牌的挂节点
local POKER_JOINTS = { }

-- 本局玩家可以下注倍率
local mNN_ZUJU_JIABEI = 
{
    [1] = 5,
    [2] = 10,
    [3] = 15,
    [4] = 20,
}

--TUDOU
local currentRoomState = 0;

local mUINode = 
{
    ButtonInvite1GameObject = nil,      -- 邀请按钮1
    ButtonInvite2GameObject = nil,      -- 邀请按钮2
}

-- 有牛光圈
local SelectImage = {}
-- 有牛字
local YouNiu = nil

-- 添加UI按钮事件响应
function AddButtonHandlers()

    this.transform:Find('Canvas/Buttons/ButtonCaiDan1'):GetComponent("Button").onClick:AddListener(ButtonCaiDan_OnClick)
    this.transform:Find('Canvas/Buttons/ButtonCaiDan2'):GetComponent("Button").onClick:AddListener(ButtonCaiDan_OnClick)
    this.transform:Find('Canvas/Buttons/ButtonBegin'):GetComponent("Button").onClick:AddListener(ButtonBegin_OnClick)
    this.transform:Find('Canvas/MasterInfo/ZBButton'):GetComponent("Button").onClick:AddListener(ZBButton_OnClick)
    this.transform:Find('Canvas/ReturnCaiDan'):GetComponent("Button").onClick:AddListener(ReturnCaiDan_OnClick)
    this.transform:Find('Canvas/ReturnCaiDan/ImageMask'):GetComponent("Button").onClick:AddListener(ReturnCaiDanHide_OnClick)
    this.transform:Find('Canvas/ReturnCaiDan/ButtonExit'):GetComponent("Button").onClick:AddListener(ButtonExit_OnClick)
    this.transform:Find('Canvas/ReturnCaiDan/ButtonChange'):GetComponent("Button").onClick:AddListener(ButtonChange_OnClick)
    this.transform:Find('Canvas/ReturnCaiDan/ButtonGameRule'):GetComponent("Button").onClick:AddListener(ButtonGameRule_OnClick)
    this.transform:Find('Canvas/ReturnCaiDan/RankButton'):GetComponent("Button").onClick:AddListener(RankButtonOnClick)
    this.transform:Find('Canvas/MasterInfo/QiangZhuangButton/OK'):GetComponent("Button").onClick:AddListener(QiangZhuangOK_OnClick)
    this.transform:Find('Canvas/MasterInfo/QiangZhuangButton/NO'):GetComponent("Button").onClick:AddListener(QiangZhuangNO_OnClick)
    

    this.transform:Find('Canvas/PokerHandle/ButtonOpen'):GetComponent("Button").onClick:AddListener(OpenCardButton_OnClick)

    this.transform:Find('Canvas/GameRule/CloseBtn'):GetComponent("Button").onClick:AddListener(HideGameRule_OnClick)
    this.transform:Find('Canvas/GameRule/Title/back'):GetComponent("Button").onClick:AddListener(HideGameRule_OnClick)

    this.transform:Find('Canvas/StoreButton'):GetComponent("Button").onClick:AddListener(StoreButtonOnClick)
    


    this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton1'):GetComponent("Button").onClick:AddListener( function() BetXXX_OnClick(1) end)
    this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton2'):GetComponent("Button").onClick:AddListener( function() BetXXX_OnClick(2) end)
    this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton3'):GetComponent("Button").onClick:AddListener( function() BetXXX_OnClick(3) end)
    this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton4'):GetComponent("Button").onClick:AddListener( function() BetXXX_OnClick(4) end)

    -- 坐下标记设置要求回调
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        this.transform:Find('Canvas/Players/Player' .. position .. '/Head/Sitdown'):GetComponent("Button").onClick:AddListener(ButtonInvite_OnClick)
    end
end

-- 初始化房间 玩家相关
function InitGameRoomPlayersRelative()

    local playerRoot = this.transform:Find('Canvas/Players')
    for playerIndex = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        mPLAYERS_SLOT[playerIndex] = lua_NewTable(PlayerUIInfo)
        mPLAYERS_SLOT[playerIndex].playerRoot = playerRoot:Find('Player' .. playerIndex)
        local childRoot = mPLAYERS_SLOT[playerIndex].playerRoot
        mPLAYERS_SLOT[playerIndex].Name = childRoot:Find('Head/Name'):GetComponent('Text')
        mPLAYERS_SLOT[playerIndex].HeadIcon = childRoot:Find('Head/HeadIcon/Icon'):GetComponent('Image')
        mPLAYERS_SLOT[playerIndex].HeadBack = childRoot:Find('Head/HeadIcon')
        mPLAYERS_SLOT[playerIndex].GoldText = childRoot:Find('Head/GoldText'):GetComponent('Text')
        mPLAYERS_SLOT[playerIndex].WaitTips = childRoot:Find('Head/WaitTips').gameObject
        mPLAYERS_SLOT[playerIndex].Sitdown = childRoot:Find('Head/Sitdown').gameObject
        mPLAYERS_SLOT[playerIndex].BankerTips1 = childRoot:Find('Head/BankerTips1')
        mPLAYERS_SLOT[playerIndex].BankerTips2 = childRoot:Find('Head/BankerTips2')
        mPLAYERS_SLOT[playerIndex].BankerTips3 = childRoot:Find('Head/BankerTips3')
        mPLAYERS_SLOT[playerIndex].WinTips1 = childRoot:Find('Head/WinTips1')
        mPLAYERS_SLOT[playerIndex].WinTips2 = childRoot:Find('Head/WinTips2')
        mPLAYERS_SLOT[playerIndex].ZBImage = childRoot:Find('ZBImage').gameObject
        mPLAYERS_SLOT[playerIndex].DoubleTips = childRoot:Find('DoubleTips').gameObject
        mPLAYERS_SLOT[playerIndex].PokerType = childRoot:Find('PokerType/TypeIcon'):GetComponent('Image')
        mPLAYERS_SLOT[playerIndex].PokerTypeBack = childRoot:Find('PokerType')
        mPLAYERS_SLOT[playerIndex].PokerTypeXText = childRoot:Find('PokerType/TypeIcon/XText'):GetComponent('Text')
        mPLAYERS_SLOT[playerIndex].QiangZhuang = childRoot:Find('QiangZhuang')
        mPLAYERS_SLOT[playerIndex].WinText = this.transform:Find('Canvas/Result/Player' .. playerIndex .. '/WinText'):GetComponent('Text')
        mPLAYERS_SLOT[playerIndex].LoseText = this.transform:Find('Canvas/Result/Player' .. playerIndex .. '/LoseText'):GetComponent('Text')
        mPLAYERS_SLOT[playerIndex].CardRoot = childRoot:Find('Cards')

        
        for cardIndex = 1, 5, 1 do
            if mPLAYERS_SLOT[playerIndex].Cards == nil then
                mPLAYERS_SLOT[playerIndex].Cards = { }
            end
            -- 初始化玩家扑克牌
            mPLAYERS_SLOT[playerIndex].Cards[cardIndex] = mPLAYERS_SLOT[playerIndex].CardRoot:Find('Card' .. cardIndex)
            -- 玩家扑克牌挂接点
            -- POKER_JOINTS[position * 10 + pokerPos] = { }
            POKER_JOINTS[playerIndex * 10 + cardIndex] = this.transform:Find('Canvas/Players/PokerPoints/Points' .. playerIndex .. cardIndex)
        end
        -- 初始化扑克的挂接点
        for pointIndex = 1, 10, 1 do
            if mPLAYERS_SLOT[playerIndex].Points == nil then
                mPLAYERS_SLOT[playerIndex].Points = { }
            end
            mPLAYERS_SLOT[playerIndex].Points[pointIndex] = mPLAYERS_SLOT[playerIndex].CardRoot:Find('Points/Points' .. pointIndex)
        end

        -- 初始化有牛光圈
        for Index = 1, 4, 1 do
            SelectImage[Index] = this.transform:Find('Canvas/Players/Player6/Cards/Card'..Index..'/Select').gameObject
        end

        YouNiu = this.transform:Find('Canvas/Players/Player6/YouNiu').gameObject

        -- 显示状态默认
        ResetPlayerInfo(mPLAYERS_SLOT[playerIndex])
    end
end

-- 初始化房间其他信息
function InitGameRoomOtherRelative()

    this.transform:Find('Canvas/Buttons').gameObject:SetActive(true)
    mReturnCaiDan = this.transform:Find('Canvas/ReturnCaiDan').gameObject
    this.transform:Find('Canvas/ReturnCaiDan/ImageMask').gameObject:SetActive(true)
    mGameRule = this.transform:Find('Canvas/GameRule').gameObject
    mPokerHandle = this.transform:Find('Canvas/PokerHandle').gameObject
    mCountDown = this.transform:Find('Canvas/CountDown').gameObject
    mCountDownText = this.transform:Find('Canvas/CountDown/ValueText'):GetComponent('Text')
    mGameResult = this.transform:Find('Canvas/Result').gameObject
    mShuffleAni = this.transform:Find('Canvas/ShuffleAni').gameObject
    mDoubleButtons = this.transform:Find('Canvas/MasterInfo/DoubleButtons').gameObject
    mChipRoot = this.transform:Find('Canvas/Result/ChipRoot')
    mButtonOpen = this.transform:Find('Canvas/PokerHandle/ButtonOpen')
    mButtonOpenText = this.transform:Find('Canvas/PokerHandle/ButtonOpen/CountDown'):GetComponent("Text")
    mBankerTips = this.transform:Find('Canvas/BankerTips').gameObject
    mGameOverWaitTips = this.transform:Find('Canvas/GameOverWaitTips/').gameObject
    mGameOverWaitTipsText = this.transform:Find('Canvas/GameOverWaitTips/TipsText'):GetComponent("Text")
    ZBButtonGameObject = this.transform:Find('Canvas/MasterInfo/ZBButton').gameObject


    -- 筹码挂接点
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        CHIP_JOINTS[position].JointPoint = this.transform:Find('Canvas/Result/ChipJoint/Point' .. position)
    end
    -- 结算筹码组件
    for chipIndex = 1, 5, 1 do
        ChipItemTransform[chipIndex] = this.transform:Find('Canvas/Result/ChipJoint/ChipItems/Chip' .. chipIndex)
    end

    mReturnCaiDan:SetActive(false)
    mPokerHandle:SetActive(false)
    mCountDown:SetActive(false)
    mGameResult:SetActive(false)
    mShuffleAni:SetActive(false)
    mGameRule:SetActive(false)
    mBankerTips:SetActive(false)
    mGameOverWaitTips:SetActive(false)
    ShowBeginAndInviteButton(false)
    ShowBetXXX(false)
    ZBButtonShowState(false)
    UpdateButtonInvite2ShowState()

    if GameConfig.IsSpecial() == true then
        this.transform:Find('Canvas/StoreButton').gameObject:SetActive(false)
        this.transform:Find('Canvas/Notice').gameObject:SetActive(false)
        this.transform:Find('Canvas/NotifyButtons').gameObject:SetActive(false)
    end
    
end

-- 重置玩家信息归零
function ResetPlayerInfo(tPlayer)

    if nil == tPlayer then
        error('玩家组件为nil')
        return
    end
    tPlayer.Name.text = ""
    tPlayer.DoubleTips:SetActive(false)
    tPlayer.HeadBack.gameObject:SetActive(true)
    tPlayer.GoldText.text = ""
    tPlayer.WaitTips:SetActive(false)
    tPlayer.ZBImage:SetActive(false)
    tPlayer.Sitdown:SetActive(false)
    tPlayer.PokerTypeBack.gameObject:SetActive(false)
    tPlayer.QiangZhuang.gameObject:SetActive(false)
    tPlayer.BankerTips1.gameObject:SetActive(false)
    tPlayer.BankerTips2.gameObject:SetActive(false)
    tPlayer.BankerTips3.gameObject:SetActive(false)
    tPlayer.WinTips1.gameObject:SetActive(false)
    tPlayer.WinTips2.gameObject:SetActive(false)
    tPlayer.CardRoot.gameObject:SetActive(false)

end

-- 玩家下注倍率显示
function ShowBetXXX(showParam)
    if nil == mDoubleButtons then
        return
    end
    if mDoubleButtons.activeSelf == showParam then
        return
    end
    mDoubleButtons:SetActive(showParam)
    if showParam then
        RefreshJiaBeiValues()
    end
end

-- 显示倒计时组件
function ShowCountDown(showParam)

    if nil == mCountDown then
        return
    end
    if mCountDown.activeSelf == showParam then
        return
    end
    mCountDown:SetActive(showParam)

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
    end
    
    ShowCountDown(true)

end

-- 房主是否显示开始和邀请按钮
function ShowBeginAndInviteButton(show)
    this.transform:Find('Canvas/Buttons/ButtonBegin').gameObject:SetActive(show)
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
    if mRoomData.RoomType ~= ROOM_TYPE.ZuJuNN then
       showParam = false 
    end
end

function UpdateButtonInvite2ShowState()
    local tShow = true
    if mRoomData.RoomType ~= ROOM_TYPE.ZuJuNN then
        tShow = false 
     end
end

-- 初始化房间到初始状态
function InitRoomBaseInfos(roomStateParam)

    SetRoomBaseInfo()
    mReturnCaiDan:SetActive(false)
    mPokerHandle:SetActive(false)
    mCountDown:SetActive(false)

    ResetGamePositionInfo()

    -- 开始 邀请按钮显示
    ShowBeginAndInviteButton(false)

    this.transform:Find('Canvas/RoomWaitTips').gameObject:SetActive(false)
    mRoomWaitTips2 = this.transform:Find('Canvas/RoomWaitTips2').gameObject
    mRoomWaitTips2:SetActive(false)

    mCuoPaiWaitTips = this.transform:Find('Canvas/MasterInfo/CuoPaiWaitTips').gameObject
    mCuoPaiWaitTips:SetActive(false)
end

-- 设置房间基础信息
function SetRoomBaseInfo()

    this.transform:Find('Canvas/RoomTitle'):GetComponent('Text').text = mRoomData.RoomName
    this.transform:Find('Canvas/RoomNumber/Text'):GetComponent('Text').text = tostring(mRoomData.RoomID)
    this.transform:Find('Canvas/RoomRule'):GetComponent('Text').text = GetRoomRuleTips1(mRoomData.MinBet)
    if mRoomData.RoomType ~= ROOM_TYPE.ZuJuNN then
        this.transform:Find('Canvas/RoomNumber').gameObject:SetActive(false)
    end
end

-- 获取房间规则显示描述1
function GetRoomRuleTips1(nBet)
    local ruleTips = string.format( data.GetString("NN_Rule_Tips"),lua_NumberToStyle1String(mRoomData.MinBet))
    return ruleTips
end

-- 设置玩家坐下状态
function SetPlayerSitdownState(positionParam)

    if mPLAYERS_SLOT[positionParam] == nil then
        return
    end
    if mRoomData.NNPlayerList[positionParam].IsValid == PlayerStateEnumNN.NULL then
        mPLAYERS_SLOT[positionParam].Sitdown:SetActive(false)
        mPLAYERS_SLOT[positionParam].HeadBack.gameObject:SetActive(false)
        mPLAYERS_SLOT[positionParam].ZBImage:SetActive(false)
    else
        mPLAYERS_SLOT[positionParam].Sitdown:SetActive(false)
        mPLAYERS_SLOT[positionParam].HeadBack.gameObject:SetActive(true)
    end

end

-- 设置玩家名称 头像 金币
function SetPlayerBaseInfo(positionParam)

    local showObj = mPLAYERS_SLOT[positionParam]
    local showData = mRoomData.NNPlayerList[positionParam]
    if showData.IsValid >= PlayerStateEnumNN.JoinNO then
        -- print(string.format('Name:[%s] Gold:[%f] HeadIcon:[%d]', showData.Name, showData.Gold, showData.HeadIcon))
        showObj.Name.text = showData.strLoginIP
        showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.Gold,2))
        showObj.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(showData.HeadIcon))
    else
        showObj.Name.text = ""
        showObj.GoldText.text = ""
    end
end

-- 刷新所有玩家等待下一局标签
function RefreshAllPlayerWaitTipsAndGoldText(forceHideParam)
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        RefreshPlayerWaitTipsAndGoldText(position, forceHideParam)
    end
end

function RefreshPlayerWaitTipsAndGoldText(positionParam, forceHideParam)
    local showObj = mPLAYERS_SLOT[positionParam]
    local showData = mRoomData.NNPlayerList[positionParam]
    if showData.IsValid == PlayerStateEnumNN.NULL then
        showObj.WaitTips:SetActive(false)
        showObj.GoldText.text = ""
        return
    end

    local isShow = showData.IsValid == PlayerStateEnumNN.JoinNO

    if forceHideParam then
        isShow = false
    end
    showObj.WaitTips:SetActive(isShow)
    if isShow then
        showObj.GoldText.text = ""
    else
        --TUDOU
        if currentRoomState ~= ROOM_STATE_NN.SETTLEMENT then
          showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.Gold,2))
        end
    end
end

-- 显示庄家tips
function ShowBankerTips(showParam)

    if mBankerTips.activeSelf == showParam then
        return
    end
    mBankerTips:SetActive(showParam)
end

-- 重置游戏房间到指定的游戏状态
function ResetGameRoomToRoomState(currentState)
    mRoomData = GameData.RoomInfo.CurrentRoom
    mMasterData = mRoomData.NNPlayerList[MAX_NNZUJU_ROOM_PLAYER]
    canPlaySoundEffect = false
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()

    InitRoomBaseInfos(currentsate)
    RefreshGameRoomToEnterGameState(currentState, true)
    canPlaySoundEffect = true
    InitRoomChange()
end

-- 刷新游戏房间进入到指定房间状态
function RefreshGameRoomByRoomStateSwitchTo(roomState)
    currentRoomState = roomState;
    RefreshGameRoomToEnterGameState(roomState, false)
end

-- 刷新游戏房间到游戏状态
function RefreshGameRoomToEnterGameState(roomState, isInit)
    --print(string.format("-----组局状态:[%d] CD:[%f] Init:[%s]时间:[%f]", roomState, mRoomData.CountDown, lua_BOLEAN_String(isInit), CS.UnityEngine.Time.time))
    RefreshStartPartOfGameRoomByState(roomState, isInit)
    RefreshWaitPartOfGameRoomByState(roomState, isInit)
    RefreshShufflePartOfGameRoomByState(roomState, isInit)
    RefreshPlayDealPartOfGameRoomByState(roomState, isInit)
    RefreshQiangZhuangPartOfGameRoomByState(roomState, isInit)
    RefreshQiangZhuangOverPartOfGameRoomByState(roomState, isInit)
    RefreshXuanDoublePartOfGameRoomByState(roomState, isInit)
    RefreshDoublePartOfGameRoomByState(roomState, isInit)
    RefreshCuoPartOfGameRoomByState(roomState, isInit)
    RefreshResultPartOfGameRoomByState(roomState, isInit)
    NNPrompt(roomState, isInit)
end

-- 重置房间信息到可以重新开局
function ResetGameRoomForReStart()

    -- 重置座位信息
    ResetGamePositionInfo()
    -- 重置扑克牌显示
    ResetPokerCardVisible()
    -- TODO

end

-- 重置游戏座位信息
function ResetGamePositionInfo()
    -- 重置座位信息
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        ResetPlayerInfo(mPLAYERS_SLOT[position])
        SetPlayerSitdownState(position)
        SetPlayerBaseInfo(position)
    end
end

-- 重置扑克牌显示
function ResetPokerCardVisible()
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        for cardIndex = 1, 5, 1 do
            SetTablePokerCardVisible(mPLAYERS_SLOT[position].Cards[cardIndex], false)
        end
    end
end

-------------------------------------------------------------------------------
----------------------------------- 牛牛提示------------------------------------
function NNPrompt(roomStateParam, initParam)
    if roomStateParam >= ROOM_STATE_NN.QIANG_ZHUANG and roomStateParam < ROOM_STATE_NN.CUO then
        if mRoomData.NNPlayerList[6].PlayerState > PlayerStateEnumNN.ZhunBeiOK then
            if TheFirstThree() then
                for i = 1, 3 do
                    GameObjectSetActive(SelectImage[i],true)
                end
                GameObjectSetActive(YouNiu,true)
            elseif TheLastThreeSheets() then
                for i = 2, 4 do
                    GameObjectSetActive(SelectImage[i],true)
                end
                GameObjectSetActive(YouNiu,true)
            elseif OneTwoFour() then
                GameObjectSetActive(SelectImage[4],true)
                for i =1, 2 do
                    GameObjectSetActive(SelectImage[i],true)
                end
                GameObjectSetActive(YouNiu,true)
            elseif OneThreeFour() then
                GameObjectSetActive(SelectImage[1],true)
                for i =3, 4 do
                    GameObjectSetActive(SelectImage[i],true)
                end
                GameObjectSetActive(YouNiu,true)
            end
        end
    else
        for i = 1, 4 do
            GameObjectSetActive(SelectImage[i],false)
        end
        GameObjectSetActive(YouNiu,false)
    end
end

-- 判断前三张
function TheFirstThree()
    local tNumber = 0
    for i = 1, 3 do
        local tnumber = mRoomData.NNPlayerList[6].Pokers[i].PokerNumber
        if tnumber > 10 then
            tnumber = 10
        end
        tNumber = tNumber + tnumber
    end
    if tNumber%10 == 0 then
        return true
    else
        return false
    end

end
-- 判断后三张
function TheLastThreeSheets()
    local tNumber = 0
    for i = 2, 4 do
        local tnumber = mRoomData.NNPlayerList[6].Pokers[i].PokerNumber
        if tnumber > 10 then
            tnumber = 10
        end
        tNumber = tNumber + tnumber
    end
    if tNumber%10 == 0 then
        return true
    else
        return false
    end
end
-- 判断一二四
function OneTwoFour()
    local tNumber = mRoomData.NNPlayerList[6].Pokers[4].PokerNumber
    if tNumber > 10 then
        tNumber = 10
    end
    for i = 1, 2 do
        local tnumber = mRoomData.NNPlayerList[6].Pokers[i].PokerNumber
        if tnumber > 10 then
            tnumber = 10
        end
        tNumber = tNumber + tnumber
    end
    if tNumber%10 == 0 then
        return true
    else
        return false
    end
end
-- 判断一三四张
function OneThreeFour()
    local tNumber = mRoomData.NNPlayerList[6].Pokers[1].PokerNumber
    if tNumber > 10 then
        tNumber = 10
    end
    for i = 3, 4 do
        local tnumber = mRoomData.NNPlayerList[6].Pokers[i].PokerNumber
        if tnumber > 10 then
            tnumber = 10
        end
        tNumber = tNumber + tnumber
    end
    if tNumber%10 == 0 then
        return true
    else
        return false
    end
end


-------------------------------------------------------------------------------
------------------------【等待开始阶段】[START] [1]----------------------------
function RefreshStartPartOfGameRoomByState(roomStateParam, initParam)

    this.transform:Find('Canvas/RoomWaitTips').gameObject:SetActive(false)
    if roomStateParam == ROOM_STATE_NN.START then
        CheckHomeowner()
        ResetGamePositionInfo()
    else
        ShowBeginAndInviteButton(false)
    end

end

-- 检测房主是否是自己
function CheckHomeowner()

    if mRoomData.MasterID == GameData.RoleInfo.AccountID then
        -- 自己是房主
        ShowBeginAndInviteButton(true)
        this.transform:Find('Canvas/RoomWaitTips').gameObject:SetActive(false)
    else
        ShowBeginAndInviteButton(false)
        this.transform:Find('Canvas/RoomWaitTips').gameObject:SetActive(true)
    end

end

---------------------------------------------------------------------------
------------------------【等待阶段】-------------------------------------

function RefreshWaitPartOfGameRoomByState(roomStateParam, initParam)
    if roomStateParam == ROOM_STATE_NN.WAIT or initParam == true then
        ResetGameRoomForReStart()
        -- 调用下GC回收
        lua_Call_GC()
        this:StopAllDelayInvoke()
        UpdateButtonInvite1ShowState()
    elseif roomStateParam >= ROOM_STATE_NN.DEAL then

    end

    -- 检测玩家是否处于空闲状态
    if roomStateParam <= ROOM_STATE_NN.DEAL then
        RefreshAllPlayerWaitTipsAndGoldText(true)
    else
        RefreshAllPlayerWaitTipsAndGoldText(false)
    end
    ZBButtonShowState(roomStateParam == ROOM_STATE_NN.WAIT)
    HandlePlayerZBImageShowState(roomStateParam == ROOM_STATE_NN.WAIT)
    RefreshBankerTipsShowState(roomStateParam)
    RefreshRoomWaitTips2ShowState(roomStateParam)
end

-- 刷新庄家标签显示状态
function RefreshBankerTipsShowState(roomStateParam)
    if roomStateParam >= ROOM_STATE_NN.WAIT and roomStateParam <= ROOM_STATE_NN.QIANG_ZHUANG_OVER and mRoomData.RoomType ~= ROOM_TYPE.TONGBI then
        ShowBankerTips(true)
    else
        ShowBankerTips(false)
    end
end

function ZBButtonShowState( showParam )
    if  ZBButtonGameObject.activeSelf == showParam then
        return
    end
    ZBButtonGameObject:SetActive(showParam)
end

-- 设置是否需要显示等待下一局
function ShowRoomWaitTips2(show)
    if mRoomWaitTips2.activeSelf == show then
        return
    end
    mRoomWaitTips2:SetActive(show)
end

function RefreshRoomWaitTips2ShowState(roomStateParam)
    -- body
    if roomStateParam <= ROOM_STATE_NN.WAIT then
        ShowRoomWaitTips2(false)
    else
        ShowRoomWaitTips2(mMasterData.PlayerState < PlayerStateEnumNN.JoinOK)
    end
end

-- 玩家准备事件通知
function OnNotifyNNZJPlayerReadyEvent( positionParam )
    ZBImageShow(positionParam,mRoomData.NNPlayerList[positionParam].PlayerState == PlayerStateEnumNN.ZhunBeiOK)
    if positionParam  == MAX_NNZUJU_ROOM_PLAYER then
        ZBButtonShowState(false)
    end
end

--==============================--
--desc:处理玩家准备标记图标显示状态
--time:2018-01-04 04:55:29
--@isCheckParam:
--@return 
--==============================--
function HandlePlayerZBImageShowState(isCheckParam )
    -- body
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        local showState = false
        if isCheckParam == true then
            showState = mRoomData.NNPlayerList[position].PlayerState == PlayerStateEnumNN.ZhunBeiOK
        else
            showState = false
        end
        ZBImageShow(position,showState)
    end
end

-- 玩家准备标记显示
function ZBImageShow( positionParam,  showParam)
    if mPLAYERS_SLOT[positionParam].ZBImage.activeSelf == showParam  then
        return
    end
    mPLAYERS_SLOT[positionParam].ZBImage:SetActive(showParam)
end

---------------------------------------------------------------------------
------------------------【洗牌阶段】-------------------------------------
function RefreshShufflePartOfGameRoomByState(roomStateParam, initParam)
    if roomStateParam == ROOM_STATE_NN.SHUFFLE then
        -- 该阶段 会确认遗留下来的玩家状态
    else

    end
    ShowShuffleAni(false)
end

function ShowShuffleAni(showParam)
    if mShuffleAni.activeSelf == showParam then
        return
    end
    mShuffleAni:SetActive(showParam)
end

-------------------------------------------------------------------------------
-------------------------------【发牌阶段】[DEAL][7]----------------------------------
function RefreshPlayDealPartOfGameRoomByState(roomStateParam, initParam)
    if roomStateParam == ROOM_STATE_NN.DEAL then
        -- 可以播放发牌动画的玩家
        if initParam == true then
            -- 直接将牌摆好
            for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
                if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK then
                    for cardIndex = 1, 5, 1 do
                        CS.Utility.ReSetTransform(mPLAYERS_SLOT[position].Cards[cardIndex], mPLAYERS_SLOT[position].CardRoot)
                        lua_Paste_Transform_Value(mPLAYERS_SLOT[position].Cards[cardIndex], mPLAYERS_SLOT[position].Points[cardIndex])
                    end
                end
            end
            CheckSelfBefore3PokerLight(false)

            ShowShuffleAni(false)
        else
            PlayDealAnimation()
        end
    elseif roomStateParam > ROOM_STATE_NN.DEAL then
        -- TODO
        if initParam == true then
            -- 直接将牌摆好
            for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
                if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK then
                    for cardIndex = 1, 5, 1 do
                        CS.Utility.ReSetTransform(mPLAYERS_SLOT[position].Cards[cardIndex], mPLAYERS_SLOT[position].CardRoot)
                        lua_Paste_Transform_Value(mPLAYERS_SLOT[position].Cards[cardIndex], mPLAYERS_SLOT[position].Points[cardIndex])
                    end
                end
            end
            CheckSelfBefore3PokerLight(false)
        end

        for index = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            if PlayerStateEnumNN.JoinOK == mRoomData.NNPlayerList[index].IsValid then
                if false == mPLAYERS_SLOT[index].CardRoot.gameObject.activeSelf then
                    mPLAYERS_SLOT[index].CardRoot.gameObject:SetActive(true)
                end
            end
        end
    else
        for index = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            if true == mPLAYERS_SLOT[index].CardRoot.gameObject.activeSelf then
                mPLAYERS_SLOT[index].CardRoot.gameObject:SetActive(false)
            end
        end
    end
end

-- 发牌动画方案2
function PlayDealAnimation()
    -- 可以播放发牌动画的玩家
    local tresetPosition = { }
    for position = MAX_NNZUJU_ROOM_PLAYER, 1, -1 do
        if PlayerStateEnumNN.JoinOK == mRoomData.NNPlayerList[position].IsValid then
            table.insert(tresetPosition, position)
        end
    end

    -- 发牌动画播放
    for cardIndex = 5, 1, -1 do
        for k1, v1 in pairs(tresetPosition) do
            -- 位置重置中心
            CS.Utility.ReSetTransform(mPLAYERS_SLOT[v1].Cards[cardIndex], POKER_JOINTS[v1 * 10 + cardIndex])
        end
    end
    local tcanPlayAnimationPosition = { }
    for index = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if PlayerStateEnumNN.JoinOK == mRoomData.NNPlayerList[index].IsValid then
            table.insert(tcanPlayAnimationPosition, index)
        end
    end
    local delayTime = 0
    for pokerIndex = 1, 5, 1 do

        for k1, v1 in pairs(tcanPlayAnimationPosition) do
            SetTablePokerCardVisible(mPLAYERS_SLOT[v1].Cards[pokerIndex], false)

            local pokerCard1 = mRoomData.NNPlayerList[v1].Pokers[pokerIndex]

            delayTime = delayTime + 0.1
            this:DelayInvoke(delayTime,
            function()
                mPLAYERS_SLOT[v1].CardRoot.gameObject:SetActive(true)
                local cardItem = mPLAYERS_SLOT[v1].Cards[pokerIndex]
                lua_Clear_AllUITweener(cardItem)

                if cardItem.gameObject.activeSelf == false then
                    cardItem.gameObject:SetActive(true)
                end

                local pokerCard = mRoomData.NNPlayerList[v1].Pokers[pokerIndex]
                local script = cardItem.gameObject:AddComponent(typeof(CS.TweenTransform))
                script.from = POKER_JOINTS[v1 * 10 + pokerIndex]
                script.to = mPLAYERS_SLOT[v1].Points[pokerIndex]
                script.duration = 0.4
                script:OnFinished("+",
                ( function()
                    CS.UnityEngine.Object.Destroy(script)
                    if pokerCard.PokerNumber > 0 then
                        cardItem:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(pokerCard))
                    end
                    SetTablePokerCardVisible(cardItem, pokerCard.Visible)
                    -- TODO 测试
                    CS.Utility.ReSetTransform(cardItem, mPLAYERS_SLOT[v1].CardRoot)
                    lua_Paste_Transform_Value(cardItem, script.to)
                end ))
                script:Play(true)
                -- 音效发牌音效
                PlaySoundEffect('NN_fapai')
            end )

        end

    end
    -- 最后需要隐藏洗牌组件
    this:DelayInvoke(0.1, function() ShowShuffleAni(false) end)
end

-- 设置玩家扑克牌是否可见
function SetTablePokerCardVisible(pokerCard, isVisible)
    if nil == pokerCard then
        error('玩家扑克牌数据异常')
        return
    end
    if pokerCard:Find('back').gameObject.activeSelf == lua_NOT_BOLEAN(isVisible) then
        return
    end
    pokerCard:Find('back').gameObject:SetActive(lua_NOT_BOLEAN(isVisible))
    if isVisible then
        -- 翻牌音效
    end
end

-- 检测自己前3张是否需要名牌(参数:是否强制亮牌)
function CheckSelfBefore3PokerLight(isForceParam)
    if mMasterData.IsValid == PlayerStateEnumNN.JoinOK then
        if mRoomData.LightPoker == 1 or isForceParam == true then
            -- 前4张亮牌
            for index = 1, 4, 1 do
                local cardItem = mPLAYERS_SLOT[MAX_NNZUJU_ROOM_PLAYER].Cards[index]
                local pokerCard = mMasterData.Pokers[index]
                SetTablePokerCardVisible(cardItem, true)
                cardItem:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(pokerCard))
            end
        end
    end
end

-------------------------------------------------------------------------------
------------------------------- 【抢庄阶段】[QIANG_ZHUANG][13]各个玩家抢庄状态-------------------
function RefreshQiangZhuangPartOfGameRoomByState(roomStateParam, initParam)
    if roomStateParam == ROOM_STATE_NN.QIANG_ZHUANG then
        for index = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            if PlayerStateEnumNN.JoinOK == mRoomData.NNPlayerList[index].IsValid then
                local playerState = mRoomData.NNPlayerList[index].PlayerState
                if playerState == PlayerStateEnumNN.QiangZhuangNO or playerState == PlayerStateEnumNN.QiangZhuangNO then
                    RefreshPlayerQiangZhuangState(index, true)
                else
                    RefreshPlayerQiangZhuangState(index, false)
                    if index == MAX_NNZUJU_ROOM_PLAYER then
                        -- 自己的抢庄按钮处理
                        this.transform:Find('Canvas/MasterInfo/QiangZhuangButton').gameObject:SetActive(CanQiangZhuang(MAX_NNZUJU_ROOM_PLAYER))
                        this.transform:Find('Canvas/MasterInfo/QiangZhuangTips').gameObject:SetActive(lua_NOT_BOLEAN(CanQiangZhuang(MAX_NNZUJU_ROOM_PLAYER)))
                        SetQiangZhuangBetTips()
                    end
                end
            else
                mPLAYERS_SLOT[index].QiangZhuang.gameObject:SetActive(false)
            end

        end
        RefreshQiangZhuangCountDownState(true)
        -- 自己未参与
        if mMasterData.IsValid ~= PlayerStateEnumNN.JoinOK then
            this.transform:Find('Canvas/MasterInfo/QiangZhuangWaitTips').gameObject:SetActive(true)
        end
    else
        -- 自己的抢庄按钮处理
        this.transform:Find('Canvas/MasterInfo/QiangZhuangButton').gameObject:SetActive(false)
        this.transform:Find('Canvas/MasterInfo/QiangZhuangWaitTips').gameObject:SetActive(false)
        this.transform:Find('Canvas/MasterInfo/QiangZhuangTips').gameObject:SetActive(false)
        RefreshQiangZhuangCountDownState(false)
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

-- 玩家抢庄状态更新
function OnNotifyZJRoomPlayerQiangZhuang(positionParam)

    RefreshPlayerQiangZhuangState(positionParam, true)
    if positionParam == MAX_NNZUJU_ROOM_PLAYER then
        -- 自己抢庄按钮更新
        this.transform:Find('Canvas/MasterInfo/QiangZhuangButton').gameObject:SetActive(false)
        this.transform:Find('Canvas/MasterInfo/QiangZhuangWaitTips').gameObject:SetActive(true)
    end

end

-- 设置抢庄参与条件
function SetQiangZhuangBetTips()

    local playerCount = 0
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK then
            playerCount = playerCount + 1
        end
    end
    playerCount = playerCount - 1
    local showTips = string.format(data.GetString("NN_QZ_Tips"), data.PublicConfig.NN_ZUJU_ADMISSION * mRoomData.MinBet)
    this.transform:Find('Canvas/MasterInfo/QiangZhuangTips/Text'):GetComponent('Text').text = showTips

end

-- 能否参与抢庄
function CanQiangZhuang(positionParam)

    if mRoomData.NNPlayerList[positionParam].IsValid ~= PlayerStateEnumNN.JoinOK then
        return false
    end

    local playerCount = 0
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK then
            playerCount = playerCount + 1
        end
    end
    playerCount = playerCount - 1
    local minGold = mRoomData.MinBet * playerCount * 3
    return mRoomData.NNPlayerList[positionParam].Gold >= minGold

end


-------------------------------------------------------------------------------
---------------【抢庄阶段结束】[QIANG_ZHUANG_OVER][14]展示各个玩家抢庄状态

function RefreshQiangZhuangOverPartOfGameRoomByState(roomStateParam, initParam)
    if roomStateParam == ROOM_STATE_NN.QIANG_ZHUANG_OVER then
        for index = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            if PlayerStateEnumNN.JoinOK == mRoomData.NNPlayerList[index].IsValid then
                RefreshPlayerQiangZhuangState(index, true)
            end
        end
    else
        for index = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            RefreshPlayerQiangZhuangState(index, false)
        end
    end
end

-- 刷新玩家抢庄标识显示
function RefreshPlayerQiangZhuangState(positionParam, showParam)

    if mPLAYERS_SLOT[positionParam].QiangZhuang.gameObject.activeSelf == showParam then
        return
    end
    mPLAYERS_SLOT[positionParam].QiangZhuang.gameObject:SetActive(showParam)

    local playerState = mRoomData.NNPlayerList[positionParam].PlayerState

    if showParam == true then
        if playerState == PlayerStateEnumNN.QiangZhuangNO or playerState == PlayerStateEnumNN.QiangZhuangOK then
            if playerState == PlayerStateEnumNN.QiangZhuangNO then
                mPLAYERS_SLOT[positionParam].QiangZhuang:Find('NO').gameObject:SetActive(true)
                mPLAYERS_SLOT[positionParam].QiangZhuang:Find('OK').gameObject:SetActive(false)
                PlaySoundEffect('NN_qiang_2')
            elseif playerState == PlayerStateEnumNN.QiangZhuangOK then
                mPLAYERS_SLOT[positionParam].QiangZhuang:Find('NO').gameObject:SetActive(false)
                mPLAYERS_SLOT[positionParam].QiangZhuang:Find('OK').gameObject:SetActive(true)
                PlaySoundEffect('NN_qiang_1')
            end
            local tweenScale = mPLAYERS_SLOT[positionParam].QiangZhuang:GetComponent('TweenScale')
            tweenScale:ResetToBeginning()
            tweenScale:Play(true)
            -- 延迟隐藏
            this:DelayInvoke(0.4,
            function()
                mPLAYERS_SLOT[positionParam].QiangZhuang:GetComponent('TweenScale').enabled = false
            end )
            PlaySelfQiangZhuangStateSound(positionParam)
        else
            -- TODO
            -- 非抢庄状态
            mPLAYERS_SLOT[positionParam].QiangZhuang.gameObject:SetActive(false)
        end
    end
end

-- 播放玩家自己抢庄表示语音
function PlaySelfQiangZhuangStateSound(positionParam)
    if positionParam == MAX_NNZUJU_ROOM_PLAYER then
        if mMasterData.PlayerState == PlayerStateEnumNN.QiangZhuangOK then
            PlaySoundEffect('NN_qiang_1')
        else
            PlaySoundEffect('NN_qiang_2')
        end
    end
end

-------------------------------------------------------------------------------
----------------------刷新【选庄阶段】[XUAN_ZHUANG][15]各个玩家抢庄状态--------
function RefreshXuanDoublePartOfGameRoomByState(roomStateParam, initParam)
    if roomStateParam == ROOM_STATE_NN.XUAN_ZHUANG then

        if initParam == true then
            if mRoomData.BankerID > 0 then
                local bankerPos = mRoomData.BankerID
                RefreshBankerTagShowState(bankerPos, true)
                -- ShowBankerEffect(bankerPos, true)
            end
            return
        end

        local tBankerJoin = { }
        for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            if PlayerStateEnumNN.JoinOK == mRoomData.NNPlayerList[position].IsValid then
                if mRoomData.NNPlayerList[position].PlayerState == PlayerStateEnumNN.QiangZhuangOK then
                    table.insert(tBankerJoin, position)
                end
            else
                mPLAYERS_SLOT[position].BankerTips1.gameObject:SetActive(false)
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
                if PlayerStateEnumNN.JoinOK == mRoomData.NNPlayerList[index].IsValid then
                    if mRoomData.NNPlayerList[index].PlayerState == PlayerStateEnumNN.QiangZhuangOK then
                        table.insert(tRoundResult, index)
                    end
                end
            end
            -- 每次停留时间
            local onceTime = 0.2
            for k2, v2 in pairs(tRoundResult) do
                this:DelayInvoke((k2 - 1) * onceTime,
                function()
                    mPLAYERS_SLOT[v2].BankerTips1.gameObject:SetActive(true)
                    this:DelayInvoke(onceTime,
                    function()
                        mPLAYERS_SLOT[v2].BankerTips1.gameObject:SetActive(false)

                    end )
                end )
            end
            -- 最后定庄显示
            this:DelayInvoke(#tRoundResult * onceTime,
            function()
                -- 定庄特效
                ShowBankerEffect(bankerPos, true)
            end )

            this:DelayInvoke(#tRoundResult * onceTime + 1,
            function()
                -- 飞庄特效
                RefreshBankerTagShowState(bankerPos, true)
            end )


        elseif bankerCount == 1 then
            local bankerPos = mRoomData.BankerID
            RefreshBankerTagShowState(bankerPos, true)
            -- 一人抢庄 直接定庄 无特效
            -- ShowBankerEffect(bankerPos, true)
        else
            -- 无庄家
            print('本局无庄家*****')
        end
    elseif roomStateParam > ROOM_STATE_NN.XUAN_ZHUANG then
        -- 处于选庄阶段之后
        local bankerPos = mRoomData.BankerID
        if bankerPos > 0 and mRoomData.RoomType ~= ROOM_TYPE.TONGBI then
            RefreshBankerTagShowState(bankerPos, true)
        end
    else
        -- TODO其他阶段
        for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            mPLAYERS_SLOT[position].BankerTips1.gameObject:SetActive(false)
            RefreshBankerTagShowState(position, false)
            ShowBankerEffect(position, false)
        end
    end
end

-- 庄家定庄标记显示
function RefreshBankerTagShowState(positionParam, showParam)

    if mPLAYERS_SLOT[positionParam].BankerTips2.gameObject.activeSelf == showParam then
        return
    end

    if true == showParam then
        local tweenTransform = mPLAYERS_SLOT[positionParam].BankerTips2:Find('BankerTips'):GetComponent('TweenTransform')
        tweenTransform:ResetToBeginning()
        tweenTransform:Play(true)
        ShowBankerTips(false)
        -- 进入音效
        PlaySoundEffect('NN_zhuang')
    end
    mPLAYERS_SLOT[positionParam].BankerTips2.gameObject:SetActive(showParam)

end

-- 显示定庄特效
function ShowBankerEffect(positionParam, showParam)
    -- 定庄特效
    mPLAYERS_SLOT[positionParam].BankerTips3.gameObject:SetActive(showParam)
    if true == showParam then
        local spriteAnimation = mPLAYERS_SLOT[positionParam].BankerTips3:GetComponent('UGUISpriteAnimation')
        spriteAnimation:RePlay()
        -- 延迟隐藏
        this:DelayInvoke(1.2,
        function()
            mPLAYERS_SLOT[positionParam].BankerTips3.gameObject:SetActive(false)

        end )
    end

end

-------------------------------------------------------------------------------
----------------------- 刷新【加倍阶段】[XUAN_DOUBLE] [OVER_DOUBLE] [16-17]各个玩家加倍---------
function RefreshDoublePartOfGameRoomByState(roomStateParam, initParam)

    if roomStateParam == ROOM_STATE_NN.XUAN_DOUBLE then
        RefreshDoubleCountDownState(true)
        for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            RefreshPlayerDoubleValue(position)
        end
        -- 检测自己加倍按钮是否开启
        if mMasterData.IsValid == PlayerStateEnumNN.JoinOK and mRoomData.BankerID ~= MAX_NNZUJU_ROOM_PLAYER then
            -- 自己参与本局游戏 并且不是庄家 状态属于为确认抢庄
            if mMasterData.PlayerState <= PlayerStateEnumNN.QiangZhuangNO then
                ShowBetXXX(true)
            else
                ShowBetXXX(false)
            end
        else
            ShowBetXXX(false)
        end

        if mRoomData.BankerID == MAX_NNZUJU_ROOM_PLAYER or mMasterData.IsValid ~= PlayerStateEnumNN.JoinOK then
            -- 自己是庄家
            ShowDoubleWaitTips(true)
        end

    elseif roomStateParam >= ROOM_STATE_NN.OVER_DOUBLE then
        -- TODO
        for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            RefreshPlayerDoubleValue(position)
        end
        ShowBetXXX(false)
        ShowDoubleWaitTips(false)
        RefreshDoubleCountDownState(false)
    else
        ShowBetXXX(false)
        ShowDoubleWaitTips(false)
        RefreshDoubleCountDownState(false)
    end

end

--==============================--
--desc:更新玩家可以下注倍率
--time:2018-01-06 11:16:06
--@return 
--==============================--
function RefreshJiaBeiValues()
    
    local tPlayerCompensate = mMasterData.nCompensate
    local tBankerCompensate = mRoomData.nBankerCompensate
    local tCompensateMin = data.PublicConfig.NN_ZUJU_BET_MIN
    -- 玩家可以下注最大值
    tPlayerCompensate = math.min( tPlayerCompensate, tBankerCompensate )
    tPlayerCompensate = math.max( tPlayerCompensate, tCompensateMin)
    -- 调整为固定倍率
    -- mNN_ZUJU_JIABEI[1] = tCompensateMin
    -- mNN_ZUJU_JIABEI[4] = tPlayerCompensate
    -- local tCompensate3 = math.floor( tPlayerCompensate * 0.5)
    -- tCompensate3 = math.min( tCompensate3, tPlayerCompensate)
    -- mNN_ZUJU_JIABEI[3] = math.max( tCompensate3, tCompensateMin)
    -- local tCompensate2 = math.floor( tPlayerCompensate * 0.3)
    -- local tCompensate2 = math.min( tCompensate2, tCompensate3 )
    -- tCompensate2 = math.max( tCompensate2, tCompensateMin )
    -- mNN_ZUJU_JIABEI[2] = tCompensate2

    this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton1/Text'):GetComponent("Text").text = string.format( "x%d", mNN_ZUJU_JIABEI[1])
    this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton2/Text'):GetComponent("Text").text = string.format( "x%d", mNN_ZUJU_JIABEI[2])
    this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton3/Text'):GetComponent("Text").text = string.format( "x%d", mNN_ZUJU_JIABEI[3])
    this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton4/Text'):GetComponent("Text").text = string.format( "x%d", mNN_ZUJU_JIABEI[4])
    for i = 1, 4 do
        this.transform:Find('Canvas/MasterInfo/DoubleButtons/JBButton'..i):GetComponent("Button").interactable = (mNN_ZUJU_JIABEI[i] <= tPlayerCompensate)
    end
end

-- 刷新指定玩家下注倍率
function RefreshPlayerDoubleValue(positionParam)

    local tPlayerData = mRoomData.NNPlayerList[positionParam]
    local tPlayerState = tPlayerData.PlayerState
    if PlayerStateEnumNN.JoinOK == tPlayerData.IsValid and positionParam ~= mRoomData.BankerID then
        if tPlayerState == PlayerStateEnumNN.DoubleOK or tPlayerState == PlayerStateEnumNN.DoubleNO then
            if mPLAYERS_SLOT[positionParam].DoubleTips.activeSelf == false then
                mPLAYERS_SLOT[positionParam].DoubleTips:SetActive(true)
                local tweenScale = mPLAYERS_SLOT[positionParam].DoubleTips:GetComponent('TweenScale')
                tweenScale:ResetToBeginning()
                tweenScale:Play(true)
                -- 延迟隐藏
                this:DelayInvoke(0.4,
                function() mPLAYERS_SLOT[positionParam].DoubleTips:GetComponent('TweenScale').enabled = false    end )

                mPLAYERS_SLOT[positionParam].DoubleTips.transform:Find('TipsOK').gameObject:SetActive(true)
                mPLAYERS_SLOT[positionParam].DoubleTips.transform:Find('TipsOK/Text'):GetComponent("Text").text = string.format( "X%d", tPlayerData.nBetCompensate)
                PlaySelfDoubleStateSound(positionParam,tPlayerState)
            end
        else
            mPLAYERS_SLOT[positionParam].DoubleTips:SetActive(false)
        end
    else
        mPLAYERS_SLOT[positionParam].DoubleTips:SetActive(false)
    end

end

-- 自己是庄家时，提示等待他人加倍
function ShowDoubleWaitTips(show)
    this.transform:Find('Canvas/MasterInfo/DoubleWaitTips').gameObject:SetActive(show)
end

-- 刷新加倍CD显示
function RefreshDoubleCountDownState(isActive)

    ShowCountDown(isActive)
    isUpdateDoubleCountDown = isActive

end

-- 更新加倍CD
function UpdateDoubleCountDown()
    if isUpdateDoubleCountDown == true then
        RefreshCountDownText()
    end
end

-- 玩家加倍状态更新
function OnNotifyZJRoomPlayerDouble(positionParam)

    if positionParam == MAX_NNZUJU_ROOM_PLAYER then
        -- 自己加倍按钮
        ShowBetXXX(false)
        ShowDoubleWaitTips(true)
    end
    RefreshPlayerDoubleValue(positionParam)
end

-- 播放自己加倍状态音效
function PlaySelfDoubleStateSound(positionParam,tPlayerState)
    --if positionParam == MAX_NNZUJU_ROOM_PLAYER then
        if tPlayerState == PlayerStateEnumNN.DoubleOK then
            PlaySoundEffect('NN_jiabei_1')
        else
            PlaySoundEffect('NN_jiabei_2')
        end
    --end
end

-------------------------------------------------------------------------------
------------------------------- 进入【搓牌阶段】[CUO][OVER_CUO][18-19]---------------------------
-- 是否已经进入搓牌动画
local isStartEnterCheckAnimation = false
-- 进入搓牌动画时间
local isStartEnterCheckAnimationTime = 0

function RefreshCuoPartOfGameRoomByState(roomStateParam, initParam)

    if roomStateParam == ROOM_STATE_NN.CUO then
        for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            -- 设置玩家扑克牌点数
            SetPlayerPokerCardPoint(position)
            -- 已经翻牌玩家
            if mRoomData.NNPlayerList[position].IsCuoPai == 1 then
                for index = 1, 5, 1 do
                    local cardItem = mPLAYERS_SLOT[position].Cards[index]
                    SetTablePokerCardVisible(cardItem, true)
                end
                PlaySplitPokerCardsAnimation(position, mRoomData.NNPlayerList[position].CanPlaySplitPkoerAnimation)
                mRoomData.NNPlayerList[position].CanPlaySplitPkoerAnimation = false
            end
        end
        if mMasterData.IsValid == PlayerStateEnumNN.JoinOK then
            if mMasterData.IsCuoPai == 1 then
                -- 自己已经搓牌了
                return
            else
                -- 前3张亮牌
                CheckSelfBefore3PokerLight(true)
                -- TODO 搓牌开始
                if initParam then
                    local passedTime = mRoomData.CountDown
                    -- 本次进入与上一次进入的时间差
                    local isStartEnterCheckAnimationTimePass = Time.realtimeSinceStartup - isStartEnterCheckAnimationTime

                    if isStartEnterCheckAnimationTimePass < 10 then
                        -- 本次进入时间与上一次时间少于10秒 认为是同一局游戏再次进入
                        if mRoomData.CountDown < 3 then
                            -- 切出去再回来 小于3秒 自动发送搓牌
                            -- ShowPokerHandle(false)
                            NetMsgHandler.Send_CS_ZJRoom_CuoPai()
                            -- 临界值切入切出 最后一张牌需要显示出来
                            local cardItem = mPLAYERS_SLOT[MAX_NNZUJU_ROOM_PLAYER].Cards[5]
                            cardItem.gameObject:SetActive(true)
                        else
                            ShowPokerHandle(true)
                            StartEnterCheckAnimation(true, false)
                        end
                    else
                        -- 本次进入时间与上一次时间大于10秒 认为是非同一局游戏再次进入
                        ShowPokerHandle(true)
                        -- 飞牌动画（从牌的节点 4- 5 分别飞到挂接点）
                        isStartEnterCheckAnimationTime = Time.realtimeSinceStartup
                        StartEnterCheckAnimation(true, true)
                    end
                else
                    -- 正常流程进入
                    ShowPokerHandle(true)
                    -- 飞牌动画（从牌的节点 4- 5 分别飞到挂接点）
                    isStartEnterCheckAnimationTime = Time.realtimeSinceStartup
                    StartEnterCheckAnimation(true, true)
                end
            end
        else
            ShowCuoPaiWaitTips(true)
        end
    elseif roomStateParam == ROOM_STATE_NN.OVER_CUO then
        -- 搓牌结束 等待自己的搓牌动作完毕
        RefreshOpenPokerCardButtonState(false)
        ShowCuoPaiWaitTips(false)
        RefreshEveryOnePokerType(initParam)
    else
        ShowCuoPaiWaitTips(false)
        ShowPokerHandle(false)
        RefreshOpenPokerCardButtonState(false)
        isStartEnterCheckAnimation = false
        isOpenPokerCardAnimation = false
    end
end

-- 设置对应位置玩家扑克牌点数(按原始顺序)
function SetPlayerPokerCardPoint(positionParam)

    for cardIndex = 1, 5, 1 do
        local cardTransfrom = mPLAYERS_SLOT[positionParam].Cards[cardIndex]
        local cardData = mRoomData.NNPlayerList[positionParam].Pokers[cardIndex]
        if cardData.PokerNumber > 0 then
            cardTransfrom:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(cardData))
        end
    end

end

-- 设置搓牌组件显示
function ShowPokerHandle(show)

    if mPokerHandle.activeSelf == show then
        return
    end
    mPokerHandle:SetActive(show)

end

function StartEnterCheckAnimation(isHandler, isAni)
    isStartEnterCheckAnimation = true
    local tUINode = mPLAYERS_SLOT[MAX_NNZUJU_ROOM_PLAYER]
    -- 翻牌5
    local pokerCard2 = mMasterData.Pokers[5]
    -- 设置 可操作的牌
    local handleCard2 = this.transform:Find('Canvas/PokerHandle/HandleCard2'):GetComponent("PageCurl")
    handleCard2:ResetSprites(GameData.GetPokerCardBackSpriteNameOfBig(pokerCard2), GameData.GetPokerCardSpriteNameOfBig(pokerCard2))
    handleCard2.UserData = 5
    handleCard2.gameObject:SetActive(false)
    
    local pokerCard2Item = tUINode.Cards[5]
    pokerCard2Item.gameObject:SetActive(true)
    AddEventOfHandlePokerCard(handleCard2)
    pokerCard2Item:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteNameOfBig(pokerCard2))
    local handleJoint2 = this.transform:Find('Canvas/PokerHandle/Points/HandlePoint2')
    CheckStartAnimation(pokerCard2Item, tUINode.Points[5], handleJoint2, handleCard2, isAni)

    RefreshOpenPokerCardButtonState(true)
end

-- 刷新开拍按钮状态
function RefreshOpenPokerCardButtonState(isActive)
    ShowOpenPokerButton(isActive)
    isUpdateOpenPokerCountDown = isActive
end

-- 翻牌CD
local mOpenCardCD = 0

-- 更新玩家开牌按钮CD
function UpdateOpenPokerCardCountDown()
    if isUpdateOpenPokerCountDown == true then
        local tCountDown = math.ceil(mRoomData.CountDown)
        if tCountDown < 0 then
            tCountDown = 0
        end
        if mOpenCardCD ~= tCountDown then
            mOpenCardCD = tCountDown
            mButtonOpenText.text = lua_FormatToCountdownStyle(mOpenCardCD)
        end
    end
end

function CheckStartAnimation(cardItem, from, to, handleCard, isAni)
    handleCard.transform.position = to.position
    if isAni then
        local script = cardItem.gameObject:AddComponent(typeof(CS.TweenTransform))
        script.from = from
        script.to = to
        script.duration = 0.4
        script:OnFinished("+",( function() CheckStartAnimationEnd(cardItem, script, handleCard) end))
        script:Play(true)
    else
        lua_Paste_Transform_Value(cardItem, to)
        CheckStartAnimationEnd(cardItem, script, handleCard)
    end
end

function CheckStartAnimationEnd(cardItem, script, handleCard)
    CS.UnityEngine.Object.Destroy(script)
    cardItem.gameObject:SetActive(false)
    handleCard.gameObject:SetActive(true)
    handleCard:ResetPageCurl(888, 600, true, true)
end

function AddEventOfHandlePokerCard(handleCard)
    handleCard:OpenCardCallBack('-', OpenOneCard)
    handleCard:OpenCardCallBack('+', OpenOneCard)
end

function OpenOneCard(userData)
    local pokerIndex = tonumber(userData)
    -- 搓牌自己的5张
    local index = pokerIndex
    -- 4/5 --调整为只翻1张牌
    local isLastOne = true
    if isLastOne then
        NetMsgHandler.Send_CS_ZJRoom_CuoPai()
        HandleOpenPokerCardAnimationStepOne()
        ShowOpenPokerButton(false)
    else
    end
end

local isOpenPokerCardAnimation = false

-- 有玩家的开牌动画1
function HandleOpenPokerCardAnimationStepOne()
    isStartEnterCheckAnimation = false
    isOpenPokerCardAnimation = true

    local pokerIndex = 5
    local pokerCard = mMasterData.Pokers[pokerIndex]
    local cardItem = mPLAYERS_SLOT[MAX_NNZUJU_ROOM_PLAYER].Cards[pokerIndex]
    SetTablePokerCardVisible(cardItem, true)
    cardItem.gameObject:SetActive(true)
    local pageCurl = this.transform:Find('Canvas/PokerHandle/HandleCard2'):GetComponent("PageCurl")
    pageCurl.gameObject:SetActive(false)
    lua_Clear_AllUITweener(cardItem)
    if pageCurl.IsSpriteRotated then
        cardItem.eulerAngles = CS.UnityEngine.Vector3(0, 0, 90)
        local script = cardItem.gameObject:AddComponent(typeof(CS.TweenRotation))
        script.from = CS.UnityEngine.Vector3(0, 0, 90)
        script.to = CS.UnityEngine.Vector3.zero
        script.duration = 0.2
        script:OnFinished("+",( function() CS.UnityEngine.Object.Destroy(script) end))
        script:Play(true)
    else
        cardItem.eulerAngles = CS.UnityEngine.Vector3(0, 0, 0)
    end

    this:DelayInvoke(0.3, function() HandleOpenPokerCardAnimationStepTwo() end)
end

-- 有玩家的开牌动画2
function HandleOpenPokerCardAnimationStepTwo()
    ---- 扑克牌飞回到原始位置
    local pokerIndex = 5
    local pokerCard = mMasterData.Pokers[pokerIndex]
    local cardItem = mPLAYERS_SLOT[MAX_NNZUJU_ROOM_PLAYER].Cards[pokerIndex]
    cardItem.gameObject:SetActive(true)
    local script = cardItem.gameObject:AddComponent(typeof(CS.TweenTransform))

    script.to = mPLAYERS_SLOT[MAX_NNZUJU_ROOM_PLAYER].Points[pokerIndex]
    script.duration = 0.3
    script:OnFinished("+",
    ( function()
        CS.UnityEngine.Object.Destroy(script)
        isOpenPokerCardAnimation = false
        PlaySplitPokerCardsAnimation(MAX_NNZUJU_ROOM_PLAYER, true)
    end ))
    script:Play(true)
    -- 搓牌还原
    ShowPokerHandle(false)
end

-- 等待他人搓牌显示
function ShowCuoPaiWaitTips(showParam)
    ShowCountDown(showParam)
    isUpdateCuoPokerCountDown = showParam
    if mCuoPaiWaitTips.activeSelf == showParam then
        return
    end
    mCuoPaiWaitTips:SetActive(showParam)
end

-- 更新等待他人搓牌倒计时
function UpdateCuoPokerCountDown()
    if isUpdateCuoPokerCountDown == true then
        RefreshCountDownText()
    end
end

-- 刷新所有玩家的扑克牌牌型
function RefreshEveryOnePokerType(initParam)

    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK then
            for cardIndex = 1, 5, 1 do
                local cardTransform = mPLAYERS_SLOT[position].Cards[cardIndex]
                local cardData = mRoomData.NNPlayerList[position].Pokers[cardIndex]
                SetTablePokerCardVisible(cardTransform, cardData.Visible)
                if initParam == true then
                    -- 扑克牌面重置
                    cardTransform:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(cardData))
                end
                cardTransform.gameObject:SetActive(true)
            end
            if mRoomData.NNPlayerList[position].IsCuoPai == 1 then
                -- 分牌动画
                if position == MAX_NNZUJU_ROOM_PLAYER and mRoomData.NNPlayerList[position].CanPlaySplitPkoerAnimation == false then
                    -- 结算期间 自己已经分牌 直接分开
                    PlaySplitPokerCardsAnimation(MAX_NNZUJU_ROOM_PLAYER, false)
                else
                    PlaySplitPokerCardsAnimation(position, mRoomData.NNPlayerList[position].CanPlaySplitPkoerAnimation)
                    mRoomData.NNPlayerList[position].CanPlaySplitPkoerAnimation = false
                end
            else
                print('搓牌结束阶段 玩家是否搓牌 状态有误')
            end
        end
    end

end

-------------------------------------------------------------------------------
--------------------------- 进入【结算阶段】[SETTLEMENT] [20]------------------
-- 本局输家+赢家 数量计数
local mLoserCount = 0
local mWinnerCount = 0
local mNeedDelayTime = 0
-- 赢家筹码显示延迟时间
local mWinnerAnimationDelayTime = 0

function RefreshResultPartOfGameRoomByState(roomStateParam, initParam)

    if roomStateParam == ROOM_STATE_NN.SETTLEMENT then
        ShowGameResult(true)
        lua_Transform_ClearChildren(mChipRoot, false)
        ResetPlayerWinGold()
        --RefreshPlayerGoldValue()
        -- 自己的4，5张牌复原检测
        ResetSelf45PkoerCard()
        ResetSettleDelayTime()
        --print('延迟时间:' .. mNeedDelayTime .. '结算进入状态:' .. lua_BOLEAN_String(initParam))
        if initParam == true then
            RefreshEveryOnePokerType(true)
            if mRoomData.CountDown > mNeedDelayTime then
                PlayWinGoldChipAnimation(true)
                this:DelayInvoke(mNeedDelayTime, function() PlayWinGoldValueAnimation() end)
            else
                PlayWinGoldChipAnimation(false)
                this:DelayInvoke(0.5, function() PlayWinGoldValueAnimation() end)
            end
        else
            PlayWinGoldChipAnimation(true)
            this:DelayInvoke(mNeedDelayTime, function() PlayWinGoldValueAnimation() end)
        end
    else
        ShowGameResult(false)
        for index = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            ShowWinGoldEffect(index, false)
        end
        RefreshGameOverTipsShowState(false)
    end
end

-- 设置结算显示
function ShowGameResult(show)
    if mGameResult.activeSelf == show then
        return
    end
    mGameResult:SetActive(show)
end

-- 复原自己的4 5 张扑克
function ResetSelf45PkoerCard()
    -- 自己的4，5张牌复原检测
    local tUINode = mPLAYERS_SLOT[MAX_NNZUJU_ROOM_PLAYER]
    if mMasterData.IsValid == PlayerStateEnumNN.JoinOK then
        tUINode.Cards[4].gameObject:SetActive(true)
        tUINode.Cards[5].gameObject:SetActive(true)
        local pokerCards = mMasterData.Pokers
        local pokerType = GetNNPokerCardTypeByPokerCards(pokerCards[1], pokerCards[2], pokerCards[3], pokerCards[4], pokerCards[5])
        if pokerType == 0 then
            lua_Paste_Transform_Value(tUINode.Cards[4], tUINode.Points[4])
            lua_Paste_Transform_Value(tUINode.Cards[5], tUINode.Points[5])
        else
            lua_Paste_Transform_Value(tUINode.Cards[4], tUINode.Points[9])
            lua_Paste_Transform_Value(tUINode.Cards[5], tUINode.Points[10])
        end
    end
end

-- 重置玩家输赢金币值
function ResetPlayerWinGold()
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        mPLAYERS_SLOT[position].WinText.text = ''
        mPLAYERS_SLOT[position].LoseText.text = ''
    end
end

-- 刷新玩家金币
function RefreshPlayerGoldValue()
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        local showObj = mPLAYERS_SLOT[position]
        local showData = mRoomData.NNPlayerList[position]
        if showData.IsValid == PlayerStateEnumNN.JoinOK then
            showObj.GoldText.text = tostring(lua_GetPreciseDecimal(showData.Gold,2))
        else
            showObj.GoldText.text = ""
        end
    end
end

-- 重置结算延迟时间
function ResetSettleDelayTime()
    mLoserCount = 0
    mWinnerCount = 0
    mNeedDelayTime = 0

    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK and position ~= mRoomData.BankerID then
            if mRoomData.NNPlayerList[position].WinGold < 0 then
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
function PlayWinGoldChipAnimation(isAni)

    ShowPlayerToBankerAnimation(isAni)
    if mLoserCount > 0 then
        -- 有输家 先飞筹码到庄家
        this:DelayInvoke(2.0, function() ShowBankerToPlayerAnimation(isAni) end)
    else
        ShowBankerToPlayerAnimation(isAni)
    end

end

-- 筹码从玩家飞入到庄家
function ShowPlayerToBankerAnimation(isAni)

    if isAni then
        for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK and mRoomData.NNPlayerList[position].WinGold < 0 then
                if position ~= mRoomData.BankerID then
                    PlayGoldFlyAnimation(position, mRoomData.BankerID, position)
                end
            end
        end
    end

end

-- 筹码从庄家飞入到玩家
function ShowBankerToPlayerAnimation(isAni)

    if isAni then
        for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK and mRoomData.NNPlayerList[position].WinGold > 0 then
                if position ~= mRoomData.BankerID then
                    PlayGoldFlyAnimation(mRoomData.BankerID, position, position)
                end
            end
        end
    end

end

-- 播放筹码飞入动画(参数1:开始点 参数2:结束点,参数3:筹码来源点)
function PlayGoldFlyAnimation(positionForm, positionTo, positionSource)

    --print(string.format('筹码飞入[%d]==>[%d] 来源:[%d]', positionForm, positionTo, positionSource))
    -- 牌型倍率
    local pokerCards = mRoomData.NNPlayerList[positionTo].Pokers
    local pokerType, sortedPokerCards, maxPokerCard = GetNNPokerCardTypeByPokerCards(pokerCards[1], pokerCards[2], pokerCards[3], pokerCards[4], pokerCards[5])
    local NN_ZUJU_COMPENSATE = data.PublicConfig.NN_ZUJU_COMPENSATE
    local tCompensate = NN_ZUJU_COMPENSATE[pokerType]

    for i = 1, tCompensate, 1 do
        -- 丢入筹码
        local newChip = CS.UnityEngine.Object.Instantiate(ChipItemTransform[tCompensate])
        CS.Utility.ReSetTransform(newChip, mChipRoot)
        newChip.gameObject.name = 'Chips_' .. i
        newChip.position = CHIP_JOINTS[positionForm].JointPoint.position
        newChip.gameObject:SetActive(true)
        local script = newChip.gameObject:AddComponent(typeof(CS.TweenTransform))
        script.from = CHIP_JOINTS[positionForm].JointPoint
        script.to = CHIP_JOINTS[positionTo].JointPoint
        script.duration = 0.65
        script.delay = i * 0.1
        if script.delay > 1 then
            script.delay = 1
        end
        script:Play(true)
        script:OnFinished("+",( function()
            CS.UnityEngine.Object.Destroy(script.gameObject)
            -- 获取筹码音效
            PlaySoundEffect('7')
        end ))
    end

end

-- 玩家输赢金币显示
function PlayWinGoldValueAnimation()

    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        ShowPlayerWinGoldValue(position)
        local WinGold = mRoomData.NNPlayerList[position].WinGold
        if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK then
            ShowWinGoldEffect(position, WinGold > 0)
            if position == MAX_NNZUJU_ROOM_PLAYER then
                PlayGameResultSoundEffect()
            end
        end
    end
    this:DelayInvoke(0.5, function()
        RefreshPlayerGoldValue();
    end)
    this:DelayInvoke(1.5,
    function()
        ResetPlayerWinGold()
        RefreshGameOverTipsShowState(true)
    end )
    PlayBankerAllWinOrLostSound()
end

-- 游戏结算音效
function PlayGameResultSoundEffect()
    if mMasterData.IsValid == PlayerStateEnumNN.JoinOK then
        -- 玩家输赢音效
        if mMasterData.WinGold > 0 then
            PlaySoundEffect('NN_win')
        else
            PlaySoundEffect('NN_lost')
        end
    end

end

-- 显示玩家金币结算
function ShowPlayerWinGoldValue(positionParam)

    local WinGold = mRoomData.NNPlayerList[positionParam].WinGold
    if mRoomData.NNPlayerList[positionParam].IsValid == PlayerStateEnumNN.JoinOK then
        if WinGold > 0 then
            mPLAYERS_SLOT[positionParam].WinText.text = '+' .. lua_CommaSeperate(WinGold)
            local tweenposition = mPLAYERS_SLOT[positionParam].WinText.transform:GetComponent('TweenPosition')
            tweenposition:ResetToBeginning()
            tweenposition:Play(true)
            local tweenalpha = mPLAYERS_SLOT[positionParam].WinText.transform:GetComponent('TweenAlpha')
            tweenalpha:ResetToBeginning()
            tweenalpha:Play(true)
        elseif WinGold < 0 then
            mPLAYERS_SLOT[positionParam].LoseText.text = lua_CommaSeperate(WinGold)
            local tweenposition = mPLAYERS_SLOT[positionParam].LoseText.transform:GetComponent('TweenPosition')
            tweenposition:ResetToBeginning()
            tweenposition:Play(true)
            local tweenalpha = mPLAYERS_SLOT[positionParam].LoseText.transform:GetComponent('TweenAlpha')
            tweenalpha:ResetToBeginning()
            tweenalpha:Play(true)
        end
    end

end

-- 显示赢钱特效
function ShowWinGoldEffect(positionParam, showParam)

    -- 定庄特效
    mPLAYERS_SLOT[positionParam].WinTips1.gameObject:SetActive(showParam)
    mPLAYERS_SLOT[positionParam].WinTips2.gameObject:SetActive(showParam)
    if true == showParam then
        local spriteAnimation1 = mPLAYERS_SLOT[positionParam].WinTips1:GetComponent('UGUISpriteAnimation')
        spriteAnimation1:RePlay()
        -- 延迟隐藏
        this:DelayInvoke(1.5,
        function()
            mPLAYERS_SLOT[positionParam].WinTips1.gameObject:SetActive(false)
        end )
        local spriteAnimation2 = mPLAYERS_SLOT[positionParam].WinTips2:GetComponent('UGUISpriteAnimation')
        spriteAnimation2:RePlay()
        -- 延迟隐藏
        this:DelayInvoke(1.5,
        function()
            mPLAYERS_SLOT[positionParam].WinTips2.gameObject:SetActive(false)
        end )
    end

end

-- 庄家通杀-通陪音效
function PlayBankerAllWinOrLostSound()

    if mRoomData.RoomType == ROOM_TYPE.TONGBI then
        -- 通比模式不播
        return
    end
    -- 参与游戏玩家数量
    local joingameNumber = 0
    -- 赢钱玩家数量
    local winGoldNumber = 0
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if mRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK then
            joingameNumber = joingameNumber + 1
            if position ~= mRoomData.BankerID then
                if mRoomData.NNPlayerList[position].WinGold > 0 then
                    winGoldNumber = winGoldNumber + 1
                end
            end
        end
    end
    --print('结算时赢家:' .. winGoldNumber .. '参与游戏人数:' .. joingameNumber)
    if joingameNumber <= 2 then
        return
    end

    if winGoldNumber == 0 then
        -- 庄家通杀
        PlaySoundEffect('NN_all_win')
    elseif winGoldNumber == joingameNumber - 1 then
        -- 庄家通赔
        PlaySoundEffect('NN_all_lost')
    end

end

-- 刷新游戏结束等待tips显示
function RefreshGameOverTipsShowState(showParam)
    isUpdateGameOverWaitCountDown = showParam
    if mGameOverWaitTips.activeSelf == showParam then
        return
    end
    mGameOverWaitTips:SetActive(showParam)

end

local mGameOverCD = 0
-- 刷新游戏结束等待CD
function RefreshGameOverTipsCountDown()

    if isUpdateGameOverWaitCountDown == true then
        if nil == mGameOverWaitTipsText then
            return
        end
        local tCountDown = math.ceil(mRoomData.CountDown) 
        if tCountDown < 0 then
            tCountDown = 0
        end
        if mGameOverCD ~= tCountDown then
            mGameOverCD = tCountDown
            mGameOverWaitTipsText.text = string.format(data.GetString('NN_Game_Over_Tips'), lua_FormatToCountdownStyle(mGameOverCD))
        end
    end

end


-------------------------------退出菜单模块------------------------
-- 菜单选择按钮call
function ButtonCaiDan_OnClick()

    if mReturnCaiDan.activeSelf then
        ReturnCaiDanShow(false)
        this.transform:Find('Canvas/Buttons/ButtonCaiDan1').gameObject:SetActive(true)
        this.transform:Find('Canvas/Buttons/ButtonCaiDan2').gameObject:SetActive(false)
    else
        this.transform:Find('Canvas/Buttons/ButtonCaiDan1').gameObject:SetActive(false)
        this.transform:Find('Canvas/Buttons/ButtonCaiDan2').gameObject:SetActive(true)
        ReturnCaiDanShow(true)
        this.transform:Find('Canvas/ReturnCaiDan/ButtonExit'):GetComponent("Button").interactable = CheckCanQuitGame()
    end
end

--==============================--
--desc:玩家能够离开房间
--time:2018-01-11 11:37:54
--@return 
--==============================--
function CheckCanQuitGame()
    local tQuit =  true
    if mMasterData.PlayerState < PlayerStateEnumNN.JoinOK then
        tQuit = true
    else
        tQuit = false
    end
    return tQuit
end


-- 菜单选择隐藏call
function ReturnCaiDan_OnClick()
    ButtonCaiDan_OnClick()
    --ReturnCaiDanShow(false)
end

function ReturnCaiDanHide_OnClick()
    -- body
    ButtonCaiDan_OnClick()
    --ReturnCaiDanShow(false)
end

-- 推出房间按钮call
function ButtonExit_OnClick()
    local tQuit = CheckCanQuitGame()
    if tQuit == true  then
        NetMsgHandler.Send_CS_NN_Leave_Room(mRoomData.RoomID)
    end
    ReturnCaiDanShow(false)
end

function ButtonChange_OnClick()
    ReturnCaiDanShow(false)
end

-- 解散房间按钮call
function ButtonGameRule_OnClick()
    ButtonCaiDan_OnClick()
    --ReturnCaiDanShow(false)
    ShowGameRule(true)

end

function HideGameRule_OnClick()
    ShowGameRule(false)
end

-- 菜单栏显示接口
function ReturnCaiDanShow(isShow)
    mReturnCaiDan:SetActive(isShow)
end

function ShowGameRule(showParam)

    if mGameRule.activeSelf == showParam then
        return
    end
    mGameRule:SetActive(showParam)

end

-------------------------------玩家自己操作模块--------------

-- 开始游戏按钮call(房主可见)
function ButtonBegin_OnClick()
    --NetMsgHandler.Send_CS_NN_Ready()
end

-- 邀请按钮call
function ButtonInvite_OnClick()
    local tRoomID = mRoomData.RoomID
    local tRoomType = mRoomData.RoomType
    local tBet = mRoomData.MinBet
    local tEnterLimit = mRoomData.MinBet * 200
    local tBet = lua_NumberToStyle1String(tBet)
    local tEnterLimit = lua_NumberToStyle1String(tEnterLimit)
    GameData.OpenIniteUI(tRoomID, tRoomType, tBet, tEnterLimit)
end

-- 准备按钮
function ZBButton_OnClick()
    -- body
    NetMsgHandler.Send_CS_NN_Ready()
end

-- 玩家抢庄按钮call
function QiangZhuangOK_OnClick()
    NetMsgHandler.Send_CS_ZJRoom_QiangZhuang(PlayerStateEnumNN.QiangZhuangOK)
end

-- 玩家不抢庄按钮call
function QiangZhuangNO_OnClick()
    NetMsgHandler.Send_CS_ZJRoom_QiangZhuang(PlayerStateEnumNN.QiangZhuangNO)
end

-- 玩家N倍下注call
function BetXXX_OnClick(times)

    local tJiaBei = mNN_ZUJU_JIABEI[times]
    if tJiaBei == nil then
        tJiaBei = 2
    end
    NetMsgHandler.Send_CS_ZJRoom_XuanDouble(tJiaBei)

    ShowBetXXX(false)
end

-- 直接翻牌call
function OpenCardButton_OnClick()

    NetMsgHandler.Send_CS_ZJRoom_CuoPai()
    mMasterData.CanPlaySplitPkoerAnimation = false
    HandleOpenPokerCardAnimationStepOne()
    ShowOpenPokerButton(false)

end

-- 设置直开牌按钮显示
function ShowOpenPokerButton(show)
    mButtonOpen.gameObject:SetActive(show)
end


-- 新增一个玩家
function OnNotifyZJRoomAddPlayer(positionParam)
    SetPlayerSitdownState(positionParam)
    SetPlayerBaseInfo(positionParam)
    RefreshPlayerWaitTipsAndGoldText(positionParam, mRoomData.RoomState <= ROOM_STATE_NN.DEAL)
    -- 进入音效
    PlaySoundEffect('NN_enter')
    if mRoomData.RoomState == ROOM_STATE_NN.START then
        if mRoomData.MasterID == GameData.RoleInfo.AccountID then
            -- 此刻自己是房主
            local tweenScale = this.transform:Find('Canvas/Buttons/ButtonBegin'):GetComponent("TweenScale")
            tweenScale:ResetToBeginning()
            tweenScale:Play(true)
            this:DelayInvoke(0.4,
            function()
                local tweenScale = this.transform:Find('Canvas/Buttons/ButtonBegin'):GetComponent("TweenScale")
                tweenScale:ResetToBeginning()
                tweenScale.enabled = false
            end )
        end
    end

    UpdateButtonInvite1ShowState()
end

-- 删除玩家
function OnNotifyZJRoomDeletePlayer(positionParam)
    SetPlayerSitdownState(positionParam)
    SetPlayerBaseInfo(positionParam)
    RefreshPlayerWaitTipsAndGoldText(positionParam, true)

    if mPLAYERS_SLOT[positionParam].CardRoot.gameObject.activeSelf == true then
        mPLAYERS_SLOT[positionParam].CardRoot.gameObject:SetActive(false)
    end

    UpdateButtonInvite1ShowState()
end


-- 玩家搓牌成功
function OnNotifyZJRoomPlayerCuoPai(positionParam)
    for index = 1, 5, 1 do
        local cardTransform = mPLAYERS_SLOT[positionParam].Cards[index]
        local cardData = mRoomData.NNPlayerList[positionParam].Pokers[index]
        SetTablePokerCardVisible(cardTransform, cardData.Visible)
    end

    if positionParam ~= MAX_NNZUJU_ROOM_PLAYER then
        -- 自己抽牛流程 走开拍流程 或者 结算自动
        SetPlayerPokerType(positionParam)
    else
        ShowCuoPaiWaitTips(true)
    end
end

-- 设置玩家的牌型
function SetPlayerPokerType(positionParam)

    PlaySplitPokerCardsAnimation(positionParam, mRoomData.NNPlayerList[positionParam].CanPlaySplitPkoerAnimation)
    mRoomData.NNPlayerList[positionParam].CanPlaySplitPkoerAnimation = false

end

-- 分牌动画
function PlaySplitPokerCardsAnimation(positionParam, isAni)
    if isStartEnterCheckAnimation == true and positionParam == MAX_NNZUJU_ROOM_PLAYER then
        HandleOpenPokerCardAnimationStepOne()
        return
    end
    if isOpenPokerCardAnimation == true and positionParam == MAX_NNZUJU_ROOM_PLAYER then
        -- 正在翻自己的牌回去
        return
    end

    local pokerCards = mRoomData.NNPlayerList[positionParam].Pokers
    local pokerType, sortedPokerCards, maxPokerCard = GetNNPokerCardTypeByPokerCards(pokerCards[1], pokerCards[2], pokerCards[3], pokerCards[4], pokerCards[5])

    -- 有牛的情况，需要等到分牌后再出现牌型
    if pokerType == BRAND_TYPE.NONIU then
        SetPokerType(positionParam, pokerType)
    else
        if isAni then
            this:DelayInvoke(0.2, function() SplitPokerCardsAnimationStepOne(positionParam, sortedPokerCards, true) end)
            this:DelayInvoke(0.4, function() SplitPokerCardsAnimationStepTwo(positionParam, true) end)
            this:DelayInvoke(0.8, function()
                SetPokerType(positionParam, pokerType)
            end )
        else
            SplitPokerCardsAnimationStepOne(positionParam, sortedPokerCards, false)
            SplitPokerCardsAnimationStepTwo(positionParam, false)
            SetPokerType(positionParam, pokerType)
        end
    end

end

-- 处理玩家没牛的情况
function SplitPokerCardsOfNoNiu(positionParam, pokerType, sortedPokerCards, maxPokerCard)
    SetPokerType(positionParam, pokerType)
    for index = 1, 5, 1 do
        if sortedPokerCards[index] == maxPokerCard then
            local cardItem = mPLAYERS_SLOT[positionParam].Cards[index]
            local localPosition = cardItem.localPosition
            cardItem.localPosition = CS.UnityEngine.Vector3(localPosition.x, localPosition.y + 20, localPosition.z)
        end
    end
end

-- 扯牛动画步骤:1
function SplitPokerCardsAnimationStepOne(positionParam, sortedPokerCards, isAni)

    for index = 1, 5, 1 do
        local cardItem = mPLAYERS_SLOT[positionParam].Cards[index]
        lua_Clear_AllUITweener(cardItem)
        -- print(string.format('====玩家[%d] 扑克牌数据[%d]:点数[%d] 花色[%d]', positionParam, index, sortedPokerCards[index].PokerNumber, sortedPokerCards[index].PokerType))
        if isAni then
            local script = cardItem.gameObject:AddComponent(typeof(CS.TweenTransform))
            script.to = mPLAYERS_SLOT[positionParam].Points[3]
            script.duration = 0.1
            script:OnFinished("+",( function()
                CS.UnityEngine.Object.Destroy(script)
                cardItem:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(sortedPokerCards[index]))
            end ))
            script:Play(true)
        else
            cardItem:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(sortedPokerCards[index]))
        end
    end

end

-- 扯牛动画步骤:2
function SplitPokerCardsAnimationStepTwo(positionParam, isAni)

    for index = 1, 5, 1 do
        local cardItem = mPLAYERS_SLOT[positionParam].Cards[index]
        lua_Clear_AllUITweener(cardItem)
        if isAni then
            local script = cardItem.gameObject:AddComponent(typeof(CS.TweenTransform))
            script.to = mPLAYERS_SLOT[positionParam].Points[index + 5]
            script.duration = 0.2
            script:OnFinished("+",( function()
                CS.UnityEngine.Object.Destroy(script)
            end ))
            script:Play(true)
        else
            -- 直接复位
            lua_Paste_Transform_Value(cardItem, mPLAYERS_SLOT[positionParam].Points[index + 5])
        end
    end

end

-- 设置扑克牌的牌型
function SetPokerType(positionParam, pokerType)
    mPLAYERS_SLOT[positionParam].PokerType:ResetSpriteByName("sprite_Niu_" .. pokerType)
    if mPLAYERS_SLOT[positionParam].PokerTypeBack.gameObject.activeSelf == false then
        mPLAYERS_SLOT[positionParam].PokerTypeBack.gameObject:SetActive(true)
        local tCompensate = data.PublicConfig.NN_ZUJU_COMPENSATE[pokerType]
        mPLAYERS_SLOT[positionParam].PokerTypeXText.text = tostring(tCompensate)
        local tweenScale = mPLAYERS_SLOT[positionParam].PokerTypeBack:GetComponent('TweenScale')
        tweenScale:ResetToBeginning()
        tweenScale:Play(true)

        -- 延迟隐藏
        this:DelayInvoke(0.4,
        function()
            local IsMan = false
            for k=1,#data.PublicConfig.HeadIconMan,1 do
                if mRoomData.NNPlayerList[positionParam].HeadIcon == data.PublicConfig.HeadIconMan[k] then
                    IsMan = true
                    break
                end
            end
            local mName = "NN_paixing_man_"..pokerType
            if IsMan == false then
                mName = "NN_paixing_woman_"..pokerType
            end
            -- 音效牌型播报
            PlaySoundEffect(mName)
            mPLAYERS_SLOT[positionParam].PokerTypeBack:GetComponent('TweenScale').enabled = false
        end )
    end

end

-- 音效播放接口
function PlaySoundEffect(musicid)
    if true == canPlaySoundEffect then
        MusicMgr:PlaySoundEffect(musicid)
    end
end

-- 进入房间失败
function OnNotifyEnterRoonErrorResult(resultType)
    -- 以下几种原因自动返回大厅
    -- 2: 房间不存在
    -- 3: 房间已满
    -- 8: 房间维护中
    -- 9: 金币不足
    -- 10: 已在其他房间进行游戏
    if resultType == 2 or resultType == 3 or resultType == 8 or resultType == 9 or resultType == 10 then
        HandleRefreshHallUIShowState(true)
        CS.WindowManager.Instance:CloseWindow('UIGame1', false)
    else
        -- TODO
    end

end

-- 玩家自己的金币变化
function OnNotifyPlayerGoldUpdateEvent()
    local tUINode = mPLAYERS_SLOT[MAX_NNZUJU_ROOM_PLAYER]
    if mMasterData.IsValid >= PlayerStateEnumNN.JoinNO then
        mMasterData.Gold = GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount)
        --TUDOU
        if currentRoomState ~= ROOM_STATE_NN.SETTLEMENT then
            --tUINode.GoldText.text = lua_NumberToStyle1String(mMasterData.Gold)
        end
    end
end

-- 商城按钮
function StoreButtonOnClick()
    GameConfig.OpenStoreUI()
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.NnRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.NnRankTime >= 60 then
        return true
    end
    return false
end


-- 响应排行榜按钮点击事件
function RankButtonOnClick()
    ButtonCaiDan_OnClick()
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = GAME_RANK_TYPE.NN_MONEY
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(GAME_RANK_TYPE.NN_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.NN_MONEY)
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
    mRoomData = GameData.RoomInfo.CurrentRoom
    mMasterData = mRoomData.NNPlayerList[MAX_NNZUJU_ROOM_PLAYER]
    InitGameRoomPlayersRelative()
    InitGameRoomOtherRelative()
    AddButtonHandlers()
    InitRoomChange()
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
end

function Start()
    CS.MatchLoadingUI.Hide()
    if GameConfig.IsSpecial() then
        if CS.AppDefine.GameID == 3 then
            CS.Utility.AutorotateToPortrait()
        end
    end
end

function WindowOpened()

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, ResetGameRoomToRoomState)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZJRoomAddPlayer, OnNotifyZJRoomAddPlayer)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZJRoomDeletePlayer, OnNotifyZJRoomDeletePlayer)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoomState, RefreshGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZJRoomPlayerQiangZhuang, OnNotifyZJRoomPlayerQiangZhuang)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZJRoomPlayerDouble, OnNotifyZJRoomPlayerDouble)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZJRoomPlayerCuoPai, OnNotifyZJRoomPlayerCuoPai)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyEnterRoonErrorResult, OnNotifyEnterRoonErrorResult)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent, OnNotifyPlayerGoldUpdateEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyNNZJPlayerReadyEvent, OnNotifyNNZJPlayerReadyEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyRoomChangeEvent, OnNotifyRoomChangeEvent)

    MusicMgr:PlayBackMusic("BG_qznn")
    if mRoomData.RoomID ~= 0 then
        ResetGameRoomToRoomState(mRoomData.RoomState)
    end

end

function WindowClosed()

    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, ResetGameRoomToRoomState)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZJRoomAddPlayer, OnNotifyZJRoomAddPlayer)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZJRoomDeletePlayer, OnNotifyZJRoomDeletePlayer)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoomState, RefreshGameRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZJRoomPlayerQiangZhuang, OnNotifyZJRoomPlayerQiangZhuang)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZJRoomPlayerDouble, OnNotifyZJRoomPlayerDouble)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZJRoomPlayerCuoPai, OnNotifyZJRoomPlayerCuoPai)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyEnterRoonErrorResult, OnNotifyEnterRoonErrorResult)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, OnNotifyPlayerGoldUpdateEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyNNZJPlayerReadyEvent, OnNotifyNNZJPlayerReadyEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyRoomChangeEvent, OnNotifyRoomChangeEvent)
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
end

function Update()
    NNGameMgr:UpdateRoomCountDown(Time.deltaTime)
    UpdateQiangZhuangDown()
    UpdateDoubleCountDown()
    UpdateOpenPokerCardCountDown()
    UpdateCuoPokerCountDown()
    RefreshGameOverTipsCountDown()
end

function OnDestroy()
    lua_Call_GC()
end
