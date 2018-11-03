
local selectStoreConfig = nil
local mGoldText = nil

function Awake()
	mGoldText = this.transform:Find("Canvas/Gold/GoldText"):GetComponent('Text')
	AddButtonHandlers()
end

function WindowOpened()
	ResetStoreUI()
	ResetStoreContentPart()
	NetMsgHandler.RegisterGameParser(ProtrocolID.CS_Buy_Goods, Received_CS_Buy_Goods)
	CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent, UpdateGold)
	UpdateGold()
end

function WindowClosed()
	NetMsgHandler.RemoveGameParser(ProtrocolID.CS_Buy_Goods, Received_CS_Buy_Goods)
	CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, UpdateGold)
end

function ResetStoreUI()
	this.transform:Find('Canvas/CloseStore').gameObject:SetActive(true)
end

-- 按钮响应事件绑定
function AddButtonHandlers()
    this.transform:Find('Canvas/CloseStore'):GetComponent("Button").onClick:AddListener(CloseStoreButtonOnClick)
    this.transform:Find('Canvas/CloseButton'):GetComponent("Button").onClick:AddListener(CloseStoreButtonOnClick)
end

function UpdateGold()
	mGoldText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount))
end

-----------------------------------------------------------------------------------
-----------------------------------商城界面部分------------------------------------
function ResetStoreContentPart()
	local dataItemIndex = 1
	local newStoreItem = nil
	for key, value in ipairs(data.StoreConfig) do
		if value ~= nil then
			if dataItemIndex <= 6 then
				newStoreItem = this.transform:Find('Canvas/StoreItems/StoreItem'..dataItemIndex)
				newStoreItem:Find('BuyButton'):GetComponent("Button").onClick:AddListener(function () StoreItemButtonOnClick(value) end)
				newStoreItem.gameObject:SetActive(true)
				ResetStoreContentData(newStoreItem, key, value, 2)
			end
		end
		dataItemIndex = dataItemIndex + 1
	end
end

function ResetStoreContentData(storeItem, key, storeConfig, index)
	local dataItem = storeItem
	if storeConfig ~= nil then
		local itemCountText = dataItem:Find("ItemCount"):GetComponent("Text")
		itemCountText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(storeConfig.AddDiamond))
		dataItem:Find("PriceText"):GetComponent("Text").text = string.format("￥%.2f", storeConfig.Price)
	end
end

function StoreItemButtonOnClick(storeConfig)
	if LoginMgr.RunningPlatformID == 3 and (GameData.IsOpenApplePay == 1 or GameConfig.IsSpecial() ) then--直接走苹果支付流程
		print("苹果 支付")
		--调用platformbridge支付接口,打开loading界面
		CS.LoadingDataUI.Show(20)
		--构建信息json
		infoTable = {}
		infoTable["accountID"] = GameData.RoleInfo.AccountID
		infoTable["goodsID"] = storeConfig.ID
		infoTable["serverID"] = tostring(GameData.ServerID)
		infoJSON = CS.LuaAsynFuncMgr.Instance:MakeJson(infoTable)
		PlatformBridge:CallFunc(PLATFORM_TYPE.PLATFORM_APP_STORE, PLATFORM_FUNCTION_ENUM.PLATFORM_FUNCTION_PAY, infoJSON)
	else
		CS.BubblePrompt.Show("支付功能暂未开启...", "UIStoreIOS")
	end
end

-- 关闭商城界面
function CloseStoreButtonOnClick()
	CS.WindowManager.Instance:CloseWindow('UIStoreIOS', false)
end

---------------------------------------------------------------------------
------------------------CS_Buy_Goods  900----------------------------------
function Send_CS_Buy_Goods()
	if selectStoreConfig ~= nil then
		local message = CS.Net.PushMessage()
		message:PushUInt32(GameData.RoleInfo.AccountID)
		message:PushByte(selectStoreConfig.ID)
		NetMsgHandler.SendMessageToGame(ProtrocolID.CS_Buy_Goods, message, true)
	end
end

function Received_CS_Buy_Goods(message)
	CS.LoadingDataUI.Hide()
	local resultType = message:PopByte()
	if resultType == 0 then
		ResetStoreUI()
		CS.BubblePrompt.Show("购买成功", "UIStoreIOS")
	end
end