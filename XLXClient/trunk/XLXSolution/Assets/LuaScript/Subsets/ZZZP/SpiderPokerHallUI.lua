
local mTime = CS.UnityEngine.Time

-- 金币值文本组件
local GoldValueText = nil
-- 房间锁
local LockObject = {}
-- UI组件根节点
local mMyTransform = nil
-- 房间等级
local RoomLevel = 1

-- 商城界面
local StoreInterface = nil

function Awake()
    mMyTransform = this.transform
    InitSpiderUIElement()
    AddButtonHandlers()
    SetRoomInfo()
end

function InitSpiderUIElement()
    GoldValueText = mMyTransform:Find('Canvas/RoleInfo/Gold/Number'):GetComponent('Text')
    StoreInterface = mMyTransform:Find('Canvas/Store').gameObject
    for Index=1,4,1 do
        LockObject[Index] = mMyTransform:Find('Canvas/RoomLevel/RoomContent/Viewport/Content/RoomInfo'..Index..'/back/Lock').gameObject
        GameObjectSetActive(LockObject[Index],true)
    end
    GameObjectSetActive(LockObject[1],false)
end

function AddButtonHandlers()
    mMyTransform:Find('Canvas/RoomLevel/RoomContent/Viewport/Content/RoomInfo1/back'):GetComponent('Button').onClick:AddListener(function() OpenSpritePokerGame(1) end)
    for Index=2,4,1 do
        mMyTransform:Find('Canvas/RoomLevel/RoomContent/Viewport/Content/RoomInfo'..Index..'/back'):GetComponent('Button').onClick:AddListener(JingQingQiDai )
    end
    mMyTransform:Find('Canvas/Store/Background/Determine'):GetComponent('Button').onClick:AddListener(SpiderPokerRechargeButtonOnClick )
    mMyTransform:Find('Canvas/RoleInfo/Gold'):GetComponent('Button').onClick:AddListener(function() OpenStoreInterface(true) end)
    mMyTransform:Find('Canvas/Store/Background/Close'):GetComponent('Button').onClick:AddListener(function() OpenStoreInterface(false) end)
end

-- 设置房间基础信息
function SetRoomInfo()
    if CS.UnityEngine.PlayerPrefs.GetInt("SpiderIsNew") == 0 then
        CS.UnityEngine.PlayerPrefs.SetInt("SpiderIsNew",1)
        CS.UnityEngine.PlayerPrefs.SetInt("SpiderMayOpenLevel",1)
    end

    GoldValueText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))

    if CS.UnityEngine.PlayerPrefs.GetInt("SpiderMayOpenLevel") ~= nil then
        local Count = CS.UnityEngine.PlayerPrefs.GetInt("SpiderMayOpenLevel")
        for Index=1,Count,1 do
            GameObjectSetActive(LockObject[Index],false)
        end
    end
end

function OpenSpritePokerGame(Level)
    RoomLevel = Level
    CS.UnityEngine.PlayerPrefs.SetInt("SpiderEnterLevel", RoomLevel)
    if CS.WindowManager.Instance:FindWindowNodeByName('SpiderPokerGameUI') == nil then
        local GoldValue = GameData.RoleInfo.GoldCount
        if GoldValue >= 500 then
            GameData.RoleInfo.GoldCount = GoldValue-500
            NetMsgHandler.Send_CS_Update_FreeGold(-500)
            CS.WindowManager.Instance:OpenWindow("SpiderPokerGameUI")
            this:DelayInvoke(1,function ()
                CS.WindowManager.Instance:CloseWindow("SpiderPokerHallUI",false)
            end)
        else
            PromptDisplay()
        end
    end
end

-- 打开充值面板
function OpenStoreInterface(mShow)
    GameObjectSetActive(StoreInterface,mShow)
end

function JingQingQiDai()
    CS.BubblePrompt.Show(data.GetString("敬请期待"), "SpiderEnterLevel")
end

-- 点击充值按钮
function SpiderPokerRechargeButtonOnClick()
    print("苹果 支付")
	--调用platformbridge支付接口,打开loading界面
	CS.LoadingDataUI.Show(20)
	--构建信息json
	infoTable = {}
	infoTable["accountID"] = GameData.RoleInfo.AccountID
	infoTable["goodsID"] = 1
	infoTable["serverID"] = tostring(GameData.ServerID)
	infoJSON = CS.LuaAsynFuncMgr.Instance:MakeJson(infoTable)
	PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_APP_STORE, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, infoJSON)
end

-- 提示
function PromptDisplay()
    local Prompt = mMyTransform:Find('Canvas/Prompt').gameObject
    GameObjectSetActive(Prompt,false)
    GameObjectSetActive(Prompt,true)
    this:DelayInvoke(1.5,function ()
        GameObjectSetActive(Prompt,false)
    end)
end

-- 充值成功
function ZZZPUpdateGoldValue()
    GoldValueText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))
    local Prompt = mMyTransform:Find('Canvas/Prompt1').gameObject
    GameObjectSetActive(Prompt,false)
    GameObjectSetActive(Prompt,true)
    this:DelayInvoke(1.5,function ()
        GameObjectSetActive(Prompt,false)
    end)
end

function onNotifyGoldUpdateEvent()
    GoldValueText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))
end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZZZPUpdateGoldValue, ZZZPUpdateGoldValue)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent, onNotifyGoldUpdateEvent)
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZZZPUpdateGoldValue, ZZZPUpdateGoldValue)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, onNotifyGoldUpdateEvent)
end