-- 下注默认数量
local BetNumber = 1

-- 翻倍默认数
local DoubleNumber = 1

local Time =CS.UnityEngine.Time

local isUpdateTime =false
--local DoubleCount = 3
local isUpdate=false
local timer=3

local HistoricalRecordsObject = {}
local HistoricalRecordsText = {}

local victory_timer =2
local isLightUpdate=0
local FlashState=true

local MusicNum=0

local mSscWinTweenPosition = nil
local mSscWinGameObject = nil
local IsUpdatePlay = false
local PlayTimer = 16.3

---------------------------------------------- TUDOU ----------------------------------------------

---------_________TUDOU_________---------

local window_Help = nil;
local button_Help = nil;
local button_Help_Close = nil;
local mask_Help = nil;
--帮助页面相关
function DoHelp()
    window_Help = this.transform:Find("Canvas/Window_Help");
    button_Help = this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_Third");
    button_Help_Close = this.transform:Find("Canvas/Window_Help/Title/Button_Close");
    mask_Help = this.transform:Find("Canvas/Mask_Help");
    button_Help:GetComponent("Button").onClick:AddListener(Window_Help_Open);
    button_Help_Close:GetComponent("Button").onClick:AddListener(Window_Help_Close);
    mask_Help:GetComponent("Button").onClick:AddListener(Window_Help_Close);
end

--打开帮助界面
function Window_Help_Open()
    PlaySoundEffect("2");
    window_Help.gameObject:SetActive(true);
    mask_Help.gameObject:SetActive(true);
end

--关闭帮助界面
function Window_Help_Close()
    PlaySoundEffect("2");
    window_Help.gameObject:SetActive(false);
    mask_Help.gameObject:SetActive(false);
end

---------_________TUDOU_________---------


--结算特效 Objects

local settlement = nil              --整个结算
local settlement_Mask = nil;        --结算黑色遮罩
local table_Settlement_Text = {}; --结算结果
local table_SettlementText_TS = {}; --结算结果TweenScale
local table_Poker_settlement = {};  --结算显示的扑克
local table_Settlement_Star = {};
local table_Button_Lottery = {};    --下注的按钮(表)
local table_ButtonLeft_Lottery = {};--下注的左侧按钮(表)
local pokerImage = nil;
local ParticleEffectObj = nil;

--获取结算特效 Objects
function GetSettlementObjects()
    local tempPath = "Canvas/Window/Settlement/";
    settlement = this.transform:Find("Canvas/Window/Settlement");
    settlement_Mask = this.transform:Find(tempPath.."Mask");
    
    for k = 1, 3 do
        table_Poker_settlement[k] = this.transform:Find(tempPath.."Show_Poker_Bg/Poker_"..k):GetComponent("Image")
    end

    for k = 1, 6 do
        table_Settlement_Text[k] = this.transform:Find(tempPath.."Show_Poker_Head/Result_Text_"..k);
        table_SettlementText_TS[k] = table_Settlement_Text[k]:GetComponent("TweenScale");
        
    end

    for k = 1, 7 do
        table_Settlement_Star[k] = this.transform:Find(tempPath.."Star/Star_"..k);
    end

    pokerImage = this.transform:Find(tempPath.."Show_Poker_Bg/Poker"):GetComponent("Image")
    
end

--常态特效 Objects

local table_Light_Left = {};
local table_Light_Right = {};
local table_Light_Middle = {};
local table_Objects_Logo = {};
local table_Logo_TA = {};
local light1 = nil;
local light2 = nil;
local isBlink = true;
local speed_Blink = 0;
local speed_Blink_Logo = 1.5;
local isChangeLight = false;

-- 倒计时CD
local CDSecondText = nil


--
--我的金币
local myCoins;
--银行按钮
local button_Bank;
--排行榜按钮
local button_RankList;
--帮助按钮
local button_Help;
--奖金池  TweenAlpha
local moneyPoolTA;
--帮助窗口
-- local window_Help;
--
local ifOpenHelp = true;
-- 关闭按钮
local Button_Close;
--
local canClose = true;
--
local isFirstIn = true;

local button_PlayerList = nil;

--是否第一次进入动画一开始下注动画
local isFirst_Animation1 = false;
--是否第一次进入动画二结算动画
local isFirst_Animation2 = false;
--是否第一次进入奖励结算展示
local isFirst_Animation3 = false;
--是否第一次播放停止下注
local isFirst_Sound1 = false;
--这把是否下注
local isBet = false;
--等待阶段提示
local mText_Wait = nil;

--获取常态特效 Objects
function GetNormalStateObjects()
    for k = 1, 6 do
        table_Light_Left[k] = this.transform:Find("Canvas/Window/Lights_Left/Light_"..k):GetComponent("Image");
        table_Light_Right[k] = this.transform:Find("Canvas/Window/Lights_Right/Light_"..k):GetComponent("Image");
    end
    for k = 1, 22 do
        table_Light_Middle[k] = this.transform:Find("Canvas/Window/Lights_Middle/Light_"..k):GetComponent("Image");
    end
    for k = 1, 10 do
        table_Objects_Logo[k] = this.transform:Find("Canvas/Window/Logo/Logo_"..k);
        table_Logo_TA[k] = table_Objects_Logo[k]:GetComponent("TweenAlpha");
    end
    light1 = table_Light_Left[1].sprite;
    light2 = table_Light_Right[1].sprite;
end

--两侧的灯的闪烁效果
function LightBlink()
    
    if isChangeLight then
        for k = 1, 6 do
            if k % 2 == 0 then
                table_Light_Left[k].sprite = light1;
                table_Light_Right[k].sprite = light1;
            else
                table_Light_Left[k].sprite = light2;
                table_Light_Right[k].sprite = light2;
            end
        end
        for k = 1, 22 do
            if k % 2 == 0 then
                table_Light_Middle[k].sprite = light1;
            else
                table_Light_Middle[k].sprite = light2;
            end
        end
    else
        for k = 1, 6 do
            if k % 2 == 0 then
                table_Light_Left[k].sprite = light2
                table_Light_Right[k].sprite = light2;
            else
                table_Light_Left[k].sprite = light1;
                table_Light_Right[k].sprite = light1;
            end
        end
        for k = 1, 22 do
            if k % 2 == 0 then
                table_Light_Middle[k].sprite = light2;
            else
                table_Light_Middle[k].sprite = light1;
            end
        end
    end
    isChangeLight = not isChangeLight
end

--Logo的闪烁效果
function LogoBlink()
    for k = 1, 10 do
        this:DelayInvoke(k*0.1, function()
            table_Logo_TA[k]:ResetToBeginning();
            table_Logo_TA[k]:Play(true);
        end)
    end
    for k = 1, 2 do
        this:DelayInvoke(1 + 0.2 * k, function()
            for k = 1, 7 do
                table_Objects_Logo[k]:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 0);
            end
        end)
        this:DelayInvoke(1.1 + 0.2 * k, function()
            for k = 1, 7 do
                table_Objects_Logo[k]:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 1);
            end
        end)
    end
    this:DelayInvoke(1.6, function()
        for k = 1, 10 do
            table_Objects_Logo[k]:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 0)
        end
    end)
end

---------------------------------------------- TUDOU ----------------------------------------------


--添加点击事件
function AddClickEvents()

    this.transform:Find("Canvas/Window/Content/Listing/Chips/RightArrow"):GetComponent("Button").onClick:AddListener(function() PlaySoundEffect("2") end);
    this.transform:Find("Canvas/Window/Content/Listing/Chips/LeftArrow"):GetComponent("Button").onClick:AddListener(function() PlaySoundEffect("2") end);

    -- 关闭按钮
    this.transform:Find('Canvas/Window/Top/CloseBtn'):GetComponent("Button").onClick:AddListener(CloseUI)

    -- 下注区
    this.transform:Find('Canvas/Window/Content/Button/One/Cut1'):GetComponent("Button").onClick:AddListener(BetCut)
    this.transform:Find('Canvas/Window/Content/Button/One/Add1'):GetComponent("Button").onClick:AddListener(BetAdd)
    this.transform:Find('Canvas/Window/Content/Button/One/Number'):GetComponent("Button").onClick:AddListener(BetAdd)

    -- 翻倍区
    this.transform:Find('Canvas/Window/Content/Button/Tow/Cut2'):GetComponent("Button").onClick:AddListener(DoubleCut)
    this.transform:Find('Canvas/Window/Content/Button/Tow/Add2'):GetComponent("Button").onClick:AddListener(DoubleAdd)

    -- 押注区按钮
    for index=1,6,1 do
        this.transform:Find('Canvas/Window/Content/Boundary/Right/Image'..index..'/Image_Button'):GetComponent("Button").onClick:AddListener(function() BetTypeNumber(index) end)
        this.transform:Find('Canvas/Window/Content/Boundary/Right/Image'..index):GetComponent("Button").onClick:AddListener(function() BetTypeNumber(index) end)
    end
    
    -- 押注区赔付比显示
    for index=1,5,1 do
        this.transform:Find("Canvas/Window/Content/Boundary/Right/Image"..index.."/Text1/Image"):GetComponent("Image"):ResetSpriteByName("sprite_"..data.ShishicaiConfig.HISTORY_TYPE_SPRITE[index]);
        this.transform:Find('Canvas/Window/Content/Boundary/Right/Image'..index..'/Text1/Text2'):GetComponent("Text").text=""..data.ShishicaiConfig.PAY_RATE[index].."倍"
    end

    this.transform:Find('Canvas/Panel2/Canvas/RewardInterface'):GetComponent("Button").onClick:AddListener(CloseRewardInterface)

    --TUDOU
    button_Bank:GetComponent("Button").onClick:AddListener(function()
        PlaySoundEffect("2");
        GameConfig.OpenStoreUI();
    end)
    button_RankList:GetComponent("Button").onClick:AddListener(RankButtonOnClick)
    
    button_PlayerList.onClick:AddListener(function() RoleCountButtonOnClick() end)
end

-- 是否读取本地排行榜信息
function JudgmentTimeInterval(windowData)
    if GameData.RankInfo.SscRankTime == 0 then
        return true
    end
    local time1 = os.time()
    if time1 - GameData.RankInfo.SscRankTime >= 60 then
        return true
    end
    return false
end

-- 点击排行榜
function RankButtonOnClick()
    PlaySoundEffect("2");
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = GAME_RANK_TYPE.SSC_MONEY;
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(GAME_RANK_TYPE.SSC_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.SSC_MONEY);
    end
end


function FindObjects()
    myCoins = this.transform:Find("Canvas/Window/CoinAcount/Acount"):GetComponent("Text");
    button_Bank = this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_First");
    button_RankList = this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_Second");
    button_Help = this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_Third");
    moneyPoolTA = this.transform:Find("Canvas/Window/Title/BigNumber/Text"):GetComponent("TweenAlpha");
    Button_Close = this.transform:Find("Canvas/Window/Top/CloseBtn"):GetComponent("Button");
    ParticleEffectObj = this.transform:Find("Canvas/Panel1/Canvas/jingbipengse/01")
    for k = 1, 6 do
        table_Button_Lottery[k] = this.transform:Find("Canvas/Window/Content/Boundary/Right/Image"..k):GetComponent("Button")
        table_ButtonLeft_Lottery[k] = this.transform:Find("Canvas/Window/Content/Boundary/Right/Image"..k.."/Image_Button"):GetComponent("Button")
    end
    mText_Wait = this.transform:Find("Canvas/Window/Text_Wait").gameObject
    this.transform:Find("Canvas/Window/Text_Wait/Text"):GetComponent("Text").text = data.GetString("Tips_Wait")
    mText_Wait:SetActive(false)

    button_PlayerList = this.transform:Find("Canvas/Window/Button_PlayerList"):GetComponent("Button");

    CDSecondText = this.transform:Find('Canvas/Window/Content/TimeNumber/Text1'):GetComponent("Text")
    for Index =1, 16, 1 do
        HistoricalRecordsObject[Index] = this.transform:Find('Canvas/Window/Content/Content/Chip'..Index).gameObject
        HistoricalRecordsText[Index] = this.transform:Find('Canvas/Window/Content/Content/Chip'..Index..'/Text'):GetComponent('Text')
    end
end

function InitValues()
    window_Help.gameObject:SetActive(false);
    settlement.gameObject:SetActive(false);
    
    this.transform:Find("Canvas/Ani_Left").gameObject:SetActive(false);
    this.transform:Find("Canvas/Ani_Right").gameObject:SetActive(false);
    this.transform:Find("Canvas/Panel1/Canvas/jingbipengse/01").gameObject:SetActive(false);
    this.transform:Find("Canvas/Panel2/Canvas/RewardInterface").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Settlement").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window_Help").gameObject:SetActive(false);
    this.transform:Find("Canvas/Mask_Help").gameObject:SetActive(false);
    this.transform:Find("Canvas/Panel1/Canvas/jingbipengse/01").gameObject:SetActive(false);
    this.transform:Find("Canvas/Panel2/Canvas/RewardInterface").gameObject:SetActive(false);
    for k = 1, 6 do
        this.transform:Find("Canvas/Window/Settlement/Show_Poker_Head/Result_Text_"..k).gameObject:SetActive(false);
    end
end



-- 倒计时
function CountDown_Info()
    CountDown_Info_Display()
    if GameData.LotteryInfo.CountDown ~=nil then
        isUpdateTime = true
    end
end

local mSecond1 = -1
local mSecond2 = -1

-- 倒计时显示
function CountDown_Info_Display()


    mSecond1 = math.floor(GameData.LotteryInfo.CountDown)
    if GameData.LotteryInfo.NowState == 0 and mSecond1 == 21 and isFirst_Animation1 then
        isFirst_Animation1 = false;
        Button_Close.interactable = true;
        Animation_StartLottery();
    end
    if GameData.LotteryInfo.NowState == 0 and mSecond1 == 19 then
        for k = 1, 6 do
            table_Button_Lottery[k].interactable = true;
            table_ButtonLeft_Lottery[k].interactable = true;
        end
    end

    if GameData.LotteryInfo.NowState == 0 and mSecond1 == 3 and isFirst_Sound1 then
        isFirst_Sound1 = false;
        CS.BubblePrompt.Show(data.GetString("Tip_Stop_Bet"), "TimeTimeColor");
        PlaySoundEffect("36");
        for k = 1, 6 do
            table_Button_Lottery[k].interactable = false;
            table_ButtonLeft_Lottery[k].interactable = false;---设置下注阶段按钮灰化
        end
        isBet = false;
        for k = 1, 6 do
            local tData = GameData.LotteryInfo.myBet[k]
            if tData ~= nil and tData > 0 then
                isBet = true;
            end
        end

        if not isBet then
            this:DelayInvoke(1.2, function()
                PlaySoundEffect("37");
            end)
            isBet = true;
        end
        
    end
    
    if GameData.LotteryInfo.NowState == 1  and mSecond1 == 7 and isFirst_Animation2 then
        isFirst_Animation2 = false;
        Animation_Settlement();
    end

    if GameData.LotteryInfo.NowState == 1 and mSecond1 == 3 and isFirst_Animation3 then
        isFirst_Animation3 = false;
        this:DelayInvoke(2.8, function()
            ParticleEffectObj.gameObject:SetActive(false);
            myCoins.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
        end)
    end

    if GameData.LotteryInfo.NowState == 2 and mSecond1 == 2 and isFirst_Animation4 then
        isFirst_Animation4 = false;
        
        GameObjectSetActive(mText_Wait, true)
        this:DelayInvoke(1.8, function()
            GameObjectSetActive(mText_Wait, false)
        end)
    end
    

    -- CS.UnityEngine.Profiling.Profiler.BeginSample("=====State 111===22==")
    if GameData.LotteryInfo.NowState == 0 then
        if mSecond2 ~= mSecond1 then
            mSecond2 = mSecond1
            CDSecondText.text = string.format("%02d", mSecond2)
        end
        GameObjectSetActive(CDSecondText.gameObject, true)
        GameObjectSetActive(mText_Wait, false)
    else
        GameObjectSetActive(CDSecondText.gameObject, false)
        for k = 1, 6 do
            table_Button_Lottery[k].interactable = false
            table_ButtonLeft_Lottery[k].interactable = false
        end
    end

    if mSecond1 <= 0 then
        isUpdateTime=false
    end

    -- CS.UnityEngine.Profiling.Profiler.EndSample()
end


-- 上次豹子出现距离现在时间
function BaoZiLastTime()
    local baoziLastTime = GameData.LotteryInfo.LastBaoziTime
    if baoziLastTime > 359999 then
        baoziLastTime = 359999
    end

    local mSecond1 = math.floor((baoziLastTime % 3600) % 60)
    local Minute = math.floor((baoziLastTime % 3600) / 60)
    local Hour = math.floor(baoziLastTime / 3600)

    if Hour > 9 then
        this.transform:Find('Canvas/Window/Content/Boundary/baozhiTime/Hour'):GetComponent("Text").text=""..Hour
    else 
        this.transform:Find('Canvas/Window/Content/Boundary/baozhiTime/Hour'):GetComponent("Text").text="0"..Hour
    end

    if Minute > 9 then
        this.transform:Find('Canvas/Window/Content/Boundary/baozhiTime/Minute'):GetComponent("Text").text=""..Minute
    else
        this.transform:Find('Canvas/Window/Content/Boundary/baozhiTime/Minute'):GetComponent("Text").text="0"..Minute
    end
end

-- 下注
function BetTypeNumber(index)
    -- -- 请求时时彩下注
    PlaySoundEffect('5')
    if GameData.LotteryInfo.NowState ~= 0 then
        CS.BubblePrompt.Show(data.GetString("开奖时间无法下注"),"TimeTimeColor")
    else
        GameData.LotteryInfo.Bet_Button_Type=index
        GameData.LotteryInfo.MyBet_Gold=GameData.LotteryInfo.BetNumber*GameData.LotteryInfo.DoubleNumber*10000
        NetMsgHandler.LotteryForBet()
        this:DelayInvoke(0.5, function()
            myCoins.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
        end)
    end
end

-- 关闭UIcall
function CloseUI()
    local canQuit = true
    for k = 1, 6 do
        local tData = GameData.LotteryInfo.myBet[k]
        if tData ~= nil and tData > 0 then
            -- body
            canQuit = false
            break
        end
    end

    if canQuit then
        PlaySoundEffect('2')
        -- body
        NetMsgHandler.QuitLottery()
    end
    -- CS.WindowManager.Instance:CloseWindow("TimeTimeColor",false)
end

-- 处理配置相关信息
function HandleInfo()
    HandleRefreshHallUIShowState(false);
    isFirst_Sound1 = true;
    isFirst_Animation1 = true;
    isFirst_Animation2 = true;
    isFirst_Animation3 = true;
    isFirst_Animation4 = true;
    BetDoubleNumberText() -- 刷新 下注数_翻倍数
    HistoricalLicensingResults() -- 历史开牌结果—_只显示三十轮
    BetsArea() -- 刷新下注区和彩金池的的数量
    PlayerInfo() -- 上轮获益最多玩家信息
    LicensingResults() -- 开牌
    CountDown_Info() -- 倒计时
    BaoZiLastTime()  --上次豹子出现时间
    PlayerHaveGoldNumber()
    SscWinInfoDisplay()
    RefreshPlayerCount();
    ResetBetButton()
end

-- 重置下注按钮
function ResetBetButton()
    if GameData.LotteryInfo.NowState == 0 and GameData.LotteryInfo.CountDown > 3 then
        for k = 1, 6 do
            table_Button_Lottery[k].interactable = true
            table_ButtonLeft_Lottery[k].interactable = true
        end
    else
        for k = 1, 6 do
            table_Button_Lottery[k].interactable = false
            table_ButtonLeft_Lottery[k].interactable = false
        end
    end
end

-- 押中牌型闪光
function Card_TYpe_Light()
    isLightUpdate=GameData.LotteryInfo.NowState
    local count=GameData.LotteryInfo.Victory_Card_Type
    if MusicNum<1 then
        local num =count+25
        MusicNum=MusicNum+1
        local number=""..num
    end

    victory_timer=victory_timer-Time.deltaTime
    if victory_timer<=0 then
        victory_timer=2
        FlashState=false
        isLightUpdate=0
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyAcceptBetVictory,GameData.LotteryInfo.is_Bet_Victory)
    end

end


-- 刷新 下注数_翻倍数
function BetDoubleNumberText()
    this.transform:Find('Canvas/Window/Content/Button/One/Number/Text'):GetComponent("Text").text = lua_CommaSeperate(GameData.LotteryInfo.BetNumber)
    this.transform:Find('Canvas/Window/Content/Button/Tow/Text'):GetComponent("Text").text = lua_CommaSeperate(GameData.LotteryInfo.DoubleNumber)

end

-- 上轮获益最多玩家信息
function PlayerInfo()
    local Winner_Gold =(GameConfig.GetFormatColdNumber(GameData.LotteryInfo.Winner_Gold))
    this.transform:Find('Canvas/Window/Content/Boundary/Player/Gold/Number'):GetComponent("Text").text=lua_NumberToStyle1String(Winner_Gold)
    this.transform:Find('Canvas/Window/Content/Boundary/Player/RoleIcon/Vip/Value'):GetComponent("Text").text="VIP"..GameData.LotteryInfo.WinnerVipLevel
    this.transform:Find('Canvas/Window/Content/Boundary/Player/RoleName'):GetComponent("Text").text=GameData.LotteryInfo.WinnerStrLoginIP
    this.transform:Find('Canvas/Window/Content/Boundary/Player/RoleIcon'):GetComponent("Image"):ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.LotteryInfo.WinnerID))
end

-- 刷新下注区和彩金池的的数量
function BetsArea()
    -- 玩家本身下注信息
    for index = 1,6  do
        if GameData.LotteryInfo.myBet[index] ~= nil then
            local myBet=GameConfig.GetFormatColdNumber(GameData.LotteryInfo.myBet[index]) 
            this.transform:Find('Canvas/Window/Content/Boundary/Right/Image'..index..'/Text2'):GetComponent("Text").text=lua_NumberToStyle1String(myBet)
            if myBet ~= 0 then
                Button_Close.interactable = false;
            end
        else
            this.transform:Find('Canvas/Window/Content/Boundary/Right/Image'..index..'/Text2'):GetComponent("Text").text="0"
        end
    end

    -- 所有玩家下注信息
    for index = 1,6  do
        if GameData.LotteryInfo.Bet[index] ~= nil then
            local Bet=GameConfig.GetFormatColdNumber(GameData.LotteryInfo.Bet[index]) 
            this.transform:Find('Canvas/Window/Content/Boundary/Right/Image'..index..'/Text3'):GetComponent("Text").text=""..lua_NumberToStyle1String(Bet)
        else
            this.transform:Find('Canvas/Window/Content/Boundary/Right/Image'..index..'/Text3'):GetComponent("Text").text="0"
        end
    end

    -- 奖金池区
    this.transform:Find('Canvas/Window/Title/BigNumber/Text'):GetComponent("Text").text ="".. string.format('%.2f', GameConfig.GetFormatColdNumber(GameData.LotteryInfo.GoldPool))

end

-- 历史开牌结果—_只显示三十轮
function HistoricalLicensingResults()
    local count=GameData.LotteryInfo.OpenCardNum
    for num=1,count,1 do
        if HistoricalRecordsObject[num] ~= nil then
            GameObjectSetActive(HistoricalRecordsObject[num],true)
            HistoricalRecordsText[num].text = ""..data.ShishicaiConfig.HISTORY_TYPE[GameData.LotteryInfo.OpenCardHistory[count+1-num]]
        end
        --this.transform:Find('Canvas/Window/Content/Listing/Chips/Viewport/Content/Chip'..num..'/Image/Text'):GetComponent("Text").text=""..data.ShishicaiConfig.HISTORY_TYPE[GameData.LotteryInfo.OpenCardHistory[count+1-num]]
    end
    PlayerInfo()
end

-- 开牌
function LicensingResults()
    if GameData.LotteryInfo.PokersNum == 0 then
        PukerBack()
    else
        PukerPositive()
    end
end

function PukerBack()
    for num=1,3,1 do
    this.transform:Find('Canvas/Window/Content/Poker/Image'..num):GetComponent("Image"):ResetSpriteByName(GameData.GetPokerCardBackSpriteName())
    end
end

--TUDOU: 结算特效
function PukerPositive()
    
    --local contentTween= this.transform:Find('Canvas/Window/Content/Listing/Chips/Viewport/Content').gameObject
    --contentTween:SetActive(false)
    --contentTween:SetActive(true)
    --[[local tween=this.transform:Find('Canvas/Window/Content/Listing/Chips/Viewport/Content'):GetComponent("TweenPosition")
    if tween ~= nil then
        tween.enabled=true
        tween:ResetToBeginning()
        tween.to = CS.UnityEngine.Vector3(0,0,0)
        tween.duration=0.01
        tween:Play(true)
    end--]]
end

-- 获奖界面打开
function OpenRewardInterface(isOpen)
    isFirstIn = false;
    if isOpen == 1 then
        local Bet_Victory_Gold =(GameConfig.GetFormatColdNumber(GameData.LotteryInfo.Bet_Victory_Gold))
        -- local RewardInterface = this.transform:Find('Canvas/Window/RewardInterface').gameObject:SetActive(true)
        if Bet_Victory_Gold>=10000 then
            Bet_Victory_Gold=Bet_Victory_Gold/10000
        this.transform:Find('Canvas/Panel2/Canvas/RewardInterface/Reward/Text'):GetComponent("Text").text="<color=#00FF00>"..lua_CommaSeperate(Bet_Victory_Gold).."万</color>"
        else
            this.transform:Find('Canvas/Panel2/Canvas/RewardInterface/Reward/Text'):GetComponent("Text").text="<color=#00FF00>"..lua_CommaSeperate(Bet_Victory_Gold).."</color>"
        end
        GameData.LotteryInfo.is_Bet_Victory=0
        isUpdate=truet
        MusicNum=0
        this:DelayInvoke(2, function()
            PlaySoundEffect('game_win');
            ParticleEffectObj.gameObject:SetActive(true);
            PlaySoundEffect('HB_Gold');
            this.transform:Find('Canvas/Panel2/Canvas/RewardInterface').gameObject:SetActive(true);
        end)
        
        this:DelayInvoke(4, function()
            CloseRewardInterface();
        end)
    else
        this:DelayInvoke(2, function()
            mText_Wait:SetActive(true)
        end)
    end
    
end

-- 获奖界面关闭
function CloseRewardInterface()
    local RewardInterface = this.transform:Find('Canvas/Panel2/Canvas/RewardInterface').gameObject:SetActive(false)
    isUpdate=false
    --FlashState=true
    timer=3
end

-- 玩家拥有金币数量
function PlayerHaveGoldNumber()
    -- PlaySoundEffect("2");
    local haveGold=(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))
    --local haveGold=GameData.RoleInfo.GoldCount
    this.transform:Find('Canvas/Window/CoinAcount/Acount'):GetComponent("Text").text=tostring(lua_GetPreciseDecimal(haveGold,2))
end

-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(tostring( musicid ))
end

-- 下注_减
function BetCut()
    --local BetNumber=GameData.LotteryInfo.BetNumber
    BetNumber=BetNumber-1
    if BetNumber <1 then
        BetNumber=4
    end
    GameData.LotteryInfo.BetNumber=data.ShishicaiConfig.BET_GOLD[BetNumber]
    PlaySoundEffect('2')
    BetDoubleNumberText()
end

-- 下注_加
function BetAdd()
    --local BetNumber=GameData.LotteryInfo.BetNumber
    BetNumber=BetNumber+1
    if BetNumber >4 then
        BetNumber=1
    end
    GameData.LotteryInfo.BetNumber=data.ShishicaiConfig.BET_GOLD[BetNumber]
    PlaySoundEffect('2')
    BetDoubleNumberText()
end

-- 翻倍数_减
function DoubleCut()
    DoubleNumber=DoubleNumber-1
    if DoubleNumber<1 then
        DoubleNumber=3
    end
    GameData.LotteryInfo.DoubleNumber=data.ShishicaiConfig.BET_NUMBER[DoubleNumber]
    PlaySoundEffect('2')
    BetDoubleNumberText()
end

-- 翻倍数_加
function DoubleAdd()
    DoubleNumber=DoubleNumber+1
    if DoubleNumber>3 then
        DoubleNumber=1
    end
    GameData.LotteryInfo.DoubleNumber=data.ShishicaiConfig.BET_NUMBER[DoubleNumber]
    PlaySoundEffect('2')
    BetDoubleNumberText()
end

--结算特效
function Animation_Settlement()
    for Index = 1, 3, 1 do
        table_Poker_settlement[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    settlement.gameObject:SetActive(true);
    
    for num=1,3,1 do
        this:DelayInvoke(num*0.5, function()
            PlaySoundEffect("4");
            local pokerColor=GameData.LotteryInfo.PokerColor[num];
            local pokerNumber=GameData.LotteryInfo.PokerSize[num];
            table_Poker_settlement[num]:ResetSpriteByName(GameData.GetLotteryPokerSpriteName(pokerColor,pokerNumber));
        end)
    end
    local tempPokerType = GameData.LotteryInfo.Victory_Card_Type;
    --字体缩小
    this:DelayInvoke(2, function()
        local tempSoundIndex = 25 + tempPokerType;
        PlaySoundEffect(tempSoundIndex);
        table_Settlement_Text[7 - tempPokerType].gameObject:SetActive(true);
        table_SettlementText_TS[7 - tempPokerType]:ResetToBeginning();
        table_SettlementText_TS[7 - tempPokerType]:Play(true);
    end)
    --星星闪烁
    this:DelayInvoke(2, function()
        -- for k = 1, 3 do
            this:DelayInvoke(0, function()
                table_Settlement_Star[1].gameObject:SetActive(true);
                local tempTR = table_Settlement_Star[1]:GetComponent("TweenRotation");
                local tempTS = table_Settlement_Star[1]:GetComponent("TweenScale");
                local tempTA = table_Settlement_Star[1]:GetComponent("TweenAlpha");
                tempTS:ResetToBeginning();
                tempTR:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTS:Play(true);
                tempTR:Play(true);
                tempTA:Play(true);
                this:DelayInvoke(0.4, function()
                    table_Settlement_Star[1].gameObject:SetActive(false);
                end)
            end)
            this:DelayInvoke(0.1, function()
                table_Settlement_Star[2].gameObject:SetActive(true);
                table_Settlement_Star[3].gameObject:SetActive(true);
                local tempTR1 = table_Settlement_Star[2]:GetComponent("TweenRotation");
                local tempTS1 = table_Settlement_Star[2]:GetComponent("TweenScale");
                local tempTA1 = table_Settlement_Star[2]:GetComponent("TweenAlpha");
                local tempTR2 = table_Settlement_Star[3]:GetComponent("TweenRotation");
                local tempTS2 = table_Settlement_Star[3]:GetComponent("TweenScale");
                local tempTA2 = table_Settlement_Star[3]:GetComponent("TweenAlpha");
                tempTS1:ResetToBeginning();
                tempTR1:ResetToBeginning();
                tempTA1:ResetToBeginning();
                tempTS2:ResetToBeginning();
                tempTR2:ResetToBeginning();
                tempTA2:ResetToBeginning();
                tempTS1:Play(true);
                tempTR1:Play(true);
                tempTA1:Play(true);
                tempTS2:Play(true);
                tempTR2:Play(true);
                tempTA2:Play(true);
                this:DelayInvoke(0.4, function()
                    table_Settlement_Star[2].gameObject:SetActive(false);
                    table_Settlement_Star[3].gameObject:SetActive(false);
                end)
            end)
            this:DelayInvoke(0.2, function()
                table_Settlement_Star[4].gameObject:SetActive(true);
                local tempTR = table_Settlement_Star[4]:GetComponent("TweenRotation");
                local tempTS = table_Settlement_Star[4]:GetComponent("TweenScale");
                local tempTA = table_Settlement_Star[4]:GetComponent("TweenAlpha");
                tempTS:ResetToBeginning();
                tempTR:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTS:Play(true);
                tempTR:Play(true);
                tempTA:Play(true);
                this:DelayInvoke(0.4, function()
                    table_Settlement_Star[4].gameObject:SetActive(false);
                end)
            end)
            this:DelayInvoke(0.3, function()
                table_Settlement_Star[5].gameObject:SetActive(true);
                local tempTR = table_Settlement_Star[5]:GetComponent("TweenRotation");
                local tempTS = table_Settlement_Star[5]:GetComponent("TweenScale");
                local tempTA = table_Settlement_Star[5]:GetComponent("TweenAlpha");
                tempTS:ResetToBeginning();
                tempTR:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTS:Play(true);
                tempTR:Play(true);
                tempTA:Play(true);
                this:DelayInvoke(0.4, function()
                    table_Settlement_Star[5].gameObject:SetActive(false);
                end)
            end)
            this:DelayInvoke(0.4, function()
                table_Settlement_Star[6].gameObject:SetActive(true);
                local tempTR = table_Settlement_Star[6]:GetComponent("TweenRotation");
                local tempTS = table_Settlement_Star[6]:GetComponent("TweenScale");
                local tempTA = table_Settlement_Star[6]:GetComponent("TweenAlpha");
                tempTS:ResetToBeginning();
                tempTR:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTS:Play(true);
                tempTR:Play(true);
                tempTA:Play(true);
                this:DelayInvoke(0.4, function()
                    table_Settlement_Star[6].gameObject:SetActive(false);
                end)
            end)
            this:DelayInvoke(0.5, function()
                table_Settlement_Star[7].gameObject:SetActive(true);
                local tempTR = table_Settlement_Star[7]:GetComponent("TweenRotation");
                local tempTS = table_Settlement_Star[7]:GetComponent("TweenScale");
                local tempTA = table_Settlement_Star[7]:GetComponent("TweenAlpha");
                tempTS:ResetToBeginning();
                tempTR:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTS:Play(true);
                tempTR:Play(true);
                tempTA:Play(true);
                this:DelayInvoke(0.4, function()
                    table_Settlement_Star[7].gameObject:SetActive(false);
                end)
            end)
        -- end
    end)
    --销毁结算特效
    this:DelayInvoke(3.6, function()
        table_Settlement_Text[7 - tempPokerType].gameObject:SetActive(false);
        settlement.gameObject:SetActive(false);
        for k = 1, 3 do
            table_Poker_settlement[k].sprite = pokerImage.sprite
        end
        for k = 1, 7 do
            table_Settlement_Star[k].gameObject:SetActive(false);
        end
        Button_Close.interactable = true;
    end)
end

-- 开始投注动画函数
function Animation_StartLottery()
    -- 左侧 
    PlaySoundEffect("35");
    local AnimationObject1 = this.transform:Find('Canvas/Ani_Left').gameObject
    local AnimationTweenPosition = AnimationObject1.transform:GetComponent("TweenPosition")
    local AnimationPosition1 = this.transform:Find('Canvas/PeopleAnimationPosition1').gameObject
    local AnimationPosition2 = this.transform:Find('Canvas/PeopleAnimationPosition2').gameObject
    GameObjectSetActive(AnimationObject1,true)
    AnimationTweenPosition.from = CS.UnityEngine.Vector3(AnimationPosition1.transform.localPosition.x,AnimationPosition1.transform.localPosition.y,0)
    AnimationTweenPosition.to = CS.UnityEngine.Vector3(AnimationPosition2.transform.localPosition.x,AnimationPosition2.transform.localPosition.y,0)
    AnimationTweenPosition.duration = 2
    AnimationTweenPosition:ResetToBeginning()
    AnimationTweenPosition:Play(true)
    local Animation_Shou = this.transform:Find("Canvas/Ani_Left/Shou").gameObject;
    local Animation_Shou_TR = Animation_Shou:GetComponent("TweenRotation");
    local Animation_Hand = this.transform:Find("Canvas/Ani_Left/Shou/hand").gameObject;
    local Animation_Hand_TR = Animation_Hand:GetComponent("TweenRotation");
    -- GameObjectSetActive(Animation_Shou, true);
    this:DelayInvoke(0.4, function()
        Animation_Shou_TR:ResetToBeginning();
        Animation_Shou_TR:Play(true);
    end)
    this:DelayInvoke(0.45, function()
        Animation_Hand_TR:ResetToBeginning();
        Animation_Hand_TR:Play(true);
    end)
    -- 右侧
    local AnimationObject2 = this.transform:Find('Canvas/Ani_Right').gameObject;
    local Animation_TP = AnimationObject2:GetComponent("TweenPosition");
    GameObjectSetActive(AnimationObject2, true);
    Animation_TP.to = CS.UnityEngine.Vector3(AnimationPosition1.transform.localPosition.x,AnimationPosition1.transform.localPosition.y-260,0)
    Animation_TP.from = CS.UnityEngine.Vector3(AnimationPosition2.transform.localPosition.x,AnimationPosition2.transform.localPosition.y-260,0)
    Animation_TP.duration = 2
    Animation_TP:ResetToBeginning();
    Animation_TP:Play(true);


    this:DelayInvoke(2,function ()
        -- body
        GameObjectSetActive(AnimationObject1,false);
        GameObjectSetActive(AnimationObject2, false);
        Animation_Shou_TR:ResetToBeginning();
        Animation_Hand_TR:ResetToBeginning();
    end)
end

-- 房间玩家列表查看响应
function RoleCountButtonOnClick()
    -- body
    PlaySoundEffect("2");
    local initParam = CS.WindowNodeInitParam("UIRoomPlayers")
    initParam.WindowData = 5;
    CS.WindowManager.Instance:OpenWindow(initParam)
end

function RefreshPlayerCount()
    this.transform:Find("Canvas/Window/Button_PlayerList/Text"):GetComponent("Text").text = ""..GameData.LotteryInfo.PlayerCount;
end



function  InitRoomInfo()
    CS.MatchLoadingUI.Hide()
    MusicMgr:StopAllSoundEffect();
    this:StopAllDelayInvoke();
    InitValues();
    RefreshPlayerCount();

end

-- 获奖玩家信息显示
function SscWinInfoDisplay()
    if #GameData.SscWinnInfo>=1 and IsUpdatePlay == false then
        IsUpdatePlay=false
        mSscWinGameObject:SetActive(true)
        mSscWinGameObject.transform:Find("Text"):GetComponent("Text").text=string.format(data.GetString("JH_Wheel_WinningMessage"),GameData.SscWinnInfo[1].StrLoginIP,GameData.SscWinnInfo[1].PlayerGold)
        --mSscWinGameObject.transform:Find("Text"):GetComponent("Text").text="恭喜"..GameData.SscWinnInfo[1].StrLoginIP.."玩家中大奖，获得"..GameData.SscWinnInfo[1].PlayerGold.."金币"
        this:DelayInvoke(2.8,function()
            table.remove(GameData.SscWinnInfo,1)
        end)
        mSscWinTweenPosition:ResetToBeginning()
        mSscWinTweenPosition:Play(true)
        IsUpdatePlay = true
    elseif #GameData.SscWinnInfo == 0 then
        mSscWinGameObject:SetActive(false)
        IsUpdatePlay=false
    end
end

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    
    DoHelp();
    MusicMgr:StopAllSoundEffect();
    this:StopAllDelayInvoke();

    isFirstIn = true;
    --获取结算特效Objects
    GetSettlementObjects();
    --获取常态特效Objects
    GetNormalStateObjects();
    --得到所需物体
    FindObjects();
    --初始化数值
    InitValues();
    --添加点击事件
    AddClickEvents();

    local canReturn = true;
    for k = 1, 6 do
        local tData = GameData.LotteryInfo.myBet[k]
        if tData ~= nil and tData > 0 then
            canReturn = false;
        else
        end
    end
    
    Button_Close.interactable = canReturn;


    mSscWinTweenPosition = this.transform:Find("Canvas/Window/WinningMessage/Text"):GetComponent("TweenPosition")
    mSscWinGameObject= this.transform:Find("Canvas/Window/WinningMessage").gameObject
    GameData.LotteryInfo.BetNumber=data.ShishicaiConfig.BET_GOLD[BetNumber]
    GameData.LotteryInfo.DoubleNumber=data.ShishicaiConfig.BET_NUMBER[DoubleNumber]
    local haveGold=(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))
    local betgold=GameData.LotteryInfo.BetNumber*GameData.LotteryInfo.DoubleNumber
    if haveGold< betgold then
        GameData.LotteryInfo.BetNumber=data.ShishicaiConfig.BET_GOLD[BetNumber]
        GameData.LotteryInfo.DoubleNumber=data.ShishicaiConfig.BET_NUMBER[DoubleNumber]
    end
    mSscWinGameObject:SetActive(false)
    HandleInfo()
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    CS.MatchLoadingUI.Hide()
    GameData.GameState = GAME_STATE.ROOM
    GameData.RoomInfo.CurrentRoom.RoomType = ROOM_TYPE.SSC
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    GameData.LotteryInfo.ssc_isOpen = 1
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptLotteryInfo, HandleInfo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.SendTheMessageToBeSuccessful, BetsArea)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptBetVictory, OpenRewardInterface)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyOpenCard,Card_TYpe_Light)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent,PlayerHaveGoldNumber)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifySscUpdateWinInfo, SscWinInfoDisplay)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, InitRoomInfo);
    MusicMgr:PlayBackMusic("BG_SSC")
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    GameData.LotteryInfo.ssc_isOpen = 0
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptLotteryInfo, HandleInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.SendTheMessageToBeSuccessful, BetsArea)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptBetVictory, OpenRewardInterface)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyOpenCard, Card_TYpe_Light)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, PlayerHaveGoldNumber)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifySscUpdateWinInfo, SscWinInfoDisplay)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, InitRoomInfo);
    GameData.SscWinnInfo={}
    MusicMgr:StopAllSoundEffect();
    this:StopAllDelayInvoke();
    local tempObj = CS.WindowManager.Instance:FindWindowNodeByName("UIRoomPlayers")
    if tempObj ~= nil then
        CS.WindowManager.Instance:CloseWindow("UIRoomPlayers", false)
    end
end

-- Unity MonoBehavior Update 时调用此方法
function Update()

    if isUpdateTime  then
        GameData.LotteryInfoCountDown(Time.deltaTime)
        -- CS.UnityEngine.Profiling.Profiler.BeginSample("=====State 111=====")
        CountDown_Info_Display()
        -- CS.UnityEngine.Profiling.Profiler.EndSample()
    end

    if isLightUpdate==1 then
       Card_TYpe_Light()
    end

    if IsUpdatePlay == true then
        PlayTimer = PlayTimer-Time.deltaTime
        if PlayTimer <= 0 then
            IsUpdatePlay=false
            SscWinInfoDisplay()
            PlayTimer = 16.3
        end
    end

    --TUDOU
    speed_Blink = speed_Blink + Time.deltaTime;
    speed_Blink_Logo = speed_Blink_Logo + Time.deltaTime;
    if isBlink then
        if speed_Blink > 0.2 then
            speed_Blink = 0;
            LightBlink();
        end
        if speed_Blink_Logo > 1.8 then
            speed_Blink_Logo = 0;
            LogoBlink();
        end
    end

end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    lua_Call_GC()
end


