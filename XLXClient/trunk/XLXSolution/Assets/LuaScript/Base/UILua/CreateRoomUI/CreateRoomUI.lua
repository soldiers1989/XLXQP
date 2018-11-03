
local MyTransform = nil

local mToggleGroup = {}
local mToggleFlag = {}
local mRoomNodes = {}
local mGZBrokerageGameObjects = {}
local mGZToggleGameObjects = {}

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    MyTransform = this.transform
    -- 返回按钮
    MyTransform:Find('Canvas/ButtonClose'):GetComponent("Button").onClick:AddListener(ReturnButtonOnClick)
    for i = 1, 5 do
        mToggleGroup[i] = MyTransform:Find('Canvas/RoomType/Toggle'..i):GetComponent('Toggle')
        mToggleGroup[i].onValueChanged:AddListener( function(isOn) RoomValueOnValueChanged(isOn, i) end)
        mToggleFlag[i] = MyTransform:Find('Canvas/RoomType/Toggle'..i.."/Background/Checkmark/Image").gameObject
    end
    mRoomNodes[1] = MyTransform:Find('Canvas/YSZNode').gameObject
    mRoomNodes[2] = MyTransform:Find('Canvas/NNNode').gameObject
    mRoomNodes[3] = MyTransform:Find('Canvas/HBNode').gameObject
    mRoomNodes[4] = MyTransform:Find('Canvas/TTZNode').gameObject
    mRoomNodes[5] = MyTransform:Find('Canvas/MJNode').gameObject

    mGZBrokerageGameObjects[1] = MyTransform:Find('Canvas/YSZNode/GZBrokerage').gameObject
    mGZBrokerageGameObjects[2] = MyTransform:Find('Canvas/NNNode/GZBrokerage').gameObject
    mGZBrokerageGameObjects[3] = MyTransform:Find('Canvas/HBNode/GZBrokerage').gameObject
    mGZBrokerageGameObjects[4] = MyTransform:Find('Canvas/TTZNode/GZBrokerage').gameObject
    mGZBrokerageGameObjects[5] = MyTransform:Find('Canvas/MJNode/GZBrokerage').gameObject
    
    mGZToggleGameObjects[1] = MyTransform:Find('Canvas/YSZNode/GZToggle').gameObject
    mGZToggleGameObjects[2] = MyTransform:Find('Canvas/NNNode/GZToggle').gameObject
    mGZToggleGameObjects[3] = MyTransform:Find('Canvas/HBNode/GZToggle').gameObject
    mGZToggleGameObjects[4] = MyTransform:Find('Canvas/TTZNode/GZToggle').gameObject
    mGZToggleGameObjects[5] = MyTransform:Find('Canvas/MJNode/GZToggle').gameObject

    for index = 1, 5 do
        GameObjectSetActive(mRoomNodes[index], false)
        GameObjectSetActive(mGZBrokerageGameObjects[index], false)
        GameObjectSetActive(mToggleFlag[index], false)
        GameObjectSetActive(mGZToggleGameObjects[index],false)
        mGZToggleGameObjects[index].transform:GetComponent("Toggle").onValueChanged:AddListener(function (isOn)  
            GameObjectSetActive(mGZBrokerageGameObjects[index], isOn)  
        end)
    end

    if GameConfig.IsSpecial() == true then
        GameObjectSetActive( mToggleGroup[5].gameObject, false)
    end

end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyCreateRoomSuccess, OnNotifyCreateRoomSuccessEvent)
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyCreateRoomSuccess, OnNotifyCreateRoomSuccessEvent)
end

-- 对应脚本的刷新数据方法
function RefreshWindowData(windowData)
    if windowData ~= nil then
        mToggleGroup[windowData.RoomType].isOn = true
        if windowData.OpenType == 2 then
            for index = 1, 5 do
                GameObjectSetActive(mGZBrokerageGameObjects[index], TeaHouseMgr:CanCreateOwnerTeaRoom() == 1)
                GameObjectSetActive(mGZToggleGameObjects[index], TeaHouseMgr:CanCreateOwnerTeaRoom() == 1)
            end    
        end
    end
end

-- 响应 返回按钮 点击事件
function ReturnButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('CreateRoomUI', false)
end

function RoomValueOnValueChanged(isOn, roomType)
    GameObjectSetActive(mRoomNodes[roomType], isOn)
    GameObjectSetActive(mToggleFlag[roomType], isOn)
end

function OnNotifyCreateRoomSuccessEvent()
    CS.WindowManager.Instance:CloseWindow("CreateRoomUI", false)
end
