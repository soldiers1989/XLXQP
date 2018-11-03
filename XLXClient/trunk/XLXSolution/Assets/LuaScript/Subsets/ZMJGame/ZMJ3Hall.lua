local Time = CS.UnityEngine.Time

local StoreInterface = nil
local NameText = nil
local GoldText = nil


function Awake()
    GameData.GameState=GAME_STATE.HALL
    StoreInterface = this.transform:Find('Canvas/Back/Store').gameObject
    NameText = this.transform:Find('Canvas/Back/Name/NameText'):GetComponent('Text')
    GoldText = this.transform:Find('Canvas/Back/Gold/GoldText'):GetComponent('Text')
    this.transform:Find('Canvas/Back/Room1'):GetComponent('Button').onClick:AddListener(EnterPDKRoom1)
    this.transform:Find('Canvas/Back/Room2'):GetComponent('Button').onClick:AddListener(EnterPDKRoom2)
    this.transform:Find('Canvas/Back/Room3'):GetComponent('Button').onClick:AddListener(EnterPDKRoom3)
    this.transform:Find('Canvas/Back/Room4'):GetComponent('Button').onClick:AddListener(EnterPDKRoom4)
    this.transform:Find('Canvas/Back/Gold'):GetComponent('Button').onClick:AddListener(function() StoreInterfaceIsDisplay(true) end)
    this.transform:Find('Canvas/Back/StoreButton'):GetComponent('Button').onClick:AddListener(function() StoreInterfaceIsDisplay(true) end)
    this.transform:Find('Canvas/Back/Store/Back/Close'):GetComponent('Button').onClick:AddListener(function() StoreInterfaceIsDisplay(false) end)
    for Index= 1, 6, 1 do
        StoreInterface.transform:Find('Back/StoreButton'..Index):GetComponent('Button').onClick:AddListener(function() StoreButtonOnClick(Index) end)
    end
    UpdateRoleInfos()
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    
end

-- 商城按钮是否显现
function StoreInterfaceIsDisplay(mShow)
    GameObjectSetActive(StoreInterface,mShow)
end

-- 点击充值按钮
function StoreButtonOnClick(StoreId)
    --调用platformbridge支付接口,打开loading界面
    CS.LoadingDataUI.Show(20)
    local configData = data.StoreConfig[30 + StoreId]

    print("=====IOS 支付信息:", configData.ID)
    --构建信息json
    local infoTable = {}
    infoTable["accountID"] = GameData.RoleInfo.AccountID
    infoTable["goodsID"] = configData.ID
    infoTable["serverID"] = tostring(GameData.ServerID)
    infoJSON = CS.LuaAsynFuncMgr.Instance:MakeJson(infoTable)
    PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_APP_STORE, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, infoJSON)
end

-- 进入跑得快初级场
function EnterPDKRoom1()
    Send_CS_NNPP_Enter_Room(1,0)
end

-- 进入跑得快中级场
function EnterPDKRoom2()
    Send_CS_NNPP_Enter_Room(2,0)
end

-- 进入跑的快高级场
function EnterPDKRoom3()
    Send_CS_NNPP_Enter_Room(3,0)
end

-- 进入跑得快土豪场
function EnterPDKRoom4()
    Send_CS_NNPP_Enter_Room(4,0)
end

-- 更新玩家信息
function UpdateRoleInfos()
    NameText.text = GameData.RoleInfo.AccountName
    GoldText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))
end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyZZZPUpdateGoldValue,UpdateRoleInfos)

    UpdateRoleInfos()
    CS.Utility.AutorotateToLandscapeLeft()
end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, UpdateRoleInfos)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyZZZPUpdateGoldValue, UpdateRoleInfos)
end
