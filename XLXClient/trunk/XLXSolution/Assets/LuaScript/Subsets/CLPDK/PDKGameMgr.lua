--[[
   文件名称:PDKGameMgr.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

if PDKGameMgr == nil then
    PDKGameMgr =
    {
        PDKRoomPPOnline = {},    -- 跑得快匹配房间在线人数
    }
end

--==============================--
--desc:跑得快组局房间初始化
--time:2018-01-12 04:55:50
--@return 
--==============================--
function PDKGameMgr:InitRoomInfoPDKWR(roomTypeParam)
    local tNewRoom = PDKRoom:New()
    tNewRoom:Init(true, roomTypeParam)
    GameData.RoomInfo.CurrentRoom = tNewRoom
end

function PDKGameMgr:UpdateRoomCountDown( deltaValue )
    -- body
    GameData.RoomInfo.CurrentRoom.CountDown = GameData.RoomInfo.CurrentRoom.CountDown - deltaValue
end

--==============================--
--desc:跑得快组局房间位置转换(服务器位置==>UI显示位置)
--time:2018-01-12 05:17:48
--@nSeverPosition:
--@return 
--==============================--
function PDKRoomPositionConvert(nSeverPosition)
    if nSeverPosition > 0 then
        local position =(MAX_PDKZUJU_ROOM_PLAYER - GameData.RoomInfo.CurrentRoom.SelfPosition + nSeverPosition - 1) % MAX_PDKZUJU_ROOM_PLAYER + 1
        return position
    else
        print("服务器传入位置有误:" .. nSeverPosition)
        return 0
    end
end

--==============================--
--desc:获取扑克牌的牌型(跑得快)
--time:2018-01-12 07:35:18
--@pokerCard1:
--@pokerCard2:
--@pokerCard3:
--@pokerCard4:
--@pokerCard5:
--@return arg1: 扑克牌型 arg2: 重新拍好序的扑克牌 arg3: 最大的一张扑克牌
--==============================--
function GetPDKPokerCardTypeByPokerCards(pokerCard1, pokerCard2, pokerCard3, pokerCard4, pokerCard5)
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
function GetPDKZUJURoomDataByRoomIndex( indexParam , pageParam, onePageParam)
    -- body
    local tData = nil
    local _count = #GameData.PDKRoomList
    local tagIndex  = (pageParam - 1) * onePageParam + indexParam
    if tagIndex <= _count and tagIndex > 0 then
        -- body
        tData = GameData.PDKRoomList[tagIndex]
    end
    return tData
end

-------------------------------------------------------------------------------
-------------------------------组局厅房间相关协议------------------------------

-------------------------------------------------------------------------------
-------------------------------CS_PDK_Room_History  1200-------------------------
--==============================--
--desc:请求跑得快匹配房间在线人数
--time:2018-06-04 15:31:38
--@return 
--==============================--
function NetMsgHandler.Send_CS_PDKPP_Room_OnLine()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) 
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PDKPP_Room_OnLine, message, false)
end

function NetMsgHandler.Received_CS_PDKPP_Room_OnLine(message)
    -- 房间数量
    local count  = message:PopUInt16()
    PDKGameMgr.PDKRoomPPOnline = {}
    for index = 1, count, 1 do
        local OnlineData  =  {}
        -- 房间等级 （1平民 2小资 3老板）
        OnlineData.roomIndex  = message:PopByte()
        -- 房间在新人数
        OnlineData.OnlineCount  = message:PopUInt16()
        PDKGameMgr.PDKRoomPPOnline[index] = OnlineData
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomOnlineEvent, nil)
end

---------------------------------------------------------------------------
-----------------CS_PDKPP_Enter_Room  1212-------------------------------------

--==============================--
--desc:进入跑得快匹配房间
--time:2018-01-29 03:22:49
--@return 
--==============================--
function NetMsgHandler.Send_CS_PDKPP_Enter_Room(roomTypeParam,roomID)
    CS.MatchLoadingUI.Show()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(roomTypeParam)
    message:PushUInt32(roomID)
   -- print("*****************************请求进入跑得快匹配房间"..roomTypeParam.."******************************"..ProtrocolID.CS_PDKPP_Enter_Room.."roomID"..roomID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PDKPP_Enter_Room, message, false)
end
--==============================--
--desc:
--time:2018-01-29 03:23:08
--@message:
--@return 
--==============================--
function NetMsgHandler.Received_CS_PDKPP_Enter_Room( message )

    local resultType = message:PopByte()
    --print("**************************反馈进入跑得快匹配房间"..resultType.."******************************")
    if resultType == 0 then
        -- 进入游戏房间
        --local tRoomID  = message:PopUInt32()
        GameData.InitCurrentRoomInfo(ROOM_TYPE.PiPeiPDK, tRoomID)
        --CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
    else
        CS.MatchLoadingUI.Hide()     
        if resultType == 7 then
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        else
            if resultType == 8 then
                local GoldValue = message:PopInt64()
            end
            CS.BubblePrompt.Show(data.GetString("PDK_Enter_Room_Error_" .. resultType), "HallUI")
            NetMsgHandler.ExitRoomToHall(0)
        end
        
    end
end

---------------------------------------------------------------------------
-----------------CS_PDK_Leave_Room  1208-------------------------------------
-- 组局厅请求离开房间
function  NetMsgHandler.Send_CS_PDK_Leave_Room(rooIDParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PDK_Leave_Room, message, false)
end

function  NetMsgHandler.Received_CS_PDK_Leave_Room(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        NetMsgHandler.ExitRoomToHall(0)
    else
        local ErrorHints = data.GetString("PDK_Exit_Room_Error_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
    end

end

---------------------------------------------------------------------------
-----------------S_PDK_GAME_DATA  1214--------------------------------
-- 服务器发送房间总信息
function  NetMsgHandler.Received_S_PDK_Get_Game_Data(message)
    
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 房间ID
    local RoomID = message:PopUInt32()
    -- 房间等级
    local RoomLevel = message:PopByte()
    -- 房主ID
    local MasterID = message:PopUInt32()
    -- 房间状态
    local RoomState = message:PopByte()
    --print("*********************接收服务器发送跑的快房间总信息*******************",RoomState)
    -- 房间当前状态倒计时
    local CountDown = message:PopUInt32() / 1000
    -- 底注
    local MinBet = message:PopInt64()
    -- 玩家服务器位置
    local selfPos = message:PopByte()
    -- 上一出牌玩家位置
    local  LastPosition = message:PopByte()
    -- 桌面牌是谁出的
    --local DesktopCard = message:PopByte()
    -- 出牌张数
    local  OutCardNumber = message:PopByte()
    tRoomData.OutPokerTypre = 0
    
    tRoomData.OutCardInfo={}
    tRoomData.DesktopCardTable={}
    for Index = 1, OutCardNumber, 1 do
        -- 花色
        local PokerType = message:PopByte()
        -- 牌值
        local PokerNumber = message:PopByte()
        table.insert(tRoomData.OutCardInfo,{PokerType=PokerType,PokerNumber=PokerNumber} )
        table.insert(tRoomData.DesktopCardTable,{PokerType=PokerType,PokerNumber=PokerNumber} )
        if PokerNumber == 1 then
            tRoomData.DesktopCardTable[#tRoomData.DesktopCardTable].PokerNumber =14
        elseif PokerNumber == 2 then
            tRoomData.DesktopCardTable[#tRoomData.DesktopCardTable].PokerNumber =15
        end
    end
    
    --print(string.format('=====跑得快组局厅信息: RoomID:[%d] 房主ID:[%d] 房间状态:[%d] 状态倒计时:[%d]', RoomID, MasterID, RoomState, CountDown))

    tRoomData.RoomID = RoomID
    tRoomData.RoomLevel = RoomLevel
    tRoomData.MasterID = MasterID
    tRoomData.RoomState = RoomState
    tRoomData.CountDown = CountDown
    --tRoomData.DesktopCard = PDKRoomPositionConvert(DesktopCard)
    tRoomData.SelfPosition = selfPos
    tRoomData.MinBet = GameConfig.GetFormatColdNumber(MinBet)
    tRoomData.LastPosition = PDKRoomPositionConvert(LastPosition)
    tRoomData.OutCardNumber = OutCardNumber

    -- 进入房间时 将位置清空
    for position = 1, MAX_PDKZUJU_ROOM_PLAYER, 1 do
        tRoomData.PDKPlayerList[position].IsValid = PlayerStateEnumPDK.NULL
    end

    -- 玩家数据解析
    -- 房间玩家信息
    local playerCount = message:PopByte()
    for index = 1, playerCount, 1 do
         ParsePPPDKRoomPlayer(message)
    end

    tRoomData.PokerNumber = {}
    for Index=1,13,1 do
        -- 各牌值剩余牌数量
        local tNumber = message:PopByte()
        table.insert(tRoomData.PokerNumber,tNumber)
    end

    -- 结算数据解析
    -- 结算玩家数量
    
    local SettlementCount = message:PopByte()
    for posIndex = 1, SettlementCount, 1 do
        
        -- 玩家座位号
        local position = message:PopByte()
        
        position = PDKRoomPositionConvert(position)
        -- 玩家名字
        local Name = message:PopString()
        
        -- 赢牌张数
        local SettlementPokerNumber = message:PopInt32()
        -- 💣数
        local BoomNumber = message:PopByte()
        
        -- 金币变化数
        local WinGold = message:PopInt64()
        -- 金币数
        local goldValue = message:PopInt64()
        -- 剩余牌数量
        local SurplusPokerNumber = message:PopByte()
        tRoomData.PDKPlayerList[position].SurplusPokerNumber = SurplusPokerNumber
        tRoomData.PDKPlayerList[position].SurplusPokerPokers = {}
        for Index = 1,SurplusPokerNumber,1 do
            -- 牌花色
            local tPokerType = message:PopByte()
            -- 牌值
            local tPokerNumber = message:PopByte()
            --tRoomData.PDKPlayerList[position].SurplusPokerPokers[Index].PokerType = PokerType
            --tRoomData.PDKPlayerList[position].SurplusPokerPokers[Index].PokerNumber = PokerNumber
            table.insert(tRoomData.PDKPlayerList[position].SurplusPokerPokers,{PokerType=tPokerType,PokerNumber=tPokerNumber})
        end
        WinGold = GameConfig.GetFormatColdNumber(WinGold)
        goldValue = GameConfig.GetFormatColdNumber(goldValue)
        tRoomData.PDKPlayerList[position].SettlementName = Name
        tRoomData.PDKPlayerList[position].SettlementPokerNumber = SettlementPokerNumber
        tRoomData.PDKPlayerList[position].BombNumber = BoomNumber
        tRoomData.PDKPlayerList[position].WinGold = WinGold
        tRoomData.PDKPlayerList[position].Gold = goldValue
    end

    -- 桌面的牌是谁出的
    local DesktopCard = message:PopByte()
    DesktopCard = PDKRoomPositionConvert(DesktopCard)
    if DesktopCard == 0 then
        DesktopCard=3
    end
    -- 桌面牌的牌型
    local DesktopCardType = message:PopByte()
    tRoomData.DesktopCard = DesktopCard
    tRoomData.DesktopCardType = DesktopCardType

    -- 通知房间状态更新
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, tRoomData.RoomState)
    -- 切换状态为房间
    GameData.GameState = GAME_STATE.ROOM
    OpenPDKGameUI()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyEnterGameEvent, nil)
   
end

-- 进入对战游戏房间
function  OpenPDKGameUI()
    --CS.MatchLoadingUI.Show()
    local gameui1Node = CS.WindowManager.Instance:FindWindowNodeByName('PDKGameUI')
    if gameui1Node == nil then
        local openparam = CS.WindowNodeInitParam("PDKGameUI")
        openparam.NodeType = 0
        openparam.LoadComplatedCallBack = function(windowNode)
            HandleRefreshHallUIShowState(false)
        end
        CS.WindowManager.Instance:OpenWindow(openparam)
    else
        -- TODO  已经处于对战房间
        CS.MatchLoadingUI.Hide()
    end
end

-- 解析组局厅房间玩家详细信息
function  ParsePPPDKRoomPlayer(message)
    -- 玩家ID
    local playerID = message:PopUInt32()
    -- 玩家名字
    local Name = message:PopString()
    -- 头像ID
    local HeadIcon = message:PopByte()
    -- 玩家所在地址
    local strLoginIP = message:PopString()
    -- 玩家拥有金币
    local goldValue = message:PopInt64()
    -- 玩家位置
    local severposition = message:PopByte()
    -- 玩家状态
    local PlayerState = message:PopByte()
    -- 是否托管(1托管 0为托管)
    local IsRobot = message:PopByte()

    goldValue = GameConfig.GetFormatColdNumber(goldValue)
    

    local position = PDKRoomPositionConvert(severposition)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    if PlayerState == 5 then
        tRoomData.PlardCardPosition = position
    end
    tRoomData.PDKPlayerList[position].ID = playerID
    tRoomData.PDKPlayerList[position].IsValid = 1
    tRoomData.PDKPlayerList[position].Position = severposition
    tRoomData.PDKPlayerList[position].Name = Name
    tRoomData.PDKPlayerList[position].HeadIcon = HeadIcon
    tRoomData.PDKPlayerList[position].Gold = goldValue
    tRoomData.PDKPlayerList[position].strLoginIP = strLoginIP
    tRoomData.PDKPlayerList[position].PlayerState = PlayerState
    tRoomData.PDKPlayerList[position].IsRobot = IsRobot
    if PlayerState >= PlayerStateEnumPDK.JoinOK and PlayerState < PlayerStateEnumPDK.LookOn then
        tRoomData.PDKPlayerList[position].IsValid = PlayerStateEnumPDK.JoinOK
    else
        --tRoomData.PDKPlayerList[position].IsValid = PlayerStateEnumPDK.LookOn
    end
    -- 解析扑克牌数据
    -- 手牌数量
    local pokerNumber = message:PopByte()
    --print("=================玩家"..position.."拥有"..pokerNumber.."张扑克牌".."玩家状态"..PlayerState)
    tRoomData.PDKPlayerList[position].PokerNumber = pokerNumber
    tRoomData.PDKPlayerList[position].Pokers={}
    if tRoomData.PDKPlayerList[position].ID == GameData.RoleInfo.AccountID then
        for cardIndex = 1, pokerNumber, 1 do
            tRoomData.PDKPlayerList[position].Pokers[cardIndex]={}
            -- 牌花色
            local tPokerType = message:PopByte()
            -- 牌值
            local tPokerNumber = message:PopByte()
            tRoomData.PDKPlayerList[position].Pokers[cardIndex].PokerType = tPokerType
            tRoomData.PDKPlayerList[position].Pokers[cardIndex].PokerNumber = tPokerNumber
        end
    end
end 

-------------------------------------------------------------------------------
-----------------S_PDK_Enter_Next_State  1210--------------------------------
-- 组局厅--服务器通知进入下一阶段
function  NetMsgHandler.Received_S_PDK_Enter_Next_State(message)
    -- 当前房间状态
    local roomState = message:PopByte()
    -- print("*********************服务器通知进入下一阶段*********************",roomState)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    --print(string.format('组局厅当前状态:[%d] 房间类型:[%d]', roomState, tRoomData.RoomType))
    if roomState == ROOM_STATE_PDK.START then
        -- 重回等待开始游戏状态
        --PDKParseWaitStart(message)
        PDKParseWaitStart(message)
    elseif roomState == ROOM_STATE_PDK.DEAL then
        -- 发牌状态
        PDKParseZJRoomDeal(message)
    elseif roomState == ROOM_STATE_PDK.DECISION then
        -- 确定先手状态
        PDKParseZJRoomDecision(message)
    elseif roomState == ROOM_STATE_PDK.CHUPAI then
        -- 出牌状态
        PDKParseZJRoomChuPai(message)
    elseif roomState == ROOM_STATE_PDK.WAITCHUPAI then
        -- 等待出牌状态
        PDKParseZJRoomWaitChuPai(message)
    elseif roomState == ROOM_STATE_PDK.SETTLEMENT then
        -- 结算状态
        PDKParseZJRoomResult(message)
    end
    -- 设置组局厅房间状态
    --GameData.RoomInfo.CurrentRoom:SetRoomState(roomState)
    GameData.RoomInfo.CurrentRoom.RoomState = roomState
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoomState, roomState)
end

-- 重会[等待开始]状态
--[[function  PDKParseWaitStart(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 重置有效玩家的状态
    for position = 1, MAX_NNZUJU_ROOM_PLAYER, 1 do
        if tRoomData.PDKPlayerList[position].IsValid >= PlayerStateEnumNN.Ready then
            tRoomData.PDKPlayerList[position].IsValid = PlayerStateEnumNN.LookOn
            tRoomData.PDKPlayerList[position].PlayerState = PlayerStateEnumNN.LookOn
        end
    end
end--]]

-- 解析等待状态
function PDKParseWaitStart(message)
    -- 玩家数量
    local PlayerNumber = message:PopByte()
    for Index = 1, PlayerNumber, 1 do
        -- 玩家位置
        local position = message:PopByte()
        position = PDKRoomPositionConvert(position)
        -- 玩家状态
        local PlayerState = message:PopByte()
        local tRoomData = GameData.RoomInfo.CurrentRoom
        tRoomData.PDKPlayerList[position].PlayerState = PlayerState
    end
end

-- 解析玩家发牌
function PDKParseZJRoomDeal(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 房间当前状态倒计时
    local CountDown = message:PopUInt32() /1000
    tRoomData.CountDown = CountDown
    tRoomData.DesktopCard = 3
    -- 玩家数量
    local PlayerNumber = message:PopByte()
    for Index = 1, PlayerNumber, 1 do
        -- 玩家位置
        local position = message:PopByte()
        position = PDKRoomPositionConvert(position)
        -- 游戏状态(3:当前出牌 4：等待出牌)
        local playeState = message:PopByte()
        -- 牌数量
        local PokerCount = message:PopByte()
        tRoomData.PDKPlayerList[position].PlayerState = playeState
        tRoomData.PDKPlayerList[position].PokerNumber = PokerCount
        tRoomData.PDKPlayerList[position].Pokers={}
        --if position == 3 then
            for Count=1,PokerCount, 1 do
                -- 花色
                local PokerType = message:PopByte()
                -- 牌值
                local PokerNumber = message:PopByte()
                table.insert(tRoomData.PDKPlayerList[position].Pokers,{PokerType=PokerType,PokerNumber=PokerNumber})
                --print("解析玩家发牌",position,Count,PokerType,PokerNumber)
            end
        --end
    end
end

-- 解析玩家先手状态
function PDKParseZJRoomDecision(message)
    -- 第一手玩家出牌倒计时
    local CountDown = message:PopUInt32()/1000
    GameData.RoomInfo.CurrentRoom.CountDown = CountDown
end

-- 解析玩家出牌
function PDKParseZJRoomChuPai(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 玩家位置
    local position = message:PopByte()
    -- 下一出牌玩家位置
    local NextPosition = message:PopByte()
    -- 当前倒计时
    local CountDown = message:PopUInt32()/1000
    -- 玩家状态
    local state = message:PopByte()
    -- 牌型
    local PokerTableType = message:PopByte()
    -- 牌数量
    local Count=message:PopByte()
    position = PDKRoomPositionConvert(position)
    NextPosition= PDKRoomPositionConvert(NextPosition)
    tRoomData.LastPosition = position
    tRoomData.PDKPlayerList[position].PlayerState = state
    tRoomData.OutPokerTypre = PokerTableType
    tRoomData.PDKPlayerList[NextPosition].PlayerState = PlayerStateEnumPDK.Out
    tRoomData.PlardCardPosition = NextPosition
    
    tRoomData.OutCardNumber = Count
    tRoomData.CountDown = CountDown
    tRoomData.OutCardInfo={}
    --print("&&&&&&&&&&&&&&&&&上一出牌玩家位置"..position.."下一出牌玩家位置"..NextPosition.."倒计时"..tRoomData.CountDown.."",tRoomData.PDKPlayerList[position].PlayerState,PokerTableType,Count)
    for Index = 1,Count,1 do
        -- 花色
        local PokerType = message:PopByte()
        -- 牌值
        local PokerNumber = message:PopByte()
        table.insert(tRoomData.OutCardInfo,{PokerType=PokerType,PokerNumber=PokerNumber} )
        
    end
    -- 桌面的牌是谁出的
    local DesktopCard = message:PopByte()
    -- 桌面牌的牌型
    local DesktopCardType = message:PopByte()
    tRoomData.DesktopCard = PDKRoomPositionConvert(DesktopCard)
    -- 桌面的牌数量
    local DesktopCardNumber = message:PopByte()
    tRoomData.DesktopCardTable={}
    for Index=1,DesktopCardNumber,1 do
        
        -- 花色
        local PokerType = message:PopByte()
        -- 牌值
        local PokerNumber = message:PopByte()
        if PokerNumber == 1 then
            PokerNumber =14
        elseif PokerNumber == 2 then
            PokerNumber =15
        end
        table.insert(tRoomData.DesktopCardTable, {PokerType=PokerType,PokerNumber=PokerNumber})
    end
    
    tRoomData.DesktopCardType = DesktopCardType
end

-- 解析玩家等待出牌
function PDKParseZJRoomWaitChuPai(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 玩家位置
    local position = message:PopByte()
    -- 下一出牌玩家位置
    local NextPosition = message:PopByte()
    -- 当前倒计时
    local CountDown = message:PopUInt32()/1000
    -- 玩家状态
    local state = message:PopByte()
    -- 牌型
    local PokerTableType = message:PopByte()
    -- 桌面的牌是谁出的
    --local DesktopCard = message:PopByte()
    -- 牌数量
    local Count=message:PopByte()
    position = PDKRoomPositionConvert(position)
    NextPosition= PDKRoomPositionConvert(NextPosition)
    tRoomData.LastPosition = position
    tRoomData.PDKPlayerList[position].PlayerState = state
    tRoomData.OutPokerTypre = PokerTableType
    tRoomData.PDKPlayerList[NextPosition].PlayerState = PlayerStateEnumPDK.Out
    tRoomData.PlardCardPosition = NextPosition
    tRoomData.OutCardNumber = Count
    tRoomData.CountDown = CountDown
    tRoomData.OutCardInfo={}
    
    --print("&&&&&&&&&&&&&&&&&上一出牌玩家位置"..position.."下一出牌玩家位置"..NextPosition.."倒计时"..tRoomData.CountDown.."",tRoomData.PDKPlayerList[position].PlayerState,PokerTableType,Count)
    for Index = 1,Count,1 do
        -- 花色
        local PokerType = message:PopByte()
        -- 牌值
        local PokerNumber = message:PopByte()
        table.insert(tRoomData.OutCardInfo,{PokerType=PokerType,PokerNumber=PokerNumber} )
        
    end
    -- 桌面的牌是谁出的
    local DesktopCard = message:PopByte()
    -- 桌面牌的牌型
    local DesktopCardType = message:PopByte()
    tRoomData.DesktopCard = PDKRoomPositionConvert(DesktopCard)
    -- 桌面的牌数量
    local DesktopCardNumber = message:PopByte()
    tRoomData.DesktopCardTable={}
    for Index=1,DesktopCardNumber,1 do
        -- 花色
        local PokerType = message:PopByte()
        -- 牌值
        local PokerNumber = message:PopByte()
        if PokerNumber == 1 then
            PokerNumber =14
        elseif PokerNumber == 2 then
            PokerNumber =15
        end
        table.insert(tRoomData.DesktopCardTable, {PokerType=PokerType,PokerNumber=PokerNumber})
            
    end
    tRoomData.DesktopCardType = DesktopCardType
end

-- 解析玩家结算
function PDKParseZJRoomResult(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 当前倒计时
    local CountDown = message:PopUInt32()/1000
    tRoomData.CountDown = CountDown
    -- 参与结算玩家数量
    local PlayerNumber = message:PopByte()
    for Index=1, PlayerNumber, 1 do
        -- 玩家位置
        local position = message:PopByte()
        position = PDKRoomPositionConvert(position)
        -- 玩家地址
        local Name = message:PopString()
        -- 玩家赢牌张数
        local WinCardNumber = message:PopInt32()
        -- 💣数
        local BoomsNumber = message:PopByte()
        -- 变化金币数量
        local WinGold = message:PopInt64()
        -- 玩家拥有金币
        local goldValue = message:PopInt64()
        -- 剩余牌数量
        local CardsNumber = message:PopByte()
        tRoomData.PDKPlayerList[position].SurplusPokerNumber = CardsNumber
        tRoomData.PDKPlayerList[position].SurplusPokerPokers = {}
        for Count=1,CardsNumber,1 do
            -- 花色
            local PokerType = message:PopByte()
            -- 牌值
            local PokerNumber = message:PopByte()
            --tRoomData.PDKPlayerList[position].SurplusPokerPokers[Count].PokerType = PokerType
           -- tRoomData.PDKPlayerList[position].SurplusPokerPokers[Count].PokerNumber = PokerNumber
            table.insert(tRoomData.PDKPlayerList[position].SurplusPokerPokers,{PokerType=PokerType,PokerNumber=PokerNumber})
        end
        WinGold = GameConfig.GetFormatColdNumber(WinGold)
        goldValue = GameConfig.GetFormatColdNumber(goldValue)
        tRoomData.PDKPlayerList[position].SettlementName = Name
        tRoomData.PDKPlayerList[position].SettlementPokerNumber = WinCardNumber
        tRoomData.PDKPlayerList[position].BombNumber = BoomsNumber
        tRoomData.PDKPlayerList[position].WinGold = WinGold
        tRoomData.PDKPlayerList[position].Gold = goldValue
    end

end
---------------------------------------------------------------------------
-----------------S_PDK_AddPlayer  1213 -------------------------------------
--新增一个玩家
function  NetMsgHandler.Received_S_ZJPDKRoom_AddPlayer(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 玩家位置
    local severPosition = message:PopByte()
    -- 玩家ID
    local nAccountID = message:PopUInt32()
    -- 玩家名字
    local playerName = message:PopString()
    -- 玩家头像ID
    local HeadIcon = message:PopByte()
    -- 玩家金币数量
    local GoldValue = message:PopInt64()
    -- 玩家地址
    local strLoginIP = message:PopString()
    -- 玩家状态
    --local PlayerState = message:PopByte()

    --local PlayerState = message:PopByte()
    
    
    
    GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
    local position = PDKRoomPositionConvert(severPosition)
    --[[if PlayerState > PlayerStateEnumPDK.JoinOK then
        tRoomData.PDKPlayerList[position].IsValid = PlayerStateEnumPDK.JoinOK
    else
        tRoomData.PDKPlayerList[position].IsValid = PlayerState
    end--]]

    tRoomData.PDKPlayerList[position].ID = nAccountID
    tRoomData.PDKPlayerList[position].PlayerState = PlayerStateEnumPDK.Ready
    tRoomData.PDKPlayerList[position].Position = severPosition
    tRoomData.PDKPlayerList[position].Name = playerName
    tRoomData.PDKPlayerList[position].HeadIcon = HeadIcon
    tRoomData.PDKPlayerList[position].Gold = GoldValue
    tRoomData.PDKPlayerList[position].strLoginIP = strLoginIP

    local eventArg = position
    -- 通知界面显示
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPDKRoomAddPlayer, eventArg)
end

---------------------------------------------------------------------------
-----------------S_PDK_DeletePlayer  1211--------------------------------

function  NetMsgHandler.Received_S_ZJRoom_DeletePlayer(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local position = message:PopByte()
    position = PDKRoomPositionConvert(position)
    tRoomData.PDKPlayerList[position].IsValid = PlayerStateEnumPDK.NULL
    tRoomData.PDKPlayerList[position].PlayerState = PlayerStateEnumPDK.NULL
    tRoomData.PDKPlayerList[position].Name = ''
    tRoomData.PDKPlayerList[position].HeadIcon = 0
    --tRoomData.PDKPlayerList[position].HeadIconUrl = ''
    tRoomData.PDKPlayerList[position].Gold = 0
    tRoomData.PDKPlayerList[position].strLoginIP = ""
    tRoomData.PDKPlayerList[position].ID = 0

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPDKDeletePlayerEvent, position)
end

---------------------------------------------------------------------------
-----------------CS_PDK_Ready  1203-------------------------------------
-- 组局厅玩家请求准备
function  NetMsgHandler.Send_CS_PDK_Ready()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PDK_Ready, message, false)
end

-- 服务器反馈玩家准备
function  NetMsgHandler.Received_CS_PDK_Ready(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 玩家账号ID
        local ID = message:PopUInt32()
        -- 玩家座位号
        local severPosition = message:PopByte()
        -- 玩家状态
        local tState  = message:PopByte()
        local position = PDKRoomPositionConvert(severPosition)
        tRoomData.PDKPlayerList[position].PlayerState = tState
       -- print("服务器反馈玩家准备",ID,position,tState)
        local eventArg = position
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPDKZJPlayerReadyEvent, eventArg)
    else
        CS.BubblePrompt.Show(data.GetString("PDK_Room_Ready_Error_" .. resultType), "PDKGameUI1")
    end
end

---------------------------------------------------------------------------
-----------------CS_PDK_PlayerChuPai  1206---------------------------------
-- （匹配跑得快）玩家请求出牌
function NetMsgHandler.Send_CS_PDK_PlayerOutPoker(tOutCardTable)
    local message = CS.Net.PushMessage()
    -- 玩家账号ID
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 玩家出牌数量
    message:PushUInt16(#tOutCardTable)
    for Index=1,#tOutCardTable,1 do
        -- 牌花色
        message:PushByte(tOutCardTable[Index].PokerType)
        -- 牌值
        message:PushByte(tOutCardTable[Index].PokerNumber)
    end
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PDK_PlayerChuPai, message, false)
end

-- （匹配跑得快）反馈玩家请求出牌
function  NetMsgHandler.Received_CS_PDK_PlayerOutPoker(message)
    local resultType = message:PopByte()
    if resultType == 0 then
       -- print("跑得快出牌成功！！！！！！！！！")
    else
        if resultType ~= 4 then
            local ErrorHints = data.GetString("PDK_OutCard_Error_" .. resultType)
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        end
    end
end

---------------------------------------------------------------------------
-----------------CS_PDK_ROBOT  1217---------------------------------
-- 玩家请求托管
function NetMsgHandler.Send_CS_PDK_ROBOT(RobotType)
    local message = CS.Net.PushMessage()
    -- 玩家账号ID
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 请求托管类型(0取消 1托管)
    message:PushByte(RobotType)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PDK_ROBOT, message, false)
end

-- 反馈玩家托管
function  NetMsgHandler.Received_CS_PDK_ROBOT(message)
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom
        if tRoomData.PDKPlayerList[3].IsRobot == 0 then
            local IsRobot = message:PopByte()
            tRoomData.PDKPlayerList[3].IsRobot = IsRobot
        else
            tRoomData.PDKPlayerList[3].IsRobot=0
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPDKRobotEvent)
    else
        local ErrorHints = data.GetString("PDK_ROBOT_Error_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
    end
end

---------------------------------------------------------------------------
-----------------CS_PDK_ROBOT  1218---------------------------------
-- 玩家请求提示
function NetMsgHandler.Send_CS_PDK_Prompt()
    local message = CS.Net.PushMessage()
    -- 玩家账号ID
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_PDK_Prompt, message, false)
end

-- 反馈玩家提示
function  NetMsgHandler.Received_CS_PDK_Prompt(message)
    local resultType = message:PopByte()
    
    if resultType ==0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom
        -- 提示张数
        local Count = message:PopByte()
        tRoomData.Prompt = {}
        for Index= 1 , Count, 1 do
            -- 牌型
            local PokerType = message:PopByte()
            -- 牌值
            local  PokerNumber = message:PopByte()
            table.insert(tRoomData.Prompt,{PokerType=PokerType,PokerNumber = PokerNumber} )
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPDKPromptEvent)
    else
        local ErrorHints = data.GetString("PDK_Prompt_Error_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
    end
end

---------------------------------------------------------------------------
-----------------S_PDK_BombChangeGold  1219---------------------------------
-- 服务器反馈炸弹实时结算通知
function  NetMsgHandler.Received_S_PDK_BombChangeGold(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.ChangeGoldList={}
    local tCount = message:PopByte()
    for Index=1,tCount,1 do
        local position = message:PopByte()
        -- 变化金币
        local ChangeGold = message:PopInt64()
        ChangeGold = GameConfig.GetFormatColdNumber(ChangeGold)
        local tposition = PDKRoomPositionConvert(position)
        tRoomData.PDKPlayerList[tposition].Gold = tRoomData.PDKPlayerList[tposition].Gold + ChangeGold
        table.insert(tRoomData.ChangeGoldList,{position=tposition,Gold=ChangeGold})
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyPDKBombChangeGoldEvent)
end