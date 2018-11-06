--[[
   文件名称:BRHallUI.lua
   创 建 人:土豆陛下
   创建时间：2018-10-10 00:28
   功能描述：新版房间列表(百人厅)
]]--

--region 定义变量

local primaryIndex = 0;
local intermediateIndex = 0;
local SeniorIndex = 0;
local currentRoomType = 0;
local templateItem = nil        -- 实例化的Item模板
local parentTF = nil;           -- Item父节点
local noticeObj = nil;          -- 跑马灯
local allItem = {};
local allRoomInfo = {};
local isFirstOpen = true;
local Buttons = {
    -- 该局部数组说明如下:
    -- 数组.x 为第x个游戏类型的按钮
    returnBtn = nil,            -- 返回按钮
    startBtn = nil,             -- 快速游戏按钮
}

local PlayerInfo = {
    vipLevel = 0,               -- VIP等级
    playerID = 0,               -- ID
    textName = "",              -- 昵称
    goldAmount = 0,             -- 金币数量
    imgHead = "",               -- 头像
}      -- 玩家信息显示物体

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
    [1] = nil,  -- 百人金花
    [15] = nil,  -- 龙虎斗
    [16] = nil,  -- 百家乐
}

--endregion

-- 获取所有物体及其组件
function GetAllObjects()
    -- 玩家信息区域
    PlayerInfo.imgHead = this.transform:Find("Canvas/TopArea/RoleIcon"):GetComponent("Image");
    PlayerInfo.vipLevel = this.transform:Find("Canvas/TopArea/Vip/Level"):GetComponent("Text");
    PlayerInfo.playerID = this.transform:Find("Canvas/TopArea/RoleID/ID"):GetComponent("Text");
    PlayerInfo.textName = this.transform:Find("Canvas/TopArea/RoleName/Name"):GetComponent("Text");
    PlayerInfo.goldAmount = this.transform:Find("Canvas/TopArea/Gold/Amount"):GetComponent("Text");

    noticeObj = this.transform:Find("Canvas/TopArea/Notice").gameObject;
    templateItem = this.transform:Find("Canvas/CenterArea/Viewport/Content/Item").gameObject;
    parentTF = this.transform:Find("Canvas/CenterArea/Viewport/Content");

    GameNameImgObj[1] = this.transform:Find("Canvas/TopArea/Logo_Icon/GameName1").gameObject;
    GameNameImgObj[15] = this.transform:Find("Canvas/TopArea/Logo_Icon/GameName2").gameObject;
    GameNameImgObj[16] = this.transform:Find("Canvas/TopArea/Logo_Icon/GameName3").gameObject;

    Buttons.InformationBtn = this.transform:Find("Canvas/TopArea/RoleIcon"):GetComponent("Button");
    Buttons.GoldBtn = this.transform:Find("Canvas/TopArea/Gold"):GetComponent("Button");
    Buttons.returnBtn = this.transform:Find("Canvas/BottomArea/Return"):GetComponent("Button");
    Buttons.startBtn = this.transform:Find("Canvas/BottomArea/AutoMatch"):GetComponent("Button");

end

-- 获取基本数据
function GetBasicData()
    currentRoomType = GameData.RoomInfo.RoomList_Type;
end

-- 请求房间列表信息
function RequestRoomListInformation()
    if currentRoomType == ROOM_TYPE.BRJH then
        NetMsgHandler.Send_CS_BRJH_Hall_Request_Statistics_New8(1, 2, 3)
    elseif currentRoomType == ROOM_TYPE.LHDRoom then
        NetMsgHandler.Send_CS_LHD_Hall_Room_New8();
    elseif currentRoomType == ROOM_TYPE.BJLRoom then
        BJLGameMgr.Send_CS_BJL_Hall_Room_New8();
    else
    end
end

-- 隐去所有的Items
function HideAllItems()
    local tempContent = this.transform:Find("Canvas/CenterArea/Viewport/Content");
    local tempCount = tempContent.childCount - 1;
    GameObjectSetActive(GameNameImgObj[currentRoomType], false);
    for index = 1, tempCount do
        local tempStatistics = allRoomInfo[index];
        local tempItem = tempContent.transform:Find(tostring(index)).gameObject;
        GameObjectSetActive(allItem[index].state[1].gameObject, false);
        GameObjectSetActive(allItem[index].state[2].gameObject, false);
        GameObjectSetActive(allItem[index].state[3].gameObject, false);
        GameObjectSetActive(allItem[index].whiteBoard.gameObject, true);
        GameObjectSetActive(allItem[index].mask, false);
        GameObjectSetActive(allItem[index].JQQD, false);
        GameObjectSetActive(allItem[index].rootObj.gameObject, false);
    end
end
-- 返回大厅
function ReturnToTheHall()
    GameData.RoomInfo.RoomList_Type = ROOM_TYPE.None;
    GameData.HallData.SelectType = ROOM_TYPE.None;
    HandleRefreshHallUIShowState(true)
    HideAllItems();
    local BRHallUI = CS.WindowManager.Instance:FindWindowNodeByName("BRHallUI")
    if BRHallUI ~= nil then
        BRHallUI.WindowGameObject:SetActive(false)
    else
        print('*********BRHallUI查找失败，请检查!')
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

-- 添加点击事件
function AddClickEvents()
    Buttons.InformationBtn.onClick:AddListener(InformationBtn);
    Buttons.GoldBtn.onClick:AddListener(OnBtnShopClick);
    Buttons.returnBtn.onClick:AddListener(ReturnToTheHall);
    Buttons.startBtn.onClick:AddListener(StartToMatchRoom);
end
-- 设置顶部房间信息
function SetPlayerinformation()
    PlayerInfo.imgHead:ResetSpriteByName(GameData.GetRoleIconSpriteName(GameData.RoleInfo.AccountIcon));
    PlayerInfo.vipLevel.text = ""..GameData.RoleInfo.VipLevel;
    PlayerInfo.playerID.text = ""..GameData.RoleInfo.AccountID;
    PlayerInfo.textName.text = ""..GameData.RoleInfo.AccountName;
    PlayerInfo.goldAmount.text = ""..lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount));
    GameObjectSetActive(GameNameImgObj[currentRoomType], true);
    GameObjectSetActive(noticeObj, true);
end
-- 实例化 房间Item
function InstantiateRoomItems(eventArgs)
    if eventArgs == nil then
        return;
    end
    this:DelayInvoke(0.3, function()
        CS.MatchLoadingUI.Hide();
    end)
    allRoomInfo = eventArgs;
    for gameIndex = 1, GameData.RoleInfo.BRTRoomAmount do
        this:DelayInvoke(0.1, function()
            local tempItem = {};
            tempItem.rootObj = this.transform:Find("Canvas/CenterArea/Viewport/Content/"..gameIndex);
            if tempItem.rootObj == nil then
                tempItem.rootObj = CS.UnityEngine.Object.Instantiate(templateItem);                          -- 房间Item Object
                tempItem.rootObj.name = tostring(gameIndex);
                CS.Utility.ReSetTransform(tempItem.rootObj.transform, parentTF.transform);
            end
            --region 获取Item里面的物体元素
            tempItem.rootBtn = tempItem.rootObj.transform:Find("BgPart1"):GetComponent("Button");
            tempItem.level = tempItem.rootObj.transform:Find("Level"):GetComponent("Text");       -- 房间【等级】[初中高级场]
            tempItem.state = {};
            for index = 1, 3 do
                tempItem.state[index] = tempItem.rootObj.transform:Find("State"..index).gameObject;           -- 房间【状态】
            end
            tempItem.betRange = tempItem.rootObj.transform:Find("BetRange"):GetComponent("Text");         -- 房间【下注范围】
            tempItem.PlayerAmount = tempItem.rootObj.transform:Find("PlayerAmount"):GetComponent("Text");     -- 【玩家数量】
            tempItem.enterGame = tempItem.rootObj.transform:Find("EnterGameBtn"):GetComponent("Button");
            tempItem.whiteBoard = tempItem.rootObj.transform:Find("HallUIStatisticsAreaHandle");
            tempItem.luaScript = tempItem.rootObj.transform:Find("HallUIStatisticsAreaHandle"):GetComponent("LuaBehaviour").LuaScript
            tempItem.enterGameBtn = tempItem.rootObj.transform:Find("EnterGameBtn"):GetComponent("Button");
            tempItem.mask = tempItem.rootObj.transform:Find("Mask").gameObject;
            tempItem.JQQD = tempItem.rootObj.transform:Find("JQQD").gameObject;
            --endregion
            local tempStatistics = eventArgs[gameIndex];
            local roomLevel = tempStatistics.Index;
            if roomLevel == 1 then
                if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomState == RoomState[3] then
                    primaryIndex = primaryIndex + 1;
                    tempItem.level.text = "初级厅"..string.format("%03d", primaryIndex);
                    if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomLabel == RoomLable[3] then
                        GameObjectSetActive(tempItem.state[1], true);
                    elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomLabel == RoomLable[4] then
                        GameObjectSetActive(tempItem.state[2], true);
                    elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].PrimaryRoomLabel == RoomLable[6] then
                        GameObjectSetActive(tempItem.state[3], true);
                    else
                    end
                    local betMin = GameData.RoleInfo.BRTRoomConfiguration[tempStatistics.Index].BetValueMin;
                    local betMax = GameData.RoleInfo.BRTRoomConfiguration[tempStatistics.Index].BetValueMax;
                    betMin = lua_NumberToStyle1String(betMin);
                    betMax = lua_NumberToStyle1String(betMax);
                    tempItem.betRange.text = string.format("%s-%s", tostring(betMin), tostring(betMax));
                    tempItem.PlayerAmount.text = ""..tempStatistics.Counts.RoleCount;
                    if isFirstOpen then
                        tempItem.rootBtn.onClick:AddListener(function()
                            EnterTheGame(gameIndex);
                        end);
                        tempItem.enterGameBtn.onClick:AddListener(function()
                            EnterTheGame(gameIndex);
                        end);
                    end

                    tempItem.luaScript.ResetRelativeRoomID(tempStatistics.RoomID);
                else
                    primaryIndex = primaryIndex + 1;
                    tempItem.level.text = "初级厅"..string.format("%03d", primaryIndex);
                    GameObjectSetActive(tempItem.whiteboard, false);
                    GameObjectSetActive(tempItem.mask, true);
                    GameObjectSetActive(tempItem.JQQD, true);
                end
            elseif roomLevel == 2 then
                if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomState == RoomState[3] then
                    intermediateIndex = intermediateIndex + 1;
                    tempItem.level.text = "中级厅"..string.format("%03d", intermediateIndex);
                    if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomLabel == RoomLable[3] then
                        GameObjectSetActive(tempItem.state[1], true);
                    elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomLabel == RoomLable[4] then
                        GameObjectSetActive(tempItem.state[2], true);
                    elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].IntermediateRoomLabel == RoomLable[6] then
                        GameObjectSetActive(tempItem.state[3], true);
                    else
                    end
                    local betMin = GameData.RoleInfo.BRTRoomConfiguration[tempStatistics.Index].BetValueMin;
                    local betMax = GameData.RoleInfo.BRTRoomConfiguration[tempStatistics.Index].BetValueMax;
                    betMin = lua_NumberToStyle1String(betMin);
                    betMax = lua_NumberToStyle1String(betMax);
                    tempItem.betRange.text = string.format("%s-%s", tostring(betMin), tostring(betMax));
                    tempItem.PlayerAmount.text = ""..tempStatistics.Counts.RoleCount;
                    if isFirstOpen then
                        tempItem.rootBtn.onClick:AddListener(function()
                            EnterTheGame(gameIndex);
                        end);
                        tempItem.enterGameBtn.onClick:AddListener(function()
                            EnterTheGame(gameIndex);
                        end);
                    end

                    tempItem.luaScript.ResetRelativeRoomID(tempStatistics.RoomID);
                else
                    intermediateIndex = intermediateIndex + 1;
                    tempItem.level.text = "中级厅"..string.format("%03d", intermediateIndex);
                    GameObjectSetActive(tempItem.whiteboard, false);
                    GameObjectSetActive(tempItem.mask, true);
                    GameObjectSetActive(tempItem.JQQD, true);
                end
            elseif roomLevel == 3 then
                if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomState == RoomLable[3] then
                    SeniorIndex = SeniorIndex + 1;
                    tempItem.level.text = "高级厅"..string.format("%03d", SeniorIndex);
                    if GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[3] then
                        GameObjectSetActive(tempItem.state[1], true);
                    elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[4] then
                        GameObjectSetActive(tempItem.state[2], true);
                    elseif GameData.GameTypeListInfo[RoomTypeIndex[currentRoomType]].SeniorRoomLabel == RoomLable[6] then
                        GameObjectSetActive(tempItem.state[3], true);
                    else
                    end
                    local betMin = GameData.RoleInfo.BRTRoomConfiguration[tempStatistics.Index].BetValueMin;
                    local betMax = GameData.RoleInfo.BRTRoomConfiguration[tempStatistics.Index].BetValueMax;
                    betMin = lua_NumberToStyle1String(betMin);
                    betMax = lua_NumberToStyle1String(betMax);
                    tempItem.betRange.text = string.format("%s-%s", tostring(betMin), tostring(betMax));
                    tempItem.PlayerAmount.text = ""..tempStatistics.Counts.RoleCount;
                    if isFirstOpen then
                        tempItem.enterGameBtn.onClick:AddListener(function()
                            EnterTheGame(gameIndex);
                        end);
                        tempItem.rootBtn.onClick:AddListener(function()
                            EnterTheGame(gameIndex);
                        end);
                    end

                else
                    SeniorIndex = SeniorIndex + 1;
                    tempItem.level.text = "高级厅"..string.format("%03d", SeniorIndex);
                    tempItem.betRange.text = "";
                    tempItem.PlayerAmount.text = "0";
                    GameObjectSetActive(tempItem.whiteBoard.gameObject, false);
                    GameObjectSetActive(tempItem.mask, true);
                    GameObjectSetActive(tempItem.JQQD, true);
                end
                tempItem.luaScript.ResetRelativeRoomID(tempStatistics.RoomID);
            else
            end
            --if GameData.GameTypeListInfo[currentRoomType].
            allItem[gameIndex] = tempItem;
            GameObjectSetActive(tempItem.rootObj.gameObject, true);
        end)
    end
    this:DelayInvoke(GameData.RoleInfo.BRTRoomAmount*0.1+0.5, function()
        isFirstOpen = false;
    end);
end
--【快速游戏】
function StartToMatchRoom()
    local goldAmount = GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount);
    local canEnter = -1;
    local tempIndex = 0;
    local tempMax = 0;
    for index = GameData.RoleInfo.BRTRoomAmount, 1, -1 do
        local roomIndex = allRoomInfo[index].Index;
        if goldAmount >=  GameData.RoleInfo.BRTRoomConfiguration[roomIndex].EnterGoldMin then
            if goldAmount >= GameData.RoleInfo.BRTRoomConfiguration[roomIndex].EnterGoldMax then
                canEnter = 0;
                tempMax = GameData.RoleInfo.BRTRoomConfiguration[roomIndex].EnterGoldMax;
                break;
            else
                canEnter = 1;
                tempIndex = index;
                break;
            end
        else
        end
    end

    if canEnter == -1 then
        local tempData = allRoomInfo[1].Index;
        local enterMin = GameData.RoleInfo.BRTRoomConfiguration[tempData].EnterGoldMin;
        local tempName = "";
        local boxData = CS.MessageBoxData()
        boxData.Title = "提示"
        boxData.Content = string.format(data.GetString("JH_Enter_MJRoom_Tips"),lua_NumberToStyle1String(enterMin),tempName);
        boxData.Style = 1
        boxData.LuaCallBack = NetMsgHandler.GoldNotEnoughConfirmOnClick;
        CS.MessageBoxUI.Show(boxData);
    elseif canEnter == 0 then
        local desc = string.format(data.GetString("MJ_Enter_Room_Error_8"));
        CS.BubblePrompt.Show(desc ,"DZHallUI");
    elseif canEnter == 1 then
        if currentRoomType == ROOM_TYPE.BRJH then
            NetMsgHandler.Send_CS_Enter_Room(allRoomInfo[tempIndex].RoomID, allRoomInfo[tempIndex].Index);
        elseif currentRoomType == ROOM_TYPE.LHDRoom then
            NetMsgHandler.Send_CS_LHD_Enter_Room(allRoomInfo[tempIndex].RoomID, allRoomInfo[tempIndex].Index);
        elseif currentRoomType == ROOM_TYPE.BJLRoom then
            BJLGameMgr.Send_CS_BJL_Enter_Room(allRoomInfo[tempIndex].RoomID, allRoomInfo[tempIndex].Index);
        else
        end
    else

    end
end
-- 进入游戏
function EnterTheGame(Index)
    local roomID = allRoomInfo[Index].RoomID;
    local roomLevel = allRoomInfo[Index].roomLevel;
    local goldAmount = GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount);
    local tempLevel = GameData.RoomInfo.StatisticsInfo[roomID].Index;
    local enterMin = GameData.RoleInfo.BRTRoomConfiguration[tempLevel].EnterGoldMin;
    local enterMax = GameData.RoleInfo.BRTRoomConfiguration[tempLevel].EnterGoldMax;
    local canEnter = -1;
    --for index = 1, GameData.RoleInfo.BRTRoomAmount do
    if goldAmount >= enterMin then
        if goldAmount > enterMax then
            canEnter = 0;
        else
            canEnter = 1;
        end
    else
    end
    --end
    if canEnter == 1 then
        if currentRoomType == ROOM_TYPE.BRJH then
            NetMsgHandler.Send_CS_Enter_Room(roomID, roomLevel);
        elseif currentRoomType == ROOM_TYPE.LHDRoom then
            NetMsgHandler.Send_CS_LHD_Enter_Room(roomID, roomLevel);
        elseif currentRoomType == ROOM_TYPE.BJLRoom then
            BJLGameMgr.Send_CS_BJL_Enter_Room(roomID, roomLevel);
        else
        end
    elseif canEnter == -1 then
        local tempData = allRoomInfo[1].Index;
        local boxData = CS.MessageBoxData();
        boxData.Title = "温馨提示";
        boxData.Content = string.format(data.GetString("JH_Enter_LHRoom_Tips"), lua_NumberToStyle1String(enterMin));
        boxData.Style = 1;
        boxData.OKButtonName = "确定";
        boxData.LuaCallBack = NetMsgHandler.GoldNotEnoughConfirmOnClick;
        CS.MessageBoxUI.Show(boxData);
    elseif canEnter == 0 then
        local desc = string.format(data.GetString("MJ_Enter_Room_Error_8"));
        CS.BubblePrompt.Show(desc ,"DZHallUI");
    end
end









--region 系统函数

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    isFirstOpen = true;
    GetAllObjects();
    AddClickEvents();
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.Screen.orientation = CS.ScreenOrientation.Portrait;
    CS.MatchLoadingUI.Show();
    primaryIndex = 0;
    intermediateIndex = 0;
    SeniorIndex = 0;
    HandleRefreshHallUIShowState(false);    -- 关闭大厅
    GetBasicData();
    SetPlayerinformation();
    RequestRoomListInformation();
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateStatistics_New8, InstantiateRoomItems);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent, SetPlayerinformation);
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateStatistics_New8, InstantiateRoomItems);
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, SetPlayerinformation);
end

-- 对应脚本的刷新数据方法
function RefreshWindowData(windowData)

end

-- Unity MonoBehavior Start 时调用此方法
function Start()
end

--endregion

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