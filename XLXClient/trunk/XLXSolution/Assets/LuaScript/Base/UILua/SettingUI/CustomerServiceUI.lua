--[[
   文件名称:CustomerServiceUI_.lua
   创 建 人:TUDOU
   创建时间：2018-09-18 15:50
   功能描述：客服中心
]]--

--region __________________(定义变量)

-- 常用全局函数转为本地函数
local InstantiateObj = CS.UnityEngine.Object.Instantiate;
local ReSetTransform = CS.Utility.ReSetTransform;
local math_Ceil = math.ceil;
local Time = CS.UnityEngine.Time;
-- 变量
local currentPlatform;              -- 当前的平台
local CD = 15;                      -- 两次发送消息的间隔
local submitCount = 0;              -- 提交的数量
local singleHeight = 0;             -- 单行行高
local dialogImageWidth = 0;         -- 消息框宽度(Image宽度)
local dialogImageHeight = 0;        -- 消息框高度(Image高度)
local dialogItemWidth = 0;          -- 消息Item宽度
local dialogItemHeight = 0;         -- 消息Item高度
local windowWidth = 0;              -- 窗体的宽度
local dialogBasicWidth = 0;         -- 基本问题窗体的宽度
local dialogBasicHeight = 0;        -- 基本问题窗体的高度
local imageBasicWidth = 0;          -- 基本问题宽度(Image宽度)
local imageBasicHeight = 0;         -- 基本问题宽度(Image高度)
local contentTextHeight = 0;        -- 问题文本高度
local isAddTime = false;
local basicCD = -1;                 -- 基本问题的点击CD
-- 预制体及其组件
local textQQ = nil;                 -- QQ
local textWeChat = nil;             -- 微信
local prefabLeft = {
    rootObj = nil,                  -- 左显示框
    rootObjRTF = nil,               -- 左显示框的RectTransform
    imageRTF = nil,                 -- Image的RectTransform
    type = 0,                       -- 类型(1:玩家 2:客服)
    text = nil,                     -- Text文本组件(内容)
    time = nil,                     -- Text文本组件(时间)
};         -- 左文本显示框
local prefabRight = {
    rootObj = nil,                  -- 右显示框
    rootObjRTF = nil,               -- 右显示框的RectTransform
    imageRTF = nil,                 -- Image的RectTransform
    type = 0,                       -- 类型(1:玩家 2:客服)
    text = nil,                     -- Text文本组件(内容)
    time = nil,                     -- Text文本组件(时间)
};        -- 右文本显示框
local basicQuestion = {             -- 常见问题
    rootObj = nil,                  -- 常见问题显示框
    rootObjRTF = nil,               -- 常见问题显示框RectTransform
    image = nil,                    -- 显示框背景
    imageRTF = nil,                 -- 显示卡背景图片RectTransform
    headObj = nil,                  -- 头部文本
    tailObj = nil,                  -- 尾部文本
    contentObj = nil,               -- 常见问题文本框
    contentObjRTF = nil,            -- 常见问题文本高度
    textContent = nil,              -- 常见问题内容文本
};      -- 客服常见问题
local buttons = {
    btnClose = nil,                 -- 关闭客服中心
    btnQQ = nil,                    -- QQ(复制并打开)
    btnWeChat = nil,                -- 微信(复制并打开)
    btnSend = nil,                  -- 发送
};            -- 按钮
local contentTF = nil;              -- 文本显示框transform
local inputField = nil;             -- 文本输入InputField

local mToggle1 = nil
local mToggle2 = nil
local mToggle3 = nil
local mToggle1Label = nil
local mToggle2Label = nil
local mToggle3Label = nil
local mToggle3Label1 = nil

local customerView = nil

local mailRedTip = nil
local mailView = nil
local imageNoMail = nil
local imageNoMail2 = nil
local mailContainer = nil
local mailList = nil
local mailItem = nil

local mailDetailWindow = nil
local textSender = nil
local textDate = nil
local textMailContent = nil
local attachmentView = nil
local btnGetAttachment = nil
local textAttachment

local advertiseTip = nil
local advertiseView = nil
local advertiseList = nil
local advertiseItem = nil

local advertiseDetailWindow = nil
local textAdvertiseTitle = nil
local textAdvertiseContent = nil
local imageAdvertise = nil
local buttonGoto = nil
local curAdvertiseInfo

--endregion

-- 获取基本数据
function GetBasicData()
    currentPlatform = CS.Utility.GetCurrentPlatform();
    prefabLeft.text.text = "";
    singleHeight = prefabLeft.text.preferredHeight + 5;
    dialogImageWidth = prefabLeft.imageRTF.sizeDelta.x;
    dialogImageHeight = prefabLeft.imageRTF.sizeDelta.y;
    dialogItemWidth = prefabLeft.rootObjRTF.sizeDelta.x;
    dialogItemHeight = prefabLeft.rootObjRTF.sizeDelta.y;
    dialogBasicWidth = basicQuestion.rootObjRTF.sizeDelta.x;
    dialogBasicHeight = basicQuestion.rootObjRTF.sizeDelta.y;
    imageBasicWidth = basicQuestion.imageRTF.sizeDelta.x;
    imageBasicHeight = basicQuestion.imageRTF.sizeDelta.y;
    contentTextHeight = basicQuestion.contentObjRTF.sizeDelta.y;
    windowWidth = this.transform:Find("Canvas"):GetComponent("RectTransform").sizeDelta.x;

end

--  清除空字符
function ClearNullCharacter(stringData)
    local tempString = string.gsub(stringData, "^%s*(.-)%s*$", "%1")
    return tempString;
end

-- 获取物体及其组件
function GetObjects()
    mailRedTip = this.transform:Find("Canvas/Window/MailTip").gameObject
    mailRedTip:SetActive(GameData.MailRed == 1)

    customerView = this.transform:Find("Canvas/Window/CustomerBox").gameObject

    mailView = this.transform:Find("Canvas/Window/MailBox").gameObject
    imageNoMail = this.transform:Find("Canvas/Window/MailBox/ImageNoMail").gameObject
    imageNoMail2 = this.transform:Find("Canvas/Window/MailBox/ImageNoMail2").gameObject
    mailContainer = this.transform:Find("Canvas/Window/MailBox/MailList").gameObject
    mailList = this.transform:Find("Canvas/Window/MailBox/MailList/Viewport/Content")
    mailItem = this.transform:Find("Canvas/Window/MailBox/MailList/Viewport/Content/MailItem")
    mailDetailWindow = this.transform:Find("Canvas/Window/MailBox/MailDetailWindow").gameObject
    textSender = this.transform:Find("Canvas/Window/MailBox/MailDetailWindow/TextSender"):GetComponent("Text");
    textDate = this.transform:Find("Canvas/Window/MailBox/MailDetailWindow/TextDate"):GetComponent("Text");
    textMailContent = this.transform:Find("Canvas/Window/MailBox/MailDetailWindow/TextMailContent"):GetComponent("Text");
    attachmentView = this.transform:Find("Canvas/Window/MailBox/MailDetailWindow/AttachmentView").gameObject;
    btnGetAttachment = this.transform:Find("Canvas/Window/MailBox/MailDetailWindow/AttachmentView/ButtonGetAttachment"):GetComponent("Button");
    textAttachment = this.transform:Find("Canvas/Window/MailBox/MailDetailWindow/AttachmentView/TextAttachmentNum"):GetComponent("Text");

    advertiseTip = this.transform:Find("Canvas/Window/GongGaoTip").gameObject
    advertiseTip:SetActive(GameData.NoticeRed == 1)
    advertiseView = this.transform:Find("Canvas/Window/GonggaoBox").gameObject
    advertiseList = this.transform:Find("Canvas/Window/GonggaoBox/AdertiseList/Viewport/Content")
    advertiseItem = this.transform:Find("Canvas/Window/GonggaoBox/AdertiseList/Viewport/Content/AdvertiseItem")

    advertiseDetailWindow = this.transform:Find("Canvas/Window/GonggaoBox/GonggaoDetailWindow").gameObject
    textAdvertiseTitle = this.transform:Find("Canvas/Window/GonggaoBox/GonggaoDetailWindow/TextTitle"):GetComponent("Text")
    textAdvertiseContent = this.transform:Find("Canvas/Window/GonggaoBox/GonggaoDetailWindow/TextContent"):GetComponent("Text")
    imageAdvertise = this.transform:Find("Canvas/Window/GonggaoBox/GonggaoDetailWindow/ImageAdertise"):GetComponent("Image")
    buttonGoto = this.transform:Find("Canvas/Window/GonggaoBox/GonggaoDetailWindow/ButtonGoto"):GetComponent("Button")
--    buttonLabel = this.transform:Find("Canvas/Window/GonggaoBox/GonggaoDetailWindow/ButtonGoto/Text"):GetComponent("Text")
--    buttonCloseAdvertiseWindow = this.transform:Find("Canvas/Window/GonggaoDetailWindow/ButtonClose"):GetComponent("Button")

    mToggle1Label = this.transform:Find("Canvas/Window/ToggleGroup/Toggle1/Label2").gameObject
    mToggle1Label:SetActive(false)
    mToggle2Label = this.transform:Find("Canvas/Window/ToggleGroup/Toggle2/Label2").gameObject
    mToggle3Label1 = this.transform:Find("Canvas/Window/ToggleGroup/Toggle3/Label1"):GetComponent("Text")
    mToggle3Label = this.transform:Find("Canvas/Window/ToggleGroup/Toggle3/Label2").gameObject

    mToggle1 = this.transform:Find("Canvas/Window/ToggleGroup/Toggle1"):GetComponent('Toggle')
    mToggle2 = this.transform:Find("Canvas/Window/ToggleGroup/Toggle2"):GetComponent('Toggle')
    mToggle3 = this.transform:Find("Canvas/Window/ToggleGroup/Toggle3"):GetComponent('Toggle')
    mToggle1.onValueChanged:AddListener( function(isOn) OnTabChanged(isOn, 1) end)
    mToggle2.onValueChanged:AddListener( function(isOn) OnTabChanged(isOn, 2) end)
    mToggle3.onValueChanged:AddListener( function(isOn) OnTabChanged(isOn, 3) end)

    textQQ = this.transform:Find("Canvas/Window/CustomerBox/QQ/Number"):GetComponent("Text");
    textWeChat = this.transform:Find("Canvas/Window/CustomerBox/WeChat/Text"):GetComponent("Text");
    local tempPath1 = "Canvas/Window/CustomerBox/Content/Scroll View/Viewport/Content/";
    prefabLeft.rootObj = this.transform:Find(tempPath1.."Left").gameObject;
    prefabLeft.rootObjRTF = this.transform:Find(tempPath1.."Left"):GetComponent("RectTransform");
    prefabLeft.imageRTF = this.transform:Find(tempPath1.."Left/Image"):GetComponent("RectTransform");
    prefabLeft.text = this.transform:Find(tempPath1.."Left/Image/Text"):GetComponent("Text");
    prefabLeft.time = this.transform:Find(tempPath1.."Left/Image/Time"):GetComponent("Text");
    prefabRight.rootObj = this.transform:Find(tempPath1.."Right").gameObject;
    prefabRight.rootObjRTF = this.transform:Find(tempPath1.."Right"):GetComponent("RectTransform");
    prefabRight.imageRTF = this.transform:Find(tempPath1.."Right/Image"):GetComponent("RectTransform");
    prefabRight.text = this.transform:Find(tempPath1.."Right/Image/Text"):GetComponent("Text");
    prefabRight.time = this.transform:Find(tempPath1.."Right/Image/Time"):GetComponent("Text");
    buttons.btnClose = this.transform:Find("Canvas/Window/Title/ReturnButton"):GetComponent("Button");
    buttons.btnQQ = this.transform:Find("Canvas/Window/CustomerBox/QQButton"):GetComponent("Button");
    buttons.btnWeChat = this.transform:Find("Canvas/Window/CustomerBox/WXButton"):GetComponent("Button");
    buttons.btnSend = this.transform:Find("Canvas/Window/CustomerBox/Content/Button"):GetComponent("Button");
    contentTF = this.transform:Find("Canvas/Window/CustomerBox/Content/Scroll View/Viewport/Content");
    inputField  = this.transform:Find("Canvas/Window/CustomerBox/Content/InputField"):GetComponent("InputField");
    local tempPath2 = "Canvas/Window/CustomerBox/Content/Scroll View/Viewport/Content/BasicQuestion";
    basicQuestion.rootObj = this.transform:Find(tempPath2).gameObject;
    basicQuestion.rootObjRTF = this.transform:Find(tempPath2):GetComponent("RectTransform");
    basicQuestion.image = this.transform:Find(tempPath2.."/Image");
    basicQuestion.imageRTF = this.transform:Find(tempPath2.."/Image");
    basicQuestion.headObj = this.transform:Find(tempPath2.."/Image/Text_Head").gameObject;
    basicQuestion.tailObj = this.transform:Find(tempPath2.."/Image/Text_Tail").gameObject;
    basicQuestion.contentObj = this.transform:Find(tempPath2.."/Image/Text").gameObject;
    basicQuestion.contentObjRTF = this.transform:Find(tempPath2.."/Image/Text"):GetComponent("RectTransform");
    basicQuestion.textContent = this.transform:Find(tempPath2.."/Image/Text"):GetComponent("Text");
end

-- 添加点击事件
function AddClickEvents()
    buttons.btnClose.onClick:AddListener(ReturnToHall);         -- 关闭客服中心
    buttons.btnWeChat.onClick:AddListener(function ()           -- 微信服务号(复制并打开)
        CopyAndOpenClicked(1)
    end);
    buttons.btnQQ.onClick:AddListener(function ()               -- 客服QQ号(复制并打开)
        CopyAndOpenClicked(2);
    end);
    inputField.onValueChanged:AddListener(CheckInputString);
    buttons.btnSend.onClick:AddListener(SendMessage);           -- 发送

    btnGetAttachment.onClick:AddListener(GetAttachment)
--    buttonCloseAdvertiseWindow.onClick:AddListener(closeAdvertiseWindow)
    buttonGoto.onClick:AddListener(GotoInWindow);
end

-- 关闭客服返回大厅
function ReturnToHall()
    NetMsgHandler.Send_CS_PlayerCloseUI();
    CS.WindowManager.Instance:CloseWindow("CustomerServiceUI", false);
end

-- 计算输入框内字符个数
function GetCharacterCount()
    local tempString = inputField.text;
    local byteLength = #tempString;
    local strCount = 0;
    local index = 1;
    while (index <= byteLength) do
        local currentByte = string.byte(tempString, index);
        local byteCount = 1;
        if currentByte > 0 and currentByte <= 127 then              -- 1字节字符
            byteCount = 1;
        elseif currentByte >= 192 and currentByte < 223 then        -- 双字节字符
            byteCount = 2;
        elseif currentByte >= 224 and currentByte < 239 then        -- 汉字
            byteCount = 3;
        elseif currentByte >= 240 and currentByte <= 247 then       -- 4字节字符
            byteCount = 4;
        else
        end
        --local tempChar = string.sub(tempString, index, index + byteCount - 1);
        index = index + byteCount;
        strCount = strCount + 1;
    end
    return strCount;
end

-- 获取文本字符串行数
function GetTextRowCount(tempText)
    local count = tempText.preferredHeight / singleHeight;
    count = math_Ceil(count);
    return count;
end

-- 检测玩家输入的字符数量
function CheckInputString()

    local tempCount = GetCharacterCount();
    if tempCount >= 50 then
        CS.BubblePrompt.Show("您输入的文字已达到上限", "CustomerServiceUI");
    end

end

-- 根据对话框内字符行数设置对话框的高
function SetDialogBox(itemRTF, imageRTF, rowCount)
    local tempDialogVector2 = CS.UnityEngine.Vector2(itemRTF.sizeDelta.x, dialogItemHeight + (rowCount-1)*singleHeight);
    local tempImageVector2 = CS.UnityEngine.Vector2(imageRTF.sizeDelta.x, dialogImageHeight + (rowCount-1)*singleHeight);
    itemRTF.sizeDelta = tempDialogVector2;
    imageRTF.sizeDelta = tempImageVector2;
end

-- 复制并打开【微信】
function CopyAndOpenWechat()
    if currentPlatform == 2 or currentPlatform == 3 then
        local inputText = "";
        if GameData.RoleInfo.OfficialWX == nil or GameData.RoleInfo.OfficialWX == "" then
            return;
        end
        if currentPlatform == 2 then
            CS.BubblePrompt.Show("复制成功", "UIExtract");
        end
        inputText = ""..GameData.RoleInfo.OfficialWX;
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, inputText);
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_WXCHAT, inputText);
    end
end

-- 复制并打开【QQ】
function CopyAndOpenQQ()
    if currentPlatform == 2 or currentPlatform == 3 then
        local inputText = "";
        if GameData.RoleInfo.OfficialQQ == nil or GameData.RoleInfo.OfficialQQ == "" then
            return;
        end
        local inputString = "";
        inputText = ""..GameData.RoleInfo.OfficialQQ;
        PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_SHEARPLATE, inputText);
        if currentPlatform == 2 then
            inputString = "mqqwpa://im/chat?chat_type=wpa&uin="..GameData.RoleInfo.OfficialQQ;
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_QQCHAT, inputString);
        else
            PlatformBridge:CallFunc(currentPlatform, PLATFORM_FUNCTION_ENUM.PLATFORM_QQCHAT, inputText);
        end
    end
end

-- 【复制并打开】点击事件
function CopyAndOpenClicked(index)
    if index == 1 then
        CopyAndOpenWechat();
    elseif index == 2 then
        CopyAndOpenQQ();
    else
    end
end

-- 从服务器请求数据
function RequestData()
    NetMsgHandler.Send_CS_PlayerPullInfo();
end

-- 判断是否可发送
function JudgeCanSendMessage()
    local canSend = true;
    local interval = 0;
    if GameData.lastSendTime == 0 then
        GameData.lastSendTime = os.time();
        return canSend;
    end
    interval = os.time() - GameData.lastSendTime;
    if interval >= CD then
        GameData.lastSendTime = os.time();
    else
        canSend = false;
    end
    return canSend;
end

-- 点击发送文本
function SendMessage()
    if GameData.KFZX.ServerIsSendToPlayer then
        submitCount = 0;
    end
    GameData.KFZX.ServerIsSendToPlayer = false;
    if submitCount >= 20 then
        submitCount = 20;
        CS.BubblePrompt.Show("您已输入超过20条，请稍后再输入", "CustomerServiceUI");
        inputField.text = "";
        return;
    end
    if not JudgeCanSendMessage() then
        CS.BubblePrompt.Show("您输入太过频繁，请稍后再试", "CustomerServiceUI");
        inputField.text = "";
        return nil;
    end
    local tempString = inputField.text;
    tempString = ClearNullCharacter(tempString);
    if tempString == "" then
        CS.BubblePrompt.Show("不能输入空字符, 请重新输入", "CustomerServiceUI");
        inputField.text = "";
        return nil;
    end
    local textData = inputField.text;
    NetMsgHandler.Send_CS_PlayerSendInfo(textData);
    submitCount = submitCount + 1;
    inputField.text = "";
end

-- 播放界面【音效】
function PlayKFZXAudio()
    local index = math.random(2);
    local musicID = "OpenGM"..index;
    MusicMgr:PlaySoundEffect(musicID);
end

-- 客服发送信息过来
function KFSendMessage()
    InstantiateMessage(GameData.Server, 1);
end

-- 玩家发送信息给服务器
function PlayerSendMessage()
    InstantiateMessage(GameData.Player, 1);
end

-- 给常见问题添加【下划线】
function AddUnderLine(Text, index)
    if Text == nil then
        return;
    end
    -- local tempText = InstantiateObj(Text);
    -- ReSetTransform(tempText.transform, Text.transform);
    local tempText = Text.transform:Find("Text"):GetComponent("Text");
    local tempTextRTF = tempText.transform:GetComponent("RectTransform");
    -- tempTextRTF.anchoredPosition3D = CS.UnityEngine.Vector3.zero;
    -- tempTextRTF.offsetMax = CS.UnityEngine.Vector2.zero;
    -- tempTextRTF.offsetMin = CS.UnityEngine.Vector2.zero;
    -- tempTextRTF.anchorMax = CS.UnityEngine.Vector2.one;
    -- tempTextRTF.anchorMin = CS.UnityEngine.Vector2.zero;
    tempText.text = "_";
    local singleWidth = tempText.preferredWidth;
    local width = Text.preferredWidth;
    local count = math_Ceil(width/singleWidth);
    if index >= 10 then
        tempText.text = "  _";
        tempText.text = "    "..tempText.text;
        for index = 1, count-5 do
            tempText.text = tempText.text.."_";
        end
    else
        tempText.text = "    "..tempText.text;
        for index = 1, count-3 do
            tempText.text = tempText.text.."_";
        end
    end
    local tempy = tempTextRTF.sizeDelta.y;
    tempTextRTF.sizeDelta= CS.UnityEngine.Vector2(0, tempy);
    GameObjectSetActive(tempText.gameObject, true);
    return tempText;
end

-- 实例化【常见问题】对话框
function InstantiateBasicQ()
    local tempItem = {};
    tempItem.rootObj = InstantiateObj(basicQuestion.rootObj);
    tempItem.rootObjRTF = tempItem.rootObj.transform:GetComponent("RectTransform");
    tempItem.image = tempItem.rootObj.transform:Find("Image");
    tempItem.imageRTF = tempItem.image.transform:GetComponent("RectTransform");
    ReSetTransform(tempItem.rootObj.transform, contentTF);
    tempItem.rootObj.transform:SetAsFirstSibling();
    local count = GameData.KFZX.BasicQuestionCount;
    if count > 0 then
        for index = 1, count do
            local questionItem = InstantiateObj(basicQuestion.contentObj);
            questionItem.name = ""..index;
            ReSetTransform(questionItem.transform, tempItem.image.transform)
            local tempContentText = questionItem.transform:GetComponent("Text");
            tempContentText.text = index..". "..GameData.basicQuestion[index];
            AddUnderLine(tempContentText, index);
            local tempButton = tempContentText.transform:GetComponent("Button");
            tempButton.onClick:AddListener(function()
                if basicCD >= 3 or basicCD == -1 then
                    if basicCD == -1 then
                        isAddTime = true;
                    end
                    basicCD = 0;
                    local tempData1 = {};
                    tempData1.Sender = 1;
                    tempData1.Content = GameData.basicQuestion[index];
                    tempData1.Time = "";
                    this:DelayInvoke(0.3, function()
                        InstantiateMessage(tempData1, 1);
                    end)
                    local tempData2 = {};
                    tempData2.Sender = 2;
                    tempData2.Content = "答："..GameData.basicAnswer[index];
                    tempData2.Time = "";
                    this:DelayInvoke(0.6, function()
                        InstantiateMessage(tempData2, 1);
                    end)
                else
                    CS.BubblePrompt.Show("您输入过于频繁，请稍后再试", "CustomerServiceUI")
                end
            end);
            GameObjectSetActive(questionItem.gameObject, true);
        end
    else
    end
    local tempDialogVector2 = CS.UnityEngine.Vector2(dialogBasicWidth, dialogBasicHeight + count*contentTextHeight);
    local tempImageVector2 = CS.UnityEngine.Vector2(dialogImageWidth, dialogImageHeight + count*contentTextHeight);
    tempItem.rootObjRTF.sizeDelta = tempDialogVector2;
    tempItem.imageRTF.sizeDelta = tempImageVector2;
    tempItem.tailObj = tempItem.rootObj.transform:Find("Image/Text_Tail");
    tempItem.tailObj.transform:SetAsLastSibling();
    GameObjectSetActive(tempItem.tailObj.gameObject, false);
    basicQuestion.rootObj.transform:SetAsFirstSibling();
    GameObjectSetActive(tempItem.rootObj.gameObject, true);
end

-- 实例化对话框
function InstantiateMessage(tempData, tempNum)
    local tempItem = {};
    if tempData.Sender == 1 then            -- 玩家信息
        tempItem.rootObj = InstantiateObj(prefabRight.rootObj);
    elseif tempData.Sender == 2 then        -- 客服信息
        tempItem.rootObj = InstantiateObj(prefabLeft.rootObj);
    else
        return;
    end
    ReSetTransform(tempItem.rootObj.transform, contentTF);
    if tempNum == 1 then
        tempItem.rootObj.transform:SetAsFirstSibling();
    end
    tempItem.text = tempItem.rootObj.transform:Find("Image/Text"):GetComponent("Text");
    tempItem.time = tempItem.rootObj.transform:Find("Image/Time"):GetComponent("Text");
    tempItem.text.text = tempData.Content;
    tempItem.time.text = tempData.Time;
    tempItem.itemRTF = tempItem.rootObj:GetComponent("RectTransform");
    tempItem.imageRTF = tempItem.rootObj.transform:Find("Image"):GetComponent("RectTransform");
    local rowCount = GetTextRowCount(tempItem.text);
    SetDialogBox(tempItem.itemRTF, tempItem.imageRTF, rowCount);
    GameObjectSetActive(tempItem.rootObj.gameObject, true);
end

-- 根据信息记录实例化对话框
function ShowHistoryRecordsDialog()
    if GameData.KFZX.Info ~= nil then
        for index = #GameData.KFZX.Info, 1, -1 do
            InstantiateMessage(GameData.KFZX.Info[index], 0);
        end
    end
    InstantiateBasicQ();
end

function DisplayContactInformation()
    textQQ.text = ""..GameData.RoleInfo.OfficialQQ
    textWeChat.text = ""..GameData.RoleInfo.OfficialWX
end

--region __________________(系统函数)

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    GetObjects();             -- 获取物体及其组件
    AddClickEvents();         -- 添加点击事件
    GetBasicData();           -- 基本数据
    RequestData();            -- 从服务器请求数据
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyKFZXBackInfo, PlayerSendMessage);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyKFZXSendInfo, KFSendMessage);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyKFZXPlayerPullInfo, ShowHistoryRecordsDialog);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyKFZXOfficialInfo, DisplayContactInformation);
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateEmailInfo, UpdateEmailInfo)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.updateEmailAttachment, UpdateEmailAttachment)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UPDATE_ADVERTISE_NAME, UpdateAdvertiseName)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UPDATE_ADVERTISE_LIST, UpdateAdvertiseList)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyNoticeNew, UpdateAdvertiseRed)

    DisplayContactInformation()
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyKFZXBackInfo, PlayerSendMessage);
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyKFZXSendInfo, KFSendMessage);
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyKFZXPlayerPullInfo, ShowHistoryRecordsDialog);
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyKFZXOfficialInfo, DisplayContactInformation);
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateEmailInfo, UpdateEmailInfo)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.updateEmailAttachment, UpdateEmailAttachment)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UPDATE_ADVERTISE_NAME, UpdateAdvertiseName)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UPDATE_ADVERTISE_LIST, UpdateAdvertiseList)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyNoticeNew, UpdateAdvertiseRed)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    PlayKFZXAudio()
end

-- Unity MonoBehavior Update 时调用此方法
function Update()
    if isAddTime then
        basicCD = basicCD + Time.deltaTime;
    end
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()

end

function OnTabChanged(isOn, typeParam)
    GameObjectSetActive(mToggle1Label, true)
    GameObjectSetActive(mToggle2Label, true)
    GameObjectSetActive(mToggle3Label, true)
    if isOn then
        lua_Transform_ClearChildren(advertiseList, true)
        lua_Transform_ClearChildren(mailList, true)
        GameObjectSetActive(mailView, typeParam == 3)
        GameObjectSetActive(advertiseView, typeParam == 2)
        GameObjectSetActive(customerView, typeParam == 1)
        if typeParam == 1 then
            GameObjectSetActive(mToggle1Label, false)
        elseif typeParam == 2 then
            GameObjectSetActive(mToggle2Label, false)
            CS.LoadingDataUI.Show()
            NetMsgHandler.Send_CS_ADVERTISE_INFO()
            GameData.NoticeRed = 0
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyNoticeNew)
        elseif typeParam == 3 then
            GameObjectSetActive(mToggle3Label, false)
            CS.LoadingDataUI.Show()
            EmailMgr:ClearAll()
            NetMsgHandler.SendRequestEmails(0)
            GameData.MailRed = 0
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyMailNew)
        end
    end
end

function UpdateAdvertiseName(advertiseName)
    --mToggle3Label:GetComponent("Text").text = advertiseName
    --mToggle3Label1.text = advertiseName
end

function UpdateAdvertiseRed()
    if advertiseView.activeSelf == false then
        advertiseTip:SetActive(true)
    end
end

function UpdateAdvertiseList(advertiseInfoList)
    if advertiseView.activeSelf == false then
        advertiseTip:SetActive(true)
        return
    end

    advertiseTip:SetActive(false)
    CS.LoadingDataUI.Hide()

    lua_Transform_ClearChildren(advertiseList, true)
    advertiseItem.gameObject:SetActive(false)

    for k, v in pairs(advertiseInfoList) do
        local newItem = CS.UnityEngine.Object.Instantiate(advertiseItem)
        CS.Utility.ReSetTransform(newItem, advertiseList)
        newItem.gameObject:SetActive(true)
        SetAdvertiseInfo(newItem, v)
    end
end

function SetAdvertiseInfo(newItem, advertiseInfo)
    newItem:GetComponent("Button").onClick:AddListener(function () ClickAdvertiseItem(newItem, advertiseInfo) end)
--    newItem:Find('ButtonGo'):GetComponent("Button").onClick:AddListener(function () Goto(advertiseInfo) end)
--    local imageUrl = GameConfig.AdvertiseBannerUrl..advertiseInfo.imageID..".jpg"
--    local advertiseImg = newItem:Find('Image'):GetComponent("Image")
--    this:StartCoroutine(advertiseImg:ResetSpriteByRemoteUrlOrLocal(imageUrl,"",true))

    local advertiseName = newItem:Find("TextName"):GetComponent("Text")
    advertiseName.text = advertiseInfo.title;

    local imgNormal = newItem:Find("Image").gameObject
    imgNormal:SetActive(true);
    local imgSelect = newItem:Find("ImageSelect").gameObject
    imgSelect:SetActive(false);

    local advertiseNew = newItem:Find("ImageNew").gameObject
    local advertiseNewSelect = newItem:Find("ImageNewSelect").gameObject
    local advertiseHot = newItem:Find("ImageHot").gameObject
    local advertiseHotSelect = newItem:Find("ImageHotSelect").gameObject

    advertiseHotSelect:SetActive(false)
    advertiseNewSelect:SetActive(false)

    if advertiseInfo.flag == 0 then
        advertiseNew:SetActive(false)
        advertiseHot:SetActive(false)
    elseif advertiseInfo.flag == 1 then
        advertiseNew:SetActive(true)
        advertiseHot:SetActive(false)
    elseif advertiseInfo.flag == 2 then
        advertiseNew:SetActive(false)
        advertiseHot:SetActive(true)
    end

--    if advertiseInfo.gotoID == "0" or advertiseInfo.gotoID == "" then
--        newItem:Find('ButtonGo').gameObject:SetActive(false)
--    else
--        newItem:Find('ButtonGo').gameObject:SetActive(true)
--    end
end
local selectAdvertiseItem = nil
function ClickAdvertiseItem(newItem, advertiseInfo)
    if selectAdvertiseItem ~= nil then
        selectAdvertiseItem:Find("Image").gameObject:SetActive(true)
        selectAdvertiseItem:Find("ImageSelect").gameObject:SetActive(false)
        if curAdvertiseInfo.flag == 1 then
            selectAdvertiseItem:Find("ImageNew").gameObject:SetActive(true)
            selectAdvertiseItem:Find("ImageNewSelect").gameObject:SetActive(false)
            selectAdvertiseItem:Find("ImageHot").gameObject:SetActive(false)
            selectAdvertiseItem:Find("ImageHotSelect").gameObject:SetActive(false)
        elseif curAdvertiseInfo.flag == 2 then
            selectAdvertiseItem:Find("ImageNew").gameObject:SetActive(false)
            selectAdvertiseItem:Find("ImageNewSelect").gameObject:SetActive(false)
            selectAdvertiseItem:Find("ImageHot").gameObject:SetActive(true)
            selectAdvertiseItem:Find("ImageHotSelect").gameObject:SetActive(false)
        end
    end
    selectAdvertiseItem = newItem;
    curAdvertiseInfo = advertiseInfo

    selectAdvertiseItem:Find("Image").gameObject:SetActive(false)
    selectAdvertiseItem:Find("ImageSelect").gameObject:SetActive(true)
    if advertiseInfo.flag == 1 then
        selectAdvertiseItem:Find("ImageNew").gameObject:SetActive(false)
        selectAdvertiseItem:Find("ImageNewSelect").gameObject:SetActive(true)
        selectAdvertiseItem:Find("ImageHot").gameObject:SetActive(false)
        selectAdvertiseItem:Find("ImageHotSelect").gameObject:SetActive(false)
    elseif advertiseInfo.flag == 2 then
        selectAdvertiseItem:Find("ImageNew").gameObject:SetActive(false)
        selectAdvertiseItem:Find("ImageNewSelect").gameObject:SetActive(false)
        selectAdvertiseItem:Find("ImageHot").gameObject:SetActive(false)
        selectAdvertiseItem:Find("ImageHotSelect").gameObject:SetActive(true)
    end

    advertiseDetailWindow:SetActive(true)
    textAdvertiseTitle.text = advertiseInfo.title

    if advertiseInfo.content == nil or advertiseInfo.content == "" then
        textAdvertiseContent.text = ""
        local imageUrl = GameConfig.AdvertiseContentUrl..advertiseInfo.imageID..".jpg"
        this:StartCoroutine(imageAdvertise:ResetSpriteByRemoteUrlOrLocal(imageUrl,"",true))
    else
        textAdvertiseContent.text = advertiseInfo.content
    end

    if advertiseInfo.gotoID == "0" or advertiseInfo.gotoID == "" then
--        buttonLabel.text = "确定"
    else
--        buttonLabel.text = "去看看"
    end
end

function Goto(advertiseInfo)
    if advertiseInfo.gotoID ~= "0" and advertiseInfo.gotoID ~= "" then
        CS.WindowManager.Instance:OpenWindow(advertiseInfo.gotoID)
    end
end

function GotoInWindow()
    if curAdvertiseInfo.gotoID == "0" or curAdvertiseInfo.gotoID == "" then
        closeAdvertiseWindow()
    else
        CS.WindowManager.Instance:OpenWindow(curAdvertiseInfo.gotoID)
    end
end

function closeAdvertiseWindow()
    advertiseDetailWindow:SetActive(false)
end

-- 刷新邮件数据
function UpdateEmailInfo()
    if mailView.activeSelf == false then
        mailRedTip:SetActive(true)
        return
    end
    mailRedTip:SetActive(false)
    CS.LoadingDataUI.Hide()

    lua_Transform_ClearChildren(mailList, true)
    mailItem.gameObject:SetActive(false)

    local mailNum = 0

    for k, v in pairs(EmailMgr.NewMailHasAttach) do
        AddMailItem(v)
        mailNum = mailNum + 1
    end

    for k, v in pairs(EmailMgr.NewMailNoAttach) do
        AddMailItem(v)
        mailNum = mailNum + 1
    end

    for k, v in pairs(EmailMgr.ReadMailHasAttach) do
        AddMailItem(v)
        mailNum = mailNum + 1
    end

    for k, v in pairs(EmailMgr.ReadMailGotAttach) do
        AddMailItem(v)
        mailNum = mailNum + 1
    end

    for k, v in pairs(EmailMgr.ReadMailNoAttach) do
        AddMailItem(v)
        mailNum = mailNum + 1
    end

    if mailNum > 0 then
        imageNoMail:SetActive(false)
        imageNoMail2:SetActive(false)
    else
        imageNoMail:SetActive(true)
        imageNoMail2:SetActive(true)
    end
end

function AddMailItem(mailInfo)
    local newItem = CS.UnityEngine.Object.Instantiate(mailItem)
    CS.Utility.ReSetTransform(newItem, mailList)
    newItem.gameObject:SetActive(true)
    SetMailInfo(newItem, mailInfo)
end

-- 重置邮件Item数据
function SetMailInfo(newItem, mailInfo)
    newItem:GetComponent("Button").onClick:AddListener(function () ShowMailDetail(mailInfo) end)
    newItem:Find('TextMailName'):GetComponent("Text").text = mailInfo.sTitle
    newItem:Find('TextMailSender'):GetComponent("Text").text = "发件人："..mailInfo.sSenderName
    newItem:Find('TextMailDate'):GetComponent("Text").text = CS.Utility.UnixTimestampToDateTime(mailInfo.nSendDate):ToString('yyyy-MM-dd HH:mm')
    if mailInfo.hasAttachment == 1 and mailInfo.nGold > 0 then
        newItem:Find('ImageAttachment').gameObject:SetActive(true)
        newItem:Find('ImageAttachmentGot').gameObject:SetActive(false)
    elseif mailInfo.hasAttachment == 1 then
        newItem:Find('ImageAttachment').gameObject:SetActive(false)
        newItem:Find('ImageAttachmentGot').gameObject:SetActive(true)
    else
        newItem:Find('ImageAttachment').gameObject:SetActive(false)
        newItem:Find('ImageAttachmentGot').gameObject:SetActive(false)
    end
    if mailInfo.bIsRead == 1 then
        newItem:Find("ImageUnread").gameObject:SetActive(false)
        newItem:Find("ImageRead").gameObject:SetActive(true)
    else
        newItem:Find("ImageUnread").gameObject:SetActive(true)
        newItem:Find("ImageRead").gameObject:SetActive(false)
    end
end

local curMailInfo = nil
function ShowMailDetail(mailInfo)
    curMailInfo = mailInfo
    mailDetailWindow:SetActive(true)
    textSender.text = "发件人："..mailInfo.sSenderName
    textDate.text = CS.Utility.UnixTimestampToDateTime(mailInfo.nSendDate):ToString('yyyy-MM-dd HH:mm')
    textMailContent.text = mailInfo.sContent
    if mailInfo.hasAttachment == 1 then
        attachmentView:SetActive(true)
        textAttachment.text = "×"..tostring(mailInfo.nGold)
    else
        attachmentView:SetActive(false)
    end

    btnGetAttachment.interactable = mailInfo.nGold > 0

    if curMailInfo.bIsRead == 0 then
        EmailMgr:ReadMail(curMailInfo.MailID)
        curMailInfo.bIsRead = 1
        NetMsgHandler.SendReadEmail(curMailInfo.MailID)
        UpdateEmailInfo()
    end
end

function CloseMailDetail()
    mailDetailWindow:SetActive(false)
end

function GetAttachment()
    if curMailInfo.nGold > 0 and curMailInfo.hasAttachment == 1 then
        CS.LoadingDataUI.Show()
        NetMsgHandler.SendGetEmailReward(curMailInfo.MailID)
    end
end

function UpdateEmailAttachment()
    CS.LoadingDataUI.Hide();
    curMailInfo.nGold = 0
    textAttachment.text = "×0"
    btnGetAttachment.interactable = false;
end

--endregion