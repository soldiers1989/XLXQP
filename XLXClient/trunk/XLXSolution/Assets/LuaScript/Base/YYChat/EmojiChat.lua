--[[
   文件名称:YYIMChat.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--
local MyTime = CS.UnityEngine.Time
local MyTransform = nil
local XiaoXiInterface = nil
local BiaoQingInterface = nil
local WenZiInterfacxe = nil

local PAOPAO_TYPE = 1
local mRoomNumber = 4
local mEmojiNodes = {}
local mEmojiPositions = {}
local mTextNodes = {}
local mTextTips = "MJ_TEXTNEWS_"

-- 表情界面显示
function ExpressionIterface(isShow)
    if isShow == true then
        ExpressionChildrenIterface()
    end
    GameObjectSetActive(XiaoXiInterface, isShow)
end

function ExpressionChildrenIterface()
    BiaoQingInterface:SetActive(false)
    WenZiInterfacxe:SetActive(false)
    XiaoXiInterface.transform:Find('Button/WenZiBtn/Image').gameObject:SetActive(false)
    XiaoXiInterface.transform:Find('Button/EmojiBtn/Image').gameObject:SetActive(false)
    XiaoXiInterface.transform:Find('Button/WenZiImage/Image').gameObject:SetActive(false)
    XiaoXiInterface.transform:Find('Button/BiaoQingImage/Image').gameObject:SetActive(false)
    if PAOPAO_TYPE == 1 then
        BiaoQingInterface:SetActive(true)
        XiaoXiInterface.transform:Find('Button/EmojiBtn/Image').gameObject:SetActive(true)
        XiaoXiInterface.transform:Find('Button/BiaoQingImage/Image').gameObject:SetActive(true)
    elseif PAOPAO_TYPE == 2 then
        WenZiInterfacxe:SetActive(true)
        XiaoXiInterface.transform:Find('Button/WenZiBtn/Image').gameObject:SetActive(true)
        XiaoXiInterface.transform:Find('Button/WenZiImage/Image').gameObject:SetActive(true)
    end
end

function ExpressionChildrenButtonOnClick(nIndex)
    PAOPAO_TYPE = nIndex
    ExpressionChildrenIterface()
end

-- 发送表情消息
function SendPAOPAO(index,xiaoxiType)
    local tRoomData = GameData.RoomInfo.CurrentRoom
    NetMsgHandler.SendChatPaoPao(tRoomData.SelfPosition,tRoomData.RoomType, PAOPAO_TYPE, index, xiaoxiType)
    ExpressionIterface(false)
end

-- 显示聊天信息
function UpdatePaoPaoInfo(eventArg)
    local position,roomType,senderEnum,sendIndex = eventArg.position,eventArg.roomType,eventArg.senderEnum,eventArg.sendIndex
    --print("聊天信息:",position,roomType,senderEnum,sendIndex)
    
    if senderEnum == 1 then
        -- 表情聊天
        local tNodeParent=this.transform:Find('EmojiItems')
        if tNodeParent.transform:Find('Copy_'..position) ~= nil then
            local OldEmo = tNodeParent.transform:Find('Copy_'..position).gameObject
            CS.UnityEngine.Object.Destroy(OldEmo)
        end
        local tNewNode = CS.UnityEngine.Object.Instantiate(mEmojiNodes[sendIndex])
        CS.Utility.ReSetTransform(tNewNode, tNodeParent)
        lua_Paste_Transform_Value(tNewNode,mEmojiPositions[position])
        tNewNode.name="Copy_"..position
        tNewNode.gameObject:SetActive(true)
        CS.UnityEngine.Object.Destroy(tNewNode.gameObject,3)
    elseif senderEnum == 2 then
        -- 文本聊天
        local wenziObj= mTextNodes[position].gameObject
        if wenziObj.activeSelf == false then
            wenziObj:SetActive(true)
            wenziObj.transform:Find("Text"):GetComponent("Text").text=string.format(data.GetString(mTextTips .. sendIndex))
            local finalWidth = wenziObj.transform:Find("Text"):GetComponent("RectTransform").sizeDelta.x
            wenziObj.transform:GetComponent("RectTransform").sizeDelta = CS.UnityEngine.Vector2(finalWidth,80)
            this:DelayInvoke(1,function()
                wenziObj:SetActive(false)
            end)
        end
    end
end

-- 设置文本消息内容
function TextNewsInfo()
    for mIndex=1,6,1 do
        XiaoXiInterface.transform:Find('WenZiChat/Viewport/Content/Template'..mIndex.."/Text"):GetComponent("Text").text=string.format(data.GetString(mTextTips .. mIndex))
    end
end

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    MyTransform = this.transform
    XiaoXiInterface = MyTransform:Find('EmojiIterface').gameObject
    BiaoQingInterface = MyTransform:Find('EmojiIterface/EmojiChat').gameObject
    WenZiInterfacxe = MyTransform:Find('EmojiIterface/WenZiChat').gameObject

    GameObjectSetActive(XiaoXiInterface, false) 
    MyTransform:Find('EmojiButton'):GetComponent("Button").onClick:AddListener(function() ExpressionIterface(true)end)
    MyTransform:Find('EmojiIterface/Mask'):GetComponent("Button").onClick:AddListener(function() ExpressionIterface(false) end)

    MyTransform:Find('EmojiIterface/Button/EmojiBtn'):GetComponent("Button").onClick:AddListener(function() ExpressionChildrenButtonOnClick(1)end)
    MyTransform:Find('EmojiIterface/Button/WenZiBtn'):GetComponent("Button").onClick:AddListener(function() ExpressionChildrenButtonOnClick(2)end)

    -- 发送表情ID
    for index = 1,16 do
        MyTransform:Find('EmojiIterface/EmojiChat/Viewport/Content/ExpressionButton'..index):GetComponent("Button").onClick:AddListener(function() SendPAOPAO(index,1)end)
        mEmojiNodes[index] = MyTransform:Find('EmojiItems/Expression_'..index)
    end
    -- 发送文字消息ID
    for mIndex = 1, 6, 1 do
        MyTransform:Find('EmojiIterface/WenZiChat/Viewport/Content/Template'..mIndex):GetComponent("Button").onClick:AddListener(function() SendPAOPAO(mIndex,2)end)
        
    end

    
    local tRoomType = GameData.RoomInfo.CurrentRoom.RoomType
    
    if tRoomType == ROOM_TYPE.MenJi or tRoomType == ROOM_TYPE.ZuJu then
        mRoomNumber = JHZUJU_ROOM_PLAYER_MAX
        mTextTips = "JH_TEXTNEWS_"
    elseif tRoomType == ROOM_TYPE.ZuJuNN or tRoomType == ROOM_TYPE.PiPeiNN then
        mRoomNumber = MAX_NNZUJU_ROOM_PLAYER
        mTextTips = "NN_TEXTNEWS_"
    elseif tRoomType == ROOM_TYPE.HongBao or tRoomType == ROOM_TYPE.PPHongBao then
        mRoomNumber = MAX_HBZUJU_ROOM_PLAYER
        mTextTips = "HB_TEXTNEWS_"
    elseif tRoomType == ROOM_TYPE.ZuJuTTZ or tRoomType == ROOM_TYPE.PiPeiTTZ then
        mRoomNumber = MAX_TTZZUJU_ROOM_PLAYER
        mTextTips = "TTZ_TEXTNEWS_"
    elseif tRoomType == ROOM_TYPE.ZuJuMaJiang then
        mRoomNumber = MAX_MJZUJU_ROOM_PLAYER
        mTextTips = "MJ_TEXTNEWS_"
    elseif tRoomType == ROOM_TYPE.PiPeiPDK then
        mRoomNumber = MAX_PDKZUJU_ROOM_PLAYER
        mTextTips = "PDK_TEXTNEWS_"
    end

    for position = 1, mRoomNumber do
        mEmojiPositions[position] = MyTransform:Find('EmojiItems/Player'..position)
        mTextNodes[position] = MyTransform:Find('TextItems/Expression_'..position)
    end

    TextNewsInfo()
end

-- Unity MonoBehavior Start 时调用此方法
function Start()

    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyChatPaoPao, UpdatePaoPaoInfo)-- 显示聊天信息
    
end

function Update()
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyChatPaoPao, UpdatePaoPaoInfo)
end