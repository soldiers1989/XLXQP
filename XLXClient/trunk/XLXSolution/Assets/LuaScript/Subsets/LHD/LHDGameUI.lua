local Time = CS.UnityEngine.Time
local BetCountDownKey = "BetCountdown"
local isUpdateBetCountDown = false
local m_BetLimitTime = 3                -- 下注倒计时限制时间
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

local BankerListShowTime = 5					-- 庄家列表显示时间
local BankerListShowPassTime = 0				-- 庄家列表显示时间流逝

-- 庄家UI节点信息
local BankerNode = 
{
    NameText = nil,             -- 庄家Name Text    
    GoldText = nil,             -- 庄家金币 Text
    HeadIcon = nil,             -- 庄家头像 Image
    LeftRoundText = nil,        -- 庄家剩余局数
    UpBankerBtn = nil,          -- 上庄按钮
    DownBankerBtn = nil,        -- 下庄按钮

    BankerListGameObject = nil, -- 庄家列表
    BankerListUpArrow = nil,    -- 庄家列表标记1
    BankerListDownArrow = nil,  -- 庄家列表标记2
}

local mRoleCountText = nil      -- 房间在线人数
-- 玩家信息
local RoleNameText = nil
local RoleGoldText = nil
local RoleChangeGold = nil
-- 荷官泡泡信息
local DealerPaoPaoGameObject = nil
local DealerPaoPaoText = nil
local DealerPaoPaoImage = nil
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

---------_________TUDOU_________---------

local button_Help = nil;
local button_Help_Close = nil;
local mask_Help = nil;
local window_Help = nil;
function DoHelp()
    window_Help = this.transform:Find("Canvas/Window_Help");
    button_Help = this.transform:Find("Canvas/RoomInfo/ButtonHelp");
    button_Help_Close = this.transform:Find("Canvas/Window_Help/Title/Button_Close");
    mask_Help = this.transform:Find("Canvas/Mask_Help");
    button_Help:GetComponent("Button").onClick:AddListener(Window_Help_Open);
    button_Help_Close:GetComponent("Button").onClick:AddListener(Window_Help_Close);
    mask_Help:GetComponent("Button").onClick:AddListener(Window_Help_Close);
end


--打开帮助页面
function Window_Help_Open()
    window_Help.gameObject:SetActive(true);
    mask_Help.gameObject:SetActive(true);
end

function Window_Help_Close()
    window_Help.gameObject:SetActive(false);
    mask_Help.gameObject:SetActive(false);
end

--关闭帮助页面

---------_________TUDOU_________---------

-- 按钮事件响应绑定             --OK
function AddButtonHandlers()
    this.transform:Find('Canvas/RoomInfo/ButtonExitRoom'):GetComponent("Button").onClick:AddListener(ExitRoomButtonOnClick)
    this.transform:Find('Canvas/RoomInfo/Banker/BankerList'):GetComponent("Button").onClick:AddListener(BankerListButtonOnClick)
    this.transform:Find('Canvas/RoomInfo/Banker/BankerList/List/back02'):GetComponent("Button").onClick:AddListener(BankerListButtonOnClick)
    this.transform:Find('Canvas/RoomInfo/Banker/ButtonUpBanker'):GetComponent("Button").onClick:AddListener(UpBankerButtonOnClick)
    this.transform:Find('Canvas/RoomInfo/Banker/ButtonDownBanker'):GetComponent("Button").onClick:AddListener(DownBankerButtonOnClick)
    this.transform:Find('Canvas/RoomInfo/RoleCount'):GetComponent("Button").onClick:AddListener(LHDRoleCountBtnOnClick)
    -- this.transform:Find('Canvas/RoomInfo/ButtonHelp'):GetComponent("Button").onClick:AddListener(LHDButtonHelpOnClick)
    this.transform:Find('Canvas/RoomInfo/StoreButton'):GetComponent("Button").onClick:AddListener(StoreButtonOnClick)
    this.transform:Find('Canvas/RoomInfo/RankButton'):GetComponent("Button").onClick:AddListener(RankButtonOnClick)

    AddBetRelativeHandlers()
end

-- 押注区 筹码选择区 事件响应绑定   --OK
function AddBetRelativeHandlers()
    -- 押注区域
    for buttonIndex = 1, 3, 1 do
        this.transform:Find('Canvas/BetChipHandle/BetArea/Area' .. buttonIndex):GetComponent("Button").onClick:AddListener( function() BetAreaButtonOnClick(buttonIndex) end)
    end

    -- 筹码选择
    for index = 1, 10, 1 do
        this.transform:Find('Canvas/BetChipHandle/Chips/Viewport/Content/Chip' .. index):GetComponent("Toggle").onValueChanged:AddListener( function(isOn) ChipValueOnValueChanged(isOn, CHIP_VALUE[index]) end)
    end
end

--=============================游戏流程处理 BEGIN==============================


-- 重置游戏房间到指定的游戏状态     --OK
function ResetLHDRoomToRoomState(currentState)
    canPlaySoundEffect = false
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    InitRoomBaseInfos()
    -- 重置庄家信息
    RefreshLHDBankerInfo(1)
    RefreshLHDRoomRoleCount(GameData.RoomInfo.CurrentRoom.RoleCount)
    RefreshExitRoomButtonState(true)
    RefreshGameRoomToEnterGameState(currentState, true)
    canPlaySoundEffect = true
end

-- 刷新游戏房间进入到指定房间状态   --OK
function RefreshLHDRoomByRoomStateSwitchTo(roomState)
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
    roomLimit:Find('Item1/Value'):GetComponent("Text").text = lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetLongHuMin) .. "-" .. lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetLongHuMax)
    roomLimit:Find('Item2/Value'):GetComponent("Text").text = lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetHeMin)
    roomLimit:Find('Item3/Value'):GetComponent("Text").text = lua_NumberToStyle1String(GameData.RoomInfo.CurrentRoom.BetHeMax)
end

-- 设置房间筹码定位点       -OK
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
    for index = 1, 3, 1 do
        betAreaRoot:Find('Area' .. index .. '/Rate'):GetComponent("Text").text = "1:" .. LHD_COMPENSATE[index]
    end
end

-- 初始化游戏房间的扑克牌相关   --OK
function InitGameRoomPokerCardRelative()
    m_PokerCardsRoot = this.transform:Find('Canvas/DealPokers/Cards')
    for cardIndex = 1, 2, 1 do
        POKER_CARDS[cardIndex] = m_PokerCardsRoot:Find('Card' .. cardIndex)
    end

    -- 初始化发牌收牌节点(开始节点，中间节点，结束节点,发牌节点)
    local dealPokerJoints = this.transform:Find('Canvas/DealPokers/Points')

    POKER_JOINTS[0] = dealPokerJoints:Find('StartPoint')
    POKER_JOINTS[98] = dealPokerJoints:Find('MiddlePoint')
    POKER_JOINTS[99] = dealPokerJoints:Find('EndPoint')
    for index = 1, 2, 1 do
        POKER_JOINTS[index] = dealPokerJoints:Find('Poker' .. index)
    end
    -- 荷官泡泡
    GameObjectSetActive(DealerPaoPaoGameObject, false)
end

-- 初始化房间的押注和筹码相关   --OK
function InitGameRoomBetAndChipRelative()
    -- 初始化筹码挂节点
    local chipsJointRoot = this.transform:Find('Canvas/BetChipHandle/ChipJoints')
    for index = 1, 3, 1 do
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

-- 刷新房间内人数       --OK
function RefreshLHDRoomRoleCount(roleCount)
    mRoleCountText.text = tostring(roleCount)
end

-- 设置角色名称         --OK
function InitRoomBaseInfoOfMineInfo()
    RoleNameText.text = GameData.RoleInfo.IPLocation
    ResetMineInfoOfGoldCount(nil, true)
end

-- 刷新我的金币数量     --OK
function RefreshLHDMineInfoOfGoldCount(arg)
    ResetMineInfoOfGoldCount(arg, false)
end

-- 刷新我的金币数量接口 --OK
function ResetMineInfoOfGoldCount(arg, isInit)

    local displayCount  = GameData.RoleInfo.DisplayGoldCount
    local ceachCount = GameData.RoleInfo.Cache.ChangedGoldCount
    RoleGoldText.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(displayCount),2))
    -- 玩家本局赢钱处理
    RoleGoldText.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(displayCount),2))
    if ceachCount ~= 0 then
        local ceachString = lua_CommaSeperate(GameConfig.GetFormatColdNumber(ceachCount))
        if ceachCount > 0 then
            ceachString = "+" .. ceachString
            -- 大于0 才播放
            LHDPlaySoundEffect('game_win')
        end
        RoleChangeGold:GetComponent('Text').text = ceachString
        local tweenPosition = RoleChangeGold:GetComponent('TweenPosition')
        tweenPosition:ResetToBeginning()
        tweenPosition.gameObject:SetActive(true)
        tweenPosition:Play(true)
        this:DelayInvoke(tweenPosition.duration, function() tweenPosition.gameObject:SetActive(false) end)
    else
        GameObjectSetActive(RoleChangeGold.gameObject,false)
    end
    
    -- 在押注状态且非重新进入的情况下，刷新下筹码状态
    if GameData.RoomInfo.CurrentRoom.RoomState == LHD_ROOM_STATE.BET and isInit == false then
        LHDResetChipsInteractable(false)
    end
end

---------------------------------------------------------------------------

-- 离开房间按钮             --OK
function ExitRoomButtonOnClick()
    -- 如果是庄家不能离开房间
    if not isUpdateExitRoomCountDown then
        if GameData.RoomInfo.CurrentRoom.BankerInfo.ID == GameData.RoleInfo.AccountID then
            return
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
                return
            end
        end
    end
    NetMsgHandler.Send_CS_LHD_Exit_Room()
end

-- 刷新推出房间按钮状态     -OK
function RefreshExitRoomButtonState(force)
    if isUpdateExitRoomCountDown then
        -- 如果退出房间阶段
        ResetExitRoomStateValue(true, force)
    elseif GameData.RoomInfo.CurrentRoom.BankerInfo.ID == GameData.RoleInfo.AccountID then
        -- 如果是庄家不能离开房间
        ResetExitRoomStateValue(false, force)
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
function LHDRoleCountBtnOnClick()
    -- body
    local initParam = CS.WindowNodeInitParam("UIRoomPlayers")
    initParam.WindowData = 2
    CS.WindowManager.Instance:OpenWindow(initParam)
end

-- 商城按钮                 --OK
function StoreButtonOnClick()
    GameConfig.OpenStoreUI()
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.LhdRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.LhdRankTime >= 60 then
        return true
    end
    return false
end

-- 响应排行榜按钮点击事件   --OK
function RankButtonOnClick()
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = 10
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(10) == true then
        NetMsgHandler.SendRequestRanks(10)
    end
end

--===========================上庄列表相关功能 Start============================

-- 刷新庄家信息         --OK
function RefreshLHDBankerInfo(arg)
    if arg == 1 then
        local bankerInfo = GameData.RoomInfo.CurrentRoom.BankerInfo
        BankerNode.NameText.text = bankerInfo.strLoginIP
        BankerNode.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(bankerInfo.HeadIcon))
        BankerNode.GoldText.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(bankerInfo.Gold))
        BankerNode.LeftRoundText.text = tostring(bankerInfo.LeftCount)
        -- 刷新下离开房间按钮状态
        RefreshExitRoomButtonState(false)
        RefreshBankerButtonState()
    end
end

-- 上庄列表信息按钮call --OK
function BankerListButtonOnClick()
    if BankerNode.BankerListGameObject.activeSelf then
        GameObjectSetActive(BankerNode.BankerListGameObject, false)
        GameObjectSetActive(BankerNode.BankerListUpArrow, false)
        GameObjectSetActive(BankerNode.BankerListDownArrow, true)
        BankerListShowPassTime = 0
    else
        GameObjectSetActive(BankerNode.BankerListGameObject, true)
        GameObjectSetActive(BankerNode.BankerListUpArrow, true)
        GameObjectSetActive(BankerNode.BankerListDownArrow, false)

        NetMsgHandler.Send_CS_LHD_Up_Banker_List()
        RefreshLHDCandidateBankerList(nil)
        BankerListShowPassTime = BankerListShowTime
    end
end

-- 上庄按钮响应 --OK
function UpBankerButtonOnClick()
    NetMsgHandler.Send_CS_LHD_Up_Banker()
end

-- 下庄按钮响应 --OK
function DownBankerButtonOnClick()
    if GameData.RoleInfo.AccountID == GameData.RoomInfo.CurrentRoom.BankerInfo.ID then
        local boxData = CS.MessageBoxData()
        boxData.Title = "提示"
        boxData.Content = data.GetString("Down_Banker_Tips")
        boxData.Style = 2
        boxData.OKButtonName = "放弃"
        boxData.CancelButtonName = "确定"
        boxData.LuaCallBack = LHDDownBankerMessageBoxCallBack
        
        CS.MessageBoxUI.Show(boxData)
    end
end

function LHDDownBankerMessageBoxCallBack(result)
    if result == 2 then
        -- 取消和确定位置反向了的
        if GameData.RoleInfo.AccountID == GameData.RoomInfo.CurrentRoom.BankerInfo.ID then
            NetMsgHandler.Send_CS_LHD_Down_Banker()
        end
    end
end

-- 刷新上庄和下庄按钮状态 --OK
function RefreshBankerButtonState()
    if GameData.RoleInfo.AccountID == GameData.RoomInfo.CurrentRoom.BankerInfo.ID then
        GameObjectSetActive(BankerNode.UpBankerBtn, false)
        GameObjectSetActive(BankerNode.DownBankerBtn, true)
    else
        GameObjectSetActive(BankerNode.UpBankerBtn, true)
        GameObjectSetActive(BankerNode.DownBankerBtn, false)
    end
end

-- 刷新候选庄家列表 --OK
function RefreshLHDCandidateBankerList(arg)
    local listTransform = BankerNode.BankerListGameObject.transform
    for index = 1, 5, 1 do
        local bankerInfo = GameData.RoomInfo.CurrentRoom.BankerList[index]
        if bankerInfo ~= nil then
            listTransform:Find("Item" .. index).gameObject:SetActive(true)
            listTransform:Find("Item" .. index .. "/VipLevel"):GetComponent("Text").text = "V" .. tostring(bankerInfo.VipLevel)
            if bankerInfo.ID == GameData.RoleInfo.AccountID then
                listTransform:Find("Item" .. index .. "/Name"):GetComponent("Text").text = string.format("<color=#F7DE1F>%s</color>", bankerInfo.strLoginIP)
                listTransform:Find("Item" .. index .. "/Gold"):GetComponent("Text").text = string.format("<color=#F7DE1F>%s</color>", lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(bankerInfo.GoldCount)))
            else
                listTransform:Find("Item" .. index .. "/Name"):GetComponent("Text").text = string.format("<color=#E8D7C6>%s</color>", bankerInfo.strLoginIP)
                listTransform:Find("Item" .. index .. "/Gold"):GetComponent("Text").text = string.format("<color=#E8D7C6>%s</color>", lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(bankerInfo.GoldCount)))
            end
        else
            listTransform:Find("Item" .. index).gameObject:SetActive(false)
        end
    end
end

-- 庄家列表自动隐藏 --OK
function AutoRefreshBankerListHide()
    -- body
    local deltaTime = CS.UnityEngine.Time.deltaTime
    if BankerListShowPassTime > 0 then
        BankerListShowPassTime = BankerListShowPassTime - deltaTime
        if BankerListShowPassTime < 0 then
            if true == BankerNode.BankerListGameObject.activeSelf then
                BankerNode.BankerListGameObject:SetActive(false)
            end
            BankerListShowPassTime = 0
        end
    end
end

-- 荷官泡泡Tips         --OK
function DealerPlayPaoPaoTips(roomState, isInit)
    -- body
    if true == isInit then
        return
    end
    if roomState ~= LHD_ROOM_STATE.SHUFFLE then
        -- 非洗牌阶段 推出
        return
    end
    if GameData.RoomInfo.CurrentRoom.BankerInfo.ID > SystemBankerID then
        -- 非系统坐庄
        return
    end
    local speakRate = CS.UnityEngine.Random.Range(0, 100)
    if speakRate > data.PublicConfig.DEALER_PAOPAO_RATE then
        return
    end

    local DelaySpeakTime = CS.UnityEngine.Random.Range(5, 15)
    this:DelayInvoke(DelaySpeakTime, function() GameObjectSetActive(DealerPaoPaoGameObject,true) end)
    this:DelayInvoke(DelaySpeakTime + 3.0, function() GameObjectSetActive(DealerPaoPaoGameObject,false) end)
    local paopaoIndex = math.floor(CS.UnityEngine.Random.Range(1, data.PublicConfig.DEALER_PAOPAO_MAX + 1))
    DealerPaoPaoText.text = data.GetString("Dealer_PaoPao_" .. paopaoIndex)
    local back = DealerPaoPaoImage
    CS.Utility.SetRectTransformWidthHight(back, 72, math.ceil(DealerPaoPaoText.preferredWidth + 32))
end

-- 刷新牌桌上龙虎文字   --OK
function HideOrShowDeskWord(wordIndex, isActive)
    this.transform:Find('Canvas/Back/Text' .. wordIndex).gameObject:SetActive(isActive)
end

--===========================上庄列表相关功能 End  ============================

-- 刷新游戏房间到游戏状态       --OK
function RefreshGameRoomToEnterGameState(roomState, isInit)
    --print("*****龙虎斗房间:", roomState, isInit)
    if isInit or roomState == LHD_ROOM_STATE.WAIT then
        ResetGameRoomForReStart()
        -- 调用下GC回收
        lua_Call_GC()
        this:StopAllDelayInvoke()
        -- 荷官泡泡
        GameObjectSetActive(DealerPaoPaoGameObject, false)
    end
    LHDRefreshShufflePartOfGameRoomByState(roomState, isInit)   -- 洗牌阶段 OK
    LHDRefreshBetAreaPartOfGameRoomByState(roomState, isInit)   -- 下注区域 OK
    LHDRefreshBetCountDownOfGameRoomByState(roomState)          -- 下注CD   OK
    LHDRefreshDealPartOfGameRoomByState(roomState, isInit)      -- 发牌阶段 OK
    LHDRefreshCheckPartOfGameRoomByState(roomState, isInit)     -- 亮牌阶段 Ok
    RefreshSettlementPartOfGameRoomByState(roomState, isInit)   -- 结算阶段 OK

    DealerPlayPaoPaoTips(roomState, isInit)                     --OK
end

-- 重置房间信息到可以重新开局，清理掉桌面上的内容(押注区域，发牌区域，操作扑克牌区域，可能的延迟动画等) --OK
function ResetGameRoomForReStart()
    ResetBetChipsAndAreaToRestart()
    LHDResetPokerCardToRestart()
    LHDResetSettlementToRestart()
    -- 刷新牌桌上龙虎文字
    HideOrShowDeskWord(1, true)
    HideOrShowDeskWord(2, true)
end

-- 重置押注区域信息 --OK
function ResetBetChipsAndAreaToRestart()
    -- 清理掉筹码节点下的所有筹码
    for areaType = 1, 3, 1 do
        lua_Transform_ClearChildren(CHIP_JOINTS[areaType].JointPoint, false)
    end
    -- 关闭掉区域动画
    LHDHandleBetAreaAnimation(3)
end

-- 重置扑克牌相关信息           --OK
function LHDResetPokerCardToRestart()
    for index = 1, 2, 1 do
        local pokerCardItem = POKER_CARDS[index]
        -- 清理掉所有的UITweener(界面动画脚本)
        lua_Clear_AllUITweener(pokerCardItem)
        lua_Paste_Transform_Value(pokerCardItem, POKER_JOINTS[0])
        pokerCardItem.gameObject:SetActive(false)
        LHDSetTablePokerCardVisible(pokerCardItem, false)
    end
end

-- 重置结算区域相关信息     --OK
function LHDResetSettlementToRestart()
    GameObjectSetActive(SettlementNode.RootNode, false)
    for index = 1, 2, 1 do
        SettlementNode.Cards[index]:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardBackSpriteName())
        SettlementNode.Cards[index].gameObject:SetActive(false)
    end
    SettlementNode.SealImage.gameObject:SetActive(false)
end

--=============================================================================
--=================[洗牌阶段] [LHD_ROOM_STATE.SHUFFLE] [2]=====================

function LHDRefreshShufflePartOfGameRoomByState(roomState, isInit)
    if roomState == LHD_ROOM_STATE.SHUFFLE then
        if not isInit then
            GameObjectSetActive(ShuffleAniGameObject, true)
            CS.Common.Animation.AnimationControl.PlayAnimation("ShuffleAnimation", 0, true)
            -- 音效洗牌音效
            LHDPlaySoundEffect('10')

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
--=================[发牌阶段] [LHD_ROOM_STATE.DEAL] [3]==========================
-- 扑克牌发牌相关内容       --OK
function LHDRefreshDealPartOfGameRoomByState(roomState, isInit)

    if isInit then
        LHDResetPokerCardToRestart()
        if roomState >= LHD_ROOM_STATE.DEAL then
            HandleDealPokerCardToCardTable(roomState >= LHD_ROOM_STATE.CHECK)
        end
    else
        if roomState == LHD_ROOM_STATE.DEAL then
            LHDResetPokerCardToRestart()
            HandleDealPokerCardToCardTable(false)
        end
    end
end

-- 扑克牌发送到牌桌上           --OK
function HandleDealPokerCardToCardTable(isNoAnimation)
    local stateTotalLastTime = data.PublicConfig.LHD_ROOM_TIME[LHD_ROOM_STATE.DEAL]
    local elapseTime = stateTotalLastTime - GameData.RoomInfo.CurrentRoom.CountDown

    if isNoAnimation then
        elapseTime = stateTotalLastTime
    end
    m_PokerCardsRoot:GetComponent("AnimationControl"):Play(elapseTime, true)
end

-- 发牌动画结束Event 对应每一张牌翻发到桌面     --OK
function HandleLHDAnimationControlFrameComplated(args)
    if args ~= nil then
        local params = lua_string_split(args, "##")
        local eventType = params[1]
        if eventType == "DealComplated" then
            local cardIndex = tonumber(params[2])
            local cardItem = POKER_CARDS[cardIndex]
            local pokerCard = GameData.RoomInfo.CurrentRoom.Pokers[cardIndex]
            if pokerCard ~= nil then
                print("*****发牌完毕:",cardIndex, pokerCard.Visible)
                LHDSetTablePokerCardVisible(cardItem, pokerCard.Visible)
            end
        end
        if eventType == "DealStart" then
            local cardIndex = tonumber(params[2])
            LHDPlaySoundEffect('3')
        end
    end
end

-- 设置玩家扑克牌是否可见           --OK
function LHDSetTablePokerCardVisible(pokerCard, isVisible)
    pokerCard:Find('back').gameObject:SetActive(lua_NOT_BOLEAN(isVisible))
    if isVisible then
        LHDPlaySoundEffect('4')
    end
end

--=============================================================================
--=================[下注阶段][LHD_ROOM_STATE.BET] [4]=========================

-- 刷新押注区域相关的内容       --OK
function LHDRefreshBetAreaPartOfGameRoomByState(roomState, isInit)
    if isInit then
        if roomState >= LHD_ROOM_STATE.BET then
            if roomState < LHD_ROOM_STATE.SETTLEMENT then
                LHDResetBetChipsAlreadyOnTable(GameData.RoomInfo.CurrentRoomChips)
            end
            HandleLHDBetValueChanged(3)
        end
        -- 初始状态的时候，筹码都设置成为不可用
        LHDResetChipsInteractable(true)
    end

    if roomState == LHD_ROOM_STATE.BET then
        -- 押注开始动画
        LHDResetChipsInteractable(false)

        local tBetTime = data.PublicConfig.LHD_ROOM_TIME[LHD_ROOM_STATE.BET]

        if GameData.RoomInfo.CurrentRoom.CountDown >(tBetTime -2) then
            LHDHandleBetAreaAnimation(1)
            this:DelayInvoke(1.7,
            function()
                LHDHandleBetAreaAnimation(3)
            end )
        end
    else
        -- 非下注阶段均不能使用下注
        LHDResetChipsInteractable(true)
    end
    LHDRefreshBetPartActive(roomState)
end

function LHDRefreshBetPartActive(roomState)
    local tChipsRoot = this.transform:Find('Canvas/BetChipHandle/Chips').gameObject
    local tChipsActive = true
    if roomState >= LHD_ROOM_STATE.BET then
        if GameData.RoomInfo.CurrentRoom.BankerInfo.ID ~= GameData.RoleInfo.AccountID then
            tChipsActive = true
        else
            tChipsActive = false
        end
    else
        if GameData.RoomInfo.CurrentRoom.BankerInfo.ID ~= GameData.RoleInfo.AccountID then
            tChipsActive = true
        else
            tChipsActive = false
        end
    end
    GameObjectSetActive(tChipsRoot, tChipsActive)
end

-- 刷新押注阶段CD           --OK
function LHDRefreshBetCountDownOfGameRoomByState(roomState)
    if roomState == LHD_ROOM_STATE.BET then
        local countDown = GameData.RoomInfo.CurrentRoom.CountDown
        -- 开局2秒内进入房间提示已开局，请下注
        local tBetTime = data.PublicConfig.LHD_ROOM_TIME[LHD_ROOM_STATE.BET]
        if tBetTime - countDown < 2 then
            CS.BubblePrompt.Show(data.GetString("Tip_Start_Bet"), "LHDGameUI")
            -- 音效:已开局请下注
            LHDPlaySoundEffect('35')
        end
        if countDown > 3 then
            isUpdateBetCountDown = true
            GameObjectSetActive(BetCountDownGameObject, true)
        else
            GameObjectSetActive(BetCountDownGameObject, false)
        end
    else
        GameObjectSetActive(BetCountDownGameObject, false)
    end
end

-- 更新押注倒计时       --OK
function UpdateBetCountDown()
    if isUpdateBetCountDown == true then
        local countDown = GameData.RoomInfo.CurrentRoom.CountDown
        if countDown < m_BetLimitTime then
            GameObjectSetActive(BetCountDownGameObject, false)
            isUpdateBetCountDown = false
            if LHD_ROOM_STATE.BET == GameData.RoomInfo.CurrentRoom.RoomState and countDown > m_BetLimitTime - 0.5 then
                -- 停止下注提示
                if countDown > 0.3 then
                    CS.BubblePrompt.Show(data.GetString("Tip_Stop_Bet"), "LHDGameUI")
                end
                -- 音效:停止下注
                LHDPlaySoundEffect('36')
                -- 音效:是否下注提示
                local betValue = GameData.RoomInfo.CurrentRoom.BetValues
                local isPlay = true
                for k, v in pairs(betValue) do
                    if nil ~= v and v > 0 then
                        isPlay = false
                        break
                    end
                end

                -- 自己是庄家不需要提示未下注
                if GameData.RoomInfo.CurrentRoom.BankerInfo.ID == GameData.RoleInfo.AccountID then
                    isPlay = false
                end

                if true == isPlay then
                    this:DelayInvoke(1.2, function() LHDPlaySoundEffect('37') end)
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
        this:DelayInvoke(i - 1, function() LHDPlaySoundEffect('8') end)
    end
    if count > 1 then
        this:DelayInvoke(count - 1, function() LHDPlaySoundEffect('9') end)
    end
end

------------------------------------------------------------
-------------------[筹码 1] 可否使用相关-----------------------

-- [筹码 1] 刷新筹码可否使用状态         --OK
function LHDResetChipsInteractable(forceInteractableFalse)
    local roleGold = GameData.RoleInfo.GoldCount

    local selectChipRoot = this.transform:Find('Canvas/BetChipHandle/Chips/Viewport/Content')
    for index = 1, 10, 1 do
        local chipItem = selectChipRoot:Find('Chip' .. index):GetComponent("Toggle")
        if forceInteractableFalse then
            LHDRefreshChipInteractable(chipItem, false)
        else
            local chipValue = CHIP_VALUE[index]
            if not LHDIsChipCanBeUsedInCurrentRoom(index) or roleGold < chipValue then
                LHDRefreshChipInteractable(chipItem, false)
            else
                LHDRefreshChipInteractable(chipItem, true)
            end
        end
    end
end

-- [筹码 1] 筹码选项 可否使用设置        --OK
function LHDRefreshChipInteractable(chipItem, interactable)
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
function LHDIsChipCanBeUsedInCurrentRoom(chipIndex)
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
function LHDHandleBetAreaAnimation(aniType)
    local betAreaRoot = this.transform:Find('Canvas/BetChipHandle/BetArea')
    if aniType == 1 then
        for index = 1, 3, 1 do
            -- 打开线条灯光
            local areaAni = betAreaRoot:Find('Area' .. index .. '/LineLight')
            areaAni.gameObject:SetActive(true)
            areaAni:GetComponent("TweenAlpha"):ResetToBeginning()
            areaAni:GetComponent("TweenAlpha"):Play(true)
        end
    elseif aniType == 2 then
        local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
        for index = 1, 3, 1 do
            -- 打开区域灯光
            local areaAni = betAreaRoot:Find('Area' .. index .. '/AreaLight')
            if CS.Utility.GetLogicAndValue(gameResult, LHD_AREA_WIN_CODE[index]) == LHD_AREA_WIN_CODE[index] then
                -- 只有赢得区域闪烁
                areaAni.gameObject:SetActive(true)
                areaAni:GetComponent("TweenAlpha"):ResetToBeginning()
                areaAni:GetComponent("TweenAlpha"):Play(true)
            else
                areaAni.gameObject:SetActive(false)
            end
        end
    else
        for index = 1, 3, 1 do
            -- 关闭区域灯光
            betAreaRoot:Find('Area' .. index .. '/AreaLight').gameObject:SetActive(false)
            -- 关闭线条灯光
            betAreaRoot:Find('Area' .. index .. '/LineLight').gameObject:SetActive(false)
        end
    end
end

-- 设置押注区域值  1他人下注 2 自己下注 3房间初始化 nil 清理数据      --OK
function HandleLHDBetValueChanged(arg)
    if arg ~= 1 then
        for index = 1, 3, 1 do
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
    for index = 1, 3, 1 do
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

--=================CS_LHD_Bet  1259---------------------------------
-- 押注区域被点击了             --OK
function BetAreaButtonOnClick(areaType)
    -- 发送押注信息, 非押注阶段不可押注, 押注倒计时期间
    if isUpdateBetCountDown then
        if GameData.RoomInfo.CurrentRoom.RoomState == LHD_ROOM_STATE.BET then
            -- 如果是庄家，直接返回
            if GameData.RoleInfo.AccountID == GameData.RoomInfo.CurrentRoom.BankerInfo.ID then
                return
            end

            if GameData.RoomInfo.CurrentRoom.SelectBetValue > 0 then
                NetMsgHandler.Send_CS_LHD_Bet(areaType, GameData.RoomInfo.CurrentRoom.SelectBetValue)
            else
                CS.BubblePrompt.Show("请选择筹码", "LHDGameUI")
            end
        end
    end
end

-- 下注结果处理         --OK
function HandleLHDBetResultEvent(eventArgs)
    if eventArgs.ResultType == 0 then
        BetChipToDesk(eventArgs.AreaType, eventArgs.BetValue, eventArgs.RoleID)
    else
        local betAreaItem = this.transform:Find('Canvas/BetChipHandle/BetArea/Area' .. eventArgs.AreaType)
        if betAreaItem ~= nil then
            betAreaItem:GetComponent("SwitchAnimation"):Play(1)
        end
        if eventArgs.ResultType == 8 or eventArgs.ResultType == 9 or eventArgs.ResultType == 11 then
            CS.BubblePrompt.Show(string.format(data.GetString("T_1259_"..eventArgs.ResultType),lua_NumberToStyle1String(eventArgs.ErrorValue)),"LHDGameUI")
        else
            CS.BubblePrompt.Show(data.GetString("T_1259_" .. eventArgs.ResultType), "LHDGameUI")
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
    LHDCastChipToBetArea(areaType, betValue, tostring(roleID), true, startPoint.JointPoint.position)
    -- 押注筹码音效
    LHDPlaySoundEffect('5')
end

--=================重置已经在桌面上的筹码       --OK
function LHDResetBetChipsAlreadyOnTable(currentRoomChips)
    -- 遍历 押注区域
    for areaType = 1, 3, 1 do
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
                            LHDCastChipToBetArea(areaType, CHIP_VALUE[chipIndex], chipName, false, nil)
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
function LHDCastChipToBetArea(areaType, chipValue, chipName, isAnimation, fromWorldPoint)
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
--=================[亮牌阶段][LHD_ROOM_STATE.CHECK] [5]=========================
-- 亮牌阶段处理相关             --OK
function LHDRefreshCheckPartOfGameRoomByState(roomState, isInit)

    if isInit then
        if roomState >= LHD_ROOM_STATE.CHECK then
            LHDRefreshPokerCardSpriteOfTable()
            LHDRefreshPokerCardVisible(false)
        end
    else
        if roomState == LHD_ROOM_STATE.CHECK then
            -- 亮牌
            LHDRefreshPokerCardSpriteOfTable()
            LHDRefreshPokerCardVisible(true)
        end
    end
end

-- 设置牌桌上的扑克牌点数Sprite     --OK
function LHDRefreshPokerCardSpriteOfTable()
    for pokerIndex = 1, 2, 1 do
        local pokerCard = GameData.RoomInfo.CurrentRoom.Pokers[pokerIndex]
        POKER_CARDS[pokerIndex]:GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardSpriteName(pokerCard))
    end
end

-- 刷新统计区域的扑克牌信息         --OK
function RefreshSettlementPartOfPokerCard(pokerIndex)
    local pokerCard = GameData.RoomInfo.CurrentRoom.Pokers[pokerIndex]
    local cardItem = SettlementNode.Cards[pokerIndex]
    local cardSpriteName = GameData.GetPokerDisplaySpriteName(pokerCard)
    cardItem:GetComponent("Image"):ResetSpriteByName(cardSpriteName)
    cardItem.gameObject:SetActive(true)
end

-- 亮牌操作                         --OK
function LHDRefreshPokerCardVisible(isAni)
    print("*****亮牌阶段操作:", isAni)
    local cardItem1 = POKER_CARDS[1]
    local cardItem2 = POKER_CARDS[2]
    local pokerCard1 = GameData.RoomInfo.CurrentRoom.Pokers[1]
    local pokerCard2 = GameData.RoomInfo.CurrentRoom.Pokers[2]

    if isAni then
        this:DelayInvoke(0.5, function () 
            LHDSetTablePokerCardVisible(cardItem1, true) 
            RefreshSettlementPartOfPokerCard(1)
        end)
        this:DelayInvoke(1.5, function () 
            LHDSetTablePokerCardVisible(cardItem2, true)
            RefreshSettlementPartOfPokerCard(2)
        end)
    else
        LHDSetTablePokerCardVisible(cardItem1, true)
        LHDSetTablePokerCardVisible(cardItem2, true)
        RefreshSettlementPartOfPokerCard(1)
        RefreshSettlementPartOfPokerCard(2)
    end
end

--=============================================================================
--=================[结算阶段][LHD_ROOM_STATE.SETTLEMENT] [6]====================
-- 结算阶段 相关处理    --OK
function RefreshSettlementPartOfGameRoomByState(roomState, isInit)
    GameObjectSetActive(SettlementNode.RootNode, roomState >= LHD_ROOM_STATE.CHECK)
    if roomState == LHD_ROOM_STATE.SETTLEMENT then
        SettlementNode.SealImage:ResetSpriteByName(LHDGetSealIconNameByGameResult(GameData.RoomInfo.CurrentRoom.GameResult))
        SettlementAllAnimations(isInit)
    end
end

-- 结果类型Image                --OK
function LHDGetSealIconNameByGameResult(gameResult)
    if CS.Utility.GetLogicAndValue(gameResult, LHD_WIN_CODE.LONG) == LHD_WIN_CODE.LONG then
        return 'sprite_Seal_1'
    elseif CS.Utility.GetLogicAndValue(gameResult, LHD_WIN_CODE.HU) == LHD_WIN_CODE.HU then
        return 'sprite_Seal_2'
    elseif CS.Utility.GetLogicAndValue(gameResult, LHD_WIN_CODE.HE) == LHD_WIN_CODE.HE then
        return 'sprite_Seal_4'
    else
        return 'sprite_Seal_4'
    end
end

-- 结算阶段动画处理         --OK
function SettlementAllAnimations(isInit)
    -- 开始收筹码
    if not isInit then
        -- 龙 牌型
        LHDPlaySoundEffect('LHD_p_long')
        this:DelayInvoke(0.5, function () LHDPlayBrandTypeAudio(LHDPokerType(1)) end)
        -- 虎 牌型
        this:DelayInvoke(1.5, function () LHDPlaySoundEffect('LHD_p_hu') end)
        this:DelayInvoke(2.0, function () LHDPlayBrandTypeAudio(LHDPokerType(2)) end)
        -- 开始收集筹码
        this:DelayInvoke(3.0, function ()
            LHDCollectChips()
            -- 显示印章
            LHDHandleShowGameResult(true)
        end)
    else
        -- 显示印章
        LHDHandleShowGameResult(false)
    end
end

-- 胜负结果音效+闪烁            --OK
function LHDHandleShowGameResult(isAudio)
    if isAudio then
        -- 胜负结果
        PlayGameWinCodeAudio()
    end
    -- 直接显示印章不播放音效
    ShowGameResultSeal(isAudio)
    -- 押注区域开始闪烁
    LHDHandleBetAreaAnimation(2)
    -- 本局统计追加值
    if GameData.RoomInfo.CurrentRoom.AppendStatisticsEventArgs ~= nil then
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics, GameData.RoomInfo.CurrentRoom.AppendStatisticsEventArgs)
    end
end

-- 牌型获取         --OK
function LHDPokerType(pokerIndex)
    local pokerData = GameData.RoomInfo.CurrentRoom.Pokers[pokerIndex]
    return pokerData.PokerNumber
end

-- 牌型音效
function LHDPlayBrandTypeAudio(pokerType)
    local musicid = "LHD_p_"
    musicid = musicid .. pokerType
    LHDPlaySoundEffect(musicid)
end

-- 胜负结果             --OK
function PlayGameWinCodeAudio()
    local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
    if CS.Utility.GetLogicAndValue(gameResult, LHD_WIN_CODE.LONG) == LHD_WIN_CODE.LONG then
        LHDPlaySoundEffect('LHD_result_1')
    elseif CS.Utility.GetLogicAndValue(gameResult, LHD_WIN_CODE.HU) == LHD_WIN_CODE.HU then
        LHDPlaySoundEffect('LHD_result_2')
    elseif CS.Utility.GetLogicAndValue(gameResult, LHD_WIN_CODE.HE) == LHD_WIN_CODE.HE then
        LHDPlaySoundEffect('LHD_result_4')
    end
end

-- 显示本局结果印章     --OK
function ShowGameResultSeal(isMusic)
    if isMusic == true then
        LHDPlaySoundEffect('6')
    end
    GameObjectSetActive(SettlementNode.SealImage.gameObject, true)
end

--===========================================================================
--=================处理筹码赔付相关============================================

-- [筹码赔付 1]： 开始收集筹码                          --OK
function LHDCollectChips()
    LHDCollectLoseAreaChips()
end

-- [筹码动画 1]: 筹码飞向庄家           --OK
function LHDCollectLoseAreaChips()

    local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
    -- 和局检测
    local isDogfall = CS.Utility.GetLogicAndValue(gameResult, LHD_WIN_CODE.HE) == LHD_WIN_CODE.HE
    local durationTime = 0.5
    local collectMaxArea = 3
    if isDogfall then
        collectMaxArea = 0
    end
    -- 确认筹码目标点
    local endPoint = CHIP_JOINTS[13].JointPoint.position
    if GameData.RoomInfo.CurrentRoom.BankerInfo.ID == GameData.RoleInfo.AccountID then
        endPoint = CHIP_JOINTS[11].JointPoint.position
    end

    local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
    local isPlayed = false
    -- 筹码计数
    local chipCount = 0
    for areaIndex = 1, collectMaxArea, 1 do
        if CS.Utility.GetLogicAndValue(gameResult, LHD_AREA_WIN_CODE[areaIndex]) ~= LHD_AREA_WIN_CODE[areaIndex] then
            -- 筹码飞向庄家
            local chipJoint = CHIP_JOINTS[areaIndex].JointPoint
            local childCount = chipJoint.childCount
            chipCount = chipCount + childCount
            isPlayed = true
            for index = childCount - 1, 0, -1 do
                local chipItem = chipJoint:GetChild(index)
                local script = CS.TweenPosition.Begin(chipItem.gameObject, durationTime, endPoint, true)
                LHDAddRandomDelayForChip(script)
                script:OnFinished('+',( function() LHDHandleAnimationPlayEnd(chipItem) end))
                script:Play(true)
            end
        end
    end
    -- 筹码音效11111
    LHDDelayPlayAudioForChip(chipCount)

    if isPlayed then
        this:DelayInvoke(1.2, LHDBankerThrowChipsToLostArea)
    else
        LHDBankerThrowChipsToLostArea()
    end
end

-- [筹码动画 2]: 庄家筹码飞向桌面       --OK
function LHDBankerThrowChipsToLostArea()

    local durationTime = 0.5
    local roleIDStr = tostring(GameData.RoleInfo.AccountID)
    -- 确认筹码起始点
    local startPoint = CHIP_JOINTS[13].JointPoint.position
    if GameData.RoomInfo.CurrentRoom.BankerInfo.ID == GameData.RoleInfo.AccountID then
        startPoint = CHIP_JOINTS[11].JointPoint.position
    end

    local gameResult = GameData.RoomInfo.CurrentRoom.GameResult
    local isPlayed = false

    -- 筹码计数
    local chipCount = 0
    for areaIndex = 1, 3, 1 do
        if CS.Utility.GetLogicAndValue(gameResult, LHD_AREA_WIN_CODE[areaIndex]) == LHD_AREA_WIN_CODE[areaIndex] then
            local chipArea = CHIP_JOINTS[areaIndex]
            local chipJoint = chipArea.JointPoint
            local childCount = chipJoint.childCount
            local payCount = LHD_COMPENSATE[areaIndex]
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
                    LHDAddRandomDelayForChip(script)
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
                        LHDAddRandomDelayForChip(script)
                        script:Play(true)
                    end
                    areaWinGold = areaWinGold - count * CHIP_VALUE[index]
                end
            end
        end
    end
    -- 筹码音效22222
    LHDDelayPlayAudioForChip(chipCount)
    if isPlayed then
        this:DelayInvoke(1.5, LHDHandleRoleCollectOwnChipAreas)
    else
        LHDHandleRoleCollectOwnChipAreas()
    end
end

-- [筹码动画 3]：玩家收筹码表现（赢得筹码和+ 和局返还龙、虎区域筹码）
function LHDHandleRoleCollectOwnChipAreas()

    HandleLHDBetValueChanged(3)
    LHDHandleSettlementGetGoldShowTip()

    local isPlayed = false
    local roleIDStr = tostring(GameData.RoleInfo.AccountID)
    local durationTime = 0.5
    -- 筹码计数
    local chipCount = 0
    for areaIndex = 1, 3, 1 do
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
                LHDAddRandomDelayForChip(script)
                script:OnFinished('+',( function() LHDHandleAnimationPlayEnd(chipItem) end))
                script:Play(true)
            end
        end
    end
    -- 筹码音效33333
    LHDDelayPlayAudioForChip(chipCount)
    LHDCollectPokerCardsAnimationStepOne()
end

-- 为筹码增加 0- 0.5s 的延迟，让其错乱飞    --OK
function LHDAddRandomDelayForChip(script)
    script.delay = CS.UnityEngine.Random.Range(0, 0.5)
end

-- 为筹码音效增加 0 - 0.3 的延迟,让其感觉音效很多   --OK
function LHDDelayPlayAudioForChip(chipAllCount)
    if chipAllCount > 0 then
        local limitCount = 4
        for i = 1, chipAllCount do
            if i > limitCount then
                break
            end
            local delayTime = CS.UnityEngine.Random.Range(0, 0.3)
            this:DelayInvoke(delayTime, function() LHDPlaySoundEffect('7') end)
        end
    end
end

-- 销毁筹码
function LHDHandleAnimationPlayEnd(chipItem)
    CS.UnityEngine.Object.Destroy(chipItem.gameObject)
end

-- [结算阶段]: 玩家赢钱             --OK
function LHDHandleSettlementGetGoldShowTip()
    GameData.SyncDisplayGoldCount()
end

-- 收牌动画第一段
function LHDCollectPokerCardsAnimationStepOne()
    local movePokerTable = {}
    -- 扑克收集
    for index = 1, 2, 1 do
        local pokerCardItem = POKER_CARDS[index]
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
                    LHDCollectPokerCardsAnimationStepTwo(pokerCard)
                end
            end )
            script:Play(true)
        end
    end
end

-- 收牌动画第二段
function LHDCollectPokerCardsAnimationStepTwo(pokerCard)
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
function LHDPlaySoundEffect(musicid)
    if true == canPlaySoundEffect then
        MusicMgr:PlaySoundEffect(tostring(musicid))
    end
end

--=============================UI 系统接口 Begin===============================

function Awake()
    CS.MatchLoadingUI.Show()
    local BRHallUI = CS.WindowManager.Instance:FindWindowNodeByName("BRHallUI")
    if BRHallUI ~= nil then
        BRHallUI.WindowGameObject:SetActive(false)
    else
        print('*********BRHallUI查找失败，请请检查!')
    end
    local transformRoot = this.transform
    -- 庄家信息解析
    DoHelp();
    local bankerRoot = transformRoot:Find('Canvas/RoomInfo/Banker')
    BankerNode.NameText = bankerRoot:Find('Name'):GetComponent("Text")
    BankerNode.GoldText = bankerRoot:Find('Gold'):GetComponent("Text")
    BankerNode.HeadIcon = bankerRoot:Find('BankerIcon'):GetComponent("Image")
    BankerNode.LeftRoundText = bankerRoot:Find('BankerList/List/LeftRound/Number'):GetComponent("Text")
    BankerNode.UpBankerBtn = bankerRoot:Find('ButtonUpBanker').gameObject
    BankerNode.DownBankerBtn = bankerRoot:Find('ButtonDownBanker').gameObject
    BankerNode.BankerListGameObject = bankerRoot:Find('BankerList/List').gameObject
    BankerNode.BankerListUpArrow = bankerRoot:Find('BankerList/UpArrow').gameObject
    BankerNode.BankerListDownArrow = bankerRoot:Find('BankerList/DownArrow').gameObject
    -- 房间人数
    mRoleCountText = transformRoot:Find('Canvas/RoomInfo/RoleCount/ValueText'):GetComponent("Text")
    -- 玩家信息
    RoleNameText = transformRoot:Find('Canvas/RoleInfo/Name'):GetComponent("Text")
    RoleGoldText = transformRoot:Find('Canvas/RoleInfo/GoldCount'):GetComponent("Text")
    RoleChangeGold = transformRoot:Find('Canvas/RoleInfo/ChangedGold')
    -- 荷官泡泡信息
    DealerPaoPaoGameObject = transformRoot:Find('Canvas/DealerPaoPao').gameObject
    DealerPaoPaoText = transformRoot:Find('Canvas/DealerPaoPao/Text'):GetComponent('Text')
    DealerPaoPaoImage = transformRoot:Find('Canvas/DealerPaoPao/Image')
    -- 房间信息
    RoomIDText = this.transform:Find('Canvas/RoomInfo/RoomID/Value'):GetComponent("Text")
    -- 洗牌动画组件
    ShuffleAniGameObject = this.transform:Find('Canvas/ShuffleAni').gameObject
    ShuffleAni2GameObject = this.transform:Find('Canvas/ShuffleAni2').gameObject
    BetCountDownGameObject = this.transform:Find('Canvas/CountDown').gameObject
    BetCountDownText = this.transform:Find('Canvas/CountDown/ValueText'):GetComponent("Text")

    SettlementNode.RootNode = this.transform:Find('Canvas/PokerHandle/Result').gameObject
    SettlementNode.SealImage = this.transform:Find('Canvas/PokerHandle/Result/Seal'):GetComponent("Image")
    SettlementNode.Cards[1] = this.transform:Find('Canvas/PokerHandle/Result/SettlementCards/Card1')
    SettlementNode.Cards[2] = this.transform:Find('Canvas/PokerHandle/Result/SettlementCards/Card2')

    InitGameRoomPokerCardRelative()
    InitGameRoomBetAndChipRelative()
    AddButtonHandlers()

    GameObjectSetActive(SettlementNode.RootNode, false)
end

function Start()
    CS.MatchLoadingUI.Hide()
end

-- UI 开启
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, ResetLHDRoomToRoomState)                        --OK
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoomState, RefreshLHDRoomByRoomStateSwitchTo)

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateBankerInfo, RefreshLHDBankerInfo)                        --OK
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateRoleCount, RefreshLHDRoomRoleCount)                      --OK
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.SyncUpdateGold, RefreshLHDMineInfoOfGoldCount)                 --OK
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateBankerList, RefreshLHDCandidateBankerList)               --OK

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyBetResult, HandleLHDBetResultEvent)                      --OK
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateBetValue, HandleLHDBetValueChanged)                      --OK
    CS.EventDispatcher.Instance:AddEventListener(CS.Common.Animation.AnimationControl.FrameComplated, HandleLHDAnimationControlFrameComplated)



    if GameData.RoomInfo.CurrentRoom.RoomID ~= 0 then
        ResetLHDRoomToRoomState(GameData.RoomInfo.CurrentRoom.RoomState)
    end
    -- 设置统计区域脚本关联的房间号
    local topTrendScript = this.transform:Find('Canvas/TopArea'):GetComponent("LuaBehaviour").LuaScript
    topTrendScript.ResetRelativeRoomID(GameData.RoomInfo.CurrentRoom.RoomID)

    -- 音效祝你好运
    LHDPlaySoundEffect('45')
    MusicMgr:PlayBackMusic("BG_LHT")
end

-- UI 关闭
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, ResetLHDRoomToRoomState)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoomState, RefreshLHDRoomByRoomStateSwitchTo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateBankerInfo, RefreshLHDBankerInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateRoleCount, RefreshLHDRoomRoleCount)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.SyncUpdateGold, RefreshLHDMineInfoOfGoldCount)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateBankerList, RefreshLHDCandidateBankerList)

    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyBetResult, HandleLHDBetResultEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateBetValue, HandleLHDBetValueChanged)
    CS.EventDispatcher.Instance:RemoveEventListener(CS.Common.Animation.AnimationControl.FrameComplated, HandleLHDAnimationControlFrameComplated)


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
    UpdateBetCountDown()
    AutoRefreshBankerListHide()
end

function OnDestroy()
    lua_Call_GC()
end

--=============================UI 系统接口 End  ===============================
