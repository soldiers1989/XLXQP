--[[
   文件名称:BJLGameMgr.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

if BJLGameMgr == nil then
    BJLGameMgr =
    {
    }
end

--==============================--
--desc:百家乐组局房间初始化
--time:2018-01-12 04:55:50
--@return 
--==============================--
function BJLGameMgr:InitRoomInfo(roomTypeParam)
    local tNewRoom = BJLRoom:New()
    tNewRoom:Init(true, roomTypeParam)
    GameData.RoomInfo.CurrentRoom = tNewRoom
end

function BJLGameMgr:UpdateRoomCountDown( deltaValue )
    -- body
    GameData.RoomInfo.CurrentRoom.CountDown = GameData.RoomInfo.CurrentRoom.CountDown - deltaValue
end

--============================================================================
--=================[龙虎斗]相关协议[1251~1266]解析==============================

--============================================================================
--=================[CS_BJL_Hall_Room] [1271]==================================
--==============================--
--desc:请求百家乐匹配房间在线人数
--time:2018-01-29 03:21:03
--@return 
--==============================--
function BJLGameMgr.Send_CS_BJL_Hall_Room()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BJL_Hall_Room, message, false)
end

function BJLGameMgr.Received_CS_BJL_Hall_Room(message)
    local count  = message:PopUInt16()
    local currentTime = CS.UnityEngine.Time.realtimeSinceStartup
    for index = 1, count, 1 do
        local tBJLStatistics  =  NetMsgHandler.NewStatisticsInfo()
        tBJLStatistics.Index  = message:PopByte()
        tBJLStatistics.RoomID  = message:PopUInt32()

        local roundCount = message:PopUInt16()
        for round = 1, roundCount, 1 do
            table.insert(tBJLStatistics.Trend, message:PopByte())
        end
        BJLGameMgr.ParseRightTrend(tBJLStatistics, roundCount)

        tBJLStatistics.Counts.LongWin = message:PopByte()
        tBJLStatistics.Counts.HuWin = message:PopByte()
        tBJLStatistics.Counts.HeJu = message:PopByte()
        tBJLStatistics.Counts.LongJinHua = message:PopByte()
        tBJLStatistics.Counts.HuJinHua = message:PopByte()
        tBJLStatistics.Counts.LongHuBaoZi = message:PopByte()
        tBJLStatistics.Round.CurrentRound = message:PopByte()

        
        tBJLStatistics.Counts.RoleCount = message:PopUInt16()
        tBJLStatistics.Time = currentTime
        GameData.RoomInfo.StatisticsInfo[tBJLStatistics.RoomID] = tBJLStatistics
        local eventArgs = { RoomType = 4, Index= tBJLStatistics.Index, RoomID = tBJLStatistics.RoomID, OperationType = 0 }
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics, eventArgs)
    end
end

function BJLGameMgr.Send_CS_BJL_Hall_Room_New8()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BJL_Hall_Room_New8, message, false)
end

function BJLGameMgr.Received_CS_BJL_Hall_Room_New8(message)
    local count  = message:PopUInt16()
    GameData.RoleInfo.BRTRoomAmount = count;
    local eventArgs = {};
    local currentTime = CS.UnityEngine.Time.realtimeSinceStartup
    for index = 1, count, 1 do
        local tBJLStatistics  =  NetMsgHandler.NewStatisticsInfo()
        tBJLStatistics.Index  = message:PopByte()
        tBJLStatistics.RoomID  = message:PopUInt32()

        local roundCount = message:PopUInt16()
        for round = 1, roundCount, 1 do
            table.insert(tBJLStatistics.Trend, message:PopByte())
        end
        BJLGameMgr.ParseRightTrend(tBJLStatistics, roundCount)

        tBJLStatistics.Counts.LongWin = message:PopByte()
        tBJLStatistics.Counts.HuWin = message:PopByte()
        tBJLStatistics.Counts.HeJu = message:PopByte()
        tBJLStatistics.Counts.LongJinHua = message:PopByte()
        tBJLStatistics.Counts.HuJinHua = message:PopByte()
        tBJLStatistics.Counts.LongHuBaoZi = message:PopByte()
        tBJLStatistics.Round.CurrentRound = message:PopByte()


        tBJLStatistics.Counts.RoleCount = message:PopUInt16()
        tBJLStatistics.Time = currentTime
        GameData.RoomInfo.StatisticsInfo[tBJLStatistics.RoomID] = tBJLStatistics
        local tempEventArgs = { RoomType = 4, Index= tBJLStatistics.Index, RoomID = tBJLStatistics.RoomID, OperationType = 0 }
        eventArgs[index] = tBJLStatistics;
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics_New8, eventArgs);
end

-- 右侧路单解析
function BJLGameMgr.ParseRightTrend(statisticParam, roundCount)
    if roundCount > 0 then
        -- 本局已有路单信息
        local tHeValue = BJL_WIN_CODE.HE
        local tXDuiZiValue = BJL_WIN_CODE.LONGDUIZI
        local tZDuiZiValue = BJL_WIN_CODE.HUDUIZI

        local tHeadValue = statisticParam.Trend[1]
        local tHeadIsXDui = CS.Utility.GetLogicAndValue(tHeadValue, tXDuiZiValue) == tXDuiZiValue
        local tHeadIsZDui = CS.Utility.GetLogicAndValue(tHeadValue, tZDuiZiValue) == tZDuiZiValue
        
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
                local tXDui = CS.Utility.GetLogicAndValue(newValue, tXDuiZiValue) == tXDuiZiValue
                local tZDui = CS.Utility.GetLogicAndValue(newValue, tZDuiZiValue) == tZDuiZiValue

                if not tIsHe2  then
                    tRounRBeginIndex = roundR
                    break
                else
                    statisticParam.Trend_RHeadHeCount = statisticParam.Trend_RHeadHeCount + 1
                    if not tHeadIsXDui and tXDui then
                        statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tXDuiZiValue
                        tHeadIsXDui = true
                    end
                    if not tHeadIsZDui and  tZDui then
                        statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tZDuiZiValue
                        tHeadIsZDui = true
                    end
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

            local tLastXDui = CS.Utility.GetLogicAndValue(tTrendRValue, tXDuiZiValue) == tXDuiZiValue
            local tLastZDui = CS.Utility.GetLogicAndValue(tTrendRValue, tZDuiZiValue) == tZDuiZiValue

            if statisticParam.Trend_RHeadHeCount > 0 then
                -- 整合头部和局信息
                local tHeadXDui = CS.Utility.GetLogicAndValue(statisticParam.Trend_RHeadValue, tXDuiZiValue) == tXDuiZiValue
                local tHeadZDui = CS.Utility.GetLogicAndValue(statisticParam.Trend_RHeadValue, tZDuiZiValue) == tZDuiZiValue
                if not tLastXDui and tHeadXDui then
                    tLastValue.TrendRValue = tLastValue.TrendRValue + tXDuiZiValue
                    tLastXDui = true
                end
                if not tLastZDui and tHeadZDui then
                    tLastValue.TrendRValue = tLastValue.TrendRValue + tZDuiZiValue
                    tLastZDui = true
                end
            else
                -- 头部无和局信息
            end
            table.insert(statisticParam.Trend_R, tLastValue)
            -- 过滤和局信息
            for i = tRounRBeginIndex + 1, roundCount do
                local tTrend = statisticParam.Trend[i]
                local tIsHe = CS.Utility.GetLogicAndValue(tTrend, tHeValue) == tHeValue
                if tIsHe then
                    tLastValue.TrendRHeCount = tLastValue.TrendRHeCount + 1
                    local tXDui = CS.Utility.GetLogicAndValue(tTrend, tXDuiZiValue) == tXDuiZiValue
                    local tZDui = CS.Utility.GetLogicAndValue(tTrend, tZDuiZiValue) == tZDuiZiValue
                    if not tLastXDui and  tXDui then
                        tLastValue.TrendRValue = tLastValue.TrendRValue + tXDuiZiValue
                        tLastXDui = true
                    end
                    if not tLastZDui and tZDui  then
                        tLastValue.TrendRValue = tLastValue.TrendRValue + tZDuiZiValue
                        tLastZDui = true
                    end
                else
                    tLastValue = {TrendRValue = tTrend, TrendRHeCount = 0}
                    tLastXDui = CS.Utility.GetLogicAndValue(tTrend, tXDuiZiValue) == tXDuiZiValue
                    tLastZDui = CS.Utility.GetLogicAndValue(tTrend, tZDuiZiValue) == tZDuiZiValue
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
function BJLGameMgr.AppendRightStatistic(statisticParam, trendParam)
    local tHeValue = BJL_WIN_CODE.HE
    local tXDuiZiValue = BJL_WIN_CODE.LONGDUIZI
    local tZDuiZiValue = BJL_WIN_CODE.HUDUIZI
    local tNewIsHe = CS.Utility.GetLogicAndValue(trendParam, tHeValue) == tHeValue
    local tNewIsXDui = CS.Utility.GetLogicAndValue(trendParam, tXDuiZiValue) == tXDuiZiValue
    local tNewIsZDui = CS.Utility.GetLogicAndValue(trendParam, tZDuiZiValue) == tZDuiZiValue

    local tRightCount = #statisticParam.Trend_R

    if tNewIsHe then
        if tRightCount > 0 then
            -- 已经有路单信息 追加和局信息
            local tRightLast = statisticParam.Trend_R[tRightCount]
            tRightLast.TrendRHeCount = tRightLast.TrendRHeCount + 1
            local tXDui = CS.Utility.GetLogicAndValue(tRightLast.TrendRValue, tXDuiZiValue) == tXDuiZiValue
            local tZDui = CS.Utility.GetLogicAndValue(tRightLast.TrendRValue, tZDuiZiValue) == tZDuiZiValue
            if not tXDui and  tNewIsXDui then
                tRightLast.TrendRValue = tRightLast.TrendRValue + tXDuiZiValue
            end
            if not tZDui and tNewIsZDui  then
                tRightLast.TrendRValue = tRightLast.TrendRValue + tZDuiZiValue
            end
            statisticParam.Trend_R[tRightCount] = tRightLast
            -- print("*****BJL LUDAN 333:==1=1", tRightLast.TrendRValue, tRightLast.TrendRHeCount)
        else
            -- 还没有路单信息 追加和局信息
            if statisticParam.Trend_RHeadHeCount > 0 then
                -- 已经有和局累计
                local tTrendHe = statisticParam.Trend_RHeadValue
                local tXDui = CS.Utility.GetLogicAndValue(tTrendHe, tXDuiZiValue) == tXDuiZiValue
                local tZDui = CS.Utility.GetLogicAndValue(tTrendHe, tZDuiZiValue) == tZDuiZiValue
                if not tXDui and  tNewIsXDui then
                    statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tXDuiZiValue
                end
                if not tZDui and tNewIsZDui  then
                    statisticParam.Trend_RHeadValue = statisticParam.Trend_RHeadValue + tZDuiZiValue
                end
                statisticParam.Trend_RHeadHeCount = statisticParam.Trend_RHeadHeCount + 1
                -- print("*****BJL LUDAN 333:==1=2", statisticParam.Trend_RHeadValue, statisticParam.Trend_RHeadHeCount)
            else
                -- 无和局信息
                statisticParam.Trend_RHeadHeCount = 1
                statisticParam.Trend_RHeadValue = trendParam
                -- print("*****BJL LUDAN 333:==1=3", statisticParam.Trend_RHeadValue, statisticParam.Trend_RHeadHeCount)
            end
        end
    else
        local tAppendData = {TrendRValue = trendParam, TrendRHeCount = 0}
        if tRightCount > 0 then
            -- 已经有路单信息 ==>直接追加一条新的信息
            table.insert(statisticParam.Trend_R, tAppendData)
            -- print("*****BJL LUDAN 333:==2=1", tAppendData.TrendRValue, tAppendData.TrendRHeCount)
        else
            -- 还没有路单信息
            if statisticParam.Trend_RHeadHeCount > 0 then
                -- 之前已经有和局累计
                local tTrendHe = statisticParam.Trend_RHeadValue
                local tXDui = CS.Utility.GetLogicAndValue(tTrendHe, tXDuiZiValue) == tXDuiZiValue
                local tZDui = CS.Utility.GetLogicAndValue(tTrendHe, tZDuiZiValue) == tZDuiZiValue
                if not tNewIsXDui and  tXDui then
                    tAppendData.TrendRValue = tAppendData.TrendRValue + tXDuiZiValue
                end
                if not tNewIsZDui and tZDui  then
                    tAppendData.TrendRValue = tAppendData.TrendRValue + tZDuiZiValue
                end
                tAppendData.TrendRHeCount = statisticParam.Trend_RHeadHeCount
                table.insert(statisticParam.Trend_R, tAppendData)
                -- print("*****BJL LUDAN 333:==2=2", tAppendData.TrendRValue, tAppendData.TrendRHeCount)
            else
                -- 之前无任何信息
                table.insert(statisticParam.Trend_R, tAppendData)
                -- print("*****BJL LUDAN 333:==2=3", tAppendData.TrendRValue, tAppendData.TrendRHeCount)
            end
        end
    end

    local tCount = #statisticParam.Trend_R
    return tNewIsHe, statisticParam.Trend_R[tCount]
end

--==============================--
--desc:大路 矩阵数据解析
--@statisticParam: 路单详情
--@return 
--==============================--
function BJLGameMgr.MatrixTrendParse(statisticParam)
    -- 矩阵路单记录值重置
    statisticParam.Trend_Matrix = {}
    statisticParam.Trend_List = {}
    statisticParam.posX = 0
    statisticParam.posY = 0
    statisticParam.Trend_LastPos = 0
    statisticParam.Trend_LastUpdateValue = 0

    local tTrend = statisticParam.Trend_R
    local tTrendCount = #tTrend
    for i = 1, tTrendCount do
        BJLGameMgr.AppendMatrixTrendValue(statisticParam.Trend_R[i], statisticParam)
    end
    -- for k1, v1 in pairs(statisticParam.Trend_Matrix) do
    --     local strDesc = string.format("=====[%d]:",k1)
    --     for k2, v2 in pairs(v1)do
    --         strDesc = string.format("%s:[%d,%d][%d,%d,%d]:", strDesc, k1, k2, v2.x, v2.y, v2.value)
    --     end
    --     print("=====Desc:", strDesc)
    -- end
end

--==============================--
--desc:大路 矩阵路单追加
--@newValue: 新路单
--@statisticParam: 数据详情
--@return 
--==============================--
function BJLGameMgr.AppendMatrixTrendValue(newValue, statisticParam)
    local posX = statisticParam.posX
    local posY = statisticParam.posY
    local tValue = newValue.TrendRValue
    local tLastPos = statisticParam.Trend_LastPos
    local tLastUpdateValue = statisticParam.Trend_LastUpdateValue
    
    if tLastPos == 0 then
        posX = 1
        posY = 1
        tLastUpdateValue = BJLGameMgr.GetTrend2UpdateValue(tValue)
        -- print("=====Append Mat 1:", posX, posY)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(tValue, tLastUpdateValue) == tLastUpdateValue then
            -- 本次与上一次开奖结果一致 
            posX = posX + 1
            posY = posY
        else
            -- 开辟新行
            posX = 1
            posY = posY + 1
            tLastUpdateValue = BJLGameMgr.GetTrend2UpdateValue(tValue)
        end
        -- print("=====Append Mat 2:", posX, posY)
    end
    -- 矩阵元素nil 处理 因为是二维数组 必须确保一维元素非空
    if statisticParam.Trend_Matrix[posX] == nil then
        statisticParam.Trend_Matrix[posX] = {}
    end
    statisticParam.posX = posX
    statisticParam.posY = posY
    tLastPos = tLastPos + 1
    local tMatData = { value = tValue, x = posX, y = posY, pos = tLastPos}
    -- print(string.format("===matrix==[%d,%d] = {vale=%d, pos=%d}", tMatData.x, tMatData.y, tMatData.value, tMatData.pos))
    statisticParam.Trend_Matrix[posX][posY] = tMatData
    statisticParam.Trend_List[tLastPos] = tMatData
    statisticParam.Trend_LastPos = tLastPos
    statisticParam.Trend_LastUpdateValue = tLastUpdateValue
end

function BJLGameMgr.GetTrend2UpdateValue(value)
    if CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.LONG) == BJL_WIN_CODE.LONG then
        return BJL_WIN_CODE.LONG
    elseif CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.HU) == BJL_WIN_CODE.HU then
        return BJL_WIN_CODE.HU
    else
        return BJL_WIN_CODE.HE
    end
end

--==============================--
--desc:[大眼仔]路单 解析
--@statisticParam: 路单详情
--@return 
--==============================--
function BJLGameMgr.BigEyeTrendParse(statisticParam)
    -- 矩阵路单记录值重置
    statisticParam.Trend_BigEye = {}        -- 右侧[大眼仔]路单
    if not BJLGameMgr.CanParsePredictionTrendByType(statisticParam, 1) then
        return
    end
    -- tMatData = { value = tValue, x = posX, y = posY, pos = tLastPos}
    -- [1,2] -->[2,2]
    
    local tHeadIndex = statisticParam.Trend_Matrix[1][2].pos + 1
    for i = tHeadIndex, #statisticParam.Trend_List do
        local tPreData = statisticParam.Trend_List[i-1]
        local tResult = BJLGameMgr.PredictionTrendBigEye(statisticParam.Trend_Matrix, tPreData, statisticParam.Trend_List[i])
        if tResult ~= nil then
            table.insert(statisticParam.Trend_BigEye, tResult)
        else
            print("=====BigEye TrendParse error 1=====")
        end
    end
end

--==============================--
--desc:是否可以开始解析对应路单走势预测
--@statisticParam: 路单矩阵数据
--@trendTypeParam: 需要被预测值
--@return true false
--==============================--
function BJLGameMgr.CanParsePredictionTrendByType(statisticParam, trendTypeParam)
    if trendTypeParam == nil or trendTypeParam > 3 or trendTypeParam < 1 then
        trendTypeParam = 1
    end
    local posX = 1
    local posY = 1
    if trendTypeParam == 1 then
        -- 大眼仔路
        posX = 1
        posY = 2
    elseif trendTypeParam == 2 then
        -- 小路
        posX = 1
        posY = 3
    else
        -- 曱甴路
        posX = 1
        posY = 4
    end

    if statisticParam.Trend_Matrix[posX] == nil or statisticParam.Trend_Matrix[posX][posY] == nil then
        -- 未达到记录标准
        print("===== 子路起始位置 为空 111")
        return false
    end
    local tHeadIndex = statisticParam.Trend_Matrix[posX][posY].pos + 1
    if statisticParam.Trend_List[tHeadIndex] == nil then
        -- 还未出路单为非和记录
        print("===== 子路起始记录 为空 111")
        return false
    end

    return true
end

--==============================--
--desc:是否可以开始对应路单走势预测
--@statisticParam: 路单矩阵数据
--@trendTypeParam: 需要被预测值
--@return true false
--==============================--
function BJLGameMgr.CanPredictionTrendByType(statisticParam, trendTypeParam)
    if trendTypeParam == nil or trendTypeParam > 3 or trendTypeParam < 1 then
        trendTypeParam = 1
    end
    local posX = 1
    local posY = 1
    if trendTypeParam == 1 then
        -- 大眼仔路
        posX = 1
        posY = 2
    elseif trendTypeParam == 2 then
        -- 小路
        posX = 1
        posY = 3
    else
        -- 曱甴路
        posX = 1
        posY = 4
    end

    if statisticParam.Trend_Matrix[posX] == nil or statisticParam.Trend_Matrix[posX][posY] == nil then
        -- 未达到记录标准
        print("===== 子路起始位置 为空 111")
        return false
    end

    return true
end

--==============================--
--desc:尝试追加 大眼仔路单
--@statisticParam: 路单矩阵数据
--@return
--==============================--
function BJLGameMgr.TryAppendBigEyeTrend(statisticParam)
    if not BJLGameMgr.CanParsePredictionTrendByType(statisticParam, 1) then
        return
    end
    local tHeadIndex = #statisticParam.Trend_List
    local tPreData = statisticParam.Trend_List[tHeadIndex-1]
    local tResultData = statisticParam.Trend_List[tHeadIndex]

    local tResult = BJLGameMgr.PredictionTrendBigEye(statisticParam.Trend_Matrix, tPreData, tResultData)
    table.insert(statisticParam.Trend_BigEye, tResult)
end

--==============================--
--desc:[大眼仔]路单预测结果
--@matrixParam: 路单矩阵数据
--@pointAParam: 需要被预测值
--@resultParam: 实际出现的值
--@return 
--==============================--
function BJLGameMgr.PredictionTrendBigEye(matrixParam, pointAParam, resultParam)
    --起始点A[1，2] -- 预测值B[2,2]-->预测值同排前一列C[2,1]--> C点上一个位置D[1,1]
    --起始点A[2，2] -- 预测值B[3,2]-->预测值同排前一列C[3,1]--> C点上一个位置D[2,1]

    local tPointA = {x = pointAParam.x, y = pointAParam.y}
    local tPointB = {x = tPointA.x + 1, y = tPointA.y}
    local tPointC = {x = tPointB.x, y = tPointB.y - 1}
    local tPointD = {x = tPointC.x - 1, y = tPointC.y}
    -- print(string.format("A[%d,%d]-->B[%d,%d]-->C[%d,%d]-->D[%d,%d]", tPointA.x, tPointA.y, tPointB.x, tPointB.y, tPointC.x, tPointC.y, tPointD.x, tPointD.y))
    local result = 0    -- 0 空 1蓝色 2红色
    if matrixParam[tPointC.x] == nil or matrixParam[tPointC.x][tPointC.y] == nil  then
        if matrixParam[tPointD.x] == nil or matrixParam[tPointD.x][tPointD.y] == nil then
            result = 2
        else
            result = 1
        end
    else
        result = 2
    end
    -- print("===== 大眼仔路 预测111:", result)
    -- 4:和 1:闲家 2:庄家
    local tXianValue = BJL_WIN_CODE.LONG
    local tZhuangValue = BJL_WIN_CODE.HU
    local tIsXian1 = CS.Utility.GetLogicAndValue(pointAParam.value, tXianValue) == tXianValue
    local tIsXian2 = CS.Utility.GetLogicAndValue(resultParam.value, tXianValue) == tXianValue
    -- print("===== 大眼仔路 预测222:", pointAParam.value, resultParam.value, tIsXian1, tIsXian2, pointAParam.pos - 2)
    if tIsXian1 ~= tIsXian2 then
        -- 预测值 与 实际结果不一致 结果取反
        if result == 1 then
            result = 2
        else
            result = 1
        end
    end
    -- print("===== 大眼仔路 预测333:", result)
    return result
end

--==============================--
--desc:[小路]路单 解析
--@statisticParam: 路单详情
--@return 
--==============================--
function BJLGameMgr.SmallTrendParse(statisticParam)
    -- 矩阵路单记录值重置
    statisticParam.Trend_Small = {}        -- 右侧[小路]路单
    if not BJLGameMgr.CanParsePredictionTrendByType(statisticParam, 2) then
        return
    end
    -- tMatData = { value = tValue, x = posX, y = posY, pos = tLastPos}
    -- [1,2] -->[2,2]

    local tHeadIndex = statisticParam.Trend_Matrix[1][3].pos + 1
    for i = tHeadIndex, #statisticParam.Trend_List do
        local tPreData = statisticParam.Trend_List[i-1]
        local tResult = BJLGameMgr.PredictionTrendSmall(statisticParam.Trend_Matrix, tPreData, statisticParam.Trend_List[i])
        if tResult ~= nil then
            table.insert(statisticParam.Trend_Small, tResult)
        else
            print("=====Small TrendParse error 1")
        end
    end
end

--==============================--
--desc:尝试追加 [小路]路单
--@statisticParam: 路单矩阵数据
--@return
--==============================--
function BJLGameMgr.TryAppendSmallTrend(statisticParam)
    if not BJLGameMgr.CanParsePredictionTrendByType(statisticParam, 2) then
        return
    end
    local tHeadIndex = #statisticParam.Trend_List
    local tPreData = statisticParam.Trend_List[tHeadIndex-1]
    local tResultData = statisticParam.Trend_List[tHeadIndex]

    local tResult = BJLGameMgr.PredictionTrendSmall(statisticParam.Trend_Matrix, tPreData, tResultData)
    table.insert(statisticParam.Trend_Small, tResult)
end

--==============================--
--desc:[小路]路单预测结果
--@matrixParam: 矩阵路单
--@pointAParam: 起始点
--@resultParam: 结果值
--@return 
--==============================--
function BJLGameMgr.PredictionTrendSmall(matrixParam, pointAParam, resultParam)
    -- 当第3列第一排有填入后，下一次开奖（非和）则开始记录小路
    -- 前前列（小路）位置是否为空
    --起始点A[1，3] -- 预测值B[2,3]-->预测值同排前二列C[2,1]--> C点上一个位置D[1,1]
    --起始点A[2，3] -- 预测值B[3,3]-->预测值同排前二列C[3,1]--> C点上一个位置D[2,1]

    local tPointA = {x = pointAParam.x, y = pointAParam.y}
    local tPointB = {x = tPointA.x + 1, y = tPointA.y}
    local tPointC = {x = tPointB.x, y = tPointB.y - 2}
    local tPointD = {x = tPointC.x - 1, y = tPointC.y}
    local result = 0    -- 0 空 1蓝色 2红色
    if matrixParam[tPointC.x] == nil or matrixParam[tPointC.x][tPointC.y] == nil  then
        if matrixParam[tPointD.x] == nil or matrixParam[tPointD.x][tPointD.y] == nil then
            result = 2
        else
            result = 1
        end
    else
        result = 2
    end
    -- print("===== 小路 预测111:", result)
    -- 4:和 1:闲家 2:庄家
    local tXianValue = BJL_WIN_CODE.LONG
    local tZhuangValue = BJL_WIN_CODE.HU
    local tIsXian1 = CS.Utility.GetLogicAndValue(pointAParam.value, tXianValue) == tXianValue
    local tIsXian2 = CS.Utility.GetLogicAndValue(resultParam.value, tXianValue) == tXianValue
    -- print("===== 小路 预测222:", pointAParam.value, resultParam.value, tIsXian1, tIsXian2)
    if tIsXian1 ~= tIsXian2 then
        -- 预测值 与 实际结果不一致 结果取反
        if result == 1 then
            result = 2
        else
            result = 1
        end
    end
    -- print("===== 小路 预测333:", result)
    return result
end

--==============================--
--desc:[曱甴路(yuēyóu)]路单 解析
--@statisticParam: 路单详情
--@return 
--==============================--
function BJLGameMgr.YueYouTrendParse(statisticParam)
    -- 矩阵路单记录值重置
    statisticParam.Trend_YueYou = {}        -- 右侧[曱甴路]路单
    if not BJLGameMgr.CanParsePredictionTrendByType(statisticParam, 3) then
        return
    end
    -- tMatData = { value = tValue, x = posX, y = posY, pos = tLastPos}
    -- [1,2] -->[2,2]

    local tHeadIndex = statisticParam.Trend_Matrix[1][4].pos + 1
    for i = tHeadIndex, #statisticParam.Trend_List do
        local tPreData = statisticParam.Trend_List[i-1]
        local tResult = BJLGameMgr.PredictionTrendYueYou(statisticParam.Trend_Matrix, tPreData, statisticParam.Trend_List[i])
        if tResult ~= nil then
            table.insert(statisticParam.Trend_YueYou, tResult)
        else
            print("=====YueYou TrendParse error 1=====")
        end
    end
end

--==============================--
--desc:尝试追加 [曱甴路]路单
--@statisticParam: 路单矩阵数据
--@return
--==============================--
function BJLGameMgr.TryAppendYueYouTrend(statisticParam)
    if not BJLGameMgr.CanParsePredictionTrendByType(statisticParam, 3) then
        return
    end
    local tHeadIndex = #statisticParam.Trend_List
    local tPreData = statisticParam.Trend_List[tHeadIndex-1]
    local tResultData = statisticParam.Trend_List[tHeadIndex]

    local tResult = BJLGameMgr.PredictionTrendYueYou(statisticParam.Trend_Matrix, tPreData, tResultData)
    table.insert(statisticParam.Trend_YueYou, tResult)
end

--==============================--
--desc:[曱甴路(yuēyóu)]路单预测结果
--@typeParam:
--@levelParam:
--@return 
--==============================--
function BJLGameMgr.PredictionTrendYueYou(matrixParam, pointAParam, resultParam)
    -- 当第4列第一排有填入后，下一次开奖（非和）则开始记录曱甴路
    -- 前前前列（曱甴路）为空?
    -- 起始点A[1，4] -- 预测值B[2,4]-->预测值同排前一列C[2,1]--> C点上一个位置D[1,1]
    -- 起始点A[2，4] -- 预测值B[3,4]-->预测值同排前一列C[3,1]--> C点上一个位置D[2,1]

    local tPointA = {x = pointAParam.x, y = pointAParam.y}
    local tPointB = {x = tPointA.x + 1, y = tPointA.y}
    local tPointC = {x = tPointB.x, y = tPointB.y - 3}
    local tPointD = {x = tPointC.x - 1, y = tPointC.y}
    local result = 0    -- 0 空 1蓝色 2红色
    if matrixParam[tPointC.x] == nil or matrixParam[tPointC.x][tPointC.y] == nil  then
        if matrixParam[tPointD.x] == nil or matrixParam[tPointD.x][tPointD.y] == nil then
            result = 2
        else
            result = 1
        end
    else
        result = 2
    end
    -- print("===== 曱甴路 预测111:", result)
    -- 4:和 1:闲家 2:庄家
    local tXianValue = BJL_WIN_CODE.LONG
    local tZhuangValue = BJL_WIN_CODE.HU
    local tIsXian1 = CS.Utility.GetLogicAndValue(pointAParam.value, tXianValue) == tXianValue
    local tIsXian2 = CS.Utility.GetLogicAndValue(resultParam.value, tXianValue) == tXianValue
    -- print("===== 曱甴路 预测222:", pointAParam.value, resultParam.value, tIsXian1, tIsXian2)
    if tIsXian1 ~= tIsXian2 then
        -- 预测值 与 实际结果不一致 结果取反
        if result == 1 then
            result = 2
        else
            result = 1
        end
    end
    -- print("===== 曱甴路 预测333:", result)
    return result
end

--============================================================================
--=================[CS_BJL_Enter_Room] [1272]=================================

function  BJLGameMgr.Send_CS_BJL_Enter_Room(roomIDParam, roomLvParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomLvParam)
    message:PushUInt32(roomIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BJL_Enter_Room, message, false)
    CS.MatchLoadingUI.Show()
end

function  BJLGameMgr.Received_CS_BJL_Enter_Room(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local roomData = { }
        --房间ID
        local tRoomID = message:PopUInt32()
        local tTemplateID = message:PopByte()
        GameData.RoomInfo.CurrentRoom.RoomID = tRoomID
        GameData.InitCurrentRoomInfo(ROOM_TYPE.BJLRoom, tRoomID)
        GameData.RoomInfo.CurrentRoom.TemplateID = tTemplateID
        HandleBJLGameUIShowState(true)
        --local BRHallUI = CS.WindowManager.Instance:FindWindowNodeByName("BRHallUI")
        --if BRHallUI ~= nil then
        --    BRHallUI.WindowGameObject:SetActive(false)
        --else
        --    print('*********BRHallUI查找失败，请请检查!')
        --end
    else
        CS.MatchLoadingUI.Hide()
        if resultType == 3 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType == 7 then
                local GoldValue = message:PopInt64()
            end
            CS.BubblePrompt.Show(data.GetString("T_1272_" .. resultType), "BJLGameUI")
        end
        NetMsgHandler.ExitRoomToHall(0)
    end
end

-- 龙虎斗GameUI显示处理
function HandleBJLGameUIShowState(activeParam)
    if activeParam then
        local gameNode = CS.WindowManager.Instance:FindWindowNodeByName('BJLGameUI')
        if gameNode == nil then
            -- TODO Iphonex 适配
            local openparam = CS.WindowNodeInitParam("BJLGameUI", true)
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
        CS.WindowManager.Instance:CloseWindow("BJLGameUI", false)
    end
end

--============================================================================
--=================[S_BJL_GameData] [1273]====================================

function BJLGameMgr.Received_S_BJL_GameData(message)
    -- Home 出去 再切换回来时也会调用此接口，重新初始化房间信息
    -- 解析房间的基本信息
    -- 房间ID
    GameData.RoomInfo.CurrentRoom.RoomID = message:PopUInt32()
    -- 房间配置ID
    GameData.RoomInfo.CurrentRoom.TemplateID = message:PopByte()
    -- 以进行游戏局数
    GameData.RoomInfo.CurrentRoom.CurrentRound = message:PopUInt16()
    -- 房间状态
    GameData.RoomInfo.CurrentRoom.RoomState = message:PopByte()
    -- 牌组剩余数量
    GameData.RoomInfo.CurrentRoom.CardCount = message:PopUInt16()
    GameData.RoomInfo.CurrentRoom.CacheCardCount = GameData.RoomInfo.CurrentRoom.CardCount
    -- 当前状态倒计时
    GameData.RoomInfo.CurrentRoom.CountDown = message:PopUInt32() / 1000.0
    -- 下注庄闲下限
    GameData.RoomInfo.CurrentRoom.BetZXMin = message:PopInt64()
    -- 下注庄闲上限
    GameData.RoomInfo.CurrentRoom.BetZXMax = message:PopInt64()
    -- 下注庄闲对下限
    GameData.RoomInfo.CurrentRoom.BetZXDMin = message:PopInt64()
    -- 下注庄闲对上限
    GameData.RoomInfo.CurrentRoom.BetZXDMax = message:PopInt64()
    -- 下注和下限
    GameData.RoomInfo.CurrentRoom.BetHeMin = message:PopInt64()
    -- 下注和上限
    GameData.RoomInfo.CurrentRoom.BetHeMax = message:PopInt64()

    -- print("**BJL** 房间信息:", GameData.RoomInfo.CurrentRoom.RoomState, GameData.RoomInfo.CurrentRoom.CountDown)
    -- 解析自己各区域押注信息
    NetMsgHandler.BJLParseAndSetBetValue(message)
    -- 解析房间各区域总押注信息
    NetMsgHandler.BJLParseAndSetTotalBetValue(message)

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetValue, 3)

    -- 解析已押注到押注区域的筹码信息
    NetMsgHandler.BJLParseAndSetChipsOnBetAreas(message)

    -- 解析扑克牌
    if GameData.RoomInfo.CurrentRoom.RoomState >= BJL_ROOM_STATE.CHECK then
        NetMsgHandler.BJLParsePokerData(message)
    else
        for i = 1, 2 do
            GameData.RoomInfo.CurrentRoom.PokersX[i] = { }
            GameData.RoomInfo.CurrentRoom.PokersX[i].PokerType = i
            GameData.RoomInfo.CurrentRoom.PokersX[i].PokerNumber =  i
            GameData.RoomInfo.CurrentRoom.PokersX[i].Visible = false

            GameData.RoomInfo.CurrentRoom.PokersZ[i] = { }
            GameData.RoomInfo.CurrentRoom.PokersZ[i].PokerType = i
            GameData.RoomInfo.CurrentRoom.PokersZ[i].PokerNumber =  i+2
            GameData.RoomInfo.CurrentRoom.PokersZ[i].Visible = false
        end
    end
    -- 本局结果
    GameData.RoomInfo.CurrentRoom.GameResult = message:PopByte()

    -- 刷新游戏房间状态值
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, GameData.RoomInfo.CurrentRoom.RoomState)

end

-- 解析自己各区域押注信息
function NetMsgHandler.BJLParseAndSetBetValue(message)
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
function NetMsgHandler.BJLParseAndSetTotalBetValue(message)
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
function NetMsgHandler.BJLParseAndSetChipsOnBetAreas(message)
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

--============================================================================
--=================[S_BJL_Game_Statistics] [1274]====================================

-- 返回全部统计信息
function BJLGameMgr.Received_S_BJL_Game_Statistics(message)

    local tBJLStatistics  =  NetMsgHandler.NewStatisticsInfo()
    tBJLStatistics.Index  = message:PopByte()
    tBJLStatistics.RoomID  = message:PopUInt32()

    local roundCount = message:PopUInt16()
    print("===1274==BJL RoundCount:", roundCount)
    for round = 1, roundCount, 1 do
        local tTrend = message:PopByte()
        table.insert(tBJLStatistics.Trend, tTrend)
    end

    BJLGameMgr.ParseRightTrend(tBJLStatistics, roundCount)
    BJLGameMgr.MatrixTrendParse(tBJLStatistics)
    BJLGameMgr.BigEyeTrendParse(tBJLStatistics)
    BJLGameMgr.SmallTrendParse(tBJLStatistics)
    BJLGameMgr.YueYouTrendParse(tBJLStatistics)

    tBJLStatistics.Counts.LongWin = message:PopByte()
    tBJLStatistics.Counts.HuWin = message:PopByte()
    tBJLStatistics.Counts.HeJu = message:PopByte()
    tBJLStatistics.Counts.LongJinHua = message:PopByte()
    tBJLStatistics.Counts.HuJinHua = message:PopByte()
    tBJLStatistics.Counts.LongHuBaoZi = message:PopByte()
    tBJLStatistics.Round.CurrentRound = message:PopByte()

    tBJLStatistics.Counts.RoleCount = message:PopUInt16()
    tBJLStatistics.Time = CS.UnityEngine.Time.realtimeSinceStartup
    
    tBJLStatistics.Round.MaxRound = GameData.RoomInfo.CurrentRoom.MaxRound
    
    GameData.RoomInfo.StatisticsInfo[tBJLStatistics.RoomID] = tBJLStatistics

    local eventArgs = { RoomID = tBJLStatistics.RoomID, OperationType = 0 }
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateStatistics, eventArgs)

    -- print("=====BJL=====Statistics all:", 1274, roundCount)
end

--============================================================================
--=================[S_BJL_Game_Append_Statistics] [1275]======================

-- 返回本局追加路单信息
function BJLGameMgr.Received_S_BJL_Game_Append_Statistics(message)
    print("=====1275=====")
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

    local tIsHe, tNewTrend = BJLGameMgr.AppendRightStatistic(statistics, tTrend)
    print("=====1275=====2", tIsHe)
    if not tIsHe then
        BJLGameMgr.AppendMatrixTrendValue(tNewTrend, statistics)

        BJLGameMgr.TryAppendBigEyeTrend(statistics)
        BJLGameMgr.TryAppendSmallTrend(statistics)
        BJLGameMgr.TryAppendYueYouTrend(statistics)
    end
    statistics.Counts.LongWin = message:PopByte()
    statistics.Counts.HuWin = message:PopByte()
    statistics.Counts.HeJu = message:PopByte()
    statistics.Counts.LongJinHua = message:PopByte()
    statistics.Counts.HuJinHua = message:PopByte()
    statistics.Counts.LongHuBaoZi = message:PopByte()
    statistics.Round.CurrentRound = message:PopByte()

    -- print("=====BJL=====Statistics Append:", 1275)
    GameData.RoomInfo.CurrentRoom.AppendStatisticsEventArgs = eventArgs
end


--============================================================================
--=================[CS_BJL_Exit_Room] [1276]==================================
-- 退出房间请求
function BJLGameMgr.Send_CS_BJL_Exit_Room()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BJL_Exit_Room, message, false)
end

-- 反馈退出房间结果
function BJLGameMgr.Received_CS_BJL_Exit_Room(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        
    else
        CS.BubblePrompt.Show(data.GetString("T_1276_".. resultType), "BJLGameUI")
    end
    NetMsgHandler.ExitRoomToHall(0)
end

--============================================================================
--=================[S_BJL_Next_State] [1277]==================================

-- 组局厅--服务器通知进入下一阶段
function  BJLGameMgr.Received_S_BJL_Next_State(message)
    -- 当前房间状态
    local roomState = message:PopByte()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- print(string.format('[百家乐]====================当前状态:[%d] 房间类型:[%d] Time:[%f]', roomState, tRoomData.RoomType, CS.UnityEngine.Time.time))
    if roomState == BJL_ROOM_STATE.WAIT then
        -- 1等待
        BJLGameMgr.ClearCurrentRoundData()
    elseif roomState == BJL_ROOM_STATE.SHUFFLE then
        -- 2洗牌
        local tCardCount = message:PopUInt16()
        GameData.RoomInfo.CurrentRoom.CardCount = tCardCount
        GameData.RoomInfo.CurrentRoom.CacheCardCount = tCardCount
    elseif roomState == BJL_ROOM_STATE.CUTANI then
        -- 3丢牌动画
        local tPokerType = message:PopByte()
        local tPokerNumber = message:PopByte()
        local tCardCount = message:PopUInt16()
        GameData.RoomInfo.CurrentRoom.CutPoker = { }
        GameData.RoomInfo.CurrentRoom.CutPoker.PokerType = tPokerType
        GameData.RoomInfo.CurrentRoom.CutPoker.PokerNumber = tPokerNumber
        GameData.RoomInfo.CurrentRoom.CutPoker.Visible = true
        GameData.RoomInfo.CurrentRoom.CacheCardCount = GameData.RoomInfo.CurrentRoom.CardCount
        GameData.RoomInfo.CurrentRoom.CardCount = tCardCount
    elseif roomState == BJL_ROOM_STATE.BET then
        -- 4下注
    elseif roomState == BJL_ROOM_STATE.CHECK then
        -- 5亮牌
        NetMsgHandler.BJLParsePokerData(message)
        local tCardCount = message:PopUInt16()
        GameData.RoomInfo.CurrentRoom.CacheCardCount = GameData.RoomInfo.CurrentRoom.CardCount
        GameData.RoomInfo.CurrentRoom.CardCount = tCardCount
    elseif roomState == BJL_ROOM_STATE.SETTLEMENT then
        -- 6结算
        NetMsgHandler.BJLParseAndSetSettlement(message)
    end
    -- 设置组局厅房间状态
    GameData.RoomInfo.CurrentRoom:SetRoomState(roomState)
end

-- 聚龙厅清理本局数据
function BJLGameMgr.ClearCurrentRoundData()
    GameData.RoomInfo.CurrentRoom.BetRankList = { }
    GameData.RoomInfo.CurrentRoom.BetValues = { }
    GameData.RoomInfo.CurrentRoom.TotalBetValues = { }
    GameData.RoomInfo.CurrentRoom.WinGold = { }
    GameData.RoomInfo.CurrentRoom.PokersX = { }
    GameData.RoomInfo.CurrentRoom.PokersZ = { }
    GameData.RoomInfo.CurrentRoom.CutPoker = { }
    GameData.RoomInfo.CurrentRoom.GameResult = 0
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateBetValue, nil)
end

-- 解析扑克牌数据
function NetMsgHandler.BJLParsePokerData(message)
    -- 扑克牌默认值设置
    -- 闲家牌
    local tXianCount = message:PopUInt16()
    for index = 1, tXianCount do
        local tPokerType = message:PopByte()
        local tPokerNumber =  message:PopByte()
        GameData.RoomInfo.CurrentRoom.PokersX[index] = { }
        GameData.RoomInfo.CurrentRoom.PokersX[index].PokerType = tPokerType
        GameData.RoomInfo.CurrentRoom.PokersX[index].PokerNumber = tPokerNumber
        GameData.RoomInfo.CurrentRoom.PokersX[index].Visible = true
    end
    -- 庄家牌
    local tZhuang = message:PopUInt16()
    for index = 1, tZhuang do
        local tPokerType = message:PopByte()
        local tPokerNumber =  message:PopByte()
        GameData.RoomInfo.CurrentRoom.PokersZ[index] = { }
        GameData.RoomInfo.CurrentRoom.PokersZ[index].PokerType = tPokerType
        GameData.RoomInfo.CurrentRoom.PokersZ[index].PokerNumber = tPokerNumber
        GameData.RoomInfo.CurrentRoom.PokersZ[index].Visible = true
    end
end

-- 结算状态数据解析
function NetMsgHandler.BJLParseAndSetSettlement(message)
    local tGameResult = message:PopByte()
    local tWinGold = message:PopInt64()
    GameData.RoomInfo.CurrentRoom.GameResult = tGameResult
    GameData.RoomInfo.CurrentRoom.MasterWinGold = tWinGold
    local count = message:PopUInt16()
    for index = 1, count, 1 do
        local winCode = message:PopByte()
        local winValue = message:PopInt64()
        GameData.RoomInfo.CurrentRoom.WinGold[BJL_WIN_AREA_CODE[winCode]] = { BetValue = 0, WinGold = winValue, IsPayOff = 0 }
    end
end

--============================================================================
--=================[CS_BJL_Bet] [1278]========================================

-- 押注区域被点击了
function BJLGameMgr.Send_CS_BJL_Bet(areaType, betValue)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(areaType)
    message:PushInt64(betValue)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BJL_Bet, message, false)
end

-- 处理收到服务器 押注结果 消息
function BJLGameMgr.Received_CS_BJL_Bet(message)
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
    else
        print("=====1278 下注错误码:", resultType)
    end
    if resultType == 7 or resultType == 8 or resultType == 9 then
        ErrorValue = message:PopInt64()/10000
    end
    local betChipEventArg = { RoleID = roleID, AreaType = areaType, BetValue = betValue, ResultType = resultType, ErrorValue = ErrorValue }
    -- 调用下注结果
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyBetResult, betChipEventArg)

end

--============================================================================
--=================[S_BJL_Game_Player_Count] [1279]===========================

function BJLGameMgr.Received_S_BJL_Game_Player_Count(message)
    local tRoleCount = message:PopUInt16()
    GameData.RoomInfo.CurrentRoom.RoleCount = tRoleCount
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoleCount, tRoleCount)
end

--============================================================================
--=================[CS_BJL_Request_Role_List] [1280]==========================

function BJLGameMgr.Send_CS_BJL_Request_Role_List()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_BJL_Request_Role_List, message, true)
end

function BJLGameMgr.Received_CS_BJL_Request_Role_List(message)
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
        CS.BubblePrompt.Show(data.GetString("Role_List_Error" .. resultType), "BJLGameUI")
    end
end