local playerItemParent = nil
local playerItem = nil
local openCode = 1				--(开启原因 1百人金花 2龙虎斗)

function Awake()
	this.transform:Find('Canvas/Window/CloseBtn'):GetComponent("Button").onClick:AddListener(CloseButtonOnClick)
	playerItemParent = this.transform:Find('Canvas/Window/Content/Viewport/Content')
	playerItem = this.transform:Find('Canvas/Window/Content/Viewport/Content/Item')
end

function Start()
	-- body
	if openCode == 1 then
		NetMsgHandler.Send_CS_Request_Role_List()
	elseif  openCode == 2 then
		NetMsgHandler.Send_CS_LHD_Request_Role_List()
	elseif openCode == 3 then
		BJLGameMgr.Send_CS_BJL_Request_Role_List()
	elseif openCode == 4 then
		NetMsgHandler.Send_CS_BCBM_Request_Role_List();
	elseif openCode == 5 then
		NetMsgHandler.Send_CS_SSC_Request_Role_List();
	end
	
end

function RefreshWindowData(windowData)
	--获取玩家列表
	if nil ~= windowData then
		openCode = windowData
	end
end

function WindowOpened()
	CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyUpdateRoomPlayerList, RefreshPlayerListItems)
end

function WindowClosed()
	CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyUpdateRoomPlayerList, RefreshPlayerListItems)
end

-- 关闭按钮响应
function CloseButtonOnClick()
	PlaySoundEffect("2");
	CS.WindowManager.Instance:CloseWindow("UIRoomPlayers", false)
end

local function _CompMJRoom( tA, tB)
	local result1 = tA.AccountID == GameData.RoleInfo.AccountID
	local result2 = tB.AccountID == GameData.RoleInfo.AccountID

    return result1 and (tA.createRoomTime>tB.createRoomTime) or (tA.IsJoin>tB.IsJoin)
end

-- 刷新玩家列表信息
function RefreshPlayerListItems(plarDatas)
	if plarDatas == nil  then
		return;
	end
	lua_Transform_ClearChildren(playerItemParent, true)
	playerItem.gameObject:SetActive(false)
	local tMine = nil
	local tData = {}
	for key,playerData in ipairs(plarDatas) do
		if playerData.AccountID == GameData.RoleInfo.AccountID then
			tMine = table.remove(plarDatas, key)
			break
		end
	end
	if tMine ~= nil then
		table.insert(plarDatas,1,tMine)
	end

	for key,playerInfo in ipairs(plarDatas) do
		local instanceItem = CS.UnityEngine.GameObject.Instantiate(playerItem)
		if nil ~= instanceItem then
			instanceItem.gameObject:SetActive(true)
			CS.Utility.ReSetTransform(instanceItem, playerItemParent)
			instanceItem:Find('NameText'):GetComponent("Text").text = tostring(playerInfo.strLoginIP)
			instanceItem:Find('GoldText'):GetComponent("Text").text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(playerInfo.GoldCount))
			instanceItem:Find('IconImage'):GetComponent("Image"):ResetSpriteByName(GameData.GetRoleIconSpriteName(playerInfo.HeadIcon))
			instanceItem:Find('Flag').gameObject:SetActive(playerInfo.AccountID == GameData.RoleInfo.AccountID)
		end
	end
end
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(tostring( musicid ))
end