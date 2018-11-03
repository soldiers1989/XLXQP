--[[
   文件名称:TTZGameMgr.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

if TTZGameMgr == nil then
    TTZGameMgr =
    {
        TTZRoomPPOnline = {},       -- 推筒子匹配房间在线人数
        TTZRoomList = {},           -- 推筒子组局房间列表
    }
end

--==============================--
--desc:推筒子组局房间初始化
--time:2018-01-12 04:55:50
--@return 
--==============================--
function TTZGameMgr:InitRoomInfo(roomTypeParam)
    local tNewRoom = TTZRoom:New()
    tNewRoom:Init(true, roomTypeParam)
    GameData.RoomInfo.CurrentRoom = tNewRoom
end

function TTZGameMgr:UpdateRoomCountDown( deltaValue )
    -- body
    GameData.RoomInfo.CurrentRoom.CountDown = GameData.RoomInfo.CurrentRoom.CountDown - deltaValue
end

--==============================--
--desc:推筒子组局房间位置转换(服务器位置==>UI显示位置)
--time:2018-01-12 05:17:48
--@nSeverPosition:
--@return 
--==============================--
function TTZGameMgr.TTZRoomPositionConvert(nSeverPosition)
    if nSeverPosition > 0 then
        local position =(MAX_TTZZUJU_ROOM_PLAYER - GameData.RoomInfo.CurrentRoom.SelfPosition + nSeverPosition - 1) % MAX_TTZZUJU_ROOM_PLAYER + 1
        return position
    else
        print("服务器传入位置有误:" .. nSeverPosition)
        return 0
    end
end

--==============================--
--desc:获取扑克牌的牌型(推筒子)
--time:2018-02-28 05:22:21
--@pokerCard1:麻将1
--@pokerCard2:麻将2
--@return agr1 牌型 agr2 点数
--==============================--
function TTZGameMgr.GetPokerCardTypeByPokerCards(pokerCard1, pokerCard2)
    if pokerCard1 == nil or pokerCard2 == nil then
        return TTZ_Card_Type.SANPAI1, 0
    end

    local number1 = math.min(10, pokerCard1.PokerNumber)
    local number2 = math.min(10, pokerCard2.PokerNumber)

    -- 牌型确认
    local resultType = TTZ_Card_Type.SANPAI2
    if number1 == number2 then
        -- 豹子以上
        if number1 == 10 then
            resultType = TTZ_Card_Type.ZHIZUN
        else
            resultType = TTZ_Card_Type.BAOZI
        end
    else
        if number1 + number2 == 10 then
            --28杠
            if number1 == 2 or number1 == 8 then
                resultType = TTZ_Card_Type.GANG28
            end
        end
    end

    -- 点数确认
    local resultNumber = 0
    if number1 ~= 10 then
        number1 = number1 * 10
    else
        number1 = 5
    end
    if number2 ~= 10 then
        number2 = number2 * 10
    else
        number2 = 5
    end
    resultNumber = (number1 + number2) % 100
    -- 高牌确认
    if resultType == TTZ_Card_Type.SANPAI2 then
        if resultNumber <= 75 then
             resultType = TTZ_Card_Type.SANPAI1
        end
    end

    return resultType, resultNumber
end

--==============================--
--desc:获取推筒子扑克资源
--time:2018-03-01 11:13:27
--@pokerNumber:
--@return 
--==============================--
function TTZGameMgr.GetPokerCardSpriteName(pokerNumber)
    local cardSpriteName = "sprite_ttz_"..pokerNumber
    return cardSpriteName
end

--==============================--
--desc:获取推筒子扑克牌型资源
--time:2018-03-05 06:12:50
--@pokerType:
--@pokerNumber:
--@return 
--==============================--
function TTZGameMgr.GetPokerCardTypeSpriteName( pokerType, pokerNumber )
    local cardSpriteName = "sprite_ttzd_tzz"
    if pokerType == TTZ_Card_Type.ZHIZUN then
        cardSpriteName = "sprite_ttzd_tzz"
    elseif pokerType == TTZ_Card_Type.BAOZI then
        cardSpriteName = "sprite_ttzd_tbz"
    elseif pokerType == TTZ_Card_Type.GANG28 then
        cardSpriteName = "sprite_ttzd_t28"
    else
        cardSpriteName = "sprite_ttzd_"..pokerNumber
    end
    return cardSpriteName
end


--==============================--
--desc:获取组局房间信息
--time:2017-11-30 08:12:26
--@indexParam:选择房间Item标识
--@pageParam: 当前第几页
--@onePageParam:一页 多少条目
--@return 房间Item详情
--==============================--
function TTZGameMgr.GetRoomDataByRoomIndex( indexParam , pageParam, onePageParam)
    -- body
    local tData = nil
    local _count = #TTZGameMgr.TTZRoomList
    local tagIndex  = (pageParam - 1) * onePageParam + indexParam
    if tagIndex <= _count and tagIndex > 0 then
        -- body
        tData = TTZGameMgr.TTZRoomList[tagIndex]
    end
    return tData
end

-------------------------------------------------------------------------------
-------------------------------组局厅房间相关协议------------------------------

-------------------------------------------------------------------------------
-------------------------------CS_NN_Room_History  740-------------------------
--==============================--
--desc:请求推筒子匹配房间在线人数
--time:2018-01-29 03:21:03
--@return 
--==============================--
function NetMsgHandler.Send_CS_TTZPP_Room_OnLine()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_PIPEI_ONLINE, message, false)
end

function NetMsgHandler.Received_CS_TTZPP_Room_OnLine(message)
    local count  = message:PopByte()
    TTZGameMgr.TTZRoomPPOnline = {}
    for index = 1, count, 1 do
        local OnlineData  =  {}
        OnlineData.roomIndex  = message:PopByte()
        OnlineData.OnlineCount  = message:PopUInt16()
        TTZGameMgr.TTZRoomPPOnline[index] = OnlineData
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomOnlineEvent, nil)
end

---------------------------------------------------------------------------
-----------------CS_TTZ_ZUJU_ROOM_LIST  741------------------------------------

function  NetMsgHandler.Send_CS_TTZRoom_RoomList()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_ZUJU_ROOM_LIST, message, false)
    TTZGameMgr.TTZRoomList = { }
end

local function _CompTTZRoom( tA, tB)
    return tA.IsJoin==tB.IsJoin and (tA.createRoomTime>tB.createRoomTime) or (tA.IsJoin>tB.IsJoin)
end

function  NetMsgHandler.Received_CS_TTZRoom_RoomList(message)
    local count = message:PopUInt16()
    for i = 1, count do
        local roomData = { }
        --房间ID
        roomData.RoomID = message:PopUInt32()
        -- 游戏模式（1=明牌，2=暗牌）
        roomData.GameMode = message:PopByte()
        -- 倍率模式(1=浮动，2=固定 )
        roomData.Rate = message:PopByte()
        --当前玩家数量
        roomData.OnlineCount = message:PopByte()
        --房间最大人数
        roomData.RoomMaxNumber=message:PopByte()
        --房间底注
        roomData.BetMin = message:PopUInt32()
        --房间进入限制
        roomData.EnterChip = message:PopUInt32()
        --房间离开限制
        roomData.QuitChip = message:PopUInt32()
        --是否加锁（0=公开，1=不公开）
        roomData.IsLock = message:PopByte()
        -- 是否进入过（0 没进过 1 进过）
        roomData.IsJoin = message:PopByte()
        -- 创建时间
        roomData.createRoomTime=message:PopUInt32()
        TTZGameMgr.TTZRoomList = TTZGameMgr.TTZRoomList or { }
        TTZGameMgr.TTZRoomList[i] = roomData
    end
    if count > 0 then
        table.sort( TTZGameMgr.TTZRoomList, _CompTTZRoom )
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomListUpdateEvent)
end


---------------------------------------------------------------------------
-----------------CS_NN_Room_Create  742-------------------------------------

--==============================--
--desc:推筒子组局房间创建请求
--time:2018-01-20 11:21:04
--@nRoomLevel:房间等级
--@isLock:是否锁定
--@nBet:房间底注
--@nEnterimit:入场限制
--@nLeaveLimit:进场限制
--@nGameMode:是否明牌
--@nRate:倍率方式
--@roomStyle:(1 普通房间,2 茶馆房间 3馆主房间)
--@systemCost:系统抽水
--@ownerCost:馆主抽水
--@return 
--==============================--
function  NetMsgHandler.Send_CS_TTZ_Room_Create(nRoomLevel, isLock, nEnterimit, nLeaveLimit, nGameMode, nRate, roomStyle, systemCost, ownerCost)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(nRoomLevel)
    message:PushByte(isLock or 1)
    message:PushInt64(nEnterimit)
    message:PushInt64(nLeaveLimit)
    message:PushByte(nGameMode)
    message:PushByte(nRate)
    message:PushByte(roomStyle)
    message:PushByte(systemCost)
    message:PushByte(ownerCost)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_ZUJU_CREATE, message, true)
end

function  NetMsgHandler.Received_CS_TTZ_Room_Create(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local ZJRoomID = message:PopUInt32()
        GameData.RoomInfo.CurrentRoom.RoomID = ZJRoomID
        -- 组局厅房间创建成功 马上进入房间
        NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(ZJRoomID,0)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyCreateRoomSuccess, nil)
    else
        CS.BubblePrompt.Show(data.GetString("TTZ_Create_Error_" .. resultType), "HallUI")
    end
end

---------------------------------------------------------------------------
-----------------CS_TTZ_ZUJU_ENTER_ROOM  743-------------------------------
-----------------注意 743 744 协议合并
-- (推筒子)请求进入房间
function  NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(roomIDParam,roomType)
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    --0 匹配场 ~=0组句房
    message:PushUInt32(roomIDParam)
    -- 0 组局场 1~4 匹配场
    message:PushByte(roomType)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_ZUJU_ENTER_ROOM, message, false)
end

-- (推筒子)服务器反馈进入房间结果
function  Received_CS_TTZ_ZUJU_ENTER_ROOM(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 进入游戏房间
        local tRoomID  = message:PopUInt32()
        local tRoomType = message:PopByte()
        GameData.InitCurrentRoomInfo(tRoomType, tRoomID)

        CS.WindowManager.Instance:CloseWindow("TTZCreateRoom", false)
        CS.WindowManager.Instance:CloseWindow("UIJoinRoom", false)
        --CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
    else
        if resultType == 5 then
            CS.MatchLoadingUI.Hide()
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            CS.MatchLoadingUI.Hide()
            CS.BubblePrompt.Show(data.GetString("TTZ_Enter_Error_" .. resultType), "HallUI")
            NetMsgHandler.ExitRoomToHall(0)
            if resultType == 7 then
                local GoldValue = message:PopInt64()
            end
        end  
    end
end

-------------------------------------------------------------------------------
-------------------------------CS_TTZ_PIPEI_ENTER_ROOM  744(废弃)-------------------------
--==============================--
--desc:
--time:2018-01-29 03:22:49
--@return 
--==============================--
function Send_CS_TTZ_PIPEI_ENTER_ROOM(roomTypeParam,rooidParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(roomTypeParam)
    message:PushUInt32(rooidParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_PIPEI_ENTER_ROOM, message, true)
end
--==============================--
--desc:
--time:2018-01-29 03:23:08
--@message:
--@return 
--==============================--
function Received_CS_TTZ_PIPEI_ENTER_ROOM( message )

    local resultType = message:PopByte()
    if resultType == 0 then
        -- 进入游戏房间
        local tRoomID  = message:PopUInt32()
        GameData.InitCurrentRoomInfo(ROOM_TYPE.PiPeiTTZ, tRoomID)

    else
        CS.BubblePrompt.Show(data.GetString("TTZ_Enter_Room_Error_" .. resultType), "HallUI")
        NetMsgHandler.ExitRoomToHall(0)
        CS.LoadingDataUI.Hide()
    end
end


---------------------------------------------------------------------------
-----------------CS_TTZ_LEAVE_ROOM  745-------------------------------------
-- 组局厅请求离开房间
function  NetMsgHandler.Send_CS_TTZ_LEAVE_ROOM()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    --message:PushUInt32(rooIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_LEAVE_ROOM, message, true)
end

function  Received_CS_TTZ_LEAVE_ROOM(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        NetMsgHandler.ExitRoomToHall(0)
    else
        CS.BubblePrompt.Show(data.GetString("TTZ_Exit_Room_Error_" .. resultType), "HallUI")
    end
end

---------------------------------------------------------------------------
-----------------S_TTZ_ROOM_DATA  746--------------------------------

function  Received_S_TTZ_ROOM_DATA(message)
    print("=====746================")
    local RoomID = message:PopUInt32()
    local MasterID = message:PopUInt32()
    local RoomState = message:PopByte()
    local CountDown = message:PopUInt32() / 1000
    local BankerPos = message:PopByte()
    local selfPos = message:PopByte()
    -- 赔付模式 (名牌暗牌) （底注） (是否枷锁)
    local LightPoker = message:PopByte()
    local nCompensateType = message:PopByte()
    local MinBet = message:PopInt64()
    local IsLock = message:PopByte()
    -- 牌局数量
    local BoardNumber = message:PopUInt32()
    local tBankerCompensate = message:PopByte()
    -- print(string.format('=====746 推筒子组局信息: RoomID:[%d] 房主ID:[%d] 房间状态:[%d] 明暗模式:[%d] 模式:[%d]', RoomID, MasterID, RoomState, LightPoker, nCompensateType))

    local tRoomData = GameData.RoomInfo.CurrentRoom

    tRoomData.RoomID = RoomID
    tRoomData.MasterID = MasterID
    tRoomData.RoomState = RoomState
    tRoomData.CountDown = CountDown
    tRoomData.SelfPosition = selfPos
    tRoomData.CompensateType = nCompensateType
    tRoomData.LightPoker = LightPoker
    tRoomData.BoardNumber = BoardNumber
    tRoomData.MinBet = GameConfig.GetFormatColdNumber(MinBet)
    tRoomData.IsLock = IsLock
    tRoomData.BankerID = TTZGameMgr.TTZRoomPositionConvert(BankerPos)
    tRoomData.nBankerCompensate = tBankerCompensate

    -- 进入房间时 将位置清空
    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        tRoomData.TTZPlayerList[position].PlayerState = PlayerStateEnumTTZ.NULL
    end

    -- 玩家数据解析
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
         ParseTTZRoomPlayer(message)
    end

    -- 玩家当前金币解析
    local playerCount2 = message:PopUInt16()
    for posIndex = 1, playerCount2, 1 do
        local position = message:PopByte()
        local WinGold = message:PopInt64()
        local goldValue = message:PopInt64()
        position = TTZGameMgr.TTZRoomPositionConvert(position)
        WinGold = GameConfig.GetFormatColdNumber(WinGold)
        goldValue = GameConfig.GetFormatColdNumber(goldValue)
        tRoomData.TTZPlayerList[position].WinGold = WinGold
        tRoomData.TTZPlayerList[position].Gold = goldValue
    end

    -- 玩家状态设置
    if RoomState >= ROOM_STATE_TTZ.DEAL and LightPoker == 1 then
        -- 自己前3张 名牌模式显示设置
        local tPlayer = tRoomData.TTZPlayerList[MAX_TTZZUJU_ROOM_PLAYER]
        if tPlayer.PlayerState >= PlayerStateEnumTTZ.JoinOK then
            for index = 1, 1, 1 do
                tPlayer.Pokers[index].Visible = true
            end
        end
    end
    if RoomState >= ROOM_STATE_TTZ.OVER_KANPAI then
        -- 结算状态 设置玩家扑克显示 可否搓牛状态
        for pos = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
            if tRoomData.TTZPlayerList[pos].PlayerState >= PlayerStateEnumTTZ.JoinOK then
                for cardIndex = 1, 2, 1 do
                    tRoomData.TTZPlayerList[pos].Pokers[cardIndex].Visible = true
                end
            end
        end
    end

    -- 通知房间状态更新
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, tRoomData.RoomState)
    -- 切换状态为房间
    GameData.GameState = GAME_STATE.ROOM
    OpenTTZGameUI()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyEnterGameEvent, nil)
end

-- 进入对战游戏房间
function  OpenTTZGameUI()
    --CS.LoadingDataUI.Show()
    local gameui1Node = CS.WindowManager.Instance:FindWindowNodeByName('TTZGameUI')
    if gameui1Node == nil then
        local openparam = CS.WindowNodeInitParam("TTZGameUI")
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
function  ParseTTZRoomPlayer(message)
    local playerID = message:PopUInt32()
    local Name = message:PopString()
    local HeadIcon = message:PopByte()
    local goldValue = message:PopInt64()
    local severposition = message:PopByte()
    local PlayerState = message:PopByte()
    local tCompensate = message:PopByte()
    local tBetCompensate = message:PopByte()

    goldValue = GameConfig.GetFormatColdNumber(goldValue)

    local position = TTZGameMgr.TTZRoomPositionConvert(severposition)

    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.TTZPlayerList[position].ID = playerID
    tRoomData.TTZPlayerList[position].Position = severposition
    tRoomData.TTZPlayerList[position].Name = Name
    tRoomData.TTZPlayerList[position].HeadIcon = HeadIcon
    tRoomData.TTZPlayerList[position].Gold = goldValue
    tRoomData.TTZPlayerList[position].nCanCompensate = tCompensate
    tRoomData.TTZPlayerList[position].nBetCompensate = tBetCompensate

    tRoomData.TTZPlayerList[position].PlayerState = PlayerState

    -- 解析扑克牌数据
    local pokerNumber = message:PopUInt16()
    for cardIndex = 1, pokerNumber, 1 do
        local PokerType = message:PopByte()
        local PokerNumber = message:PopByte()
        tRoomData.TTZPlayerList[position].Pokers[cardIndex].PokerType = PokerType
        tRoomData.TTZPlayerList[position].Pokers[cardIndex].PokerNumber = PokerNumber
        -- 已经搓牌 该玩家的牌应该全部显示
        if PlayerState == PlayerStateEnumTTZ.KanPai then
            tRoomData.TTZPlayerList[position].Pokers[cardIndex].Visible = true
        end
    end
    tRoomData.TTZPlayerList[position].strLoginIP = message:PopString()
end 

-------------------------------------------------------------------------------
-----------------S_TTZ_NEXT_STATE  747--------------------------------
-- 组局厅--服务器通知进入下一阶段
function  Received_S_TTZ_NEXT_STATE(message)
    print("=====747================")
    -- 当前房间状态
    local roomState = message:PopByte()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- print(string.format('=====747 推筒子当前状态:[%d] 房间类型:[%d]', roomState, tRoomData.RoomType))
    if roomState == ROOM_STATE_TTZ.START then
        -- 重回等待开始游戏状态
         ParseTTZReadyStart(message)
    elseif roomState == ROOM_STATE_TTZ.READY then
        -- 等待状态
        -- 清理掉当局数据
         ParseTTZReadyStart(message)
         ParseTTZDeletePlayer(message)
    elseif roomState == ROOM_STATE_TTZ.DEAL then
        -- 发牌状态
         ParseTTZDeal(message)
    elseif roomState == ROOM_STATE_TTZ.QIANG_ZHUANG then
        -- 抢庄状态
    elseif roomState == ROOM_STATE_TTZ.QIANG_ZHUANG_OVER then
        -- 抢庄结束
         ParseTTZOverQiangZhuang(message)
    elseif roomState == ROOM_STATE_TTZ.SET_ZHUANG then
        -- 选庄状态
         ParseTTZXuanZhuang(message)
    elseif roomState == ROOM_STATE_TTZ.XUAN_DOUBLE then
        -- 加倍状态
         ParseTTZStartXiaZhu(message)
    elseif roomState == ROOM_STATE_TTZ.OVER_DOUBLE then
        -- 加倍结束
         ParseTTZDoubleOver(message)
    elseif roomState == ROOM_STATE_TTZ.KANPAI then
        -- 自己搓牌状态
         ParseTTZKanPai(message)
    elseif roomState == ROOM_STATE_TTZ.OVER_KANPAI then
        -- 搓牌阶段结束
         ParseTTZKanPaiOver(message)
    elseif roomState == ROOM_STATE_TTZ.SETTLEMENT then
        -- 结算状态
         ParseTTZResult(message)
    end
    -- 设置组局厅房间状态
    GameData.RoomInfo.CurrentRoom:SetRoomState(roomState)
end

-- 重会[等待开始]状态
function  ParseTTZReadyStart(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 重置有效玩家的状态
    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        if tRoomData.TTZPlayerList[position].PlayerState >= PlayerStateEnumTTZ.JoinOK then
            tRoomData.TTZPlayerList[position].PlayerState = PlayerStateEnumTTZ.LookOn
        end
    end
end

-- 解析组局厅移除玩家列表
function  ParseTTZDeletePlayer(message)
    local BoardNumber = message:PopUInt32()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.BoardNumber = BoardNumber
    -- 解析移除玩家列表
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        position = TTZGameMgr.TTZRoomPositionConvert(position)

        tRoomData.TTZPlayerList[position].ID = 0
        tRoomData.TTZPlayerList[position].Name = ""
        tRoomData.TTZPlayerList[position].HeadIconUrl = ""
        tRoomData.TTZPlayerList[position].HeadIcon = 0
        tRoomData.TTZPlayerList[position].Gold = 0
        tRoomData.TTZPlayerList[position].PlayerState = PlayerStateEnumTTZ.NULL
    end

    tRoomData.BankerID = 0
end

-- 解析玩家下发牌情况
function  ParseTTZDeal(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 玩家状态重置
    for positionIndex = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        tRoomData.TTZPlayerList[positionIndex].PlayerState = PlayerStateEnumTTZ.NULL
        tRoomData.TTZPlayerList[positionIndex].CanPlaySplitPkoerAnimation = true
    end

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        local PlayerState = message:PopByte()
        position = TTZGameMgr.TTZRoomPositionConvert(position)
        local pokerCount = message:PopUInt16()
        for pokerIndex = 1, pokerCount, 1 do
            local tPokerType = message:PopByte()
            local tPokerNumber = message:PopByte()
            tRoomData.TTZPlayerList[position].Pokers[pokerIndex].PokerType = tPokerType
            tRoomData.TTZPlayerList[position].Pokers[pokerIndex].PokerNumber = tPokerNumber
            tRoomData.TTZPlayerList[position].Pokers[pokerIndex].Visible = false
        end

        -- 此刻会确认玩家参与游戏的状态( 参与 观看 )
        tRoomData.TTZPlayerList[position].PlayerState = PlayerState
    end
    -- 名牌模式 自己亮3张
    if tRoomData.LightPoker == 1 then
        local tPlayer = tRoomData.TTZPlayerList[MAX_TTZZUJU_ROOM_PLAYER]
        tPlayer.Pokers[1].Visible = true
    end
end

-- 解析抢庄结束情况
function  ParseTTZOverQiangZhuang(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        local PlayerState = message:PopByte()
        position = TTZGameMgr.TTZRoomPositionConvert(position)
        tRoomData.TTZPlayerList[position].PlayerState = PlayerState
    end
end

-- 解析选庄列表
function  ParseTTZXuanZhuang(message)
    -- 庄家位置
    local bankerPosition = message:PopByte()
    -- 位置转换
    bankerPosition = TTZGameMgr.TTZRoomPositionConvert(bankerPosition)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    tRoomData.BankerID = bankerPosition
    tRoomData.TTZPlayerList[bankerPosition].PlayerState = PlayerStateEnumTTZ.QZOK

    local playerCount = message:PopUInt16()
    for playerIndex = 1, playerCount, 1 do
        local position = message:PopByte()
        position = TTZGameMgr.TTZRoomPositionConvert(position)
        tRoomData.TTZPlayerList[position].PlayerState = PlayerStateEnumTTZ.QZOK
    end
end

-- 解析下注阶段玩家可以下注倍数
function  ParseTTZStartXiaZhu(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local nBankerCompensate = message:PopByte()
    local playerCount = message:PopUInt16()
    for index = 1,playerCount do
        local serverPosition = message:PopByte()
        local nCanCompensate = message:PopByte()
        local position = TTZGameMgr.TTZRoomPositionConvert(serverPosition)
        tRoomData.TTZPlayerList[position].nCanCompensate = nCanCompensate
    end
    tRoomData.nBankerCompensate = nBankerCompensate
end

-- 解析加倍结束 游戏状态
function  ParseTTZDoubleOver(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        -- 此刻的游戏状态表示的是玩家是否加倍
        local PlayerState = message:PopByte()
        local nBetCompensate = message:PopByte()
        position = TTZGameMgr.TTZRoomPositionConvert(position)
        tRoomData.TTZPlayerList[position].PlayerState = PlayerState
        tRoomData.TTZPlayerList[position].nBetCompensate = nBetCompensate
    end
end

-- 解析搓牌阶段 玩家扑克牌和游戏状态
function  ParseTTZKanPai(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        position = TTZGameMgr.TTZRoomPositionConvert(position)
        local pokerCount = message:PopUInt16()
        for pokerIndex = 1, pokerCount, 1 do
            local tPokerType = message:PopByte()
            local tPokerNumber = message:PopByte()
            tRoomData.TTZPlayerList[position].Pokers[pokerIndex].PokerType = tPokerType
            tRoomData.TTZPlayerList[position].Pokers[pokerIndex].PokerNumber = tPokerNumber
            tRoomData.TTZPlayerList[position].Pokers[pokerIndex].Visible = false
        end
    end

    tRoomData.TTZPlayerList[MAX_TTZZUJU_ROOM_PLAYER].Pokers[1].Visible = true
    tRoomData.TTZPlayerList[MAX_TTZZUJU_ROOM_PLAYER].Pokers[2].Visible = false
end

function  ParseTTZKanPaiOver(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    for position = 1, MAX_TTZZUJU_ROOM_PLAYER, 1 do
        if tRoomData.TTZPlayerList[position].PlayerState > PlayerStateEnumTTZ.JoinOK then
            tRoomData.TTZPlayerList[position].PlayerState = PlayerStateEnumTTZ.KanPai
            for cardIndex = 1, 2, 1 do
                -- 亮牌处理
                tRoomData.TTZPlayerList[position].Pokers[cardIndex].Visible = true
            end
        end
    end
end

-- 解析结算状态 玩家胜负情况
function  ParseTTZResult(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
        local position = message:PopByte()
        local WinGold = message:PopInt64()
        local GoldValue = message:PopInt64()
        WinGold = GameConfig.GetFormatColdNumber(WinGold)
        GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
        
        position = TTZGameMgr.TTZRoomPositionConvert(position)
        tRoomData.TTZPlayerList[position].WinGold = WinGold
        tRoomData.TTZPlayerList[position].Gold = GoldValue

        for cardIndex = 1, 2, 1 do
            tRoomData.TTZPlayerList[position].Pokers[cardIndex].Visible = true
        end
    end
end

---------------------------------------------------------------------------
-----------------S_TTZ_ADD_PLAYER  748-------------------------------------

function  Received_S_TTZ_ADD_PLAYER(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local severPosition = message:PopByte()
    local PlayerAccountID = message:PopUInt32()
    local playerName = message:PopString()
    local HeadIcon = message:PopByte()
    local GoldValue = message:PopInt64()
    local strLoginIP = message:PopString()
    GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
    local position = TTZGameMgr.TTZRoomPositionConvert(severPosition)

    tRoomData.TTZPlayerList[position].PlayerState = PlayerStateEnumTTZ.LookOn
    tRoomData.TTZPlayerList[position].Position = severPosition
    tRoomData.TTZPlayerList[position].ID  = PlayerAccountID
    tRoomData.TTZPlayerList[position].Name = playerName
    tRoomData.TTZPlayerList[position].HeadIcon = HeadIcon
    tRoomData.TTZPlayerList[position].Gold = GoldValue
    tRoomData.TTZPlayerList[position].strLoginIP = strLoginIP

    local eventArg = position
    -- 通知界面显示
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTTZAddPlayerEvent, eventArg)
end

---------------------------------------------------------------------------
-----------------S_TTZ_REMOVE_PLAYER  749--------------------------------

function  Received_S_TTZ_REMOVE_PLAYER(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local position = message:PopByte()
    position = TTZGameMgr.TTZRoomPositionConvert(position)
    tRoomData.TTZPlayerList[position].PlayerState = PlayerStateEnumTTZ.NULL
    tRoomData.TTZPlayerList[position].Name = ''
    tRoomData.TTZPlayerList[position].HeadIcon = 0
    tRoomData.TTZPlayerList[position].HeadIconUrl = ''
    tRoomData.TTZPlayerList[position].Gold = 0

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTTZDeletePlayerEvent, position)
end

---------------------------------------------------------------------------
-----------------CS_TTZ_READY  750-------------------------------------
-- 推筒子请求准备
function  NetMsgHandler.Send_CS_TTZ_Ready()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_READY, message, false)
end

-- 服务器反馈推筒子请求准备
function  Received_CS_TTZ_READY(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local resultType = message:PopByte()
    if resultType == 0 then
        local severPosition = message:PopByte()
        local tState  = message:PopByte()
        local position = TTZGameMgr.TTZRoomPositionConvert(severPosition)
        tRoomData.TTZPlayerList[position].PlayerState = tState

        local eventArg = position
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTTZPlayerReadyEvent, eventArg)
    else
        CS.BubblePrompt.Show(data.GetString("TTZ_Ready_Error_" .. resultType), "TTZGameUI")
    end
end

---------------------------------------------------------------------------
-----------------CS_TTZ_QIANG_ZHUANG  751--------------------------------
-- 请求是否抢庄 参数: 4 抢庄 5 不抢
function  NetMsgHandler.Send_CS_TTZ_QiangZhuang(qiangZhuangStateParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(qiangZhuangStateParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_QIANG_ZHUANG, message, false)
end

-- 服务器反馈抢庄结果()
function  Received_CS_TTZ_QIANG_ZHUANG(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local resultType = message:PopByte()
    if resultType == 0 then
        local PlayerPos = message:PopByte()
        -- 4抢庄 5不抢
        local PlayerState = message:PopByte()
        PlayerPos = TTZGameMgr.TTZRoomPositionConvert(PlayerPos)
        tRoomData.TTZPlayerList[PlayerPos].PlayerState = PlayerState
        -- 通知该玩家参与抢庄状态
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTTZPlayerQiangZhuangEvent, PlayerPos)
    else
        -- 抢庄异常
        CS.BubblePrompt.Show(data.GetString("TTZ_QZ_Error_" .. resultType), "TTZGameUI")
    end
end


---------------------------------------------------------------------------
-----------------CS_TTZ_BETTING  752--------------------------------
-- 请求加倍
function  NetMsgHandler.Send_CS_TTZ_Betting(doubleParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(doubleParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_BETTING, message, false)
end

function  Received_CS_TTZ_BETTING(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local playerPos = message:PopByte()
        local nBetCompensate = message:PopByte()
        playerPos = TTZGameMgr.TTZRoomPositionConvert(playerPos)
        local tRoomData = GameData.RoomInfo.CurrentRoom
        tRoomData.TTZPlayerList[playerPos].PlayerState = PlayerStateEnumTTZ.JiaBeiOK
        tRoomData.TTZPlayerList[playerPos].nBetCompensate = nBetCompensate
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTTZPlayerDoubleEvent, playerPos)
    else
        -- 加倍异常
        if resultType ~= 4 then
            CS.BubblePrompt.Show(data.GetString("TTZ_Bet_Error_" .. resultType), "TTZGameUI")
        end
    end
end



-------------------------------------------------------------------------------
-------------------------------CS_TTZ_KANPAI  753---------------------------
-- 组局厅 搓牌结束通知
function  NetMsgHandler.Send_CS_TTZ_KANPAI()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TTZ_KANPAI, message, false)
end


function  Received_CS_TTZ_KANPAI(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local position = message:PopByte()
        local tRoomData = GameData.RoomInfo.CurrentRoom

        position = TTZGameMgr.TTZRoomPositionConvert(position)
        for index = 1, 2, 1 do
            tRoomData.TTZPlayerList[position].Pokers[index].Visible = true
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTTZPlayerKanPaiEvent, position)
    else
        CS.BubblePrompt.Show(data.GetString("TTZ_KanPai_Error_" .. resultType), "TTZGameUI")
    end
end
