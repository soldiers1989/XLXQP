--[[
   文件名称:TTZRoom.lua
   创 建 人:
   创建时间：2017.12
   功能描述：
]]--

-- 【推筒子组局】玩家信息
if TTZPlayer == nil  then
    TTZPlayer = {}
end

function TTZPlayer:New(  )
    local tObj = 
    {
        -- 玩家ID
        ID = 0,
        -- 玩家位置
        Position = 1,
        -- 玩家名称
        Name = '张三',
        -- 玩家头像ID
        HeadIcon = 0,
        -- 玩家微信头像Url
        HeadIconUrl = '',
        -- 玩家金币值
        Gold = 0,

        -- 玩家状态 (0 空位 1 旁观者 2 已经准备 3参与游戏 4 抢庄 5 不抢庄 6 加倍 7 不加倍 8 看牌)
        PlayerState = PlayerStateEnumTTZ.NULL,
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


if TTZRoom == nil then
    TTZRoom = {}
end

function TTZRoom:New()
    local  tNode = 
    {
        -- 房间ID
        RoomID = 10,
        -- 房间类型
        RoomType = ROOM_TYPE.ZuJuTTZ,
        -- 房主ID
        MasterID = 0,
        -- 房间人数
        RoleCount = 0,
        -- 最大人数
        MaxRoleCount = 5,
        -- 房间当前阶段
        RoomState = ROOM_STATE_TTZ.START,
        -- 倒计时
        CountDown = 20,
        -- 庄家ID(0无庄家)
        BankerID = 1,
        -- 玩家自己所在位置
        SelfPosition = 1,
        -- 组局厅玩家列表 [1] = TTZPlayer,[2] = TTZPlayer
        TTZPlayerList = {},
        -- 赔付模式(1浮动 2固定)
        CompensateType = 1,
        -- 是否明牌 1明 2暗
        LightPoker = 2,

        -- 房间名称
        RoomName = '帝豪俱乐部',
        -- 底注
        MinBet = 10,
        -- 是否加锁 0不加 1加锁
        IsLock = 0,
        -- 庄家赔付比率
        nBankerCompensate = 0,
        -- 牌局次数
        BoardNumber = 0,
    }
    Extends(tNode, self)
    return tNode
end

function TTZRoom:Init( isInitAll, roomTypeParam)
    if isInitAll == true  then
        self.TTZPlayerList = {}
        for i=1,MAX_TTZZUJU_ROOM_PLAYER do
            local tNode = TTZPlayer:New()
            self.TTZPlayerList[i] = tNode
        end
        self:SetRoomState(ROOM_STATE_TTZ.START)
    end
    self.RoomType = roomTypeParam
end

function TTZRoom:SetRoomState(nState, nNextTime)
    local nRoomType = self.RoomType
    local nStateTime = 0
    if nNextTime == nil then
        nStateTime = data.Get_ROOM_STATE_TIME(ROOM_TYPE.ZuJuTTZ, nState)
    end
    local nTime = nNextTime or nStateTime
    self.RoomState = nState
    self.CountDown = nTime
    if nState ~= 0 then
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoomState, nState)
    end
    return nTime
end

--==============================--
--desc:获取房间当前人数
--time:2018-01-25 02:22:03
--@return 
--==============================--
function TTZRoom:PlayerCount()
    local tCount = 0
    for i = 1,MAX_NNZUJU_ROOM_PLAYER, 1 do
        if self.TTZPlayerList[i].PlayerState > PlayerStateEnumNN.NULL then
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
function TTZRoom:GetPlayerPosition(accountid)
    local position = 6
    for i = 1,MAX_NNZUJU_ROOM_PLAYER, 1 do
        if self.TTZPlayerList[i].ID == accountid then
            position = i
            break
        end
    end
    return position
end