local Chips_Gold=0
local Time =CS.UnityEngine.Time
local time_1=0
local time_2=0
local time_3=0
local isCopy=0
local scaleTime_1=0

local mCarWinTweenPosition = nil
local IsUpdatePlay = false
local PlayTimer = 16.3
local ShangZhuangText = nil

local GuiWei = false
local mCloseBtn = nil
-- 抽奖光圈组件
local RewardLightGameObject = nil
local RewardLightTweenPosition = nil

local  TheLevel=0

local lightTable_Run1 = {};
local lightTable_Run2 = {};

--中心时间显示
local time_Center = 0;

local flag_First_One = true;
local flag_First_Two = true;
local flag_First_Three = true;
local flag_First_Four = true;
local flag_First_Five = true;
local flag_First_Effect = true;
--是否播放停止下注提示音
local flag_First_TipsEndLottery = false;
--本局是否下注
local isBet = false;
local is_Banker = false;
local startRotate = false

--->_____________________________________TUDOU_____________________________________--->
--Unity 中的 Gameobject
local GameObject = CS.UnityEngine.GameObject;
--灯闪烁的时间
local lightTwinkleTime = 0;
--跑马灯时间
local lightRunTime1 = 0;
--跑马灯时间
local lightRunTime2 = 0;
--跑马灯的速度
local lightRunSpeed = 0;
--是否在一轮里面只运行一次
local isRunForOnce1 = true;
local isRunForOnce2 = true;
local isRunForOnce3 = true;
local isRunForOnce4 = true;
--是否进入游戏后第一次进入奔驰宝马
local isInFirst = true;
--上次中奖的位置
local last_Stay_Index = 1;
--跑马灯跑过的个数
local runCount = 0;
--倒计时Mask
local mask_Number;
--倒计时计数
local counter_Countdown;
--时间
local time_Countdown;
--可变换的灯泡
local tempSprite1;
local tempSprite2;
--透明灯泡
local light_Luncency;
--
local flag_IsRun = true;
--
local flag_Blink = false;
--是否进入待机状态
local flag_IsInStandby = true;
--时间
local time_EveryFPS = 0;
--时间All
local time_All = 0;
--抽奖的时间
local time_Lottery = 0;
--抽奖跑马灯各圈的速度
local speed_Run1;
local speed_Run2;
local speed_Run3;
local speed_Run4;
--
local flag_isBlinkY = false;

local stillBet = false;

local count = 0;

--此盘是否获胜
local isWin = false;
--是否播放[等待]
local is_First_Wait = false;
--是否短线重连
local isReconnect = false;

local distance = 0;

--玩家列表按钮
local button_PlayerList = nil;
local RoomPlayerCount = nil

-- local ifOpenHelp = true;

---------_________TUDOU_________---------

local window_Help = nil;
local button_Help = nil;
local button_Help_Close = nil;
local mask_Help = nil;
function DoHelp()
    window_Help = this.transform:Find("Canvas/Window/Window_Help");
    button_Help = this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_Third");
    button_Help_Close = this.transform:Find("Canvas/Window/Window_Help/Title/Button_Close");
    mask_Help = this.transform:Find("Canvas/Window/Mask_Help");
    button_Help:GetComponent("Button").onClick:AddListener(Window_Help_Open);
    button_Help_Close:GetComponent("Button").onClick:AddListener(Window_Help_Close);
    mask_Help:GetComponent("Button").onClick:AddListener(Window_Help_Close);
end

--打开帮助页面
function Window_Help_Open()
    PlaySoundEffect("2");
    window_Help.gameObject:SetActive(true);
    mask_Help.gameObject:SetActive(true);
end

--关闭帮助页面
function Window_Help_Close()
    PlaySoundEffect("2");
    window_Help.gameObject:SetActive(false);
    mask_Help.gameObject:SetActive(false);
end


--待机时跑马灯的速度（时间间隔）
local speed_LightRun_Standby = 0;
--待机时灯闪烁的速度（时间间隔）
local speed_OutLight_Blink = 0;
--当前的状态
local currentLevel = 0;
--当前的场次（1：初级场---2：种鸡场---3：高级场）
local currentType = 0;
--获奖界面
local mRewardInfo = {}

local canLeave = true;

local count_Gold;

--是否断线重连
local isInMiddle = false;


--粒子特效【金币喷射】
local ParticleObject = nil;




---------         外圈灯         ---------

--灯泡图片
local sprite1 = nil;
local sprite2 = nil;


--投注的车标(下注区))
local table_Button_Logo = {};
local table_Button_Image = {}
local table_Betting = {}            -- 下注信息总览

--外圈灯泡  Table
local table_Light_Outside = {}
local table_Light_Outside_Image = {}
--外圈灯泡  Table1
local table_Light_Outside1 = {};
--外圈灯泡  Table2
local table_Light_Outside2 = {};
--灯光位置 index  Table
local table_Light_Index = {};
--跑马灯 & 拖尾  Table
local table_Light_Run = {};
--跑马灯 & 拖尾  Table
local table_RunLight_TP = {};
--LOGO坐标
local table_Logo_Position = {};
--暂时亮的灯的表
local table_Light_Temp = {};
--倒计时资源表
local table_Countdown_Animation = {};
--倒计时物体表
local table_Countdown_GameObject = {};
--倒计时数字变形表
local table_Countdown_TweenScale = {};
--倒计时渐隐表
local table_Countdown_Alpha = {};
--抽奖时跑马灯拖尾灯 Index
local table_Index_OutTuoWei = {};
--抽奖时跑马灯拖尾灯
local table_Light_OutTuoWei = {};
--筹码
local table_ChouMa = {};

--闪烁时长
local time_Blink = 0;
local time_Blink_bool = true;
--黄框闪烁的次数
local count_Blink = 0;
--抽奖是否第一次进入
local isFirstInLottery = true;

--倒计时
local flag_Countdown_1 = true;
local flag_Countdown_2 = true;
local flag_Countdown_3 = true;

---------         内圈灯         ---------

--待机灯1   &   TweenPosition组件
local light_Standby1_1, standby1_1_TP;
local light_Standby1_2, standby1_2_TP;
--待机灯2   &   TweenPosition组件
local light_Standby2_1, standby2_1_TP;
local light_Standby2_2, standby2_2_TP;
--待机灯3   &   TweenPosition组件
local light_Standby3_1, standby3_1_TP;
local light_Standby3_2, standby3_2_TP;
--待机灯4   &   TweenPosition组件
local light_Standby4_1, standby4_1_TP;
local light_Standby4_2, standby4_2_TP;

--抽奖跑马灯    &   TweenPosition组件
local light_Run_1,  run_1_TP;
local light_Run_2,  run_2_TP;
local light_Run_3,  run_3_TP;

--灯光效果  &   拖尾效果 位置
local index_Standby1_1;
local index_Standby1_2;
local index_Standby1_3;
local index_Standby2_1;
local index_Standby2_2;
local index_Standby2_3;
local index_Standby3_1;
local index_Standby3_2;
local index_Standby4_1;
local index_Standby4_2;
local index_Run_1;
local index_Run_2;
local index_Run_3;

----------   结算特效   ----------
local table_Obj_Star = {};
local table_Obj_Ribbon = {};
local table_Card_Red = {};
local table_Card_Yellow = {};
local table_Card_Green = {};
local table_Card_Blue = {};
local Mask_Settlement = {};
local Sunshine_Outside;
local Sunshine_Inside;
local Settlement;
local centerPosition;
local table_Position_Settlement = {};
local table_Position_Star = {};
local table_Position_Ribbon = {};
local table_Logo_Sprite = {};
local Img_Logo;
local tempTime1 = 0;
local tempTime2 = 0;

--是否第一次开始待机跑马灯
local flag_IsStandbyFirst;
--是否第一次开始抽奖跑马灯
local flag_IsLotteryFirst;
--跑马灯圈数
local lapCount = -1;

--上次停留的位置    &   TweenPosition组件
local light_Stay, light_Stay_TweenAlpha, light_Stay_Image
local light_Stay_Blink, light_Stay_Blink_TweenAlpha, light_Stay_Blink_Image

--获取待机时的灯以及相应组件
--获取抽奖时的灯以及相应组件
function GetLights_Outside()

    local tempPath = "Canvas/Window/Content/Center/LightAll/";

    --待机灯1   &   TweenPosition组件
    light_Standby1_1 = this.transform:Find(tempPath.."Standby1_1");
    light_Standby1_2 = this.transform:Find(tempPath.."Standby1_2");

    --待机灯2   &   TweenPosition组件
    light_Standby2_1 = this.transform:Find(tempPath.."Standby2_1");
    light_Standby2_2 = this.transform:Find(tempPath.."Standby2_2");

    --待机灯3   &   TweenPosition组件
    light_Standby3_1 = this.transform:Find(tempPath.."Standby3_1");
    light_Standby3_2 = this.transform:Find(tempPath.."Standby3_2");

    --待机灯4   &   TweenPosition组件
    light_Standby4_1 = this.transform:Find(tempPath.."Standby4_1");
    light_Standby4_2 = this.transform:Find(tempPath.."Standby4_2");

    --跑马灯
    light_Run_1 = this.transform:Find(tempPath.."Run_1");
    light_Run_2 = this.transform:Find(tempPath.."Run_2");
    light_Run_3 = this.transform:Find(tempPath.."Run_3");

    --标记位（上次中奖的位置)
    light_Stay = this.transform:Find(tempPath.."Stay_Light")
    light_Stay_TweenAlpha = light_Stay:GetComponent("TweenAlpha")
    light_Stay_Image = light_Stay:GetComponent("Image")
    light_Stay_Blink = this.transform:Find(tempPath.."Stay_Light_Blink");
    light_Stay_Blink_TweenAlpha = light_Stay_Blink:GetComponent("TweenAlpha")
    light_Stay_Blink_Image = light_Stay_Blink:GetComponent("Image")
    
end

local tempSprite = 0;

--获取投注的车标+下注信息
function GetButtons_Logo()
    local tempPath = "Canvas/Window/Content/Button/Car/bc_btn_xz_";
    for k = 1, 8 do
        table_Button_Logo[k] = this.transform:Find(tempPath..k.."_Button"):GetComponent("Button");
        table_Button_Image[k] = this.transform:Find("Canvas/Window/Content/Button/Car/bc_btn_xz_"..k.."_Button"):GetComponent("Image")
        table_Betting[k] = {}
        table_Betting[k].Mine = this.transform:Find(tempPath..k..'/Num_All_xz_'..k):GetComponent("Text")
        table_Betting[k].AllBet = this.transform:Find(tempPath..k..'/Num_SoAll_xz_'..k):GetComponent("Text")
    end
end

--获取外圈的灯泡 并  添加到表中
function GetLights_Inside()

    local tempPath = "Canvas/Window/Content/Boundary/bc_ic_";
    sprite1 = this.transform:Find("Canvas/Window/Content/Boundary/dengpao1").transform:GetComponent("Image").sprite;
    sprite2 = this.transform:Find("Canvas/Window/Content/Boundary/dengpao2").transform:GetComponent("Image").sprite;

    tempSprite1 = sprite1;
    tempSprite2 = sprite2;
    --遍历将灯泡存储到灯泡Table里面
    for index = 2, 22 do
        if index == 7 or index == 12 or index == 18 then
            local tempObj1 = this.transform:Find(tempPath..index.."/Image1");
            local tempObj2 = this.transform:Find(tempPath..index.."/Image2");
            local tImage1 = tempObj1:GetComponent("Image")
            local tImage2 = tempObj2:GetComponent("Image")
            
            table.insert(table_Light_Outside, tempObj1);
            table.insert(table_Light_Outside, tempObj2);
            table.insert(table_Light_Outside1, tempObj1);
            table.insert(table_Light_Outside2, tempObj2);

            table.insert(table_Light_Outside_Image, tImage1);
            table.insert(table_Light_Outside_Image, tImage2);
        else
            local tempObj = this.transform:Find(tempPath..index.."/Image");
            local tImage1 = tempObj:GetComponent("Image")
            table.insert(table_Light_Outside, tempObj);
            table.insert(table_Light_Outside1, tempObj);
            table.insert(table_Light_Outside_Image, tImage1);
        end
    end
    local tempHead = this.transform:Find(tempPath.."1/Image1");
    local tempTail = this.transform:Find(tempPath.."1/Image2");
    local tImage1 = tempHead:GetComponent("Image")
    local tImage2 = tempTail:GetComponent("Image")
    table.insert(table_Light_Outside, 1, tempHead);
    table.insert(table_Light_Outside1, 1, tempHead);
    table.insert(table_Light_Outside, tempTail);
    table.insert(table_Light_Outside2, 1, tempTail);
    table.insert(table_Light_Outside_Image, tImage1);
    table.insert(table_Light_Outside_Image, tImage2);

end
--获取二十二个车标的坐标
function GetLogoPosition()
    local tempPath = "Canvas/Window/Content/Boundary/bc_ic_";
    for k = 1, 22 do
        table_Logo_Position[k] = this.transform:Find(tempPath..k).localPosition;
        table_Logo_Sprite[k] = this.transform:Find(tempPath..k):GetComponent("Image").sprite;
    end
end

--获取结算特效的物体
function GetSettlementGameObjects()
    Settlement = this.transform:Find("Canvas/Window/Settlement");
    local tempPath = "Canvas/Window/Settlement/";
    for k = 1, 8 do
        local tempObj = this.transform:Find(tempPath.."Img_Star"..k);
        table.insert(table_Obj_Star, tempObj);
    end
    for k = 1, 2 do
        local tempObj = this.transform:Find(tempPath.."Img_Red"..k);
        table.insert(table_Card_Red, tempObj);
    end
    for k = 1, 2 do
        local tempObj = this.transform:Find(tempPath.."Img_Yellow"..k);
        table.insert(table_Card_Yellow, tempObj);
    end
    for k = 1, 2 do
        local tempObj = this.transform:Find(tempPath.."Img_Green"..k);
        table.insert(table_Card_Green, tempObj);
    end
    for k = 1, 2 do
        local tempObj = this.transform:Find(tempPath.."Img_Blue"..k);
        table.insert(table_Card_Blue, tempObj);
    end
    table.insert(table_Obj_Ribbon, table_Card_Green[1]);
    table.insert(table_Obj_Ribbon, table_Card_Red[1]);
    table.insert(table_Obj_Ribbon, table_Card_Red[2]);
    table.insert(table_Obj_Ribbon, table_Card_Green[2]);
    table.insert(table_Obj_Ribbon, table_Card_Yellow[1]);
    table.insert(table_Obj_Ribbon, table_Card_Blue[1]);
    table.insert(table_Obj_Ribbon, table_Card_Yellow[2]);
    table.insert(table_Obj_Ribbon, table_Card_Blue[2]);
    Sunshine_Outside = this.transform:Find(tempPath.."OutImg2");
    Sunshine_Inside = this.transform:Find(tempPath.."OutImg1");
    Img_Logo = this.transform:Find(tempPath.."Image");
    Mask_Settlement = this.transform:Find(tempPath.."SettlementMask");

    GameObjectSetActive(Settlement.gameObject, false)
end

--将 位置标签 index 添加入表中
function InsertTableIndex()
    table.insert( table_Light_Index, index_Standby1_1);
    table.insert( table_Light_Index, index_Standby1_2);
    table.insert( table_Light_Index, index_Standby1_3);
    table.insert( table_Light_Index, index_Standby2_1);
    table.insert( table_Light_Index, index_Standby2_2);
    table.insert( table_Light_Index, index_Standby2_3);
    table.insert( table_Light_Index, index_Standby3_1);
    table.insert( table_Light_Index, index_Standby3_2);
    table.insert( table_Light_Index, index_Standby4_1);
    table.insert( table_Light_Index, index_Standby4_2);
    table.insert( table_Light_Index, index_Run_1);
    table.insert( table_Light_Index, index_Run_2);
    table.insert( table_Light_Index, index_Run_3);
end

--将 物体 添加入  表中
function InsertTableGameObject()
    table.insert( table_Light_Run, light_Standby1_1 );
    table.insert( table_Light_Run, light_Standby1_2 );
    table.insert( table_Light_Run, light_Standby2_1 );
    table.insert( table_Light_Run, light_Standby2_2 );
    table.insert( table_Light_Run, light_Standby3_1 );
    table.insert( table_Light_Run, light_Standby3_2 );
    table.insert( table_Light_Run, light_Standby4_1 );
    table.insert( table_Light_Run, light_Standby4_2 );
    table.insert( table_Light_Run, light_Run_1 );
    table.insert( table_Light_Run, light_Run_2 );
    table.insert( table_Light_Run, light_Run_3 );
end

--将 灯泡的 TweenPosition 组件放入  表中
function InsertTableLightTP()
    table.insert( table_RunLight_TP, standby1_1_TP );
    table.insert( table_RunLight_TP, standby1_2_TP );
    table.insert( table_RunLight_TP, standby2_1_TP );
    table.insert( table_RunLight_TP, standby2_2_TP );
    table.insert( table_RunLight_TP, standby3_1_TP );
    table.insert( table_RunLight_TP, standby3_2_TP );
    table.insert( table_RunLight_TP, standby4_1_TP );
    table.insert( table_RunLight_TP, standby4_2_TP );
    table.insert( table_RunLight_TP, run_1_TP );
    table.insert( table_RunLight_TP, run_2_TP );
    table.insert( table_RunLight_TP, run_3_TP );
end

--初始化  index 等值
function Initial_Index()
    for  k = 1, 11 do
        table_Light_Index[k] = -1;
    end
    for k = 1, 3 do
        table_Index_OutTuoWei[k] = -1;
    end
    table_Light_OutTuoWei = {}

    table_Position_Star[1] = CS.UnityEngine.Vector3(0, 420, 0);
    table_Position_Star[2] = CS.UnityEngine.Vector3(-420, 30, 0);
    table_Position_Star[3] = CS.UnityEngine.Vector3(460, 30, 0);
    table_Position_Star[4] = CS.UnityEngine.Vector3(0, -420,0);
    table_Position_Star[5] = CS.UnityEngine.Vector3(-340, 360, 0);
    table_Position_Star[6] = CS.UnityEngine.Vector3(-340, -340, 0);
    table_Position_Star[7] = CS.UnityEngine.Vector3(360, -340, 0);
    table_Position_Star[8] = CS.UnityEngine.Vector3(358, 360, 0);

    table_Position_Ribbon[1] = CS.UnityEngine.Vector3(0, 420, 30);
    table_Position_Ribbon[2] = CS.UnityEngine.Vector3(460, 50, 0);
    table_Position_Ribbon[3] = CS.UnityEngine.Vector3(-420, 10, 0);
    table_Position_Ribbon[4] = CS.UnityEngine.Vector3(-340, -350, 0);
    table_Position_Ribbon[5] = CS.UnityEngine.Vector3(0, -400, 10);
    table_Position_Ribbon[6] = CS.UnityEngine.Vector3(360, -350, 0);
    table_Position_Ribbon[7] = CS.UnityEngine.Vector3(365, 370, 0);
    table_Position_Ribbon[8] = CS.UnityEngine.Vector3(-340, 370, 0);

    local tmpPath = "Canvas/Window/Window_Reward/RewardInterface"
    mRewardInfo.RootObject = this.transform:Find(tmpPath).gameObject
    mRewardInfo.RewardText = this.transform:Find(tmpPath ..'/Reward/Text'):GetComponent("Text")
    mRewardInfo.RewardObject = this.transform:Find(tmpPath..'/Reward').gameObject
    GameObjectSetActive(mRewardInfo.RootObject, false)

    ShangZhuangText = this.transform:Find('Canvas/Window/Content/Center/SonZong/Number'):GetComponent("Text");
    time_Center = this.transform:Find('Canvas/Window/Content/Center/CloseTime'):GetComponent("Text");
    count_Gold = this.transform:Find("Canvas/Window/Information/Gold/Number"):GetComponent("Text"); 
    centerPosition = Img_Logo.localPosition;
    flag_IsStandbyFirst = true;
    flag_IsLotteryFirst = true;

    lapCount = -1;
    runCount = 0;
    counter_Countdown = 0;
    count_Blink = -1;
    flag_IsRun = true;
    flag_IsInStandby = true;
    time_EveryFPS = 0;

    flag_First_One = true;
    flag_First_Two = true;
    flag_First_Three = true;
    flag_First_Four = true;
    flag_First_Five = true;
    flag_IsLotteryFirst = true;
    flag_First_Settlement = true;
    flag_First_TipsEndLottery = true;

    isWin = false;

    stillBet = true;
    local tempNum = data.BenchibaomaConfig.BET_GOLD[GameData.CarInfo.Level];
    for k = 1, 4 do
        --this.transform:Find("Canvas/Window/Content/Button/Boll/Back/Image"..k.."/Text"):GetComponent("Text").text = ""..tempNum[k];
        this.transform:Find("Canvas/Window/Content/Button/Boll/Back/Image"..k.."/Text"):GetComponent("Text").text = ""..GameData.CarInfo.ChipsValue[k];
    end
    mCloseBtn = this.transform:Find('Canvas/Window/Top/CloseBtn'):GetComponent("Button")
    mCloseBtn.interactable = true
    
    for k = 1, #GameData.CarInfo.myBet do
        local tData = GameData.CarInfo.myBet[k];
        if tData ~= nil and tData > 0 then
            mCloseBtn.interactable = false;
            break
        end
    end

    for k = 1, 11 do
        table_Light_Run[k].gameObject:SetActive(false);
        table_Light_Index[k] = -1;
    end
    distance = 0;
    --this.transform:Find("Canvas/Window/Content/Center/GameRecord/Chips/RightArrow").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Content/Center/BankerListInfo").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Number").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Mask_Help").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Window_Help").gameObject:SetActive(false);
    this.transform:Find("Canvas/Ani_Left").gameObject:SetActive(false);
    this.transform:Find("Canvas/Ani_Right").gameObject:SetActive(false);
    this.transform:Find("Canvas/jingbipengse/01").gameObject:SetActive(false);
    
    local tempPos1 = 0;
    if GameData.CarInfo.LastLotteryTarget ~= 0 then
        tempPos1 = GameData.CarInfo.LastLotteryTarget;
        -- last_Stay_Index = GameData.CarInfo.LastLotteryTarget;
    end
    light_Stay.localPosition = CS.UnityEngine.Vector3(table_Logo_Position[tempPos1].x, table_Logo_Position[tempPos1].y, 0);
    light_Stay.gameObject:SetActive(true);
    startRotate = false; 
    IsUpdatePlay = false;
end

local mText_WaitGameObject = nil
local mText_WaitText = nil
local mCDLeftText = nil
local mCDRightText = nil
--获取其他物体
function GetOtherObjects()
    ParticleObject = this.transform:Find("Canvas/jingbipengse/01");
    
    for k = 1, 4 do
        table_ChouMa[k] = this.transform:Find("Canvas/Window/Content/Button/Boll/Back/Image"..k):GetComponent("Button")
    end
    button_PlayerList = this.transform:Find("Canvas/Window/Content/Center/Button_PlayerList"):GetComponent("Button");

    mText_WaitGameObject = this.transform:Find("Canvas/Window/Text_Wait").gameObject
    mText_WaitText = this.transform:Find("Canvas/Window/Text_Wait/Text"):GetComponent("Text")
    GameObjectSetActive(mText_WaitGameObject, false)

    mCDLeftText = this.transform:Find('Canvas/Window/Content/Center/Left/Number'):GetComponent("Text")
    mCDRightText = this.transform:Find('Canvas/Window/Content/Center/Right/Number'):GetComponent("Text")
end

--获取倒计时的动画组件
function GetCountdown_Animation()
    local tempPath = "Canvas/Window/Number/Images";
    mask_Number = this.transform:Find("Canvas/Window/Number");
    for k = 1, 3 do
        table_Countdown_GameObject[k] = this.transform:Find(tempPath..k)
        table_Countdown_Animation[k] = table_Countdown_GameObject[k]:GetComponent("UGUISpriteAnimation");
        table_Countdown_TweenScale[k] = table_Countdown_GameObject[k]:GetComponent("TweenScale");
        table_Countdown_Alpha[k] = table_Countdown_GameObject[k]:GetComponent("TweenAlpha");
    end
end
-- 响应点击筹码 (A)
function ClickTheChips(index)
    --Chips_Gold=data.BenchibaomaConfig.BET_GOLD[index]
    --修改筹码 倍率
    --Chips_Gold=data.BenchibaomaConfig.BET_GOLD[currentLevel][index]
    Chips_Gold = GameData.CarInfo.ChipsValue[index]
    PlaySoundEffect('2')
    ChipsLight(index);---------------------》B
end

-- 筹码高亮 (B)
function ChipsLight(index)
    
    local tempPath = "Canvas/Window/Content/Button/Boll/Back/Image";

    for k = 1, 4 do
        this.transform:Find(tempPath..k.."/Image").gameObject:SetActive(false);    
    end

    this.transform:Find(tempPath..index.."/Image").gameObject:SetActive(true);

end

-- 响应下注按钮 (C)
function BetButtonOnClick(index)
    
    if Chips_Gold ~= 0 then
        if GameData.RoleInfo.GoldCount >= 500 then
            PlaySoundEffect('5')
            GameData.CarInfo.BetType = index;
            GameData.CarInfo.myBetGold = Chips_Gold * 10000;
            NetMsgHandler.Send_CS_Car_Bet(GameData.CarInfo.Level);
            this:DelayInvoke(0.5, function()
                count_Gold.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
            end)
        else
            CS.BubblePrompt.Show(data.GetString("Car_Bet_Error_1"),"CarRotationUI")
        end
    else
        CS.BubblePrompt.Show(data.GetString("NotChoice_Chips_1"),"CarRotationUI")
    end
end


-- 响应上庄下庄按钮 (D)
function OnBankerApply()
    PlaySoundEffect('2')
    if GameData.CarInfo.isBanker == 0 then
        NetMsgHandler.Send_CS_Car_UpperDealer(GameData.CarInfo.Level)
    else
        local boxData = CS.MessageBoxData()
        boxData.Title = "提示"
        boxData.Content = data.GetString("Down_Banker_Tips")
        boxData.Style = 2
        boxData.OKButtonName = "放弃"
        boxData.CancelButtonName = "确定"
        boxData.LuaCallBack = BMWDownBankerMessageBoxCallBack
        local parentWindow = CS.WindowManager.Instance:FindWindowNodeByName("CarRotationUI")
        CS.MessageBoxUI.Show(boxData, parentWindow)
    end
end

-- 下庄确认按钮响应
function BMWDownBankerMessageBoxCallBack(result)
    if result == 2 then
        -- 取消和确定位置反向了的
        NetMsgHandler.Send_CS_Car_LowerDealer(GameData.CarInfo.Level)
    end
end

-- 响应庄家列表按钮 (E)
function BankerListButtonOnChick()
    PlaySoundEffect('2')
    NetMsgHandler.Send_CS_BankerListInfo(GameData.CarInfo.Level)
end

-- 关闭庄家列表 (F)
function OnCloseBankerList()
    this.transform:Find('Canvas/Window/Content/Center/BankerListInfo').gameObject:SetActive(false)
end

-- 获奖界面关闭 (G)            !!!!!!!!! 待处理 !!!!!!!!!
function CloseRewardInterface()
    GameObjectSetActive(mRewardInfo.RootObject, false)
    isUpdate = false;
  
end

-- 上轮大赢家信息
function LastWinnerInfo()
    this.transform:Find('Canvas/Window/Content/Center/Player1/RoleName'):GetComponent("Text").text=GameData.CarInfo.WinnerStrLoginIP
    local gold=GameConfig.GetFormatColdNumber(GameData.CarInfo.WinnerGold/10000)
    gold=math.floor(gold)
    this.transform:Find('Canvas/Window/Content/Center/Player1/Gold/Number'):GetComponent("Text").text=tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.CarInfo.WinnerGold),2))
    this.transform:Find('Canvas/Window/Content/Center/Player1/RoleIcon/Vip/Value'):GetComponent("Text").text="VIP"..GameData.CarInfo.WinnerVipLevel
    local Winner=this.transform:Find('Canvas/Window/Content/Center/Player1/RoleIcon').gameObject
    Winner:GetComponent("Image"):ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.CarInfo.WinnerID))
end

-- 当前玩家下注和总下注金额显示区
function BetGoldAppear()

    -- 玩家下注信息
    for index=1,8 do
        -- 玩家自己下注信息
        if GameData.CarInfo.myBet[index]~=nil then
            local myBet=GameConfig.GetFormatColdNumber(GameData.CarInfo.myBet[index])
            myBet=math.floor(myBet);
            if myBet ~= 0 then
                canLeave = false;
                mCloseBtn.interactable = false;
            end
            table_Betting[index].Mine.text = ""..myBet
        else
            table_Betting[index].Mine.text = "0"
        end
        -- 所有玩家总下注信息
        if GameData.CarInfo.AllBet[index]~=nil then
            local Bet=(GameConfig.GetFormatColdNumber(GameData.CarInfo.AllBet[index]))
            Bet = math.floor(Bet)
            table_Betting[index].AllBet.text = ""..Bet
        else
            table_Betting[index].AllBet.text = "0"
        end
    end

end

local mNewFlag = nil
local mHistoryItems = {}
local mChipsItems = {}
local mTmpChips = {}

function InitHistoricalVictoryNode()
    local tmpPath = 'Canvas/Window/Content/Center/GameRecord'
    mNewFlag = this.transform:Find(tmpPath .. '/Content/Chip1/Image').gameObject
    for index = 1, 8 do
        mChipsItems[index] = this.transform:Find(tmpPath .. '/ChipsItem/CarBrand_'..index).gameObject
    end
    for index = 1, 24 do
        mHistoryItems[index] = this.transform:Find(tmpPath .. '/Content/Chip'..index).gameObject
    end
end


-- 历史获胜结果
function TheResultOfHistoricalVictory()
    local num = GameData.CarInfo.LastBetNum

    if num ~= 0 then
        mNewFlag:SetActive(true)
    else
        isCopy = 0
        mNewFlag:SetActive(false)
    end
    if  isCopy == 0 then
        if num ~= 0 then
            for index = 1, num do
                -- 倒序取值
                local carType = GameData.CarInfo.LastBetResult[num+1-index]
                if mHistoryItems[index] ~= nil then
                    local chips = mHistoryItems[index]
                    local Original = mChipsItems[carType]
                    local tCopyNode = CS.UnityEngine.Object.Instantiate(Original)
                    tCopyNode.name = "CarBrand_".. carType
                    CS.Utility.ReSetTransform(tCopyNode.transform,chips.transform)
                    isCopy = 1
                    mTmpChips[index] = tCopyNode
                end
            end
        end
    elseif isCopy == 1 and GameData.CarInfo.NowState == 4 then
        -- 移除以前的数据
        for index = 1, num do
            if mTmpChips[index] ~= nil then
                CS.UnityEngine.Object.Destroy(mTmpChips[index])
            end
        end
        -- 构建新的数据
        for index = 1, num do
            local carType = GameData.CarInfo.LastBetResult[num+1-index]
            if mHistoryItems[index] ~= nil then
                local chips = mHistoryItems[index]
                local Original = mChipsItems[carType]
                local tCopyNode = CS.UnityEngine.Object.Instantiate(Original)
                tCopyNode.name = "CarBrand_".. carType
                CS.Utility.ReSetTransform(tCopyNode.transform,chips.transform)
                mTmpChips[index] = tCopyNode
            end
        end
    end
end


local mLastFerrariCDSecond = 0
local mLastFerrariCDSecond2 = -1
-- 法拉利上次出现时间
function LastFerrariAppearTime( deltaTime )

    if deltaTime ~= nil then
        GameData.CarInfo.LastFerrariTime = GameData.CarInfo.LastFerrariTime + deltaTime
    end

    local FerrariAppearTime = GameData.CarInfo.LastFerrariTime
    if FerrariAppearTime > 359999 then
        FerrariAppearTime = 359999
    end
    mLastFerrariCDSecond = math.floor(FerrariAppearTime)
    local second = math.floor((mLastFerrariCDSecond % 3600) % 60)
    local Minute = math.floor((mLastFerrariCDSecond % 3600) / 60)
    local Hour = math.floor(mLastFerrariCDSecond / 3600)

    if Minute < 10 then
        Minute="0"..Minute
    else
        Minute=""..Minute
    end

    if Hour < 10 then
        Hour="0"..Hour
    else
        Hour=""..Hour
    end

    if second < 10 then
        second = "0"..second;
    else
        second = ""..second;
    end
    if mLastFerrariCDSecond2 ~= mLastFerrariCDSecond then
        mLastFerrariCDSecond2 = mLastFerrariCDSecond
        mCDLeftText.text = Hour..":"..Minute..":"..second
    end
end


local mLastLamborghiniSecond = 0
local mLastLamborghiniSecond2 = -1
-- 兰博基尼上次出现时间
function LastLamborghiniAppearTime(deltaTime)
    if deltaTime ~= nil then
        GameData.CarInfo.LastLamborghiniTime = GameData.CarInfo.LastLamborghiniTime + deltaTime 
    end
    local LamborghiniAppearTime = GameData.CarInfo.LastLamborghiniTime
    
    if LamborghiniAppearTime > 359999 then
        LamborghiniAppearTime = 359999
    end
    mLastLamborghiniSecond = math.floor( LamborghiniAppearTime )

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
        second = "0"..second;
    else
        second = ""..second;
    end

    if mLastLamborghiniSecond2 ~= mLastLamborghiniSecond then
        mLastLamborghiniSecond2 = mLastLamborghiniSecond
        mCDRightText.text = Hour..":"..Minute..":"..second;
    end
end

--设置界面信息显示
function Show_Information_UI()
    LastWinnerInfo()  -- 上轮大赢家信息
    BetGoldAppear()   -- 当前玩家下注和总下注金额显示区
    TheResultOfHistoricalVictory()  -- 历史获胜结果
    LastFerrariAppearTime()         -- 法拉利上次出现时间
    LastLamborghiniAppearTime()     -- 兰博基尼上次出现时间
    BankerInfo()      -- 庄家信息
end



----------------------Awake_Function()----------------------
--从服务器获取信息
function GetDataFromServers()

    currentLevel = GameData.CarInfo.Level;
    currentType = GameData.CarInfo.Type;

end
--初始获取界面物体及组件
function GetObject_UI()
    --获取投注的车标按钮
    GetButtons_Logo()
    --获取内圈灯
    GetLights_Inside();
    --获取外圈灯泡
    GetLights_Outside();
    --获取二十二个车标的坐标
    GetLogoPosition();
    --获取倒计时资源
    GetCountdown_Animation();
    --获取结算物体
    GetSettlementGameObjects();
    --获取物体
    GetOtherObjects();

    RoomPlayerCount = this.transform:Find("Canvas/Window/Content/Center/Button_PlayerList/Text"):GetComponent("Text")
end

--初始设置表的数据
function SetTable_UI()
    --将位置标签index添加入表中
    InsertTableIndex();
    --将跑马灯泡物体添加入表中
    InsertTableGameObject();
    --将跑马灯泡物体TweenPosition组件加入表中
    InsertTableLightTP();
end

-- 初始筹码高亮 (H)
function AwakeChipsLight()
    local gold = GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount)
    Chips_Gold = data.BenchibaomaConfig.BET_GOLD[currentLevel][GameData.CarInfo.ChipsPosition]
    if gold < Chips_Gold then
        GameData.CarInfo.ChipsPosition = 1
    end
    --Chips_Gold=data.BenchibaomaConfig.BET_GOLD[TheLevel][GameData.CarInfo.ChipsPosition]
    ChipsLight(GameData.CarInfo.ChipsPosition)
end

--添加点击事件
function AddClickEvents()

    --关闭页面按钮添加点击事件
    this.transform:Find('Canvas/Window/Top/CloseBtn'):GetComponent("Button").onClick:AddListener(
        CloseUI--------------》关闭奔驰宝马界面UI函数
    );

    --添加点击筹码事件
    for index=1,4 do
        this.transform:Find('Canvas/Window/Content/Button/Boll/Back/Image'..index):GetComponent("Button").onClick:AddListener(function() 
            ClickTheChips(index)----------》A
        end)
    end
    --点击下注按钮
    for index=1,8 do
        this.transform:Find('Canvas/Window/Content/Button/Car/bc_btn_xz_'..index.."_Button"):GetComponent("Button").onClick:AddListener(function()
            BetButtonOnClick(index);
        end)
    end

    --点击上庄/下庄按钮
    this.transform:Find('Canvas/Window/Content/Center/sz_Image'):GetComponent("Button").onClick:AddListener(
        OnBankerApply-------------》D
    )
    this.transform:Find('Canvas/Window/Content/Center/xz_Image'):GetComponent("Button").onClick:AddListener(
        OnBankerApply-------------》D
    )

    --点击庄家列表
    this.transform:Find('Canvas/Window/Content/Center/Player/BankerList'):GetComponent("Button").onClick:AddListener(
        BankerListButtonOnChick-------------》E
    )

    --点击关闭庄家列表
    this.transform:Find('Canvas/Window/Content/Center/BankerListInfo/BackGround/Image'):GetComponent("Button").onClick:AddListener(
        OnCloseBankerList------------》F
    )
    
    -- 获利界面关闭按钮
    this.transform:Find('Canvas/Window/Window_Reward/RewardInterface'):GetComponent("Button").onClick:AddListener(
        CloseRewardInterface
    )

    --银行按钮点击事件
    this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_First"):GetComponent("Button").onClick:AddListener(
        function()
            GameConfig.OpenStoreUI();
        end
    )

    --排行榜按钮点击事件
    this.transform:Find("Canvas/Window/Top_Left_Buttons/Button_Second"):GetComponent("Button").onClick:AddListener(RankButtonOnClick)
    
    button_PlayerList.onClick:AddListener(function()
        RoleCountButtonOnClick();
    end)

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

-- 排行榜
function RankButtonOnClick()
    local initParam = CS.WindowNodeInitParam("UIRoomRank")
    initParam.WindowData = GAME_RANK_TYPE.BCBM_MONEY;
    CS.WindowManager.Instance:OpenWindow(initParam)
    if JudgmentTimeInterval(GAME_RANK_TYPE.BCBM_MONEY) == true then
        NetMsgHandler.SendRequestRanks(GAME_RANK_TYPE.BCBM_MONEY)
    end
end

-----------TUDOU-----------
function State_Lottery()
    light_Stay_Blink.gameObject:SetActive(false);
    light_Stay.gameObject:SetActive(false);
    for k = 1, 22 do
        table_Light_Index[k] = -1;
    end
    --设置待机时的跑马灯关闭
    for k = 1, 8 do
        table_Light_Index[k] = -1;
        table_Light_Run[k].gameObject:SetActive(false);
    end
    --设置抽奖的跑马灯
    for k = 9, 11 do
        table_Light_Index[k] = -1;
        table_Light_Run[k].gameObject:SetActive(false);
    end
    for k = 1, 26 do
        table_Light_Outside_Image[k].sprite = sprite2;
        --table_Light_Outside_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 1)
    end
    table_Light_OutTuoWei = {}
    this.transform:Find("Canvas/Window/Content/Center/CloseTime"):GetComponent("Text").text = "";
    local targetPosition = GameData.CarInfo.LotteryTarget;
    tempCha = 0;
    if targetPosition <= last_Stay_Index then
        tempCha = targetPosition + 22 - last_Stay_Index;
    else
        tempCha = targetPosition - last_Stay_Index;
    end
    distance = 0;
    distance = tempCha + (22 * 4);
    speed_Run1 = 0.55;
    speed_Run2 = 0.05;
    speed_Run3 = 0.05;
    speed_Run4 = 0.05;
    time_Lottery = 0;
    runCount = 0;
    startRotate = true;
    this:DelayInvoke(0.5, function()
        PlaySoundEffect("BCBM_chesheng");
    end)
    
    counter_Countdown = 0;
end

--显示结算特效
function Show_SettlementEffects()

    for k = 1, 8 do
        table_Obj_Star[k].gameObject:SetActive(false);
        table_Obj_Ribbon[k].gameObject:SetActive(false);
    end
    local targetIndex = GameData.CarInfo.LotteryTarget;
    local startPosition = table_Logo_Position[targetIndex];
    Img_Logo.localPosition = startPosition;
    -- last_Stay_Index = targetIndex;
    Img_Logo:GetComponent("Image").sprite = table_Logo_Sprite[targetIndex];
    Settlement.gameObject:SetActive(true);
    Img_Logo.gameObject:SetActive(true);
    local tempTP = Img_Logo:GetComponent("TweenPosition");
    local tempTS = Img_Logo:GetComponent("TweenScale");
    tempTP.from = startPosition;
    tempTP.to = centerPosition;
    tempTP:ResetToBeginning();
    tempTS:ResetToBeginning();
    tempTP:Play(true);
    tempTS:Play(true);

    tempTime1 = 0
    this:DelayInvoke(0.5, function()
        PlaySoundEffect("PDK_WIN");
        local tempTR_OutImg2 = Sunshine_Outside:GetComponent("TweenRotation");
        local tempTS_OutImg1 = Sunshine_Inside:GetComponent("TweenScale");
        Sunshine_Inside.gameObject:SetActive(true);
        Sunshine_Outside.gameObject:SetActive(true);
        Mask_Settlement.gameObject:SetActive(true);
        tempTR_OutImg2:Play(true);
        tempTS_OutImg1:Play(true);

        ---正四方星星1
        for k = 1, 8 do
            tempTime1 = tempTime1 + 0.02 * k;
            this:DelayInvoke(tempTime1, function() 
                local tempTP = table_Obj_Star[k]:GetComponent("TweenPosition");
                local tempTA = table_Obj_Star[k]:GetComponent("TweenAlpha");
                local tempTR = table_Obj_Star[k]:GetComponent("TweenRotation");
                tempTP.from =  centerPosition
                tempTP.to = table_Position_Star[k];
                tempTP:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTR:ResetToBeginning();
                table_Obj_Star[k].gameObject:SetActive(true);
                tempTP:Play(true);
                tempTA:Play(true);
                tempTR:Play(true);
            end)
        end
        tempTime1 = tempTime1 - 0.1;
        for k = 1, 8 do
            tempTime1 = tempTime1 + 0.02 * k;
            this:DelayInvoke(tempTime1, function() 
                local tempTP = table_Obj_Ribbon[k]:GetComponent("TweenPosition");
                local tempTA = table_Obj_Ribbon[k]:GetComponent("TweenAlpha");
                local tempTR = table_Obj_Ribbon[k]:GetComponent("TweenRotation");
                tempTP.from = centerPosition;
                tempTP.to = table_Position_Ribbon[k];
                tempTP:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTR:ResetToBeginning();
                table_Obj_Ribbon[k].gameObject:SetActive(true);
                tempTP:Play(true);
                tempTA:Play(true);
                tempTR:Play(true);
            end)
        end
        tempTime1 = tempTime1 - 0.4;
        for k = 1, 8 do
            tempTime1 = tempTime1 + 0.02 * k;
            this:DelayInvoke(tempTime1, function() 
                local tempTP = table_Obj_Star[k]:GetComponent("TweenPosition");
                local tempTA = table_Obj_Star[k]:GetComponent("TweenAlpha");
                local tempTR = table_Obj_Star[k]:GetComponent("TweenRotation");
                tempTP.from = centerPosition;
                tempTP.to = table_Position_Star[k];
                tempTP:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTR:ResetToBeginning();
                table_Obj_Star[k].gameObject:SetActive(true);
                tempTP:Play(true);
                tempTA:Play(true);
                tempTR:Play(true);
            end)
        end
        tempTime1 = tempTime1 - 0.1;
        for k = 1, 8 do
            tempTime1 = tempTime1 + 0.02 * k;
            this:DelayInvoke(tempTime1, function() 
                local tempTP = table_Obj_Ribbon[k]:GetComponent("TweenPosition");
                local tempTA = table_Obj_Ribbon[k]:GetComponent("TweenAlpha");
                local tempTR = table_Obj_Ribbon[k]:GetComponent("TweenRotation");
                tempTP.from = centerPosition;
                tempTP.to = table_Position_Ribbon[k];
                tempTP:ResetToBeginning();
                tempTA:ResetToBeginning();
                tempTR:ResetToBeginning();
                table_Obj_Ribbon[k].gameObject:SetActive(true);
                tempTP:Play(true);
                tempTA:Play(true);
                tempTR:Play(true);
            end)
        end
    end);

    this:DelayInvoke(2.5, function()
        for k = 1, 8 do
            table_Obj_Star[k].gameObject:SetActive(false);
            table_Obj_Ribbon[k].gameObject:SetActive(false);
        end
        Sunshine_Inside.gameObject:SetActive(false);
        Sunshine_Outside.gameObject:SetActive(false);
        Settlement.gameObject:SetActive(false);
    end);
end



--设置投注的车标+下注按钮的状态（是否可点击）
function SetState_LogoButton(canPress)

    if GameData.CarInfo.isBanker == 1 then
        -- 玩家是庄家 则不能点击下注
        canPress = false
    end

    for k = 1, 8 do
        if table_Button_Logo[k].interactable ~= canPress then
            table_Button_Logo[k].interactable = canPress
            if canPress then
                table_Button_Image[k].color = CS.UnityEngine.Color(1, 1, 1, 1)
            else
                table_Button_Image[k].color = CS.UnityEngine.Color(0.5, 0.5, 0.5, 1)
            end
        end
    end
    for k = 1, 4 do
        if table_ChouMa[k].interactable ~= canPress then
            table_ChouMa[k].interactable = canPress
        end
    end
end

-- 关闭奔驰宝马界面
function CloseUI()
    PlaySoundEffect('2')
    NetMsgHandler.QuitCar(GameData.CarInfo.Level)
end

--->_____________________________________TUDOU_____________________________________--->待机灯光显示效果  跑马灯显示效果

--灯光效果
--待机时外圈灯光闪烁标记
local flag = true;
function ShowLights_Standby(flag)      ---没问题
    
    if flag == true then
        tempSprite1, tempSprite2 = tempSprite2, tempSprite1;
    end
    for k, v in pairs(table_Light_Outside_Image) do
        if k % 2 == 0 then
            v.sprite = tempSprite1;
        else
            v.sprite = tempSprite2
        end
    end
    flag = false;
end

--待机时的跑马灯效果
function ShowRun_Standby()
    for k, v in pairs(table_Light_Index) do
        if v ~= -1 then
            v = v - 1;
            table_Light_Index[k] = v;
        end
    end
    if flag_IsStandbyFirst then
        if(table_Light_Index[1]==3) then
            table_Light_Index[2] = 4;
            GameObjectSetActive(table_Light_Run[2].gameObject, true)
            table_Light_Index[4] = 15;
            GameObjectSetActive(table_Light_Run[4].gameObject, true)
            table_Light_Index[6] = 9;
            GameObjectSetActive(table_Light_Run[6].gameObject, true)
            table_Light_Index[8] = 21;
            GameObjectSetActive(table_Light_Run[8].gameObject, true)
            flag_IsStandbyFirst = false;

        else
            if (table_Light_Index[1] == -1) then
                table_Light_Index[1] = 4;
                table_Light_Run[1].localPosition = table_Logo_Position[table_Light_Index[1]];
                GameObjectSetActive(table_Light_Run[1 ].gameObject, true)
                table_Light_Index[3] = 15;
                table_Light_Run[3].localPosition = table_Logo_Position[table_Light_Index[3]];
                GameObjectSetActive(table_Light_Run[3].gameObject, true)
                table_Light_Index[5] = 9;
                table_Light_Run[5].localPosition = table_Logo_Position[table_Light_Index[5]];
                GameObjectSetActive(table_Light_Run[5].gameObject, true)
                table_Light_Index[7] = 21;
                table_Light_Run[7].localPosition = table_Logo_Position[table_Light_Index[7]];
                GameObjectSetActive(table_Light_Run[7].gameObject, true)
            else

            end
        end
        
    else
        
    end
    for k, v in pairs(table_Light_Index) do
        if(v == 0) then
            table_Light_Index[k] = 22;
        end
    end
    for k = 1, 8 do
        if table_Light_Run[k].gameObject.activeSelf then
            table_Light_Run[k].localPosition = table_Logo_Position[table_Light_Index[k]];
        end
    end
end

--初始化外圈灯
function Initial_Light_Out()
    for k = 1, 26 do
        table_Light_Outside_Image[k].sprite = sprite1;
		table_Light_Outside_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 0);
    end
end
-------------------------------------------------抽奖时的跑马灯效果-------------------------------------------------

function ShowRun_Lottery()

    -- PlaySoundEffect("BCBM_light_run");
    runCount = runCount + 1;
    flag_IsInStandby = false;
    flag_Blink = false;
    for k, v in pairs(table_Light_Index) do
        if v ~= -1 then
            v = v + 1;
            table_Light_Index[k] = v;
        end
    end
    for k = 1, 3 do
        if table_Index_OutTuoWei[k] ~= -1 then
            table_Index_OutTuoWei[k] = table_Index_OutTuoWei[k] + 1;
        end
    end
    if flag_IsLotteryFirst then
        if (table_Light_Index[9] == ((last_Stay_Index+1) % 22)) then
            table_Light_Index[10] = last_Stay_Index;
            table_Light_Run[10].gameObject:SetActive(true);
            table_Index_OutTuoWei[2] = last_Stay_Index;
        elseif (table_Light_Index[9] == ((last_Stay_Index+2) % 22)) then
            table_Light_Index[11] = last_Stay_Index;
            table_Light_Run[11].gameObject:SetActive(true);
            table_Index_OutTuoWei[3] = last_Stay_Index;
            flag_IsLotteryFirst = false;
        else
            if (table_Light_Index[9] == -1) then
                table_Light_Index[9] = last_Stay_Index;
                table_Light_Run[9].gameObject:SetActive(true);
                table_Index_OutTuoWei[1] = last_Stay_Index;
                lapCount = -1;
            else

            end
            
        end
    else
        
    end
    for k, v in pairs(table_Light_Index) do
        if v == 23 then
            table_Light_Index[k] = 1;
        end
    end
    for k = 1, 3 do
        if table_Index_OutTuoWei[k] == 23 then
            table_Index_OutTuoWei[k] = 1;
        end
    end
    for k = 9, 11 do
        if table_Light_Run[k].gameObject.activeSelf then
            table_Light_Run[k].localPosition = table_Logo_Position[table_Light_Index[k]];
        end
    end

    for k, v in pairs(table_Light_OutTuoWei) do
        if table_Light_OutTuoWei[k] ~= 0 then
            table_Light_OutTuoWei[k].transform:GetComponent("Image").sprite = sprite2;
            table_Light_OutTuoWei[k].transform:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 0);
        end
    end

    table_Light_OutTuoWei = {}
    
    -- 设置外圈灯拖尾灯效
    for k = 1, 3 do
        if table_Index_OutTuoWei[k] ~= -1 then
             table_Light_Outside1[table_Index_OutTuoWei[k]].transform:GetComponent("Image").sprite = sprite2;
             table_Light_Outside1[table_Index_OutTuoWei[k]].transform:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 1.2-0.3*k);
             table.insert(table_Light_OutTuoWei, table_Light_Outside1[table_Index_OutTuoWei[k]]);
             if (table_Index_OutTuoWei[k] == 1) then
                table_Light_Outside2[1].transform:GetComponent("Image").sprite = sprite2;
                table_Light_Outside2[1].transform:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 1.2-0.3*k);
                table.insert(table_Light_OutTuoWei, table_Light_Outside2[1]);
             elseif (table_Index_OutTuoWei[k] == 7) then
                table_Light_Outside2[2].transform:GetComponent("Image").sprite = sprite2;
                table_Light_Outside2[2].transform:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 1.2-0.3*k);
                table.insert(table_Light_OutTuoWei, table_Light_Outside2[2]);
             elseif (table_Index_OutTuoWei[k] == 12) then
                table_Light_Outside2[3].transform:GetComponent("Image").sprite = sprite2;
                table_Light_Outside2[3].transform:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 1.2-0.3*k);
                table.insert(table_Light_OutTuoWei, table_Light_Outside2[3]);
             elseif (table_Index_OutTuoWei[k] == 18) then
                table_Light_Outside2[4].transform:GetComponent("Image").sprite = sprite2;
                table_Light_Outside2[4].transform:GetComponent("Image").color = CS.UnityEngine.Color(255, 255, 255, 1.2-0.3*k);
                table.insert(table_Light_OutTuoWei, table_Light_Outside2[4]);
             end
        end
    end
end

-- 处理基本信息
function EssentialInfor()

    HandleRefreshHallUIShowState(false);
    LastWinnerInfo()  -- 上轮大赢家信息
    BetGoldAppear()   -- 当前玩家下注和总下注金额显示区
    TheResultOfHistoricalVictory()  -- 历史获胜结果
    LastFerrariAppearTime()         -- 法拉利上次出现时间
    LastLamborghiniAppearTime()     -- 兰博基尼上次出现时间
    BankerInfo()      -- 庄家信息
    CarWinInfoDisplay()
    RefreshPlayerCount();           --刷新玩家信息
    --ShowLights_Standby()
    --ShowRun_Standby();
end


-- 庄家信息
function BankerInfo()
    --ShangZhuangText.text=">"..data.BenchibaomaConfig.PLAYER_UPBANKER_GOLD[GameData.CarInfo.Level]
    ShangZhuangText.text=">"..GameData.CarInfo.UpperBankersGold
    this.transform:Find('Canvas/Window/Content/Center/Player/RoleName'):GetComponent("Text").text=GameData.CarInfo.BankerStrLoginIP
    this.transform:Find('Canvas/Window/Content/Center/Player/Gold/Number'):GetComponent("Text").text=lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.CarInfo.BankerGold))
    this.transform:Find('Canvas/Window/Content/Center/Player/RoleIcon/Vip/Value'):GetComponent("Text").text="VIP"..GameData.CarInfo.BankerVipLevel
    local Banker= this.transform:Find('Canvas/Window/Content/Center/Player/RoleIcon').gameObject
    Banker:GetComponent("Image"):ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.CarInfo.BankerID))
    if GameData.CarInfo.isBanker == 0  then
        local SZ_Image=this.transform:Find('Canvas/Window/Content/Center/sz_Image').gameObject:SetActive(true)
        local XZ_Image=this.transform:Find('Canvas/Window/Content/Center/xz_Image').gameObject:SetActive(false)
    else
        local XZ_Image=this.transform:Find('Canvas/Window/Content/Center/xz_Image').gameObject:SetActive(true)
        local SZ_Image=this.transform:Find('Canvas/Window/Content/Center/sz_Image').gameObject:SetActive(false)
    end
end

--倒计时321的显示TUDOU
function Show_321Countdown()
    
    PlaySoundEffect("8");
    if GameData.CarInfo.NowState ~= 4 then
        GuiWei=false
    end
    mask_Number.gameObject:SetActive(true);
    table_Countdown_GameObject[1].gameObject:SetActive(true);
    table_Countdown_TweenScale[1]:Play(true);
    table_Countdown_Animation[1]:RePlay();
    table_Countdown_Alpha[1]:Play(true);
    this:DelayInvoke(1, function()
        table_Countdown_TweenScale[1]:ResetToBeginning();
        table_Countdown_Alpha[1]:ResetToBeginning();
    end);
    flag_Countdown_1 = false;
        
    this:DelayInvoke(1.0, function()
        PlaySoundEffect("8");
        table_Countdown_GameObject[2].gameObject:SetActive(true);
        table_Countdown_GameObject[1].gameObject:SetActive(false);
        table_Countdown_TweenScale[2]:Play(true);
        table_Countdown_Animation[2]:RePlay();
        table_Countdown_Alpha[2]:Play(true);
        this:DelayInvoke(1, function()
            table_Countdown_TweenScale[2]:ResetToBeginning();
            table_Countdown_Alpha[2]:ResetToBeginning();
        end);
        flag_Countdown_1 = false;
    end)
    this:DelayInvoke(2, function()
        PlaySoundEffect("8");
        table_Countdown_GameObject[3].gameObject:SetActive(true);
        table_Countdown_GameObject[2].gameObject:SetActive(false);
        table_Countdown_TweenScale[3]:Play(true);
        table_Countdown_Animation[3]:RePlay();
        table_Countdown_Alpha[3]:Play(true);
        this:DelayInvoke(1, function()
            table_Countdown_TweenScale[3]:ResetToBeginning();
            table_Countdown_Alpha[3]:ResetToBeginning();
            table_Countdown_GameObject[3].gameObject:SetActive(false);
            mask_Number.gameObject:SetActive(false);
        end);
        flag_Countdown_1 = false;
    end)
end

-- 开始抽奖
function StartTheLottery()
    Initial_Light_Out();
end

-- 玩家押中打开获胜界面
function PlayerBetVictory()
    isWin = true;
    local BetWinner_Gold = GameData.CarInfo.BetWinner_Gold

    mRewardInfo.RewardText.text="<color=#00FF00>"..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(BetWinner_Gold)).."</color>";
end

-- 庄家盈利，打开获胜界面
function BankerBetVictor()
    isWin = true;
    is_Banker = true;
end


-- 庄家列表信息
function OnBankerListInfo()
    this.transform:Find('Canvas/Window/Content/Center/BankerListInfo').gameObject:SetActive(true)
    local Remainder=0
    if GameData.CarInfo.BankerRemainder ~= 0 then
        Remainder = GameData.CarInfo.BankerRemainder
    else
        Remainder="0"
    end
    -- 当前庄家剩余局数
    this.transform:Find('Canvas/Window/Content/Center/BankerListInfo/BackGround/Text'):GetComponent("Text").text=""..Remainder

    for index=1,5 do
        if this.transform:Find('Canvas/Window/Content/Center/BankerListInfo/BackGround/Chips/Viewport/Content/Chip'..index..'/ChipsItem(Clone)')~=nil then
            local destoryCopy=this.transform:Find('Canvas/Window/Content/Center/BankerListInfo/BackGround/Chips/Viewport/Content/Chip'..index..'/ChipsItem(Clone)').gameObject
            CS.UnityEngine.Object.Destroy(destoryCopy)
        end
    end

    local num = GameData.CarInfo.BankerNumber
    for index=1,num do
        local chips = this.transform:Find('Canvas/Window/Content/Center/BankerListInfo/BackGround/Chips/Viewport/Content/Chip'..index).gameObject
        local BankerItem = this.transform:Find('Canvas/Window/Content/Center/BankerListInfo/BackGround/ChipsItem').gameObject
        local tCopyNode=CS.UnityEngine.Object.Instantiate(BankerItem)
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
-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(tostring( musicid ))
end



--断线重连
function InitRoomInfo()
    -- UI 关闭时 停掉所有的音效并停止挂起的携程
    MusicMgr:StopAllSoundEffect()
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    startRotate = false;
    Initial_Index();
    count_Gold.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
    RefreshPlayerCount();           --刷新玩家信息
end

-- 获奖玩家信息显示
function CarWinInfoDisplay()
    if #GameData.CarWinnInfo>=1 and IsUpdatePlay == false then
        IsUpdatePlay=false
        mCarWinTweenPosition.transform:GetComponent("Text").text=string.format(data.GetString("JH_Wheel_WinningMessage"),GameData.CarWinnInfo[1].StrLoginIP,GameData.CarWinnInfo[1].PlayerGold)
        --mCarWinTweenPosition.transform:GetComponent("Texft").text="恭喜"..GameData.CarWinnInfo[1].StrLoginIP.."玩家中大奖，获得"..GameData.CarWinnInfo[1].PlayerGold.."金币"
        this:DelayInvoke(2.8,function()
            table.remove(GameData.CarWinnInfo,1)
        end)
        mCarWinTweenPosition:ResetToBeginning()
        mCarWinTweenPosition:Play(true)
        IsUpdatePlay = true
    elseif #GameData.CarWinnInfo == 0 then
        IsUpdatePlay=false
    end
end

-- 对应脚本的刷新数据方法
function RefreshWindowData(windowData)

end



flag_isBlinkY = false;

local time_tempBlink = 0;


---——————————————————————————————————————————TUDOU——————————————————————————————————————————---（不同阶段分类进入函数）
function Differentiate_State()


    --获取当前的阶段/状态
    local currentState = GameData.CarInfo.NowState

    if currentState == 1 then        ---倒计时状态
        OnState_1()
    elseif currentState == 2 then        ---投注状态
        OnState_2()
    elseif currentState == 3 then        ---抽奖状态
        -- CS.UnityEngine.Profiling.Profiler.BeginSample("=====State 333=====")
        OnState_3()
        -- CS.UnityEngine.Profiling.Profiler.EndSample()
    elseif currentState == 4 then        ---结算状态
        -- CS.UnityEngine.Profiling.Profiler.BeginSample("=====State 444=====")
        OnState_4()
        -- CS.UnityEngine.Profiling.Profiler.EndSample()
    elseif currentState == 5 then        ---等待时间
        -- CS.UnityEngine.Profiling.Profiler.BeginSample("=====State 555=====")
        OnState_5()
        -- CS.UnityEngine.Profiling.Profiler.EndSample()
    else

    end
end



-- 下注阶段
function OnState_2()
    if flag_First_Two then

        flag_First_One = true;
        flag_First_Two = false;
        flag_First_Three = true;
        flag_First_Four = true;
        flag_First_Five = true;
        flag_IsLotteryFirst = true;
        flag_First_Settlement = true;
        flag_First_TipsEndLottery = true;
        isBet = false;
        canLeave = true;
        startRotate = false;
        GameObjectSetActive(mText_WaitGameObject, false)
        count_Gold.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
        if GameData.CarInfo.ResidualTimeOfEachStage == 21 then
            Animation_StartLottery();
            PlaySoundEffect("35");
            isReconnect = false;
        else
            isReconnect = true;
        end
        if GameData.CarInfo.ResidualTimeOfEachStage <= 19 then
            SetState_LogoButton(true)
        end

        CheckCloseBtnState()
        SetState_LogoButton(false)
        for k = 1, 8 do
            table_Light_Index[k] = -1;
            table_Light_Run[k].gameObject:SetActive(false);
        end
        
    end

    if GameData.CarInfo.ResidualTimeOfEachStage <= 19 and GameData.CarInfo.ResidualTimeOfEachStage >3 then
        SetState_LogoButton(true)
    else
        SetState_LogoButton(false)
    end

    if GameData.CarInfo.ResidualTimeOfEachStage == 3 and flag_First_TipsEndLottery then
        PlaySoundEffect("36");
        CS.BubblePrompt.Show(data.GetString("Tip_Stop_Bet"), "CarRotationUI");
        flag_First_TipsEndLottery = false;
        for k = 1, #GameData.CarInfo.myBet do
            local tData = GameData.CarInfo.myBet[k];
            if tData ~= nil and tData > 0 then
                isBet = true;
            end
        end
        if not isBet then
            this:DelayInvoke(1.2, function()
                PlaySoundEffect("37")
            end)
            isBet = true;
        end
    end

    State_Bet()

    time_Center.text= ""..GameData.CarInfo.ResidualTimeOfEachStage;
end

-- 321倒计时
function OnState_1()
    if flag_First_One then
        flag_First_One = false;
        flag_First_Two = true;
        flag_First_Three = true;
        flag_First_Four = true;
        flag_First_Five = true;
        flag_First_Settlement = true;
        flag_First_TipsEndLottery = true;
        flag_IsLotteryFirst = true;
        startRotate = false;
        isBet = false;
        count_Gold.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
        SetState_LogoButton(false);
        if GameData.CarInfo.ResidualTimeOfEachStage == 3 then
            Show_321Countdown()
            isReconnect = false;
        else
            isReconnect = true;
        end

        for k = 1, 11 do
            table_Light_Index[k] = -1;
            table_Light_Run[k].gameObject:SetActive(false);
        end
        CheckCloseBtnState()
    end
    time_Center.text = "";
    if isReconnect then
        State_Bet();
    end
end

-- 抽奖阶段
function OnState_3()
    if flag_First_Three then
        flag_First_One = true;
        flag_First_Two = true;
        flag_First_Three = false;
        flag_First_Four = true;
        flag_First_Five = true;
        flag_IsLotteryFirst = true;
        flag_First_Settlement = true;
        flag_First_TipsEndLottery = true;
        isBet = false;
        startRotate = false;
        
        count_Gold.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
        if GameData.CarInfo.ResidualTimeOfEachStage == 7 then
            State_Lottery();
            isReconnect = false;
        else
            isReconnect = true;
        end
        SetState_LogoButton(false);
        for  k = 1, 8 do
            table_Light_Index[k] = -1;
            table_Light_Run[k].gameObject:SetActive(false);
        end

        CheckCloseBtnState()
    end
    time_Center.text = ""
    if isReconnect then
        State_Bet();
    end
end

-- 结算阶段
function OnState_4()
    if flag_First_Four then
        flag_First_One = true;
        flag_First_Two = true;
        flag_First_Three = true;
        flag_First_Four = false;
        flag_First_Five = true;
        flag_IsLotteryFirst = true;
        flag_First_Settlement = true;
        flag_First_TipsEndLottery = true;
        isBet = false;
        startRotate = false;
        for k = 9, 11 do
            table_Light_Run[k].gameObject:SetActive(false);
            table_Light_Index[k] = -1;
        end
        if GameData.CarInfo.ResidualTimeOfEachStage == 6 then
            last_Stay_Index = GameData.CarInfo.LotteryTarget;
            light_Stay_Blink.transform.localPosition = table_Logo_Position[last_Stay_Index];
            light_Stay_Blink.gameObject:SetActive(true);
            flag_IsInStandby = true;
            time_Blink = 0.8;
            this:DelayInvoke(0.8, function()
                light_Stay_Blink.gameObject:SetActive(false);
                local tempPos = GameData.CarInfo.LotteryTarget;
                light_Stay_Blink_Image.color = CS.UnityEngine.Color(255, 255, 255, 0);
                light_Stay.transform.localPosition = CS.UnityEngine.Vector3(table_Logo_Position[tempPos].x, table_Logo_Position[tempPos].y, 0);
                light_Stay_Image.color = CS.UnityEngine.Color(255, 255, 255, 1);
                light_Stay.gameObject:SetActive(true);
                flag_IsInStandby = false;
            end)
            for k = 1, 26 do
				table_Light_Outside_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 1);
                table_Light_Outside[k].gameObject:SetActive(true);
            end

            flag_Blink = true;
            flag_IsRun = true;

            isReconnect = false;
        else
            isReconnect = true;
        end
        CheckCloseBtnState()
        SetState_LogoButton(false)
        for k = 1, 8 do
            table_Light_Index[k] = -1;
            table_Light_Run[k].gameObject:SetActive(false);
        end
    end
    time_Center.text="";
    if GameData.CarInfo.ResidualTimeOfEachStage == 5 and flag_First_Settlement then
        flag_First_Settlement = false;
        Show_SettlementEffects();
    end
    if GameData.CarInfo.ResidualTimeOfEachStage == 2 then
        if isWin then
            if is_Banker then
                is_Banker = false;
                isWin = false;
                PlaySoundEffect('game_win')
                local BankerWinner_Gold = GameData.CarInfo.BankerSettlement_Gold
                if GameData.CarInfo.isBankerWinner == 1 then
                    GameObjectSetActive(mRewardInfo.RootObject, true)
                    GameObjectSetActive(mRewardInfo.RewardObject, true)

                    ParticleObject.gameObject:SetActive(true);
                    PlaySoundEffect('HB_Gold');
                    mRewardInfo.RewardText.text=lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(BankerWinner_Gold))
                    this:DelayInvoke(1.8,function()
                        GameObjectSetActive(mRewardInfo.RootObject.gameObject, false)
                        GameObjectSetActive(mRewardInfo.RewardObject, false)
                        ParticleObject.gameObject:SetActive(false);
                        count_Gold.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
                    end)
                elseif GameData.CarInfo.isBankerWinner == 2 then
                    
                end
            else
                isReconnect = false;
                isWin = false;
                PlaySoundEffect('game_win');
                GameObjectSetActive(mRewardInfo.RootObject, true)
                GameObjectSetActive(mRewardInfo.RewardObject, true)
                ParticleObject.gameObject:SetActive(true);
                PlaySoundEffect('HB_Gold');
                this:DelayInvoke(1.8, function()
                    GameObjectSetActive(mRewardInfo.RootObject, false)
                    GameObjectSetActive(mRewardInfo.RewardObject, false)
                    ParticleObject.gameObject:SetActive(false);
                    count_Gold.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
                end)
            end
        else
            mText_WaitText.text = data.GetString("Tips_Wait")
            GameObjectSetActive(mText_WaitGameObject, true)
        end
    end
end

-- 等待3秒(下一局即将开始)
function OnState_5()
    if flag_First_Five then
        flag_First_One = true;
        flag_First_Two = true;
        flag_First_Three = true;
        flag_First_Four = true;
        flag_First_Five = false;
        flag_First_Settlement = true;
        flag_First_TipsEndLottery = true;
        isBet = false;
        count_Gold.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));

        mText_WaitText.text = data.GetString("Tips_Wait")
        GameObjectSetActive(mText_WaitGameObject, true)

        this:DelayInvoke(1.8, function()
            GameObjectSetActive(mText_WaitGameObject, false)
        end)
        SetState_LogoButton(false)
        for k = 1, 8 do
            table_Light_Index[k] = -1;
            table_Light_Run[k].gameObject:SetActive(false);
        end
        CheckCloseBtnState()
    end
    time_Center.text = ""
end

-- 检测关闭按钮状态(玩家有主动下注值，则不允许玩家推出游戏)
function CheckCloseBtnState()
    local flag = true
    for k = 1, #GameData.CarInfo.myBet do
        local tData = GameData.CarInfo.myBet[k]
        if tData ~= nil and tData > 0 then
            flag = false
            break
        end
    end
    mCloseBtn.interactable = flag
end

---——————————————————————————————————————————TUDOU——————————————————————————————————————————---（不同阶段分类进入函数）

--投注状态
function State_Bet()

    speed_LightRun_Standby = speed_LightRun_Standby + Time.deltaTime;
    speed_OutLight_Blink = speed_OutLight_Blink + Time.deltaTime;
    
    if speed_LightRun_Standby > 0.8 then
		for k = 1, 26 do
            table_Light_Outside_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 1);
        end
        ShowRun_Standby();
        speed_LightRun_Standby = 0;
    end
    if speed_OutLight_Blink > 0.5 then
        ShowLights_Standby(true);
        speed_OutLight_Blink = 0;
    end

end

local tempTime1 = 0;




-- 开始投注函数
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
    initParam.WindowData = 4;
    CS.WindowManager.Instance:OpenWindow(initParam)
end

-- 刷新房间内玩家数
function RefreshPlayerCount()
    RoomPlayerCount.text = ""..GameData.CarInfo.PlayerCount
end

function Awake()
    --从服务器获取所需数据
    GetDataFromServers()
    --NetMsgHandler.Send_CS_CarInfo(GameData.CarInfo.Level);
    MusicMgr:StopAllSoundEffect();
    DoHelp();
    stillBet = false;
    isFirstInLottery = true;
    canLeave = true;
    last_Stay_Index = GameData.CarInfo.LastLotteryTarget;
    
    --初始获取物体及组件
    GetObject_UI();
    --获取其他物体
    GetOtherObjects();
    --初始设置表的数据
    SetTable_UI();
    --初始化 index 等值
    Initial_Index();
    --从服务器获取所需数据
    GetDataFromServers()
    --设置筹码高亮
    AwakeChipsLight()
    --添加点击事件
    AddClickEvents();
    InitHistoricalVictoryNode()
    --设置界面信息显示
    Show_Information_UI();
    
    flag_IsStandbyFirst = true;
   
    --不要删————————————————————————————————————————————————————————————————————————————————————————————————————————
    
    -- RewardLightTweenPosition.enabled=false
    -- RewardLightTweenPosition.transform.localPosition = CS.UnityEngine.Vector3(mLightPosition_X[4],mLightPosition_Y[4],0)

    mCarWinTweenPosition = this.transform:Find("Canvas/Window/WinningMessage/PromptText"):GetComponent("TweenPosition")
    --不要删————————————————————————————————————————————————————————————————————————————————————————————————————————
    -- NetMsgHandler.Send_CS_CarInfo()
    EssentialInfor()
    
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    CS.MatchLoadingUI.Hide()
    GameData.GameState = GAME_STATE.ROOM
    GameData.RoomInfo.CurrentRoom.RoomType = ROOM_TYPE.BMWBENZ
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    GameData.CarInfo.isNewOpen=1
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarInfo,EssentialInfor)    --更新奔驰宝马信息
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarBankerInfo,BankerInfo)  --更新庄家信息
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarBankerBetInfo,BetGoldAppear)  --更新下注信息
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarBankerListInfo,OnBankerListInfo)  --更新庄家列表信息
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptStartTheLottery,StartTheLottery)  --开始抽奖
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarInterfacePlayerBetVictory,PlayerBetVictory)  --玩家押中弹出获胜界面
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAcceptCarInterfaceBankerBetVictory,BankerBetVictor)  --庄家弹出获胜界面
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyCarUpdateWinInfo, CarWinInfoDisplay)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, InitRoomInfo);
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateRoomPlayerList, playerList);
    MusicMgr:PlayBackMusic("BG_BCBM")
    if GameData.RoomInfo.CurrentRoom.RoomID ~= 0 then
        Show_Information_UI();
    end
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    GameData.CarInfo.isNewOpen = 0
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarInfo, EssentialInfor)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarBankerInfo, BankerInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarBankerBetInfo, BetGoldAppear)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarBankerListInfo, OnBankerListInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptStartTheLottery, StartTheLottery)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarInterfacePlayerBetVictory, PlayerBetVictory)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAcceptCarInterfaceBankerBetVictory, BankerBetVictor)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyCarUpdateWinInfo, CarWinInfoDisplay)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, InitRoomInfo);
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyUpdateRoomPlayerList, playerList);
    GameData.CarWinnInfo={}
    -- UI 关闭时 停掉所有的音效并停止挂起的携程
    MusicMgr:StopAllSoundEffect()
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
    local tempObj = CS.WindowManager.Instance:FindWindowNodeByName("UIRoomPlayers")
    if tempObj ~= nil then
        CS.WindowManager.Instance:CloseWindow("UIRoomPlayers", false)
    end
end

local timeTemp = 0;

-- Unity MonoBehavior Update 时调用此方法
function Update()

    timeTemp = timeTemp + Time.deltaTime;
    --更新同步服务器时间
    GameData.CarInfoCountDown(Time.deltaTime);
    --判别阶段以及显示
    Differentiate_State();
    
    LastFerrariAppearTime(Time.deltaTime)
    LastLamborghiniAppearTime(Time.deltaTime)

    count = count + Time.deltaTime;
    counter_Countdown = counter_Countdown + Time.deltaTime;
    time_All = time_All + Time.deltaTime;

    time_tempBlink = time_tempBlink + Time.deltaTime;

    if flag_isBlinkY == true and count % 40 == 0 then
        light_Stay_TweenAlpha:Play(true);
        flag_Blink = true;
    end

    if IsUpdatePlay == true then
        PlayTimer = PlayTimer-Time.deltaTime
        
        if PlayTimer <= 0 then
            IsUpdatePlay=false
            CarWinInfoDisplay()
            PlayTimer = 16.3
        end
    end

    time_EveryFPS = time_EveryFPS + Time.deltaTime;
    if flag_IsInStandby and count > time_Blink then
        if light_Stay_Blink.gameObject.activeSelf then
            light_Stay_Blink_TweenAlpha:ResetToBeginning();
            light_Stay_Blink_TweenAlpha:Play(true);
            count = 0;
        end
    end

    time_Lottery = time_Lottery + Time.deltaTime;

    -- CS.UnityEngine.Profiling.Profiler.BeginSample("=====State 333===555==")
        
    --抽奖过程(暂不更改)
    if startRotate then
        if runCount <= 4 then
            if time_Lottery > speed_Run1 then
                ShowRun_Lottery();
                time_Lottery = 0;
                speed_Run1 = speed_Run1 - 0.1;
            end
        elseif runCount <=distance - 5 then
            if time_Lottery > 0.03  then
                ShowRun_Lottery();
                time_Lottery = 0;
            end
        elseif runCount <= distance then
            if time_Lottery > speed_Run2 then
                ShowRun_Lottery();
                time_Lottery = 0;
                speed_Run2 = speed_Run2 + 0.1;
            end
        else
        end
    end
    -- CS.UnityEngine.Profiling.Profiler.EndSample()
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    lua_Call_GC();
end
