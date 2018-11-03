--[[
   文件名称:MJRoom.lua
   创 建 人:
   创建时间：2017.12
   功能描述：
]]--

-- 【麻将组局】玩家信息
if MJPlayer == nil  then
    MJPlayer = {}
end

function MJPlayer:New(  )
    local tObj = 
    {
        -- 玩家ID
        ID = 0,
        -- 玩家位置
        Position = 1,
        -- 玩家名称
        Name = '',
        -- 玩家头像ID
        HeadIcon = 0,
        -- 玩家微信头像Url
        HeadIconUrl = '',
        -- 玩家金币值
        Gold = 0,

        -- 玩家状态 (0 空位 1 旁观者 2 已经准备 3参与游戏 4 抢庄 5 不抢庄 6 加倍 7 不加倍 8 看牌)
        PlayerState = PlayerStateEnumMJ.NULL,
        -- 玩家可以下注倍率
        nCanCompensate = 0,
        -- 玩家下注倍率
        nBetCompensate = 0,

        -- 玩家的扑克信息 格式为: [1] = {PokerType = 1, PokerNumber = 13, Visible = false,}
        Pokers = 
        {
            [1] = {PokerType = 1, PokerNumber = 1, Visible = false,},
            [2] = {PokerType = 1, PokerNumber = 2, Visible = false,},
        },
        -- 玩家赢取金币数量
        WinGold = 0,
        -- 是否搓牌 0未搓 1已经搓牌
        IsCuoPai = 0,
    }
    Extends(tObj, self)
    return tObj
end 


if MJRoom == nil then
    MJRoom = {}
end

function MJRoom:New()
    local  tNode = 
    {
        -- 房间ID
        RoomID = 10,
        -- 房间类型
        RoomType = ROOM_TYPE.ZuJuMaJiang,
        -- 房主ID
        MasterID = 0,
        -- 房间人数
        RoleCount = 0,
        -- 最大人数
        MaxRoleCount = 4,
        -- 房间当前阶段
        RoomState = ROOM_STATE_MJ.START,
        -- 倒计时
        CountDown = 20,
        -- 庄家ID(0无庄家)
        BankerID = 1,
        -- 玩家自己所在位置
        SelfPosition = 1,
        -- 组局厅玩家列表 [1] = MJPlayer,[2] = MJPlayer
        MJPlayerList ={},
        -- 金币改变原因
        MJGoldList={},
        -- 本局流水信息
        TheBureauGameWaterInfo={},
        -- 房间总流水信息
        GameWaterInfo={},
        -- 房间总流水信息每条原因
        GameWaterLiet={},
        -- 房间排行信息
        GameRankInfo={},
        -- 房间名称
        RoomName = '帝豪俱乐部',
        -- 底注
        MinBet = 10,
        -- 是否加锁 0不加 1加锁
        IsLock = 0,
        -- 牌局次数
        BoardNumber = 0,
    }
    Extends(tNode, self)
    return tNode
end

function MJRoom:Init( isInitAll, roomTypeParam)
    if isInitAll == true  then
        self.MJPlayerList = {}
        for i=1,MAX_MJZUJU_ROOM_PLAYER do
            local tNode = MJPlayer:New()
            self.MJPlayerList[i] = tNode
        end
        self:SetRoomState(ROOM_STATE_MJ.START)
    end
    self.RoomType = roomTypeParam
end

function MJRoom:SetRoomState(nState, nNextTime)
    local nRoomType = self.RoomType
    local nStateTime = 0
    if nNextTime == nil then
        nStateTime = data.Get_ROOM_STATE_TIME(ROOM_TYPE.ZuJuMaJiang, nState)
    end
    local nTime = nNextTime or nStateTime
    self.RoomState = nState
    self.CountDown = nTime
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoomState, nState)
    return nTime
end

--==============================--
--desc:获取房间当前人数
--time:2018-01-25 02:22:03
--@return 
--==============================--
function MJRoom:PlayerCount()
    local tCount = 0
    for i = 1,MAX_MJZUJU_ROOM_PLAYER, 1 do
        if self.MJPlayerList[i].PlayerState > PlayerStateEnumMJ.NULL then
            tCount = tCount + 1
        end
    end
    return tCount
end

--==============================--
--desc:获取房间玩家位置(通过账号ID)
--time:2018-01-25 02:22:03
--@accountid: 玩家账号ID  
--@return 
--==============================--
function MJRoom:GetPlayerPosition(accountid)
    local position = 4
    for i = 1,MAX_MJZUJU_ROOM_PLAYER, 1 do
        if self.MJPlayerList[i].ID == accountid then
            position = i
            break
        end
    end
    return position
end
