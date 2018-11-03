--[[
   文件名称:JHZuJuRoom.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

-- 【牛牛组局厅】玩家信息
if JHPlayer == nil  then
    JHPlayer = {}
end

function JHPlayer:New(  )
    local tObj = 
    {
        -- 玩家ID
        AccountID = 0,
        -- 名称
        Name = '同花顺',
        -- 头像ID
        HeadIcon = 0,
        -- 玩家头像url
        HeadUrl = '',
        -- 当前拥有金币数量
        GoldValue = 0,
        -- 本局下注金额
        BetChipValue = 0,
        -- 玩家位置
        Position = 0,
        -- 玩家经度
        fLongitude = 0,
        -- 玩家维度
        fLatitude = 0,

        -- 玩家参与游戏状态(0 空位 1 旁观 2参与)
        PlayerState = 0,
        -- 玩家准备状态(0准备状态默认值 1 准备 2未准备)
        ReadyState = 0,
        -- 看牌标记(0未看牌 1看牌)
        LookState = 0,
        -- 弃牌状态(0 未弃牌 1弃牌)
        DropCardState = 0,
        -- 比牌状态(0 默认状态 1比牌输 2 比牌赢)
        CompareState = 0,
        -- 免费PK状态 0 不允许 1 允许
        FreePK = 1,
        -- 扑克列表
        PokerList = 
        { 
            [1] = {PokerType = 1, PokerNumber = 1, Visible = false,},
            [2] = {PokerType = 1, PokerNumber = 2, Visible = false,},
            [3] = {PokerType = 1, PokerNumber = 3, Visible = false,},
        },
        -- 是否是本局赢家
        IsWinner = false,
        -- 赢取的金币值
        WinGoldValue = 0,
        -- 是否亮牌(结算时刻)
        IsShowPokerCard = false,
    }
    Extends(tObj, self)
    return tObj
end 


if JHZuJuRoom == nil then
    JHZuJuRoom = {}
end

function JHZuJuRoom:New()
    local  tNode = 
    {
        -- 房间ID
        RoomID = 0,
        -- 房间主类型
        RoomType = ROOM_TYPE.MenJi,

        -- 房主ID
        MasterID = 1,
        -- 房间子类型
        SubType = 0,
        -- 房间模式(0经典 1激情)
        GameMode = GameModeEnum.Common,
        -- 比闷模式(必闷1圈 必闷3圈)
        MenJiRound = 1,
        -- 是否允许陌生人加入(0 开放 1关闭)
        IsLock = 0,

        -- 房间底注
        BetMin = 10,
        -- 下注上限
        BetMax = 400,
        -- 房间状态
        RoomState = ROOM_STATE_JHWR.Wait,
        -- 当前状态CD
        CountDown = 0,
        -- 玩家自己位置
        SelfPosition = 0,
        -- 庄家位置
        BankerPosition = 1,
        -- 当前下注总额
        BetAllValue = 0,
        -- 当前对战回合
        RoundTimes = 0,
        -- 当前局数
        CurrentRound = 0,
        -- 当前下注位置
        BettingPosition = 0,
        -- 当前名牌下注
        MingCardBetMin = 0,
        -- 当前暗牌下注最小值
        DarkCardBetMin = 0,

        -- 房间对应位置玩家详细数据
        JHPlayers = { },
        -- 当前房间所有下注情况
        AllBetInfo = { },
        -- =========挑战数据========
        -- 挑战者: 位置
        ChallengerPosition = 0,
        -- 应邀参与者位置
        ActorPosition = 0,
        -- 挑战赢家位置
        PKVSWinnerPosition = 0,
        -- 比牌失败者位置
        PKVSLoserPosition = 0,

        -- 结算时赢家数量
        WinnerCount = 0,

        -- 名牌下注档次
        MingCardBettingValue =
        {
            [1] = 2,
            [2] = 5,
            [3] = 10,
            [4] = 20,
            [5] = 40,
        },

        -- 暗牌下注档次
        DarkCardBettingValue =
        {
            [1] = 1,
            [2] = 2,
            [3] = 5,
            [4] = 10,
            [5] = 20,
        }
    }
    Extends(tNode, self)
    return tNode
end

function JHZuJuRoom:Init( isInitAll, roomTypeParam)
    if isInitAll == true  then
        self.NNPlayerList = {}
        for i=1,JHZUJU_ROOM_PLAYER_MAX do
            local tNode = JHPlayer:New()
            self.JHPlayers[i] = tNode
        end
        self:SetRoomState(ROOM_STATE_JHWR.Wait)
    end
    self.RoomType = roomTypeParam
end

function JHZuJuRoom:SetRoomState(nState, nNextTime)
    local nStateTime = 0
    if nNextTime == nil then
        nStateTime = ROOM_TIME_JHWR[nState]
    end
    local nTime = nNextTime or nStateTime
    self.RoomState = nState
    self.CountDown = nTime
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateRoomState, nState)
    return nTime
end

--==============================--
--desc:金花组局房间初始化下注额度
--time:2018-01-23 08:22:40
--@return 
--==============================--
function JHZuJuRoom:InitBettingValue()
    for index = 1, 5, 1 do
        self.MingCardBettingValue[index] = self.BetMin * JHMingPaiRate[index]
        self.DarkCardBettingValue[index] = self.BetMin * JHDarkPaiRate[index]
    end
end

--==============================--
--desc:还原房间数据到准备阶段
--time:2018-01-23 08:28:58
--@return 
--==============================--
function JHZuJuRoom:ResetRoomDataToWaitState()
    
    self.BetAllValue = 0
    self.RoundTimes = 0
    self.BettingPosition = 0
    self.MingCardBetMin = self.BetMin
    self.DarkCardBetMin = self.BetMin
    self.AllBetInfo = { }
    self.ChallengerPosition = 0
    self.ActorPosition = 0
    self.PKVSWinnerPosition = 0
    self.PKVSLoserPosition = 0
    self.WinnerCount = 0
    -- 玩家数据重置
    local tPlayerNodes = self.JHPlayers
    for position = 1, JHZUJU_ROOM_PLAYER_MAX, 1 do
        tPlayerNodes[position].BetChipValue = 0
        tPlayerNodes[position].Position = 0
        tPlayerNodes[position].ReadyState = 0
        -- 看牌状态(0:焖牌  1:看牌)
        tPlayerNodes[position].LookState = 0
        -- 弃牌状态(0 未弃牌 1弃牌)
        tPlayerNodes[position].DropCardState = 0
        -- 比牌状态(0 未比牌 1比牌输 2比牌赢)
        tPlayerNodes[position].CompareState = 0
        tPlayerNodes[position].FreePK = 1
        tPlayerNodes[position].IsWinner = false
        tPlayerNodes[position].WinGoldValue = 0
        tPlayerNodes[position].IsShowPokerCard = false
        -- 扑克牌还原默认值
        for cardIndex = 1, 3, 1 do
            tPlayerNodes[position].PokerList[cardIndex].PokerType = cardIndex
            tPlayerNodes[position].PokerList[cardIndex].PokerNumber = 14
            tPlayerNodes[position].PokerList[cardIndex].Visible = false
        end
        -- 非空位玩家状态还原
        if tPlayerNodes[position].PlayerState == PlayerStateEnum.JoinOK then
            tPlayerNodes[position].PlayerState = PlayerStateEnum.JoinNO
        end
    end
end

--==============================--
--desc:获取筹码类型
--time:2018-01-23 08:53:46
--@betValue:
--@return 
--==============================--
function JHZuJuRoom:GetBetType(betValue)
    local level = 1
    local compareValue1 = 1
    for index = 1, 5, 1 do
        compareValue1 = self.MingCardBettingValue[index]
        compareValue1 = GameConfig.GetFormatColdNumber(compareValue1)
        if betValue <= compareValue1 then
            level = index
            break
        end
    end
    return level
end

--==============================--
--desc:获取下注金额(通过下注等级)
--time:2018-01-24 10:02:48
--@betLevel:下注等级
--@return 1明牌下注 2暗牌下注
--==============================--
function JHZuJuRoom:GetBettingValueByLevel(betLevel)
    return  self.MingCardBettingValue[betLevel], self.DarkCardBettingValue[betLevel]
end

--==============================--
--desc:更新房间下注总额
--time:2018-01-24 10:10:54
--@betValue:当前下注
--@return 本局下注总额
--==============================--
function JHZuJuRoom:UpdateBetAllValue( betValue )
    self.BetAllValue = self.BetAllValue + betValue
end

--==============================--
--desc:获取房间玩家位置(通过账号ID)
--time:2018-01-25 02:22:03
--@accountid: 玩家账号ID  
--@return 
--==============================--
function JHZuJuRoom:GetPlayerPosition(accountid)
    local position = 6
    for i = 1,JHZUJU_ROOM_PLAYER_MAX, 1 do
        if self.JHPlayers[i].AccountID == accountid then
            position = i
            break
        end
    end
    return position
end

