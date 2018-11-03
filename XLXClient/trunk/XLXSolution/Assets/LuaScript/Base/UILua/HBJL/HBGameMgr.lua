
local function SortRoomList(tA, tB)
    return tA.IsJoin==tB.IsJoin and (tA.EstablishTime>tB.EstablishTime) or (tA.IsJoin>tB.IsJoin)
end

-- 请求红包接龙房间列表
function NetMsgHandler.Send_CS_HB_Room_List()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_HB_RoomList, message, false)
end

-- 服务器反馈红包接龙房间列表
function NetMsgHandler.Received_CS_HBRoomList(message)
    GameData.HBRoomList = { }
    --是否成功
    local refType=message:PopByte()
    if refType == 0 then
        --房间数量
        local roomCount = message:PopUInt16()
        for index = 1, roomCount, 1 do
            local roomData = { }
            roomData.Position = index
            --房间ID
            roomData.RoomID = message:PopUInt32()
            -- 游戏模式（1=小接龙，2=大接龙）
            roomData.GameMode = message:PopByte()
            --当前玩家数量
            roomData.OnlineCount = message:PopByte()
            --房间最大人数
            roomData.RoomMaxNumber=message:PopByte()
            --红包底注
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
            roomData.EstablishTime=message:PopUInt32()
            GameData.HBRoomList[index] = roomData
        end
        table.sort(GameData.HBRoomList, SortRoomList)

        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomListUpdateEvent, nil)
    else
        CS.BubblePrompt.Show(data.GetString("HB_Exit_Room_Error_1" ), "HallUI")
        
    end
end

-- (红包接龙)请求历史关联房间
function  NetMsgHandler.Send_CS_HB_Room_History()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_HB_Room_History, message, true)
end

---- (红包接龙)反馈历史关联房间

function NetMsgHandler.Received_CS_HB_Room_History(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 成功
        -- 房间数量
        local count = message:PopUInt16()
        GameData.RoomInfo.RelationRooms = { }
        for i = 1, count, 1 do
            -- 房间ID
            local roomID = message:PopUInt32()
            -- 房主名字
            local masterName = message:PopString()
            GameData.RoomInfo.RelationRooms[roomID] = masterName
        end
    else
        CS.BubblePrompt.Show(data.GetString("HB_Exit_Room_Error_1"), "HallUI")
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHBHistoryRoomEvent, nil)
end

-- 
--==============================--
--desc:红包接龙请求创建房间(房间等级 陌生人加入 游戏模式(小接龙 大接龙):1 2 入场金币:100 离场金币:20)
--time:2018-01-20 11:21:04
--@roomLevel:房间等级
--@isLockParam:是否锁定
--@roomTypeParam:游戏模式(小接龙 大接龙):1 2
--@roomStyle:(1 普通房间,2 茶馆房间 3馆主房间)
--@systemCost:系统抽水
--@ownerCost:馆主抽水
--@return 
--==============================--
function NetMsgHandler.Send_CS_HB_Create_Room(roomLevel, isLockParam, roomTypeParam, roomStyle, systemCost, ownerCost)
    -- body
    local message = CS.Net.PushMessage();
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 房间等级
    message:PushByte(roomLevel)
    -- 是否公开
    message:PushByte(isLockParam)
    -- 房间类型
    message:PushByte(roomTypeParam)
    message:PushByte(roomStyle)
    message:PushByte(systemCost)
    message:PushByte(ownerCost)
    

    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_HB_Create_Room, message, true)
end

-- 红包接龙请求创建房间反馈
function NetMsgHandler.Received_CS_HB_Create_Room(message)
    -- body
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then

        local ZJRoomID = message:PopUInt32()
        GameData.RoomInfo.CurrentRoom.RoomID = ZJRoomID
        -- 红包接龙房间创建成功 马上进入房间
        NetMsgHandler.Send_CS_HB_Enter_Room1(ZJRoomID,0)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyCreateRoomSuccess, nil)
        
    else
        CS.BubblePrompt.Show(data.GetString("HB_Create_Room_Error_" .. resultType), "HallUI")
    end
end

-- 红包接龙请求进入房间 713
function NetMsgHandler.Send_CS_HB_Enter_Room1(roomIDParam,roomType)
    -- body
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    --0 匹配场 ~=0组局厅
    message:PushUInt32(roomIDParam)
    -- 0 组局场 7~10 匹配场
    message:PushByte(roomType)
    GameData.HBJL.RoomLevel=roomType
    CS.MatchLoadingUI.Show()
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_HB_Enter_Room, message, false)
end

-- 红包接龙请求进入组局房间  713
function NetMsgHandler.Received_CS_HB_Enter_Room1(message)
    -- body
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 进入游戏房间
        local tRoomID  = message:PopUInt32()
        GameData.InitCurrentRoomInfo(ROOM_TYPE.HongBao, tRoomID)
        
        CS.WindowManager.Instance:CloseWindow("UIJoinRoom", false)
        --CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
    elseif resultType == 3 then
        local boxData = CS.MessageBoxData()
        boxData.Title = "提示"
        boxData.Content = data.GetString("HB_Enter_Room_Error_3")
        boxData.Style = 1
        boxData.LuaCallBack = HB_GoldNotEnoughConfirmOnClick
        -- 直接提出房间并弹出提示
        NetMsgHandler.ExitRoomToHall(0)
        CS.MessageBoxUI.Show(boxData)
        CS.MatchLoadingUI.Hide()
    else
        if resultType ~= 5 then
            CS.BubblePrompt.Show(data.GetString("HB_Enter_Room_Error_" .. resultType), "HallUI")
            NetMsgHandler.ExitRoomToHall(0)
            CS.MatchLoadingUI.Hide()
            if resultType == 7 then
                local GoldValue = message:PopInt64()
            end
        else
            CS.MatchLoadingUI.Hide()
            NetMsgHandler.TryAutoEnterRoomMessageBos()
        end
    end
end

-- 红包接龙反馈房间详细信息  715
function NetMsgHandler.Received_S_HB_Set_Game_Data(message)
    -- 房间ID
    GameData.RoomInfo.CurrentRoom.RoomID = message:PopUInt32()
    -- 房间子类型（1组局 2 匹配）
    GameData.RoomInfo.CurrentRoom.SubType = message:PopByte()
    if GameData.RoomInfo.CurrentRoom.SubType == 1 then
        GameData.RoomInfo.CurrentRoom.RoomType = ROOM_TYPE.HongBao
    elseif GameData.RoomInfo.CurrentRoom.SubType == 2 then
        GameData.RoomInfo.CurrentRoom.RoomType = ROOM_TYPE.PPHongBao
    end
    -- 游戏模式（1小接龙 2大接龙）
    GameData.RoomInfo.CurrentRoom.GameMode = message:PopByte()
    -- 房间红包底注
    GameData.RoomInfo.CurrentRoom.BetMin = message:PopUInt32()
    -- 房间状态
    GameData.RoomInfo.CurrentRoom.RoomState = message:PopByte()
    -- 房间倒计时
    GameData.RoomInfo.CurrentRoom.CountDown = message:PopUInt32()/1000
    -- 玩家所在位置
    GameData.RoomInfo.CurrentRoom.SelfPosition = message:PopByte()
    -- 玩家是否抢过本局红包(0没抢过 1抢过)
    GameData.HBJL.RobRedEnvelopes = message:PopByte()
    -- 房间玩家数量
    local playerCount = message:PopByte()
    -- 发红包玩家ID
    local giveID=message:PopUInt32()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.FaHBID=giveID
    tRoomData.playerCount=playerCount
    for index=1,playerCount,1 do 
        -- 服务器玩家位置
        local severposition = message:PopByte()
        -- 玩家ID
        local playerID = message:PopUInt32()
        -- 玩家姓名
        local Name = message:PopString()
        -- 头像ID
        local HeadIcon = message:PopByte()
        -- 玩家金币
        local GoldValue = message:PopInt64()

        local position = GameData.PlayerPositionConvert8ShowPosition(severposition)
        GoldValue = GameConfig.GetFormatColdNumber(GoldValue)

        if giveID == playerID then
            tRoomData.FHB_GOLD=GoldValue
        end
        tRoomData.HongBaoPlayers[position]={}
        tRoomData.HongBaoPlayers[position].PlayerState = PlayerStateEnumHB.JoinOK
        tRoomData.HongBaoPlayers[position].ID = playerID
        tRoomData.HongBaoPlayers[position].Position = severposition
        tRoomData.HongBaoPlayers[position].Name = Name
        tRoomData.HongBaoPlayers[position].HeadIcon = HeadIcon
        tRoomData.HongBaoPlayers[position].GoldValue = GoldValue
        tRoomData.HongBaoPlayers[position].strLoginIP = message:PopString()
    end
    if GameData.RoomInfo.CurrentRoom.RoomState == ROOM_STATE_HB.WAIT then
    elseif GameData.RoomInfo.CurrentRoom.RoomState == ROOM_STATE_HB.XUAN_ZHUANG then
    elseif GameData.RoomInfo.CurrentRoom.RoomState == ROOM_STATE_HB.FA_HONGBAO then
        local type=message:PopByte()
        -- 玩家不是庄家
        if type == 0 then
        -- 玩家是庄家
        elseif type == 1 then

        end
    elseif GameData.RoomInfo.CurrentRoom.RoomState == ROOM_STATE_HB.QIANG_HONGBAO then
        tRoomData.QHBposition={}
        -- 发红包玩家名字
        local bankerName=message:PopString()
        -- 发红包玩家地址
        local bankerStrLoginIP = message:PopString()
        -- 红包剩余数量
        local SurplusHBNumber = message:PopByte()
        -- 抢红包玩家数量
       --[[ local count = message:PopByte()
        tRoomData.QHB_Count=count
        tRoomData.GrabRedEnvelopeInfo={}
        for index=1,count do
            tRoomData.GrabRedEnvelopeInfo[index]={}
            -- 玩家名字
            tRoomData.GrabRedEnvelopeInfo[index].Name=message:PopString()
            -- 玩家Icon
            tRoomData.GrabRedEnvelopeInfo[index].HeadIcon=message:PopByte()
            -- 玩家地址
            tRoomData.GrabRedEnvelopeInfo[index].strLoginIP=message:PopString()
        end--]]
        tRoomData.FaHongBaoPlayerName=bankerName
        tRoomData.FaHongBaoPlayerStrLoginIP=bankerStrLoginIP
        tRoomData.SurplusHBNumber = SurplusHBNumber
    elseif GameData.RoomInfo.CurrentRoom.RoomState == ROOM_STATE_HB.SETTLEMENT then
        -- 结算玩家数量
        local count =message:PopByte()
        tRoomData.QHB_Count=count
        tRoomData.GrabRedEnvelopeInfo={}
        for index=1,count do
            -- 玩家账号ID
            local JSplayerID=message:PopUInt32()
            -- 玩家名字
            local JSMingZi=message:PopString()
            -- 玩家头像
            local JSheadIcon=message:PopByte()
            -- 玩家地址
            local strLoginIP=message:PopString()
            -- 结算金币
            local JSgold=message:PopInt64()
            JSgold = GameConfig.GetFormatColdNumber(JSgold)
            tRoomData.GrabRedEnvelopeInfo[index]={}
            tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeName=JSMingZi
            tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeHeadIcon=JSheadIcon
            tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeStrLoginIP=strLoginIP
            tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeplayerID=JSplayerID
            tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeGold=JSgold
        end
        local fhb_name=tRoomData.GrabRedEnvelopeInfo[1].GrabRedEnvelopeName
        tRoomData.FaHongBaoPlayerName=fhb_name
        local fhb_strLoginIP = tRoomData.GrabRedEnvelopeInfo[1].GrabRedEnvelopeStrLoginIP
        tRoomData.FaHongBaoPlayerStrLoginIP=fhb_strLoginIP
    end
    
    

    --CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, GameData.RoomInfo.CurrentRoom.RoomState)
    -- 切换状态为房间
    GameData.GameState = GAME_STATE.ROOM
    NetMsgHandler.OpenHongBaoGameUI()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyEnterGameEvent, nil)
end

-- 进入对战游戏房间
function NetMsgHandler.OpenHongBaoGameUI()
    local gameui1Node = CS.WindowManager.Instance:FindWindowNodeByName('HBGameUI1')
    if gameui1Node == nil then
        local openparam = CS.WindowNodeInitParam("HBGameUI1")
        openparam.NodeType = 0
        openparam.LoadComplatedCallBack = function(windowNode)
            HandleRefreshHallUIShowState(false)
        end
        CS.WindowManager.Instance:OpenWindow(openparam)
       
    else
        -- TODO  已经处于对战房间
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdatePlayerPosition)
        CS.MatchLoadingUI.Hide()
    end
    GameData.SetHBRoomState(GameData.RoomInfo.CurrentRoom.RoomState)
    
end

-- 组局厅请求离开房间
function  NetMsgHandler.Send_CS_HB_Leave_Room()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    --message:PushUInt32(rooIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_HB_Leave_Room, message, true)
end

function  NetMsgHandler.Received_CS_HB_Leave_Room(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 直接提出房间并弹出提示
        NetMsgHandler.ExitRoomToHall(0)
    else
        CS.BubblePrompt.Show(data.GetString("HB_Exit_Room_Error_" .. resultType), "HallUI")
    end
end

--服务器反馈新增一个玩家  724
function NetMsgHandler.Received_S_HB_AddPlayer(message)
    --服务端玩家位置
    local severposition = message:PopByte()
    --玩家ID
    local playerID = message:PopUInt32()
    --玩家姓名
    local Name = message:PopString()
    --头像ID
    local HeadIcon = message:PopByte()
    --玩家金币
    local GoldValue = message:PopInt64()
    local strLoginIP = message:PopString()

    local position = GameData.PlayerPositionConvert8ShowPosition(severposition)
    GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.playerCount=tRoomData.playerCount+1
    tRoomData.HongBaoPlayers[position]={}
    tRoomData.HongBaoPlayers[position].IsValid=2
    tRoomData.HongBaoPlayers[position].Position = severposition
    tRoomData.HongBaoPlayers[position].Name = Name
    tRoomData.HongBaoPlayers[position].HeadIcon = HeadIcon
    tRoomData.HongBaoPlayers[position].GoldValue = GoldValue
    tRoomData.HongBaoPlayers[position].ID = playerID
    tRoomData.HongBaoPlayers[position].strLoginIP = strLoginIP

    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHBRoomAddPlayer,position)

end

--服务器反馈删除一个玩家
function NetMsgHandler.Received_S_HB_DeletePlayer(message)
    local severposition = message:PopByte()
    local position = GameData.PlayerPositionConvert8ShowPosition(severposition)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.playerCount=tRoomData.playerCount-1
    tRoomData.HongBaoPlayers[position]=nil
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHBRoomDeleteplayerPlayer,position)
end

-- 红包接龙通知房间下一阶段      717
function NetMsgHandler.Received_S_HB_Next_State(message)
    local RoomState = message:PopByte()
    GameData.RoomInfo.CurrentRoom.RoomState=RoomState
    -- print('=====717***** 红包接龙当前阶段:' .. RoomState)
    if RoomState == ROOM_STATE_HB.Wait then
    elseif RoomState == ROOM_STATE_HB.XUAN_ZHUANG then
        Received_S_HB_Give_HongBao_Position(message)
        --GameData.SetHBRoomState(RoomState)
    elseif RoomState == ROOM_STATE_HB.FA_HONGBAO then
        GameData.RoomInfo.CurrentRoom.RobRedEnvelopes = 0
        GameData.HBJL.RobRedEnvelopes = 0
        BnakerFaHongBao(message)
        
    elseif RoomState == ROOM_STATE_HB.QIANG_HONGBAO then
        
        local tRoomData = GameData.RoomInfo.CurrentRoom
        tRoomData.CountDown=data.PublicConfig.HB_TIME[3]
        -- 发红包玩家姓名
        local FaHBPlayerName=message:PopString()
        tRoomData.FaHongBaoPlayerName=FaHBPlayerName
        -- 发红包玩家地址
        local bankerStrLoginIP = message:PopString()
        tRoomData.FaHongBaoPlayerStrLoginIP=bankerStrLoginIP
        local Gold = message:PopInt64()
        Gold = GameConfig.GetFormatColdNumber(Gold)
        tRoomData.FHB_GOLD = Gold
        --GameData.SetHBRoomState(RoomState)
    elseif RoomState == ROOM_STATE_HB.SETTLEMENT then
        HB_SETTLEMENT(message)
    end
    GameData.SetHBRoomState(RoomState)
end
-- 通知发红包玩家位置
function Received_S_HB_Give_HongBao_Position(message)
    local bankerPosition = message:PopByte()
    -- 位置转换
    bankerPosition = GameData.PlayerPositionConvert8ShowPosition(bankerPosition)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.BankerID = bankerPosition
    tRoomData.HongBaoPlayers[bankerPosition].PlayerState = PlayerStateEnumHB.FaHongBaoOK
    tRoomData.FaHBID=tRoomData.HongBaoPlayers[bankerPosition].ID
end

--通知发红包
function BnakerFaHongBao(message)
    -- 玩家ID
    local BankerID = message:PopUInt32()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.FaHBID=BankerID
    tRoomData.SurplusHBNumber=5
    tRoomData.QHBposition={}
end

-- 通知结算
function HB_SETTLEMENT(message)
     -- 发红包玩家姓名
     local FaHBPlayerName=message:PopString()
     -- 发红包玩家地址
     local bankerStrLoginIP = message:PopString()
     -- 下一轮发红包玩家ID
     local NextHBID=message:PopUInt32()
    -- 结算人数
    local count= message:PopByte()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.FaHongBaoPlayerName=FaHBPlayerName
    tRoomData.FaHongBaoPlayerStrLoginIP=bankerStrLoginIP
    tRoomData.FaHBID=NextHBID
    tRoomData.QHBposition={}
    tRoomData.QHB_Count=count
    tRoomData.CountDown=data.PublicConfig.HB_TIME[3]
    for index=1,count do
        -- 抢红包玩家位置玩家
        --local position=message:PopByte()
        --position = GameData.PlayerPositionConvert8ShowPosition(position)
        -- 玩家ID
        local id=message:PopUInt32()
        -- 玩家姓名
        local name= message:PopString()
        -- 玩家头像
        local HeadIcon=message:PopByte()
        -- 玩家头像
        local strLoginIP = message:PopString()
        -- 玩家金币
        local Gold=message:PopInt64()
        -- 玩家拥有金币
        local HaveGold=message:PopInt64()
        HaveGold = GameConfig.GetFormatColdNumber(HaveGold)
        Gold = GameConfig.GetFormatColdNumber(Gold)
        tRoomData.GrabRedEnvelopeInfo[index]={}
        tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeName=name
        tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeHeadIcon=HeadIcon
        tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeStrLoginIP=strLoginIP
        tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeplayerID=id
        tRoomData.GrabRedEnvelopeInfo[index].GrabRedEnvelopeGold=Gold
        for count=1,MAX_HBZUJU_ROOM_PLAYER do
            if tRoomData.HongBaoPlayers[count]~=nil then
                if id==tRoomData.HongBaoPlayers[count].ID then
                    tRoomData.HongBaoPlayers[count].GoldValue=HaveGold
                    table.insert( tRoomData.QHBposition,count )
                end
            end
        end
    end
end

-- 庄家请求发红包      721
function NetMsgHandler.Send_CS_HB_Banker_FaHongBao()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    --message:PushUInt32(rooIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_HB_Banker_FaHongBao, message, false)
end

-- 服务器反馈发红包     721
function NetMsgHandler.Received_CS_HB_Banker_FaHongBao(message)
    local type=message:PopByte()
    print("服务器反馈发红包状态",type)
    if type ~= 0 then
        CS.BubblePrompt.Show(data.GetString("HB_FaHongBao_Error_" .. type), "HBGameUI1")
    end
end

-- 玩家请求抢红包      722
function NetMsgHandler.Send_CS_HB_Player_QiangHongBao()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    --message:PushUInt32(rooIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_HB_Player_QiangHongBao, message, false)
end

-- 服务器反馈玩家抢红包       722
function NetMsgHandler.Received_CS_HB_Player_QiangHongBao(message)
    local type =message:PopByte()
    if type==0 then
        -- 发红包玩家名字
        local BankerName=message:PopString()
        -- 发红包玩家地址
        local bankerStrLoginIP = message:PopString()
        -- 抢红包玩家位置
        local position=message:PopByte()
        -- 剩余红包数量
        local SurplusHBNumber = message:PopByte()

        position = GameData.PlayerPositionConvert8ShowPosition(position)
        local tRoomData = GameData.RoomInfo.CurrentRoom
        tRoomData.FaHongBaoPlayerName=BankerName
        tRoomData.FaHongBaoPlayerStrLoginIP=bankerStrLoginIP
        tRoomData.SurplusHBNumber = SurplusHBNumber
        if position == 8 then
            GameData.RoomInfo.CurrentRoom.RobRedEnvelopes = 1
            GameData.HBJL.RobRedEnvelopes = 1
        end
        -- 抢红包玩家数量
        --[[local Count=message:PopByte()
        tRoomData.QHB_Count=Count
        tRoomData.GrabRedEnvelopeInfo={}
        for index=1,Count do
            tRoomData.GrabRedEnvelopeInfo[index]={}
            -- 玩家名字
            tRoomData.GrabRedEnvelopeInfo[index].Name=message:PopString()
            -- 玩家Icon
            tRoomData.GrabRedEnvelopeInfo[index].HeadIcon=message:PopByte()
            -- 玩家地址
            tRoomData.GrabRedEnvelopeInfo[index].strLoginIP = message:PopString()
        end--]]

        --if SurplusHBNumber~=0 then
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateSettlementInterfaceDisplay,position)
        --end
    else
        if type ~= 3 then
            CS.BubblePrompt.Show(data.GetString("HB_QiangHongBao_Error_" .. type), "HBGameUI1")
        end
    end
end

-- 服务器反馈玩家金币不足，强制踢出
function NetMsgHandler.Received_S_HB_Kick_Out(message)
local type=message:PopByte()
    if type == 0 then
        local boxData = CS.MessageBoxData()
        boxData.Title = "提示"
        boxData.Content = data.GetString("NN_Exit_Room_Error_5")
        boxData.Style = 1
        boxData.LuaCallBack = NetMsgHandler.GoldNotEnoughConfirmOnClick
        -- 直接提出房间并弹出提示
        NetMsgHandler.ExitRoomToHall(0)
        CS.MessageBoxUI.Show(boxData)
    end
end
