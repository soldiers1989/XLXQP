--[[
   文件名称:LHDGameMgr.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

if LHDGameMgr == nil then
    LHDGameMgr =
    {
        
    }
end

--==============================--
--desc:推筒子组局房间初始化
--time:2018-01-12 04:55:50
--@return 
--==============================--
function LHDGameMgr:InitRoomInfo(roomTypeParam)
    local tNewRoom = LHDRoom:New()
    tNewRoom:Init(true, roomTypeParam)
    GameData.RoomInfo.CurrentRoom = tNewRoom
end

function LHDGameMgr:UpdateRoomCountDown( deltaValue )
    -- body
    GameData.RoomInfo.CurrentRoom.CountDown = GameData.RoomInfo.CurrentRoom.CountDown - deltaValue
end

--============================================================================
--=================[龙虎斗]相关协议[1251~1266]解析==============================

--============================================================================
--=================[CS_LHD_Hall_Room] [1251]==================================
--==============================--
--desc:请求推筒子匹配房间在线人数
--time:2018-01-29 03:21:03
--@return 
--==============================--
function NetMsgHandler.Send_CS_LHD_Hall_Room()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Hall_Room, message, false)
end

function NetMsgHandler.Received_CS_LHD_Hall_Room(message)
    local count  = message:PopUInt16()
    local currentTime = CS.UnityEngine.Time.realtimeSinceStartup
    for index = 1, count, 1 do
        local tLHDStatistics  =  NetMsgHandler.NewStatisticsInfo()
        tLHDStatistics.Index  = message:PopByte()
        tLHDStatistics.RoomID  = message:PopUInt32()

        local roundCount = message:PopUInt16()
        for round = 1, roundCount, 1 do
            table.insert(tLHDStatistics.Trend, message:PopByte())
        end
        LHDGameMgr.ParseRightTrend(tLHDStatistics, roundCount)
        

        tLHDStatistics.Counts.LongWin = message:PopByte()
        tLHDStatistics.Counts.HuWin = message:PopByte()
        tLHDStatistics.Counts.HeJu = message:PopByte()
        tLHDStatistics.Round.CurrentRound = message:PopByte()
        tLHDStatistics.Round.MaxRound = message:PopByte()
        tLHDStatistics.Counts.RoleCount = message:PopUInt16()
        tLHDStatistics.Time = currentTime
        GameData.RoomInfo.StatisticsInfo[tLHDStatistics.RoomID] = tLHDStatistics
        local eventArgs = { RoomType = 3, Index= tLHDStatistics.Index, RoomID = tLHDStatistics.RoomID, OperationType = 0 }
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics, eventArgs)
    end
    print("*****LHD LUDAN 1251:===", count)
end

function NetMsgHandler.Send_CS_LHD_Hall_Room_New8()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Hall_Room_New8, message, false)
end

function NetMsgHandler.Received_CS_LHD_Hall_Room_New8(message)
    local count  = message:PopUInt16()
    GameData.RoleInfo.BRTRoomAmount = count;
    local eventArgs = {};
    local currentTime = CS.UnityEngine.Time.realtimeSinceStartup
    for index = 1, count, 1 do
        local tLHDStatistics  =  NetMsgHandler.NewStatisticsInfo()
        tLHDStatistics.Index  = message:PopByte()
        tLHDStatistics.RoomID  = message:PopUInt32()

        local roundCount = message:PopUInt16()
        for round = 1, roundCount, 1 do
            table.insert(tLHDStatistics.Trend, message:PopByte())
        end
        LHDGameMgr.ParseRightTrend(tLHDStatistics, roundCount)


        tLHDStatistics.Counts.LongWin = message:PopByte()
        tLHDStatistics.Counts.HuWin = message:PopByte()
        tLHDStatistics.Counts.HeJu = message:PopByte()
        tLHDStatistics.Round.CurrentRound = message:PopByte()
        tLHDStatistics.Round.MaxRound = message:PopByte()
        tLHDStatistics.Counts.RoleCount = message:PopUInt16()
        tLHDStatistics.Time = currentTime
        GameData.RoomInfo.StatisticsInfo[tLHDStatistics.RoomID] = tLHDStatistics
        local tempEventArgs = { RoomType = 3, Index= tLHDStatistics.Index, RoomID = tLHDStatistics.RoomID, OperationType = 0 }
        eventArgs[index] = tLHDStatistics;
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics_New8, eventArgs)
    print("*****LHD LUDAN 1251:===", count)
end

-- 右侧路单解析
function LHDGameMgr.ParseRightTrend(statisticParam, roundCount)
    if roundCount > 0 then
        -- 本局已有路单信息
        local tHeValue = LHD_WIN_CODE.HE
        local tHeadValue = statisticParam.Trend[1]

        local tIsHe = CS.Utility.GetLogicAndValue(tHeadValue, tHeValue) == tHeValue
        local tRounRBeginIndex = 0
        -- 排除头部和局信息
        if tIsHe then
            -- 第一次就出现和局
            statisticParam.Trend_RHeadHeCount = 1
            statisticParam.Trend_RHeadValue = tHeadValue
            -- 找到首次非heju
            for roundR = 2, roundCount do
                local newValue = statisticParam.Trend[roundR]
                local tIsHe2 = CS.Utility.GetLogicAndValue(newValue, tHeValue) == tHeValue
                if not tIsHe2  then
                    tRounRBeginIndex = roundR
                    break
                else
                    statisticParam.Trend_RHeadHeCount = statisticParam.Trend_RHeadHeCount + 1
                end
            end
            if tRounRBeginIndex > 0 then
                -- 找到非和局开始标签
            else
                -- 目前全部是和局
            end
        else
            statisticParam.Trend_RHeadHeCount = 0
            statisticParam.Trend_RHeadValue = 0
            tRounRBeginIndex = 1
        end

        if tRounRBeginIndex > 0 then
            -- 当前存在非和局路单
            local tTrendRValue = statisticParam.Trend[tRounRBeginIndex]
            local tTrendRHeCount = statisticParam.Trend_RHeadHeCount
            local tLastValue = {TrendRValue = tTrendRValue, TrendRHeCount = tTrendRHeCount}
            table.insert(statisticParam.Trend_R, tLastValue)

            -- 过滤和局信息
            for i = tRounRBeginIndex + 1, roundCount do
                local tTrend = statisticParam.Trend[i]
                local tIsHe = CS.Utility.GetLogicAndValue(tTrend, tHeValue) == tHeValue
                if tIsHe then
                    tLastValue.TrendRHeCount = tLastValue.TrendRHeCount + 1
                else
                    tLastValue = {TrendRValue = tTrend, TrendRHeCount = 0}
                    table.insert(statisticParam.Trend_R, tLastValue)
                end
            end
        else
            -- 当前无非和局路单
        end
    else
        -- 目前无路单信息
    end
end

-- 更新右侧统计数据
function LHDGameMgr.AppendRightStatistic(statisticParam, trendParam)
    local tHeValue = LHD_WIN_CODE.HE
    local tNewIsHe = CS.Utility.GetLogicAndValue(trendParam, tHeValue) == tHeValue
    
    local tRightCount = #statisticParam.Trend_R
    if tNewIsHe then
        if tRightCount > 0 then
            -- 已经有路单信息 追加和局信息
            local tRightLast = statisticParam.Trend_R[tRightCount]
            tRightLast.TrendRHeCount = tRightLast.TrendRHeCount + 1
            statisticParam.Trend_R[tRightCount] = tRightLast
        else
            -- 还没有路单信息 追加和局信息
            if statisticParam.Trend_RHeadHeCount > 0 then
                -- 已经有和局累计
                statisticParam.Trend_RHeadHeCount = statisticParam.Trend_RHeadHeCount + 1
            else
                -- 无和局信息
                statisticParam.Trend_RHeadHeCount = 1
                statisticParam.Trend_RHeadValue = trendParam
            end
        end
    else
        local tAppendData = {TrendRValue = trendParam, TrendRHeCount = 0}
        if tRightCount > 0 then
            -- 已经有路单信息 ==>直接追加一条新的信息
            table.insert(statisticParam.Trend_R, tAppendData)
        else
            -- 还没有路单信息
            if statisticParam.Trend_RHeadHeCount > 0 then
                -- 之前已经有和局累计
                tAppendData.TrendRHeCount = statisticParam.Trend_RHeadHeCount
            else
                -- 之前无任何信息
            end
            table.insert(statisticParam.Trend_R, tAppendData)
        end
    end

    local tCount = #statisticParam.Trend_R
    return tNewIsHe, statisticParam.Trend_R[tCount]
end

--============================================================================
--=================[CS_LHD_Enter_Room] [1252]=================================

function  NetMsgHandler.Send_CS_LHD_Enter_Room(roomIDParam, roomLvParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomLvParam)
    message:PushUInt32(roomIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Enter_Room, message, false)
    CS.MatchLoadingUI.Show()
end

function  NetMsgHandler.Received_CS_LHD_Enter_Room(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local roomData = { }
        --房间ID
        local tRoomID = message:PopUInt32()
        local tTemplateID = message:PopByte()
        GameData.RoomInfo.CurrentRoom.RoomID = tRoomID
        GameData.InitCurrentRoomInfo(ROOM_TYPE.LHDRoom, tRoomID)
        GameData.RoomInfo.CurrentRoom.TemplateID = tTemplateID
        HandleLHDGameUIShowState(true)
        --local BRHallUI = CS.WindowManager.Instance:FindWindowNodeByName("BRHallUI")
        if BRHallUI ~= nil then
            BRHallUI.WindowGameObject:SetActive(false)
        else
            print('*********BRHallUI查找失败，请请检查!')
        end
    else
        CS.MatchLoadingUI.Hide()
        if resultType == 3 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType == 7 then
                local GoldValue = message:PopInt64()
            end
            CS.BubblePrompt.Show(data.GetString("T_1252_" .. resultType), "LHDGameUI")
        end
        NetMsgHandler.ExitRoomToHall(0)
    end
end

-- 龙虎斗GameUI显示处理
function HandleLHDGameUIShowState(activeParam)
    if activeParam then
        local gameNode = CS.WindowManager.Instance:FindWindowNodeByName('LHDGameUI')
        if gameNode == nil then
            -- TODO 占时还未适配IphoneX
            local openparam = CS.WindowNodeInitParam("LHDGameUI")
            openparam.NodeType = 0
            openparam.LoadComplatedCallBack = function(windowNode)
                HandleRefreshHallUIShowState(false)
            end
            CS.WindowManager.Instance:OpenWindow(openparam)
        else
            CS.MatchLoadingUI.Hide()
        end
        -- 切换状态为房间
        GameData.GameState = GAME_STATE.ROOM
    else
        CS.WindowManager.Instance:CloseWindow("LHDGameUI", false)
    end
end

--============================================================================
--=================[S_LHD_GameData] [1253]====================================

function NetMsgHandler.Received_S_LHD_GameData(message)
    -- Home 出去 再切换回来时也会调用此接口，重新初始化房间信息
    -- 解析房间的基本信息
    -- 房间ID
    GameData.RoomInfo.CurrentRoom.RoomID = message:PopUInt32()
    -- 房间配置ID
    GameData.RoomInfo.CurrentRoom.TemplateID = message:PopByte()
    -- 最大游戏局数
    GameData.RoomInfo.CurrentRoom.MaxRound = message:PopByte()
    -- 以进行游戏局数
    GameData.RoomInfo.CurrentRoom.CurrentRound = message:PopByte()
    -- 房间状态
    GameData.RoomInfo.CurrentRoom.RoomState = message:PopByte()
    -- 当前状态倒计时
    GameData.RoomInfo.CurrentRoom.CountDown = message:PopUInt32() / 1000.0
    -- 投注龙虎下限
    GameData.RoomInfo.CurrentRoom.BetLongHuMin = message:PopInt64()
    -- 投注龙虎上限
    GameData.RoomInfo.CurrentRoom.BetLongHuMax = message:PopInt64()
    -- 投注和下限
    GameData.RoomInfo.CurrentRoom.BetHeMin = message:PopInt64()
    -- 投注和上限
    GameData.RoomInfo.CurrentRoom.BetHeMax = message:PopInt64()
    -- print("**LHD** 房间信息:", GameData.RoomInfo.CurrentRoom.RoomState, GameData.RoomInfo.CurrentRoom.CountDown)
    -- 解析自己各区域押注信息
    NetMsgHandler.LHDParseAndSetBetValue(message)
    -- 解析房间各区域总押注信息
    NetMsgHandler.LHDParseAndSetTotalBetValue(message)

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetValue, 3)

    -- 解析已押注到押注区域的筹码信息
    NetMsgHandler.LHDParseAndSetChipsOnBetAreas(message)

    -- 解析庄家信息
    NetMsgHandler.LHDParseAndSetBankerInfo(message)

    -- 解析扑克牌
    if GameData.RoomInfo.CurrentRoom.RoomState >= LHD_ROOM_STATE.CHECK then
        NetMsgHandler.LHDParseAndSetPokerCards(message)
    else
        -- 扑克牌默认值设置
        -- 龙牌
        GameData.RoomInfo.CurrentRoom.Pokers[1] = { }
        GameData.RoomInfo.CurrentRoom.Pokers[1].PokerType = 1
        GameData.RoomInfo.CurrentRoom.Pokers[1].PokerNumber =  1
        GameData.RoomInfo.CurrentRoom.Pokers[1].Visible = false
        -- 虎牌
        GameData.RoomInfo.CurrentRoom.Pokers[2] = { }
        GameData.RoomInfo.CurrentRoom.Pokers[2].PokerType = 2
        GameData.RoomInfo.CurrentRoom.Pokers[2].PokerNumber =  2
        GameData.RoomInfo.CurrentRoom.Pokers[2].Visible = false
    end
    -- 本局结果
    GameData.RoomInfo.CurrentRoom.GameResult = message:PopByte()

    -- 刷新游戏房间状态值
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, GameData.RoomInfo.CurrentRoom.RoomState)

end

-- 解析自己各区域押注信息
function NetMsgHandler.LHDParseAndSetBetValue(message)
    local betCount = message:PopUInt16()
    if betCount > 0 then
        for index = 1, betCount, 1 do
            local betArea = message:PopByte()
            local betValue = message:PopInt64()
            GameData.RoomInfo.CurrentRoom.BetValues[betArea] = betValue
        end
    end
end

-- 解析房间各区域总押注信息
function NetMsgHandler.LHDParseAndSetTotalBetValue(message)
    local totalBetCount = message:PopUInt16()
    if totalBetCount > 0 then
        for index = 1, totalBetCount, 1 do
            local totalBetArea = message:PopByte()
            local totalBetValue = message:PopInt64()
            GameData.RoomInfo.CurrentRoom.TotalBetValues[totalBetArea] = totalBetValue
        end
    end
end

-- 解析押注区域已经存在的筹码信息
function NetMsgHandler.LHDParseAndSetChipsOnBetAreas(message)
    -- 解析桌面上已有的筹码面值和数量
    local count = message:PopUInt16()
    local currentRoomChips = { }
    for index = 1, count, 1 do
        local betArea = message:PopByte()
        local chipValue = message:PopUInt32()
        local chipCount = message:PopUInt32()
        local betAreaInfo = currentRoomChips[betArea]
        if betAreaInfo == nil then
            betAreaInfo = { }
            currentRoomChips[betArea] = betAreaInfo
        end

        local chipInfo = betAreaInfo[chipValue]
        if chipInfo == nil then
            chipInfo = { }
            betAreaInfo[chipValue] = chipInfo
        end
        chipInfo.Count = chipCount
    end
    GameData.RoomInfo.CurrentRoomChips = currentRoomChips
end

-- 解析设置庄家信息
function NetMsgHandler.LHDParseAndSetBankerInfo(message)
    if GameData.RoomInfo.CurrentRoom.BankerInfo == nil then
        GameData.RoomInfo.CurrentRoom.BankerInfo = { }
    end
    GameData.RoomInfo.CurrentRoom.BankerInfo.ID = message:PopUInt32()
    GameData.RoomInfo.CurrentRoom.BankerInfo.Name = message:PopString()
    GameData.RoomInfo.CurrentRoom.BankerInfo.Gold = message:PopInt64()
    -- 庄家剩余局数
    GameData.RoomInfo.CurrentRoom.BankerInfo.LeftCount = message:PopByte()
    -- 头像ID
    GameData.RoomInfo.CurrentRoom.BankerInfo.HeadIcon = message:PopByte()
    -- 上一个庄家是否被强制下庄
    --GameData.RoomInfo.CurrentRoom.BankerInfo.IsLastForceDownBanker = message:PopByte() == 1
    GameData.RoomInfo.CurrentRoom.BankerInfo.strLoginIP = message:PopString()
end



--============================================================================
--=================[S_LHD_Game_Statistics] [1254]====================================

-- 返回全部统计信息
function NetMsgHandler.Received_S_LHD_Game_Statistics(message)

    local tLHDStatistics  =  NetMsgHandler.NewStatisticsInfo()
    tLHDStatistics.Index  = message:PopByte()
    tLHDStatistics.RoomID  = message:PopUInt32()

    local roundCount = message:PopUInt16()
    for round = 1, roundCount, 1 do
        table.insert(tLHDStatistics.Trend, message:PopByte())
    end
    LHDGameMgr.ParseRightTrend(tLHDStatistics, roundCount)
    BJLGameMgr.MatrixTrendParse(tLHDStatistics)
    BJLGameMgr.BigEyeTrendParse(tLHDStatistics)
    BJLGameMgr.SmallTrendParse(tLHDStatistics)
    BJLGameMgr.YueYouTrendParse(tLHDStatistics)

    tLHDStatistics.Counts.LongWin = message:PopByte()
    tLHDStatistics.Counts.HuWin = message:PopByte()
    tLHDStatistics.Counts.HeJu = message:PopByte()

    tLHDStatistics.Round.CurrentRound = message:PopByte()
    tLHDStatistics.Round.MaxRound = message:PopByte()
    tLHDStatistics.Counts.RoleCount = message:PopUInt16()
    tLHDStatistics.Time = CS.UnityEngine.Time.realtimeSinceStartup
    
    tLHDStatistics.Round.MaxRound = GameData.RoomInfo.CurrentRoom.MaxRound
    
    GameData.RoomInfo.StatisticsInfo[tLHDStatistics.RoomID] = tLHDStatistics

    local eventArgs = { RoomID = tLHDStatistics.RoomID, OperationType = 0 }
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics, eventArgs)

    print("*****LHD LUDAN 1254:===", roundCount)
end

--============================================================================
--=================[S_LHD_Game_Append_Statistics] [1255]======================

-- 返回本局追加路单信息
function NetMsgHandler.Received_S_LHD_Game_Append_Statistics(message)
    local roomID = message:PopUInt32()
    local currentRoomID = GameData.RoomInfo.CurrentRoom.RoomID
    if roomID ~= currentRoomID then
        return
    end

    local statistics = GameData.RoomInfo.StatisticsInfo[roomID]
    local eventArgs = { RoomID = roomID, OperationType = 1 }

    if statistics == nil then
        statistics = NetMsgHandler.NewStatisticsInfo()
        statistics.RoomID = currentRoomID
        GameData.RoomInfo.StatisticsInfo[currentRoomID] = statistics
        eventArgs.OperationType = 0
    end

    statistics.Time = CS.UnityEngine.Time.realtimeSinceStartup
    local tTrend = message:PopByte()
    table.insert(statistics.Trend, tTrend)

    local tIsHe, tNewTrend = LHDGameMgr.AppendRightStatistic(statistics, tTrend)
    if not tIsHe then
        BJLGameMgr.AppendMatrixTrendValue(tNewTrend, statistics)

        BJLGameMgr.TryAppendBigEyeTrend(statistics)
        BJLGameMgr.TryAppendSmallTrend(statistics)
        BJLGameMgr.TryAppendYueYouTrend(statistics)
    end

    statistics.Counts.LongWin = message:PopByte()
    statistics.Counts.HuWin = message:PopByte()
    statistics.Counts.HeJu = message:PopByte()

    statistics.Round.CurrentRound = message:PopByte()
    statistics.Round.MaxRound = message:PopByte()

    GameData.RoomInfo.CurrentRoom.AppendStatisticsEventArgs = eventArgs
    print("*****LHD LUDAN 1255:===", tTrend)
end

--============================================================================
--=================[CS_LHD_Exit_Room] [1256]==================================
-- 退出房间请求
function NetMsgHandler.Send_CS_LHD_Exit_Room()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Exit_Room, message, false)
end

-- 反馈退出房间结果
function NetMsgHandler.Received_CS_LHD_Exit_Room(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        NetMsgHandler.ExitRoomToHall(0)
    else
        CS.BubblePrompt.Show(data.GetString("T_1256_".. resultType), "LHDGameUI")
    end
end

--============================================================================
--=================[S_LHD_Kick_Room] [1257][废弃]=============================

-- 被提出房间(1 金币不足 2 五局未参与)
function NetMsgHandler.Received_S_LHD_Kick_Room(message)
    
end

--============================================================================
--=================[S_LHD_Next_State] [1258]==================================

-- 组局厅--服务器通知进入下一阶段
function  NetMsgHandler.Received_S_LHD_Next_State(message)
    -- 当前房间状态
    local roomState = message:PopByte()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    print(string.format('[龙虎斗]==当前状态:[%d] 房间类型:[%d] Time[%f]', roomState, tRoomData.RoomType, CS.UnityEngine.Time.time))
    if roomState == LHD_ROOM_STATE.WAIT then
        -- 1等待
        LHDGameMgr.ClearCurrentRoundData()
    elseif roomState == LHD_ROOM_STATE.SHUFFLE then
        -- 2洗牌
    elseif roomState == LHD_ROOM_STATE.DEAL then
        -- 3发牌
    elseif roomState == LHD_ROOM_STATE.BET then
        -- 4下注
    elseif roomState == LHD_ROOM_STATE.CHECK then
        -- 5亮牌
        NetMsgHandler.LHDParseAndSetPokerCards(message)
    elseif roomState == LHD_ROOM_STATE.SETTLEMENT then
        -- 6结算
        NetMsgHandler.LHDParseAndSetSettlement(message)
    end
    -- 设置组局厅房间状态
    GameData.RoomInfo.CurrentRoom:SetRoomState(roomState)
end

-- 聚龙厅清理本局数据
function LHDGameMgr.ClearCurrentRoundData()
    GameData.RoomInfo.CurrentRoom.BetRankList = { }
    GameData.RoomInfo.CurrentRoom.BetValues = { }
    GameData.RoomInfo.CurrentRoom.TotalBetValues = { }
    GameData.RoomInfo.CurrentRoom.WinGold = { }
    GameData.RoomInfo.CurrentRoom.Pokers = { }
    GameData.RoomInfo.CurrentRoom.GameResult = 0
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetValue, nil)
end

-- 解析收到的扑克牌
function NetMsgHandler.LHDParseAndSetPokerCards(message)
    -- 龙牌
    GameData.RoomInfo.CurrentRoom.Pokers[1] = { }
    GameData.RoomInfo.CurrentRoom.Pokers[1].PokerType = message:PopByte()
    GameData.RoomInfo.CurrentRoom.Pokers[1].PokerNumber =  message:PopByte()
    GameData.RoomInfo.CurrentRoom.Pokers[1].Visible = true
    -- 虎牌
    GameData.RoomInfo.CurrentRoom.Pokers[2] = { }
    GameData.RoomInfo.CurrentRoom.Pokers[2].PokerType = message:PopByte()
    GameData.RoomInfo.CurrentRoom.Pokers[2].PokerNumber =  message:PopByte()
    GameData.RoomInfo.CurrentRoom.Pokers[2].Visible = true
end

-- 结算状态数据解析
function NetMsgHandler.LHDParseAndSetSettlement(message)
    GameData.RoomInfo.CurrentRoom.GameResult = message:PopByte()
    local tWinGold = message:PopInt64()
    local tCurrentGold = message:PopInt64()
    GameData.RoomInfo.CurrentRoom.MasterWinGold = tWinGold
    GameData.RoomInfo.CurrentRoom.MasterCurrentGold = tCurrentGold
    local count = message:PopUInt16()
    for index = 1, count, 1 do
        local winCode = message:PopByte()
        local winValue = message:PopInt64()
        GameData.RoomInfo.CurrentRoom.WinGold[LHD_WIN_AREA_CODE[winCode]] = { BetValue = 0, WinGold = winValue, IsPayOff = 0 }
    end

    if count > 0 then
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyWinGold, nil)
    end
end

--============================================================================
--=================[CS_LHD_Bet] [1259]========================================

-- 押注区域被点击了
function NetMsgHandler.Send_CS_LHD_Bet(areaType, betValue)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(areaType)
    message:PushInt64(betValue)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Bet, message, false)
end

-- 处理收到服务器 押注结果 消息
function NetMsgHandler.Received_CS_LHD_Bet(message)
    local resultType = message:PopByte()
    local roleID = message:PopUInt32()
    local areaType = message:PopByte()
    local betValue = message:PopInt64()

    local ErrorValue = 0

    if resultType == 0 then
        local eventArg = 1
        if (roleID == GameData.RoleInfo.AccountID) then
            if GameData.RoomInfo.CurrentRoom.BetValues[areaType] == nil then
                GameData.RoomInfo.CurrentRoom.BetValues[areaType] = 0
            end
            GameData.RoomInfo.CurrentRoom.BetValues[areaType] = GameData.RoomInfo.CurrentRoom.BetValues[areaType] + betValue
            eventArg = 2
        end

        if GameData.RoomInfo.CurrentRoom.TotalBetValues[areaType] == nil then
            GameData.RoomInfo.CurrentRoom.TotalBetValues[areaType] = 0
        end

        GameData.RoomInfo.CurrentRoom.TotalBetValues[areaType] = GameData.RoomInfo.CurrentRoom.TotalBetValues[areaType] + betValue
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetValue, eventArg)
    end

    if resultType == 8 or resultType == 9 or resultType == 11 then
        ErrorValue = message:PopInt64() /10000
    end

    local betChipEventArg = { RoleID = roleID, AreaType = areaType, BetValue = betValue, ResultType = resultType ,ErrorValue = ErrorValue }
    -- 调用下注结果
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyBetResult, betChipEventArg)

end

--============================================================================
--=================[S_LHD_Game_Player_Count] [1260]===========================

function NetMsgHandler.Received_S_LHD_Game_Player_Count(message)
    local tRoleCount = message:PopUInt16()
    GameData.RoomInfo.CurrentRoom.RoleCount = tRoleCount
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoleCount, tRoleCount)
end

--============================================================================
--=================[S_LHD_Update_Banker] [1261]===============================
-- 庄家信息刷新
function NetMsgHandler.Received_S_LHD_Update_Banker(message)
    local lastBankerName = GameData.RoomInfo.CurrentRoom.BankerInfo.Name
    
    if GameData.RoomInfo.CurrentRoom.BankerInfo == nil then
        GameData.RoomInfo.CurrentRoom.BankerInfo = { }
    end
    GameData.RoomInfo.CurrentRoom.BankerInfo.ID = message:PopUInt32()
    GameData.RoomInfo.CurrentRoom.BankerInfo.Name = message:PopString()
    GameData.RoomInfo.CurrentRoom.BankerInfo.Gold = message:PopInt64()
    -- 庄家剩余局数
    GameData.RoomInfo.CurrentRoom.BankerInfo.LeftCount = message:PopByte()
    -- 头像ID
    GameData.RoomInfo.CurrentRoom.BankerInfo.HeadIcon = message:PopByte()
    GameData.RoomInfo.CurrentRoom.BankerInfo.strLoginIP = message:PopString()
    GameData.RoomInfo.CurrentRoom.BankerInfo.IsLastForceDownBanker = message:PopByte() == 1


    if GameData.RoomInfo.CurrentRoom.BankerInfo.IsLastForceDownBanker then
        CS.BubblePrompt.Show(string.format(data.GetString("Down_Banker_Tips_Force"), lastBankerName), "LHDGameUI")
    end

    CS.BubblePrompt.Show(string.format(data.GetString("Update_Banker_Tips"), GameData.RoomInfo.CurrentRoom.BankerInfo.Name), "LHDGameUI")

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBankerInfo, 1)
end

--============================================================================
--=================[S_LHD_Update_Banker_Gold] [1262]==========================
-- 庄家金币+剩余当庄局数更新
function NetMsgHandler.Received_S_LHD_Update_Banker_Gold(message)
    GameData.RoomInfo.CurrentRoom.BankerInfo.Gold = message:PopInt64()
    GameData.RoomInfo.CurrentRoom.BankerInfo.LeftCount = message:PopByte()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBankerInfo, 1)
end

--============================================================================
--=================[CS_LHD_Request_Role_List] [1263]==========================

function NetMsgHandler.Send_CS_LHD_Request_Role_List()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Request_Role_List, message, true)
end

function NetMsgHandler.Received_CS_LHD_Request_Role_List(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local count = message:PopUInt16()
        local playerList = { }
        for index = 1, count, 1 do
            local player = { }
            player.AccountID = message:PopUInt32()
            player.GoldCount = message:PopInt64()
            player.HeadIcon = message:PopByte()
            player.strLoginIP = message:PopString()
            playerList[index] = player
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateRoomPlayerList, playerList)
    else
        CS.BubblePrompt.Show(data.GetString("Role_List_Error" .. resultType), "LHDGameUI")
    end
end

--============================================================================
--=================[CS_LHD_Up_Banker_List] [1264]=============================

function NetMsgHandler.Send_CS_LHD_Up_Banker_List()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Up_Banker_List, message, false)
end

function NetMsgHandler.Received_CS_LHD_Up_Banker_List(message)
    local resultType = message:PopByte()
    local count = message:PopUInt16()
    GameData.RoomInfo.CurrentRoom.BankerList = { }
    for index = 1, count, 1 do
        local bankerInfo = { }
        bankerInfo.ID = message:PopUInt32()
        bankerInfo.Name = message:PopString()
        bankerInfo.GoldCount = message:PopInt64()
        bankerInfo.VipLevel = message:PopByte()
        bankerInfo.strLoginIP = message:PopString()
        GameData.RoomInfo.CurrentRoom.BankerList[index] = bankerInfo
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBankerList, nil)
end

--============================================================================
--=================[CS_LHD_Up_Banker] [1265]==================================

function NetMsgHandler.Send_CS_LHD_Up_Banker()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Up_Banker, message, false)
end

function NetMsgHandler.Received_CS_LHD_Up_Banker(message)
    local resultType = message:PopByte();
    local showMsg = data.GetString("Up_Bank_Error_" .. resultType)
    if resultType == 4 then
        local roomConfig = data.RoomConfig[GameData.RoomInfo.CurrentRoom.TemplateID]
        if roomConfig ~= nil then
            showMsg = string.format(showMsg, lua_NumberToStyle1String(roomConfig.UpBankerGold))
        end
    end
    CS.BubblePrompt.Show(showMsg, "LHDGameUI");
end

--============================================================================
--=================[CS_LHD_Down_Banker] [1266]================================

function NetMsgHandler.Send_CS_LHD_Down_Banker()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_LHD_Down_Banker, message, false)
end

function NetMsgHandler.Received_CS_LHD_Down_Banker(message)
    local resultType = message:PopByte()
    CS.BubblePrompt.Show(data.GetString("Down_Banker_Error_" .. resultType), "LHDGameUI")
end



