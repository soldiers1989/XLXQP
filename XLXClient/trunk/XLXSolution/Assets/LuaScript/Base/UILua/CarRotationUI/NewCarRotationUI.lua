local Time = CS.UnityEngine.Time

local HelpWindowObject = nil                -- 帮助界面
local HelpMaskObject = nil                  -- 帮助界面Mask
local BankersListObject = nil               -- 庄家列表界面
local BankersListInfoItem = nil             -- 庄家队列模板
local RewardObject = nil                    -- 中奖界面
local RewardLiZi = nil                      -- 中奖粒子特效
local AnimationObjectLeft = nil             -- 开始下注左侧
local AnimationObjectRight = nil            -- 开始下注右侧
local AnimationPosition1 = nil              -- 开始下注位置1
local AnimationPosition2 = nil              -- 开始下注位置2
local LotteryDrawLight = nil                -- 抽奖光圈1
local LotteryDrawLight2 = nil               -- 抽奖光圈2
local LotteryDrawLight3 = nil               -- 抽奖光圈3
local LastLightObject = nil                 -- 上次中奖位置光圈
local FlashOfLightObject = nil              -- 中奖位置闪光
local SettlementMask = nil                  -- 结算Mask
local SettlementCanvas = nil                -- 结算Canvas
local SettlementImage = nil                 -- 结算中奖Image

local GolcValueText = nil                   -- 玩家本身拥有金币Text
local DZValueText = nil                     -- 上庄限额Text
local OnlineNumber = nil                    -- 在线人数Text
local CountDownText = nil                   -- 倒计时Text
local LamborghiniText = nil                 -- 兰博基尼上次出现时间
local FerrariText = nil                     -- 玛莎拉蒂上次出现时间
local WinningText = nil                     -- 中奖金额Text
local BankersGameCountText = nil            -- 庄家剩余局数

local UpBankersImage = nil                  -- 上庄按钮
local DownBankersImage = nil                -- 下庄按钮

local AnimationTweenPositionLeft = nil      -- 开始下注左侧TweenPosition
local AnimationTweenPositionRight = nil     -- 开始下注右侧TweenPosition
local HandTweenRotation1 = nil              -- 开始下注手TweenRotation
local HandTweenRotation2 = nil              -- 开始下注手TweenRotation
local FlashOfLightTweenAlpha = nil          -- 中奖位置闪光TweenAlpha
local SettlementTweenPosition = nil         -- 结算图片TweenPosition
local SettlementTweenScale = nil            -- 结算图片TweenScale

local ChipsSelectObject = {}                -- 筹码被选中光圈Object
local HistoricalRecordsObjecty = {}         -- 历史纪录Object
local LightDengPaoObject = {}               -- 灯泡光Object
local WaitLightObject = {}                  -- 待机状态图片
local ChouJiangDengPaoLightObject = {}      -- 抽奖状态灯泡Object
local ChouJiangDengPaoLightImage = {}       -- 抽奖状态灯泡Image
local SettlementLiZi = {}                   -- 结算粒子特效
local BankersInfoParent = {}                -- 庄家列表父节点

local ChipsValueText = {}                   -- 筹码值Text
local AllBetValueText = {}                  -- 每种类型总下注Text
local BetValueText = {}                     -- 玩家自己本身下注Text

local NewImage = {}                         -- 历史纪录区域New图片
local HistoricalRecordsImage = {}           -- 历史纪录Image
local BetButtonImage = {}                   -- 下注按钮图片
local BetButtonTableImage = {}              -- 筹码按钮图片

local BankersListPosition = {}              -- 庄家队列位置
local LastDengPaoIndex = {}                 -- 上一次灯泡位置

local ChipsButtonTable = {}                 -- 筹码按钮Button
local BetButtonTable = {}                   -- 下注按钮Button
local CloseButton = nil                     -- 退出按钮

local DengPaoSpriteAnimation = {}           -- 灯泡UGUI Sprite Animation

-- 庄家信息
local BankersInfo = 
{
    Object = nil,
    HeadIcon = nil,
    Vip = nil,
    GoldValue = nil,
    Name = nil,
}

-- 上轮大赢家信息
local LastWinnerInfo = 
{
    Object = nil,
    HeadIcon = nil,
    Vip = nil,
    GoldValue = nil,
    Name = nil,
}

-- 321倒计时组件
local CountDown = 
{
    Mask = nil,
    Object = {},
    TweenScale = {},
    TweenAlpha = {},
    Animation = {},
}
-- 抽奖光圈位置
local CircleLightPosition = 
{
    X = {},
    Y = {},
}

-- 待机状态图片位置
local WaitImageIndex = 
{
    [1] = 4,
    [2] = 5,
    [3] = 20,
    [4] = 21,
    [5] = 15,
    [6] = 16,
    [7] = 9,
    [8] = 10,
}

local SelectBetGoldValue = 0                -- 选中下注金额
local RunAllCount = 0                       -- 抽奖状态需跑格子数量
local RunCount = 0                          -- 抽奖已跑过的格子数量
local LastWinIndex = 1                      -- 上次中奖位置
local RunTime1 = 0.55                       -- 抽奖前4格速度
local RunTime2 = 0.045                      -- 抽奖中间速度
local RunTime3 = 0.05                       -- 抽奖最后4格速度
local time_Lottery = 0                      -- 抽奖状态当前格子已过时间
local waitTime = 0.8                          -- 待机状态动画时间间隔

local StopBet = false                       -- 停止下注是否播放
local StartBet = false                      -- 开始下注是否播放
local ChouJiangAnimation = false            -- 是否开始播放抽奖动画
local IsStartChouJiang = false              -- 是否是刚好抽奖
local IsWaitAnimation = false               -- 是否开始待机动画
local iswinning = false                     -- 玩家是否获胜
local isBankersWinning = false              -- 庄家是否获胜

-- 打开商城界面
function OpenStoreInterface()
    GameConfig.OpenStoreUI()
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.BcbmRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.BcbmRankTime >= 60 then
        return true
    end
    return false
end

-- 打开排行榜
function OpenRankInterface()
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = GAME_RANK_TYPE.BCBM_MONEY
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(GAME_RANK_TYPE.BCBM_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.BCBM_MONEY)
    end
end

-- 打开帮助界面
function OpenHelpInterface(mShow)
    -- body
    GameObjectSetActive(HelpWindowObject,mShow)
    GameObjectSetActive(HelpMaskObject,mShow)
end

-- 点击庄家列表按钮
function BankersListButtonOnClick()
    -- body
    NetMsgHandler.Send_CS_BankerListInfo(GameData.CarInfo.Level)
end

-- 打开庄家列表界面
function OpenBankersInfoInterface()
    -- body
    GameObjectSetActive(BankersListObject,true)
    for index = 1, 5 do
        if BankersInfoParent[index].transform:Find('ChipsItem(Clone)')~=nil then
            local destoryCopy=BankersInfoParent[index].transform:Find('ChipsItem(Clone)').gameObject
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
    end
    BankersGameCountText.text = tostring(GameData.CarInfo.BankerRemainder)
    local num = GameData.CarInfo.BankerNumber
    for index=1,num do
        local chips = BankersInfoParent[index]
        local tCopyNode=CS.UnityEngine.Object.Instantiate(BankersListInfoItem)
        CS.Utility.ReSetTransform(tCopyNode.transform,chips.transform)
        tCopyNode:SetActive(true)
        local gold=lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.CarInfo.BankersGold[index]))
        local listName=GameData.CarInfo.BankersStrLoginIP[index]
        local listVIP="VIP"..GameData.CarInfo.BankerListVIP[index]
        tCopyNode.transform:Find('Gold'):GetComponent('Text').text = ""..gold
        tCopyNode.transform:Find('Name'):GetComponent('Text').text = ""..listName
        tCopyNode.transform:Find('VIP/Text'):GetComponent('Text').text = ""..listVIP
    end
end

-- 关闭庄家列表信息
function CloseBankersInfoInterface()
    GameObjectSetActive(BankersListObject,false)
end

-- 打开在线人数界面
function OpenOnlineNumberInterface()
    -- body
    local initParam = CS.WindowManager.Instance:FindWindowNodeByName("UIRoomPlayers")
    if initParam == nil then
        local initParam = CS.WindowNodeInitParam("UIRoomPlayers")
        initParam.WindowData = 4
        CS.WindowManager.Instance:OpenWindow(initParam)
    end
end

-- 显示庄家信息
function DisplayBankersInfo()
    -- body
    BankersInfo.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.CarInfo.BankerID))
    BankersInfo.Name.text = GameData.CarInfo.BankerStrLoginIP
    BankersInfo.Vip.text = "VIP"..GameData.CarInfo.BankerVipLevel
    BankersInfo.GoldValue.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.CarInfo.BankerGold),2))
    if GameData.CarInfo.isBanker == 0  then
        GameObjectSetActive(UpBankersImage,true)
        GameObjectSetActive(DownBankersImage,false)
    else
        GameObjectSetActive(UpBankersImage,false)
        GameObjectSetActive(DownBankersImage,true)
    end
end

-- 显示上轮大赢家信息
function DisplayLastWinnerInfo()
    -- body
    LastWinnerInfo.HeadIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.CarInfo.WinnerID))
    LastWinnerInfo.Name.text = GameData.CarInfo.WinnerStrLoginIP
    LastWinnerInfo.Vip.text = "VIP"..GameData.CarInfo.WinnerVipLevel
    LastWinnerInfo.GoldValue.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.CarInfo.WinnerGold),2))
end

-- 显示历史纪录区域
function DisplayHistoricalRecordsInfo()
    local Num = GameData.CarInfo.LastBetNum
    if GameData.CarInfo.LastBetNum > 24 then
        Num = 24
    end
    for i=Num, 1, -1 do
        GameObjectSetActive(HistoricalRecordsObjecty[i],true)
        if i == Num then
            GameObjectSetActive(NewImage[i],true)
        else
            GameObjectSetActive(NewImage[i],false)
        end
        local SpriteName = "sprite_bc_ic_"..GameData.CarInfo.LastBetResult[Num+i-Num]
        HistoricalRecordsImage[i]:ResetSpriteByName(SpriteName)
    end
    if Num < 24 then
        if HistoricalRecordsObjecty[Num+1].activeSelf == false then
            return 
        end
        for i = Num + 1, 24 do
            GameObjectSetActive(HistoricalRecordsObjecty[i],false)
            GameObjectSetActive(NewImage[i],false)
        end
    end
end

-- 更新下注信息
function UpdateBetInfo(BetType)
    -- body
    if GameData.CarInfo.myBet[BetType]~=nil then
        BetValueText[BetType].text = tostring(math.floor(GameConfig.GetFormatColdNumber(GameData.CarInfo.myBet[BetType])) )
        UpdatePlayerGold()
    else
        BetValueText[BetType].text = "0"
    end

    if GameData.CarInfo.IsBet == true then
        CloseButton.interactable = false
    end

    if GameData.CarInfo.AllBet[BetType]~=nil then
        AllBetValueText[BetType].text = tostring(math.floor(GameConfig.GetFormatColdNumber(GameData.CarInfo.AllBet[BetType])))
    else
        AllBetValueText[BetType].text = "0"
    end
end

-- 重置下注信息
function RestBetInfo()
    -- body
    for i = 1, 8 do
        BetValueText[i].text = "0"
        AllBetValueText[i].text = "0"
        GameData.CarInfo.AllBet[i] = 0
        GameData.CarInfo.myBet[i] = 0
    end
end

-- 更新玩家金币数量
function UpdatePlayerGold()
    GolcValueText.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2))
end

-- 更新在线人数
function UpdateOnlineNumber()
    -- body
    OnlineNumber.text = tostring(GameData.CarInfo.PlayerCount)
end

local mLastFerrariCDSecond = 0
local mLastFerrariCDSecond2 = -1
local mLastLamborghiniSecond = 0
local mLastLamborghiniSecond2 = -1

-- 显示兰博基尼和法拉利上次出现时间
function DisplayLBandFLLLastTime(deltaTime)
    if deltaTime ~= nil then
        GameData.CarInfo.LastFerrariTime = GameData.CarInfo.LastFerrariTime + deltaTime
        GameData.CarInfo.LastLamborghiniTime = GameData.CarInfo.LastLamborghiniTime + deltaTime 
    end

    local FerrariAppearTime = GameData.CarInfo.LastFerrariTime
    local LamborghiniAppearTime = GameData.CarInfo.LastLamborghiniTime

    if FerrariAppearTime > 359999 then
        FerrariAppearTime = 359999
    end
    if LamborghiniAppearTime > 359999 then
        LamborghiniAppearTime = 359999
    end
    mLastFerrariCDSecond = math.floor(FerrariAppearTime)
    mLastLamborghiniSecond = math.floor( LamborghiniAppearTime )
    local second1 = math.floor((mLastFerrariCDSecond % 3600) % 60)
    local Minute1 = math.floor((mLastFerrariCDSecond % 3600) / 60)
    local Hour1 = math.floor(mLastFerrariCDSecond / 3600)
    if Minute1 < 10 then
        Minute1="0"..Minute1
    else
        Minute1=""..Minute1
    end

    if Hour1 < 10 then
        Hour1="0"..Hour1
    else
        Hour1=""..Hour1
    end

    if second1 < 10 then
        second1 = "0"..second1
    else
        second1 = ""..second1
    end
    if mLastFerrariCDSecond2 ~= mLastFerrariCDSecond then
        mLastFerrariCDSecond2 = mLastFerrariCDSecond
        FerrariText.text = Hour1..":"..Minute1..":"..second1
    end
    local second = math.floor((mLastLamborghiniSecond % 3600) % 60)
    local Minute = math.floor((mLastLamborghiniSecond % 3600) / 60)
    local Hour = math.floor(mLastLamborghiniSecond / 3600)

    if Minute < 10 then
        Minute = "0"..Minute
    else
        Minute = ""..Minute
    end

    if Hour < 10 then
        Hour = "0"..Hour
    else
        Hour=""..Hour
    end

    if second < 10 then
        second = "0"..second
    else
        second = ""..second
    end

    if mLastLamborghiniSecond2 ~= mLastLamborghiniSecond then
        mLastLamborghiniSecond2 = mLastLamborghiniSecond
        LamborghiniText.text = Hour..":"..Minute..":"..second
    end
end

-- 显示倒计时
function DisplayCountDown(deltaTime)
    if GameData.CarInfo.ResidualTimeOfEachStage > 0 then
        if GameData.CarInfo.ResidualTimeOfEachStage <= 2.5 and StopBet == false then
            StopBet = true
            for i = 1, 8 do
                BetButtonTable[i].interactable = false
                BetButtonImage[i].color = CS.UnityEngine.Color(0.5, 0.5, 0.5, 1)
            end
            for i = 1, 4 do
                ChipsButtonTable[i].interactable = false
                BetButtonTableImage[i].color = CS.UnityEngine.Color(0.5, 0.5, 0.5, 1)
            end
            PlaySoundEffect("36")
            if GameData.CarInfo.BankerAccountID ~= GameData.RoleInfo.AccountID then
                local isBet = false
                for k = 1, #GameData.CarInfo.myBet do
                    local tData = GameData.CarInfo.myBet[k];
                    if tData ~= nil and tData > 0 then
                        isBet = true
                    end
                end
                if not isBet then
                    this:DelayInvoke(1, function()
                        PlaySoundEffect("37")
                    end)
                end
            end
            CS.BubblePrompt.Show(data.GetString("Tip_Stop_Bet"), "CarRotationUI")
        end
        GameData.CarInfo.ResidualTimeOfEachStage = GameData.CarInfo.ResidualTimeOfEachStage - deltaTime
        if GameData.CarInfo.ResidualTimeOfEachStage < 0 then
            GameData.CarInfo.ResidualTimeOfEachStage = 0
        end
        CountDownText.text = tostring(math.floor(GameData.CarInfo.ResidualTimeOfEachStage))
    else
        CountDownText.text = "0"
    end
    
end

-- 321倒计时动画
function CountDown321Animation()
    if GameData.CarInfo.ResidualTimeOfEachStage <= 2 then
        return 
    end
    PlaySoundEffect("8")
    GameObjectSetActive(CountDown.Mask,true)
    GameObjectSetActive(CountDown.Object[1],true)
    CountDown.Animation[1]:RePlay()
    CountDown.TweenScale[1]:ResetToBeginning()
    CountDown.TweenScale[1]:Play(true)
    CountDown.TweenAlpha[1]:ResetToBeginning()
    CountDown.TweenAlpha[1]:Play(true)
    this:DelayInvoke(1, function ()
        PlaySoundEffect("8")
        GameObjectSetActive(CountDown.Object[1],false)
        GameObjectSetActive(CountDown.Object[2],true)
        CountDown.Animation[2]:RePlay()
        CountDown.TweenScale[2]:ResetToBeginning()
        CountDown.TweenScale[2]:Play(true)
        CountDown.TweenAlpha[2]:ResetToBeginning()
        CountDown.TweenAlpha[2]:Play(true)
    end)
    this:DelayInvoke(2, function ()
        PlaySoundEffect("8")
        GameObjectSetActive(CountDown.Object[2],false)
        GameObjectSetActive(CountDown.Object[3],true)
        CountDown.Animation[3]:RePlay()
        CountDown.TweenScale[3]:ResetToBeginning()
        CountDown.TweenScale[3]:Play(true)
        CountDown.TweenAlpha[3]:ResetToBeginning()
        CountDown.TweenAlpha[3]:Play(true)
    end)
    this:DelayInvoke(3,function ()
        GameObjectSetActive(CountDown.Object[3],false)
        GameObjectSetActive(CountDown.Mask,false)
    end)
end

-- 点击筹码
function ChipsButtonOnClick(mIndex)
    -- body
    SelectBetGoldValue = GameData.CarInfo.ChipsValue[mIndex]
    ChipsLight(mIndex)
end

-- 点击下注按钮
function BetButtonOnClick(mIndex)
    -- body
    if SelectBetGoldValue == 0 then
        CS.BubblePrompt.Show(data.GetString("NotChoice_Chips_1"),"CarRotationUI")
        return
    end
    if GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount) > GameData.RoleInfo.RoomConfiguration[GameData.CarInfo.Level].BetValueMin then
        PlaySoundEffect('5')
        GameData.CarInfo.BetType = mIndex
        GameData.CarInfo.myBetGold = SelectBetGoldValue * 10000
        NetMsgHandler.Send_CS_Car_Bet(GameData.CarInfo.Level)
    else
        CS.BubblePrompt.Show(data.GetString("Car_Bet_Error_1"),"CarRotationUI")
    end
end

-- 筹码高亮
function ChipsLight(mIndex)
    for Index = 1, 4, 1 do
        if Index == mIndex then
            GameObjectSetActive(ChipsSelectObject[Index],true)
        else
            GameObjectSetActive(ChipsSelectObject[Index],false)
        end
    end
end

-- 退出按钮是否可点
function CloseButtonIsClick()
    -- body
    if GameData.CarInfo.IsBet == true then
        CloseButton.interactable = false
        return 
    end

    if GameData.CarInfo.BankerAccountID == GameData.RoleInfo.AccountID then
        CloseButton.interactable = false
    else
        CloseButton.interactable = true
    end
end

-- 下注按钮是否可点
function BetButtonIsClick()
    -- body
    if GameData.CarInfo.NowState == BenChiBaoMa_State.BET and GameData.CarInfo.BankerAccountID ~= GameData.RoleInfo.AccountID then
        if BetButtonTable[1].interactable == true then
            return 
        end
        for i = 1, 8 do
            BetButtonTable[i].interactable = true
            BetButtonImage[i].color = CS.UnityEngine.Color(1, 1, 1, 1)
        end
        for i = 1, 4 do
            ChipsButtonTable[i].interactable = true
            BetButtonTableImage[i].color = CS.UnityEngine.Color(1, 1, 1, 1)
        end
    else
        if BetButtonTable[1].interactable == false then
            return 
        end
        for i = 1, 8 do
            BetButtonTable[i].interactable = false
            BetButtonImage[i].color = CS.UnityEngine.Color(0.5, 0.5, 0.5, 1)
        end
        for i = 1, 4 do
            ChipsButtonTable[i].interactable = false
            BetButtonTableImage[i].color = CS.UnityEngine.Color(0.5, 0.5, 0.5, 1)
        end
    end
end

-- 点击上庄按钮
function UpBankerButtonOnClick()
    NetMsgHandler.Send_CS_Car_UpperDealer(GameData.CarInfo.Level)
end

-- 点击下庄按钮
function DownBankerButtonOnClick()
    NetMsgHandler.Send_CS_Car_LowerDealer(GameData.CarInfo.Level)
end

-- 灯泡灯光关闭打开
function CloseOpenDengPaoLight(mShow)
    if LightDengPaoObject[1][1].activeSelf == mShow then
        return 
    end
    for i= 1, 22 do
        for Index = 1, #LightDengPaoObject[i] do
            GameObjectSetActive(LightDengPaoObject[i][Index],mShow)
        end
    end
end

-- 灯泡Animation 关闭开启
function DengPaoAnimationOpenClose(mShow)
    if DengPaoSpriteAnimation[1][1].enabled == mShow then
        return 
    end
    for i = 1, 22 do
        for Index = 1, #DengPaoSpriteAnimation[i] do
            DengPaoSpriteAnimation[i][Index].enabled = mShow
        end
    end
end

-- 开始下注动画
function StartBetAnimation()
    -- 左侧
    GameObjectSetActive(AnimationObjectLeft,true)
    HandTweenRotation1:ResetToBeginning()
    HandTweenRotation2:ResetToBeginning()
    AnimationTweenPositionLeft.from = CS.UnityEngine.Vector3(AnimationPosition1.transform.localPosition.x,AnimationPosition1.transform.localPosition.y,0)
    AnimationTweenPositionLeft.to = CS.UnityEngine.Vector3(AnimationPosition2.transform.localPosition.x,AnimationPosition2.transform.localPosition.y,0)
    AnimationTweenPositionLeft.duration = 2
    AnimationTweenPositionLeft:ResetToBeginning()
    AnimationTweenPositionLeft:Play(true)
    this:DelayInvoke(0.4, function()
        HandTweenRotation1:Play(true)
    end)
    this:DelayInvoke(0.45, function()
        HandTweenRotation2:Play(true)
    end)
    -- 右侧
    GameObjectSetActive(AnimationObjectRight, true)
    AnimationTweenPositionRight.from = CS.UnityEngine.Vector3(AnimationPosition2.transform.localPosition.x,AnimationPosition2.transform.localPosition.y-260,0)
    AnimationTweenPositionRight.to = CS.UnityEngine.Vector3(AnimationPosition1.transform.localPosition.x,AnimationPosition1.transform.localPosition.y-260,0)
    AnimationTweenPositionRight.duration = 2
    AnimationTweenPositionRight:ResetToBeginning()
    AnimationTweenPositionRight:Play(true)
    this:DelayInvoke(2,function ()
        -- body
        GameObjectSetActive(AnimationObjectLeft,false)
        GameObjectSetActive(AnimationObjectRight, false)
    end)
end

-- 待机动画
function WaitLightAnimation()
    for Index = 1, 8 do
        WaitImageIndex[Index] = WaitImageIndex[Index] -1
        if WaitImageIndex[Index] == 0 then
            WaitImageIndex[Index] = 22
        end
        WaitLightObject[Index].transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[WaitImageIndex[Index]],CircleLightPosition.Y[WaitImageIndex[Index]],0)
    end
end

-- 抽奖动画
function LotteryDrawAnimation()
    -- body
    RunCount = RunCount + 1
    if IsStartChouJiang then
        if RunCount == 1 then
            GameObjectSetActive(LotteryDrawLight2,true)
        elseif RunCount == 2 then
            GameObjectSetActive(LotteryDrawLight3,true)
            IsStartChouJiang = false
        end
    end

    for Index = 1, #LastDengPaoIndex do
        for i = 1, #ChouJiangDengPaoLightObject[LastDengPaoIndex[Index]] do
            GameObjectSetActive(ChouJiangDengPaoLightObject[LastDengPaoIndex[Index]][i],false)
        end
    end
    local IsRunCount = (RunCount + LastWinIndex)%22
    if IsRunCount == 0 then
        IsRunCount = 22
    end
    local IsRunCount2 = (RunCount - 1 + LastWinIndex)%22
    if IsRunCount2 == 0 then
        IsRunCount2 = 22
    end
    local IsRunCount3 = (RunCount - 2 + LastWinIndex)%22
    if IsRunCount3 == 0 then
        IsRunCount3 = 22
    end

    --if RunCount ~= RunAllCount then
        LastDengPaoIndex = {}
        if RunCount <= 6 then
            PlaySoundEffect("BCBM_light_run2")
        elseif RunCount > RunAllCount - 9 then
            PlaySoundEffect("BCBM_light_run2")
        --elseif RunCount%2 == 0 then
        else
            PlaySoundEffect("BCBM_light_run")
        end
        LotteryDrawLight.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[IsRunCount],CircleLightPosition.Y[IsRunCount],0)
        for i = 1, #ChouJiangDengPaoLightObject[IsRunCount] do
            GameObjectSetActive(ChouJiangDengPaoLightObject[IsRunCount][i],true)
            ChouJiangDengPaoLightImage[IsRunCount][i].color = CS.UnityEngine.Color(255, 255, 255, 1);
        end
        LastDengPaoIndex[1] = IsRunCount
    
        if LotteryDrawLight2.activeSelf then
            LotteryDrawLight2.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[IsRunCount2],CircleLightPosition.Y[IsRunCount2],0)
            LastDengPaoIndex[2] = IsRunCount2
            for i = 1, #ChouJiangDengPaoLightObject[IsRunCount2] do
                GameObjectSetActive(ChouJiangDengPaoLightObject[IsRunCount2][i],true)
                ChouJiangDengPaoLightImage[IsRunCount2][i].color = CS.UnityEngine.Color(255, 255, 255, 0.6)
            end
        end
    
        if LotteryDrawLight3.activeSelf then
            LotteryDrawLight3.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[IsRunCount3],CircleLightPosition.Y[IsRunCount3],0)
            LastDengPaoIndex[3] = IsRunCount3
            for i = 1, #ChouJiangDengPaoLightObject[IsRunCount3] do
                GameObjectSetActive(ChouJiangDengPaoLightObject[IsRunCount3][i],true)
                ChouJiangDengPaoLightImage[IsRunCount3][i].color = CS.UnityEngine.Color(255, 255, 255, 0.3)
            end
        end
    --end


    if RunCount == RunAllCount then
        FlashOfLightObject.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[IsRunCount],CircleLightPosition.Y[IsRunCount],0)
        --PlaySoundEffect("BCBM_light_run")
        GameObjectSetActive(FlashOfLightObject,true)
        FlashOfLightTweenAlpha.enabled = true
        FlashOfLightTweenAlpha:ResetToBeginning()
        FlashOfLightTweenAlpha:Play(true)
        this:DelayInvoke(0.6,function ()
            FlashOfLightTweenAlpha.enabled = false
            GameObjectSetActive(FlashOfLightObject,false)
        end)
    end
end

-- 结算动画
function SettlementAnimation()
    local SpriteName = "sprite_bc_ic_"..GameData.CarInfo.LastBetResult[#GameData.CarInfo.LastBetResult]
    SettlementImage:ResetSpriteByName(SpriteName)
    SettlementTweenPosition.from = CS.UnityEngine.Vector3(CircleLightPosition.X[GameData.CarInfo.LotteryTarget],CircleLightPosition.Y[GameData.CarInfo.LotteryTarget],0)
    SettlementTweenPosition.to = CS.UnityEngine.Vector3(0,0,0)
    SettlementTweenPosition:ResetToBeginning()
    SettlementTweenScale:ResetToBeginning()
    GameObjectSetActive(SettlementCanvas,true)
    SettlementTweenPosition:Play(true)
    SettlementTweenScale:Play(true)
    this:DelayInvoke(0.5,function ()
        PlaySoundEffect("PDK_WIN")
        for i = 1, 6 do
            GameObjectSetActive(SettlementLiZi[i],true)
        end
    end)
end

-- 处理玩家中奖
function PlayerIsWinning()
    -- body
    iswinning = true
end

-- 处理庄家获胜
function BankersIsWinning()
    isBankersWinning = (GameData.CarInfo.isBankerWinner == 1)
end

-- 玩家中奖
function PlayerReward()
    iswinning = false
    -- body
    GameObjectSetActive(SettlementCanvas,false)
    for i = 1, 6 do
        GameObjectSetActive(SettlementLiZi[i],false)
    end
    GameObjectSetActive(RewardObject,true)
    GameObjectSetActive(RewardLiZi,true)
    PlaySoundEffect('HB_Gold')
    local BetWinner_Gold = GameData.CarInfo.BetWinner_Gold
    WinningText.text = "<color=#00FF00>"..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(BetWinner_Gold)).."</color>"
    UpdatePlayerGold()
    this:DelayInvoke(3,function ()
        -- body
        GameObjectSetActive(RewardLiZi,false)
    end)
end

-- 庄家获胜
function BankersReward()
    isBankersWinning = false
    -- body
    GameObjectSetActive(SettlementCanvas,false)
    for i = 1, 6 do
        GameObjectSetActive(SettlementLiZi[i],false)
    end
    GameObjectSetActive(RewardObject,true)
    GameObjectSetActive(RewardLiZi,true)
    PlaySoundEffect('HB_Gold')
    local BetWinner_Gold = GameData.CarInfo.BankerSettlement_Gold
    WinningText.text = "<color=#00FF00>"..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(BetWinner_Gold)).."</color>"
    UpdatePlayerGold()
    this:DelayInvoke(3,function ()
        -- body
        GameObjectSetActive(RewardLiZi,false)
    end)
end

-- 关闭玩家中奖界面
function CloseRewardInterface()
    -- body
    GameObjectSetActive(RewardObject,false)
    GameObjectSetActive(RewardLiZi,false)
end

-- 退出奔驰宝马
function ExitBCBM()
    -- body
    NetMsgHandler.QuitCar(GameData.CarInfo.Level)
end

-- 房间状态切换到倒计时状态
function RefreshCountDownPartOfGameRoomByState(roomState,mShow)
    if roomState == BenChiBaoMa_State.DAOJISHI and mShow then
        CountDown321Animation()
        IsWaitAnimation = false
        if WaitLightObject[1].activeSelf then
            for i = 1, 8 do
                GameObjectSetActive(WaitLightObject[i],false)
            end
        end
    end
end

-- 房间状态切换到下注状态
function RefreshBetPartOfGameRoomByState(roomState,mShow)
    if roomState == BenChiBaoMa_State.BET then
        CloseOpenDengPaoLight(true)
        DengPaoAnimationOpenClose(true)
        LastWinIndex = GameData.CarInfo.LastLotteryTarget
        if WaitLightObject[1].activeSelf == false then
            for i = 1, 8 do
                GameObjectSetActive(WaitLightObject[i],true)
            end
        end
        waitTime = 0.5
        IsWaitAnimation = true
        if mShow then
            StartBet = true
            PlaySoundEffect("35")
            StartBetAnimation()
        end
    end
end

-- 房间状态切换到抽奖状态
function RefreshChouJiangPartOfGameRoomByState(roomState,mShow)
    if roomState == BenChiBaoMa_State.XUANZHUAN and mShow then
        CloseOpenDengPaoLight(false)
        DengPaoAnimationOpenClose(false)
        GameObjectSetActive(LastLightObject,false)
        RunTime1 = 0.55
        RunTime3 = 0.05
        local targetPosition = GameData.CarInfo.LotteryTarget
        RunAllCount = 0
        RunCount = 0
        if targetPosition <= LastWinIndex then
            RunAllCount = targetPosition + 22 - LastWinIndex
        else
            RunAllCount = targetPosition - LastWinIndex
        end
        --if RunAllCount > 20 then
            --RunAllCount = math.floor( RunAllCount / 2 )
        --end
        RunAllCount = RunAllCount + (22*3)
        LotteryDrawLight.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[LastWinIndex],CircleLightPosition.Y[LastWinIndex],0)
        LotteryDrawLight2.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[LastWinIndex],CircleLightPosition.Y[LastWinIndex],0)
        LotteryDrawLight3.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[LastWinIndex],CircleLightPosition.Y[LastWinIndex],0)
        GameObjectSetActive(LotteryDrawLight,true)
        IsStartChouJiang = true
        ChouJiangAnimation = true
    elseif roomState == BenChiBaoMa_State.XUANZHUAN then
        CloseOpenDengPaoLight(false)
        DengPaoAnimationOpenClose(false)
        IsStartChouJiang = false
        ChouJiangAnimation = false
    end
end

-- 房间状态切换到结算状态
function RefreshJieSuanPartOfGameRoomByState(roomState,mShow)
    -- body
    if roomState == BenChiBaoMa_State.JIESUAN and mShow then
        DisplayHistoricalRecordsInfo()
        RestBetInfo()
        CloseOpenDengPaoLight(true)
        DengPaoAnimationOpenClose(false)
        GameObjectSetActive(LotteryDrawLight,false)
        GameObjectSetActive(LotteryDrawLight2,false)
        GameObjectSetActive(LotteryDrawLight3,false)
        LastLightObject.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[GameData.CarInfo.LotteryTarget],CircleLightPosition.Y[GameData.CarInfo.LotteryTarget],0)
        BankersInfo.GoldValue.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.CarInfo.BankerGold),2))
        GameObjectSetActive(LastLightObject,true)
        ChouJiangAnimation = false
        for Index = 1, #LastDengPaoIndex do
            for i = 1, #ChouJiangDengPaoLightObject[LastDengPaoIndex[Index]] do
                GameObjectSetActive(ChouJiangDengPaoLightObject[LastDengPaoIndex[Index]][i],false)
            end
        end
        SettlementAnimation()
        if iswinning then
            this:DelayInvoke(3,function ()
                PlayerReward()
            end)
        end
        if isBankersWinning then
            this:DelayInvoke(3,function ()
                BankersReward()
            end)
        end
        if iswinning == false or isBankersWinning == false then
            this:DelayInvoke(3,function ()
                UpdatePlayerGold()
            end)
        end
    elseif roomState == BenChiBaoMa_State.JIESUAN then
        DisplayHistoricalRecordsInfo()
        RestBetInfo()
        DisplayBankersInfo()
        CloseOpenDengPaoLight(true)
        DengPaoAnimationOpenClose(false)
    end
end

-- 房间状态切换到等待状态
function RefreshWaitPartOfGameRoomByState(roomState,mShow)
    if roomState == BenChiBaoMa_State.WAIT then
        CloseOpenDengPaoLight(true)
        DengPaoAnimationOpenClose(true)
        CloseRewardInterface()
        DisplayBankersInfo()
        GameObjectSetActive(SettlementCanvas,false)
        GameData.CarInfo.IsBet = false
        DisplayLastWinnerInfo()
        for i = 1, 6 do
            GameObjectSetActive(SettlementLiZi[i],false)
        end
    end
end

-- 刷新游戏房间进入到指定房间状态
function RefreshGameRoomByRoomStateSwitchTo(mShow)
    print("奔驰宝马刷新游戏房间进入到指定房间状态",GameData.CarInfo.NowState)
    RefreshCountDownPartOfGameRoomByState(GameData.CarInfo.NowState,mShow)
    RefreshBetPartOfGameRoomByState(GameData.CarInfo.NowState,mShow)
    RefreshChouJiangPartOfGameRoomByState(GameData.CarInfo.NowState,mShow)
    RefreshJieSuanPartOfGameRoomByState(GameData.CarInfo.NowState,mShow)
    RefreshWaitPartOfGameRoomByState(GameData.CarInfo.NowState,mShow)
    if GameData.CarInfo.NowState ~= BenChiBaoMa_State.BET then
        CountDownText.text = ""
    end
    CloseButtonIsClick()
    BetButtonIsClick()
    UpdateOnlineNumber()
    StopBet = false
end

-- 隐藏部分UI
function HidePartUI()
    -- UI 关闭时 停掉所有的音效并停止挂起的携程
    MusicMgr:StopAllSoundEffect()
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    for i = 1, 3 do
        GameObjectSetActive(CountDown.Object[i],false)
    end
    for Index = 1, #LastDengPaoIndex do
        for i = 1, #ChouJiangDengPaoLightObject[LastDengPaoIndex[Index]] do
            GameObjectSetActive(ChouJiangDengPaoLightObject[LastDengPaoIndex[Index]][i],false)
        end
    end
    for i = 1, 6 do
        GameObjectSetActive(SettlementLiZi[i],false)
    end
    GameObjectSetActive(SettlementCanvas,false)
    GameObjectSetActive(CountDown.Mask,false)
    GameObjectSetActive(AnimationObjectLeft,false)
    GameObjectSetActive(AnimationObjectRight,false)
    GameObjectSetActive(LastLightObject,true)
    GameObjectSetActive(LotteryDrawLight,false)
    GameObjectSetActive(LotteryDrawLight2,false)
    GameObjectSetActive(LotteryDrawLight3,false)
    GameObjectSetActive(FlashOfLightObject,false)
    FlashOfLightTweenAlpha.enabled = false
    
    LastLightObject.transform.localPosition = CS.UnityEngine.Vector3(CircleLightPosition.X[LastWinIndex],CircleLightPosition.Y[LastWinIndex],0)

end

-- 初始化数值
function InitializationValue()
    -- body
    LastWinIndex = GameData.CarInfo.LastLotteryTarget
    DZValueText.text = ">"..GameData.CarInfo.UpperBankersGold
    ChouJiangAnimation = false
    HidePartUI()
    UpdatePlayerGold()
    ChipsButtonOnClick(1)
    --if GameData.CarInfo.NowState ~= BenChiBaoMa_State.JIESUAN then
        DisplayHistoricalRecordsInfo()
        DisplayBankersInfo()
        DisplayLastWinnerInfo()
    --end
    for Index = 1, 8, 1 do
        UpdateBetInfo(Index)
    end
    for Index = 1, 4, 1 do
        ChipsValueText[Index].text = tostring(GameData.CarInfo.ChipsValue[Index])
    end
    RefreshGameRoomByRoomStateSwitchTo(false)
end

-- 初始化UI
function ResetUI()
    -- body
    HelpWindowObject = this.transform:Find('Canvas/Window/Canvas2/Window_Help').gameObject
    HelpMaskObject = this.transform:Find('Canvas/Window/Canvas1/Mask_Help').gameObject
    BankersListObject = this.transform:Find('Canvas/Window/Content/Center/BankerListInfo').gameObject
    BankersListInfoItem = BankersListObject.transform:Find('BackGround/ChipsItem').gameObject
    UpBankersImage = this.transform:Find('Canvas/Window/Content/Center/sz_Image').gameObject
    DownBankersImage = this.transform:Find('Canvas/Window/Content/Center/xz_Image').gameObject
    BankersInfo.Object = this.transform:Find('Canvas/Window/Content/Center/Player').gameObject
    LastWinnerInfo.Object = this.transform:Find('Canvas/Window/Content/Center/Player1').gameObject
    RewardObject = this.transform:Find('Canvas/Window/Window_Reward/RewardInterface').gameObject
    RewardLiZi = this.transform:Find('Canvas/jingbipengse/01').gameObject
    AnimationObjectLeft = this.transform:Find('Canvas/Ani_Left').gameObject
    AnimationObjectRight = this.transform:Find('Canvas/Ani_Right').gameObject
    AnimationPosition1 = this.transform:Find('Canvas/PeopleAnimationPosition1').gameObject
    AnimationPosition2 = this.transform:Find('Canvas/PeopleAnimationPosition2').gameObject
    CountDown.Mask = this.transform:Find('Canvas/Window/Number/Mask').gameObject
    LotteryDrawLight = this.transform:Find('Canvas/Window/Content/Boundary/Light').gameObject
    LotteryDrawLight2 = this.transform:Find('Canvas/Window/Content/Boundary/Light2').gameObject
    LotteryDrawLight3 = this.transform:Find('Canvas/Window/Content/Boundary/Light3').gameObject
    LastLightObject = this.transform:Find('Canvas/Window/Content/Boundary/Stay_Light').gameObject
    FlashOfLightObject = this.transform:Find('Canvas/Window/Content/Boundary/Stay_Light_Blink').gameObject
    SettlementCanvas = this.transform:Find('Canvas/Window/Content/Boundary/Canvas').gameObject
    SettlementMask = this.transform:Find('Canvas/Window/Content/Boundary/SettlementMask').gameObject

    GolcValueText = this.transform:Find('Canvas/Window/Information/Gold/Number'):GetComponent('Text')
    DZValueText = this.transform:Find('Canvas/Window/Content/Center/SonZong/Number'):GetComponent('Text')
    OnlineNumber = this.transform:Find('Canvas/Window/Content/Center/Button_PlayerList/Text'):GetComponent('Text')
    CountDownText = this.transform:Find('Canvas/Window/Content/Center/CloseTime'):GetComponent('Text')
    LamborghiniText = this.transform:Find('Canvas/Window/Content/Center/Right/Number'):GetComponent('Text')
    FerrariText = this.transform:Find('Canvas/Window/Content/Center/Left/Number'):GetComponent('Text')
    BankersInfo.Name = BankersInfo.Object.transform:Find('RoleName'):GetComponent('Text')
    BankersInfo.GoldValue = BankersInfo.Object.transform:Find('Gold/Number'):GetComponent('Text')
    BankersInfo.Vip = BankersInfo.Object.transform:Find('RoleIcon/Vip/Value'):GetComponent('Text')
    LastWinnerInfo.Name = LastWinnerInfo.Object.transform:Find('RoleName'):GetComponent('Text')
    LastWinnerInfo.GoldValue = LastWinnerInfo.Object.transform:Find('Gold/Number'):GetComponent('Text')
    LastWinnerInfo.Vip = LastWinnerInfo.Object.transform:Find('RoleIcon/Vip/Value'):GetComponent('Text')
    WinningText = RewardObject.transform:Find('Reward/Text'):GetComponent('Text')
    BankersGameCountText = BankersListObject.transform:Find('BackGround/Text'):GetComponent('Text')
    
    BankersInfo.HeadIcon = BankersInfo.Object.transform:Find('RoleIcon'):GetComponent('Image')
    LastWinnerInfo.HeadIcon = LastWinnerInfo.Object.transform:Find('RoleIcon'):GetComponent('Image')
    SettlementImage = this.transform:Find('Canvas/Window/Content/Boundary/Canvas/Image'):GetComponent('Image')

    AnimationTweenPositionLeft = AnimationObjectLeft.transform:GetComponent("TweenPosition")
    AnimationTweenPositionRight = AnimationObjectRight.transform:GetComponent("TweenPosition")
    HandTweenRotation1 = this.transform:Find("Canvas/Ani_Left/Shou"):GetComponent("TweenRotation")
    HandTweenRotation2 = this.transform:Find("Canvas/Ani_Left/Shou/hand"):GetComponent("TweenRotation")
    FlashOfLightTweenAlpha = FlashOfLightObject.transform:GetComponent('TweenAlpha')
    SettlementTweenPosition = this.transform:Find('Canvas/Window/Content/Boundary/Canvas/Image'):GetComponent("TweenPosition")
    SettlementTweenScale = this.transform:Find('Canvas/Window/Content/Boundary/Canvas/Image'):GetComponent("TweenScale")

    CloseButton = this.transform:Find('Canvas/Window/Top/CloseBtn'):GetComponent('Button')

    for Index = 1, 4, 1 do
        ChipsSelectObject[Index] = this.transform:Find('Canvas/Window/Content/Button/Boll/Back/Image'..Index..'/Image').gameObject
        ChipsValueText[Index] = this.transform:Find('Canvas/Window/Content/Button/Boll/Back/Image'..Index..'/Text'):GetComponent('Text')
        ChipsButtonTable[Index] = this.transform:Find('Canvas/Window/Content/Button/Boll/Back/Image'..Index):GetComponent('Button')
        BetButtonTableImage[Index] = this.transform:Find('Canvas/Window/Content/Button/Boll/Back/Image'..Index):GetComponent('Image')
    end

    for i = 1, 5 do
        BankersInfoParent[i] = this.transform:Find('Canvas/Window/Content/Center/BankerListInfo/BackGround/Chips/Viewport/Content/Chip'..i).gameObject
    end

    for Index = 1, 8, 1 do
        AllBetValueText[Index] = this.transform:Find('Canvas/Window/Content/Button/Car/bc_btn_xz_'..Index..'/Num_SoAll_xz_'..Index):GetComponent('Text')
        BetValueText[Index] = this.transform:Find('Canvas/Window/Content/Button/Car/bc_btn_xz_'..Index..'/Num_All_xz_'..Index):GetComponent('Text')
        BetButtonTable[Index] = this.transform:Find('Canvas/Window/Content/Button/Car/bc_btn_xz_'..Index..'_Button'):GetComponent('Button')
        BetButtonImage[Index] = this.transform:Find('Canvas/Window/Content/Button/Car/bc_btn_xz_'..Index..'_Button'):GetComponent('Image')
        WaitLightObject[Index] = this.transform:Find('Canvas/Window/Content/Boundary/Standby'..Index).gameObject
    end

    for Index = 1, 24, 1 do
        HistoricalRecordsObjecty[Index] = this.transform:Find('Canvas/Window/Content/Center/GameRecord/Content/Chip'..Index..'/Background').gameObject
        NewImage[Index] = this.transform:Find('Canvas/Window/Content/Center/GameRecord/Content/Chip'..Index..'/Image').gameObject
        HistoricalRecordsImage[Index] = HistoricalRecordsObjecty[Index].transform:GetComponent('Image')
    end

    for i = 1, 22 do
        LightDengPaoObject[i] = {}
        DengPaoSpriteAnimation[i] = {}
        ChouJiangDengPaoLightObject[i] = {}
        ChouJiangDengPaoLightImage[i] = {}
        local findObject = this.transform:Find('Canvas/Window/Content/Boundary/bc_ic_'..i).gameObject
        local findObject1 = this.transform:Find('Canvas/Window/Content/Boundary/bc_ic_1_'..i).gameObject
        local Count = findObject.transform.childCount
        for Index = 1, Count do
            LightDengPaoObject[i][Index] =  findObject.transform:Find('Image'..Index).gameObject
            DengPaoSpriteAnimation[i][Index] = LightDengPaoObject[i][Index].transform:GetComponent('UGUISpriteAnimation')
            ChouJiangDengPaoLightObject[i][Index] = findObject1.transform:Find('Image'..Index).gameObject
            ChouJiangDengPaoLightImage[i][Index] = ChouJiangDengPaoLightObject[i][Index].transform:GetComponent('Image')
        end
    end

    for i = 1, 3 do
        CountDown.Object[i] = this.transform:Find('Canvas/Window/Number/Images'..i).gameObject
        CountDown.TweenScale[i] = CountDown.Object[i].transform:GetComponent('TweenScale')
        CountDown.TweenAlpha[i] = CountDown.Object[i].transform:GetComponent('TweenAlpha')
        CountDown.Animation[i] = CountDown.Object[i].transform:GetComponent('UGUISpriteAnimation')
    end

    for i = 1, 22 do
        local tempPath = this.transform:Find('Canvas/Window/Content/Boundary/bc_ic_'..i).gameObject.transform.localPosition
        CircleLightPosition.X[i] = tempPath.x
        CircleLightPosition.Y[i] = tempPath.y
    end
    for i = 1, 6 do
        SettlementLiZi[i] = this.transform:Find('Canvas/Window/Content/Boundary/benchibaomajiesun/light_0'..i).gameObject
    end
end

-- 按钮事件响应绑定
function AddButtonHandlers()
    this.transform:Find('Canvas/Window/Top/CloseBtn'):GetComponent('Button').onClick:AddListener(ExitBCBM)
    this.transform:Find('Canvas/Window/Top_Left_Buttons/Button_First'):GetComponent('Button').onClick:AddListener(OpenStoreInterface)
    this.transform:Find('Canvas/Window/Top_Left_Buttons/Button_Second'):GetComponent('Button').onClick:AddListener(OpenRankInterface)
    this.transform:Find('Canvas/Window/Top_Left_Buttons/Button_Third'):GetComponent('Button').onClick:AddListener(function() OpenHelpInterface(true) end)
    this.transform:Find('Canvas/Window/Canvas1/Mask_Help'):GetComponent('Button').onClick:AddListener(function() OpenHelpInterface(false) end)
    this.transform:Find('Canvas/Window/Canvas2/Window_Help/Title/Button_Close'):GetComponent('Button').onClick:AddListener(function() OpenHelpInterface(false) end)
    this.transform:Find('Canvas/Window/Content/Center/Button_PlayerList'):GetComponent('Button').onClick:AddListener(OpenOnlineNumberInterface)
    this.transform:Find('Canvas/Window/Content/Center/Player/BankerList'):GetComponent('Button').onClick:AddListener(BankersListButtonOnClick)
    this.transform:Find('Canvas/Window/Content/Center/BankerListInfo/BackGround/Image'):GetComponent("Button").onClick:AddListener(CloseBankersInfoInterface)
    this.transform:Find('Canvas/Window/Content/Center/sz_Image'):GetComponent('Button').onClick:AddListener(UpBankerButtonOnClick)
    this.transform:Find('Canvas/Window/Content/Center/xz_Image'):GetComponent('Button').onClick:AddListener(DownBankerButtonOnClick)
    this.transform:Find('Canvas/Window/Window_Reward/RewardInterface'):GetComponent('Button').onClick:AddListener(CloseRewardInterface)

    for i = 1, 4, 1 do
        ChipsButtonTable[i].onClick:AddListener(function() ChipsButtonOnClick(i) end)
    end

    for i = 1, 8 , 1 do
        BetButtonTable[i].onClick:AddListener(function() BetButtonOnClick(i) end)
    end
end

-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(tostring( musicid ))
end

function Awake()
    -- body
    ResetUI()
    AddButtonHandlers()
    InitializationValue()
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
end

function Start()
    -- body
    CS.MatchLoadingUI.Hide()
    GameData.GameState = GAME_STATE.ROOM
    GameData.RoomInfo.CurrentRoom.RoomType = ROOM_TYPE.BMWBENZ
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarInfo,InitializationValue)                           --处理房间信息
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyNextRoomState,RefreshGameRoomByRoomStateSwitchTo)            --更新房间状态
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarBankerBetInfo,UpdateBetInfo)                        --更新下注信息
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarBankerListInfo,OpenBankersInfoInterface)            --更新庄家列表信息
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarInterfacePlayerBetVictory,PlayerIsWinning)          --玩家押中弹出获胜界面
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarInterfaceBankerBetVictory,BankersIsWinning)         --庄家押中弹出获胜界面
    HandleRefreshHallUIShowState(false)
    MusicMgr:PlayBackMusic("BG_BCBM")
    -- UI 关闭时 停掉所有的音效并停止挂起的携程
    MusicMgr:StopAllSoundEffect()
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarInfo, InitializationValue)                       --处理房间信息
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyNextRoomState, RefreshGameRoomByRoomStateSwitchTo)        --更新房间状态
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarBankerBetInfo, UpdateBetInfo)                    --更新下注信息
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarBankerListInfo, OpenBankersInfoInterface)        --更新庄家列表信息
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarInterfacePlayerBetVictory, PlayerIsWinning)      --玩家押中弹出获胜界面
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarInterfaceBankerBetVictory, BankersIsWinning)     --庄家押中弹出获胜界面
    local tempObj = CS.WindowManager.Instance:FindWindowNodeByName("UIRoomPlayers")
    if tempObj ~= nil then
        CS.WindowManager.Instance:CloseWindow("UIRoomPlayers", false)
    end
end
local RunTime4 = {0.6,0.65,0.7,0.75,0.8,0.85,0.9}
-- Unity MonoBehavior Update 时调用此方法
function Update()
    if GameData.CarInfo.NowState == BenChiBaoMa_State.BET then
        DisplayCountDown(Time.deltaTime)
        if IsWaitAnimation then
            waitTime = waitTime - Time.deltaTime
            if waitTime <= 0 then
                WaitLightAnimation()
                waitTime = 0.5
            end
        end
    end
    time_Lottery = time_Lottery + Time.deltaTime
    if GameData.CarInfo.NowState == BenChiBaoMa_State.XUANZHUAN and ChouJiangAnimation == true then
        if RunCount <= 6 then
            if time_Lottery >= RunTime1 then
                time_Lottery = 0
                LotteryDrawAnimation()
                RunTime1 = RunTime1 - 0.1
            end
        elseif RunCount < RunAllCount - 9 then
            if time_Lottery >= RunTime2 then
                time_Lottery = 0
                LotteryDrawAnimation()
            end
        elseif RunCount < RunAllCount - 4 then
            if time_Lottery >= RunTime3 then
                time_Lottery = 0
                RunTime3 = RunTime3 + 0.1
                LotteryDrawAnimation()
                if RunCount >= RunAllCount - 4 then
                    RunTime3 = RunTime4[math.random(7)]
                    RunTime3 = RunTime4[6]
                end
            end
        elseif RunCount < RunAllCount then
            if time_Lottery >= RunTime3 then
                RunTime3 = RunTime4[math.random(7)]
                RunTime3 = RunTime4[6]
                time_Lottery = 0
                LotteryDrawAnimation()
            end
        end
    end
    DisplayLBandFLLLastTime(Time.deltaTime)
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    lua_Call_GC()
end