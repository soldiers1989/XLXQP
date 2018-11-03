
--[[
   文件名称:JHGameMgr.lua
   创 建 人: 
   创建时间：2018.01.23
   功能描述：
]]--

if JHGameMgr == nil then
    JHGameMgr =
    {

    }
end

--==============================--
--desc:初始化金花组局房间数据
--time:2018-01-23 02:13:40
--@roomTypeParam:
--@return 
--==============================--
function JHGameMgr:InitRoomInfoJHWR(roomTypeParam)
    local tNewRoom = JHZuJuRoom:New()
    tNewRoom:Init(true,roomTypeParam)
    GameData.RoomInfo.CurrentRoom = tNewRoom
end

-- 组局厅玩家显示位置转换
function JHGameMgr:PlayerPositionConvert2ShowPosition(tagPositionParam)
    local position = 0
    if tagPositionParam > 0 then
        position =(JHZUJU_ROOM_PLAYER_MAX - GameData.RoomInfo.CurrentRoom.SelfPosition + tagPositionParam - 1) % JHZUJU_ROOM_PLAYER_MAX + 1
    else
        
    end
    return position
end

--==============================--
--desc:获取组局房间信息
--time:2017-11-30 08:12:26
--@indexParam:选择房间Item标识
--@pageParam: 当前第几页
--@onePageParam:一页 多少条目
--@return 
--==============================--
function JHGameMgr:GetJHZUJURoomDataByRoomIndex( indexParam , pageParam, onePageParam)
    -- body
    local _data = nil
    local _count = #GameData.ZJRoomList
    local tagIndex  = (pageParam - 1) * onePageParam + indexParam
    if tagIndex <= _count and tagIndex > 0 then
        -- body
        _data = GameData.ZJRoomList[tagIndex]
    end
    return _data
end

-- ===========================================================================--
-- =============================CS_JH_Create_Room 801=========================--

--==============================--
--desc:请求创建金花组局房间 (底注 下注上限 陌生人加入 游戏模式(经典 激情):1 2 必闷N圈:1 3 入场金币:100 离场金币:20, 房间类型:1,2,3 系统手续费:1% 馆主手续费:4%)
--time:
--@betMinParam:底注
--@betMaxParam:下注上限
--@isLockParam:是否开放陌生人加入
--@roomTypeParam:游戏玩法模式:经典 激情
--@menTimesParam:闷几圈：1 3
--@enterBetParam:入场限制
--@quitBetParam:立场限制
--@isTeaRoom:是否茶馆房间(1 普通房间,2 茶馆房间 3馆主房间)
--@systemCost:系统抽水
--@ownerCost:馆主抽水
--@return 
--==============================--
function NetMsgHandler.Send_CS_JH_Create_Room(betMinParam, betMaxParam, isLockParam, roomTypeParam, menTimesParam, enterBetParam, quitBetParam,isTeaRoom,systemCost,ownerCost)
    -- body
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(betMinParam)
    message:PushUInt32(betMaxParam)
    message:PushByte(isLockParam)
    message:PushByte(roomTypeParam)
    message:PushByte(menTimesParam)
    message:PushUInt32(enterBetParam)
    message:PushUInt32(quitBetParam)
    message:PushByte(isTeaRoom)
    message:PushByte(systemCost)
    message:PushByte(ownerCost)

    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Create_Room, message, true)
end

-- 组局厅请求创建房间反馈
function NetMsgHandler.Received_CS_JH_Create_Room(message)
    -- body
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local ZJRoomID = message:PopUInt32()
        -- 组局厅房间创建成功 马上进入房间
        NetMsgHandler.Send_CS_JH_Enter_Room1(ZJRoomID)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyCreateRoomSuccess, nil)
    else
        CS.BubblePrompt.Show(data.GetString("Create_Room_Error_" .. resultType), "HallUI")
    end
end

-- ===========================================================================--
-- =============================CS_JH_Enter_Room1 802=========================--

-- 组局厅请求进入房间1
function NetMsgHandler.Send_CS_JH_Enter_Room1(roomIDParam)
    -- body
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Enter_Room1, message, false)
end

-- 组局厅请求进入组局房间
function NetMsgHandler.Received_CS_JH_Enter_Room1(message)
    CS.MatchLoadingUI.Hide()
    -- body
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 进入游戏房间
        local tRoomID  = message:PopUInt32()
        GameData.InitCurrentRoomInfo(ROOM_TYPE.ZuJu, tRoomID)
        
        CS.WindowManager.Instance:CloseWindow("UIJoinRoom", false)
    else
        CS.BubblePrompt.Show(data.GetString("ZJ_Enter_Room_Error_" .. resultType), "HallUI")
        NetMsgHandler.ExitRoomToHall(0)
    end
end

-- ===========================================================================--
-- =============================CS_JH_Enter_Room2 803=========================--

-- 组局厅请求进入房间1
function NetMsgHandler.Send_CS_JH_Enter_Room2(roomTypeParam,rooidParam)
    -- body
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(roomTypeParam)
    message:PushUInt32(rooidParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Enter_Room2, message, false)
end

-- 组局厅请求进入闷鸡房间2
function NetMsgHandler.Received_CS_JH_Enter_Room2(message)
    -- body
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRoomID  = message:PopUInt32()
        GameData.InitCurrentRoomInfo(ROOM_TYPE.MenJi, tRoomID)
    else
        CS.MatchLoadingUI.Hide()
        if resultType == 4 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType == 8 then
                local GoldValue = message:PopInt64()
            end
            CS.BubblePrompt.Show(data.GetString("MJ_Enter_Room_Error_" .. resultType), "HallUI")
            NetMsgHandler.ExitRoomToHall(0)
        end
    end
end

-- 进入对战游戏房间
function NetMsgHandler.OpenZUJUGameUI()
    local gameui1Node = CS.WindowManager.Instance:FindWindowNodeByName('GameUI1')
    if gameui1Node == nil then
        local openparam = CS.WindowNodeInitParam("GameUI1")
        openparam.NodeType = 0
        openparam.LoadComplatedCallBack = function(windowNode)
            HandleRefreshHallUIShowState(false)
            --CS.LoadingDataUI.Hide()
        end
        CS.WindowManager.Instance:OpenWindow(openparam)
    else
        CS.MatchLoadingUI.Hide()
        -- TODO  已经处于对战房间
    end
end

-- ============================================================================--
-- =============================S_JH_Set_Game_Data 804=========================--

-- 组局厅反馈房间详细信息
function NetMsgHandler.Received_S_JH_Set_Game_Data(message)
    -- body
    NetMsgHandler.ParseJHRoomBaseInfo(message)
    NetMsgHandler.ParseJHRoomPlayersInfo(message)
    NetMsgHandler.ParseChipBaseInfo(message)
    NetMsgHandler.ParseAllBetInfo(message)
    NetMsgHandler.ParseVSPKInfo(message)
    NetMsgHandler.ParseZUJURoomStateSwitchToSettlement(message)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, GameData.RoomInfo.CurrentRoom.RoomState)
    -- 切换状态为房间
    GameData.GameState = GAME_STATE.ROOM
    NetMsgHandler.OpenZUJUGameUI()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyEnterGameEvent, nil)
end

-- 解析房间基础信息
function NetMsgHandler.ParseJHRoomBaseInfo(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.RoomID = message:PopUInt32()
    tRoomData.MasterID = message:PopUInt32()
    tRoomData.RoomType = message:PopByte()
    tRoomData.SubType = message:PopByte()
    tRoomData.GameMode = message:PopByte()
    tRoomData.MenJiRound = message:PopByte()
    tRoomData.BetMin = message:PopUInt32()
    tRoomData.BetMax = message:PopUInt32()
    tRoomData.RoomState = message:PopByte()
    tRoomData.CountDown = message:PopUInt32() / 1000.0
    tRoomData.SelfPosition = message:PopByte()
    local BankerPosition = message:PopByte()
    local BetAllValue = message:PopInt64()
    local RoundTimes = message:PopByte()
    local BettingPosition = message:PopByte()
    local CurrentRound = message:PopUInt32()
    
    tRoomData.BetAllValue = GameConfig.GetFormatColdNumber(BetAllValue)

    -- 位置转换
    tRoomData.BankerPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(BankerPosition)
    tRoomData.BettingPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(BettingPosition)
    tRoomData.RoundTimes = RoundTimes
    tRoomData:InitBettingValue()
end

-- 解析房间玩家列表
function NetMsgHandler.ParseJHRoomPlayersInfo(message)
    -- body
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local playerID = message:PopUInt32()
        local Name = message:PopString()
        local HeadIcon = message:PopByte()
        local GoldValue = message:PopInt64()

        local severposition = message:PopByte()
        local PlayerState = message:PopByte()
        local LookState = message:PopByte()
        local DropCardState = message:PopByte()
        local CompareState = message:PopByte()
        local ReadyState = message:PopByte()
        local BetChipValue = message:PopInt64()

        --print(string.format('玩家基础信息ID:%d 位置:%d Name:%s Head:%d Url:%s Gold:%d Pos:%d 状态:%d 弃牌:%d 比牌:%d', playerID, severposition, Name, HeadIcon, HeadUrl, GoldValue, severposition, PlayerState,DropCardState,CompareState))

        local position = JHGameMgr:PlayerPositionConvert2ShowPosition(severposition)
        GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
        BetChipValue = GameConfig.GetFormatColdNumber(BetChipValue)

        tRoomData.JHPlayers[position].AccountID = playerID
        tRoomData.JHPlayers[position].Name = Name
        tRoomData.JHPlayers[position].HeadIcon = HeadIcon
        tRoomData.JHPlayers[position].GoldValue = GoldValue
        tRoomData.JHPlayers[position].Position = severposition
        tRoomData.JHPlayers[position].PlayerState = PlayerState
        tRoomData.JHPlayers[position].LookState = LookState
        tRoomData.JHPlayers[position].DropCardState = DropCardState
        tRoomData.JHPlayers[position].CompareState = CompareState
        tRoomData.JHPlayers[position].ReadyState = ReadyState
        tRoomData.JHPlayers[position].BetChipValue = BetChipValue
        -- 玩家的 扑克牌解析
        local cardCount = message:PopUInt16()
        for cardIndex = 1, cardCount, 1 do
            local PokerType = message:PopByte()
            local PokerNumber = message:PopByte()
            tRoomData.JHPlayers[position].PokerList[cardIndex].PokerType = PokerType
            tRoomData.JHPlayers[position].PokerList[cardIndex].PokerNumber = PokerNumber
        end
        tRoomData.JHPlayers[position].strLoginIP = message:PopString()

    end

end

--==============================--
--desc:解析明牌 暗牌下注值
--time:2017-11-30 11:14:32
--@message:
--@return 
--==============================--
function NetMsgHandler.ParseChipBaseInfo(message)
    local BettingPosition = message:PopByte()
    local MingCardBetMin = message:PopUInt32()
    local DarkCardBetMin = message:PopUInt32()
    BettingPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(BettingPosition)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.BettingPosition = BettingPosition
    tRoomData.MingCardBetMin = MingCardBetMin
    tRoomData.DarkCardBetMin = DarkCardBetMin
end

-- 解析当前所有下注情况
function NetMsgHandler.ParseAllBetInfo(message)
    -- body
    local betCount = message:PopUInt16()
    for index = 1, betCount, 1 do
        local position = message:PopByte()
        local betValue = message:PopInt64()
        position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
        betValue = GameConfig.GetFormatColdNumber(betValue)
        local BetInfo = { PositionValue = position, BetValue = betValue, BetType = 0 }
        GameData.RoomInfo.CurrentRoom.AllBetInfo[index] = BetInfo
    end

end

--==============================--
--desc:解析当前PK比牌信息
--time:2017-11-30 11:28:40
--@message:
--@return 
--==============================---
function NetMsgHandler.ParseVSPKInfo(message)
    -- 挑战者: 位置 下注筹码 剩余筹码  参与者:位置  赢家:位置
    local ChallengerPosition = message:PopByte()
    local ActorPosition = message:PopByte()
    local PKVSWinnerPosition = message:PopByte()
    ChallengerPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(ChallengerPosition)
    ActorPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(ActorPosition)
    PKVSWinnerPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(PKVSWinnerPosition)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.ChallengerPosition = ChallengerPosition
    tRoomData.ActorPosition = ActorPosition
    tRoomData.PKVSWinnerPosition = PKVSWinnerPosition
    if ChallengerPosition ~= 0 then
        -- 判断玩家比牌状态
        if PKVSWinnerPosition == ChallengerPosition then
            tRoomData.JHPlayers[ActorPosition].CompareState = 1
            tRoomData.PKVSLoserPosition = ActorPosition
        else
            tRoomData.JHPlayers[ChallengerPosition].CompareState = 1
            tRoomData.PKVSLoserPosition = ChallengerPosition
        end
    end
end


-- ============================================================================--
-- =============================S_JH_Next_State 805=========================--

-- 组局厅通知房间下一阶段
function NetMsgHandler.Received_S_JH_Next_State(message)
    -- body
    local RoomState = message:PopByte()
    -- print('=====805***** 当前阶段:' .. RoomState)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    if RoomState == ROOM_STATE_JHWR.Wait then
        -- 准备阶段
        NetMsgHandler.ParseZUJURoomStateSwitchToWait(message)
    elseif RoomState == ROOM_STATE_JHWR.SubduceBet then
        -- 扣除底注
        NetMsgHandler.ParseZUJURoomStateSwitchToSubduceBet(message)
    elseif RoomState == ROOM_STATE_JHWR.Deal then
        -- 发牌
        NetMsgHandler.ParseZUJURoomStateSwitchToDeal(message)
    elseif RoomState == ROOM_STATE_JHWR.Betting then
        -- 下注
        NetMsgHandler.ParseZUJURoomStateSwitchToBetting(message)
    elseif RoomState == ROOM_STATE_JHWR.CardVS then
        -- 比牌
        NetMsgHandler.ParseZUJURoomStateSwitchToCardVS(message)
    else
        -- Settlement 结算
        NetMsgHandler.ParseZUJURoomStateSwitchToSettlement(message)
    end

    tRoomData:SetRoomState(RoomState)
end

-- 准备阶段解析
function NetMsgHandler.ParseZUJURoomStateSwitchToWait(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData:ResetRoomDataToWaitState()
end

-- 扣除底注阶段解析
function NetMsgHandler.ParseZUJURoomStateSwitchToSubduceBet(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local severPosition = message:PopByte()
        local position = JHGameMgr:PlayerPositionConvert2ShowPosition(severPosition)
        local betValue = message:PopInt64()
        local GoldValue = message:PopInt64()
        betValue = GameConfig.GetFormatColdNumber(betValue)
        GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
        tRoomData.JHPlayers[position].GoldValue = GoldValue
        tRoomData.JHPlayers[position].BetChipValue = tRoomData.JHPlayers[position].BetChipValue + betValue
        tRoomData.JHPlayers[position].PlayerState = PlayerStateEnum.JoinOK
        -- 通知玩家下注了
        NetMsgHandler.NotifyPlayerBetting(position, betValue, 0)
    end
    local BetAllValue = message:PopInt64()
    local BankerPosition = message:PopByte()
    tRoomData.CurrentRound = message:PopUInt32()
    BetAllValue = GameConfig.GetFormatColdNumber(BetAllValue)
    tRoomData.BetAllValue = BetAllValue
    tRoomData.BankerPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(BankerPosition)
end

-- 发牌阶段解析
function NetMsgHandler.ParseZUJURoomStateSwitchToDeal(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
        local cardCount = message:PopUInt16()
        for cardIndex = 1, cardCount, 1 do
            local PokerType = message:PopByte()
            local PokerNumber = message:PopByte()
            tRoomData.JHPlayers[position].PokerList[cardIndex].PokerType = PokerType
            tRoomData.JHPlayers[position].PokerList[cardIndex].PokerNumber = PokerNumber
            tRoomData.JHPlayers[position].PokerList[cardIndex].Visible = true
        end
        
    end
end

-- 下注阶段解析
function NetMsgHandler.ParseZUJURoomStateSwitchToBetting(message)
    local RoundTimes = message:PopByte()
    local BettingPosition = message:PopByte()
    local MingCardBetMin = message:PopUInt32()
    local DarkCardBetMin = message:PopUInt32()
    local FreePK = message:PopByte()

    BettingPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(BettingPosition)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.RoundTimes = RoundTimes
    tRoomData.BettingPosition = BettingPosition
    tRoomData.MingCardBetMin = MingCardBetMin
    tRoomData.DarkCardBetMin = DarkCardBetMin
    tRoomData.JHPlayers[BettingPosition].FreePK = FreePK
end

-- 比牌阶段解析
function NetMsgHandler.ParseZUJURoomStateSwitchToCardVS(message)
    -- 挑战者: 位置 下注筹码 剩余筹码
    local ChallengerPosition = message:PopByte()
    local ChallengerBetValue = message:PopInt64()
    local ChallengerGoldValue = message:PopInt64()
    -- 总下注筹码
    local BetAllValue = message:PopInt64()

    -- 应邀参与者位置
    local ActorPosition = message:PopByte()
    -- 挑战赢家位置
    local PKVSWinnerPosition = message:PopByte()

    ChallengerPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(ChallengerPosition)
    ActorPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(ActorPosition)
    PKVSWinnerPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(PKVSWinnerPosition)

    ChallengerBetValue = GameConfig.GetFormatColdNumber(ChallengerBetValue)
    ChallengerGoldValue = GameConfig.GetFormatColdNumber(ChallengerGoldValue)
    BetAllValue = GameConfig.GetFormatColdNumber(BetAllValue)

    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.ChallengerPosition = ChallengerPosition
    tRoomData.ActorPosition = ActorPosition
    tRoomData.PKVSWinnerPosition = PKVSWinnerPosition
    tRoomData.BetAllValue = BetAllValue

    tRoomData.JHPlayers[ChallengerPosition].GoldValue = ChallengerGoldValue
    tRoomData.JHPlayers[ChallengerPosition].BetChipValue = tRoomData.JHPlayers[ChallengerPosition].BetChipValue + ChallengerBetValue

    -- 判断玩家比牌状态
    if PKVSWinnerPosition == ChallengerPosition then
        tRoomData.JHPlayers[ActorPosition].CompareState = 1
        tRoomData.PKVSLoserPosition = ActorPosition
    else
        tRoomData.JHPlayers[ChallengerPosition].CompareState = 1
        tRoomData.PKVSLoserPosition = ChallengerPosition
    end
    -- 通知挑战者下注
    NetMsgHandler.NotifyPlayerBetting(ChallengerPosition, ChallengerBetValue, 0)

end

-- 结算状态解析
function NetMsgHandler.ParseZUJURoomStateSwitchToSettlement(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 赢家数量
    local winnerCount = message:PopUInt16()
    tRoomData.WinnerCount = winnerCount
    for index = 1, winnerCount, 1 do
        local WinnerPosition = message:PopByte()
        local WinGoldValue = message:PopInt64()
        local GoldValue = message:PopInt64()

        WinnerPosition = JHGameMgr:PlayerPositionConvert2ShowPosition(WinnerPosition)
        WinGoldValue = GameConfig.GetFormatColdNumber(WinGoldValue)
        GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
        tRoomData.JHPlayers[WinnerPosition].GoldValue = GoldValue
        tRoomData.JHPlayers[WinnerPosition].WinGoldValue = WinGoldValue
        tRoomData.JHPlayers[WinnerPosition].IsWinner = true
    end
    -- 本局自己客户端需要量牌玩家
    local showCount = message:PopUInt16()
    for showIndex = 1, showCount, 1 do
        local position = message:PopByte()
        position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
        tRoomData.JHPlayers[position].IsShowPokerCard = true
        local cardCount = message:PopUInt16()
        for cardIndex = 1, cardCount, 1 do
            local PokerType = message:PopByte()
            local PokerNumber = message:PopByte()
            tRoomData.JHPlayers[position].PokerList[cardIndex].PokerType = PokerType
            tRoomData.JHPlayers[position].PokerList[cardIndex].PokerNumber = PokerNumber
            tRoomData.JHPlayers[position].PokerList[cardIndex].Visible = true
        end
    end
end

-- ============================================================================--
-- =============================S_JH_Next_State 806=========================--

-- 组局厅通知新增一个玩家
function NetMsgHandler.Received_S_JH_Add_Player(message)
    -- body
    local severPosition = message:PopByte()
    local position = JHGameMgr:PlayerPositionConvert2ShowPosition(severPosition)

    local playerID = message:PopUInt32()
    local Name = message:PopString()
    local HeadIcon = message:PopByte()
    local GoldValue = message:PopInt64()
    local PlayerState = message:PopByte()
    local strLoginIP = message:PopString()
    --print(string.format("=====新增玩家:%d,AccID:%d,Name:%s 头像:%d Url:%s 金币:%f 状态:%d", position, playerID, Name, HeadIcon, HeadUrl, GoldValue, PlayerState))
    GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.JHPlayers[position].AccountID = playerID
    tRoomData.JHPlayers[position].Name = Name
    tRoomData.JHPlayers[position].HeadIcon = HeadIcon
    tRoomData.JHPlayers[position].GoldValue = GoldValue
    tRoomData.JHPlayers[position].Position = severPosition
    tRoomData.JHPlayers[position].PlayerState = PlayerState
    tRoomData.JHPlayers[position].strLoginIP = strLoginIP

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZUJUAddPlayerEvent, position)
end

-- ============================================================================--
-- =============================S_JH_Delete_Player 807=========================--

-- 组局厅通知删除一个玩家
function NetMsgHandler.Received_S_JH_Delete_Player(message)
    -- body
    local position = message:PopByte()
    position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.JHPlayers[position].PlayerState = PlayerStateEnum.None
    tRoomData.JHPlayers[position].AccountID = 0
    tRoomData.JHPlayers[position].Name = ''
    tRoomData.JHPlayers[position].HeadIcon = 0
    tRoomData.JHPlayers[position].HeadUrl = ''
    tRoomData.JHPlayers[position].GoldValue = 0
    tRoomData.JHPlayers[position].Position = 0
    tRoomData.JHPlayers[position].BetChipValue = 0
    tRoomData.JHPlayers[position].ReadyState = 0
    tRoomData.JHPlayers[position].LookState = 0
    tRoomData.JHPlayers[position].DropCardState = 0
    tRoomData.JHPlayers[position].CompareState = 0
    tRoomData.JHPlayers[position].IsWinner = false
    tRoomData.JHPlayers[position].WinGoldValue = 0
    tRoomData.JHPlayers[position].IsShowPokerCard = false


    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZUJUDeletePlayerEvent, position)
end

-- ============================================================================--
-- =============================CS_JH_Exit_Room 808=========================--

-- 组局厅请求离开房间
function NetMsgHandler.Send_CS_JH_Exit_Room(rooIDParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(rooIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Exit_Room, message, true)
end

-- 组局厅请求离开房间反馈
function NetMsgHandler.Received_CS_JH_Exit_Room(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        NetMsgHandler.ExitRoomToHall(0)
    else
        CS.BubblePrompt.Show(data.GetString("JH_Exit_Room_Error_" .. resultType), "GameUI1")
    end
    CS.LoadingDataUI.Hide()
end

-- ============================================================================--
-- =============================CS_JH_Ready 809=========================--

-- 组局厅玩家开始准备
function NetMsgHandler.Send_CS_JH_Ready(readyParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(readyParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Ready, message)
end

-- 组局厅玩家准备反馈
function NetMsgHandler.Received_CS_JH_Ready(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local position = message:PopByte()
        local readyState = message:PopByte()
        position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
        GameData.RoomInfo.CurrentRoom.JHPlayers[position].ReadyState = readyState
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZUJUPlayerReadyStateEvent, position)
    else
        CS.BubblePrompt.Show(data.GetString("JH_Ready_Error_" .. resultType), "GameUI1")
    end
end

-- ============================================================================--
-- =============================CS_JH_Betting 810=========================--

-- 玩家请求下注(加注,跟注)
function NetMsgHandler.Send_CS_JH_Betting(roomidParam, betTypeParam, betValueParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomidParam)
    message:PushByte(betTypeParam)
    message:PushInt64(betValueParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Betting, message)
    --print(string.format("---810--CS_JH_Betting Room:%d BetType:%d BetValue:%f", roomidParam, betTypeParam, betValueParam))
end

-- 组局厅 下注反馈
function NetMsgHandler.Received_CS_JH_Betting(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local position = message:PopByte()
        local betType = message:PopByte()
        local betValue = message:PopInt64()
        local GoldValue = message:PopInt64()

        position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
        betValue = GameConfig.GetFormatColdNumber(betValue)
        GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
        local tRoomData = GameData.RoomInfo.CurrentRoom
        tRoomData.JHPlayers[position].GoldValue = GoldValue
        tRoomData.JHPlayers[position].BetChipValue = tRoomData.JHPlayers[position].BetChipValue + betValue
        tRoomData:UpdateBetAllValue(betValue)
        -- 通知玩家下注了
        NetMsgHandler.NotifyPlayerBetting(position, betValue, betType)
    else
        if resultType ~= 7 then
            CS.BubblePrompt.Show(data.GetString("JH_Betting_Error_" .. resultType), "GameUI1")
        end
    end
end

-- 广播玩家玩家下注
function NetMsgHandler.NotifyPlayerBetting(positionParam, betValueParam, betTypeParam)
    -- 通知玩家下注了
    local betChipEventArg = { PositionValue = positionParam, BetValue = betValueParam, BetType = betTypeParam }
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZUJUBettingEvent, betChipEventArg)
end

-- ============================================================================--
-- =============================CS_JH_VS_Card 811=========================--

-- 玩家请求比牌(被挑战者，发起类型)
function NetMsgHandler.Send_CS_JH_VS_Card(defenseID, PKType)

    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(defenseID)
    message:PushByte(PKType)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_VS_Card, message)
end


-- 服务器反馈比牌
function NetMsgHandler.Received_CS_JH_VS_Card(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        -- TODO 玩家发起比牌成功
        
    else
        CS.BubblePrompt.Show(data.GetString("JH_VS_Card_Error_" .. resultType), "GameUI1")
    end
end


-- ============================================================================--
-- =============================CS_JH_Drop_Card 812=========================--

function NetMsgHandler.Send_CS_JH_Drop_Card()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Drop_Card, message)
end

-- 服务器反馈玩家弃牌
function NetMsgHandler.Received_CS_JH_Drop_Card(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local position = message:PopByte()
        position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
        GameData.RoomInfo.CurrentRoom.JHPlayers[position].DropCardState = 1
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZUJUDropCardEvent, position)
    else
        CS.BubblePrompt.Show(data.GetString("JH_Drop_Card_Error_" .. resultType), "GameUI1")
    end
end

-- ============================================================================--
-- =============================CS_JH_Look_Card 813=========================--

function NetMsgHandler.Send_CS_JH_Look_Card()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Look_Card, message)
end

-- 服务器反馈 看牌
function NetMsgHandler.Received_CS_JH_Look_Card(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom
        local position = message:PopByte()
        position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
        local cardCount = message:PopUInt16()
        for cardIndex = 1, cardCount, 1 do
            local PokerType = message:PopByte()
            local PokerNumber = message:PopByte()

            tRoomData.JHPlayers[position].PokerList[cardIndex].PokerType = PokerType
            tRoomData.JHPlayers[position].PokerList[cardIndex].PokerNumber = PokerNumber
            tRoomData.JHPlayers[position].PokerList[cardIndex].Visible = false
        end
        tRoomData.JHPlayers[position].LookState = 1
    else
        CS.BubblePrompt.Show(data.GetString("JH_Look_Card_Error_" .. resultType), "GameUI1")
    end
end

-- ============================================================================--
-- =============================S_JH_Notify_Look_Card 814=========================--
-- 服务器广播玩家看牌消息
function NetMsgHandler.Received_S_JH_Notify_Look_Card(message)
    local position = message:PopByte()
    position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
    GameData.RoomInfo.CurrentRoom.JHPlayers[position].LookState = 1
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZUJULookCardEvent, position)
end

-- ============================================================================--
-- =============================CS_JH_ZuJuRoomList 815=========================--

-- 玩家请求组局房间列表
function NetMsgHandler.Send_CS_JH_ZuJuRoomList()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_ZuJuRoomList, message)
end

local function SortRoomList(tA, tB)
    return tA.IsJoin==tB.IsJoin and (tA.EstablishTime>tB.EstablishTime) or (tA.IsJoin>tB.IsJoin)
end

-- 服务器反馈组局厅房间列表
function NetMsgHandler.Received_CS_JH_ZuJuRoomList(message)
    GameData.ZJRoomList = { }
    local roomCount = message:PopUInt16()
    for index = 1, roomCount, 1 do
        local roomData = { }
        roomData.Position = index
        roomData.RoomID = message:PopUInt32()
        roomData.OnlineCount = message:PopByte()
        roomData.MenJiRound = message:PopByte()
        roomData.IsLock = message:PopByte()
        roomData.GameMode = message:PopByte()
        roomData.BetMin = message:PopInt64()
        roomData.EnterChip = message:PopInt64()
        roomData.QuitChip = message:PopInt64()
        roomData.IsJoin = message:PopByte()
        -- 创建时间
        roomData.EstablishTime=message:PopUInt32()
        GameData.ZJRoomList[index] = roomData
    end
    table.sort(GameData.ZJRoomList, SortRoomList)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomListUpdateEvent, nil)
end

-- ============================================================================--
-- ============================CS_JH_MenJiRoomOnlineCount 816=========================--

--==============================--
--desc:请求焖鸡厅房间在线人数
--time:2017-11-24 02:25:34
--@message:
--@return 
--==============================--
function NetMsgHandler.Send_CS_JH_MenJiRoomOnlineCount()
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_MenJiRoomOnlineCount, message, false)
end


function NetMsgHandler.Received_CS_JH_MenJiRoomOnlineCount(message)
    local count  = message:PopUInt16()
    GameData.MJRoomOnlineCount = {}
    for index = 1, count, 1 do
        local OnlineData  =  {}
        OnlineData.roomIndex  = message:PopByte()
        OnlineData.OnlineCount  = message:PopUInt16()
        GameData.MJRoomOnlineCount[index] = OnlineData
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomOnlineEvent, nil)
end

-- ============================================================================--
-- ============================CS_JH_Change_MenJiRoom 817=========================--

--==============================--
--desc:
--time:2017-11-25 10:25:52
--@message:
--@return 
--==============================--
    -- body
function NetMsgHandler.Send_CS_JH_Change_MenJiRoom(roomidParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomidParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_JH_Change_MenJiRoom, message, false)
end

function NetMsgHandler.Received_CS_JH_Change_MenJiRoom( message )
    -- body
    local resultType  = message:PopByte()
    if resultType == 0 then
        -- body

    else
        CS.BubblePrompt.Show(data.GetString("JH_Change_MJRoom_Error_" .. resultType), "GameUI1")
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMenJiRoomChangeEvent, nil)
end
-- ============================================================================--
-- ============================S_JH_Kick_Out 818=========================--

--==============================--
--desc:玩家金币不足，低于离场限制 被踢出房间
--time:2017-12-01 04:14:54
--@message:
--@return 
--==============================--
function NetMsgHandler.Received_S_JH_Kick_Out(message)
    -- body
    local resultType  = message:PopByte()

    local boxData = CS.MessageBoxData()
    boxData.Title = "提示"
    boxData.Content = data.GetString("Kick_Out_Tips_"..resultType)
    boxData.Style = 1
    -- 直接提出房间并弹出提示
    CS.MessageBoxUI.Show(boxData)
    
    NetMsgHandler.ExitRoomToHall(0)
end

--==================================================================================  --
-- =============================== 更新组局厅玩家金币数量 820 =========================  --
function NetMsgHandler.ZUJU_Gold_Update(message)
    CS.LoadingDataUI.Hide()
    local position = message:PopByte()
    local GoldValue = message:PopInt64()
    position = JHGameMgr:PlayerPositionConvert2ShowPosition(position)
    GameData.RoomInfo.CurrentRoom.JHPlayers[position].GoldValue =  GameConfig.GetFormatColdNumber(GoldValue)
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotZUJU_Gold_Update, position)
end

