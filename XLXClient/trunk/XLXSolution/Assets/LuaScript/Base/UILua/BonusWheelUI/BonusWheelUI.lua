local Time = CS.UnityEngine.Time

-- 灯光数据组建
local mLightGameObjects = 
{
    [1] = nil,
    [2] = nil,
    [3] = nil,
    [4] = nil,
    [5] = nil,
    [6] = nil,
    [7] = nil,
    [8] = nil,
}
-- 箭头目标旋转值
local mLightRotation = {[1] = 0, [2] = 315, [3] = 270, [4] = 225, [5] = 180, [6] = 135, [7] = 90, [8] = 45,}
local mLightTargetTime = {[1] = 0, [2] = 0.2, [3] = 0.4, [4] = 0.6, [5] = 0.8, [6] = 1.0, [7] = 1.2, [8] = 1.4,}

-- 奖励展示组建
local mRewardImageGameObject = nil
local mRewardImageText = nil
-- 奖励按钮 次数
local mRewardButton = nil
local mRewardButtonText = nil

-- 轮盘箭头组件
local mRewardPointerGameObject = nil
local mRewardPointerTweenRotation = nil

local mWheelLightTagIndex = 1 -- 目标位置

local mWheelWinGameObject = nil
local mWheelWinGameObjectText = nil
local mWheelWinTweenPosition = nil
local IsUpdatePlay = false
local PlayTimer = 16.3
local  Level=1

local IsExit = true

local jingbipengse = nil

-->>-------------------------------------   TUDOU   ------------------------------------------

------   按钮类:
local button_Close;              --关闭界面按钮
local button_Help;               --帮助按钮
local button_HelpClose;          --帮助关闭按钮
local button_StartLottery;       --开始抽奖按钮
local button_Record;             --我的中奖记录按钮
local button_Lottery10;          --10连抽按钮
local button_Lottery20;          --20连抽按钮
local button_Lottery50           --50连抽按钮
local button_Rewards;            --连抽奖励面板里确认按钮
local button_Mask_Rewards;       --连抽奖励面板遮罩关闭按钮
local button_RecordClose;        --纪录面板关闭按钮
local button_Mask_Record;        --纪录面板遮罩关闭按钮

------   table类:
local table_Light_Out = {};           --外圈灯泡(表)
local table_Light_Out_Image = {}
local table_LightOut_TS = {}
local table_Light_Sector = {};        --内环扇形(表)
local table_Light_Sector_Rotation = {}
local table_Light_Sector_Image = {}
local table_Circle = {};              --扩散圈  (表)
local table_TweenScale = {}
local table_TweenAlpha = {}
local table_SeriesLottery = {};       --连抽    (表)
local table_Coin = {};                --金币飞  (表)
local table_Coin_TweenPosition = {}
local table_Coin2 = {};
local table_PartCircle = {};          --外环八小节(表)

------   其他 Object 类
local window_Help;                  --【帮助】界面
local circle_Outside;               --外圈环(4小节)
local center_Rotate_Objects;        --中心旋转物体
local center_Rotate_Objects_Arrow = nil
local center_Rotate_Objects_Sector = nil
local center_Rotate_Objects_MengBan = nil
local tail                          --抽奖时的拖尾
local tail_1;                       --抽奖时的拖尾1
local tail_2;                       --抽奖时的拖尾2
local tail_TR;                      --拖尾的TweenRotation
local tempObj1;                     --备用Object变量1
local tempObj2;                     --备用Object变量2
local Image_Center_Unable;          --中心按钮不可用状态图片
local window_Rewards;               --连抽奖励面板
local moneyAll_Rewards;             --连抽奖励金币总值
local parent_RewardsContent;        --连抽展板(作为父物体)
local item_Rewards;                 --用于奖励面板实例化的物体
local mask_Rewards;                 --连抽奖励面板的遮罩
local window_Record;                --玩家幸运轮盘纪录
local mask_Record;                  --幸运轮盘纪录遮罩
local parent_RecordContent;         --纪录展板(作为父物体);
local item_Record;                  --用于纪录实例化的物体
local icon_Coin_Start;              --金币飞特效起点;
local icon_Coin_End;                --金币飞特效终点;
local icon_Coin_Start2;             --金币飞特效起点2(单次抽)
local icon_Coin_End2;               --金币飞特效终点2(单次抽)
local mask_Help;


------   杂乱变量
local RoomLevel = 0;
local canExit = true;           --是否可以离开界面
local time_OutLight;            --外圈灯泡闪烁计时
local time_OutCircle;           --外圈环闪烁计时(4小节)
local position_Start;           --开始旋转的位置
local angle_Sector;             --中心旋转物体(扇形)的角度
local flag_Blink;               --闪烁的信号
local isEndLottey;              --是否是抽奖结束
local text_CoinCount;           --金币数量显示【我的金币】
local isLottery;                --是否抽奖状态
local isStandby;                --是否待机状态
local count_Lottery;            --抽奖的次数
local last_MoneyCount;          --上一次金币的数量
local changePartCircle;        --是否切换外环四小节



---------___获取所有物体___
function GetAllObjects()
    ------   按钮类   ------
    button_Close = this.transform:Find("Canvas/Window/Title/Button_Close"):GetComponent("Button");
    button_Help = this.transform:Find("Canvas/Window/Button_Help"):GetComponent("Button");
    button_HelpClose = this.transform:Find("Canvas/Window/Window_Help/Title/Button_Close"):GetComponent("Button");
    button_StartLottery = this.transform:Find("Canvas/Window/Wheel/RewardButton"):GetComponent("Button"):GetComponent("Button");
    button_Record = this.transform:Find("Canvas/Window/Bottom/Above/Button_Record"):GetComponent("Button");
    button_Lottery10 = this.transform:Find("Canvas/Window/Bottom/Below/Button_1"):GetComponent("Button");
    button_Lottery20 = this.transform:Find("Canvas/Window/Bottom/Below/Button_2"):GetComponent("Button");
    button_Lottery50 = this.transform:Find("Canvas/Window/Bottom/Below/Button_3"):GetComponent("Button");
    button_Rewards = this.transform:Find("Canvas/Window/RewardsImage/Button_Sure");
    button_Mask_Rewards = this.transform:Find("Canvas/Window/Mask_Rewards"):GetComponent("Button");
    button_RecordClose = this.transform:Find("Canvas/Window/Window_Record/Title/Button_Close"):GetComponent("Button");

    ------   table类   ------
    for k = 1, 27 do     --获取外圈灯泡(表)
        table_Light_Out[k] = this.transform:Find("Canvas/Window/Wheel/Lights/Light_"..k);
        table_Light_Out_Image[k] = table_Light_Out[k]:GetComponent("Image")
        table_LightOut_TS[k] = table_Light_Out[k]:GetComponent("TweenScale");
    end
    for k = 1, 8 do      --获取内环扇形(表)
        table_Light_Sector[k] = this.transform:Find("Canvas/Window/Wheel/Light/zp_box_choose"..k);
        table_Light_Sector_Rotation[k] = table_Light_Sector[k]:GetComponent("TweenRotation")
        table_Light_Sector_Image[k] = table_Light_Sector[k]:GetComponent("Image")
    end
    for k = 1, 3 do      --获取扩散圈  (表)
        table_Circle[k] = this.transform:Find("Canvas/Window/Wheel/Circles/Circle_"..k);
        table_TweenAlpha[k] = table_Circle[k]:GetComponent("TweenAlpha")
        table_TweenScale[k] = table_Circle[k]:GetComponent("TweenScale")
    end
    for k = 1, 3 do      --获取连抽按钮(表)
        table_SeriesLottery[k] = this.transform:Find("Canvas/Window/Bottom/Below/Button_"..k):GetComponent("Button");
    end
    for k = 1, 20 do
        table_Coin[k] = this.transform:Find("Canvas/Window/RewardsImage/Above/Icon_Coin_"..k);
        table_Coin_TweenPosition[k] = table_Coin[k]:GetComponent("TweenPosition")
    end
    for k = 1, 5 do
        table_Coin2[k] = this.transform:Find("Canvas/Window/RewardImage/Coin"..k);
    end
    for k = 1, 8 do
        table_PartCircle[k] = this.transform:Find("Canvas/Window/Wheel/OutCircle/Image"..k).gameObject;
    end

    ------   其他Object类   ------
    window_Help = this.transform:Find("Canvas/Window/Window_Help");
    center_Rotate_Objects = this.transform:Find("Canvas/Window/Wheel/RewardPointer");
    center_Rotate_Objects_Arrow = center_Rotate_Objects.transform:Find('Arrow').gameObject
    center_Rotate_Objects_Sector = center_Rotate_Objects.transform:Find('Sector').gameObject
    center_Rotate_Objects_MengBan = center_Rotate_Objects.transform:Find('MengBan').gameObject
    angle_Sector = center_Rotate_Objects.eulerAngles;
    tail = this.transform:Find("Canvas/Window/Wheel/Tail");
    tail_1 = this.transform:Find("Canvas/Window/Wheel/Tail/Tail_1");
    tail_2 = this.transform:Find("Canvas/Window/Wheel/Tail/Tail_2");
    tail_TR = tail:GetComponent("TweenRotation");
    text_CoinCount = this.transform:Find("Canvas/Window/Bottom/Above/Area_Coin/Text_Coin"):GetComponent("Text");
    Image_Center_Unable = this.transform:Find("Canvas/Window/Wheel/RewardButton/Button_Unable");
    icon_Coin_Start = this.transform:Find("Canvas/Window/RewardsImage/Above/Icon_Coin");
    icon_Coin_End = this.transform:Find("Canvas/Window/RewardsImage/Above/Icon_Coin_End");
    mask_Help = this.transform:Find("Canvas/Window/Mask_Help");
    icon_Coin_Start2 = this.transform:Find("Canvas/Window/RewardImage/Image");
    icon_Coin_End2 = this.transform:Find("Canvas/Window/RewardImage/Coin_End");

    --连抽奖励面板
    window_Rewards = this.transform:Find("Canvas/Window/RewardsImage");
    moneyAll_Rewards = this.transform:Find("Canvas/Window/RewardsImage/Above/Money_All"):GetComponent("Text");
    parent_RewardsContent = this.transform:Find("Canvas/Window/RewardsImage/Scroll View/Viewport/Content");
    item_Rewards = this.transform:Find("Canvas/Window/RewardsImage/Scroll View/Viewport/Content/Item");
    mask_Rewards = this.transform:Find("Canvas/Window/Mask_Rewards");
    --纪录展板
    window_Record = this.transform:Find("Canvas/Window/Window_Record");
    mask_Record = this.transform:Find("Canvas/Window/Mask_Record");
    parent_RecordContent = this.transform:Find("Canvas/Window/Window_Record/Scroll View/Viewport/Content");
    item_Record = this.transform:Find("Canvas/Window/Window_Record/Scroll View/Viewport/Content/Item");

    --外环圈(4小节)
    circle_Outside = this.transform:Find("Canvas/Window/Wheel/OutCircle");

    ------   杂乱变量   ------
    isLottery = false;
    isStandby = true;

end


---------___添加点击事件___
function AddClickEvents()
    --关闭按钮点击事件
    button_Close.onClick:AddListener(CloseUI);
    --帮助按钮点击事件
    button_Help.onClick:AddListener(OpenHelpWindow);
    --帮助按钮关闭点击事件
    button_HelpClose.onClick:AddListener(Window_HelpClose);
    --开始抽奖点击事件
    button_StartLottery.onClick:AddListener(StartLottery);
    --【我的中奖纪录】点击事件
    button_Record.onClick:AddListener(Window_MyRecord);
    -- 10连抽
    button_Lottery10.onClick:AddListener(function()SequenceLottery(10)end);
    -- 20连抽
    button_Lottery20.onClick:AddListener(function()SequenceLottery(20)end);
    -- 50连抽
    button_Lottery50.onClick:AddListener(function()SequenceLottery(50)end);
    --连抽奖励面板底部确认按钮
    button_Rewards:GetComponent("Button").onClick:AddListener(CloseRewardsWindow);
    --连抽奖励面板遮罩按钮
    button_Mask_Rewards.onClick:AddListener(function()end);
    --中奖纪录面板关闭按钮
    button_RecordClose.onClick:AddListener(CloseRecordWindow);
    --纪录面板遮罩关闭按钮
    mask_Record:GetComponent("Button").onClick:AddListener(function()end);
    --帮助界面遮罩
    mask_Help:GetComponent("Button").onClick:AddListener(function()end);
end


--关闭界面
-- function CloseUI()
--     NetMsgHandler.Send_CS_Exit_Wheel(GameData.XYZPChooseRoomLevel);
-- end

--打开【帮助】界面
function OpenHelpWindow()
    PlaySoundEffect("2");
    window_Help.gameObject:SetActive(true);
    mask_Help.gameObject:SetActive(true);
end

--关闭【帮助】界面
function Window_HelpClose()
    PlaySoundEffect("2");
    window_Help.gameObject:SetActive(false);
    mask_Help.gameObject:SetActive(false);
end

--关闭连抽【奖励】面板
function CloseRewardsWindow()
    local tempObj;
    lua_Transform_ClearChildren(parent_RewardsContent, true);
    window_Rewards.gameObject:SetActive(false);
    mask_Rewards.gameObject:SetActive(false);
    jingbipengse:SetActive(false)
end

--连抽奖励面板的显示
function Window_RewardsOpen()
    button_Rewards.gameObject:SetActive(false);
    mask_Rewards.gameObject:SetActive(true);
    window_Rewards.gameObject:SetActive(true);
    moneyAll_Rewards.text = ""..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.FortunateInfo.allMoney ));
    for k = 1, 6 do
        if k <= 6 then
            this:DelayInvoke(0.2*k, function()
                PlaySoundEffect("BCBM_light_run");
                local tempItem = CS.UnityEngine.Object.Instantiate(item_Rewards);
                CS.Utility.ReSetTransform(tempItem, parent_RewardsContent.transform);
                tempItem:GetChild(0):GetComponent("Text").text = "第"..k.."条";
                local tempMoney = GameData.FortunateInfo.table_RewardMoney[k].money;
                tempItem:GetChild(3):GetComponent("Text").text = ""..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(tempMoney));
                tempItem.gameObject:SetActive(true);
            end)
        end
    end
    this:DelayInvoke(1.2, function()
        for k = 7, GameData.FortunateInfo.time_Lottery do
            local tempItem = CS.UnityEngine.Object.Instantiate(item_Rewards);
            CS.Utility.ReSetTransform(tempItem, parent_RewardsContent.transform);
            tempItem:GetChild(0):GetComponent("Text").text = "第"..k.."条";
            local tempMoney = GameData.FortunateInfo.table_RewardMoney[k].money;
            tempItem:GetChild(3):GetComponent("Text").text = ""..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(tempMoney));
            tempItem.gameObject:SetActive(true);
        end
    end)
    this:DelayInvoke(1.2, function()
        PlaySoundEffect('HB_Gold');
        GameObjectSetActive(jingbipengse,true)
        button_Rewards.gameObject:SetActive(true);
    end)
end

--关闭【中奖纪录】面板
function CloseRecordWindow()
    window_Record.gameObject:SetActive(false);
    mask_Record.gameObject:SetActive(false);
    lua_Transform_ClearChildren(parent_RecordContent, true);
end

--【中奖纪录】面板的展示
function Window_MyRecord()
    button_Record.interactable = false
    NetMsgHandler.Send_CS_Wheel_Record();
end

--开始抽奖
function StartLottery()
    SetRewardinteractable(false)
    Image_Center_Unable.gameObject:SetActive(true);
    NetMsgHandler.Send_CS_Daily_Wheel_Reward(GameData.XYZPChooseRoomLevel, 1)
    for k = 1, 27 do
        table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 0.5);
    end
end

--连抽
function SequenceLottery(time_Lottery)
    SetRewardinteractable(false)
    NetMsgHandler.Send_CS_Daily_Wheel_Reward(GameData.XYZPChooseRoomLevel, time_Lottery);
    for k = 1, 27 do
        table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 0.5);
    end
end

-- 设置轮盘按钮是否可点击状态
function SetRewardinteractable( state )
    for k = 1, 3 do
        table_SeriesLottery[k].interactable = state
    end
    button_StartLottery.interactable = state
end

--初始化数值
function InitValues()
    time_OutCircle = 0;
    time_OutLight = 0;
    flag_Blink = true;
    isStandby = true;
    isLottery = false;
    isEndLottey = false;
    count_Lottery = 0;
    IsExit = true;
    last_MoneyCount = GameData.RoleInfo.GoldCount
    text_CoinCount.text = ""..tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount),2));
    local tempRommType = GameData.XYZPChooseRoomLevel;
    if tempRommType == 1 then
    elseif tempRommType == 2 then
        tempRommType = 2.5;
    elseif tempRommType == 3 then
        tempRommType = 5;
    else
    end
    Level=GameData.XYZPChooseRoomLevel;
    local tempNum_Money = 0;
    if Level == 1 then
        tempNum_Money = 2;
    elseif Level == 2 then
        tempNum_Money = 5;
    elseif Level == 3 then
        tempNum_Money = 10;
    end
    changePartCircle = true;
    

    this.transform:Find("Canvas/Window/RewardImage").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Mask_Help").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Window_Record").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Mask_Rewards").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/RewardsImage").gameObject:SetActive(false);
    this.transform:Find("Canvas/Window/Bottom/Below/Button_1/Text_Count"):GetComponent("Text").text = ""..math.floor(10 * GameData.FortunateInfo.RotateOnceGold);
    this.transform:Find("Canvas/Window/Bottom/Below/Button_2/Text_Count"):GetComponent("Text").text = ""..math.floor(20 * GameData.FortunateInfo.RotateOnceGold);
    this.transform:Find("Canvas/Window/Bottom/Below/Button_3/Text_Count"):GetComponent("Text").text = ""..math.floor(50 * GameData.FortunateInfo.RotateOnceGold);

end

---------   动画系列   ---------

function Animation_Normal()          --常态动画
    --外圈灯泡
    if time_OutLight >= 0.1 then
        if flag_Blink then
            for k = 1, 27 do
                if k % 2 == 0 then
                    table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 0.5);
                else
                    table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 1);
                end
            end
        else
            for k = 1, 27 do
                if k % 2 == 0 then
                    table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 1);
                else
                    table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 0.5);
                end
            end
        end
        flag_Blink = not flag_Blink;
        time_OutLight = 0;
    end
    --外环圈(4小节)
    if time_OutCircle >= 1 then
        changePartCircle = not changePartCircle;
        if changePartCircle then
            for k = 1, 4 do
                GameObjectSetActive(table_PartCircle[k],true)
            end
            for k = 5, 8 do
                GameObjectSetActive(table_PartCircle[k],false)
            end
        else
            for k = 1, 4 do
                GameObjectSetActive(table_PartCircle[k],false)
            end
            for k = 5, 8 do
                GameObjectSetActive(table_PartCircle[k],true)
            end
        end
        time_OutCircle = 0;
    end
end

function Animation_Lottery(tempObj1, tempObj2)         --抽奖时的动画
   if tempObj2 == nil then
        for k = 1, 27 do
            if ((360 -tempObj1.eulerAngles.z) - 30) < k * 11.2  and k * 11.2 < ((360 -tempObj1.eulerAngles.z)-15) then
                table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 1);
                table_Light_Out[k].localScale = CS.UnityEngine.Vector3(2, 2, 1);
            else
                table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 0.5);
                table_Light_Out[k].localScale = CS.UnityEngine.Vector3(1, 1, 1);
            end
        end
    else
        for k = 1, 27 do
            if ((360 -tempObj1.eulerAngles.z) - 30) < k * 11.2  and k * 11.2 < ((360 -tempObj1.eulerAngles.z)-15) or
               ((360 -tempObj2.eulerAngles.z) - 30) < k * 11.2  and k * 11.2 < ((360 -tempObj2.eulerAngles.z)-15)
            then
                table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 1);
                table_Light_Out[k].localScale = CS.UnityEngine.Vector3(2, 2, 1);
            else
                table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 0.5);
                table_Light_Out[k].localScale = CS.UnityEngine.Vector3(1, 1, 1);
            end
        end
   end
    
end

function Animation_EndLottery()     --结束抽奖时的动画
    
    local tempPos = GameData.FortunateInfo.level_LastLottery;
    -- tempPos = tempPos + 1;
    local OppositePos = (tempPos + 4) % 8;
    if tempPos == 4 then
        OppositePos = 8;
    end
    for k = 1, 3 do
        this:DelayInvoke(0.08*(k-1), function()
            --左侧的效果
            local tempNum1 = OppositePos + k;
            if tempNum1 ~= 8 then
                tempNum1 = tempNum1 % 8;
            end
            -- table_Light_Sector[tempNum].transform.localRotation = CS.UnityEngine.Quaternion.Euler(CS.UnityEngine.Vector3(0, 0, -45*OppositePos+k));
            table_Light_Sector[tempNum1].transform.localRotation = table_Light_Sector[OppositePos].transform.localRotation;
            
            table_Light_Sector_Rotation[tempNum1].from = CS.UnityEngine.Vector3(0, 0, -45*(OppositePos-1));
            table_Light_Sector_Rotation[tempNum1].to = CS.UnityEngine.Vector3(0, 0, -45 * (OppositePos + 3));
            table_Light_Sector[tempNum1].gameObject:SetActive(true);
            table_Light_Sector_Image[tempNum1].color = CS.UnityEngine.Color(255, 255, 255, 1-(k-1)*0.3);
            table_Light_Sector_Rotation[tempNum1]:ResetToBeginning();
            table_Light_Sector_Rotation[tempNum1]:Play(true);
            this:DelayInvoke(0.3, function()
                table_Light_Sector[tempNum1].gameObject:SetActive(false);
            end)
            --右侧的效果
            local tempNum2 = OppositePos - k;
            if tempNum2 < 0 then
                tempNum2 = (tempNum2 + 8)%8; 
            elseif tempNum2 == 0 then
                tempNum2 = 1
            end
            table_Light_Sector[tempNum2].transform.localRotation = table_Light_Sector[OppositePos].transform.localRotation;
            table_Light_Sector_Rotation[tempNum2].from = CS.UnityEngine.Vector3(0, 0, -45*(OppositePos -1)) ;
            table_Light_Sector_Rotation[tempNum2].to = CS.UnityEngine.Vector3(0, 0, -45*(OppositePos - 1)+180);
            table_Light_Sector[tempNum2].gameObject:SetActive(true);
            table_Light_Sector_Image[tempNum2].color = CS.UnityEngine.Color(255, 255, 255, 1-(k-1)*0.3);
            table_Light_Sector_Rotation[tempNum2]:ResetToBeginning();
            table_Light_Sector_Rotation[tempNum2]:Play(true);
            this:DelayInvoke(0.3, function()
                table_Light_Sector[tempNum2].gameObject:SetActive(false);
            end)
            if k == 1 then
                tempObj1 = table_Light_Sector[tempNum1];
                tempObj2 = table_Light_Sector[tempNum2];
            end
            isEndLottey = true;
        end)
    end
    this:DelayInvoke(0.2, function()
        for k = 1, 3 do
            this:DelayInvoke(0.2*(k-1), function()
                --内环的效果
            --local CircleTS = table_Circle[k]:GetComponent("TweenScale");
            table_TweenScale[k]:ResetToBeginning();
            table_TweenScale[k]:Play(true);
            --local CircleTA = table_Circle[k]:GetComponent("TweenAlpha");
            table_TweenAlpha[k]:ResetToBeginning();
            table_TweenAlpha[k]:Play(true);
            end)
        end
    end)
    this:DelayInvoke(1.8, function()
        for k = 1, 8 do
            table_Light_Sector[k].gameObject:SetActive(false);
        end
        isEndLottey = false;
    end)
end

function Animation_CoinFly(coinCount)        ---金币飞特效
    if coinCount == 20 then
        for k = 1, 20 do
            this:DelayInvoke(0.05*(k-1), function()
                table_Coin[k].gameObject:SetActive(true);
                local tempCoinTP = table_Coin[k]:GetComponent("TweenPosition");
                local tempCoinTA = table_Coin[k]:GetComponent("TweenAlpha");
                icon_Coin_Start = this.transform:Find("Canvas/Window/RewardsImage/Above/Icon_Coin");
                icon_Coin_End = this.transform:Find("Canvas/Window/RewardsImage/Above/Icon_Coin_End");
                tempCoinTP.from = icon_Coin_Start.localPosition;
                tempCoinTP.to = icon_Coin_End.localPosition;
    
                tempCoinTP.duration = 0.3;
                tempCoinTA.duration = 0.04;
                tempCoinTP:ResetToBeginning();
                tempCoinTA:ResetToBeginning();
                tempCoinTP:Play(true);
                tempCoinTA:Play(true);
                PlaySoundEffect("XYZP_coinfly");
            end)
        end
        this:DelayInvoke(1.2, function()
            -- GameData.SyncDisplayGoldCount();
            button_Rewards.gameObject:SetActive(true);
        end)
    end
    if coinCount == 5 then
        for k = 1, 5 do
            this:DelayInvoke(0.05*(k-1), function()
                table_Coin2[k].gameObject:SetActive(true);
                local tempCoinTP = table_Coin2[k]:GetComponent("TweenPosition");
                local tempCoinTA = table_Coin2[k]:GetComponent("TweenAlpha");
                icon_Coin_Start2 = this.transform:Find("Canvas/Window/RewardImage/Image");
                icon_Coin_End2 = this.transform:Find("Canvas/Window/RewardImage/Coin_End");
                tempCoinTP.from = icon_Coin_Start2.localPosition;
                tempCoinTP.to = icon_Coin_End2.localPosition;

                tempCoinTP.duration = 0.2;
                tempCoinTA.duration = 0.1;
                tempCoinTP:ResetToBeginning();
                tempCoinTA:ResetToBeginning();
                tempCoinTP:Play(true);
                tempCoinTA:Play(true);
                PlaySoundEffect("XYZP_coinfly");
            end)
        end
        this:DelayInvoke(1.2, function()
            button_Rewards.gameObject:SetActive(true);
        end)
    end
end

--获得抽奖纪录并打开中奖纪录面板
function GetWinRecord(resultType)
    button_Record.interactable = true
    if resultType == 0 then
        window_Record.gameObject:SetActive(true);
        mask_Record.gameObject:SetActive(true);
        local recordCount = GameData.FortunateInfo.recordCount;
        for k = 1, recordCount do
            local tempItem = CS.UnityEngine.Object.Instantiate(item_Record);
            CS.Utility.ReSetTransform(tempItem, parent_RecordContent.transform);
            tempItem:GetChild(0):GetComponent("Text").text = ""..GameData.FortunateInfo.table_Record[k].date;
            tempItem:GetChild(1):GetComponent("Text").text = ""..GameData.FortunateInfo.table_Record[k].time;
            local tempCount = GameData.FortunateInfo.table_Record[k].count;
            tempItem:GetChild(2):GetComponent("Text").text = ""..tempCount;
            local tempMoney = GameData.FortunateInfo.table_Record[k].money;
            tempItem:GetChild(3):GetComponent("Text").text = ""..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(tempMoney))
            tempItem.gameObject:SetActive(true);
        end
    end
end


--<<-------------------------------------   TUDOU   ------------------------------------------

function  InitRoomInfo()
    this:StopAllDelayInvoke();
    MusicMgr:StopAllSoundEffect();
    InitValues();
end

-- UI刷新
function RefreshWindowData(windowData)
    HandleUIDefaultShow()
end

--刷新金币值
function RefreshGoldCount()
    local displayCount = GameData.RoleInfo.DisplayGoldCount;
    local cacheCount = GameData.RoleInfo.Cache.ChangeGoldCount;
    text_CoinCount.text = tostring(lua_GetPreciseDecimal(GameConfig.GetFormatColdNumber(displayCount),2));
end

-- 关闭UIcall
function CloseUI()
    if IsExit then
        NetMsgHandler.Send_CS_Exit_Wheel(GameData.XYZPChooseRoomLevel)
    else
        CS.BubblePrompt.Show(data.GetString("Bouns_Wheel_Promt"),"BonusWheelUI")
    end
end

-- UI默认状态处理
function HandleUIDefaultShow()
    HandleWheelLightShow(0)
    mRewardPointerGameObject:SetActive(true)
    mRewardPointerTweenRotation.enabled = false
    mRewardPointerTweenRotation.transform.localEulerAngles = CS.UnityEngine.Vector3(0,0,0)
    WheelWinInfoDisplay()
end

-- 轮盘动画
function HandleWheelAnimation()
    isLottery = true;
    isStandby = false;
    local tempNum = 0;
    if GameData.XYZPChooseRoomLevel == 1 then
        tempNum = 2;
    elseif GameData.XYZPChooseRoomLevel == 2 then
        tempNum = 5;
    elseif GameData.XYZPChooseRoomLevel == 3 then
        tempNum = 10;
    end
    local Num = GameData.FortunateInfo.playerMoney - GameData.FortunateInfo.allMoney - GameData.FortunateInfo.time_Lottery*tempNum;
    Image_Center_Unable.gameObject:SetActive(true);
    GameObjectSetActive(center_Rotate_Objects_Arrow,true)
    GameObjectSetActive(center_Rotate_Objects_Sector,true)
    for k = 1, 27 do
        table_Light_Out_Image[k].color = CS.UnityEngine.Color(255, 255, 255, 0.5);
    end
    SetRewardinteractable(false)
    HandleWheelLightShow(0)
    mRewardPointerGameObject:SetActive(true)
    this:DelayInvoke(0, function()
        PlaySoundEffect("XYZP_sector_run")
        mRewardPointerTweenRotation.from = CS.UnityEngine.Vector3(0, 0, 0);
        mRewardPointerTweenRotation.to = CS.UnityEngine.Vector3(0, 0, -45*(24 + GameData.FortunateInfo.level_LastLottery-1));
        mRewardPointerTweenRotation.duration = 1.4;
        mRewardPointerTweenRotation:ResetToBeginning();
        mRewardPointerTweenRotation:Play(true);
        tail_TR.from = CS.UnityEngine.Vector3(0, 0, 0);
        tail_TR.to = CS.UnityEngine.Vector3(0, 0, -45*(24 + GameData.FortunateInfo.level_LastLottery-1));
        tail_TR.duration = 1.4;
        tail_TR:ResetToBeginning();
        tail_TR:Play(true);
    end)
    this:DelayInvoke(0.06, function()
        tail_1.gameObject:SetActive(true);
    end)
    this:DelayInvoke(0.12, function()
        tail_2.gameObject:SetActive(true);
    end)
    
    --收尾
    --print("############## 终点 ", GameData.FortunateInfo.level_LastLottery );
    this:DelayInvoke(1.4, function()
        -- mengBan.gameObject:SetActive(false);
        tail_TR.from = CS.UnityEngine.Vector3(0, 0, -45*(24 + GameData.FortunateInfo.level_LastLottery-1));
        tail_TR.to = CS.UnityEngine.Vector3(0, 0, -45*(24 + GameData.FortunateInfo.level_LastLottery+1));
        tail_TR.duration = 0.2;
        tail_TR:ResetToBeginning();
        tail_TR:Play(true);
        
    end)
    this:DelayInvoke(1.48, function()
        tail_1.gameObject:SetActive(false);
    end)
    this:DelayInvoke(1.58, function()
        tail_2.gameObject:SetActive(false);
       
    end)
    this:DelayInvoke(1.6, function()
        Animation_EndLottery();
    end)
    local tTagetIndex = mWheelLightTagIndex
    local tTagetAnglesZ = mLightRotation[tTagetIndex];
    
    this:DelayInvoke(3,function()
        HandleRewardImageInfo()
        text_CoinCount.text = ""..lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(GameData.FortunateInfo.playerMoney));
    end)

    this:DelayInvoke(5, function()
        HandleRewardImageState(false)
        button_Close.interactable = true
    end)

    this:DelayInvoke(5, function()
        isLottery = false;
        isStandby = true;
        IsExit = true;
        button_Close.interactable = true
        
        SetRewardinteractable(true)
        Image_Center_Unable.gameObject:SetActive(false);
        --center_Rotate_Objects.transform:Find("Sector").gameObject:SetActive(false);
        GameObjectSetActive(center_Rotate_Objects_Sector,false)
        mRewardPointerTweenRotation.from = CS.UnityEngine.Vector3(0, 0, 0);
        mRewardPointerTweenRotation.to = CS.UnityEngine.Vector3(0, 0, 0);
        mRewardPointerTweenRotation.duration = 0;
        mRewardPointerTweenRotation:Play(true);
        for k =1 , 27 do
            table_LightOut_TS[k]:ResetToBeginning();
        end
    end)
end

-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(musicid)
end

-- 处理轮盘显示
function HandleWheelLightShow(_showPos)
    for index = 1, 8, 1 do
        local tShowParam = _showPos == index
        if mLightGameObjects[index].activeSelf ~= tShowParam then
            mLightGameObjects[index]:SetActive(tShowParam)
        end
    end
end

-- 处理配置相关数据
function OnNotifyWheelRewardEvent(_resultType)
    if _resultType == 0 then
        IsExit = false;
        button_Close.interactable = false;
        count_Lottery = GameData.FortunateInfo.time_Lottery;
        mWheelLightTagIndex = GameData.FortunateInfo.level_LastLottery;

        --播放转盘旋转动画
        HandleWheelAnimation()
    else
        Image_Center_Unable.gameObject:SetActive(false);
        SetRewardinteractable(true)
    end
end

-- 获得奖励处理
function HandleRewardImageInfo()
    if count_Lottery > 1 then
        Window_RewardsOpen();
    else
        --mRewardImageText.text = lua_CommaSeperate(HandleRewardValueByConfig(GameData.FortunateInfo.level_LastLottery+(Level*8)-8))
        mRewardImageText.text = lua_CommaSeperate(GameData.FortunateInfo.WinningGradegOLD[GameData.FortunateInfo.level_LastLottery])
        HandleRewardImageState(true)
    end
    PlaySoundEffect('WheelGold')
end

-- 奖励模块显示
function HandleRewardImageState(_show)
    mRewardImageGameObject:SetActive(_show)
    if _show then
        PlaySoundEffect('HB_Gold');
        GameObjectSetActive(jingbipengse,true)
        this:DelayInvoke(3, function()
            GameObjectSetActive(jingbipengse,false)
        end)
    end
end

-- 获取对应等级奖励数据
function HandleRewardValueByConfig(_index)
    local tValue = 0
    if _index <= 0 or _index >24 then
        _index = 1
    end
    tValue = data.TurnTableConfig[_index].Reward
    return tValue
end

-- 响应分享按钮
function ShareOnClick()

end

-- 获奖玩家信息显示
function WheelWinInfoDisplay()
    if #GameData.WheelWinInfo>=1 and IsUpdatePlay == false then
        mWheelWinGameObject:SetActive(true)
        mWheelWinGameObjectText.text=string.format(data.GetString("JH_Wheel_WinningMessage"),GameData.WheelWinInfo[1].StrLoginIP,GameData.WheelWinInfo[1].PlayerGold)
        this:DelayInvoke(2.8,function()
            table.remove(GameData.WheelWinInfo,1)
        end)
        mWheelWinTweenPosition:ResetToBeginning()
        mWheelWinTweenPosition:Play(true)
        IsUpdatePlay = true
    elseif #GameData.WheelWinInfo == 0 then
        mWheelWinGameObject:SetActive(false)
        IsUpdatePlay=false
    end
end

function Update()
    if IsUpdatePlay == true then
        PlayTimer = PlayTimer-Time.deltaTime
        if PlayTimer <= 0 then
            IsUpdatePlay=false
            WheelWinInfoDisplay()
            PlayTimer = 16.3
        end
    end
    if isLottery then
        Animation_Lottery(center_Rotate_Objects);
    end
    if isEndLottey then
        Animation_Lottery(tempObj1, tempObj2);
    end
    time_OutLight = time_OutLight + Time.deltaTime;
    time_OutCircle = time_OutCircle + Time.deltaTime;
    if isStandby then
        Animation_Normal();

    end
end

function OnDestroy()
    lua_Call_GC()
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    CS.MatchLoadingUI.Hide();
    GameData.GameState = GAME_STATE.ROOM
    GameData.RoomInfo.CurrentRoom.RoomType = ROOM_TYPE.LuckyWheel
end

function Awake()
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
    --HandleRefreshHallUIShowState(false);
    GetAllObjects();
    AddClickEvents();
    this:StopAllDelayInvoke();
    MusicMgr:StopAllSoundEffect();
    InitValues();

    mRewardButton = this.transform:Find("Canvas/Window/Wheel/RewardButton"):GetComponent("Button")
    local  consumeGold= this.transform:Find("Canvas/Window/ShareText"):GetComponent("Text")
        --consumeGold.text =string.format(data.GetString('XUZP_ConsumeGold'),lua_CommaSeperate(data.TurnTableConfig[(Level*8)].Gold))
        consumeGold.text =string.format(data.GetString('XUZP_ConsumeGold'),lua_CommaSeperate(GameData.FortunateInfo.RotateOnceGold))
    for index = 1, 8, 1 do
        mLightGameObjects[index] = this.transform:Find("Canvas/Window/Wheel/Light/zp_box_choose"..index).gameObject
        local tRewardValueText = this.transform:Find("Canvas/Window/Wheel/RewardValues/Text"..index):GetComponent("Text")
        --tRewardValueText.text = ""..lua_CommaSeperate(HandleRewardValueByConfig(index+(Level*8)-8))
        tRewardValueText.text = ""..lua_CommaSeperate(GameData.FortunateInfo.WinningGradegOLD[index])
    end
    mWheelWinGameObject = this.transform:Find("Canvas/Window/WinningInfo").gameObject
    mWheelWinGameObjectText = mWheelWinGameObject:GetComponent('Text')
    mWheelWinTweenPosition = this.transform:Find("Canvas/Window/WinningInfo/Text"):GetComponent("TweenPosition")
    mRewardImageGameObject = this.transform:Find("Canvas/Window/RewardImage").gameObject
    this.transform:Find("Canvas/Window/RewardImage/MaskImage"):GetComponent("Button").onClick:AddListener(function() HandleRewardImageState(false) end)
    mRewardImageText = this.transform:Find("Canvas/Window/RewardImage/Text"):GetComponent('Text')
    mRewardPointerGameObject  = this.transform:Find("Canvas/Window/Wheel/RewardPointer").gameObject
    mRewardPointerTweenRotation = this.transform:Find("Canvas/Window/Wheel/RewardPointer"):GetComponent("TweenRotation")
    mRewardPointerGameObject:SetActive(false)
    HandleRewardImageState(false)
    if GameConfig.IsSpecial() == true then
        this.transform:Find("Canvas/Window/ShareText").gameObject:SetActive(false)this.transform:Find("Canvas/Window/ShareText").gameObject:SetActive(false)
    end

    jingbipengse = this.transform:Find("Canvas/jingbipengse/01").gameObject

end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyWheelRewardEvent, OnNotifyWheelRewardEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyWheelUpdateWinInfo, WheelWinInfoDisplay)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyWheelWinRecord, GetWinRecord);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.SyncUpdateGold, RefreshGoldCount);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.InitRoomState, InitRoomInfo);
    MusicMgr:PlayBackMusic("BG_XYZP")
end

function WindowClosed() 
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyWheelRewardEvent, OnNotifyWheelRewardEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyWheelUpdateWinInfo, WheelWinInfoDisplay)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyWheelWinRecord, GetWinRecord)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.SyncUpdateGold, RefreshGoldCount);
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.InitRoomState, InitRoomInfo);
    -- UI 关闭时 停掉所有的音效并停止挂起的携程
    MusicMgr:StopAllSoundEffect()
    -- 停止掉所有的协程
    this:StopAllDelayInvoke()
end