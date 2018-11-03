--[[
   文件名称:TimeTimeColorUI_V.lua
   创 建 人:土豆陛下
   创建时间：2018-9-4 11:00
   功能描述：时时彩界面的View层
]]--

--region ========= ( 定义变量 )

local TTC_V = {};
local math_Floor = math.floor;

-- 系统变量
local Time = CS.UnityEngine.Time;
-- 开牌动画物体及其组件
local settlement = {
    RootObj = nil,      -- 结算弹窗
    Mask = nil,         -- 遮罩
    PokerBack = nil;    -- 扑克背面
    Text_Result = {},   -- 结算结果
    TS_Result = {},     -- 开牌结果的TweenScale
    Poker = {},         -- 开牌显示的扑克
    Star = {},          -- 开牌闪烁的星星
    TS_Star = {},       -- 星星(Tween Scale)
    TA_Star = {},       -- 星星(Tween Alpha)
    TR_Star = {},       -- 星星(Tween Rotation)
};
-- 奖励面板及粒子特效
local  rewards = {
    RootObj = nil,          -- 奖励面板
    GoldCount = 0,          -- 奖励金币数量
    ClosePanelBtn = nil,       -- 关闭奖励面板按钮
    ParticleEffect = nil,   -- 粒子特效
}
-- 开始投注动画两个定点
local point1 = nil;     -- 动画左定点
local point2 = nil;     -- 动画右定点
-- 帮助界面
local window_Help = {
    RootObj = nil,          -- 【帮助】窗体
    Mask_Help = nil,        -- 【帮助】遮罩
    button_MaskHelp = nil,  -- 【帮助】遮罩按钮
}
-- 开始投注动画左
local  ani_Left = {
    RootObj = nil,      -- 左动画
    RootObj_TP = nil,   -- 左动画TweenPosition
    Girl = nil,         -- 女孩
    Shou = nil,         -- 女孩手臂
    Shou_TR = nil,      -- 女孩手臂 TweenRotation
    Shou_Hand = nil,    -- 女孩手掌
    Shou_HandTR = nil,  -- 女孩手掌 TweenRotation
};
-- 开始投注动画右边
local ani_Right = {
    RootObj = nil,      -- 右动画
    RootObj_TP = nil,   -- 右动画 TweenPosition
};
-- "上次豹子时间"面板
local baoZiPanel = {
    Hour = 0,
    Minute = 0,
};
-- "上轮大赢家" 面板
local lastWinnerPanel = {
    GoldCount = nil,
    RoleIcon = nil,
    VipLevel = nil,
    RoleName = nil,
};
-- 历史开牌结果
local resultHistory = {
    Content = nil,
    Text_New = nil,
    Chips = {},
    Text_Result = {},
}
-- "我的金币"
local text_MyGoldCount = 0;
-- 倒计时
local text_Countdown = nil;
local temp_Countdown = 0;
-- 按钮
local buttons = {
    button_Close = nil,         -- "疯狂三张"退出按钮
    button_Shop = nil,          -- 【商城】按钮
    button_RankList = nil,      -- 【排行榜】按钮
    button_Help = nil,          -- 【帮助】界面按钮
    button_Help = nil,          -- 【帮助】界面遮罩
    button_CloseHelp = nil,     -- 【帮助】界面关闭按钮
    button_PlayerList = nil,    -- 【玩家列表】按钮
    button_MinusRate = nil,     -- 下注的倍率(减)
    button_AddRate = nil,       -- 下注的倍率(加)
    button_PlusRate = nil,      -- 下注的倍率(加)
    button_MinusTime = nil,     -- 下注的次数(减)
    button_PlusTime = nil,      -- 下注的次数(加)
    button_BetType = {},        -- 下注的类型
    button_BetTypeSmall = {},   -- 下注的类型
}
-- 左侧小灯泡
local light_Left = {};
-- 中间小灯泡
local light_Middle = {};
-- 右侧小灯泡
local light_Right = {};
-- 小灯泡(暗)
local light_Off = nil;
-- 小灯泡(亮)
local light_On = nil;
-- Logo
local logo = {};
-- 本局是否下注
local isBet = false;
-- 奖金池
local text_BonusPool = nil;
-- 下注倍率显示
local text_BetRate = nil;
-- 下注次数显示
local text_BetTime = nil;
-- "游戏即将开始"Text文本
local text_Wait = nil;
-- 房间人数
local text_RoomPlayerCount = 0;
-- 下注区
local betArea = {
    PlayerBetData = {},     -- 玩家下注的信息
    AllBetData = {},        -- 所有玩家下注的信息
    betBtn = {},            -- 下注按钮
};
local betRate = 1;                  -- 默认的下注比例
local betTime = 1;                  -- 默认的下注次数
local isTwinkle = true;             -- 是否开启常态显示效果
local isChangeLight = true;         -- 是否切换灯泡图片(灯泡闪烁效果))
local speed_Twinkle_Light = 0.2;    -- 灯泡闪烁的速度
local speed_Twinkle_Logo = 1.8;     -- Logo闪烁的速度
local time_Twinkle_Light = 0;       -- 计时器(灯泡闪烁的速度)
local time_Twinkle_Logo = 0;        -- 计时器(Logo闪烁的速度)
--endregion
--region ========= ( 获取物体及其组件 )
-- 获取常态Logo动画物体及其组件
function TTC_V.GetNormalStateObjects(this)
    for index = 1, 10 do
        logo[index] = this.transform:Find("Canvas/Window/Logo/Logo_"..index).gameObject;
    end
end

-- 获取 "开始下注" 动画物体及其组件
function TTC_V.GetStartBetAnimationObjects(this)
    local tempLocalPosition1 = this.transform:Find("Canvas/PeopleAnimationPosition1").localPosition;
    local tempLocalPosition2 = this.transform:Find("Canvas/PeopleAnimationPosition2").localPosition;
    point1 = CS.UnityEngine.Vector3(tempLocalPosition1.x, tempLocalPosition1.y, 0);
    point2 = CS.UnityEngine.Vector3(tempLocalPosition2.x, tempLocalPosition2.y, 0);
    ani_Left.RootObj = this.transform:Find("Canvas/Ani_Left").gameObject;
    ani_Left.RootObj_TP = this.transform:Find("Canvas/Ani_Left"):GetComponent("TweenPosition");
    ani_Left.Girl = this.transform:Find("Canvas/Ani_Left/girl");
    ani_Left.Shou = this.transform:Find("Canvas/Ani_Left/Shou");
    ani_Left.Shou_TR = this.transform:Find("Canvas/Ani_Left/Shou"):GetComponent("TweenRotation");
    ani_Left.Shou_Hand = this.transform:Find("Canvas/Ani_Left/Shou/hand")
    ani_Left.Shou_HandTR = this.transform:Find("Canvas/Ani_Left/Shou/hand"):GetComponent("TweenRotation");
    ani_Right.RootObj = this.transform:Find("Canvas/Ani_Right").gameObject;
    ani_Right.RootObj_TP = this.transform:Find("Canvas/Ani_Right"):GetComponent("TweenPosition");
end

-- 获取结算动画物体及其组件
function TTC_V.GetSettlementObjects(this)
    local tempPath = "Canvas/Window/Settlement";
    settlement.RootObj = this.transform:Find(tempPath).gameObject;
    settlement.Mask = this.transform:Find(tempPath.."/Mask").gameObject;
    settlement.PokerBack = this.transform:Find(tempPath.."/Show_Poker_Bg/Poker"):GetComponent("Image");
    settlement.Poker = {};
    for index = 1, 3 do
        settlement.Poker[index] = this.transform:Find(tempPath.."/Show_Poker_Bg/Poker_"..index):GetComponent("Image");
    end
    settlement.Star = {};
    settlement.TS_Star = {};
    settlement.TA_Star = {};
    settlement.TR_Star = {};
    for index = 1, 7 do
        settlement.Star[index] = this.transform:Find(tempPath.."/Star/Star_"..index);
        settlement.TS_Star[index] = settlement.Star[index]:GetComponent("TweenScale");
        settlement.TA_Star[index] = settlement.Star[index]:GetComponent("TweenAlpha");
        settlement.TR_Star[index] = settlement.Star[index]:GetComponent("TweenRotation");
    end
    settlement.Text_Result = {};
    settlement.TS_Result = {};
    tempPath = "Canvas/Window/Settlement/Show_Poker_Head/Result_Text_";
    for index = 1, 6 do
        settlement.Text_Result[index] = this.transform:Find(tempPath..index).gameObject;
        settlement.TS_Result[index] = this.transform:Find(tempPath..index):GetComponent("TweenScale");
    end
end

-- 获取奖励面板物体及其组件
function TTC_V.GetRewardsObjects(this)
    local tempPath = "Canvas/Panel2/Canvas/RewardInterface/Reward"
    rewards.RootObj = this.transform:Find("Canvas/Panel2/Canvas/RewardInterface").gameObject;
    rewards.GoldCount = this.transform:Find( tempPath.."/Text"):GetComponent("Text");
    rewards.ClosePanelBtn = this.transform:Find("Canvas/Panel2/Canvas/RewardInterface"):GetComponent("Button");
    rewards.ParticleEffect = this.transform:Find("Canvas/Panel1/Canvas/jingbipengse/01").gameObject;
end

-- 获取按钮
function TTC_V.GetButtons(this)
    buttons.button_Close = this.transform:Find("Canvas/Window/Top/CloseBtn"):GetComponent("Button");                        -- 退出按钮
    buttons.button_Shop = this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_First"):GetComponent("Button");        -- 【商城】按钮
    buttons.button_RankList = this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_Second"):GetComponent("Button");   -- 【排行榜】按钮
    buttons.button_Help = this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_Third"):GetComponent("Button");        -- 【帮助】按钮
    buttons.button_CloseHelp = this.transform:Find("Canvas/Window_Help/Title/Button_Close"):GetComponent("Button");         -- 【帮助】关闭按钮
    buttons.button_MaskHelp = this.transform:Find("Canvas/Window_Help/Mask_Help"):GetComponent("Button");                   -- 【帮助】遮罩按钮
    buttons.button_PlayerList = this.transform:Find("Canvas/Window/Button_PlayerList"):GetComponent("Button");              -- 【玩家列表】按钮
    buttons.button_MinusRate = this.transform:Find("Canvas/Window/Content/Button/One/Cut1"):GetComponent("Button");         -- 减少投注倍率
    buttons.button_AddRate = this.transform:Find("Canvas/Window/Content/Button/One/Number"):GetComponent("Button");    -- 增加投注倍率
    buttons.button_PlusRate = this.transform:Find("Canvas/Window/Content/Button/One/Add1"):GetComponent("Button");          -- 增加投注倍率
    buttons.button_MinusTime = this.transform:Find("Canvas/Window/Content/Button/Two/Cut2"):GetComponent("Button");         -- 减少次数
    buttons.button_PlusTime = this.transform:Find("Canvas/Window/Content/Button/Two/Add2"):GetComponent("Button");          -- 增加次数
    for index = 1, 6 do
        buttons.button_BetType[index] = this.transform:Find("Canvas/Window/Content/Boundary/Right/Image"..index):GetComponent("Button");
        buttons.button_BetTypeSmall[index] = this.transform:Find("Canvas/Window/Content/Boundary/Right/Image"..index.."/Image_Button"):GetComponent("Button");
    end
end

-- 获取时时彩界面显示物体及其组件
function TTC_V.GetDisplayObjects(this)
    -- 奖金池显示Text
    text_BonusPool = this.transform:Find("Canvas/Window/Title/BigNumber/Text"):GetComponent("Text");
    -- 我的金币显示Text
    text_MyGoldCount = this.transform:Find("Canvas/Window/CoinAcount/Acount"):GetComponent("Text");
    -- 倒计时
    text_Countdown = this.transform:Find("Canvas/Window/Content/TimeNumber/Text1"):GetComponent("Text");
    -- 帮助界面
    window_Help.RootObj = this.transform:Find("Canvas/Window_Help").gameObject;
    window_Help.Mask_Help = this.transform:Find("Canvas/Window_Help/Mask_Help").gameObject;
    -- 下注的倍率
    text_BetRate = this.transform:Find("Canvas/Window/Content/Button/One/Number/Text"):GetComponent("Text");
    -- 下注的次数
    text_BetTime = this.transform:Find("Canvas/Window/Content/Button/Two/Text"):GetComponent("Text");
    -- "游戏即将开始"Text文本
    text_Wait = this.transform:Find("Canvas/Window/Text_Wait").gameObject;
    -- "上次豹子时间"
    baoZiPanel.Hour = this.transform:Find("Canvas/Window/Content/Boundary/baozhiTime/Hour"):GetComponent("Text");
    baoZiPanel.Minute = this.transform:Find("Canvas/Window/Content/Boundary/baozhiTime/Minute"):GetComponent("Text");
    -- "上轮大赢家"
    lastWinnerPanel.GoldCount = this.transform:Find("Canvas/Window/Content/Boundary/Player/Gold/Number"):GetComponent("Text");
    lastWinnerPanel.RoleIcon = this.transform:Find("Canvas/Window/Content/Boundary/Player/RoleIcon"):GetComponent("Image");
    lastWinnerPanel.VipLevel = this.transform:Find("Canvas/Window/Content/Boundary/Player/RoleIcon/Vip/Value"):GetComponent("Text");
    lastWinnerPanel.RoleName = this.transform:Find("Canvas/Window/Content/Boundary/Player/RoleName"):GetComponent("Text");
    -- 房间人数
    text_RoomPlayerCount = this.transform:Find("Canvas/Window/Button_PlayerList/Text"):GetComponent("Text");
    --下注区
    betArea.PlayerBetData = {};
    betArea.AllBetData = {};
    for index = 1, 6 do
        betArea.PlayerBetData[index] = this.transform:Find("Canvas/Window/Content/Boundary/Right/Image"..index.."/Text2"):GetComponent("Text");
        betArea.AllBetData[index] = this.transform:Find("Canvas/Window/Content/Boundary/Right/Image"..index.."/Text3"):GetComponent("Text");
    end
    -- 历史开牌结果
    resultHistory.Content = this.transform:Find("Canvas/Window/Content/Content");
    resultHistory.Text_New = this.transform:Find("Canvas/Window/Content/Content/New").gameObject;
    resultHistory.Chips = {};
    resultHistory.Text_Result = {};
    for index = 1, 24 do
        resultHistory.Chips[index] = this.transform:Find("Canvas/Window/Content/Content/Chip"..index).gameObject;
        resultHistory.Text_Result[index] = this.transform:Find("Canvas/Window/Content/Content/Chip"..index.."/Text"):GetComponent("Text");
    end
end
--endregion
function TTC_V.PlaySoundEffect(musicID)
    if musicID ~= nil  then
        MusicMgr:PlaySoundEffect(tostring(musicID));
    end
end

-- 获取所有物体
function TTC_V.GetAllObjects(this)

    -- 获取常态灯光效果动画物体及其组件
    TTC_V.GetNormalStateObjects(this);
    -- 获取 "开始下注" 动画物体及组件
    TTC_V.GetStartBetAnimationObjects(this);
    -- 获取结算动画物体及其组件
    TTC_V.GetSettlementObjects(this);
    -- 获取奖励面板显示物体及其组件
    TTC_V.GetRewardsObjects(this);
    -- 获取按钮
    TTC_V.GetButtons(this);
    -- 时时彩界面显示物体
    TTC_V.GetDisplayObjects(this);

end

-- 关闭 "时时彩" 界面
function TTC_V.CloseWindow()
    NetMsgHandler.QuitLottery();
end

-- 打开 【商城】 界面
function TTC_V.OpenStoreWindow()
    GameConfig.OpenStoreUI();
end

-- 是否读取本地排行榜信息
function TTC_V.JudgmentTimeInterval(windowData)
    if GameData.RankInfo.SscRankTime == 0 then
        return true;
    end
    local time1 = os.time();
    if time1 - GameData.RankInfo.SscRankTime >= 60 then
        return true;
    end
    return false;
end

-- 打开 【排行榜】 界面  【TRUE】
function TTC_V.OpenRankListWindow()
    local initParam = CS.WindowNodeInitParam("UIRoomRank");
    initParam.WindowData = GAME_RANK_TYPE.SSC_MONEY;
    CS.WindowManager.Instance:OpenWindow(initParam);
    if TTC_V.JudgmentTimeInterval(GAME_RANK_TYPE.SSC_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.SSC_MONEY);
    end
end

-- 打开 【帮助】 界面
function TTC_V.OpenHelpWindow(state)
    GameObjectSetActive(window_Help.RootObj, state);
end

-- 打开 【玩家列表】 界面
function TTC_V.OpenPlayerListWindow()
    local initParam = CS.WindowNodeInitParam("UIRoomPlayers");
    initParam.WindowData = 5;
    CS.WindowManager.Instance:OpenWindow(initParam);
end

-- 倒计时刷新
function TTC_V.RefreshCountdown()
    if temp_Countdown ~= GameData.LotteryInfo.CountDown then
        text_Countdown.text = ""..math_Floor(GameData.LotteryInfo.CountDown)
        temp_Countdown = GameData.LotteryInfo.CountDown;
    end
end

-- 改变下注的倍率
function TTC_V.ChangeRate(type)
    -- 0:减 1:加
    if type == 0 then
        betRate = ((betRate < 2) and {4} or {betRate-1})[1];
    elseif type == 1 then
        betRate = ((betRate > 3) and {1} or {betRate+1})[1];
    else
    end
    GameData.LotteryInfo.BetNumber = data.ShishicaiConfig.BET_GOLD[betRate];
    text_BetRate.text = ""..GameData.LotteryInfo.BetNumber;
end

-- 改变下注的次数
function TTC_V.ChangeTime(type)
    if type == 0 then
        betTime = ((betTime < 2) and {3} or {betTime-1})[1];
    elseif type == 1 then
        betTime = ((betTime > 2) and {1} or {betTime+1})[1];
    else
    end
    print("--------------betTime_______________", betTime);
    GameData.LotteryInfo.DoubleNumber = data.ShishicaiConfig.BET_NUMBER[betTime];
    text_BetTime.text = ""..GameData.LotteryInfo.DoubleNumber;
end

-- 玩家下注事件
function TTC_V.BetClicked(index)
    TTC_V.PlaySoundEffect("5");
    if GameData.LotteryInfo.NowState ~= 0 then
        CS.BubblePrompt.Show(data.GetString("开奖时间无法下注"), "TimeTimeColor");
    else
        GameData.LotteryInfo.Bet_Button_Type = index;
        GameData.LotteryInfo.MyBet_Gold = GameData.LotteryInfo.BetNumber * GameData.LotteryInfo.DoubleNumber * 10000;
        NetMsgHandler.LotteryForBet();
    end
end

-- 添加点击事件
function TTC_V.AddClickEvents()
    buttons.button_Close.onClick:AddListener(TTC_V.CloseWindow);                      -- 退出时时彩界面
    buttons.button_Shop.onClick:AddListener(TTC_V.OpenStoreWindow);                   -- 打开【商城】界面
    buttons.button_RankList.onClick:AddListener(TTC_V.OpenRankListWindow);            -- 打开【排行榜】界面
    buttons.button_MaskHelp.onClick:AddListener(TTC_V.CloseHelpWindow);               -- 关闭【帮助】界面
    buttons.button_PlayerList.onClick:AddListener(TTC_V.OpenPlayerListWindow);        -- 打开【玩家列表】界面
    rewards.ClosePanelBtn.onClick:AddListener(TTC_V.CloseReewardWindow);
    buttons.button_Help.onClick:AddListener(function()
        TTC_V.OpenHelpWindow(true);                                            -- 打开【帮助】界面
    end);
    buttons.button_CloseHelp.onClick:AddListener(function ()
        TTC_V.OpenHelpWindow(false);                                           -- 关闭【帮助】界面
    end);
    buttons.button_MinusRate.onClick:AddListener(function()                           -- 减少下注倍率
        TTC_V.ChangeRate(0);
    end);
    buttons.button_AddRate.onClick:AddListener (function()                            -- 增加下注倍率
        TTC_V.ChangeRate(1);
    end);
    buttons.button_PlusRate.onClick:AddListener(function()                            -- 增加下注倍率
        TTC_V.ChangeRate(1);
    end);
    buttons.button_MinusTime.onClick:AddListener(function()                           -- 减少下注次数
        TTC_V.ChangeTime(0);
    end);
    buttons.button_PlusTime.onClick:AddListener(function()                            -- 增加下注次数
        TTC_V.ChangeTime(1);
    end);
    for index = 1, 6 do                                                               -- 下注
        buttons.button_BetType[index].onClick:AddListener(function()
            TTC_V.BetClicked(index);
        end);
    end
    for index = 1, 6 do                                                               -- 下注
        buttons.button_BetTypeSmall[index].onClick:AddListener(function()
            TTC_V.BetClicked(index);
        end);
    end
end

-- Logo的闪烁效果 【TRUE】
function TTC_V.LogoTwinkle(this)
    for index = 1, 10 do
        this:DelayInvoke(index*0.1, function()
            logo[index]:SetActive(true);
        end)
    end
    for index = 1, 2 do
        this:DelayInvoke(1 + 0.2*index, function ()
            for k = 1, 7 do
                logo[k].gameObject:SetActive(false);
            end
        end)
        this:DelayInvoke(1.1 + 0.2*index, function ()
            for  k = 1, 7 do
                logo[k].gameObject:SetActive(true);
            end
        end)
    end
    this:DelayInvoke(1.6, function()
        for index = 1, 10 do
            logo[index].gameObject:SetActive(false);
        end
    end)
end

-- 开始投注动画   【TRUE】
function TTC_V.Animation_StartBet(this)
    TTC_V.PlaySoundEffect("35");
    -- 左侧
    GameObjectSetActive(ani_Left.RootObj, true);
    ani_Left.RootObj_TP.from = point1;
    ani_Left.RootObj_TP.to = point2;
    ani_Left.RootObj_TP.duration = 2;
    ani_Left.RootObj_TP:ResetToBeginning();
    ani_Left.RootObj_TP:Play(true);

    this:DelayInvoke(0.4, function()
        ani_Left.Shou_TR:ResetToBeginning();
        ani_Left.Shou_TR:Play(true);
    end)
    this:DelayInvoke(0.45, function()
        ani_Left.Shou_HandTR:ResetToBeginning();
        ani_Left.Shou_HandTR:Play(true);
    end)

    -- 右侧
    GameObjectSetActive(ani_Right.RootObj, true);
    ani_Right.RootObj_TP.from = point2;
    ani_Right.RootObj_TP.to = point1;
    ani_Right.RootObj_TP.duration = 2;
    ani_Right.RootObj_TP:ResetToBeginning();
    ani_Right.RootObj_TP:Play(true);
    this:DelayInvoke(2, function()
        ani_Left.RootObj_TP:ResetToBeginning();
        ani_Left.Shou_TR:ResetToBeginning();
        ani_Left.Shou_HandTR:ResetToBeginning();
        ani_Right.RootObj_TP:ResetToBeginning();
        GameObjectSetActive(ani_Left.RootObj, false);
        GameObjectSetActive(ani_Right.RootObj, false);
    end)
end

-- 【上次豹子时间】显示
function TTC_V.Display_LastBaoZiInfo()
    local lastTime = GameData.LotteryInfo.LastBaoziTime;
    if lastTime > 359999 then
        lastTime = 359999;
    end
    local minute = math_Floor((lastTime % 3600) / 60 );
    local hour = math_Floor(lastTime / 3600)
    baoZiPanel.Hour.text = ((hour > 9) and { ""..hour } or {"0"..hour})[1];
    baoZiPanel.Minute.text = ( (minute > 9) and {""..minute} or {"0"..minute})[1];
end

-- 【上轮大赢家】显示
function TTC_V.Display_LastWinnerInfo()
    lastWinnerPanel.GoldCount.text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.LotteryInfo.Winner_Gold));
    lastWinnerPanel.RoleIcon:ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.LotteryInfo.WinnerID));
    lastWinnerPanel.VipLevel.text = "VIP"..GameData.LotteryInfo.WinnerVipLevel;
    lastWinnerPanel.RoleName.text = GameData.LotteryInfo.WinnerStrLoginIP;
end
-- 关闭奖励面板
function TTC_V.CloseReewardWindow()
    GameObjectSetActive(rewards.RootObj, false);
end

-- 刷新下注区和彩金池的数量
function TTC_V.RefreshBetAreaAndBonusPool()
    local flag = buttons.button_Close.interactable;
    local tempData = 0;
    for index = 1, 6 do
        -- 玩家个人下注信息
        tempData = GameConfig.GetFormatColdNumber(GameData.LotteryInfo.myBet[index]);
        betArea.PlayerBetData[index].text = ((tempData ~= nil) and {""..lua_NumberToStyle1String(tempData)} or {"0"})[1]
        if tempData ~= nil and tempData > 0 then
            flag = false;
        end
        -- 所有玩家下注信息
        tempData = GameConfig.GetFormatColdNumber(GameData.LotteryInfo.Bet[index]);
        betArea.AllBetData[index].text = ((tempData ~= nil) and {""..lua_NumberToStyle1String(tempData)} or {"0"})[1];
    end
    if buttons.button_Close.interactable == true then
        buttons.button_Close.interactable = flag;
    end
    --奖金池
    text_BonusPool.text = string.format('%.2f', GameConfig.GetFormatColdNumber(GameData.LotteryInfo.GoldPool));
end

-- 清空下注区
function TTC_V.RefreshBetArea()
    for index = 1, 6 do
        -- 玩家个人下注信息
        betArea.PlayerBetData[index].text = "0"
        -- 所有玩家下注信息
        betArea.AllBetData[index].text = "0";
    end
end

-- 【停止下注】显示文本  播放音效
function TTC_V.ShowStopBet(this)
    CS.BubblePrompt.Show(data.GetString("Tip_Stop_Bet"), "TimeTimeColor");
    isBet = false;
    local tempData = nil;
    for index = 1, 6 do
        tempData = GameData.LotteryInfo.myBet[index];
        if tempData ~= nil and tempData > 0 then
            isBet = true;
        end
    end
    TTC_V.PlaySoundEffect("36");
    if not isBet then
        this:DelayInvoke(1, function ()
            TTC_V.PlaySoundEffect("37");
        end)
    end
end

-- 刷新开牌结果 (只显示最新三十轮)
function TTC_V.RefreshResultHistory()
    if GameData.LotteryInfo.OpenCardNum ~= nil then
        local count = GameData.LotteryInfo.OpenCardNum;
        if count <= 23 then
            for index = count + 1, 24 do
                resultHistory.Text_Result[index].text = "";
                GameObjectSetActive(resultHistory.Chips[index], false);
            end
        end
        for index = 1, count do
            if resultHistory.Chips[index] ~= nil then
                GameObjectSetActive(resultHistory.Chips[index], true);
                local resultNum = GameData.LotteryInfo.OpenCardHistory[index];
                resultHistory.Text_Result[index].text = ""..data.ShishicaiConfig.HISTORY_TYPE[resultNum];
            end
        end
        CS.Utility.ReSetTransform(resultHistory.Text_New.transform, resultHistory.Chips[count].transform);
        GameObjectSetActive(resultHistory.Text_New, true);
    end

end

-- 开奖动画
function TTC_V.Animation_OpenCard(this)
    text_Countdown.text = "";
    for index = 1, 3 do
        settlement.Poker[index]:ResetSpriteByName("sprite_Poker_Back_01");
    end
    for index = 1, 7 do
        GameObjectSetActive(settlement.Star[index].gameObject, false);
    end
    GameObjectSetActive(settlement.RootObj, true);
    for index = 1, 3 do
        this:DelayInvoke(index * 0.5, function()
            TTC_V.PlaySoundEffect("4");
            local pokerColor = GameData.LotteryInfo.PokerColor[index];    -- 牌的花色
            local pokerNumber = GameData.LotteryInfo.PokerSize[index];  -- 牌的大小
            local spriteName = GameData.GetLotteryPokerSpriteName(pokerColor, pokerNumber);
            settlement.Poker[index]:ResetSpriteByName(""..spriteName);
        end)
    end
    local tempPokerType = GameData.LotteryInfo.Victory_Card_Type;
    -- 字体缩小
    this:DelayInvoke(2, function()
        local tempSoundIndex = 25 + tempPokerType;
        TTC_V.PlaySoundEffect(""..tempSoundIndex);
        settlement.Text_Result[7-tempPokerType].gameObject:SetActive(true);
        settlement.TS_Result[7-tempPokerType]:ResetToBeginning();
        settlement.TS_Result[7-tempPokerType]:Play(true);
    end)
    -- 星星闪烁
    this:DelayInvoke(2, function()
        for index = 1, 7 do
            this:DelayInvoke( 0.1 * index - 0.1, function()
                settlement.Star[index].gameObject:SetActive(true);
                settlement.TS_Star[index]:ResetToBeginning();
                settlement.TA_Star[index]:ResetToBeginning();
                settlement.TR_Star[index]:ResetToBeginning();
                settlement.TS_Star[index]:Play(true);
                settlement.TA_Star[index]:Play(true);
                settlement.TR_Star[index]:Play(true);
            end)
            this:DelayInvoke(0.1 * index + 0.3, function()
                settlement.Star[index].gameObject:SetActive(false);
            end)
        end
    end)
    -- 销毁结算特效
    this:DelayInvoke(3.6, function()
        settlement.Text_Result[7-tempPokerType].gameObject:SetActive(false);
        settlement.RootObj.gameObject:SetActive(false);
    end)
end

-- 奖励面板显示
function TTC_V.OpenRewardWindow(this)
    GameObjectSetActive(settlement.RootObj, false);
    local winGoldCount = (GameConfig.GetFormatColdNumber(GameData.LotteryInfo.Bet_Victory_Gold));
    if winGoldCount ~= nil and winGoldCount > 0 then
        if winGoldCount >= 10000 then
            winGoldCount = winGoldCount / 10000;
            rewards.GoldCount.text = "<color=#00FF00>"..lua_CommaSeperate(winGoldCount).."万</color>";
        else
            rewards.GoldCount.text = "<color=#00FF00>"..lua_CommaSeperate(winGoldCount).."</color>";
        end
        TTC_V.PlaySoundEffect("game_win");
        GameObjectSetActive(rewards.ParticleEffect, true);
        TTC_V.PlaySoundEffect("HB_Gold");
        GameObjectSetActive(rewards.RootObj, true);
        this:DelayInvoke(2, TTC_V.CloseRewardWindow);
        GameData.LotteryInfo.Bet_Victory_Gold = 0;
    else
        TTC_V.ShowWaitText(true);
    end

end

-- 显示【游戏即将开始】
function TTC_V.ShowWaitText(state)
    TTC_V.RefreshBetArea()
    buttons.button_Close.interactable = true;
    GameObjectSetActive(text_Wait, state);
end

-- 关闭奖励面板
function TTC_V.CloseRewardWindow()
    GameObjectSetActive(rewards.ParticleEffect, false);
    GameObjectSetActive(rewards.RootObj, false);
end

-- 设置下注按钮状态
function TTC_V.SetBetButtonState(state)
    for index = 1, #buttons.button_BetType do
        buttons.button_BetTypeSmall[index].interactable = state;
        buttons.button_BetType[index].interactable = state;
    end
end

-- 刷新房间玩家人数
function TTC_V.RefreshPlayerCount()
    text_RoomPlayerCount.text = ""..GameData.LotteryInfo.PlayerCount;

end

-- 刷新玩家金币数量
function TTC_V.RefreshGoldCount()
    local goldCount =GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount)
    text_MyGoldCount.text = tostring(lua_GetPreciseDecimal(goldCount,2));
end

-- 切入切出
function TTC_V.StateAndThing(state, second)
    if state == 0 then                              -- 【下注阶段】
        TTC_V.CloseRewardWindow();
        TTC_V.ShowWaitText(false);
        GameObjectSetActive(settlement.RootObj, false);
        if second < 21 and second >= 19 then
            TTC_V.SetBetButtonState(false);
            --text_Countdown.text = "";
        elseif second <= 19 and second >3 then
            TTC_V.SetBetButtonState(true);
        elseif second <= 3 then
            TTC_V.SetBetButtonState(false);
        else
        end
    elseif state == 1 then                          -- 【结算阶段】
        text_Countdown.text = "";
        if second > 2 then
            TTC_V.SetBetButtonState(false);
            TTC_V.ShowWaitText(false);
        elseif second <= 2 then
            TTC_V.SetBetButtonState(false);
        else
        end
    elseif state == 2 then                          -- 【等待阶段】
        text_Countdown.text = "";
        TTC_V.CloseRewardWindow();
        TTC_V.ShowWaitText(true);
        TTC_V.SetBetButtonState(false);
    else
    end
end

return TTC_V;