--[[
   文件名称:TeaApplyUI.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

local MyTransform = nil
local mApplyItem = nil
local mApplyParent = nil
local mApplyUINodes = {}
local mBtnAllGameObject = nil
local mNoTextGameObject = nil
local mNeedRequestMember = false

function CloseButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('TeaApplyUI', false)
    if mNeedRequestMember then
        NetMsgHandler.Send_CS_TEA_MEMBER()
    end
end

-- 同意某条申请call
function OnBtnAcceptClick(posParam)
    local tData = TeaHouseMgr.ApplyNodes[posParam]
    if tData == nil then
        CS.BubblePrompt.Show("处理数据异常:"..posParam, "TeaApplyUI")
        return 
    end
    NetMsgHandler.Send_CS_TEA_APPLY_HANDLE(tData.AccountID, 1)
end

-- 拒绝某条申请
function OnBtnRefusedClick(posParam)
    local tData = TeaHouseMgr.ApplyNodes[posParam]
    if tData == nil then
        CS.BubblePrompt.Show("处理数据异常:"..posParam, "TeaApplyUI")
        return 
    end
    NetMsgHandler.Send_CS_TEA_APPLY_HANDLE(tData.AccountID, 2)
end

-- 馆主逐条处理申请反馈
function OnNotifyTeaApplyHandleEvent(dataParam)
    local applyid = dataParam.ApplyID
    local tIndex = TeaHouseMgr:FindApplyPositionByAccount(applyid)
    if mApplyUINodes[tIndex] ~= nil then
        GameObjectSetActive(mApplyUINodes[tIndex].gameObject, false)
    end
    if dataParam.Agree == 1 and dataParam.Result == 0  then
        mNeedRequestMember = true
    end
end

-- 全部接受申请
function OnBtnAllClick()
    local dataCount = #TeaHouseMgr.ApplyNodes
    local memberCount = #TeaHouseMgr.MemberNodes
    if dataCount == 0 then
       return 
    end
    if dataCount + memberCount > TeaHouseMgr.TeaMemberMax then
        CS.BubblePrompt.Show("申请者数量已超过茶馆最大人数,请逐条处理", "TeaApplyUI")
        return
    end

    NetMsgHandler.Send_CS_TEA_APPLY_ALL()
end

-- 全部接受处理成功反馈
function OnNotifyTeaApplyAllEvent()
    for i = 1, #mApplyUINodes do
        GameObjectSetActive(mApplyUINodes[i].gameObject, false)
    end
    GameObjectSetActive(mBtnAllGameObject, false)
    mNeedRequestMember = true
end


function ResetApplyItem(transformParam, dataParam, positionParam)
    local headImage = transformParam:Find('HeadIcon'):GetComponent('Image')
    headImage:ResetSpriteByName(GameData.GetRoleIconSpriteName(dataParam.HeadIcon))
    transformParam:Find('AccountName'):GetComponent('Text').text = dataParam.strName
    transformParam:Find('AccountID'):GetComponent('Text').text = tostring(dataParam.AccountID)
    transformParam:Find('HeadIcon/VipLevel/Value'):GetComponent('Text').text = 'VIP'..dataParam.VIPLv
    transformParam:Find('BtnAccept'):GetComponent('Button').onClick:AddListener(function () OnBtnAcceptClick(positionParam) end)
    transformParam:Find('BtnRefused'):GetComponent('Button').onClick:AddListener(function () OnBtnRefusedClick(positionParam) end)
end

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    MyTransform = this.transform
    mApplyParent = MyTransform:Find('Canvas/MemmberList/MemberMask/Content')
    mApplyItem = MyTransform:Find('Canvas/MemmberList/MemberMask/Content/ApplyItem')
    MyTransform:Find('Canvas/BtnReturn'):GetComponent("Button").onClick:AddListener(CloseButtonOnClick)
    MyTransform:Find('Canvas/ButtonAll'):GetComponent("Button").onClick:AddListener(OnBtnAllClick)
    mBtnAllGameObject = MyTransform:Find('Canvas/ButtonAll').gameObject
    mNoTextGameObject = MyTransform:Find('Canvas/NoText').gameObject
    GameObjectSetActive(mNoTextGameObject, false)
    GameObjectSetActive(mApplyItem.gameObject, false)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
	local tDatas = TeaHouseMgr.ApplyNodes
    if tDatas ~= nil then
        local newItem = nil
        for key, tData in ipairs(tDatas) do
            newItem = CS.UnityEngine.Object.Instantiate(mApplyItem)
            CS.Utility.ReSetTransform(newItem, mApplyParent)
            newItem.gameObject:SetActive(true)
            ResetApplyItem(newItem, tData, key)
            mApplyUINodes[key] = newItem
        end
    end

    local count = #tDatas
    GameObjectSetActive(mBtnAllGameObject, count > 1)
    GameObjectSetActive(mNoTextGameObject, count == 0)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaApplyHandleEvent, OnNotifyTeaApplyHandleEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaApplyAllEvent, OnNotifyTeaApplyAllEvent)
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaApplyHandleEvent, OnNotifyTeaApplyHandleEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaApplyAllEvent, OnNotifyTeaApplyAllEvent)
end