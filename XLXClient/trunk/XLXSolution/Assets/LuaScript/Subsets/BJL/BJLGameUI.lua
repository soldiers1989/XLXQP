local Time = CS.UnityEngine.Time
local TransformRoot = nil

local BetCountDownKey = "BetCountdown"
local isUpdateBetCountDown = false
local m_BetLimitTime = 3                -- 下注倒计时限制时间(用于提示玩家停止下注+本局未下注)
local m_ShowCountDown = 0               -- 下注倒计时显示值

-- 离开房间倒计时
local exitRoomCountDown = 99
local isUpdateExitRoomCountDown = false
local canPlayCountDownAudio = false         	-- 能否开始播放倒计时
local nowPlayingCountDownAudio = true    		-- 是否处于播放中ing
local canPlaySoundEffect = false 				-- 能开始播放音效(进入房间时有很多东西需要筹备 筹备完毕才能开始播放)
local PokerTypeClickTime = 0					-- 扑克花色点击时刻
local PokerTypeClickCDTime = 0.5				-- 扑克花色点击CD


local m_CanExitRoom = true						-- 能否离开房间

local SystemBankerID = 100000                   -- 系统坐庄ID限制

local m_CheckColorOf1 = CS.UnityEngine.Color(41 / 255, 243 / 255, 0)
local m_CheckColorOf2 = CS.UnityEngine.Color(230 / 255, 251 / 255, 34 / 255)
local m_CheckColorOf3 = CS.UnityEngine.Color(227 / 255, 50 / 255, 8 / 255)

-- 发牌每张牌的间隔时间为0.2s
local DEAL_CONFIG =
{
    [1] = { DealCard = 1, MoveTime = 0.8, DealStartTime = 0.5, RotateTime = 0.4 },
    [2] = { DealCard = 4, MoveTime = 0.5, DealStartTime = 1.9, RotateTime = 0.4 },
    [3] = { DealCard = 2, MoveTime = 0.7, DealStartTime = 2.8, RotateTime = 0 },
    [4] = { DealCard = 5, MoveTime = 0.4, DealStartTime = 3.4, RotateTime = 0 },
    [5] = { DealCard = 3, MoveTime = 0.6, DealStartTime = 4.2, RotateTime = 0 },
    [6] = { DealCard = 6, MoveTime = 0.3, DealStartTime = 5.0, RotateTime = 0 },
}

-- 扑克牌的挂节点
local POKER_JOINTS = { }
-- 扑克牌
local POKER_CARDS = { }
-- 扑克牌根节点
local m_PokerCardsRoot = nil
local m_PokerCardsRoot1 = nil
local m_PokerCardsRoot2 = nil

-- 筹码挂节点
local CHIP_JOINTS =
{
    [1] = { JointPoint = nil, RangeX = { Min = - 130, Max = 130 }, RangeY = { Min = - 70, Max = 70 } },
    [2] = { JointPoint = nil, RangeX = { Min = - 140, Max = 140 }, RangeY = { Min = - 70, Max = 70 } },
    [3] = { JointPoint = nil, RangeX = { Min = - 130, Max = 130 }, RangeY = { Min = - 70, Max = 70 } },
    [4] = { JointPoint = nil, RangeX = { Min = - 200, Max = 200 }, RangeY = { Min = - 120, Max = 100 } },
    [5] = { JointPoint = nil, RangeX = { Min = - 200, Max = 200 }, RangeY = { Min = - 120, Max = 100 } },
    [11] = { JointPoint = nil },
    [12] = { JointPoint = nil },
    [13] = { JointPoint = nil },
}

-- 筹码模型
local CHIP_MODEL = { }

local mRoleCountText = nil      -- 房间在线人数
-- 玩家信息
local RoleNameText = nil
local RoleGoldText = nil
local RoleChangeGold = nil
-- 房间ID
local RoomIDText = nil

-- 洗牌动画
local ShuffleAniGameObject = nil
local ShuffleAni2GameObject = nil
-- 下注倒计时组件
local BetCountDownGameObject = nil
local BetCountDownText = nil
-- 结算相关信息
local SettlementNode =
{
    RootNode = nil,             -- 结算根节点
    Cards = {},                 -- 结算扑克牌
    SealImage = nil,            -- 结果印章
}

-- 扑克点数相关
local mPokerXNOGameObject = nil
local mPokerXNOGameObject2 = nil
local mPokerXNOText1 = nil
local mPokerXNOText2 = nil
local mPokerZNOGameObject = nil
local mPokerZNOGameObject2 = nil
local mPokerZNOText1 = nil
local mPokerZNOText2 = nil
local mRemainText = nil                         -- 剩余牌数

-- 切牌动画节点信息
local CutAniNode = 
{
    RootGameObject = nil,
    StartPoint = nil,
    MiddlePoint = nil,
    EndPoint = nil,
    CutCards = {},
    CutPoints = {},
}

---------_________TUDOU_________--------->>

local window_Help = nil;
local button_Help = nil;
local button_Help_Close = nil;
local toggle_Help_Rule = nil;
local toggle_Help_Explain = nil;
local mask_Help = nil;

function DoHelp()
    window_Help = this.transform:Find("Canvas/Window_Help");
    button_Help = this.transform:Find("Canvas/HelpButton");
    button_Help_Close = this.transform:Find("Canvas/Window_Help/Title/Button_Close");
    toggle_Help_Rule = this.transform:Find("Canvas/Window_Help/ToggleGroupBJL/GameRuleToggle");
    toggle_Help_Explain = this.transform:Find("Canvas/Window_Help/ToggleGroupBJL/GameExplainToggle");
    mask_Help = this.transform:Find("Canvas/Mask_Help");
    button_Help:GetComponent("Button").onClick:AddListener(Window_Help_Open);
    button_Help_Close:GetComponent("Button").onClick:AddListener(Window_Help_Close);
    toggle_Help_Rule:GetComponent("Toggle").onValueChanged:AddListener(function(value) Window_Help_Rule(value) end);
    toggle_Help_Explain:GetComponent("Toggle").onValueChanged:AddListener(function(value) Window_Help_Explain(value) end);
    mask_Help:GetComponent("Button").onClick:AddListener(Window_Help_Close);

end

--打开帮助界面
function Window_Help_Open()
    toggle_Help_Rule:GetComponent("Toggle").isOn = true;
    toggle_Help_Explain:GetComponent("Toggle").isOn = false;
    for k = 1, 3 do
        window_Help:Find("Content/Viewport/Content/Item"..k).gameObject:SetActive(true);
    end
    window_Help:Find("Content/Viewport/Content/Item4").gameObject:SetActive(false);
    window_Help.gameObject:SetActive(true);
    mask_Help.gameObject:SetActive(true);
    
end

--关闭帮助界面
function Window_Help_Close()
    for k = 1, 4 do
        window_Help:Find("Content/Viewport/Content/Item"..k).gameObject:SetActive(false);
    end
    window_Help.gameObject:SetActive(false);
    mask_Help.gameObject:SetActive(false);
end

--打开帮助界面里的【游戏规则】分页
function Window_Help_Rule(value)
    if value then
        for k = 1, 3 do
            window_Help:Find("Content/Viewport/Content/Item"..k).gameObject:SetActive(true);
        end
        window_Help:Find("Content/Viewport/Content/Item4").gameObject:SetActive(false);
    end
    
end

--打开帮助界面里的【路单说明】分页
function Window_Help_Explain(value)
    if value then
        for k = 1, 3 do
            window_Help:Find("Content/Viewport/Content/Item"..k).gameObject:SetActive(false);
        end
        window_Help:Find("Content/Viewport/Content/Item4").gameObject:SetActive(true);
    end
    
end


---------_________TUDOU_________--------->>

-- 按钮事件响应绑定             --OK
function AddButtonHandlers()
    this.transform:Find('Canvas/RoomInfo/ButtonExitRoom'):GetComponent("Button").onClick:AddListener(ExitRoomButtonOnClick)
    this.transform:Find('Canvas/RoomInfo/RoleCount'):GetComponent("Button").onClick:AddListener(BJLRoleCountBtnOnClick)
    this.transform:Find('Canvas/HelpButton'):GetComponent("Button").onClick:AddListener(BJLButtonHelpOnClick)
    this.transform:Find('Canvas/StoreButton'):GetComponent("Button").onClick:AddListener(StoreButtonOnClick)
    this.transform:Find('Canvas/RankButton'):GetComponent("Button").onClick:AddListener(RankButtonOnClick)

    AddBetRelativeHandlers()
end

-- 押注区 筹码选择区 事件响应绑定   --OK
function AddBetRelativeHandlers()
    -- 押注区域
    for buttonIndex = 1, 5, 1 do
        this.transform:Find('Canvas/BetChipHandle/BetArea/Area' .. buttonIndex):GetComponent("Button").onClick:AddListener( function() BetAreaButtonOnClick(buttonIndex) end)
    end

    -- 筹码选择
    for index = 1, 10, 1 do
        this.transform:Find('Canvas/BetChipHandle/Chips/Viewport/Content/Chip' .. index):GetComponent("Toggle").onValueChanged:AddListener( function(isOn) ChipValueOnValueChanged(isOn, CHIP_VALUE[index]) end)
    end
end

--=============================游戏流程处理 BEGIN==============================


-- 重置游戏房间到指定的游戏状态     --OK
function ResetBJLRoomToRoomState(currentState)
    canPlaySoundEffect = false
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    InitRoomBaseInfos()
    RefreshBJLRoomRoleCount(GameData.RoomInfo.CurrentRoom.RoleCount)
    RefreshExitRoomButtonState(true)
    RefreshGameRoomToEnterGameState(currentState, true)
    canPlaySoundEffect = true
end

-- 刷新游戏房间进入到指定房间状态   --OK
function RefreshBJLRoomByRoomStateSwitchTo(roomState)
    RefreshGameRoomToEnterGameState(roomState, false)
end

-- 初始化房间基础信息：房间限注金额，桌布的颜色，房间ID信息, 
-- 房间的押注赔付比例，邀请按钮的状态，筹码挂接点               --OK
function InitRoomBaseInfos()
    InitRoomBaseInfoOfRoomInfo()
    local roomConfig = data.RoomConfig[GameData.RoomInfo.CurrentRoom.TemplateID]
    if roomConfig ~= nil then
        InitRoomBaseInfoOfLimit(roomConfig)
        InitRoomBaseInfoOfChipLocation(roomConfig)
    end
    InitRoomBaseInfoOfBetRate()
    InitRoomBaseInfoOfMineInfo()
end

-- 房间限注信息 -           -OK
function InitRoomBaseInfoOfLimit(roomConfig)
    local roomLimit = this.transform:Find('Canvas/RoomInfo/LimitInfo')
    --roomLimit:Find('Item1/Value'):GetComponent("Text").text = lua_NumberToStyle1String(roomConfig.BettingZX[1]) .. "-" .. lua_NumberToStyle1String(roomConfig.BettingZX[2])
    --roomLimit:Find('Item2/Value'):GetComponent("Text").text = lua_NumberToStyle1String(roomConfig.BettingHe[1])
    --roomLimit:Find('Item3/Value'):GetComponent("Text").text = lua_NumberToStyle1String(roomConfig.BettingHe[2]) .. "/" .. lua_NumberToStyle1String(roomConfig.BettingZXPair[2])
    roomLimit:Find('Item1/Value'):GetComponent("Text").text = lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetZXMin) .. "-" .. lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetZXMax)
    roomLimit:Find('Item2/Value'):GetComponent("Text").text = lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetHeMin)
    roomLimit:Find('Item3/Value'):GetComponent("Text").text = lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetHeMax) .. "/" .. lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetZXDMax)
end

-- 设置房间筹码定位点       --OK
function InitRoomBaseInfoOfChipLocation(roomConfig)
    this.transform:Find('Canvas/BetChipHandle/Chips'):GetComponent("ScrollRectExtend"):CenterOnChild(roomConfig.CenterOnChild - 1, false)
end

-- 房间信息(房间ID)         --OK
function InitRoomBaseInfoOfRoomInfo()
    RoomIDText.text = tostring(GameData.RoomInfo.CurrentRoom.RoomID)
end

-- 设置赔付比例             --OK
function InitRoomBaseInfoOfBetRate()
    local betAreaRoot = this.transform:Find('Canvas/BetChipHandle/BetArea')
    for index = 1, 5, 1 do
        betAreaRoot:Find('Area' .. index .. '/Rate'):GetComponent("Text").text = "1:" .. BJL_COMPENSATE[index]
    end
end

-- 初始化游戏房间的扑克牌相关   --OK
function InitGameRoomPokerCardRelative()
    m_PokerCardsRoot = this.transform:Find('Canvas/DealPokers/Cards')
    POKER_CARDS[1] = m_PokerCardsRoot:Find('Card1')
    POKER_CARDS[2] = m_PokerCardsRoot:Find('Card2')
    POKER_CARDS[4] = m_PokerCardsRoot:Find('Card4')
    POKER_CARDS[5] = m_PokerCardsRoot:Find('Card5')

    m_PokerCardsRoot1 = this.transform:Find('Canvas/DealPokers/Cards1')
    POKER_CARDS[3] = m_PokerCardsRoot1:Find('Card3')
    
    m_PokerCardsRoot2 = this.transform:Find('Canvas/DealPokers/Cards2')
    POKER_CARDS[6] = m_PokerCardsRoot2:Find('Card6')
    
    -- 初始化发牌收牌节点(开始节点，中间节点，结束节点,发牌节点)
    local dealPokerJoints = this.transform:Find('Canvas/DealPokers/Points')

    POKER_JOINTS[0] = dealPokerJoints:Find('StartPoint')
    POKER_JOINTS[98] = dealPokerJoints:Find('MiddlePoint')
    POKER_JOINTS[99] = dealPokerJoints:Find('EndPoint')
    for index = 1, 6, 1 do
        POKER_JOINTS[index] = dealPokerJoints:Find('Poker' .. index)
    end
    for i = 1, 6 do
        POKER_CARDS[i].gameObject:SetActive(false)
    end
end

-- 初始化房间的押注和筹码相关   --OK
function InitGameRoomBetAndChipRelative()
    -- 初始化筹码挂节点
    local chipsJointRoot = this.transform:Find('Canvas/BetChipHandle/ChipJoints')
    for index = 1, 5, 1 do
        local rectTrans = chipsJointRoot:Find('Joint' .. index):GetComponent("RectTransform")
        CHIP_JOINTS[index].JointPoint = rectTrans
        CHIP_JOINTS[index].RangeX.Min = math.floor(- rectTrans.sizeDelta.x * 0.5)
        CHIP_JOINTS[index].RangeX.Max = math.floor(rectTrans.sizeDelta.x * 0.5)
        CHIP_JOINTS[index].RangeY.Min = math.floor(- rectTrans.sizeDelta.y * 0.5)
        CHIP_JOINTS[index].RangeY.Max = math.floor(rectTrans.sizeDelta.y * 0.5)
    end

    local chipStartJointRoot = this.transform:Find('Canvas/BetChipHandle/StartPoint')
    CHIP_JOINTS[11].JointPoint = chipStartJointRoot:Find('MyPoint')
    CHIP_JOINTS[12].JointPoint = chipStartJointRoot:Find('OtherPoint')
    CHIP_JOINTS[13].JointPoint = chipStartJointRoot:Find('BankerPoint')

    -- 筹码模型
    local chipModeRoot = this.transform:Find('Canvas/BetChipHandle/ChipRes')
    for index = 1, 10, 1 do
        CHIP_MODEL[CHIP_VALUE[index]] = chipModeRoot:Find('chip_' .. index)
        CHIP_MODEL[CHIP_VALUE[index]]:Find('Icon').gameObject.name = tostring(CHIP_VALUE[index])
    end
end

-- 初始化切牌相关信息
function InitBJLCutAniNode()
    local tRoot = TransformRoot:Find('Canvas/CutAni')
    CutAniNode.RootGameObject = tRoot.gameObject
    CutAniNode.StartPoint = tRoot:Find('CutPoints/StartPoint')
    CutAniNode.MiddlePoint = tRoot:Find('CutPoints/MiddlePoint')
    CutAniNode.EndPoint = tRoot:Find('CutPoints/EndPoint')
    for i = 0, 10 do
        CutAniNode.CutCards[i] = tRoot:Find("CutCards/Item"..i)
    end
    for i = 1, 10 do
        CutAniNode.CutPoints[i] = tRoot:Find("CutPoints/Poker"..i)
    end
    GameObjectSetActive(CutAniNode.RootGameObject, true) 
end

-- 刷新房间内人数       --OK
function RefreshBJLRoomRoleCount(roleCount)
    mRoleCountText.text = tostring(roleCount)
end

-- 刷新房间剩余牌数量
function BJLRefreshRemainText(countParam)
    
    mRemainText.text = tostring(countParam) 
end

-- 设置角色名称         --OK
function InitRoomBaseInfoOfMineInfo()
    RoleNameText.text = GameData.RoleInfo.IPLocation
    ResetMineInfoOfGoldCount(nil, true)
end

-- 刷新我的金币数量     --OK
function RefreshBJLMineInfoOfGoldCount(arg)
    ResetMineInfoOfGoldCount(arg, false)
end

-- 刷新我的金币数量接口 --OK
function ResetMineInfoOfGoldCount(arg, isInit)

    local displayCount  = GameData.RoleInfo.DisplayGoldCount
    local ceachCount = GameData.RoleInfo.Cache.ChangedGoldCount

    -- 玩家本局赢钱处理
    RoleGoldText.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(displayCount),2))
    if ceachCount ~= 0 then
        local ceachString = lua_CommaSeperate(GameConfig.GetFormatColdNumber(ceachCount))
        if ceachCount > 0 then
            ceachString = "+" .. ceachString
            -- 大于0 才播放
            BJLPlaySoundEffect('game_win')
        end
        RoleChangeGold:GetComponent('Text').text = ceachString
        local tweenPosition = RoleChangeGold:GetComponent('TweenPosition')
        tweenPosition:ResetToBeginning()
        tweenPosition.gameObject:SetActive(true)
        tweenPosition:Play(true)
        this:DelayInvoke(tweenPosition.duration, function() tweenPosition.gameObject:SetActive(false) end)
    else
        RoleChangeGold.gameObject:SetActive(false)
    end
    -- 在押注状态且非重新进入的情况下，刷新下筹码状态
    if GameData.RoomInfo.CurrentRoom.RoomState == BJL_ROOM_STATE.BET and isInit == false then
        BJLResetChipsInteractable(false)
    end
end

---------------------------------------------------------------------------

-- 离开房间按钮             --OK
function ExitRoomButtonOnClick()
    this.transform:Find('Canvas/RoomInfo/ButtonExitRoom'):GetComponent("Button").interactable = false;
    this:DelayInvoke(1, function ()
        this.transform:Find('Canvas/RoomInfo/ButtonExitRoom'):GetComponent("Button").interactable = true;
    end)
    -- 如果是庄家不能离开房间
    if not isUpdateExitRoomCountDown then
        -- 非庄家玩家，押注了不能推出
        local isBeted = false
        for areaType = 1, 5, 1 do
            local betValue = GameData.RoomInfo.CurrentRoom.BetValues[areaType]
            if betValue ~= nil and betValue > 0 then
                isBeted = true
                break
            end
        end
        if isBeted then
            return
        end
    end
    BJLGameMgr.Send_CS_BJL_Exit_Room()
end

-- 刷新推出房间按钮状态     -OK
function RefreshExitRoomButtonState(force)
    if isUpdateExitRoomCountDown then
        -- 如果退出房间阶段
        ResetExitRoomStateValue(true, force)
    else
        -- 非庄家玩家，押注了不能推出
        local isBeted = false
        for areaType = 1, 5, 1 do
            local betValue = GameData.RoomInfo.CurrentRoom.BetValues[areaType]
            if betValue ~= nil and betValue > 0 then
                isBeted = true
                break
            end
        end
        if isBeted then
            ResetExitRoomStateValue(false, force)
        else
            ResetExitRoomStateValue(true, force)
        end
    end
end

-- 重置退出房间按钮的状态   --OK
function ResetExitRoomStateValue(canExitRoom, force)
    if canExitRoom ~= m_CanExitRoom or force then
        local exitRoomButton = this.transform:Find('Canvas/RoomInfo/ButtonExitRoom'):GetComponent("Button")
        if canExitRoom == true then
            exitRoomButton.interactable = true
            exitRoomButton.transform:Find('Flag1').gameObject:SetActive(true)
            exitRoomButton.transform:Find('Flag2').gameObject:SetActive(false)
            m_CanExitRoom = true
        else
            exitRoomButton.interactable = false
            exitRoomButton.transform:Find('Flag1').gameObject:SetActive(false)
            exitRoomButton.transform:Find('Flag2').gameObject:SetActive(true)
            m_CanExitRoom = false
        end
    end
end

-- 房间玩家列表查看响应     --OK
function BJLRoleCountBtnOnClick()
    -- body
    local initParam = CS.WindowNodeInitParam("UIRoomPlayers")
    initParam.WindowData = 3
    CS.WindowManager.Instance:OpenWindow(initParam)
end

-- 帮助按钮响应             --OK
function BJLButtonHelpOnClick()
    -- local initParam = CS.WindowNodeInitParam("UIHelp")
    -- initParam.WindowData = 1
    -- CS.WindowManager.Instance:OpenWindow(initParam)
    -- BJLRefreshShufflePartOfGameRoomByState(BJL_ROOM_STATE.SHUFFLE, false)
    -- BJLRefreshCutAniPartOfGameRoomByState(BJL_ROOM_STATE.CUTANI, false)
end

-- 商城按钮                 --OK
function StoreButtonOnClick()
    GameConfig.OpenStoreUI()
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.BjlRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.BjlRankTime >= 60 then
        return true
    end
    return false
end

-- 响应排行榜按钮点击事件   --OK
function RankButtonOnClick()
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = 11
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(11) == true then
        NetMsgHandler.SendRequestRanks(11)
    end
end

--===========================上庄列表相关功能 Start============================

-- 刷新牌桌上龙虎文字   --OK
function HideOrShowDeskWord(wordIndex, isActive)
    this.transform:Find('Canvas/Back/Text' .. wordIndex).gameObject:SetActive(isActive)
end

--===========================上庄列表相关功能 End  ============================

-- 刷新游戏房间到游戏状态       --OK
function RefreshGameRoomToEnterGameState(roomState, isInit)
    if isInit or roomState == BJL_ROOM_STATE.WAIT then
        ResetGameRoomForReStart()
        -- 调用下GC回收
        lua_Call_GC()
    end
    BJLRefreshShufflePartOfGameRoomByState(roomState, isInit)   -- 洗牌阶段 OK
    BJLRefreshCutAniPartOfGameRoomByState(roomState, isInit)       -- 切牌阶段 OK
    BJLRefreshBetAreaPartOfGameRoomByState(roomState, isInit)   -- 下注区域 OK
    BJLRefreshBetCountDownOfGameRoomByState(roomState)          -- 下注CD   OK
    BJLRefreshCheckPartOfGameRoomByState(roomState, isInit)     -- 亮牌阶段 OK
    RefreshSettlementPartOfGameRoomByState(roomState, isInit)   -- 结算阶段 OK

end

-- 重置房间信息到可以重新开局，清理掉桌面上的内容(押注区域，发牌区域，操作扑克牌区域，可能的延迟动画等) --OK
function ResetGameRoomForReStart()
    ResetBetChipsAndAreaToRestart()
    BJLResetPokerCardToRestart()
    BJLResetSettlementToRestart()
    BJLResetCutAniToRestart()
    -- 刷新牌桌上龙虎文字
    HideOrShowDeskWord(1, true)
    HideOrShowDeskWord(2, true)
    BJLRefreshRemainText(GameData.RoomInfo.CurrentRoom.CardCount)
end

-- 重置押注区域信息 --OK
function ResetBetChipsAndAreaToRestart()
    -- 清理掉筹码节点下的所有筹码
    for areaType = 1, 5, 1 do
        lua_Transform_ClearChildren(CHIP_JOINTS[areaType].JointPoint, false)
    end
    -- 关闭掉区域动画
    BJLHandleBetAreaAnimation(3)
end

-- 重置扑克牌相关信息           --OK
function BJLResetPokerCardToRestart()
    for index = 1, 6, 1 do
        local pokerCardItem = POKER_CARDS[index]
        -- 清理掉所有的UITweener(界面动画脚本)
        lua_Clear_AllUITweener(pokerCardItem)
        lua_Paste_Transform_Value(pokerCardItem, POKER_JOINTS[0])
        pokerCardItem.gameObject:SetActive(false)
        BJLSetTablePokerCardVisible(pokerCardItem, false)
    end

    GameObjectSetActive(mPokerXNOGameObject, false)
    GameObjectSetActive(mPokerXNOGameObject2, false)
    mPokerXNOText1.text = ''
    mPokerXNOText2.text = ''
    GameObjectSetActive(mPokerZNOGameObject, false)
    GameObjectSetActive(mPokerZNOGameObject2, false)
    mPokerZNOText1.text = ''
    mPokerZNOText2.text = ''
end

-- 重置结算区域相关信息     --OK
function BJLResetSettlementToRestart()
    GameObjectSetActive(SettlementNode.RootNode, false)
    for index = 1, 6, 1 do
        SettlementNode.Cards[index]:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardBackSpriteName())
        SettlementNode.Cards[index].gameObject:SetActive(false)
    end
    SettlementNode.SealImage.gameObject:SetActive(false)
end

-- 切牌动画还原
function BJLResetCutAniToRestart()
    for i = 0, 10 do
        GameObjectSetActive(CutAniNode.CutCards[i].gameObject, false)
        lua_Clear_AllUITweener(CutAniNode.CutCards[i])
    end
end

--=============================================================================
--=================[洗牌阶段] [BJL_ROOM_STATE.SHUFFLE] [2]=====================

function BJLRefreshShufflePartOfGameRoomByState(roomState, isInit)
    if roomState == BJL_ROOM_STATE.SHUFFLE then
        if not isInit then
            GameObjectSetActive(ShuffleAniGameObject, true)
            local passedTime = data.PublicConfig.BJL_ROOM_TIME[BJL_ROOM_STATE.SHUFFLE] - GameData.RoomInfo.CurrentRoom.CountDown
            CS.Common.Animation.AnimationControl.PlayAnimation("ShuffleAnimation", 0, true)
            -- 音效洗牌音效
            BJLPlaySoundEffect('10')
            this:DelayInvoke(3.0, function ()
                GameObjectSetActive(ShuffleAni2GameObject, true)
                GameObjectSetActive(ShuffleAniGameObject, false)
                local m_CutDeckControl = ShuffleAni2GameObject.transform:GetComponent("CutDeckControl")
                m_CutDeckControl.IsDirectFlyToDesk = true
                m_CutDeckControl:ResetToBeginning()
            end)
            this:DelayInvoke(3.55, function ()
                GameObjectSetActive(ShuffleAni2GameObject, false)
            end)
        else
            GameObjectSetActive(ShuffleAniGameObject, false)
            GameObjectSetActive(ShuffleAni2GameObject, false)
        end
        
    else
        GameObjectSetActive(ShuffleAniGameObject, false)
        GameObjectSetActive(ShuffleAni2GameObject, false)
    end
end

--=============================================================================
--=================[丢牌阶段]  [BJL_ROOM_STATE.CUTANI] [3]======================
-- 弃牌动画处理
function BJLRefreshCutAniPartOfGameRoomByState(roomState, isInit)
    if roomState == BJL_ROOM_STATE.CUTANI then
        -- TODO 测试
        -- GameData.RoomInfo.CurrentRoom.CutPoker = { }
        -- GameData.RoomInfo.CurrentRoom.CutPoker.PokerType = 1
        -- GameData.RoomInfo.CurrentRoom.CutPoker.PokerNumber =  math.random(5, 5)
        -- GameData.RoomInfo.CurrentRoom.CutPoker.Visible = true

        GameObjectSetActive(CutAniNode.RootGameObject, true)
        if not isInit  then
            BJLCutAnimation1()
            BJLCutAnimation2()
        else
            GameObjectSetActive(CutAniNode.RootGameObject, false)
        end
        
    else
        GameObjectSetActive(CutAniNode.RootGameObject, false)
    end
end

function BJLCutAnimation1()
    MusicMgr:PlaySoundEffect("BJL_wait")
    local tCutPoker = GameData.RoomInfo.CurrentRoom.CutPoker
    local tCutItem = CutAniNode.CutCards[0]
    local tCutImage = tCutItem:GetComponent("Image")
    tCutImage:ResetSpriteByName(GameData.GetPokerCardSpriteName(tCutPoker))
    BJLSetTablePokerCardVisible(tCutItem, false)
    GameObjectSetActive(tCutItem.gameObject, true)
    
    local script = tCutItem.gameObject:AddComponent(typeof(CS.TweenTransform))
    script.from = CutAniNode.StartPoint
    script.to = CutAniNode.MiddlePoint
    script.duration = 0.4
    script:OnFinished("+",( function() 
        CS.UnityEngine.Object.Destroy(script)
        local tCardCount = GameData.RoomInfo.CurrentRoom.CacheCardCount - 1
        GameData.RoomInfo.CurrentRoom.CacheCardCount = tCardCount
        BJLRefreshRemainText(tCardCount)
    end))
    script:Play(true)
    this:DelayInvoke(0.6,function () BJLSetTablePokerCardVisible(tCutItem, true) end)
end

function BJLCutAnimation2()
    local tCutPoker = GameData.RoomInfo.CurrentRoom.CutPoker
    local tPokerNumber = tCutPoker.PokerNumber
    if tPokerNumber > 10 then
        tPokerNumber = 10
    end
    -- 确认丢弃牌
    local tFromPos = {}
    if tPokerNumber == 1 then
        tFromPos[1] = CutAniNode.CutPoints[3]
    elseif tPokerNumber == 2 then
        tFromPos[1] = CutAniNode.CutPoints[2]
        tFromPos[2] = CutAniNode.CutPoints[3]
    elseif tPokerNumber == 3 then
        tFromPos[1] = CutAniNode.CutPoints[2]
        tFromPos[2] = CutAniNode.CutPoints[3]
        tFromPos[3] = CutAniNode.CutPoints[4]
    else
        for i = 1, tPokerNumber do
            tFromPos[i] = CutAniNode.CutPoints[i]
        end
    end
    -- 确认弃牌时间参数
    local tDelayTime = 1
    local tSpaceTime = 0.1
    local tDuration = 0.4
    if tPokerNumber <= 5 then
        tSpaceTime = 0.2
    else
        tDuration = 0.3
    end
    -- 弃牌飞向桌面
    for i = 1, tPokerNumber do
        local tFlayIteam = CutAniNode.CutCards[i]
        local tToFrom = tFromPos[i]
        this:DelayInvoke(tDelayTime, function ()
            GameObjectSetActive(tFlayIteam.gameObject, true)
            BJLPlaySoundEffect('3')
            local tScript1 = tFlayIteam.gameObject:AddComponent(typeof(CS.TweenTransform))
            tScript1.from = CutAniNode.StartPoint
            tScript1.to = tToFrom
            tScript1.duration = tDuration
            tScript1:OnFinished("+",( function() 
                local tCardCount = GameData.RoomInfo.CurrentRoom.CacheCardCount - 1
                GameData.RoomInfo.CurrentRoom.CacheCardCount = tCardCount
                BJLRefreshRemainText(tCardCount)
                CS.UnityEngine.Object.Destroy(tScript1) 
            end))
            tScript1:Play(true)
        end)
        tDelayTime = tDelayTime + tSpaceTime
    end

    tDelayTime = tDelayTime + tDuration
    local movePokerTable = {}
    table.insert(movePokerTable, CutAniNode.CutCards[0])
    -- 弃牌飞向收纳盒1
    for i = 1, tPokerNumber do
        local tFlayIteam2 = CutAniNode.CutCards[i]
        table.insert(movePokerTable, tFlayIteam2)
    end
    this:DelayInvoke(tDelayTime, function () BJLCutCollectPokerCardsAnimationStepOne(movePokerTable) end)
end

-- 收牌动画第一段
function BJLCutCollectPokerCardsAnimationStepOne(movePokerTable)
    for index = 1, #movePokerTable, 1 do
        local pokerCard = movePokerTable[index]
        if pokerCard ~= nil then
            local script = pokerCard.gameObject:AddComponent(typeof(CS.TweenTransform))
            script.to = POKER_JOINTS[98]
            script.duration = 0.3
            script:OnFinished("+",
            function()
                if script ~= nil then
                    CS.UnityEngine.Object.Destroy(script)
                    BJLCutCollectPokerCardsAnimationStepTwo(pokerCard)
                end
            end )
            script:Play(true)
        end
    end
end

-- 收牌动画第二段
function BJLCutCollectPokerCardsAnimationStepTwo(pokerCard)
    local tweenPosition = pokerCard.gameObject:AddComponent(typeof(CS.TweenTransform))
    tweenPosition.to = POKER_JOINTS[99]
    tweenPosition.duration = 0.4
    tweenPosition:OnFinished("+", function()
        pokerCard.gameObject:SetActive(false)
        if tweenPosition ~= nil then
            CS.UnityEngine.Object.Destroy(tweenPosition)
        end
    end )
    tweenPosition:Play(true)
end


--=============================================================================
--=================[下注阶段][BJL_ROOM_STATE.BET] [4]=========================

-- 刷新押注区域相关的内容       --OK
function BJLRefreshBetAreaPartOfGameRoomByState(roomState, isInit)
    if isInit then
        if roomState >= BJL_ROOM_STATE.BET then
            if roomState < BJL_ROOM_STATE.SETTLEMENT then
                BJLResetBetChipsAlreadyOnTable(GameData.RoomInfo.CurrentRoomChips)
            end
            HandleBJLBetValueChanged(3)
        end
        -- 初始状态的时候，筹码都设置成为不可用
        BJLResetChipsInteractable(true)
    end

    if roomState == BJL_ROOM_STATE.BET then
        -- 押注开始动画
        BJLResetChipsInteractable(false)

        local tBetTime = data.PublicConfig.BJL_ROOM_TIME[BJL_ROOM_STATE.BET]

        if GameData.RoomInfo.CurrentRoom.CountDown >(tBetTime -2) then
            BJLHandleBetAreaAnimation(1)
            this:DelayInvoke(1.7,
            function()
                BJLHandleBetAreaAnimation(3)
            end )
        end
    else
        BJLResetChipsInteractable(true)
    end
end

-- 刷新押注阶段CD           --OK
function BJLRefreshBetCountDownOfGameRoomByState(roomState)
    if roomState == BJL_ROOM_STATE.BET then
        local countDown = GameData.RoomInfo.CurrentRoom.CountDown
        -- 开局2秒内进入房间提示已开局，请下注
        local tBetTime = data.PublicConfig.BJL_ROOM_TIME[BJL_ROOM_STATE.BET]
        if tBetTime - countDown < 2 then
            CS.BubblePrompt.Show(data.GetString("Tip_Start_Bet"), "BJLGameUI")
            -- 音效:已开局请下注
            BJLPlaySoundEffect('35')
        end
        if countDown > 3 then
            isUpdateBetCountDown = true
            GameObjectSetActive(BetCountDownGameObject, true)
        else
            isUpdateBetCountDown = false
            GameObjectSetActive(BetCountDownGameObject, false)
        end
    else
        isUpdateBetCountDown = false
        GameObjectSetActive(BetCountDownGameObject, false)
    end
end

-- 更新押注倒计时       --OK
function UpdateBetCountDown_BJL()
    if isUpdateBetCountDown == true then
        local countDown = GameData.RoomInfo.CurrentRoom.CountDown
        if countDown < m_BetLimitTime then
            isUpdateBetCountDown = false
            GameObjectSetActive(BetCountDownGameObject, false)
            if BJL_ROOM_STATE.BET == GameData.RoomInfo.CurrentRoom.RoomState and countDown > m_BetLimitTime - 0.5 then
                -- 停止下注提示
                if countDown > 0.3 then
                    CS.BubblePrompt.Show(data.GetString("Tip_Stop_Bet"), "BJLGameUI")
                end
                -- 音效:停止下注
                BJLPlaySoundEffect('36')
                -- 音效:是否下注提示
                local betValue = GameData.RoomInfo.CurrentRoom.BetValues
                local isPlay = true
                for k, v in pairs(betValue) do
                    if nil ~= v and v > 0 then
                        isPlay = false
                        break
                    end
                end
                if true == isPlay then
                    this:DelayInvoke(1.2, function() BJLPlaySoundEffect('37') end)
                end
            end
        end
        -- 显示时间比实际时间少
        local tCurrentDown = math.ceil(countDown - m_BetLimitTime)
        if m_ShowCountDown ~= tCurrentDown then
            m_ShowCountDown =tCurrentDown
            BetCountDownText.text = tostring(m_ShowCountDown)
        end
        
        if countDown < m_BetLimitTime + 5 then
            canPlayCountDownAudio = true
        else
            canPlayCountDownAudio = false
            nowPlayingCountDownAudio = false
        end

        if canPlayCountDownAudio == true and nowPlayingCountDownAudio == false then
            PlayCountDownAudio()
            nowPlayingCountDownAudio = true
        end
    end
end

-- 播放倒计时音效       --OK
function PlayCountDownAudio()
    -- 音效倒计时 5 4 3 2 1
    local countDown = GameData.RoomInfo.CurrentRoom.CountDown
    local count = math.ceil(countDown - m_BetLimitTime)
    for i = 1, count - 1 do
        this:DelayInvoke(i - 1, function() BJLPlaySoundEffect('8') end)
    end
    if count > 1 then
        this:DelayInvoke(count - 1, function() BJLPlaySoundEffect('9') end)
    end
end

------------------------------------------------------------
-------------------[筹码 1] 可否使用相关-----------------------

-- [筹码 1] 刷新筹码可否使用状态         --OK
function BJLResetChipsInteractable(forceInteractableFalse)
    local roleGold = GameData.RoleInfo.GoldCount

    local selectChipRoot = this.transform:Find('Canvas/BetChipHandle/Chips/Viewport/Content')
    for index = 1, 10, 1 do
        local chipItem = selectChipRoot:Find('Chip' .. index):GetComponent("Toggle")
        if forceInteractableFalse then
            BJLRefreshChipInteractable(chipItem, false)
        else
            local chipValue = CHIP_VALUE[index]
            if not BJLIsChipCanBeUsedInCurrentRoom(index) or roleGold < chipValue then
                BJLRefreshChipInteractable(chipItem, false)
            else
                BJLRefreshChipInteractable(chipItem, true)
            end
        end
    end
end

-- [筹码 1] 筹码选项 可否使用设置        --OK
function BJLRefreshChipInteractable(chipItem, interactable)
    if not interactable then
        if chipItem.isOn then
            local toggleGroup = chipItem.group
            toggleGroup.allowSwitchOff = true
            chipItem.isOn = false
            GameData.RoomInfo.CurrentRoom.SelectBetValue = 0
            toggleGroup.allowSwitchOff = false
        end
    end
    chipItem.interactable = interactable
end

-- [筹码 1] 筹码是否可用检测             --OK
function BJLIsChipCanBeUsedInCurrentRoom(chipIndex)
    local roomConfig = data.RoomConfig[GameData.RoomInfo.CurrentRoom.TemplateID]
    if roomConfig ~= nil then
        return lua_TableContainsValue(roomConfig.CanUseChip, chipIndex)
    end
    return false
end

-- 选中某个筹码call                     --OK
function ChipValueOnValueChanged(isOn, chipValue)
    if isOn then
        GameData.RoomInfo.CurrentRoom.SelectBetValue = chipValue
    end
end

--===========================押注区域动画======================================

-- 押注区域动画 1 压住开始动画 2结算期间动画 3关闭闪烁动画  --OK
function BJLHandleBetAreaAnimation(aniType)
    local betAreaRoot = this.transform:Find('Canvas/BetChipHandle/BetArea')
    if aniType == 1 then
        for index = 1, 5, 1 do
            -- 打开线条灯光
            local areaAni = betAreaRoot:Find('Area' .. index .. '/LineLight')
            areaAni.gameObject:SetActive(true)
            areaAni:GetComponent("TweenAlpha"):ResetToBeginning()
            areaAni:GetComponent("TweenAlpha"):Play(true)
        end
    elseif aniType == 2 then
        local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
        for index = 1, 5, 1 do
            -- 打开区域灯光
            local areaAni = betAreaRoot:Find('Area' .. index .. '/AreaLight')
            if CS.Utility.GetLogicAndValue(gameResult, BJL_AREA_WIN_CODE[index]) == BJL_AREA_WIN_CODE[index] then
                -- 只有赢得区域闪烁
                areaAni.gameObject:SetActive(true)
                areaAni:GetComponent("TweenAlpha"):ResetToBeginning()
                areaAni:GetComponent("TweenAlpha"):Play(true)
            else
                areaAni.gameObject:SetActive(false)
            end
        end
    else
        for index = 1, 5, 1 do
            -- 关闭区域灯光
            betAreaRoot:Find('Area' .. index .. '/AreaLight').gameObject:SetActive(false)
            -- 关闭线条灯光
            betAreaRoot:Find('Area' .. index .. '/LineLight').gameObject:SetActive(false)
        end
    end
end

-- 设置押注区域值  1他人下注 2 自己下注 3房间初始化 nil 清理数据      --OK
function HandleBJLBetValueChanged(arg)
    if arg ~= 1 then
        for index = 1, 5, 1 do
            local betValue = GameData.RoomInfo.CurrentRoom.BetValues[index]
            local betValueText = this.transform:Find('Canvas/BetChipHandle/BetValue/Value' .. index):GetComponent("Text")
            if betValue ~= nil and betValue > 0 then
                betValueText.gameObject:SetActive(true)
                betValueText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(betValue))
            else
                betValueText.gameObject:SetActive(false)
                betValueText.text = "0"
            end
        end
        -- 刷新下离开房间状态
        RefreshExitRoomButtonState(false)
    end
    for index = 1, 5, 1 do
        local betValue = GameData.RoomInfo.CurrentRoom.TotalBetValues[index]
        local backImage = this.transform:Find('Canvas/BetChipHandle/TotalBetValue/Image' .. index)
        local betValueText = this.transform:Find('Canvas/BetChipHandle/TotalBetValue/Value' .. index):GetComponent("Text")
        if betValue ~= nil and betValue > 0 then
            betValueText.gameObject:SetActive(true)
            betValueText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(betValue))
            backImage.gameObject:SetActive(true)
        else
            betValueText.gameObject:SetActive(false)
            betValueText.text = "0"
            backImage.gameObject:SetActive(false)
        end
    end
end

-------------------------------------------------------------------------------
-----------------------------------[筹码 2]下注相关--------------------------------

--=================CS_BJL_Bet  1278---------------------------------
-- 押注区域被点击了             --OK
function BetAreaButtonOnClick(areaType)
    -- 发送押注信息, 非押注阶段不可押注, 押注倒计时期间
    if isUpdateBetCountDown then
        if GameData.RoomInfo.CurrentRoom.RoomState == BJL_ROOM_STATE.BET then
            if GameData.RoomInfo.CurrentRoom.SelectBetValue > 0 then
                BJLGameMgr.Send_CS_BJL_Bet(areaType, GameData.RoomInfo.CurrentRoom.SelectBetValue)
            else
                CS.BubblePrompt.Show("请选择筹码", "BJLGameUI")
            end
        end
    end
end

-- 下注结果处理         --OK
function HandleBJLBetResultEvent(eventArgs)
    if eventArgs.ResultType == 0 then
        BetChipToDesk(eventArgs.AreaType, eventArgs.BetValue, eventArgs.RoleID)
    else
        local betAreaItem = this.transform:Find('Canvas/BetChipHandle/BetArea/Area' .. eventArgs.AreaType)
        if betAreaItem ~= nil then
            betAreaItem:GetComponent("SwitchAnimation"):Play(1)
        end
        if eventArgs.ResultType == 7 or eventArgs.ResultType == 8 or eventArgs.ResultType == 9 then
            CS.BubblePrompt.Show(string.format(data.GetString("T_1278_"..eventArgs.ResultType),lua_NumberToStyle1String(eventArgs.ErrorValue)),"LHDGameUI")
        else
            CS.BubblePrompt.Show(data.GetString("T_1278_" .. eventArgs.ResultType), "LHDGameUI")
        end
    end
end

-- 押注筹码到桌子上 --OK
function BetChipToDesk(areaType, betValue, roleID)
    local startPoint = nil
    if roleID == GameData.RoleInfo.AccountID then
        -- 如果是自己，则从自己点开始， 否则从其他玩家点开始
        startPoint = CHIP_JOINTS[11]
    else
        startPoint = CHIP_JOINTS[12]
    end
    BJLCastChipToBetArea(areaType, betValue, tostring(roleID), true, startPoint.JointPoint.position)
    -- 押注筹码音效
    BJLPlaySoundEffect('5')
end

--=================重置已经在桌面上的筹码       --OK
function BJLResetBetChipsAlreadyOnTable(currentRoomChips)
    -- 遍历 押注区域
    for areaType = 1, 5, 1 do
        lua_Transform_ClearChildren(CHIP_JOINTS[areaType].JointPoint, false)
        if currentRoomChips ~= nil and currentRoomChips[areaType] ~= nil then
            -- 有押注值
            local betChips = currentRoomChips[areaType]
            local leftBetValue = GameData.RoomInfo.CurrentRoom.BetValues[areaType]
            if leftBetValue == nil then
                leftBetValue = 0
            end
            for chipIndex = 10, 1, -1 do
                local chipValue = CHIP_VALUE[chipIndex]
                local chipInfo = betChips[chipValue]
                if chipInfo ~= nil then
                    local chipCount = betChips[chipValue].Count
                    if chipCount ~= nil then
                        -- 创建等值的筹码
                        for count = 1, chipCount, 1 do
                            local chipName
                            chipName, leftBetValue = HandleInitRoomChipsOfChipOwner(chipValue, leftBetValue)
                            BJLCastChipToBetArea(areaType, CHIP_VALUE[chipIndex], chipName, false, nil)
                        end
                    end
                end
            end
        end
    end
end

-- [筹码 1]: 划归初始化时某个的归属             --OK 待继续数据
function HandleInitRoomChipsOfChipOwner(chipValue, leftBetValue)
    if leftBetValue < chipValue then
        return "0", leftBetValue
    else
        leftBetValue = leftBetValue - chipValue
        return tostring(GameData.RoleInfo.AccountID), leftBetValue
    end
end

--==============================--
--desc: [筹码 2]: 向押注区域投掷筹码            --OK
--@areaType: 区域值
--@chipValue: 筹码值
--@chipName: 筹码Name
--@isAnimation: 是否有动画
--@fromWorldPoint: 起始点坐标
--@return 
--==============================--
function BJLCastChipToBetArea(areaType, chipValue, chipName, isAnimation, fromWorldPoint)
    local model = CHIP_MODEL[chipValue]
    if model ~= nil then
        local betChip = CS.UnityEngine.Object.Instantiate(model)
        betChip.gameObject.name = chipName
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

--=============================================================================
--=================[亮牌阶段] [BJL_ROOM_STATE.CHECK] [5]========================
-- 扑克牌亮牌相关内容       --OK
function BJLRefreshCheckPartOfGameRoomByState(roomState, isInit)

    if isInit then
        BJLResetPokerCardToRestart()
        if roomState >= BJL_ROOM_STATE.CHECK then
            HandleDealPokerCardToCardTable(roomState >= BJL_ROOM_STATE.CHECK)
        end
    else
        if roomState == BJL_ROOM_STATE.CHECK then
            BJLResetPokerCardToRestart()
            HandleDealPokerCardToCardTable(false)
        elseif roomState == BJL_ROOM_STATE.SETTLEMENT then
            BJLRefreshRemainText(GameData.RoomInfo.CurrentRoom.CardCount)
        end
    end
end

-- 扑克牌发送到牌桌上           --OK
function HandleDealPokerCardToCardTable(isNoAnimation)
    local tPokersX = GameData.RoomInfo.CurrentRoom.PokersX
    local tPokersZ = GameData.RoomInfo.CurrentRoom.PokersZ
    local tPokersXCount = #tPokersX
    local tPokersZCount = #tPokersZ

    if isNoAnimation then
        -- 无发牌动画(闲牌--庄牌)
        -- 闲家牌
        for index = 1, tPokersXCount, 1 do
            local pokerCardItem = POKER_CARDS[index]
            lua_Paste_Transform_Value(pokerCardItem, POKER_JOINTS[index])
            GameObjectSetActive(pokerCardItem.gameObject, true)
            BJLSetTablePokerCardVisible(pokerCardItem, true)
            local pokerCard = tPokersX[index]
            if pokerCard ~= nil then
                pokerCardItem:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(pokerCard))
                RefreshSettlementPartOfPokerCard(index,pokerCard)
            end
        end
        -- 庄家牌
        for cardPos2 = 1, tPokersZCount, 1 do
            local tCardIndex = cardPos2 + 3
            local pokerCardItem = POKER_CARDS[tCardIndex]
            lua_Paste_Transform_Value(pokerCardItem, POKER_JOINTS[tCardIndex])
            GameObjectSetActive(pokerCardItem.gameObject, true)
            BJLSetTablePokerCardVisible(pokerCardItem, true)
            
            local pokerCard = tPokersZ[cardPos2]
            if pokerCard ~= nil then
                pokerCardItem:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(pokerCard))    
                RefreshSettlementPartOfPokerCard(tCardIndex,pokerCard)
            end
        end
        BJLRefreshPokerNumber(tPokersXCount)
        BJLRefreshPokerNumber(3+tPokersXCount)
    else
        -- 有发牌动画
        m_PokerCardsRoot:GetComponent("AnimationControl"):Play(0, true)
        if tPokersXCount == 2 and tPokersZCount == 2 then
            -- 庄闲均无补牌
            
        elseif tPokersXCount == 3 and tPokersZCount == 2 then
            -- 只有闲家补牌
            this:DelayInvoke(4, function ()
                m_PokerCardsRoot1:GetComponent("AnimationControl"):Play(0, true)
            end)
        elseif tPokersXCount == 2 and tPokersZCount == 3 then
            -- 只有庄家补牌
            this:DelayInvoke(4, function ()
                m_PokerCardsRoot2:GetComponent("AnimationControl"):Play(0, true)
            end)
        else
            -- 庄闲均补牌
            this:DelayInvoke(4, function ()
                m_PokerCardsRoot1:GetComponent("AnimationControl"):Play(0, true)
            end)
            this:DelayInvoke(5.5, function ()
                m_PokerCardsRoot2:GetComponent("AnimationControl"):Play(0, true)
            end)
        end
    end
    
end

-- 发牌动画结束Event 对应每一张牌翻发到桌面     --OK
function HandleBJLAnimationControlFrameComplated(args)
    if args ~= nil then
        local params = lua_string_split(args, "##")
        local eventType = params[1]
        if eventType == "DealComplated" then
            local cardIndex = tonumber(params[2])
            local cardItem = POKER_CARDS[cardIndex]
            BJLSetTablePokerCardVisible(cardItem, true)
            BJLRefreshPokerNumber(cardIndex)

            local tPokersX = GameData.RoomInfo.CurrentRoom.PokersX
            local tPokersZ = GameData.RoomInfo.CurrentRoom.PokersZ
            local pokerCard = nil
            if cardIndex <=3 then
                pokerCard = tPokersX[cardIndex]
            else
                pokerCard = tPokersZ[cardIndex - 3]
            end
            if pokerCard ~= nil then
                cardItem:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(pokerCard))
                RefreshSettlementPartOfPokerCard(cardIndex,pokerCard)
            end
        end
        if eventType == "DealStart" then
            local cardIndex = tonumber(params[2])
            BJLPlayDealPokerAudio(cardIndex)
            BJLPlaySoundEffect('3')

            local tCardCount = GameData.RoomInfo.CurrentRoom.CacheCardCount - 1
            GameData.RoomInfo.CurrentRoom.CacheCardCount = tCardCount
            BJLRefreshRemainText(tCardCount)
        end
    end
end

-- 百家乐亮牌阶段扑克对应音效
function BJLPlayDealPokerAudio(pokerIndex)
    local tAudioID = "BJL_fapai_p_1"
    if pokerIndex == 1 or pokerIndex == 2 then
        tAudioID = "BJL_fapai_p_1"
    elseif pokerIndex == 4 or pokerIndex == 5 then
        tAudioID = 'BJL_fapai_b_1'
    elseif pokerIndex == 3 then
        tAudioID = "BJL_fapai_p_2"
    elseif pokerIndex == 6 then
        tAudioID = "BJL_fapai_b_2"
    end
    BJLPlaySoundEffect(tAudioID)
end

-- 设置玩家扑克牌是否可见           --OK
function BJLSetTablePokerCardVisible(pokerCard, isVisible)
    pokerCard:Find('back').gameObject:SetActive(lua_NOT_BOLEAN(isVisible))
    if isVisible then
        BJLPlaySoundEffect('4')
    end
end

-- 刷新统计区域的扑克牌信息         --OK
function RefreshSettlementPartOfPokerCard(pokerIndexParam, pokerDataParam)
    local cardItem = SettlementNode.Cards[pokerIndexParam]
    local cardSpriteName = GameData.GetPokerDisplaySpriteName(pokerDataParam)
    cardItem:GetComponent("Image"):ResetSpriteByName(cardSpriteName)
    GameObjectSetActive(cardItem.gameObject, true)
end

-- 刷新庄闲点数
function BJLRefreshPokerNumber(pokerIndex)
    if pokerIndex <= 3 then
        local tPokerXNO = 0
        local tPokerXActive = true
        local tPokersX = GameData.RoomInfo.CurrentRoom.PokersX
        if pokerIndex == 2 then
            tPokerXNO = BJLGetPokerNumber(tPokersX[1], tPokersX[2])
        elseif pokerIndex == 3 then
            tPokerXNO = BJLGetPokerNumber(tPokersX[1], tPokersX[2], tPokersX[3])
        else
            tPokerXActive = false
        end
        if tPokerXActive then
            mPokerXNOText1.text = tostring(tPokerXNO)
            mPokerXNOText2.text = tostring(tPokerXNO)
        else
            mPokerXNOText2.text = ''
        end
        GameObjectSetActive(mPokerXNOGameObject, tPokerXActive)
        GameObjectSetActive(mPokerXNOGameObject2, tPokerXActive)
    else
        local tPokerZNO = 0
        local tPokerZActive = true
        local tPokersZ = GameData.RoomInfo.CurrentRoom.PokersZ
        if pokerIndex == 5 then
            tPokerZNO = BJLGetPokerNumber(tPokersZ[1], tPokersZ[2])
        elseif pokerIndex == 6 then
            tPokerZNO = BJLGetPokerNumber(tPokersZ[1], tPokersZ[2], tPokersZ[3])
        else
            tPokerZActive = false
        end

        if tPokerZActive then
            mPokerZNOText1.text = tostring(tPokerZNO)
            mPokerZNOText2.text = tostring(tPokerZNO)
        else
            mPokerZNOText2.text = ''
        end
        
        GameObjectSetActive(mPokerZNOGameObject, tPokerZActive)
        GameObjectSetActive(mPokerZNOGameObject2, tPokerZActive)
    end
end

-- 扑克牌点数
function BJLGetPokerNumber(dataParam1, dataParam2, dataParam3)
    if dataParam1 == nil or dataParam2 == nil  then
        print("***BJL**获取扑克牌点数参数有误")
        return 0
    end
    local tNO = 0
    local tNO1 = dataParam1.PokerNumber > 10 and 10 or dataParam1.PokerNumber
    local tNO2 = dataParam2.PokerNumber > 10 and 10 or dataParam2.PokerNumber
    local tNO3 = 0
    if dataParam3 ~= nil then
        tNO3 = dataParam3.PokerNumber > 10 and 10 or dataParam3.PokerNumber
    end
    tNO = (tNO1 + tNO2 + tNO3) % 10
    return  tNO
end

--=============================================================================
--=================[结算阶段][BJL_ROOM_STATE.SETTLEMENT] [6]====================
-- 结算阶段 相关处理    --OK
function RefreshSettlementPartOfGameRoomByState(roomState, isInit)
    GameObjectSetActive(SettlementNode.RootNode, roomState >= BJL_ROOM_STATE.CHECK)
    if roomState == BJL_ROOM_STATE.SETTLEMENT then
        SettlementNode.SealImage:ResetSpriteByName(BJLGetSealIconNameByGameResult(GameData.RoomInfo.CurrentRoom.GameResult))
        SettlementAllAnimations(isInit)
    end
end

-- 结果类型Image                --OK
function BJLGetSealIconNameByGameResult(gameResult)
    if CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.LONG) == BJL_WIN_CODE.LONG then
        return 'sprite_Seal_bjl_1'
    elseif CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.HU) == BJL_WIN_CODE.HU then
        return 'sprite_Seal_bjl_2'
    elseif CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.HE) == BJL_WIN_CODE.HE then
        return 'sprite_Seal_bjl_4'
    else
        return 'sprite_Seal_bjl_4'
    end
end

-- 结算阶段动画处理         --OK
function SettlementAllAnimations(isInit)
    -- 开始收筹码
    if not isInit then
        local tXPokers = GameData.RoomInfo.CurrentRoom.PokersX
        local tZPokers = GameData.RoomInfo.CurrentRoom.PokersZ
        local tXCount = #tXPokers
        local tZCount = #tZPokers
        local tXPoint = BJLGetPokerNumber(tXPokers[1], tXPokers[2], tXPokers[3])
        local tZPoint = BJLGetPokerNumber(tZPokers[1], tZPokers[2], tZPokers[3])
        local tDelayTime = 0
        if tXCount == 2 and tZCount == 2 then
            --1 双方均无追加
            if tXPoint <= 7 then
                BJLPlayBrandTypeAudio(tXPoint, false)
                tDelayTime = 1.5
            else
                BJLPlaySoundEffect("BJL_fapai_p_1")
                tDelayTime = 1.0
                this:DelayInvoke(tDelayTime, function ()  BJLPlayTianPaiAudio(tXPoint)  end)
                tDelayTime = tDelayTime + 1.5
            end

            if tZPoint <= 7 then
                this:DelayInvoke(tDelayTime, function () BJLPlayBrandTypeAudio(tZPoint, true) end)
                tDelayTime = tDelayTime + 1.5
            else
                this:DelayInvoke(tDelayTime, function ()  BJLPlaySoundEffect("BJL_fapai_b_1") end)
                tDelayTime = tDelayTime + 1.0
                this:DelayInvoke(tDelayTime, function ()  BJLPlayTianPaiAudio(tZPoint)  end)
                tDelayTime = tDelayTime + 1.5
            end
        elseif tXCount == 3 and tZCount == 2 then
            --2 闲家追加: 闲家点数 + 庄家点数or天牌
            BJLPlayBrandTypeAudio(tXPoint, false)
            tDelayTime = 1.5
            if tZPoint <= 7 then
                this:DelayInvoke(tDelayTime, function () BJLPlayBrandTypeAudio(tZPoint, true) end)
                tDelayTime = tDelayTime + 1.5
            else
                this:DelayInvoke(tDelayTime, function ()  BJLPlaySoundEffect("BJL_fapai_p_1") end)
                tDelayTime = tDelayTime + 1.0
                this:DelayInvoke(tDelayTime, function ()  BJLPlayTianPaiAudio(tZPoint)  end)
                tDelayTime = tDelayTime + 1.5
            end

        elseif tXCount == 2 and tZCount == 3 then
            --3 庄家追加：闲家点数or天牌 +庄家点数
            -- 闲家播报
            if tXPoint <= 7 then
                BJLPlayBrandTypeAudio(tXPoint, false)
                tDelayTime = 1.5
            else
                BJLPlaySoundEffect("BJL_fapai_p_1")
                tDelayTime = 1.0
                this:DelayInvoke(tDelayTime, function ()  BJLPlayTianPaiAudio(tXPoint)  end)
                tDelayTime = tDelayTime + 1.5
            end
            -- 庄家播报
            this:DelayInvoke(tDelayTime, function () BJLPlayBrandTypeAudio(tZPoint, true) end)
            tDelayTime = tDelayTime + 1.5

        elseif tXCount == 3 and tZCount == 3 then
            --4 闲家庄家均追加 双方点数
            -- 闲家播报
            BJLPlayBrandTypeAudio(tXPoint, false)
            tDelayTime = 1.5
            -- 庄家播报
            this:DelayInvoke(tDelayTime, function ()  BJLPlayBrandTypeAudio(tZPoint, true)  end)
            tDelayTime = tDelayTime + 1.5
        end
        -- print("**BJL**结算阶段时间1:", tDelayTime )

        -- 开始收筹码
        this:DelayInvoke(tDelayTime, BJLCollectChips)
        -- 显示印章 + 结果音效 + 闪烁
        this:DelayInvoke(tDelayTime, function() BJLHandleShowGameResult(true) end)
    else
        
        BJLHandleShowGameResult(false)
    end
end

-- 胜负结果音效+闪烁            --OK
function BJLHandleShowGameResult(isAudio)
    if isAudio then
        -- 胜负结果
        PlayGameWinCodeAudio()
    end
    -- 直接显示印章不播放音效
    ShowGameResultSeal(isAudio)
    -- 押注区域开始闪烁
    BJLHandleBetAreaAnimation(2)
    -- 本局统计追加值
    if GameData.RoomInfo.CurrentRoom.AppendStatisticsEventArgs ~= nil then
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics, GameData.RoomInfo.CurrentRoom.AppendStatisticsEventArgs)
    end
end

-- 牌型获取         --OK
function BJLPokerType(isBanker)
    local tPokerData = {}
    if isBanker == true then
        tPokerData = GameData.RoomInfo.CurrentRoom.PokersZ
    else
        tPokerData = GameData.RoomInfo.CurrentRoom.PokersX
    end
    return BJLGetPokerNumber(tPokerData[1],tPokerData[2],tPokerData[3])
end

-- 牌型音效 扑克点数 是否庄家
function BJLPlayBrandTypeAudio(pokerPointParam, isBanker)
    local musicid = "BJL_point_1_"
    if isBanker then
        musicid = "BJL_point_0_"
    end
    musicid = musicid .. pokerPointParam
    BJLPlaySoundEffect(musicid)
end

-- 天牌音效8，9点播放
function BJLPlayTianPaiAudio(pokerPointParam)
    local musicid = "BJL_point_t_"
    musicid = musicid .. pokerPointParam
    BJLPlaySoundEffect(musicid)
end

-- 胜负结果             --OK
function PlayGameWinCodeAudio()
    local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
    -- 确认胜负方
    local tResultAudio = "BJL_win_p_"
    if CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.LONG) == BJL_WIN_CODE.LONG then
        tResultAudio = "BJL_win_p_"
    elseif CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.HU) == BJL_WIN_CODE.HU then
        tResultAudio = "BJL_win_b_"
    elseif CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.HE) == BJL_WIN_CODE.HE then
        tResultAudio = "BJL_win_h_"
    end
    
    -- 确认结果类型
    local tResultAdd = 1
    local isXDui = CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.LONGDUIZI) == BJL_WIN_CODE.LONGDUIZI
    local isZDui = CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.HUDUIZI) == BJL_WIN_CODE.HUDUIZI
    if isXDui == true and isZDui == true then
        tResultAdd = 4
    elseif isXDui == true then
        tResultAdd = 3
    elseif  isZDui == true then
        tResultAdd = 2
    else
        tResultAdd = 1
    end

    tResultAudio = tResultAudio .. tResultAdd
    BJLPlaySoundEffect(tResultAudio)
end

-- 显示本局结果印章     --OK
function ShowGameResultSeal(isMusic)
    if isMusic == true then
        BJLPlaySoundEffect('6')
    end
    GameObjectSetActive(SettlementNode.SealImage.gameObject, true)
end

--===========================================================================
--=================处理筹码赔付相关============================================

-- [筹码赔付 1]： 开始收集筹码                          --OK
function BJLCollectChips()
    BJLStartCollectChipsAni()
end

-- [筹码动画 1]                                     --OK
function BJLStartCollectChipsAni()

    -- 开始播放动画
    BJLCollectLoseAreaChips()
end

-- [筹码动画 2]: 筹码飞向庄家           --OK
function BJLCollectLoseAreaChips()

    local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
    -- 和局检测
    local isDogfall = CS.Utility.GetLogicAndValue(gameResult, BJL_WIN_CODE.HE) == BJL_WIN_CODE.HE
    local durationTime = 0.5
    local collectArea = {}
    if isDogfall then
        collectArea = {4,5}
    else
        collectArea = {1,2,3,4,5}
    end
    -- 确认筹码目标点
    local endPoint = CHIP_JOINTS[13].JointPoint.position

    local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
    -- print("***BJL**结算:", gameResult)
    local isPlayed = false
    -- 筹码计数
    local chipCount = 0
    for collectIndex = 1, #collectArea, 1 do
        local areaIndex = collectArea[collectIndex]
        if CS.Utility.GetLogicAndValue(gameResult, BJL_AREA_WIN_CODE[areaIndex]) ~= BJL_AREA_WIN_CODE[areaIndex] then
            -- 筹码飞向庄家
            -- print("筹码飞向庄家222:", areaIndex, BJL_AREA_WIN_CODE[areaIndex])
            local chipJoint = CHIP_JOINTS[areaIndex].JointPoint
            local childCount = chipJoint.childCount
            chipCount = chipCount + childCount
            isPlayed = true
            for index = childCount - 1, 0, -1 do
                local chipItem = chipJoint:GetChild(index)
                local script = CS.TweenPosition.Begin(chipItem.gameObject, durationTime, endPoint, true)
                BJLAddRandomDelayForChip(script)
                script:OnFinished('+',( function() BJLHandleAnimationPlayEnd(chipItem) end))
                script:Play(true)
            end
        end
    end
    -- 筹码音效11111
    BJLDelayPlayAudioForChip(chipCount)

    if isPlayed then
        this:DelayInvoke(1.2, BJLBankerThrowChipsToLostArea)
    else
        BJLBankerThrowChipsToLostArea()
    end
end

-- [筹码动画 3]: 庄家筹码飞向桌面       --OK
function BJLBankerThrowChipsToLostArea()

    local durationTime = 0.5
    local roleIDStr = tostring(GameData.RoleInfo.AccountID)
    -- 确认筹码起始点
    local startPoint = CHIP_JOINTS[13].JointPoint.position

    local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
    local isPlayed = false

    -- 筹码计数
    local chipCount = 0
    for areaIndex = 1, 5, 1 do
        if CS.Utility.GetLogicAndValue(gameResult, BJL_AREA_WIN_CODE[areaIndex]) == BJL_AREA_WIN_CODE[areaIndex] then
            local chipArea = CHIP_JOINTS[areaIndex]
            local chipJoint = chipArea.JointPoint
            local childCount = chipJoint.childCount
            local payCount = BJL_COMPENSATE[areaIndex]
            local winGoldInfo = GameData.RoomInfo.CurrentRoom.WinGold[areaIndex]
            local areaWinGold = 0
            if winGoldInfo ~= nil then
                areaWinGold = winGoldInfo.WinGold
            end

            if GameData.RoomInfo.CurrentRoom.BetValues[areaIndex] ~= nil then
                GameData.RoomInfo.CurrentRoom.BetValues[areaIndex] = areaWinGold
            end

            chipCount = chipCount + childCount
            isPlayed = true
            for index = childCount - 1, 0, -1 do
                local chipItem = chipJoint:GetChild(index)
                local chipItemName = chipItem.gameObject.name
                local chipItemValue = tonumber(chipItem:GetChild(0).gameObject.name)
                for i = 1, payCount, 1 do
                    if chipItemName == roleIDStr then
                        if areaWinGold > 0 and chipItemValue <= areaWinGold then
                            areaWinGold = areaWinGold - chipItemValue
                        else
                            break
                        end
                    end

                    local newChips = CS.UnityEngine.Object.Instantiate(chipItem)
                    CS.Utility.ReSetTransform(newChips, chipJoint)
                    newChips.gameObject.name = chipItemName
                    newChips.position = startPoint
                    local localX = math.random(chipArea.RangeX.Min, chipArea.RangeX.Max)
                    local localY = math.random(chipArea.RangeY.Min, chipArea.RangeY.Max)
                    local script = CS.TweenPosition.Begin(newChips.gameObject, durationTime, CS.UnityEngine.Vector3(localX, localY, 0), false)
                    BJLAddRandomDelayForChip(script)
                    script:Play(true)
                end
            end

            if areaWinGold > 0 then
                -- 赔付后还有剩余金额不能用筹码赔付
                areaWinGold = areaWinGold + CHIP_VALUE[1] / 2
                -- 加上半个筹码值，便于后续取整
                for index = 10, 1, -1 do
                    local count = math.floor(areaWinGold / CHIP_VALUE[index])
                    -- 筹码计数
                    chipCount = chipCount + count

                    for i = 1, count, -1 do
                        -- 丢入筹码
                        local newChips = CS.UnityEngine.Object.Instantiate(CHIP_MODEL[CHIP_VALUE[index]])
                        CS.Utility.ReSetTransform(newChips, chipJoint)
                        newChips.gameObject.name = roleIDStr
                        newChips.position = startPoint
                        local localX = math.random(chipArea.RangeX.Min, chipArea.RangeX.Max)
                        local localY = math.random(chipArea.RangeY.Min, chipArea.RangeY.Max)
                        local script = CS.TweenPosition.Begin(newChips.gameObject, durationTime, CS.UnityEngine.Vector3(localX, localY, 0), false)
                        BJLAddRandomDelayForChip(script)
                        script:Play(true)
                    end
                    areaWinGold = areaWinGold - count * CHIP_VALUE[index]
                end
            end
        end
    end
    -- 筹码音效22222
    BJLDelayPlayAudioForChip(chipCount)
    if isPlayed then
        this:DelayInvoke(1.5, BJLHandleRoleCollectOwnChipAreas)
    else
        BJLHandleRoleCollectOwnChipAreas()
    end
end

-- 玩家收筹码表现（赢得筹码和+ 和局返还龙、虎区域筹码）
function BJLHandleRoleCollectOwnChipAreas()

    HandleBJLBetValueChanged(3)
    BJLHandleSettlementGetGoldShowTip()

    local isPlayed = false
    local roleIDStr = tostring(GameData.RoleInfo.AccountID)
    local durationTime = 0.5
    -- 筹码计数
    local chipCount = 0
    for areaIndex = 1, 5, 1 do
        local chipJoint = CHIP_JOINTS[areaIndex].JointPoint
        if chipJoint ~= nil then
            local childCount = chipJoint.childCount
            -- 筹码计数
            chipCount = chipCount + childCount
            for index = childCount - 1, 0, -1 do
                isPlayed = true
                local chipItem = chipJoint:GetChild(index)
                local endPoint = CHIP_JOINTS[12].JointPoint.position
                if chipItem.gameObject.name == roleIDStr then
                    endPoint = CHIP_JOINTS[11].JointPoint.position
                end
                local script = CS.TweenPosition.Begin(chipItem.gameObject, durationTime, endPoint, true)
                BJLAddRandomDelayForChip(script)
                script:OnFinished('+',( function() BJLHandleAnimationPlayEnd(chipItem) end))
                script:Play(true)
            end
        end
    end
    -- 筹码音效33333
    BJLDelayPlayAudioForChip(chipCount)
    BJLCollectPokerCardsAnimationStepOne()
end

-- 为筹码增加 0- 0.5s 的延迟，让其错乱飞    --OK
function BJLAddRandomDelayForChip(script)
    script.delay = CS.UnityEngine.Random.Range(0, 0.5)
end

-- 为筹码音效增加 0 - 0.3 的延迟,让其感觉音效很多   --OK
function BJLDelayPlayAudioForChip(chipAllCount)
    if chipAllCount > 0 then
        local limitCount = 4
        for i = 1, chipAllCount do
            if i > limitCount then
                break
            end
            local delayTime = CS.UnityEngine.Random.Range(0, 0.3)
            this:DelayInvoke(delayTime, function() BJLPlaySoundEffect('7') end)
        end
    end
end

-- 销毁筹码
function BJLHandleAnimationPlayEnd(chipItem)

    CS.UnityEngine.Object.Destroy(chipItem.gameObject)
end

-- [结算阶段]: 玩家赢钱             --OK
function BJLHandleSettlementGetGoldShowTip()
    GameData.SyncDisplayGoldCount()
    
end


-- 收牌动画第一段
function BJLCollectPokerCardsAnimationStepOne()
    local tPokersXCount = #GameData.RoomInfo.CurrentRoom.PokersX
    local tPokersZCount = #GameData.RoomInfo.CurrentRoom.PokersZ

    local movePokerTable = {}
    -- 闲家牌
    for index = 1, tPokersXCount, 1 do
        local pokerCardItem = POKER_CARDS[index]
        table.insert(movePokerTable, pokerCardItem)
    end
    -- 庄家牌
    for cardPos2 = 1, tPokersZCount, 1 do
        local tCardIndex = cardPos2 + 3
        local pokerCardItem = POKER_CARDS[tCardIndex]
        table.insert(movePokerTable, pokerCardItem)
    end

    for index = 1, #movePokerTable, 1 do
        local pokerCard = movePokerTable[index]
        if pokerCard ~= nil then
            local script = pokerCard.gameObject:AddComponent(typeof(CS.TweenTransform))
            script.to = POKER_JOINTS[98]
            script.duration = 0.3
            script:OnFinished("+",
            function()
                if script ~= nil then
                    CS.UnityEngine.Object.Destroy(script)
                    BJLCollectPokerCardsAnimationStepTwo(pokerCard)
                end
            end )
            script:Play(true)
        end
    end
end

-- 收牌动画第二段
function BJLCollectPokerCardsAnimationStepTwo(pokerCard)
    local tweenPosition = pokerCard.gameObject:AddComponent(typeof(CS.TweenTransform))
    tweenPosition.to = POKER_JOINTS[99]
    tweenPosition.duration = 0.4
    tweenPosition:OnFinished("+", function()
        pokerCard.gameObject:SetActive(false)
        if tweenPosition ~= nil then
            CS.UnityEngine.Object.Destroy(tweenPosition)
        end
    end )
    tweenPosition:Play(true)
end

--=============================游戏流程处理 END  ==============================

-- 游戏状态变化音效播放接口         --OK
function BJLPlaySoundEffect(musicid)
    if true == canPlaySoundEffect then
        MusicMgr:PlaySoundEffect(tostring(musicid))
    end
end

--=============================UI 系统接口 Begin===============================

function Awake()
    print("______BJL")
    DoHelp();
    local BRHallUI = CS.WindowManager.Instance:FindWindowNodeByName("BRHallUI")
    if BRHallUI ~= nil then
        BRHallUI.WindowGameObject:SetActive(false)
    else
        print('*********BRHallUI查找失败，请请检查!')
    end
    CS.MatchLoadingUI.Hide();
    TransformRoot = this.transform
    -- 房间人数
    mRoleCountText = TransformRoot:Find('Canvas/RoomInfo/RoleCount/ValueText'):GetComponent("Text")
    -- 玩家信息
    RoleNameText = TransformRoot:Find('Canvas/RoleInfo/Name'):GetComponent("Text")
    RoleGoldText = TransformRoot:Find('Canvas/RoleInfo/GoldCount'):GetComponent("Text")
    RoleChangeGold = TransformRoot:Find('Canvas/RoleInfo/ChangedGold')
    -- 房间信息
    RoomIDText = this.transform:Find('Canvas/RoomInfo/RoomID/Value'):GetComponent("Text")
    -- 洗牌动画组件
    ShuffleAniGameObject = this.transform:Find('Canvas/ShuffleAni').gameObject
    ShuffleAni2GameObject = this.transform:Find('Canvas/ShuffleAni2').gameObject
    BetCountDownGameObject = this.transform:Find('Canvas/CountDown').gameObject
    BetCountDownText = this.transform:Find('Canvas/CountDown/ValueText'):GetComponent("Text")
    -- 结算组件
    SettlementNode.RootNode = this.transform:Find('Canvas/PokerHandle/Result').gameObject
    SettlementNode.SealImage = this.transform:Find('Canvas/PokerHandle/Result/SealImage'):GetComponent("Image")
    for cardIndex = 1, 6 do
        SettlementNode.Cards[cardIndex] = this.transform:Find('Canvas/PokerHandle/Result/SettlementCards/Card'.. cardIndex)
    end

    -- 扑克牌点数信息
    mPokerXNOGameObject = TransformRoot:Find('Canvas/DealPokers/PokerType1').gameObject
    mPokerXNOText1 = TransformRoot:Find('Canvas/DealPokers/PokerType1/ValueText'):GetComponent("Text")
    mPokerXNOGameObject2 = TransformRoot:Find('Canvas/PokerHandle/Result/Image1').gameObject
    mPokerXNOText2 = TransformRoot:Find('Canvas/PokerHandle/Result/PokerNumber1'):GetComponent("Text")

    mPokerZNOGameObject = TransformRoot:Find('Canvas/DealPokers/PokerType2').gameObject
    mPokerZNOText1 = TransformRoot:Find('Canvas/DealPokers/PokerType2/ValueText'):GetComponent("Text")
    mPokerZNOGameObject2 = TransformRoot:Find('Canvas/PokerHandle/Result/Image2').gameObject
    mPokerZNOText2 = TransformRoot:Find('Canvas/PokerHandle/Result/PokerNumber2'):GetComponent("Text")

    mRemainText = TransformRoot:Find('Canvas/RoomInfo/Zhuangshi/PokerCards/RemainText'):GetComponent("Text")

    InitGameRoomPokerCardRelative()
    InitGameRoomBetAndChipRelative()
    InitBJLCutAniNode()
    AddButtonHandlers()

    local DealPokersRoot =TransformRoot:Find('Canvas/DealPokers').gameObject
    GameObjectSetActive(DealPokersRoot, true)
    GameObjectSetActive(SettlementNode.RootNode, false)
end

function Start()
    CS.MatchLoadingUI.Hide()
end

-- UI 开启
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, ResetBJLRoomToRoomState)                        --OK
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoomState, RefreshBJLRoomByRoomStateSwitchTo)

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoleCount, RefreshBJLRoomRoleCount)                      --OK
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.SyncUpdateGold, RefreshBJLMineInfoOfGoldCount)                 --OK

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyBetResult, HandleBJLBetResultEvent)                      --OK
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateBetValue, HandleBJLBetValueChanged)                      --OK
    CS.EventDispatcher.Instance:AddEventListener(CS.Common.Animation.AnimationControl.FrameComplated, HandleBJLAnimationControlFrameComplated)



    if GameData.RoomInfo.CurrentRoom.RoomID ~= 0 then
        ResetBJLRoomToRoomState(GameData.RoomInfo.CurrentRoom.RoomState)
    end
    -- 设置统计区域脚本关联的房间号
    local topTrendScript = this.transform:Find('Canvas/TopArea'):GetComponent("LuaBehaviour").LuaScript
    topTrendScript.ResetRelativeRoomID(GameData.RoomInfo.CurrentRoom.RoomID)

    -- 音效祝你好运
    BJLPlaySoundEffect('45')
    MusicMgr:PlayBackMusic("BG_LHT")
end

-- UI 关闭
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, ResetBJLRoomToRoomState)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoomState, RefreshBJLRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoleCount, RefreshBJLRoomRoleCount)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.SyncUpdateGold, RefreshBJLMineInfoOfGoldCount)

    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyBetResult, HandleBJLBetResultEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateBetValue, HandleBJLBetValueChanged)

    CS.EventDispatcher.Instance:RemoveEventListener(CS.Common.Animation.AnimationControl.FrameComplated, HandleBJLAnimationControlFrameComplated)


    -- UI 关闭时 停掉所有的音效并停止挂起的携程
    MusicMgr:StopAllSoundEffect()
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    local tempObj = CS.WindowManager.Instance:FindWindowNodeByName("UIRoomPlayers")
    if tempObj ~= nil then
        CS.WindowManager.Instance:CloseWindow("UIRoomPlayers", false)
    end
end

-- 每一帧更新
function Update()
    GameData.ReduceRoomCountDownValue(Time.deltaTime)
    UpdateBetCountDown_BJL()
end

function OnDestroy()
    lua_Call_GC()
end

--=============================UI 系统接口 End  ===============================
