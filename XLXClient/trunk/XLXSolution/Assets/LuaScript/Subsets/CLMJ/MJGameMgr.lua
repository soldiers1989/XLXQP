--[[
   文件名称:MJGameMgr.lua
   创 建 人: 左石岩
   创建时间：2018.3
   功能描述：
]]--

if MJGameMgr == nil then
    MJGameMgr =
    {
        MJRoomPPOnline = {},       -- 推筒子匹配房间在线人数
        MJRoomList = {},           -- 推筒子组局房间列表
    }
end

--==============================--
--desc:麻将组局房间初始化
--time:2018-03-12 09:31:50
--@return 
--==============================--
function MJGameMgr:InitRoomInfo(roomTypeParam)
    local tNewRoom = MJRoom:New()
    tNewRoom:Init(true, roomTypeParam)
    GameData.RoomInfo.CurrentRoom = tNewRoom
end

function MJGameMgr:UpdateRoomCountDown( deltaValue )
    -- body
    GameData.RoomInfo.CurrentRoom.MJCountDown = GameData.RoomInfo.CurrentRoom.MJCountDown - deltaValue
end

--==============================--
--desc:麻将组局房间位置转换(服务器位置==>UI显示位置)
--time:2018-03-12 09:32:48
--@nSeverPosition:
--@return 
--==============================--
function MJGameMgr.MJRoomPositionConvert(nSeverPosition)
    if nSeverPosition > 0 then
        local position =(MAX_MJZUJU_ROOM_PLAYER - GameData.RoomInfo.CurrentRoom.SelfPosition + nSeverPosition - 1) % MAX_MJZUJU_ROOM_PLAYER + 1
        return position
    else
        print("服务器传入位置有误:" .. nSeverPosition)
        return 0
    end
end

-- 碰杠胡玩家位置(1上家，2对家，3下家,4本家)
function MJGameMgr.MJpghPlayerPosition(position,nSeverPosition)
    local MJpghPosition=
    {
        [1]={DUI=3,SHANG=4,XIA=2,BEN=1},
        [2]={DUI=4,SHANG=1,XIA=3,BEN=2},
        [3]={DUI=1,SHANG=2,XIA=4,BEN=3},
        [4]={DUI=2,SHANG=3,XIA=1,BEN=4},
    }
    if nSeverPosition == MJpghPosition[position].DUI then
        return 2
    elseif nSeverPosition == MJpghPosition[position].SHANG then
        return 3
    elseif nSeverPosition == MJpghPosition[position].XIA then
        return 1
    elseif nSeverPosition == MJpghPosition[position].BEN then
        return 4
    end
    --[[return MJpghPosition[position].
    if nSeverPosition == 1 then
        nSeverPosition=3
    elseif nSeverPosition == 2 then
        nSeverPosition=2
    elseif nSeverPosition == 3 then
        nSeverPosition=1
    elseif nSeverPosition == 4 then
        nSeverPosition=4
    end
    return nSeverPosition-]]
end

--==============================--
--desc:获取扑克牌的牌型(推筒子)
--time:2018-02-28 05:22:21
--@pokerCard1:麻将1
--@pokerCard2:麻将2
--@return agr1 牌型 agr2 点数
--==============================--
function MJGameMgr.GetPokerCardTypeByPokerCards(pokerCard1, pokerCard2)
    if pokerCard1 == nil or pokerCard2 == nil then
        return MJ_Card_Type.SANPAI1, 0
    end

    local number1 = math.min(10, pokerCard1.PokerNumber)
    local number2 = math.min(10, pokerCard2.PokerNumber)

    -- 牌型确认
    local resultType = MJ_Card_Type.SANPAI2
    if number1 == number2 then
        -- 豹子以上
        if number1 == 10 then
            resultType = MJ_Card_Type.ZHIZUN
        else
            resultType = MJ_Card_Type.BAOZI
        end
    else
        if number1 + number2 == 10 then
            --28杠
            if number1 == 2 or number1 == 8 then
                resultType = MJ_Card_Type.GANG28
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
    if resultType == MJ_Card_Type.SANPAI2 then
        if resultNumber <= 75 then
             resultType = MJ_Card_Type.SANPAI1
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
function MJGameMgr.GetPokerCardSpriteName(pokerNumber)
    local cardSpriteName = "sprite_MJ_"..pokerNumber
    return cardSpriteName
end

--==============================--
--desc:获取推筒子扑克牌型资源
--time:2018-03-05 06:12:50
--@pokerType:
--@pokerNumber:
--@return 
--==============================--
function MJGameMgr.GetPokerCardTypeSpriteName( pokerType, pokerNumber )
    local cardSpriteName = "sprite_MJd_tzz"
    if pokerType == MJ_Card_Type.ZHIZUN then
        cardSpriteName = "sprite_MJd_tzz"
    elseif pokerType == MJ_Card_Type.BAOZI then
        cardSpriteName = "sprite_MJd_tbz"
    elseif pokerType == MJ_Card_Type.GANG28 then
        cardSpriteName = "sprite_MJd_t28"
    else
        cardSpriteName = "sprite_MJd_"..pokerNumber
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
function MJGameMgr.GetRoomDataByRoomIndex( indexParam , pageParam, onePageParam)
    -- body
    local tData = nil
    local _count = #MJGameMgr.MJRoomList
    local tagIndex  = (pageParam - 1) * onePageParam + indexParam
    if tagIndex <= _count and tagIndex > 0 then
        -- body
        tData = MJGameMgr.MJRoomList[tagIndex]
    end
    return tData
end

-------------------------------------------------------------------------------
-------------------------------组局厅房间相关协议------------------------------

---------------------------------------------------------------------------
-----------------请求组局房房间列表  761------------------------------------

function  NetMsgHandler.Send_CS_MJRoom_RoomList()
    print("请求组局房房间列表")
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_ZUJU_ROOM_LIST, message, false)
    MJGameMgr.MJRoomList = { }
end

local function _CompMJRoom( tA, tB)
    return tA.IsJoin==tB.IsJoin and (tA.createRoomTime>tB.createRoomTime) or (tA.IsJoin>tB.IsJoin)
end

function  NetMsgHandler.Received_CS_MJRoom_RoomList(message)
    local count = message:PopUInt16()
    print("组局麻将房间列表数量",count)
    for i = 1, count do
        local roomData = { }
        --房间ID
        roomData.RoomID = message:PopUInt32()
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
        MJGameMgr.MJRoomList = MJGameMgr.MJRoomList or { }
        MJGameMgr.MJRoomList[i] = roomData
    end
    if count > 0 then
        table.sort( MJGameMgr.MJRoomList, _CompMJRoom )
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyHongBaoRoomListUpdateEvent)
end


---------------------------------------------------------------------------
-----------------请求创建房间  762-------------------------------------

--==============================--
--desc:麻将组局房间创建请求
--time:2018-01-20 11:21:04
--@nRoomLevel:房间等级
--@isLock:是否锁定
--@nEnterimit:入场限制
--@nLeaveLimit:进场限制
--@nZiMoMode:自摸模式
--@nDianGangHuaMode:点杠花模式
--@nJaingDui:将对
--@nMenQing:门清
--@nTianDiHu:天地胡
--@nHaiDiLaoYue:海底捞月
--@nFengDingBeiLv:封顶倍率
--@nJuShu:局数
--@isTeaRoom:是否茶馆房间(1 普通房间,2 茶馆房间 3馆主房间)
--@systemCost:系统抽水
--@ownerCost:馆主抽水
--@return 
--@房间等级 是否加锁 入场限制 离场限制 自摸模式 点杠花模式 呼叫转移 将对 门清 天地胡 海底捞月 封顶倍率 局数
--==============================--
function  NetMsgHandler.Send_CS_MJ_Room_Create(nRoomLevel, isLock, nEnterimit, nLeaveLimit, nZiMoMode, nDianGangHuaMode, nJaingDui, nMenQing, nTianDiHu, nHaiDiLaoYue, nFengDingBeiLv, nJuShu,isTeaRoom,systemCost,ownerCost )
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushByte(nRoomLevel)
    message:PushByte(isLock or 1)
    message:PushInt64(nEnterimit)
    message:PushInt64(nLeaveLimit)
    message:PushByte(nZiMoMode)
    message:PushByte(nDianGangHuaMode)
    message:PushByte(nJaingDui)
    message:PushByte(nMenQing)
    message:PushByte(nTianDiHu)
    message:PushByte(nHaiDiLaoYue)
    message:PushByte(nFengDingBeiLv)
    message:PushByte(nJuShu)
    message:PushByte(isTeaRoom)
    message:PushByte(systemCost)
    message:PushByte(ownerCost)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_ZUJU_CREATE, message, true)
end

function  NetMsgHandler.Received_CS_MJ_Room_Create(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local ZJRoomID = message:PopUInt32()
        GameData.RoomInfo.CurrentRoom.RoomID = ZJRoomID
        -- 组局厅房间创建成功 马上进入房间
        NetMsgHandler.Send_CS_MJ_ZUJU_ENTER_ROOM(ZJRoomID)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyCreateRoomSuccess,nil)
    else
        CS.BubblePrompt.Show(data.GetString("MJ_Create_Error_" .. resultType), "HallUI")
    end
end

---------------------------------------------------------------------------
-----------------请求进入房间  763-------------------------------
-- (麻将)请求进入房间
function  NetMsgHandler.Send_CS_MJ_ZUJU_ENTER_ROOM(roomIDParam)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(roomIDParam)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_ZUJU_ENTER_ROOM, message, true)
end

-- (麻将)服务器反馈进入房间结果
function  NetMsgHandler.Received_CS_MJ_ZUJU_ENTER_ROOM(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        -- 进入游戏房间
        local tRoomID  = message:PopUInt32()
        local tRoomType = message:PopByte()
        GameData.InitCurrentRoomInfo(tRoomType, tRoomID)
        CS.WindowManager.Instance:CloseWindow("MJCreateRoom", false)
        CS.WindowManager.Instance:CloseWindow("UIJoinRoom", false)
    else
        CS.BubblePrompt.Show(data.GetString("MJ_Enter_Error_" .. resultType), "HallUI")
        NetMsgHandler.ExitRoomToHall(0)
    end
end

---------------------------------------------------------------------------
-----------------请求离开房间  764-------------------------------------
-- 组局厅请求离开房间
function  NetMsgHandler.Send_CS_MJ_LEAVE_ROOM()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_LEAVE_ROOM, message, true)
end

function  NetMsgHandler.Received_CS_MJ_LEAVE_ROOM(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        NetMsgHandler.ExitRoomToHall(0)
    else
        local ErrorHints = data.GetString("MJ_Exit_Room_Error_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        --CS.BubblePrompt.Show(data.GetString("MJ_Exit_Room_Error_" .. resultType), "HallUI")
    end
end

---------------------------------------------------------------------------
-----------------服务器发送房间数据  765--------------------------------

function  NetMsgHandler.Received_S_MJ_ROOM_DATA(message)
    -- 房间ID
    local RoomID = message:PopUInt32()
    -- 房主ID
    local MasterID = message:PopUInt32()
    -- 房间状态
    local RoomState = message:PopByte()
    -- 房间状态倒计时
    local CountDown = message:PopUInt32() / 1000
    -- 房间庄家所在位置(0 表示没有庄家)
    local BankerPos = message:PopByte()
    -- 当前出牌玩家位置
    local chupaiwanjiaweizhi = message:PopByte()
    -- 玩家自己所在位置
    local selfPos = message:PopByte()
    -- 上一出牌玩家位置
    local LastOutCardPlayerPosition= message:PopByte()
    -- 底注
    local MinBet = message:PopInt64()
    -- 限入金币
    local EnterBet = message:PopInt64()
    -- 是否加锁
    local IsLock = message:PopByte()
    -- 牌局进行数量
    local BoardCurrentNumber = message:PopByte()
    -- 牌局最大数量
    local BoardMaxNumber = message:PopByte()
    -- 本次牌组剩余牌数量
    local CardsSurplusNumber = message:PopByte()
    -- 封顶
    local FengDingBeiLv = message:PopByte()
    -- 自摸模式
    local ZiMoMode= message:PopByte()
    -- 点杠花模式
    local DianGangHuaMode = message:PopByte()
    -- 将对
    local JiangDui = message:PopByte()
    -- 门清 
    local MenQing = message:PopByte()
    -- 天地胡
    local TiandiaHu = message:PopByte()
    -- 海底捞月
    local HaiDiLaoYue = message:PopByte()
    local tRoomData = GameData.RoomInfo.CurrentRoom

    tRoomData.RoomID = RoomID
    tRoomData.MasterID = MasterID
    tRoomData.RoomState = RoomState
    tRoomData.MJCountDown = CountDown
    tRoomData.SelfPosition = selfPos
    tRoomData.BankerPosition = MJGameMgr.MJRoomPositionConvert(BankerPos)
    tRoomData.PlardCardPosition=MJGameMgr.MJRoomPositionConvert(chupaiwanjiaweizhi)
    print("当前房间状态2,庄家位置",tRoomData.RoomState,tRoomData.BankerPosition)
    tRoomData.LastOutCardPlayer=MJGameMgr.MJRoomPositionConvert(LastOutCardPlayerPosition)
    tRoomData.BoardCurrentNumber = BoardCurrentNumber
    tRoomData.BoardMaxNumber = BoardMaxNumber
    tRoomData.CardsSurplusNumber = CardsSurplusNumber
    tRoomData.MinBet = GameConfig.GetFormatColdNumber(MinBet)
    tRoomData.EnterBet = GameConfig.GetFormatColdNumber(EnterBet)
    tRoomData.IsLock = IsLock
    tRoomData.FengDingBeiLv = FengDingBeiLv
    tRoomData.ZiMoMode = ZiMoMode
    tRoomData.DianGangHuaMode = DianGangHuaMode
    tRoomData.JiangDui = JiangDui
    tRoomData.MenQing = MenQing
    tRoomData.TiandiaHu = TiandiaHu
    tRoomData.HaiDiLaoYue = HaiDiLaoYue
    GameData.RoomInfo.CurrentRoom.FlowBureauInfo={}
    --tRoomData.BankerID = MJGameMgr.MJRoomPositionConvert(BankerPos)

    -- 进入房间时 将位置清空
    for position = 1, MAX_MJZUJU_ROOM_PLAYER, 1 do
        tRoomData.MJPlayerList[position].PlayerState = PlayerStateEnumMJ.NULL
    end

    -- 玩家数据解析
    local playerCount = message:PopUInt16()
    for index = 1, playerCount, 1 do
         ParseMJRoomPlayer(message)
    end

    -- 解析房间状态
    ParseMJRoomInfo(message)
    
    -- 切换状态为房间
    GameData.GameState = GAME_STATE.ROOM
    OpenMJGameUI()
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyEnterGameEvent, nil)
end

-- 解析组局厅房间玩家详细信息
function  ParseMJRoomPlayer(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 玩家ID
    local playerID = message:PopUInt32()
    -- 玩家名字
    local Name = message:PopString()
    -- 玩家头像ID
    local HeadIcon = message:PopByte()
    -- 玩家地址
    local StrLoginIP = message:PopString()
    -- 玩家金币数量
    local goldValue = message:PopInt64()
    -- 位置下标
    local severposition = message:PopByte()
    local position = MJGameMgr.MJRoomPositionConvert(severposition)
    -- 玩家状态
    local PlayerState = message:PopByte()
    -- 玩家是否一炮多响(0不处理1胡的那张牌显示虚化)
    local IsYPDX = message:PopByte()
    -- 玩家是否饶炮(0不能胡1能胡)
    local raopao = message:PopByte()
    -- 玩家是否过碰(0没有过碰1有过碰)
    local GuoPeng = message:PopByte()
    tRoomData.MJPlayerList[position].GuoPengTable={}
    for Index=1,GuoPeng,1 do
        local GuoPengType = message:PopByte()
        local GuoPengNumber = message:PopByte()
        table.insert( tRoomData.MJPlayerList[position].GuoPeng, {PokerType=GuoPengType,PokerNumber=GuoPengNumber})
    end
    -- 玩家是否刚碰过牌(0不能杠，1能杠)
    local IsPeng = message:PopByte()
    -- 玩家定缺(0无 1 筒 2 条 3 万)
    local DingQue = message:PopByte()
    goldValue = GameConfig.GetFormatColdNumber(goldValue)
    
    
    if PlayerState == PlayerStateEnumMJ.HU then
        --胡牌花色
        local HUtype=message:PopByte()
        --胡牌点数
        local HUnumber=message:PopByte()
        tRoomData.MJPlayerList[position].HUtype=HUtype
        tRoomData.MJPlayerList[position].HUnumber=HUnumber
    end

   
    tRoomData.MJPlayerList[position].ID = playerID
    tRoomData.MJPlayerList[position].Position = severposition
    tRoomData.MJPlayerList[position].Name = Name
    tRoomData.MJPlayerList[position].StrLoginIP = StrLoginIP
    tRoomData.MJPlayerList[position].HeadIcon = HeadIcon
    tRoomData.MJPlayerList[position].Gold = goldValue
    tRoomData.MJPlayerList[position].PlayerState = PlayerState
    tRoomData.MJPlayerList[position].RaoPao=raopao
    tRoomData.MJPlayerList[position].GuoPeng=GuoPeng
    tRoomData.MJPlayerList[position].QueType=DingQue
    tRoomData.MJPlayerList[position].Pokers={}
    tRoomData.MJPlayerList[position].OnlyPokers={}
    tRoomData.MJPlayerList[position].PengPokers={}
    tRoomData.MJPlayerList[position].GangPokers={}
    tRoomData.MJPlayerList[position].ChuPokers={}
    tRoomData.MJPlayerList[position].IsYPDX = IsYPDX
    tRoomData.MJPlayerList[position].IsPeng = IsPeng
    -- 解析扑克牌数据
    -- 玩家手牌数量
    local pokerNumber = message:PopUInt16()
    tRoomData.MJPlayerList[position].PokerNumber=pokerNumber
    if tRoomData.MJPlayerList[position].ID == GameData.RoleInfo.AccountID then
        for cardIndex = 1, pokerNumber, 1 do
            -- 牌花色
            local tPokerType = message:PopByte()
            -- 牌点数
            local tPokerNumber = message:PopByte()
            table.insert( tRoomData.MJPlayerList[position].Pokers, {PokerType=tPokerType, PokerNumber=tPokerNumber} )
        end
    end

    -- 单牌数量
    local OnlyCardNumber = message:PopUInt16()
    tRoomData.MJPlayerList[position].onlyPokerNumber=OnlyCardNumber
    if tRoomData.MJPlayerList[position].ID == GameData.RoleInfo.AccountID then
        for OnlyIndex = 1, OnlyCardNumber, 1 do
             -- 单牌花色
            local tOnlyPokerType = message:PopByte()
             -- 单牌点数
            local tOnlyPokerNumber = message:PopByte()
            table.insert( tRoomData.MJPlayerList[position].OnlyPokers, {PokerType=tOnlyPokerType, PokerNumber=tOnlyPokerNumber} )
        end
    end
    -- 碰牌数量
    local PengCardsNumber = message:PopUInt16()
    tRoomData.MJPlayerList[position].pengPokerNumber=PengCardsNumber
        for pengIndex = 1, PengCardsNumber, 1 do
            -- 碰牌花色
            local tPengPokerType = message:PopByte()
            -- 碰牌点数
            local tPengPokerNumber = message:PopByte()
            table.insert( tRoomData.MJPlayerList[position].PengPokers, {PokerType=tPengPokerType, PokerNumber=tPengPokerNumber} )
        end

    -- 杠牌数量
    local GangCardsNumber = message:PopUInt16()
    tRoomData.MJPlayerList[position].gangPokerNumber=GangCardsNumber
        for gangIndex = 1, GangCardsNumber, 1 do
            -- 杠牌花色
            local tGangPokerType = message:PopByte()
            -- 杠牌点数
            local tGangPokerNumber = message:PopByte()
            -- 杠牌类型(1暗杠 2明杠 3补杠)
            local tGangType = message:PopByte()
            table.insert( tRoomData.MJPlayerList[position].GangPokers, {PokerType=tGangPokerType, PokerNumber=tGangPokerNumber,GangType=tGangType} )
        end

    -- 已出牌数量
    local YiChuPai = message:PopUInt16()
    tRoomData.MJPlayerList[position].yichupaishuliang=YiChuPai
    for chupai=1,YiChuPai,1 do
        -- 出牌花色
        local chupaihuase=message:PopByte()
        -- 出牌点数
        local chupaidianshu=message:PopByte()
        table.insert( tRoomData.MJPlayerList[position].ChuPokers, {PokerType=chupaihuase, PokerNumber=chupaidianshu} )
    end
    tRoomData.MJPlayerList[position].strLoginIP = message:PopString()
end

function ParseMJRoomInfo(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    if tRoomData.RoomState == ROOM_STATE_MJ.WAIT then
        -- 牌的类型
        local Cardtype=message:PopByte()
        -- 牌的点数
        local number=message:PopByte()
        -- 位置
        local position = message:PopByte()
        position=MJGameMgr.MJRoomPositionConvert(position)
        GameData.RoomInfo.CurrentRoom.WaitCardType=Cardtype
        GameData.RoomInfo.CurrentRoom.WaitCardNumber=number
        GameData.RoomInfo.CurrentRoom.WaitPGHPlayerPosition=position
    elseif tRoomData.RoomState == ROOM_STATE_MJ.SETTLEMENT then
        --玩家数量
        local PlayerCount= message:PopUInt16()
        GameData.RoomInfo.CurrentRoom.SettlementPlayerNumber=PlayerCount
        GameData.RoomInfo.CurrentRoom.SettlementPlayer={}
        GameData.RoomInfo.CurrentRoom.ChangeGoldReason={}
        for index=1,PlayerCount,1 do
            -- 玩家位置
            local tPosition = message:PopByte()
            tPosition=MJGameMgr.MJRoomPositionConvert(tPosition)
            --玩家名字
            local tName = message:PopString()
            --玩家头像ID
            local tHeadIcon = message:PopByte()
            --玩家头像URL
            local tStrLoginIP = message:PopString()
            -- 玩家金币
            local tGold = message:PopInt64()
             --记录数量
            local tCount =message:PopUInt16()
            table.insert( GameData.RoomInfo.CurrentRoom.SettlementPlayer, {position=tPosition,Name=tName,ID=tHeadIcon,StrLoginIP=tStrLoginIP,Gold=tGold,Count=tCount} )
            for num=1,tCount,1 do
                -- 类型
                local Changetype=message:PopByte()
                -- 玩家位置
                local position1=message:PopByte()
                position1 = MJGameMgr.MJRoomPositionConvert(position1)
                -- 倍率
                local LV=message:PopUInt32()
                -- 变化金币
                local Gold1= message:PopInt64()
                if Changetype<=14 then
                    -- 胡牌类型(1自摸2非自摸)
                    local HuType=message:PopByte()
                    -- 几家
                    local PlayersNumber=message:PopByte()
                    -- 根(0没有，1，2，3，4根)
                    local Gen = message:PopByte()
                    -- 将对(1有0没有)
                    local JiangDui = message:PopByte()
                    -- 门清(1有2没有)
                    local MenQing=message:PopByte()
                    -- 杠上花(0不显示胡1杠1=杠上花，胡2杠1=杠上炮)
                    local GangShang=message:PopByte()
                    -- 海底捞(0不显示,胡2海底捞1=海底炮，胡1海底捞1=海底捞月)
                    local HaidiLao=message:PopByte()
                    -- 抢杠胡(0显示，1不显示)
                    local QiangGangHu=message:PopByte()
                    if GameData.RoomInfo.CurrentRoom.SettlementPlayer[index].position == 4 then
                        table.insert( GameData.RoomInfo.CurrentRoom.ChangeGoldReason, {Changetype=Changetype,position=position1,LV=LV,Gold=Gold1,HuType=HuType,PlayersNumber=PlayersNumber,Gen=Gen,JiangDui=JiangDui,MenQing=MenQing,GangShang=GangShang,HaidiLao=HaidiLao,QiangGangHu=QiangGangHu} )
                    end
                end
                if GameData.RoomInfo.CurrentRoom.SettlementPlayer[index].position == 4 and Changetype>14 then
                    table.insert(GameData.RoomInfo.CurrentRoom.ChangeGoldReason,{Changetype=Changetype,position=position1,LV=LV,Gold=Gold1})
                end
            end
        end
        for index=1,PlayerCount,1 do
            --位置
            local playerposition=message:PopByte()
            local aa=playerposition
            playerposition = MJGameMgr.MJRoomPositionConvert(playerposition)
            --牌数量
            local playerCardNumber=message:PopUInt16()
            local tRoomData = GameData.RoomInfo.CurrentRoom
            tRoomData.MJPlayerList[playerposition].PokerNumber=playerCardNumber
            tRoomData.MJPlayerList[playerposition].Pokers={}
            for count1=1,playerCardNumber,1 do
                --牌类型
                local cardType=message:PopByte()
                --牌点数
                local CardNumber=message:PopByte()
                table.insert( tRoomData.MJPlayerList[playerposition].Pokers, {PokerType=cardType, PokerNumber=CardNumber} )
            end
        end
    end
end


-- 进入对战游戏房间
function  OpenMJGameUI()
    CS.LoadingDataUI.Show()
    local gameui1Node = CS.WindowManager.Instance:FindWindowNodeByName('MJGameUI')
    if gameui1Node == nil then
        local openparam = CS.WindowNodeInitParam("MJGameUI")
        openparam.NodeType = 0
        openparam.LoadComplatedCallBack = function(windowNode)
            HandleRefreshHallUIShowState(false)
            CS.LoadingDataUI.Hide()
        end
        CS.WindowManager.Instance:OpenWindow(openparam)
    else
        -- TODO  已经处于对战房间
        CS.LoadingDataUI.Hide()
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.InitRoomState, GameData.RoomInfo.CurrentRoom.RoomState)
    end
end

---------------------------------------------------------------------------
-----------------通知进入下一阶段766-------------------------------------------

function NetMsgHandler.Received_S_MJ_NEXT_STATE(message)
    -- 当前房间状态
    local roomState = message:PopByte()
    print("通知房间状态进入下一阶段",roomState)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    if roomState == ROOM_STATE_MJ.START then
        -- 重回等待开始游戏状态
         ParseMJReadyStart(message)
    elseif roomState == ROOM_STATE_MJ.READY then
        -- 等待状态
        -- 清理掉当局数据
         ParseMJReadyStart(message)
         ParseMJDeletePlayer(message)
    elseif roomState == ROOM_STATE_MJ.RANDOM then
        -- 摇色子状态
        ParseMJRollTheDice(message)
    elseif roomState == ROOM_STATE_MJ.DEAL then
        -- 发牌状态
        ParseMJDeal(message)
    elseif roomState == ROOM_STATE_MJ.QUE then
        --定缺状态
         ParseMJDingQue(message)
    elseif roomState == ROOM_STATE_MJ.QUE_END then
        --定缺结束状态
        ParseMJOverDingQue(message)
    elseif roomState == ROOM_STATE_MJ.CHUPAI then
        --玩家出牌
        ParseMJPlayerPlayCard(message)
    elseif roomState == ROOM_STATE_MJ.WAIT then
        -- 等待碰杠胡阶段
        WaitPengGangHu(message)
    elseif roomState == ROOM_STATE_MJ.SETTLEMENT then
        -- 结算阶段
        PlayerSettlement(message)
    elseif roomState == ROOM_STATE_MJ.LIUJU then
        --流局阶段
        FlowBureauStage(message)
    end
    -- 设置组局厅房间状态
    GameData.RoomInfo.CurrentRoom:SetRoomState(roomState)
end

-- 重会[等待开始]状态
function  ParseMJReadyStart(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 重置有效玩家的状态
    for position = 1, MAX_MJZUJU_ROOM_PLAYER, 1 do
        if tRoomData.MJPlayerList[position].PlayerState >= PlayerStateEnumMJ.JoinOK then
            tRoomData.MJPlayerList[position].PlayerState = PlayerStateEnumMJ.LookOn
        end
    end
end

-- 解析组局厅移除玩家列表
function  ParseMJDeletePlayer(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    --tRoomData.BankerID = 0
end

--解析摇色子获取庄家位置
function ParseMJRollTheDice(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 庄家位置
    local BankerPos = message:PopByte()
    BankerPos = MJGameMgr.MJRoomPositionConvert(BankerPos)
    -- 色子1的点数
    local Dice1Number=message:PopByte()
    -- 色子2的点数
    local Dice2Number=message:PopByte()
    -- 已开始局数
    local BoardCurrentNumber = message:PopByte()
    tRoomData.BankerPosition = BankerPos
    tRoomData.BoardCurrentNumber = BoardCurrentNumber
    tRoomData.Dice1Number=Dice1Number
    tRoomData.Dice2Number=Dice2Number

end

-- 解析玩家下发牌情况
function  ParseMJDeal(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 房间玩家数量
    local count =message:PopUInt16()
    for index=1,count,1 do
        -- 玩家位置
        local position = message:PopByte()
        position=MJGameMgr.MJRoomPositionConvert(position)
        if tRoomData.MJPlayerList[position].ID == GameData.RoleInfo.AccountID then
            -- 手牌数量
            local PokerNumber=message:PopUInt16()
            tRoomData.MJPlayerList[position].PokerNumber=PokerNumber
            for cardIndex=1,PokerNumber,1 do
                -- 牌花色
                local tPokerType = message:PopByte()
                -- 牌点数
                local tPokerNumber = message:PopByte()
                table.insert( tRoomData.MJPlayerList[position].Pokers, {PokerType=tPokerType, PokerNumber=tPokerNumber} )
            end

            local OnlyCardNumber = message:PopUInt16()
            tRoomData.MJPlayerList[position].onlyPokerNumber=OnlyCardNumber
            if OnlyCardNumber>0 then
                -- 单排花色
                local tOnlyPokerType = message:PopByte()
                -- 单排点数
                local tOnlyPokerNumber = message:PopByte()
                tRoomData.MJPlayerList[position].OnlyPokers={}
                table.insert( tRoomData.MJPlayerList[position].OnlyPokers, {PokerType=tOnlyPokerType, PokerNumber=tOnlyPokerNumber} )
            end
        else
            -- 手牌数量
            local PokerNumber=message:PopUInt16()
            local OnlyCardNumber = message:PopUInt16()
            tRoomData.MJPlayerList[position].PokerNumber=PokerNumber
            tRoomData.MJPlayerList[position].onlyPokerNumber=OnlyCardNumber
        end
    end
end

-- 解析玩家定缺状态
function ParseMJDingQue(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    for index=1,4,1 do
        if tRoomData.MJPlayerList[index].PlayerState>PlayerStateEnumMJ.NULL then
            tRoomData.MJPlayerList[index].PlayerState=PlayerStateEnumMJ.QUE
        end
    end
end

-- 解析玩家定缺结束
function ParseMJOverDingQue(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    --参与玩家数量
    local count = message:PopUInt16()
    for index=1, count,1 do
        -- 玩家位置
        local position =message:PopByte()
        position=MJGameMgr.MJRoomPositionConvert(position)
        -- 缺牌类型
        local queType=message:PopByte()
        tRoomData.MJPlayerList[position].QueType=queType
        tRoomData.MJPlayerList[position].PlayerState=PlayerStateEnumMJ.QUE
    end
end

-- 解析玩家出牌
function ParseMJPlayerPlayCard(message)
    --倒计时
    local CountDown = message:PopUInt32() / 1000
    -- 出牌玩家位置
    local position =message:PopByte()
    position=MJGameMgr.MJRoomPositionConvert(position)
    GameData.RoomInfo.CurrentRoom.PlardCardPosition=position
    GameData.RoomInfo.CurrentRoom.MJCountDown = CountDown
end

-- 解析玩家等待碰杠胡
function WaitPengGangHu(message)
    --倒计时
    local CountDown = message:PopUInt32() / 1000
    -- 牌的类型
    local Cardtype=message:PopByte()
    -- 牌的点数
    local number=message:PopByte()
    -- 位置
    local position = message:PopByte()
    position=MJGameMgr.MJRoomPositionConvert(position)
    GameData.RoomInfo.CurrentRoom.WaitCardType=Cardtype
    GameData.RoomInfo.CurrentRoom.WaitCardNumber=number
    GameData.RoomInfo.CurrentRoom.WaitPGHPlayerPosition=position
    GameData.RoomInfo.CurrentRoom.MJCountDown = CountDown
end

-- 解析玩家结算
function PlayerSettlement(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    -- 有没有花猪(0没有，1有)
    local HAVEHUZHU=message:PopByte()
    if HAVEHUZHU==1 then
        local HuaZhuNumber= message:PopUInt16()
        tRoomData.HUAZHUNUMBER=HuaZhuNumber
        tRoomData.MJHuaZhuGoldList={}
        for count=1,HuaZhuNumber,1 do
            --改变金币玩家位置
            local position=message:PopByte()
            position = MJGameMgr.MJRoomPositionConvert(position)
            --改变金币数量
            local updateGold=message:PopInt64()
            -- 是否是花猪(0不是，1是)
            local IsHuaZhu = message:PopByte()
            tRoomData.MJHuaZhuGoldList[count]={}
            tRoomData.MJHuaZhuGoldList[count].position=position
            tRoomData.MJHuaZhuGoldList[count].Gold=GameConfig.GetFormatColdNumber(updateGold)
            tRoomData.MJHuaZhuGoldList[count].IsHuaZhu=IsHuaZhu
        end
    end
    -- 有没有查叫(0没有，1有)
    local HAVECHAJIAO=message:PopByte()
    if HAVECHAJIAO==1 then
        local ChaJiaoNumber= message:PopUInt16()
        tRoomData.CHAJIAONUMBER=ChaJiaoNumber
        tRoomData.MJChaJiaoGoldList={}
        for count=1,ChaJiaoNumber,1 do
            --改变金币玩家位置
            local position=message:PopByte()
            position = MJGameMgr.MJRoomPositionConvert(position)
            --改变金币数量
            local updateGold=message:PopInt64()
            -- 是否是查叫(0不是，1是)
            local IsChaJiao = message:PopByte()
            tRoomData.MJChaJiaoGoldList[count]={}
            tRoomData.MJChaJiaoGoldList[count].position=position
            tRoomData.MJChaJiaoGoldList[count].Gold=GameConfig.GetFormatColdNumber(updateGold)
            tRoomData.MJChaJiaoGoldList[count].IsChaJiao=IsChaJiao
        end
    end
    -- 有没有退税(0没有，1有)
    local HAVETUISHUI=message:PopByte()
    if HAVETUISHUI==1 then
        local TuiShuiNumber= message:PopUInt16()
        tRoomData.TUISHUINUMBER=TuiShuiNumber
        tRoomData.MJTuiShuiGoldList={}
        for count=1,TuiShuiNumber,1 do
            --改变金币玩家位置
            local position=message:PopByte()
            position = MJGameMgr.MJRoomPositionConvert(position)
            --改变金币数量
            local updateGold=message:PopInt64()
            tRoomData.MJTuiShuiGoldList[count]={}
            tRoomData.MJTuiShuiGoldList[count].position=position
            tRoomData.MJTuiShuiGoldList[count].Gold=GameConfig.GetFormatColdNumber(updateGold)
        end
    end
    --玩家数量
    local PlayerCount= message:PopUInt16()
    GameData.RoomInfo.CurrentRoom.SettlementPlayerNumber=PlayerCount
    GameData.RoomInfo.CurrentRoom.SettlementPlayer={}
    GameData.RoomInfo.CurrentRoom.ChangeGoldReason={}
    GameData.RoomInfo.CurrentRoom.HAVEHUZHU=HAVEHUZHU
    GameData.RoomInfo.CurrentRoom.HAVECHAJIAO=HAVECHAJIAO
    GameData.RoomInfo.CurrentRoom.HAVETUISHUI=HAVETUISHUI

    for index=1,PlayerCount,1 do
        -- 玩家位置
        local tPosition = message:PopByte()
        tPosition=MJGameMgr.MJRoomPositionConvert(tPosition)
        --玩家名字
        local tName = message:PopString()
        --玩家头像ID
        local tHeadIcon = message:PopByte()
        --玩家地址
        local StrLoginIP = message:PopString()
        -- 玩家总金币
        local GoldVale = message:PopInt64()
        -- 玩家金币
        local tGold = message:PopInt64()
        tRoomData.MJPlayerList[tPosition].Gold=GameConfig.GetFormatColdNumber(GoldVale)
         --记录数量
        local tCount =message:PopUInt16()
        table.insert( GameData.RoomInfo.CurrentRoom.SettlementPlayer, {position=tPosition,Name=tName,ID=tHeadIcon,StrLoginIP=StrLoginIP,Gold=tGold,Count=tCount} )
        for num=1,tCount,1 do
            -- 类型
            local Changetype=message:PopByte()
            -- 玩家位置
            local position1=message:PopByte()
            position1 = MJGameMgr.MJRoomPositionConvert(position1)
            -- 倍率
            local LV=message:PopUInt32()
            -- 变化金币
            local Gold1= message:PopInt64()
            if Changetype>=15 and Changetype<=17 then
                -- 几家
                local Players=message:PopByte()
                if GameData.RoomInfo.CurrentRoom.SettlementPlayer[index].position == 4 then
                    table.insert(GameData.RoomInfo.CurrentRoom.ChangeGoldReason,{Changetype=Changetype,position=position1,LV=LV,Gold=Gold1,PlayersNumber=Players})
                end
                
            end
            if Changetype<=14 then
                -- 胡牌类型(1自摸2非自摸)
                local HuType=message:PopByte()
                -- 几家
                local PlayersNumber=message:PopByte()
                -- 根(0没有，1，2，3，4根)
                local Gen = message:PopByte()
                -- 将对(1有0没有)
                local JiangDui = message:PopByte()
                -- 门清(1有2没有)
                local MenQing=message:PopByte()
                -- 杠上花(0不显示胡1杠1=杠上花，胡2杠1=杠上炮)
                local GangShang=message:PopByte()
                -- 海底捞(0不显示,胡2海底捞1=海底炮，胡1海底捞1=海底捞月)
                local HaidiLao=message:PopByte()
                -- 抢杠胡(0显示，1不显示)
                local QiangGangHu=message:PopByte()
                if GameData.RoomInfo.CurrentRoom.SettlementPlayer[index].position == 4 then
                    table.insert( GameData.RoomInfo.CurrentRoom.ChangeGoldReason, {Changetype=Changetype,position=position1,LV=LV,Gold=Gold1,HuType=HuType,PlayersNumber=PlayersNumber,Gen=Gen,JiangDui=JiangDui,MenQing=MenQing,GangShang=GangShang,HaidiLao=HaidiLao,QiangGangHu=QiangGangHu} )
                end
            end
            if GameData.RoomInfo.CurrentRoom.SettlementPlayer[index].position == 4 and Changetype>17 then
                table.insert(GameData.RoomInfo.CurrentRoom.ChangeGoldReason,{Changetype=Changetype,position=position1,LV=LV,Gold=Gold1})
            end
        end
        
    end
    for index=1,PlayerCount,1 do
        --位置
        local playerposition=message:PopByte()
        playerposition = MJGameMgr.MJRoomPositionConvert(playerposition)
        --牌数量
        local playerCardNumber=message:PopUInt16()
        local tRoomData = GameData.RoomInfo.CurrentRoom
        tRoomData.MJPlayerList[playerposition].PokerNumber=playerCardNumber
        tRoomData.MJPlayerList[playerposition].Pokers={}
        for count1=1,playerCardNumber,1 do
            --牌类型
            local cardType=message:PopByte()
            --牌点数
            local CardNumber=message:PopByte()
            table.insert( tRoomData.MJPlayerList[playerposition].Pokers, {PokerType=cardType, PokerNumber=CardNumber} )
        end
    end
end

-- 解析流局阶段
function FlowBureauStage(message)
    GameData.RoomInfo.CurrentRoom.FlowBureauInfo={}
end
    

---------------------------------------------------------------------------
-----------------添加一个玩家  767-------------------------------------

function  NetMsgHandler.Received_S_MJ_ADD_PLAYER(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom

    local severPosition = message:PopByte()
    local PlayerAccountID = message:PopUInt32()
    local playerName = message:PopString()
    local HeadIcon = message:PopByte()
    local GoldValue = message:PopInt64()
    local StrLoginIP = message:PopString()
    GoldValue = GameConfig.GetFormatColdNumber(GoldValue)
    local position = MJGameMgr.MJRoomPositionConvert(severPosition)

    tRoomData.MJPlayerList[position].PlayerState = PlayerStateEnumMJ.LookOn
    tRoomData.MJPlayerList[position].Position = severPosition
    tRoomData.MJPlayerList[position].ID  = PlayerAccountID
    tRoomData.MJPlayerList[position].Name = playerName
    tRoomData.MJPlayerList[position].HeadIcon = HeadIcon
    tRoomData.MJPlayerList[position].StrLoginIP = StrLoginIP
    tRoomData.MJPlayerList[position].Gold = GoldValue
    tRoomData.MJPlayerList[position].Pokers={}
    tRoomData.MJPlayerList[position].OnlyPokers={}
    tRoomData.MJPlayerList[position].PengPokers={}
    tRoomData.MJPlayerList[position].GangPokers={}
    tRoomData.MJPlayerList[position].PokerNumber=0
    tRoomData.MJPlayerList[position].onlyPokerNumber=0
    tRoomData.MJPlayerList[position].pengPokerNumber=0
    tRoomData.MJPlayerList[position].gangPokerNumber=0
    tRoomData.MJPlayerList[position].strLoginIP = message:PopString()

    local eventArg = position
    -- 通知界面显示
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJAddPlayerEvent, eventArg)
end

---------------------------------------------------------------------------
-----------------删除一个玩家  768--------------------------------

function  NetMsgHandler.Received_S_MJ_REMOVE_PLAYER(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    local position = message:PopByte()
    position = MJGameMgr.MJRoomPositionConvert(position)
    tRoomData.MJPlayerList[position].PlayerState = PlayerStateEnumMJ.NULL
    tRoomData.MJPlayerList[position].Name = ''
    tRoomData.MJPlayerList[position].HeadIcon = 0
    tRoomData.MJPlayerList[position].ID=0
    tRoomData.MJPlayerList[position].HeadIconUrl = ''
    tRoomData.MJPlayerList[position].Gold = 0
    tRoomData.MJPlayerList[position].Pokers={}
    tRoomData.MJPlayerList[position].OnlyPokers={}
    tRoomData.MJPlayerList[position].PengPokers={}
    tRoomData.MJPlayerList[position].GangPokers={}
    tRoomData.MJPlayerList[position].PokerNumber=0
    tRoomData.MJPlayerList[position].onlyPokerNumber=0
    tRoomData.MJPlayerList[position].pengPokerNumber=0
    tRoomData.MJPlayerList[position].gangPokerNumber=0
    tRoomData.MJPlayerList[position].QueType=nil
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJDeletePlayerEvent, position)
end

---------------------------------------------------------------------------
-----------------准备游戏  769--------------------------------

function NetMsgHandler.Send_CS_MJ_Prepare_Game()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_Prepare_Game, message, true)
end

function  NetMsgHandler.Received_CS_Prepare_Game(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    if resultType == 0 then
        --NetMsgHandler.ExitRoomToHall(0)
        local position=message:PopByte()
        position = MJGameMgr.MJRoomPositionConvert(position)
        tRoomData.MJPlayerList[position].PlayerState = PlayerStateEnumMJ.Ready
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJZBButtonOnClick, position,true)
    else
        local ErrorHints = data.GetString("MJ_Prepare_Game_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        --CS.BubblePrompt.Show(data.GetString("MJ_Prepare_Game_" .. resultType), "MJGameUI")
    end
end


---------------------------------------------------------------------------
----------------------玩家定缺 770--------------------------------------
function NetMsgHandler.Send_CS_MJ_DingQue(queType)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    message:PushUInt32(queType)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_DingQue, message, true)
end

function NetMsgHandler.Received_CS_DingQue(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom
        local position=message:PopByte()
        local queType=message:PopByte()
        position = MJGameMgr.MJRoomPositionConvert(position)
        tRoomData.MJPlayerList[position].PlayerState = PlayerStateEnumMJ.QUE
        tRoomData.MJPlayerList[position].QueType=queType
        if position == 4 then
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJDQButtonOnClick,position)
        end
    else
        local ErrorHints = data.GetString("MJ_DingQue_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        --CS.BubblePrompt.Show(data.GetString("MJ_DingQue_" .. resultType), "MJGameUI")
    end
end


----------------------------------------------------------------------------
-------------------玩家出牌 771 ------------------------------------------
function NetMsgHandler.Send_CS_MJ_PlayerChuPai(paiType,paiNumber,position)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 牌类型
    message:PushByte(paiType)
    -- 牌点数
    message:PushByte(paiNumber)
    -- 牌位置
    message:PushByte(position)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_PlayerChuPai, message, false)
end

function NetMsgHandler.Received_CS_MJ_PlayerChuPai(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom
        --出牌玩家位置
        local playerPosition=message:PopByte()
        playerPosition = MJGameMgr.MJRoomPositionConvert(playerPosition)
        --出牌类型
        local cardType= message:PopByte()
        --出牌点数
        local cardNumber=message:PopByte()
        -- 出牌位置
        local cardPosition=message:PopByte()
        print("服务器反馈玩家出牌信息",cardType,cardNumber,cardPosition)
        tRoomData.NowPlayerCPPosition=playerPosition
        tRoomData.NowPlayerCPType=cardType
        tRoomData.NowPlayerCPNumber=cardNumber
        tRoomData.NowPlayerCPCardPosition=cardPosition
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJPlayerChuPai)
    else
        local ErrorHints = data.GetString("MJ_PlayerChuPai_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        --CS.BubblePrompt.Show(data.GetString("MJ_PlayerChuPai_" .. resultType), "MJGameUI")
    end 
end

------------------------------------------------------------------------
-------------------玩家请求碰杠胡 772---------------------------
function NetMsgHandler.Send_CS_MJ_PengGangHu(PGHtype,GType,GNumber)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    -- 请求碰杠胡(2碰3杠4胡5过6选择杠)
    if PGHtype == 6 then
        message:PushByte(3)
        message:PushByte(GType)
        message:PushByte(GNumber)
    else
        message:PushByte(PGHtype)
    end
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_PengGangHu, message, false)
end

--反馈玩家碰杠胡
function NetMsgHandler.Received_CS_MJ_PengGangHu(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    --print("服务器反馈有玩家请求碰杠胡",resultType)
    if resultType == 0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom

        -- 操作类型
         local OperationType = message:PopByte()
         print("服务器反馈碰杠胡的操作",OperationType)
         tRoomData.playerCaoZuo=OperationType
         
         if OperationType == 2 then
            -- 操作玩家位置
            local playerPosition = message:PopByte()
            -- 被碰玩家位置
            local triggerPlayerPosition = message:PopByte()
            -- 碰牌类型
            local pengPaiType = message:PopByte()
            -- 碰牌点数
            local pengPaiNumber = message:PopByte()
            playerPosition = MJGameMgr.MJRoomPositionConvert(playerPosition)
            triggerPlayerPosition = MJGameMgr.MJRoomPositionConvert(triggerPlayerPosition)
            tRoomData.pengganghuPosition=playerPosition
            tRoomData.triggerPlayerPosition=triggerPlayerPosition
            tRoomData.pengganghuType=pengPaiType
            tRoomData.pengganghuNumber=pengPaiNumber
            print("反馈玩家碰杠胡1，操作类型",OperationType,playerPosition)
        elseif OperationType == 3 then
            -- 操作玩家位置
            local playerPosition = message:PopByte()
            -- 被杠玩家位置
            local triggerPlayerPosition = message:PopByte()
            -- 杠牌类型
            local gangPaiType = message:PopByte()
            -- 杠牌点数
            local gangPaiNumber = message:PopByte()
            --杠牌类型(1暗杠2明杠3补杠)
            local gangType=message:PopByte()
            playerPosition = MJGameMgr.MJRoomPositionConvert(playerPosition)
            triggerPlayerPosition = MJGameMgr.MJRoomPositionConvert(triggerPlayerPosition)
            tRoomData.pengganghuPosition=playerPosition
            tRoomData.triggerPlayerPosition=triggerPlayerPosition
            tRoomData.pengganghuType=gangPaiType
            tRoomData.pengganghuNumber=gangPaiNumber
            tRoomData.pengganghuMA=gangType
            print("反馈玩家碰杠胡2，操作类型",OperationType,playerPosition)
        elseif OperationType == 4 then
            -- 操作玩家位置
            local playerPosition = message:PopByte()
            -- 被胡玩家位置
            local triggerPlayerPosition = message:PopByte()
            -- 自摸类型(1自摸2非自摸)
            local ZMType = message:PopByte()
            -- 胡牌类型(1平胡2碰碰胡3清一色4暗七对5金钩钩6清一色碰碰胡7龙七对8清暗七对9清金钩钩10天湖11地胡12十八罗汉14清十八罗汉)
            local HuType=message:PopByte()
            -- 胡牌麻将类型
            local MahJongType = message:PopByte()
            -- 胡牌麻将点数
            local MahJongNumber = message:PopByte()
            playerPosition = MJGameMgr.MJRoomPositionConvert(playerPosition)
            triggerPlayerPosition = MJGameMgr.MJRoomPositionConvert(triggerPlayerPosition)
            tRoomData.pengganghuPosition=playerPosition
            tRoomData.triggerPlayerPosition=triggerPlayerPosition
            tRoomData.pengganghuZMtype=ZMType
            tRoomData.pengganghuHPtype=HuType
            tRoomData.pengganghuType=MahJongType
            tRoomData.pengganghuNumber=MahJongNumber
        elseif OperationType == 5 then
            -- 过
        elseif OperationType == 6 then
            -- 特殊
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJPlayerPengPai)
    else
        local ErrorHints = data.GetString("MJ_PlayerPengGangHu_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        --CS.BubblePrompt.Show(data.GetString("MJ_PlayerPengGangHu_" .. resultType), "MJGameUI")
    end
end


------------------------------------------------------------------------
-------------------玩家请求摸牌 773---------------------------
function NetMsgHandler.Received_CS_MJ_MoPai(message)
    -- 摸牌玩家位置
    local position = message:PopByte()
    position = MJGameMgr.MJRoomPositionConvert(position)
    --玩家摸牌数量
    local count= message:PopUInt16()
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.MJPlayerList[position].onlyPokerNumber=count
    if position == 4 then
        -- 单排花色
        local OnlyPokerType = message:PopByte()
        -- 单排点数
        local OnlyPokerNumber = message:PopByte()
        tRoomData.MJPlayerList[position].OnlyPokers={}
        table.insert( tRoomData.MJPlayerList[position].OnlyPokers, {PokerType=OnlyPokerType, PokerNumber=OnlyPokerNumber} )
    end
    -- 牌组剩余数量
    local CardsSurplusNumber = message:PopUInt16()
    tRoomData.CardsSurplusNumber = CardsSurplusNumber
    
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJPlayerMoPai,position)
end

------------------------------------------------------------------------
-------------------玩家更新金币 774---------------------------
function NetMsgHandler.Received_CS_MJ_PlayerUpdateGold(message)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    --金币改变原因(1 开局 2点杠 3暗杠 4补杠 5点炮胡 6自摸 7将对 8门清 9杠上花 10杠上炮 11海底捞 12海底炮 13抢杠胡 14一炮多响 15花猪 16查叫 17退税)
    local Reason= message:PopByte()
    -- 改变金币的玩家数量
    local playerNumber= message:PopUInt16()
    tRoomData.GoldChangetReason=Reason
    tRoomData.UPGoldPlayerNumber=playerNumber
    tRoomData.MJGoldList={}
    for count=1,playerNumber,1 do
        --改变金币玩家位置
        local position=message:PopByte()
        position = MJGameMgr.MJRoomPositionConvert(position)
        --改变金币数量
        local updateGold=message:PopInt64()
        --剩余金币数量
        local gold=message:PopInt64()
        if Reason==14 then
            local IsYPDX=message:PopByte()
            tRoomData.MJPlayerList[position].IsYPDX=IsYPDX
        end

        tRoomData.MJGoldList[count]={}
        tRoomData.MJGoldList[count].position=position
        tRoomData.MJGoldList[count].Gold=GameConfig.GetFormatColdNumber(updateGold)
        tRoomData.MJPlayerList[position].Gold=GameConfig.GetFormatColdNumber(gold)
    end
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJPlayerUpdateGold)
end

------------------------------------------------------------------------
-------------------玩家请求本局房间流水信息 775---------------------------
function NetMsgHandler.Send_CS_MJ_TheBureauGameWater()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_TheBureauGameWater, message, false)
end

--服务器反馈本局流水信息
function NetMsgHandler.Received_CS_MJ_TheBureauGameWater(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom
        --记录数量
        local count =message:PopUInt16()
        tRoomData.TheBureauGameWaterCount=count
        tRoomData.TheBureauGameWaterInfo={}
        for index=1,count,1 do
            -- 类型
            local Changetype=message:PopByte()
            -- 玩家位置
            local position=message:PopByte()
            position = MJGameMgr.MJRoomPositionConvert(position)
            -- 倍率
            local LV=message:PopUInt32()
            -- 变化金币
            local Gold= message:PopInt64()
            if Changetype>=15 and Changetype<=17 then
                -- 几家
                local Players=message:PopByte()
                table.insert(tRoomData.TheBureauGameWaterInfo,{Changetype=Changetype,position=position,LV=LV,Gold=Gold,Players=Players})
            end
            if Changetype<=14 then
                -- 胡牌类型(1自摸2非自摸)
                local HuType=message:PopByte()
                -- 几家
                local Players=message:PopByte()
                -- 根(0没有，1，2，3，4根)
                local Gen = message:PopByte()
                -- 将对(1有0没有)
                local JiangDui = message:PopByte()
                -- 门清(1有2没有)
                local MenQing=message:PopByte()
                -- 杠上花(0不显示胡1杠1=杠上花，胡2杠1=杠上炮)
                local GangShang=message:PopByte()
                -- 海底捞(0不显示,胡2海底捞1=海底炮，胡1海底捞1=海底捞月)
                local HaidiLao=message:PopByte()
                -- 抢杠胡(0显示，1不显示)
                local QiangGangHu=message:PopByte()
                table.insert(tRoomData.TheBureauGameWaterInfo,{Changetype=Changetype,position=position,LV=LV,Gold=Gold,HuType=HuType,Players=Players,Gen=Gen,JiangDui=JiangDui,MenQing=MenQing,GangShang=GangShang,HaidiLao=HaidiLao,QiangGangHu=QiangGangHu})
            end
            
            if Changetype>17 then
                table.insert(tRoomData.TheBureauGameWaterInfo,{Changetype=Changetype,position=position,LV=LV,Gold=Gold})
            end
            
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJTheBureauGameWater,true)
    else
        local ErrorHints = data.GetString("MJ_BureauGameWater_Erro_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        --CS.BubblePrompt.Show(data.GetString("MJ_BureauGameWater_Erro_" .. resultType), "MJGameUI")
    end
end

------------------------------------------------------------------------
-------------------玩家请求房间总流水信息 776---------------------------
function NetMsgHandler.Send_CS_MJ_GameWater()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_GameWater, message, false)
end

--服务器反馈房间总流水信息
function NetMsgHandler.Received_CS_MJ_GameWater(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom
        --局数数量
        local count =message:PopUInt16()
        tRoomData.GameWaterNumber=count
        for index=1,#tRoomData.GameWaterInfo do
            tRoomData.GameWaterInfo[index].GameWaterLiet={}
        end
        tRoomData.GameWaterLiet={}
        for index=1,count,1 do
            --局数
            local GameNumber = message:PopByte()
            -- 玩家数量
            local playerCount=message:PopUInt16()
            table.insert( tRoomData.GameWaterInfo,{GameNumber=GameNumber,playerCount=playerCount} )
            tRoomData.GameWaterInfo[index].GameWaterLiet={}
            for index1=1,playerCount,1 do
                --玩家姓名
                local playerName=message:PopString()
                -- 玩家头像ID
                local HeadIcon=message:PopByte()
                -- 玩家地址
                local StrLoginIP=message:PopString()
                -- 玩家金币总变化
                local playerGoldChang = message:PopInt64()
                table.insert( tRoomData.GameWaterInfo[index].GameWaterLiet,{Name=playerName,Icon=HeadIcon,StrLoginIP=StrLoginIP,Gold=playerGoldChang})
            end
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJGameWater,2)
    else
        local ErrorHints = data.GetString("MJ_GameWater_Erro_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        --CS.BubblePrompt.Show(data.GetString("MJ_GameWater_Erro_" .. resultType), "MJGameUI")
    end
end

------------------------------------------------------------------------
-------------------玩家请求房间排行 777---------------------------
function NetMsgHandler.Send_CS_MJ_GameRank()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_MJ_GameRank, message, false)
end

local function _CompMJRoomRank( tA, tB)
    return tA.Gold==tB.Gold and (tA.VictoryNumber>tB.VictoryNumber) or (tA.Gold>tB.Gold)
end
--服务器反馈房间排行
function NetMsgHandler.Received_CS_MJ_GameRank(message)
    CS.LoadingDataUI.Hide()
    local resultType = message:PopByte()
    if resultType == 0 then
        local tRoomData = GameData.RoomInfo.CurrentRoom
        -- 玩家数量
        local playerCount= message:PopUInt16()
        tRoomData.GameRankNumber=playerCount
        tRoomData.GameRankInfo={}
        for index = 1,playerCount,1 do
            -- 玩家姓名
            local playerName=message:PopString()
            -- 头像ID
            local HeadIcon=message:PopByte()
            -- 玩家地址
            local StrLoginIP= message:PopString()
            -- 改变金币
            local playerGoldChang = message:PopInt64()
            -- 参与局数
            local GameNumber = message:PopByte()
            -- 胜利局数
            local VictoryGameNumber = message:PopByte()
            table.insert( tRoomData.GameRankInfo,{Name=playerName,Icon=HeadIcon,StrLoginIP=StrLoginIP,Gold=playerGoldChang,GameNumber=GameNumber,VictoryNumber=VictoryGameNumber} )
        end
        if playerCount>0 then
            table.sort( tRoomData.GameRankInfo, _CompMJRoomRank )
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJPlayerRank,1)
    else
        local ErrorHints = data.GetString("MJ_GameRank_Erro_" .. resultType)
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJErrorHints, ErrorHints)
        --CS.BubblePrompt.Show(data.GetString("MJ_GameRank_Erro_" .. resultType), "MJGameUI")
    end
end

------------------------------------------------------------------------
------------------------------玩家认输 778---------------------------
function NetMsgHandler.Received_S_MJ_PLAYERTRANSPORT(message)
    --玩家位置
    local position = message:PopByte()
    position = MJGameMgr.MJRoomPositionConvert(position)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.MJPlayerList[position].PlayerState=PlayerStateEnumMJ.Fail
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJPlayerAdmitDefeat,true)
end

-------------------------------------------------------------------
----------------------有玩家被抢杠胡 779 -------------------------

function NetMsgHandler.ReceivedS_MJ_QIANGGANGHU(message)
    -- 补杠玩家位置
    local BGposition = message:PopByte()
    BGposition = MJGameMgr.MJRoomPositionConvert(BGposition)
    -- 补杠玩家花色
    local BGtype = message:PopByte()
    -- 补杠玩家点数
    local BGnumber = message:PopByte()

    local tRoomData = GameData.RoomInfo.CurrentRoom
    tRoomData.BQGHplayerPosition=BGposition
    tRoomData.BQGHtype=BGtype
    tRoomData.BQGHnumber=BGnumber
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMJPlayerBQGH)
end