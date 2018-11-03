--[[
   文件名称:DZHallUI.lua
   创 建 人:土豆陛下
   创建时间：2018-9-27
   功能描述：新版房间列表(多人厅)
]]--

--region 定义变量

local currentRoomType = 0;      -- 当前房间类型

-- 房间信息
local roomInfo = {};

local PlayerInfo = {
    vipLevel = 0,               -- VIP等级
    playerID = 0,               -- ID
    textName = "",              -- 昵称
    goldAmount = 0,             -- 金币数量
    imgHead = "",               -- 头像
}      -- 玩家信息显示物体

--local imgGameType = nil;        -- 游戏类型

local noticeObj = nil;          -- 跑马灯

local Buttons = {
    -- 该局部数组说明如下:
    -- 数组.x 为第x个游戏类型的按钮
    returnBtn = nil,            -- 返回按钮
    startBtn = nil,             -- 快速游戏按钮
}

local AllRoomType = {
    -- 该数组说明如下:
    -- [X][1]:  Obj 房间类型Obj
    -- [X][2]:  Text 底注
    -- [X][3]:  房间类型([初级场] [中级场] [高级场])
    -- [X][4]:  房间类型([平民场] [小资场] [老板场] [土豪场] [贵族场] [皇家场])
    -- [X][5]:  Text 准入金币数量
    -- [X][6]:  Text 房间内玩家人数
    -- [X][7]:  房间状态(【流畅】)
    -- [X][8]:  房间状态(【火爆】)
    -- [X][9]:  房间状态(【维护】)
    -- [X][10]: 准入Text
    -- [X][11]: 玩家头像图
    -- [X][12]: 敬请期待
}     -- 房间游戏类型

local AllPosition = {
    -- 该数组说明如下:
    -- [m][n]: 游戏类型为m，位置为n
}     -- 所有的位置

-- 房间类型名字索引
--local GameTypeIndex = {
--    [ROOM_TYPE.MenJi] = 1,
--    [ROOM_TYPE.PiPeiNN] = 2,
--    [ROOM_TYPE.PPHongBao] = 3,
--    [ROOM_TYPE.PiPeiTTZ] = 4,
--    [ROOM_TYPE.LuckyWheel] = 5,
--    [ROOM_TYPE.BMWBENZ] = 6,
--    [ROOM_TYPE.PiPeiPDK] = 7,
--}

-- 房间状态
local RoomState =
{
    [1] = 0,        -- 未选择
    [2] = 1,        -- 敬请期待
    [3] = 2,        -- 上架
    [4] = 3,        -- 下架
    [5] = 4,        -- 无本档次
}

-- 房间标签状态
local RoomLable =
{
    [1] = 0,        -- 未选择
    [2] = 1,        -- 无
    [3] = 2,        -- 流畅
    [4] = 3,        -- 火爆
    [5] = 4,        -- 无本场此
    [6] = 5,        -- 维护
}

-- 右上角的游戏名称Obj
local GameNameImgObj = {
    -- 1: 炸金花
    -- 2: 抢庄牛牛
    -- 3: 红包接龙
    -- 4: 推筒子
    -- 5: 幸运转盘
    -- 6: 奔驰宝马
    -- 7: 跑得快
    -- 8: 时时彩
}
-- 房间类型 index
local gameTypeIndex = 0;

--endregion

--region 逻辑函数

-- 获取界面内的物体及其组件
function GetAllObject()
    -- 玩家信息区域
    PlayerInfo.imgHead = this.transform:Find("Canvas/TopArea/RoleIcon"):GetComponent("Image");
    PlayerInfo.vipLevel = this.transform:Find("Canvas/TopArea/Vip/Level"):GetComponent("Text");
    PlayerInfo.playerID = this.transform:Find("Canvas/TopArea/RoleID/ID"):GetComponent("Text");
    PlayerInfo.textName = this.transform:Find("Canvas/TopArea/RoleName/Name"):GetComponent("Text");
    PlayerInfo.goldAmount = this.transform:Find("Canvas/TopArea/Gold/Amount"):GetComponent("Text");

    --imgGameType = this.transform:Find("Canvas/TopArea/Logo_Icon/GameName"):GetComponent("Image");
    noticeObj = this.transform:Find("Canvas/TopArea/Notice").gameObject;

    -- 右上角游戏名称Img
    for index = 1, 8 do
        GameNameImgObj[index] = this.transform:Find("Canvas/TopArea/Logo_Icon/GameName"..index).gameObject;
    end

    -- 游戏类型
    local tempPath1 = "Canvas/CenterArea/AllTypes/Type";
    for index = 1, 6 do
        AllRoomType[index] = {};
        AllRoomType[index][1] = this.transform:Find(tempPath1..index).gameObject;
        AllRoomType[index][2] = this.transform:Find(tempPath1..index.."/Rate"):GetComponent("Text");
        AllRoomType[index][3] = this.transform:Find(tempPath1..index.."/TypeName1").gameObject;
        AllRoomType[index][4] = this.transform:Find(tempPath1..index.."/TypeName2").gameObject;
        AllRoomType[index][5] = this.transform:Find(tempPath1..index.."/AccessAmount"):GetComponent("Text");
        AllRoomType[index][6] = this.transform:Find(tempPath1..index.."/PlayerAmount"):GetComponent("Text");
        AllRoomType[index][7] = this.transform:Find(tempPath1..index.."/RoomState1").gameObject;
        AllRoomType[index][8] = this.transform:Find(tempPath1..index.."/RoomState2").gameObject;
        AllRoomType[index][9] = this.transform:Find(tempPath1..index.."/RoomState3").gameObject
        AllRoomType[index][10] = this.transform:Find(tempPath1..index.."/Flag1").gameObject;
        AllRoomType[index][11] = this.transform:Find(tempPath1..index.."/Flag2").gameObject;
        AllRoomType[index][12] = this.transform:Find(tempPath1..index.."/JQQD").gameObject;
        --Buttons[index] = this.transform:Find(tempPath1..index):GetComponent("Button");
    end

    -- 所有的位置
    local tempPath2 = "Canvas/CenterArea/Position";
    for m = 1, 6 do
        AllPosition[m] = {};
        for n = 1, m do
            AllPosition[m][n] = this.transform:Find(tempPath2..m.."/Point"..n).localPosition;
        end
    end

    Buttons.InformationBtn = this.transform:Find("Canvas/TopArea/RoleIcon"):GetComponent("Button");
    Buttons.GoldBtn = this.transform:Find("Canvas/TopArea/Gold"):GetComponent("Button");
    Buttons.returnBtn = this.transform:Find("Canvas/BottomArea/Return"):GetComponent("Button");
    Buttons.startBtn = this.transform:Find("Canvas/BottomArea/AutoMatch"):GetComponent("Button");
end

-- 添加点击事件
function AddClickEvents()
    Buttons.InformationBtn.onClick:AddListener(InformationBtn);
    Buttons.GoldBtn.onClick:AddListener(OnBtnShopClick);
    Buttons.returnBtn.onClick:AddListener(ReturnToTheHall);
    Buttons.startBtn.onClick:AddListener(StartToMatchRoom);
end

-- 获取基本数据
function GetBasicData()
    currentRoomType = GameData.RoomInfo.RoomList_Type;      -- 当前的房间类型
end

-- 请求房间列表信息
function RequestRoomListInformation(autoParam)
    if currentRoomType == ROOM_TYPE.MenJi then                          -- 炸金花
        gameTypeIndex = 1;
        --NetMsgHandler.Send_CS_JH_ZuJuRoomList();
        NetMsgHandler.Send_CS_JH_MenJiRoomOnlineCount(1, 2, 3, 4);
    elseif currentRoomType == ROOM_TYPE.PiPeiNN then                    -- 牛牛
        gameTypeIndex = 2;
        NetMsgHandler.Send_CS_NNRoom_RoomList();
        Send_CS_NNPP_Room_OnLine();
    elseif currentRoomType == ROOM_TYPE.PPHongBao then                  -- 红包接龙
        gameTypeIndex = 3;
        NetMsgHandler.Send_CS_HB_Room_List();
        NetMsgHandler.Send_CS_PP_HongBaoRoomOnlineCount(1, 2, 3, 4);
    elseif currentRoomType == ROOM_TYPE.PiPeiTTZ then                   -- 推筒子
        gameTypeIndex = 4;
        NetMsgHandler.Send_CS_TTZRoom_RoomList();
        NetMsgHandler.Send_CS_TTZPP_Room_OnLine();
    elseif currentRoomType == ROOM_TYPE.LuckyWheel then                 -- 幸运转盘
        gameTypeIndex = 5;
        NetMsgHandler.Send_CS_JH_XYZPRoomList();
    elseif currentRoomType == ROOM_TYPE.BMWBENZ then                    -- 奔驰宝马
        gameTypeIndex = 6;
        NetMsgHandler.Send_CS_JH_BMBCRoomList();
    elseif currentRoomType == ROOM_TYPE.PiPeiPDK then                   -- 跑得快
        gameTypeIndex = 7;
        NetMsgHandler.Send_CS_PDKPP_Room_OnLine();
    elseif currentRoomType == ROOM_TYPE.SSC then                        -- 疯狂三张
        gameTypeIndex = 8;
        NetMsgHandler.Send_CS_SSC_Request_Role_List();
    else
    end
end

-- 显示顶部信息栏的信息及游戏类型显示
function SetTopInformation()
    PlayerInfo.imgHead:ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.RoleInfo.AccountIcon));
    PlayerInfo.vipLevel.text = ""..GameData.RoleInfo.VipLevel;
    PlayerInfo.playerID.text = ""..GameData.RoleInfo.AccountID;
    PlayerInfo.textName.text = ""..GameData.RoleInfo.AccountName;
    PlayerInfo.goldAmount.text = ""..lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount));
    GameObjectSetActive(GameNameImgObj[gameTypeIndex], true);
    GameObjectSetActive(noticeObj, true);
end

-- 设置房间的人数状态 (【流畅】【火爆】【维护】)
function SetRoomPopularState(index, tempNum)

    if index == 1 then
        if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomLabel == RoomLable[3] then
            GameObjectSetActive(AllRoomType[tempNum][7], true);       -- 流畅
        elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomLabel == RoomLable[4] then
            GameObjectSetActive(AllRoomType[tempNum][8], true);       -- 火爆
        elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomLabel == RoomLable[6] then
            GameObjectSetActive(AllRoomType[tempNum][9], true);       -- 维护
        else
        end
    elseif index == 2 then
        if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomState == RoomLable[3] then
            GameObjectSetActive(AllRoomType[tempNum][7], true);       -- 流畅
        elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomState == RoomLable[4] then
            GameObjectSetActive(AllRoomType[tempNum][8], true);       -- 火爆
        elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomState == RoomLable[6] then
            GameObjectSetActive(AllRoomType[tempNum][9], true);       -- 维护
        else
        end
    elseif index == 3 then
        if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[3] then
            GameObjectSetActive(AllRoomType[tempNum][7], true);       -- 流畅
        elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[4] then
            GameObjectSetActive(AllRoomType[tempNum][8], true);       -- 火爆
        elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[6] then
            GameObjectSetActive(AllRoomType[tempNum][9], true);       -- 维护
        else
        end
    elseif index == 4 then
        if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[3] then
            GameObjectSetActive(AllRoomType[tempNum][7], true);       -- 流畅
        elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[4] then
            GameObjectSetActive(AllRoomType[tempNum][8], true);       -- 火爆
        elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[6] then
            GameObjectSetActive(AllRoomType[tempNum][9], true);       -- 维护
        else
        end
    else
    end
end

-- 刷新设置房间列表信息
function RefreshRoomListInformation()
    local roomAmount = GameData.RoleInfo.RoomAmount;
    if currentRoomType == ROOM_TYPE.SSC then
        GameData.RoleInfo.RoomConfiguration = {}
        roomAmount = 1;
        GameData.RoleInfo.RoomConfiguration[1] = {BetValueMin = 0, EnterGoldMin = 1, }
    end
    CS.MatchLoadingUI.Hide();
    for index = 1, roomAmount do
        roomInfo = GameData.RoleInfo.RoomConfiguration[index];--(包含底注，准入金币数)
        local tempNum = ((roomAmount == 2 or roomAmount == 3) and {index*2-1} or {index})[1];
        local tempButton = AllRoomType[tempNum][1].transform:GetComponent("Button");
        tempButton.onClick:AddListener(function ()
            EnterTheGame(index);
        end);
        AllRoomType[tempNum][2].text = tostring(lua_CommaSeperate(roomInfo.BetValueMin));       -- 【底注】
        if currentRoomType == ROOM_TYPE.SSC or currentRoomType == ROOM_TYPE.BMWBENZ then
            AllRoomType[tempNum][2].text = "";
        end
        AllRoomType[tempNum][5].text = tostring(lua_CommaSeperate(roomInfo.EnterGoldMin));      -- 【准入金币数】
        if roomAmount <= 3 then
            GameObjectSetActive(AllRoomType[tempNum][3], true);
        else
            GameObjectSetActive(AllRoomType[tempNum][4], true);
        end
        --local tempRoomType = RoomTypeIndex[currentRoomType];
        if index == 1 then
            if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomState == RoomState[3] then
                SetRoomPopularState(index, tempNum);
            else
                SetJQQDState(tempButton, index);
            end
        elseif index == 2 then
            if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomState == RoomState[3] then
                SetRoomPopularState(index, tempNum);
            else
                SetJQQDState(tempButton, index);
            end
        elseif index == 3 then
            if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomState == RoomState[3] then
                SetRoomPopularState(index, tempNum);
            else
                SetJQQDState(tempButton, index);
            end
        elseif index == 4 then
            if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].TycoonRoomState == RoomState[3] then
                SetRoomPopularState(index, tempNum);
            else
                SetJQQDState(tempButton, index);
            end
        else
            tempButton.enabled = false;
            local tempSprite = AllRoomType[tempNum][1].transform:GetComponent("Image");
            tempSprite.color = CS.UnityEngine.Color.grey;
            GameObjectSetActive(AllRoomType[tempNum][2], false);
            GameObjectSetActive(AllRoomType[tempNum][5], false);

        end
        AllRoomType[tempNum][1].transform.localPosition = AllPosition[roomAmount][index];
        GameObjectSetActive(AllRoomType[tempNum][1], true);
    end
end

function SetJQQDState(tempButton, index)
    tempButton.enabled = false;
    tempButton.interactable = false;
    AllRoomType[index][1].transform:GetComponent("Image").color = CS.UnityEngine.Color.grey;
    AllRoomType[index][2].text = "";
    AllRoomType[index][5].text = "";
    AllRoomType[index][6].enabled = false;
    GameObjectSetActive(AllRoomType[index][3], false);
    GameObjectSetActive(AllRoomType[index][4], false);
    GameObjectSetActive(AllRoomType[index][7], false);
    GameObjectSetActive(AllRoomType[index][8], false);
    GameObjectSetActive(AllRoomType[index][9], false);
    GameObjectSetActive(AllRoomType[index][10], false);
    GameObjectSetActive(AllRoomType[index][11], false);
    GameObjectSetActive(AllRoomType[index][12], true);
    AllRoomType[index][1].transform:GetComponent("ButtonPlayAudio").enabled = false;
    AllRoomType[index][1].transform:GetComponent("ButtonSizeChange").enabled = false;
end

-- 设置时时彩人数
function SetSSCRoomAmount(Data)
    AllRoomType[1][6].text = tostring(#Data);
end

-- 刷新匹配房间在线人数
function RefreshPlayerAmount()
    local roomAmount = GameData.RoleInfo.RoomAmount;
    local tempRoomType = RoomTypeIndex[currentRoomType];
    local tempData = nil;
    for index = 1, roomAmount do
        if currentRoomType == ROOM_TYPE.MenJi then
            tempData = GameData.MJRoomOnlineCount[index];
        elseif currentRoomType == ROOM_TYPE.PiPeiNN then
            tempData = NNGameMgr.NNRoomPPOnline[index];
        elseif currentRoomType == ROOM_TYPE.PPHongBao then
            tempData = GameData.PPHBRoomOnlineCount[index];
        elseif currentRoomType == ROOM_TYPE.PiPeiTTZ then
            tempData = TTZGameMgr.TTZRoomPPOnline[index];
        elseif currentRoomType == ROOM_TYPE.LuckyWheel then
            tempData = GameData.OnlineCount[index];
        elseif currentRoomType == ROOM_TYPE.BMWBENZ then
            tempData = GameData.BMBCOnlineCount[index];
        elseif currentRoomType == ROOM_TYPE.PiPeiPDK then
            tempData = PDKGameMgr.PDKRoomPPOnline[index];
        elseif currentRoomType == ROOM_TYPE.SSC then

        end
        local tempIndex = index;
        if roomAmount == 2 or roomAmount == 3 then
            tempIndex = index * 2 - 1;
        end
        AllRoomType[tempIndex][6].text = tostring(tempData.OnlineCount);
    end
end

-- 响应 头像按钮点击事件
function InformationBtn()
    if not GameData.RoleInfo.IsBindAccount then
         HandleRegisterRewardUI(true)
    else
        local openParam = CS.WindowNodeInitParam("PersonalUI")
        openParam.WindowData = 0
        CS.WindowManager.Instance:OpenWindow(openParam)
    end
end

-- 响应商场按钮点击事件
function OnBtnShopClick()
    GameData.Exit_MoneyNotEnough = true
    CS.WindowManager.Instance:OpenWindow("UIExtract")
end

-- 进入选择的房间
function EnterTheGame(gameType)
    if currentRoomType > ROOM_TYPE.BJLRoom then
        CS.BubblePrompt.Show("敬请期待", "DZHallUI");
        return;
    end
    local canEnterTheGame = true;
    if gameType > 0 then
        --local tempData = nil;
        local tempGoldAmount = GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount);
        --roomInfo = GameData.RoleInfo.RoomConfiguration[gameType];
        if currentRoomType == ROOM_TYPE.SSC then
            roomInfo = nil;
        else
            roomInfo = GameData.RoleInfo.RoomConfiguration[gameType];
        end
        if roomInfo ~= nil then
            if tempGoldAmount < roomInfo.EnterGoldMin then
                canEnterTheGame = false;
                local boxData = CS.MessageBoxData();
                boxData.Title = "温馨提示";
                local tempParam1 = data.GetString("JH_Enter_MJRoom_Tips");
                local tempParam2 = lua_NumberToStyle1String(roomInfo.EnterGoldMin)
                boxData.Content = string.format(tempParam1, tempParam2, roomInfo.RoomName);
                boxData.Style = 1;
                boxData.OKButtonName = "确定";
                GameData.Exit_MoneyNotEnough = true;
                boxData.LuaCallBack = RoomList_GoldNotEnoughConfirmOnClick;
                CS.MessageBoxUI.Show(boxData);
            elseif tempGoldAmount > roomInfo.EnterGoldMax then
                canEnterTheGame = false;
                local tempParam1 = data.GetString("JH_Enter_MJRoom_Tips2");
                local tempParam2 = lua_NumberToStyle1String(roomInfo.EnterGoldMax);
                CS.BubblePrompt.Show(string.format(tempParam1, tempParam2), "DZHallUI");
            else
            end
        end
    end
    if canEnterTheGame then

        if currentRoomType == ROOM_TYPE.MenJi then
            NetMsgHandler.Send_CS_JH_Enter_Room2(gameType,0);
        elseif currentRoomType == ROOM_TYPE.PiPeiNN then
            Send_CS_NNPP_Enter_Room(gameType,0);
        elseif currentRoomType == ROOM_TYPE.PPHongBao then
            gameType=gameType+6;
            NetMsgHandler.Send_CS_HB_Enter_Room1(0,gameType);
        elseif currentRoomType == ROOM_TYPE.PiPeiTTZ then
            NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(0,gameType);
        elseif currentRoomType == ROOM_TYPE.LuckyWheel then
            NetMsgHandler.Send_CS_Daily_Wheel_Info(gameType);
        elseif currentRoomType == ROOM_TYPE.BMWBENZ then
            NetMsgHandler.Send_CS_CarInfo(gameType);
        elseif currentRoomType == ROOM_TYPE.PiPeiPDK then
            NetMsgHandler.Send_CS_PDKPP_Enter_Room(gameType,0);
        elseif currentRoomType == ROOM_TYPE.SSC then
            NetMsgHandler.ProcessingLottery();
        end
    end
end

-- 金币不足提示按钮操作CallFunc
function RoomList_GoldNotEnoughConfirmOnClick(resultType)
    if resultType == 1 then
        GameData.Exit_MoneyNotEnough = true;
        GameConfig.OpenStoreUI();
    end
end

-- 在大厅时，切出去切回来，大厅房间列表未刷新
function OnNotifyHallUpdateEvent()
    if this.gameObject.activeSelf == true then
        --TrySend_CS_NNRoom_RoomList(false);
    end
end

-- 返回大厅
function ReturnToTheHall()
    GameData.RoomInfo.RoomList_Type = ROOM_TYPE.None;
    GameData.HallData.SelectType = ROOM_TYPE.None;
    HandleRefreshHallUIShowState(true)
    CS.WindowManager.Instance:CloseWindow("DZHallUI",false);
end
-- 【快速游戏】
function StartToMatchRoom()
    if currentRoomType == ROOM_TYPE.SSC then
        NetMsgHandler.ProcessingLottery();
        return;
    end
    local roomAmount = GameData.RoleInfo.RoomAmount;
    local goldAmount = GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount);
    local canEnterTheGame = false;
    local tempRoomIndex = 0;
    for index = roomAmount, 1, -1 do
        if goldAmount >= GameData.RoleInfo.RoomConfiguration[index].EnterGoldMin then
            if goldAmount > GameData.RoleInfo.RoomConfiguration[index].EnterGoldMax then
                canEnterTheGame = false
                local tempMax = GameData.RoleInfo.RoomConfiguration[index].EnterGoldMax;
                local desc = string.format(data.GetString("MJ_Enter_Room_Error_8"));
                CS.BubblePrompt.Show(desc ,"DZHallUI");
                break;
            end
            local tempLevel = GameData.RoleInfo.RoomConfiguration[index].RoomLevel;
            if tempLevel == 1 then
                if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomState == RoomState[3] then
                    canEnterTheGame = true;
                    tempRoomIndex = index;
                    break;
                end
            elseif tempLevel == 2 then
                if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomState == RoomState[3] then
                    canEnterTheGame = true;
                    tempRoomIndex = index;
                    break;
                end
            elseif tempLevel == 3 then
                if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomState == RoomState[3] then
                    canEnterTheGame = true;
                    tempRoomIndex = index;
                    break;
                end
            elseif tempLevel == 4 then
                if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].TycoonRoomState == RoomState[3] then
                    canEnterTheGame = true;
                    tempRoomIndex = index;
                    break;
                end
            else
            end
        else
        end
    end

    if canEnterTheGame then
        if currentRoomType == ROOM_TYPE.MenJi then
            NetMsgHandler.Send_CS_JH_Enter_Room2(tempRoomIndex,0);
        elseif currentRoomType == ROOM_TYPE.PiPeiNN then
            Send_CS_NNPP_Enter_Room(tempRoomIndex,0);
        elseif currentRoomType == ROOM_TYPE.PPHongBao then
            tempRoomIndex = tempRoomIndex + 6;
            NetMsgHandler.Send_CS_HB_Enter_Room1(0,tempRoomIndex);
        elseif currentRoomType == ROOM_TYPE.PiPeiTTZ then
            NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(0,tempRoomIndex);
        elseif currentRoomType == ROOM_TYPE.LuckyWheel then
            NetMsgHandler.Send_CS_Daily_Wheel_Info(tempRoomIndex);
        elseif currentRoomType == ROOM_TYPE.BMWBENZ then
            NetMsgHandler.Send_CS_CarInfo(tempRoomIndex);
        elseif currentRoomType == ROOM_TYPE.PiPeiPDK then
            NetMsgHandler.Send_CS_PDKPP_Enter_Room(tempRoomIndex,0);
        else
        end
    else
        local tempMin = GameData.RoleInfo.RoomConfiguration[1].EnterGoldMin;
        local tempName = GameData.RoleInfo.RoomConfiguration[1].RoomName;
        canEnterTheGame = false;
        local boxData = CS.MessageBoxData()
        boxData.Title = "提示"
        boxData.Content = string.format(data.GetString("JH_Enter_MJRoom_Tips"),lua_NumberToStyle1String(tempMin),tempName);
        boxData.Style = 1
        boxData.LuaCallBack = NetMsgHandler.GoldNotEnoughConfirmOnClick;
        CS.MessageBoxUI.Show(boxData);
    end
end

--endregion

--region 系统函数

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    CS.MatchLoadingUI.Show();
    HandleRefreshHallUIShowState(false);    -- 关闭大厅
    GetAllObject();
    AddClickEvents();
    GetBasicData();
    RequestRoomListInformation(false);
    SetTopInformation();
    RefreshRoomListInformation();
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    --CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHongBaoRoomListUpdateEvent, RefreshRoomListInformation);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHongBaoRoomOnlineEvent, RefreshPlayerAmount);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHallUpdateEvent, OnNotifyHallUpdateEvent);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyUpdateRoomPlayerList, SetSSCRoomAmount);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent, SetTopInformation)
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    --CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHongBaoRoomListUpdateEvent, RefreshRoomListInformation)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHongBaoRoomOnlineEvent, RefreshPlayerAmount)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHallUpdateEvent, OnNotifyHallUpdateEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyUpdateRoomPlayerList, SetSSCRoomAmount)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, SetTopInformation);
end

-- Unity MonoBehavior Start 时调用此方法
function Start()

end

-- Unity MonoBehavior Update 时调用此方法
function Update()

end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()

end

--endregion


-- Test 输出表内容
local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

-- 分隔字符串
--function string.split(sep)
--    local sep, fields = sep or "\t", {}
--    local pattern = string.format("([^%s]+)", sep)
--    string.gsub(pattern, function(c) fields[#fields+1] = c end)
--    return fields
--end
function string.split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

-- 主要用于显示表格, 表格，标识,显示表格的深度，默认3级
function PrintTable(value, desciption, nesting, show_meta)
    if type(nesting) ~= "number" then nesting = 3 end

    show_meta = show_meta or false
    local lookupTable = {}
    local result = {}
    local traceback = string.split(debug.traceback("", 2), "\n")

    local function dump_(value, desciption, indent, nest, keylen)
        desciption ="<color=#FF00FF> "..desciption.."</color>" or "<color=#bb5555> <table> </color>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep("", keylen - string.len(dump_value_(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value_(k)
                    local vkl = string.len(vk)

                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    dump_(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    dump_(value, desciption, "\n", 1)
    local outStr="";
    for i, line in ipairs(result) do
        outStr = outStr..line
    end
    print(outStr)
    return outStr
end
