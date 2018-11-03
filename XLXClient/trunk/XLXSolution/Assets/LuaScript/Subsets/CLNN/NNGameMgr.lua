--[[
   文件名称:NNGameMgr.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

if NNGameMgr == nil then
    NNGameMgr =
    {
        NNRoomPPOnline = {},    -- 牛牛匹配房间在线人数
    }
end

--==============================--
--desc:牛牛组局房间初始化
--time:2018-01-12 04:55:50
--@return 
--==============================--
function NNGameMgr:InitRoomInfoNNWR(roomTypeParam)
    local tNewRoom = NNRoom:New()
    tNewRoom:Init(true, roomTypeParam)
    GameData.RoomInfo.CurrentRoom = tNewRoom
end

function NNGameMgr:UpdateRoomCountDown( deltaValue )
    -- body
    GameData.RoomInfo.CurrentRoom.CountDown = GameData.RoomInfo.CurrentRoom.CountDown - deltaValue
end

--==============================--
--desc:牛牛组局房间位置转换(服务器位置==>UI显示位置)
--time:2018-01-12 05:17:48
--@nSeverPosition:
--@return 
--==============================--
function NNRoomPositionConvert(nSeverPosition)
    if nSeverPosition > 0 then
        local position =(MAX_NNZUJU_ROOM_PLAYER - GameData.RoomInfo.CurrentRoom.SelfPosition + nSeverPosition - 1) % MAX_NNZUJU_ROOM_PLAYER + 1
        return position
    else
        print("服务器传入位置有误:" .. nSeverPosition)
        return 0
    end
end

--==============================--
--desc:获取扑克牌的牌型(牛牛)
--time:2018-01-12 07:35:18
--@pokerCard1:
--@pokerCard2:
--@pokerCard3:
--@pokerCard4:
--@pokerCard5:
--@return arg1: 扑克牌型 arg2: 重新拍好序的扑克牌 arg3: 最大的一张扑克牌
--==============================--
function GetNNPokerCardTypeByPokerCards(pokerCard1, pokerCard2, pokerCard3, pokerCard4, pokerCard5)
    if pokerCard1 == nil or pokerCard2 == nil or pokerCard3 == nil or pokerCard4 == nil or pokerCard5 == nil then
        return BRAND_TYPE.NONIU, nil, nil
    end
    -- 重新排序扑克牌
    local pokerCards = { pokerCard1, pokerCard2, pokerCard3, pokerCard4, pokerCard5 }
    table.sort(pokerCards, CompPokerCard)

    local number1 = math.min(10, pokerCards[1].PokerNumber)
    local number2 = math.min(10, pokerCards[2].PokerNumber)
    local number3 = math.min(10, pokerCards[3].PokerNumber)
    local number4 = math.min(10, pokerCards[4].PokerNumber)
    local number5 = math.min(10, pokerCards[5].PokerNumber)

    local resultPokers = { }
    local maxPokerCard = pokerCards[1]
    local resultNumber = 0
    local isContainNiu = true
    local indexs = { }

    if (number1 + number2 + number3) % 10 == 0 then
        resultNumber =(number4 + number5) % 10
        resultPokers = { pokerCards[1], pokerCards[2], pokerCards[3], pokerCards[4], pokerCards[5] }
    elseif (number1 + number2 + number4) % 10 == 0 then
        resultNumber =(number3 + number5) % 10
        resultPokers = { pokerCards[1], pokerCards[2], pokerCards[4], pokerCards[3], pokerCards[5] }
    elseif (number1 + number2 + number5) % 10 == 0 then
        resultNumber =(number3 + number4) % 10
        resultPokers = { pokerCards[1], pokerCards[2], pokerCards[5], pokerCards[3], pokerCards[4] }
    elseif (number1 + number3 + number4) % 10 == 0 then
        resultNumber =(number2 + number5) % 10
        resultPokers = { pokerCards[1], pokerCards[3], pokerCards[4], pokerCards[2], pokerCards[5] }
    elseif (number1 + number3 + number5) % 10 == 0 then
        resultNumber =(number2 + number4) % 10
        resultPokers = { pokerCards[1], pokerCards[3], pokerCards[5], pokerCards[2], pokerCards[4] }
    elseif (number1 + number4 + number5) % 10 == 0 then
        resultNumber =(number2 + number3) % 10
        resultPokers = { pokerCards[1], pokerCards[4], pokerCards[5], pokerCards[2], pokerCards[3] }
    elseif (number2 + number3 + number4) % 10 == 0 then
        resultNumber =(number1 + number5) % 10
        resultPokers = { pokerCards[2], pokerCards[3], pokerCards[4], pokerCards[1], pokerCards[5] }
    elseif (number2 + number3 + number5) % 10 == 0 then
        resultNumber =(number1 + number4) % 10
        resultPokers = { pokerCards[2], pokerCards[3], pokerCards[5], pokerCards[1], pokerCards[4] }
    elseif (number2 + number4 + number5) % 10 == 0 then
        resultNumber =(number1 + number3) % 10
        resultPokers = { pokerCards[2], pokerCards[4], pokerCards[5], pokerCards[1], pokerCards[3] }
    elseif (number3 + number4 + number5) % 10 == 0 then
        resultNumber =(number1 + number2) % 10
        resultPokers = { pokerCards[3], pokerCards[4], pokerCards[5], pokerCards[1], pokerCards[2] }
    else
        resultNumber = 0
        resultPokers = { pokerCard1, pokerCard2, pokerCard3, pokerCard4, pokerCard5 }
        isContainNiu = false
    end

    if isContainNiu and resultNumber == 0 then
        resultNumber = 10
    end

    return resultNumber, resultPokers, maxPokerCard
end

function CompPokerCard(tA, tB)
    if tA.PokerNumber > tB.PokerNumber then
        return true
    elseif tA.PokerNumber == tB.PokerNumber then
        if tA.PokerType > tB.PokerType then
            return true
        else
            return false
        end
    else
        return false
    end
end

--==============================--
--desc:获取组局房间信息
--time:2017-11-30 08:12:26
--@indexParam:选择房间Item标识
--@pageParam: 当前第几页
--@onePageParam:一页 多少条目
--@return 房间Item详情
--==============================--
function GetNNZUJURoomDataByRoomIndex( indexParam , pageParam, onePageParam)
    -- body
    local tData = nil
    local _count = #GameData.NNRoomList
    local tagIndex  = (pageParam - 1) * onePageParam + indexParam
    if tagIndex <= _count and tagIndex > 0 then
        -- body
        tData = GameData.NNRoomList[tagIndex]
    end
    return tData
end

-------------------------------------------------------------------------------
-------------------------------组局厅房间相关协议------------------------------

---------------------------------------------------------------------------
-----------------CS_NN_RoomList  850------------------------------------

function  NetMsgHandler.Send_CS_NNRoom_RoomList()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_RoomList, message, false)
    GameData.NNRoomList = { }
end

local function _CompNNRoom( tA, tB)
    return tA.IsJoin==tB.IsJoin and (tA.createRoomTime>tB.createRoomTime) or (tA.IsJoin>tB.IsJoin)
end

function  Received_CS_ZJRoom_RoomList(message)
    local count = message:PopUInt16()
    for i = 1, count do
        local roomData = { }
        roomData.RoomID = message:PopUInt32()
        roomData.createRoomTime = message:PopUInt32()
        roomData.OnlineCount = message:PopByte()
        roomData.IsLock = message:PopByte()
        roomData.BetMin = message:PopInt64()
        roomData.EnterLimit = message:PopInt64()
        roomData.LeaveLimit = message:PopInt64()
        roomData.IsJoin=message:PopByte()
        GameData.NNRoomList = GameData.NNRoomList or { }
        GameData.NNRoomList[i] = roomData
    end
    if count > 0 then
        table.sort( GameData.NNRoomList, _CompNNRoom )
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomListUpdateEvent)
end


---------------------------------------------------------------------------
-----------------CS_NN_Room_Create  851-------------------------------------

--==============================--
--desc:牛牛组局房间创建请求
--time:2018-01-20 11:21:04
--@roomType:房间类型
--@isLock:是否锁定
--@nBet:房间底注
--@nEnterimit:入场限制
--@nLeaveLimit:进场限制
--@roomStyle:(1 普通房间,2 茶馆房间 3馆主房间)
--@systemCost:系统抽水
--@ownerCost:馆主抽水
--@return 
--==============================--
function  NetMsgHandler.Send_CS_NN_Room_Create(roomType, isLock, nBet, nEnterimit, nLeaveLimit, roomStyle, systemCost, ownerCost)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(roomType)
    message:PushByte(isLock or 1)
    message:PushInt64(nBet)
    message:PushInt64(nEnterimit)
    message:PushInt64(nLeaveLimit)
    message:PushByte(roomStyle)
    message:PushByte(systemCost)
    message:PushByte(ownerCost)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_Room_Create, message, true)
end

function  Received_CS_NN_Room_Create(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local ZJRoomID = message:PopUInt32()
        GameData.RoomInfo.CurrentRoom.RoomID = ZJRoomID
        -- 组局厅房间创建成功 马上进入房间
        NetMsgHandler.Send_CS_NN_Enter_Room(ZJRoomID)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyCreateRoomSuccess, nil)
    else
        CS.BubblePrompt.Show(data.GetString("NN_Room_Create_Error_" .. resultType), "HallUI")
    end
end

---------------------------------------------------------------------------
-----------------CS_NN_Enter_Room  852-------------------------------------
-- (组局牛牛)请求进入房间
function  NetMsgHandler.Send_CS_NN_Enter_Room(roomIDParam)
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_Enter_Room, message, false)
end

-- (组局牛牛)服务器反馈进入房间结果
function  Received_CS_NN_Enter_Room(message)
    
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 进入游戏房间
        local tRoomID  = message:PopUInt32()
        GameData.InitCurrentRoomInfo(ROOM_TYPE.ZuJuNN, tRoomID)

        CS.WindowManager.Instance:CloseWindow("UIJoinRoom", false)
        
    else
        CS.BubblePrompt.Show(data.GetString("NN_Enter_Room_Error_" .. resultType), "HallUI")
        NetMsgHandler.ExitRoomToHall(0)
        CS.MatchLoadingUI.Hide()
    end
end



---------------------------------------------------------------------------
-----------------CS_NN_Leave_Room  853-------------------------------------
-- 组局厅请求离开房间
function  NetMsgHandler.Send_CS_NN_Leave_Room(rooIDParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(rooIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_Leave_Room, message, true)
end

function  Received_CS_NN_Leave_Room(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        
    else
        CS.BubblePrompt.Show(data.GetString("NN_Exit_Room_Error_" .. resultType), "HallUI")
    end

    NetMsgHandler.ExitRoomToHall(0)
end

---------------------------------------------------------------------------
-----------------S_NN_Get_Game_Data  854--------------------------------

function  Received_S_NN_Get_Game_Data(message)
    local RoomID = message:PopUInt32()
    local MasterID = message:PopUInt32()
    local RoomState = message:PopByte()
    local CountDown = message:PopUInt32() / 1000
    local BankerPos = message:PopByte()
    local selfPos = message:PopByte()
    -- 房间模式 (名牌暗牌)  (房间名称) （底注） (是否枷锁)
    local RoomType = message:PopByte()
    local LightPoker = message:PopByte()
    local RoomName = message:PopString()
    local MinBet = message:PopInt64()
    local IsLock = message:PopByte()
    -- 牌局数量
    local BoardNumber = message:PopUInt32()
    local tBankerCompensate = message:PopByte()
    --print(string.format('=====牛牛组局厅信息: RoomID:[%d] 房主ID:[%d] 房间状态:[%d] 明暗模式:[%d]', RoomID, MasterID, RoomState, LightPoker))
    local tRoomData = GameData.RoomInfo.CurrentRoom

    tRoomData.RoomID = RoomID
    tRoomData.MasterID = MasterID
    tRoomData.RoomState = RoomState
    tRoomData.CountDown = CountDown
    tRoomData.SelfPosition = selfPos
    tRoomData.RoomType = RoomType
    tRoomData.LightPoker = LightPoker
    tRoomData.BoardNumber = BoardNumber
    tRoomData.RoomName = RoomName
    tRoomData.MinBet = GameConfig.GetFormatColdNumber(MinBet)
    tRoomData.IsLock = IsLock
    tRoomData.BankerID = NNRoomPositionConvert(BankerPos)
    tRoomData.nBankerCompensate = tBankerCompensate

    -- 进入房间时 将位置清空
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.NULL
    end

    -- 玩家数据解析
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
         ParseZJRoomPlayer(message)
    end

    -- 玩家当前金币解析
    local playerCount2 = message:PopUInt16()
    for posIndex = 1, playerCount2, 1 do
        local position = message:PopByte()
        local WinGold = message:PopInt64()
        local goldValue = message:PopInt64()
        position = NNRoomPositionConvert(position)
        WinGold = GameConfig.GetFormatColdNumber(WinGold)
        goldValue = GameConfig.GetFormatColdNumber(goldValue)
        tRoomData.NNPlayerList[position].WinGold = WinGold
        tRoomData.NNPlayerList[position].Gold = goldValue
        if RoomState == ROOM_STATE_NN.SETTLEMENT and posIndex == 1 then
            -- 结算状态 通比: 第一个下标是赢家
            tRoomData.BankerID = position
        end
    end

    -- 玩家状态设置
    if RoomState >= ROOM_STATE_NN.DEAL and LightPoker == 1 then
        -- 自己前3张 名牌模式显示设置
        local tPlayer = tRoomData.NNPlayerList[MAX_NNZUJU_ROOM_PLAYER]
        if tPlayer.IsValid == PlayerStateEnumNN.JoinOK then
            for index = 1, 4, 1 do
                tPlayer.Pokers[index].Visible = true
            end
        end
    end
    if RoomState >= ROOM_STATE_NN.OVER_CUO then
        -- 结算状态 设置玩家扑克显示 可否搓牛状态
        for pos = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
            if tRoomData.NNPlayerList[pos].IsValid == PlayerStateEnumNN.JoinOK then
                for cardIndex = 1, 5, 1 do
                    tRoomData.NNPlayerList[pos].Pokers[cardIndex].Visible = true
                end
                tRoomData.NNPlayerList[pos].CanPlaySplitPkoerAnimation = true
            end
        end
    end

    -- 通知房间状态更新
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, tRoomData.RoomState)
    -- 切换状态为房间
    GameData.GameState = GAME_STATE.ROOM
    OpenNNGameUI()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyEnterGameEvent, nil)
end

-- 进入对战游戏房间
function  OpenNNGameUI()
    --CS.MatchLoadingUI.Show()
    local gameui1Node = CS.WindowManager.Instance:FindWindowNodeByName('NNGameUI1')
    if gameui1Node == nil then
        local openparam = CS.WindowNodeInitParam("NNGameUI1")
        openparam.NodeType = 0
        openparam.LoadComplatedCallBack = function(windowNode)
            HandleRefreshHallUIShowState(false)
            --CS.LoadingDataUI.Hide()
        end
        CS.WindowManager.Instance:OpenWindow(openparam)
    else
        -- TODO  已经处于对战房间
        CS.MatchLoadingUI.Hide()
    end
end

-- 解析组局厅房间玩家详细信息
function  ParseZJRoomPlayer(message)
    local playerID = message:PopUInt32()
    local Name = message:PopString()
    local HeadIcon = message:PopByte()
    local goldValue = message:PopInt64()
    local severposition = message:PopByte()
    local PlayerState = message:PopByte()
    local IsCuoPai = message:PopByte()
    local tCompensate = message:PopByte()
    local tBetCompensate = message:PopByte()

    goldValue = GameConfig.GetFormatColdNumber(goldValue)
    --print(string.format('玩家位置:[%d] 金币:[%f] 倍率1:%d 倍率2:%d', severposition, goldValue,tCompensate,tBetCompensate))

    local position = NNRoomPositionConvert(severposition)

    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.NNPlayerList[position].ID = playerID
    tRoomData.NNPlayerList[position].IsValid = 1
    tRoomData.NNPlayerList[position].Position = severposition
    tRoomData.NNPlayerList[position].Name = Name
    tRoomData.NNPlayerList[position].HeadIcon = HeadIcon
    tRoomData.NNPlayerList[position].Gold = goldValue
    tRoomData.NNPlayerList[position].nCompensate = tCompensate
    tRoomData.NNPlayerList[position].nBetCompensate = tBetCompensate

    tRoomData.NNPlayerList[position].PlayerState = PlayerState
    tRoomData.NNPlayerList[position].IsCuoPai = IsCuoPai
    if PlayerState >= PlayerStateEnumNN.JoinOK then
        tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.JoinOK
    else
        tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.JoinNO
    end
    -- 解析扑克牌数据
    local pokerNumber = message:PopUInt16()
    for cardIndex = 1, pokerNumber, 1 do
        local PokerType = message:PopByte()
        local PokerNumber = message:PopByte()
        tRoomData.NNPlayerList[position].Pokers[cardIndex].PokerType = PokerType
        tRoomData.NNPlayerList[position].Pokers[cardIndex].PokerNumber = PokerNumber
        -- 已经搓牌 该玩家的牌应该全部显示
        if IsCuoPai == 1 then
            tRoomData.NNPlayerList[position].Pokers[cardIndex].Visible = true
        end
    end

    tRoomData.NNPlayerList[position].strLoginIP = message:PopString()

end 

-------------------------------------------------------------------------------
-----------------S_NN_Enter_Next_State  855--------------------------------
-- 牛牛--服务器通知进入下一阶段
function  Received_S_NN_Enter_Next_State(message)
    -- 当前房间状态
    local roomState = message:PopByte()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- print(string.format('=====855 牛牛当前状态:[%d] 房间类型:[%d]', roomState, tRoomData.RoomType))
    if roomState == ROOM_STATE_NN.START then
        -- 重回等待开始游戏状态
         ParseWaitStart(message)
    elseif roomState == ROOM_STATE_NN.WAIT then
        -- 等待状态
        -- 清理掉当局数据
         ParseWaitStart(message)
         ParseZJRoomDeletePlayer(message)
    elseif roomState == ROOM_STATE_NN.SHUFFLE then
        -- 洗牌状态

    elseif roomState == ROOM_STATE_NN.DEAL then
        -- 发牌状态
         ParseZJRoomDeal(message)
    elseif roomState == ROOM_STATE_NN.QIANG_ZHUANG then
        -- 抢庄状态
    elseif roomState == ROOM_STATE_NN.QIANG_ZHUANG_OVER then
        -- 抢庄结束
         ParseNNOverQiangZhuang(message)
    elseif roomState == ROOM_STATE_NN.XUAN_ZHUANG then
        -- 选庄状态
         ParseZJRoomXuanZhuang(message)
    elseif roomState == ROOM_STATE_NN.XUAN_DOUBLE then
        -- 加倍状态
         ParseNNRoomStartXiaZhu(message)
    elseif roomState == ROOM_STATE_NN.OVER_DOUBLE then
        -- 加倍结束
         ParseZJRoomDoubleOver(message)
    elseif roomState == ROOM_STATE_NN.CUO then
        -- 自己搓牌状态
         ParseZJRoomCuoPai(message)
    elseif roomState == ROOM_STATE_NN.OVER_CUO then
        -- 搓牌阶段结束
         ParseZJRoomCuoPaiOver(message)
    elseif roomState == ROOM_STATE_NN.SETTLEMENT then
        -- 结算状态
         ParseZJRoomResult(message)
    end
    -- 设置组局厅房间状态
    GameData.RoomInfo.CurrentRoom:SetRoomState(roomState)
end

-- 重会[等待开始]状态
function  ParseWaitStart(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 重置有效玩家的状态
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if tRoomData.NNPlayerList[position].IsValid >= PlayerStateEnumNN.JoinOK then
            tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.JoinNO
            tRoomData.NNPlayerList[position].PlayerState = PlayerStateEnumNN.JoinNO
        end
    end
end

-- 解析组局厅移除玩家列表
function  ParseZJRoomDeletePlayer(message)
    local BoardNumber = message:PopUInt32()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.BoardNumber = BoardNumber
    -- 解析移除玩家列表
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        position = NNRoomPositionConvert(position)

        tRoomData.NNPlayerList[position].ID = 0
        tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.NULL
        tRoomData.NNPlayerList[position].Name = ""
        tRoomData.NNPlayerList[position].HeadIconUrl = ""
        tRoomData.NNPlayerList[position].HeadIcon = 0
        tRoomData.NNPlayerList[position].Gold = 0
        tRoomData.NNPlayerList[position].PlayerState = PlayerStateEnumNN.NULL
    end


    tRoomData.BankerID = 0
end

-- 解析玩家下发牌情况
function  ParseZJRoomDeal(message)

    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 玩家状态重置
    for positionIndex = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        tRoomData.NNPlayerList[positionIndex].IsValid = PlayerStateEnumNN.NULL
        tRoomData.NNPlayerList[positionIndex].PlayerState = PlayerStateEnumNN.NULL
        tRoomData.NNPlayerList[positionIndex].IsCuoPai = 0
        tRoomData.NNPlayerList[positionIndex].CanPlaySplitPkoerAnimation = true
    end

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        local PlayerState = message:PopByte()
        position = NNRoomPositionConvert(position)
        local pokerCount = message:PopUInt16()
        for pokerIndex = 1, pokerCount, 1 do
            local tPokerType = message:PopByte()
            local tPokerNumber = message:PopByte()
            tRoomData.NNPlayerList[position].Pokers[pokerIndex].PokerType = tPokerType
            tRoomData.NNPlayerList[position].Pokers[pokerIndex].PokerNumber = tPokerNumber
            tRoomData.NNPlayerList[position].Pokers[pokerIndex].Visible = false
        end

        -- 此刻会确认玩家参与游戏的状态( 参与 观看 )
        tRoomData.NNPlayerList[position].PlayerState = PlayerState
        if PlayerState >= 2 then
            -- 参与游戏状态
            tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.JoinOK
        elseif PlayerState == 1 then
            tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.JoinNO
        else
            tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.NULL
        end
    end
    -- 名牌模式 自己亮3张
    if tRoomData.LightPoker == 1 then
        local tPlayer = tRoomData.NNPlayerList[MAX_NNZUJU_ROOM_PLAYER]
        tPlayer.Pokers[1].Visible = true
        tPlayer.Pokers[2].Visible = true
        tPlayer.Pokers[3].Visible = true
        tPlayer.Pokers[4].Visible = true
    end

end

-- 解析抢庄结束情况
function  ParseNNOverQiangZhuang(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        local PlayerState = message:PopByte()
        position = NNRoomPositionConvert(position)
        tRoomData.NNPlayerList[position].PlayerState = PlayerState
    end
end

-- 解析选庄列表
function  ParseZJRoomXuanZhuang(message)
    -- 庄家位置
    local bankerPosition = message:PopByte()
    -- 位置转换
    bankerPosition = NNRoomPositionConvert(bankerPosition)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    tRoomData.BankerID = bankerPosition
    tRoomData.NNPlayerList[bankerPosition].PlayerState = PlayerStateEnumNN.QiangZhuangOK
    --if tRoomData.RoomType == ROOM_TYPE.ZuJuNN then
        -- 抢庄房间 需要解析参与定庄的玩家列表
        local playerCount = message:PopUInt16()
        for playerIndex = 1, playerCount, 1 do
            local position = message:PopByte()
            position = NNRoomPositionConvert(position)
            tRoomData.NNPlayerList[position].PlayerState = PlayerStateEnumNN.QiangZhuangOK
        end
    --end
end

-- 解析下注阶段玩家可以下注倍数
function  ParseNNRoomStartXiaZhu(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local nBankerCompensate = message:PopUInt32()
    local playerCount = message:PopUInt16()
    for index = 1,playerCount do
        local serverPosition = message:PopByte()
        local nCompensate = message:PopUInt32()
        local position = NNRoomPositionConvert(serverPosition)
        tRoomData.NNPlayerList[position].nCompensate = nCompensate
    end
    tRoomData.nBankerCompensate = nBankerCompensate
end

-- 解析加倍结束 游戏状态
function  ParseZJRoomDoubleOver(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        -- 此刻的游戏状态表示的是玩家是否加倍
        local PlayerState = message:PopByte()
        local nBetCompensate = message:PopByte()
        position = NNRoomPositionConvert(position)
        tRoomData.NNPlayerList[position].PlayerState = PlayerState
        tRoomData.NNPlayerList[position].nBetCompensate = nBetCompensate
    end
end

-- 解析搓牌阶段 玩家扑克牌和游戏状态
function  ParseZJRoomCuoPai(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        -- 此刻的游戏状态表示的是玩家是否加倍
        position = NNRoomPositionConvert(position)
        local pokerCount = message:PopUInt16()
        -- print(string.format('玩家:[%d] 扑克数量:[%d]', position, pokerCount))
        for pokerIndex = 1, pokerCount, 1 do
            local PokerType = message:PopByte()
            local PokerNumber = message:PopByte()
            tRoomData.NNPlayerList[position].Pokers[pokerIndex].PokerType = PokerType
            tRoomData.NNPlayerList[position].Pokers[pokerIndex].PokerNumber = PokerNumber
            tRoomData.NNPlayerList[position].Pokers[pokerIndex].Visible = true
        end

    end
    -- 该阶段 玩家自己的 5 张牌需要隐藏
    tRoomData.NNPlayerList[MAX_NNZUJU_ROOM_PLAYER].Pokers[5].Visible = false
end

function  ParseZJRoomCuoPaiOver(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if tRoomData.NNPlayerList[position].IsValid == PlayerStateEnumNN.JoinOK then
            tRoomData.NNPlayerList[position].IsCuoPai = 1
            for cardIndex = 1, 5, 1 do
                -- 亮牌处理
                tRoomData.NNPlayerList[position].Pokers[cardIndex].Visible = true
            end
        end
    end
end

-- 解析结算状态 玩家胜负情况
function  ParseZJRoomResult(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        local WinGold = message:PopInt64()
        local GoldValue = message:PopInt64()
        WinGold = GameConfig.GetFormatColdNumber(WinGold)
        GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
        if index == 1 then
            local oldBankerID = tRoomData.BankerID
            local newBankerID = NNRoomPositionConvert(position)
            tRoomData.BankerID = newBankerID
        end
        position = NNRoomPositionConvert(position)
        tRoomData.NNPlayerList[position].WinGold = WinGold
        tRoomData.NNPlayerList[position].Gold = GoldValue

        tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.JoinOK
        for cardIndex = 1, 5, 1 do
            tRoomData.NNPlayerList[position].Pokers[cardIndex].Visible = true
        end
    end
end

---------------------------------------------------------------------------
-----------------S_NN_AddPlayer  856-------------------------------------

function  Received_S_ZJRoom_AddPlayer(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local playerName = message:PopString()
    local HeadIcon = message:PopByte()

    local GoldValue = message:PopInt64()
    local severPosition = message:PopByte()
    local PlayerState = message:PopByte()
    local nAccountID = message:PopUInt32()
    local strLoginIP = message:PopString()
    
    GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
    local position = NNRoomPositionConvert(severPosition)
    if PlayerState > PlayerStateEnumNN.JoinOK then
        tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.JoinOK
    else
        tRoomData.NNPlayerList[position].IsValid = PlayerState
    end

    tRoomData.NNPlayerList[position].ID = nAccountID
    tRoomData.NNPlayerList[position].PlayerState = PlayerState
    tRoomData.NNPlayerList[position].Position = severPosition
    tRoomData.NNPlayerList[position].Name = playerName
    tRoomData.NNPlayerList[position].HeadIcon = HeadIcon
    tRoomData.NNPlayerList[position].Gold = GoldValue
    tRoomData.NNPlayerList[position].strLoginIP = strLoginIP

    local eventArg = position
    -- 通知界面显示
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZJRoomAddPlayer, eventArg)
end

---------------------------------------------------------------------------
-----------------S_NN_DeletePlayer  857--------------------------------

function  Received_S_ZJRoom_DeletePlayer(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local position = message:PopByte()
    position = NNRoomPositionConvert(position)
    tRoomData.NNPlayerList[position].IsValid = PlayerStateEnumNN.NULL
    tRoomData.NNPlayerList[position].PlayerState = PlayerStateEnumNN.NULL
    tRoomData.NNPlayerList[position].Name = ''
    tRoomData.NNPlayerList[position].HeadIcon = 0
    tRoomData.NNPlayerList[position].HeadIconUrl = ''
    tRoomData.NNPlayerList[position].Gold = 0

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZJRoomDeletePlayer, position)
end

---------------------------------------------------------------------------
-----------------CS_NN_Ready  858-------------------------------------
-- 组局厅请求开始游戏
function  NetMsgHandler.Send_CS_NN_Ready()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_Ready, message, false)
end


-- 服务器反馈组局厅开始结果(失败时才会返回)
function  Received_CS_NN_Ready(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local resultType = message:PopByte()
    if resultType == 0 then
        local severPosition = message:PopByte()
        local tState  = message:PopByte()
        local position = NNRoomPositionConvert(severPosition)
        tRoomData.NNPlayerList[position].PlayerState = tState

        local eventArg = position
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyNNZJPlayerReadyEvent, eventArg)
    else
        CS.BubblePrompt.Show(data.GetString("NN_Room_Ready_Error_" .. resultType), "NNGameUI1")
    end
end

---------------------------------------------------------------------------
-----------------CS_NN_QiangZhuang  859--------------------------------
-- 请求是否抢庄 参数: 3 抢庄 4 不抢
function  NetMsgHandler.Send_CS_ZJRoom_QiangZhuang(qiangZhuangStateParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(qiangZhuangStateParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_QiangZhuang, message, false)
end

-- 服务器反馈抢庄结果()
function  Received_CS_ZJRoom_QiangZhuang(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local resultType = message:PopByte()
    if resultType == 0 then
        local PlayerPos = message:PopByte()
        -- 4抢庄 5不抢
        local PlayerState = message:PopByte()
        PlayerPos = NNRoomPositionConvert(PlayerPos)
        tRoomData.NNPlayerList[PlayerPos].PlayerState = PlayerState
        -- 通知该玩家参与抢庄状态
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZJRoomPlayerQiangZhuang, PlayerPos)
    else
        -- 抢庄异常
        CS.BubblePrompt.Show(data.GetString("NN_Room_QZ_Error_" .. resultType), "NNGameUI1")
    end
end


---------------------------------------------------------------------------
-----------------CS_NN_JiaBei  860--------------------------------
-- 请求加倍
function  NetMsgHandler.Send_CS_ZJRoom_XuanDouble(doubleParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(doubleParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_JiaBei, message, false)
end

function  Received_CS_ZJRoom_XuanDouble(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local playerPos = message:PopByte()
        local PlayerState = message:PopByte()
        local nBetCompensate = message:PopByte()

        playerPos = NNRoomPositionConvert(playerPos)
        local tRoomData = GameData.RoomInfo.CurrentRoom
        tRoomData.NNPlayerList[playerPos].PlayerState = PlayerState
        tRoomData.NNPlayerList[playerPos].nBetCompensate = nBetCompensate
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZJRoomPlayerDouble, playerPos)
    else
        -- 加倍异常
        CS.BubblePrompt.Show(data.GetString("NN_Room_JB_Error_" .. resultType), "UIGame1")
    end
end



-------------------------------------------------------------------------------
-------------------------------CS_NN_CuoPai  861---------------------------
-- 组局厅 搓牌结束通知
function  NetMsgHandler.Send_CS_ZJRoom_CuoPai()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_CuoPai, message, false)
end


function  Received_CS_ZJRoom_CuoPai(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local position = message:PopByte()
        local tRoomData = GameData.RoomInfo.CurrentRoom

        position = NNRoomPositionConvert(position)
        for index = 1, 5, 1 do
            tRoomData.NNPlayerList[position].Pokers[index].Visible = true
        end

        tRoomData.NNPlayerList[position].CanPlaySplitPkoerAnimation =(position ~= MAX_NNZUJU_ROOM_PLAYER)

        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyZJRoomPlayerCuoPai, position)
    else
        CS.BubblePrompt.Show(data.GetString("NN_Room_CuoPai_Error_" .. resultType), "UIGame1")
    end
end


-------------------------------------------------------------------------------
-------------------------------CS_NN_Room_History  862---------------------------
-- 组局厅 搓牌结束通知
function  Send_CS_NN_Room_History()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NN_Room_History, message, false)
end


function  Received_CS_NN_Room_History(message)
    local resultType = message:PopByte()
    if resultType == 0 then

        local tRoomCount = message:PopUInt16()
        GameData.RoomInfo.HistoryRoomNN = { }
        for i = 1, tRoomCount, 1 do
            local roomID = message:PopUInt32()
            local masterName = message:PopString()
            local tNode = {RoomID = roomID,MasterName = masterName}
            table.insert(GameData.RoomInfo.HistoryRoomNN,tNode)
        end
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyNNHistoryRoomEvent, nil)
end

-------------------------------------------------------------------------------
-------------------------------CS_NN_Room_History  863-------------------------
--==============================--
--desc:请求牛牛匹配房间在线人数
--time:2018-01-29 03:21:03
--@return 
--==============================--
function Send_CS_NNPP_Room_OnLine()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NNPP_Room_OnLine, message, false)
end

function Received_CS_NNPP_Room_OnLine(message)
    local count  = message:PopUInt16()
    NNGameMgr.NNRoomPPOnline = {}
    for index = 1, count, 1 do
        local OnlineData  =  {}
        OnlineData.roomIndex  = message:PopByte()
        OnlineData.OnlineCount  = message:PopUInt16()
        NNGameMgr.NNRoomPPOnline[index] = OnlineData
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomOnlineEvent, nil)
end

-------------------------------------------------------------------------------
-------------------------------CS_NN_Room_History  864-------------------------
--==============================--
--desc:进入牛牛匹配房间
--time:2018-01-29 03:22:49
--@return 
--==============================--
function Send_CS_NNPP_Enter_Room(roomTypeParam,rooidParam)
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(roomTypeParam)
    message:PushUInt32(rooidParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_NNPP_Enter_Room, message, false)
end
--==============================--
--desc:
--time:2018-01-29 03:23:08
--@message:
--@return 
--==============================--
function Received_CS_NNPP_Enter_Room( message )
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 进入游戏房间
        local tRoomID  = message:PopUInt32()
        GameData.InitCurrentRoomInfo(ROOM_TYPE.PiPeiNN, tRoomID)
        --CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
    else
        if resultType == 4 then
            CS.MatchLoadingUI.Hide()
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            CS.MatchLoadingUI.Hide()
            CS.BubblePrompt.Show(data.GetString("NN_Enter_Room_Error_" .. resultType), "HallUI")
            NetMsgHandler.ExitRoomToHall(0)
            if resultType == 9 then
                local GoldValue = message:popInt64()
            end
        end
    end
end