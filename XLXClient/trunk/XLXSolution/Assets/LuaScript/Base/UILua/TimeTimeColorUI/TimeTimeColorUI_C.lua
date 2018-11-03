--[[
   文件名称:TimeTimeColorUI_C.lua
   创 建 人:土豆陛下
   创建时间：2018-9-4 11:00
   功能描述：时时彩界面的Controller层
]]--

local TTC_V = require("Base/UILua/TimeTimeColorUI/TimeTimeColorUI_V");
local Time = CS.UnityEngine.Time;
local math_Floor = math.floor;
local TTC_C = {};

--region ___定义变量

local currentState = 0;         -- 当前状态
local lastTime = 0;             -- 当前状态剩余秒数
local second = 0;               -- 秒数

local time_Twinkle_Light = 0;       -- 计时器(灯泡闪烁的速度)
local time_Twinkle_Logo = 0;        -- 计时器(Logo闪烁的速度)

local isTwinkle = true;             -- 是否开启常态显示效果
local isDisplayCountdown = false;     -- 是否显示倒计时
local speed_Twinkle_Logo = 1.8;     -- Logo闪烁的速度

--endregion

-- 进入时时彩房间时对时时彩进行刷新 (进入时时彩界面时发送)
function TTC_C.InitRoomInfo()
    TTC_V.RefreshBetAreaAndBonusPool();
    TTC_V.RefreshGoldCount();       -- 刷新金币数量
    TTC_V.RefreshPlayerCount();     -- 刷新房间人数
    TTC_V.Display_LastBaoZiInfo();  -- 刷新上次豹子时间
    TTC_V.Display_LastWinnerInfo(); -- 刷新上次大赢家时间
    TTC_V.RefreshResultHistory();   -- 刷新开牌结果历史
    currentState = GameData.LotteryInfo.NowState;
    second = math_Floor(GameData.LotteryInfo.CountDown);
    TTC_V.StateAndThing(currentState, second);
    if currentState == ShiShiCai_State.BET then                                                     -- 【下注阶段】
        isDisplayCountdown = true;
        if second == ShiShiCai_StateTime.YAZHU_1 then                                               -- 播放【开始下注】动画
            TTC_V.ShowWaitText(false);
            TTC_V.Animation_StartBet(this);
        elseif second <= ShiShiCai_StateTime.YAZHU_2 and second > ShiShiCai_StateTime.YAZHU_3 then  -- 真正可投注状态
            TTC_V.SetBetButtonState(true);
        elseif second == ShiShiCai_StateTime.YAZHU_3 then                                                                     -- 停止下注
            TTC_V.SetBetButtonState(false);
            TTC_V.ShowStopBet(this);
        elseif second < ShiShiCai_StateTime.YAZHU_3 then
            TTC_V.SetBetButtonState(false);
        else
        end
    elseif currentState == ShiShiCai_State.SETTLEMENT then                                          -- 【结算阶段】
        isDisplayCountdown = false;
        if second == ShiShiCai_StateTime.JIESUAN_1 then
            TTC_V.Animation_OpenCard(this);
        elseif second == ShiShiCai_StateTime.JIESUAN_2 then
            TTC_V.OpenRewardWindow(this);
            this:DelayInvoke(2.8, function()
                TTC_V.CloseRewardWindow();
            end)
        else
        end
    elseif currentState == ShiShiCai_State.WAIT then       -- 【等待阶段】
        isDisplayCountdown = false;
        if second == ShiShiCai_StateTime.WAIT_1 then
            TTC_V.ShowWaitText(true);
        else
        end
    else

    end
end

-- 时时彩游戏阶段判定并作相应操作 (每阶段发送)
function TTC_C.RefreshRoomInfo()
    currentState = GameData.LotteryInfo.NowState;
    TTC_V.RefreshPlayerCount();                 -- 刷新房间人数
    if currentState == ShiShiCai_State.BET then                         -- 【下注阶段】
        isDisplayCountdown = true;
        TTC_V.ShowWaitText(false);
        TTC_V.Animation_StartBet(this);         -- 播放开始下注动画
    elseif currentState == ShiShiCai_State.SETTLEMENT then              -- 【结算阶段】
        for index = 1, 6 do
            GameData.LotteryInfo.myBet[index] = 0;
            GameData.LotteryInfo.Bet[index] = 0;
        end
        TTC_V.RefreshBetAreaAndBonusPool();
        isDisplayCountdown = false;
        TTC_V.Animation_OpenCard(this);         -- 开牌
        TTC_V.Display_LastBaoZiInfo();          -- 刷新上次豹子时间
        TTC_V.Display_LastWinnerInfo();         -- 刷新上次大赢家时间
        TTC_V.RefreshResultHistory();           -- 刷新开牌结果历史
    elseif currentState == ShiShiCai_State.WAIT then                    -- 【等待阶段】
        isDisplayCountdown = false;
        TTC_V.ShowWaitText(true);
    else
    end
end

-- 判断阶段并做相应阶段内的事情
function TTC_C.JudgeStateAndDoThings()
    currentState = GameData.LotteryInfo.NowState;
    if currentState == ShiShiCai_State.BET then                         -- 【下注阶段】
        if second == ShiShiCai_StateTime.YAZHU_2  then
            TTC_V.SetBetButtonState(true);
        elseif second == ShiShiCai_StateTime.YAZHU_3 then
            TTC_V.SetBetButtonState(false);
            TTC_V.ShowStopBet(this);
        else
        end

    elseif currentState == ShiShiCai_State.SETTLEMENT then              -- 【结算阶段】
        if second == ShiShiCai_StateTime.JIESUAN_2 then
            --GameData.LotteryInfo.myBet = nil;
            TTC_V.OpenRewardWindow(this);
            this:DelayInvoke(2.8, function()
                TTC_V.CloseRewardWindow();
            end)
        end
    elseif currentState == ShiShiCai_State.WAIT then                    -- 【等待阶段】

    else
    end
end

-- 刷新状态&时间
function TTC_C.RefreshTimeData()
    if currentState ~= GameData.LotteryInfo.NowState then
        currentState = GameData.LotteryInfo.NowState;
    end
    if lastTime ~= GameData.LotteryInfo.CountDown then
        lastTime = GameData.LotteryInfo.lastTime;
    end
    if second ~= math_Floor(GameData.LotteryInfo.CountDown) then
        second = math_Floor(GameData.LotteryInfo.CountDown);
        TTC_C.JudgeStateAndDoThings();
    end
end

--=================================================== ( 系统函数 )  ===================================================>>

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
    MusicMgr:StopAllSoundEffect();
    this:StopAllDelayInvoke();
    -- 获取所有物体
    TTC_V.GetAllObjects(this);
    -- 添加点击事件
    TTC_V.AddClickEvents();
    GameData.LotteryInfo.BetNumber = data.ShishicaiConfig.BET_GOLD[1];
    GameData.LotteryInfo.DoubleNumber = data.ShishicaiConfig.BET_NUMBER[1];
    TTC_C.InitRoomInfo()
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    GameData.LotteryInfo.ssc_isOpen = 1
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptLotteryInfo, TTC_C.RefreshRoomInfo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.SendTheMessageToBeSuccessful, TTC_V.RefreshBetAreaAndBonusPool)
    --CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptBetVictory,
    --function ()
    --    TTC_V.Animation_OpenCard(this);
    --end)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent,TTC_V.RefreshGoldCount)
    --CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifySscUpdateWinInfo, TTC_V.OpenRewardWindow)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, TTC_C.InitRoomInfo);
    MusicMgr:PlayBackMusic("BG_SSC")
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    GameData.LotteryInfo.ssc_isOpen = 0
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptLotteryInfo, TTC_C.RefreshRoomInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.SendTheMessageToBeSuccessful, TTC_V.RefreshBetAreaAndBonusPool)
    --CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptBetVictory, function()
    --    TTC_V.Animation_OpenCard(this)
    --end)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, TTC_V.RefreshGoldCount)
    --CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifySscUpdateWinInfo, TTC_V.OpenRewardWindow)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, TTC_C.InitRoomInfo);
    GameData.SscWinnInfo={}
    MusicMgr:StopAllSoundEffect();
    this:StopAllDelayInvoke();
    local tempObj = CS.WindowManager.Instance:FindWindowNodeByName("UIRoomPlayers")
    if tempObj ~= nil then
        CS.WindowManager.Instance:CloseWindow("UIRoomPlayers", false)
    end
end

-- 对应脚本的刷新数据方法
function RefreshWindowData(windowData)

end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    CS.MatchLoadingUI.Hide();
    GameData.GameState = GAME_STATE.ROOM;
    GameData.RoomInfo.CurrentRoom.RoomType = ROOM_TYPE.SSC;
end

-- Unity MonoBehavior Update 时调用此方法
function Update()

    -- 刷新时时彩状态时间
     TTC_C.RefreshTimeData();
    GameData.LotteryInfoCountDown(Time.deltaTime);

    --region ___Logo闪烁
    time_Twinkle_Light = time_Twinkle_Light + Time.deltaTime;
    time_Twinkle_Logo = time_Twinkle_Logo + Time.deltaTime;
    if isTwinkle then
        if time_Twinkle_Logo > speed_Twinkle_Logo then
            time_Twinkle_Logo = 0;
            TTC_V.LogoTwinkle(this);
        end
    end
    --endregion
    --region ___倒计时的显示
    if isDisplayCountdown then
        TTC_V.RefreshCountdown();
    end
    --endregion
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    lua_Call_GC();
end

--=================================================== ( 系统函数 ) ===================================================<<