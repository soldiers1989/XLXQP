--[[
   文件名称:TeaHouseUI.lua
   创 建 人: 
   创建时间：2018.04
   功能描述：
]]--

local MyTransform = nil

local mNoTeaGameObject = nil            -- 无茶馆时UI
local mNoTeaCreateGameObject = nil
local mNoTeaJoinGameObject = nil
local mJoinInputField = nil
local mNameInput = nil
local mCityInput1 = nil
local mCityInput2 = nil

local mTeaNodeGameObject = nil          -- 有茶馆时UI

local mTeaUPGameObject = nil            -- 升级茶馆UI


function BtnCloseOnClick()
    CS.WindowManager.Instance:CloseWindow('TeaHouseUI', false)
end

function InitUIElement1()
    
    local transform = MyTransform:Find('Canvas/NoTea')
    mNoTeaGameObject = transform.gameObject
    transform:Find('ButtonJoin'):GetComponent("Button").onClick:AddListener(BtnJoinOnClick)
    transform:Find('ButtonCreate'):GetComponent("Button").onClick:AddListener(BtnCreateOnClick)
    mNoTeaJoinGameObject = transform:Find('JoinTea').gameObject
    mJoinInputField = transform:Find('JoinTea/InputFieldID'):GetComponent('InputField')
    transform:Find('JoinTea/BtnJoin'):GetComponent("Button").onClick:AddListener(JoinOnClick)
    transform:Find('JoinTea/BtnCancel'):GetComponent("Button").onClick:AddListener(CancelOnClick)

    
    mNoTeaCreateGameObject = transform:Find('CreateTea').gameObject
    mNameInput = transform:Find('CreateTea/InputFieldName'):GetComponent('InputField')
    mCityInput1 = transform:Find('CreateTea/InputFieldCity1'):GetComponent('InputField')
    mCityInput2 = transform:Find('CreateTea/InputFieldCity2'):GetComponent('InputField')
    transform:Find('CreateTea/BtnCreateTea'):GetComponent("Button").onClick:AddListener(BtnCreateTeaOnClick)
    transform:Find('CreateTea/Image/ButtonReturn'):GetComponent("Button").onClick:AddListener(BtnReturnNoTeaOnClick)
    
    

    GameObjectSetActive(mNoTeaJoinGameObject, false)
    GameObjectSetActive(mNoTeaCreateGameObject, false)
    
end

--=============================加入茶馆模块 START========================

function BtnJoinOnClick()
    if TeaHouseMgr.QuitTime == 0 or TeaHouseMgr.QuitTime >= 172800 then
        GameObjectSetActive(mNoTeaJoinGameObject, true)
    else
        CS.BubblePrompt.Show(data.GetString('T_218_5'), "TeaHouseUI")
    end
end

function JoinOnClick()
    local teaID = mJoinInputField.text
	if teaID == '' then
		CS.BubblePrompt.Show('茶馆ID不能为空', "TeaHouseUI")
		return
	end
	
    local finalNum = SubStringGetTotalCount(teaID)
    if finalNum < 4 or  finalNum > 8  then
        CS.BubblePrompt.Show('请输入正确的茶馆ID:4~8位长度.', "TeaHouseUI")
        return
    end
    NetMsgHandler.Send_CS_TEA_JOIN(tonumber(teaID))
end

function CancelOnClick()
    mJoinInputField.text = ''
    GameObjectSetActive(mNoTeaJoinGameObject, false)
end
--=============================加入茶馆模块 END========================

--=============================创建茶馆模块 START========================
function BtnCreateOnClick()

    if TeaHouseMgr.QuitTime == 0 or TeaHouseMgr.QuitTime >= 172800 then
        GameObjectSetActive(mNoTeaCreateGameObject, true)
        local latitude = CS.UnityEngine.Random.Range(33,40)
        local longitude = CS.UnityEngine.Random.Range(88,114) 

        local tAreaID, tAreaData, tAreaDesc = LBSMgr:GetLBSInfo(latitude, longitude)
        if tAreaID > 0 then
            mCityInput1.text = tAreaData.Province
            mCityInput2.text = tAreaData.City
        end
    else
        CS.BubblePrompt.Show(data.GetString('T_220_7'), "TeaHouseUI")
    end

    
end

function BtnCreateTeaOnClick()
    
    local teaName
    local cityName
    local cityName2
    local indexs

    teaName = mNameInput.text
	if teaName == '' then
		CS.BubblePrompt.Show('茶馆名称不能为空', "TeaHouseUI")
		return
    end
    
    if string.find(teaName, ' ') ~= nil then
        CS.BubblePrompt.Show(data.GetString("Change_Name_Error_4"), "TeaHouseUI")
        return
    end
	
    local finalNum = SubStringGetTotalCount(teaName)
    if finalNum < 2 or  finalNum > 8  then
        CS.BubblePrompt.Show('请输入正确的茶馆ID:2~8位长度.', "TeaHouseUI")
        return
    end

    for k, v in pairs(data.MaskConfig) do
		indexs = string.find(teaName, v.Value)
		if indexs ~= nil then
			CS.BubblePrompt.Show(data.GetString("Change_Name_Error_4"), "TeaHouseUI")
			return
		end
	end

    cityName = mCityInput1.text
    if cityName == '' or string.find(cityName, ' ') ~= nil then
		CS.BubblePrompt.Show('请填写正确地址1', "TeaHouseUI")
		return
    end
    cityName2 = mCityInput2.text
    if cityName2 == '' or string.find(cityName2, ' ') ~= nil then
        CS.BubblePrompt.Show('请填写正确地址2', "TeaHouseUI")
        return
    end

    for k, v in pairs(data.MaskConfig) do
		indexs = string.find(cityName, v.Value)
		if indexs ~= nil then
			CS.BubblePrompt.Show('地址包含异常字符', "TeaHouseUI")
			return
        end
        indexs = string.find(cityName2, v.Value)
        if indexs ~= nil then
			CS.BubblePrompt.Show('地址包含异常字符', "TeaHouseUI")
			return
        end
	end

    NetMsgHandler.Send_CS_TEA_CREATE(teaName, string.format( "%s.%s",cityName, cityName2))
end

function BtnReturnNoTeaOnClick()
    GameObjectSetActive(mNoTeaCreateGameObject, false)
end

--=============================创建茶馆模块 END========================

--=============================茶馆模块 START========================

local mTeaNameText = nil
local mTeaIDText = nil
local mTeaLvGameObject1 = nil
local mTeaLvGameObject2 = nil
local mTeaCountText = nil
local mTeaCityText = nil

local mPaiJuToggle = nil
local mMemberToggle = nil

local mPaijuNodeGameObject = nil        -- 茶馆牌局节点
local mRoomPageText = nil
local mRoomUINodes = {}

local mMemberNodeGameObject = nil      -- 茶馆成员节点
local mMemberPageText = nil
local mBtnUpGameObject = nil
local mBtnNewGameObject = nil
local mBtnNewApplyTag = nil             -- 有新成员申请1
local mApplyFlag = nil                  -- 有新成员申请2
local mBtnQuitGameObject = nil
local mMemberUINodes = {}

local mRoomItemsInit = false            -- 茶馆牌局节点是否初始化
local mMemberItemsInit = false         -- 茶馆成员节点是否初始化

-- 初始化有茶馆UI节点
function InitUIElement2()
    local transform = MyTransform:Find('Canvas/TeaNode')
    mTeaNodeGameObject = transform.gameObject
    mTeaNameText = transform:Find('Tile_1/Text'):GetComponent('Text')
    mTeaIDText = transform:Find('Tile_2/Text'):GetComponent('Text')
    mTeaLvGameObject1 = transform:Find('Tile_3/StarLevel12').gameObject
    mTeaLvGameObject2 = transform:Find('Tile_3/StarLevel22').gameObject
    mTeaCountText = transform:Find('Tile_4/Text'):GetComponent('Text')
    mTeaCityText = transform:Find('MemberNode/CityText'):GetComponent('Text')
    mPaiJuToggle = transform:Find('TogglePaiju'):GetComponent('Toggle')
    mPaiJuToggle.onValueChanged:AddListener( function(isOn) TeaNodeOnValueChanged(isOn, 1) end)
    mMemberToggle = transform:Find('ToggleMember'):GetComponent('Toggle')
    mMemberToggle.onValueChanged:AddListener( function(isOn) TeaNodeOnValueChanged(isOn, 2) end)
    mApplyFlag = transform:Find('ToggleMember/Flag').gameObject
    -- 牌局模块
    mPaijuNodeGameObject = transform:Find('PaijuNode').gameObject
    transform:Find('PaijuNode/CreateRoom/BtnCretae'):GetComponent("Button").onClick:AddListener(BtnCreateRoomOnClick)
    transform:Find('PaijuNode/CreateRoom/BtnUpdate'):GetComponent("Button").onClick:AddListener(BtnUpdateOnClick)
    mRoomPageText = transform:Find('PaijuNode/PageText'):GetComponent("Text")
    transform:Find('PaijuNode/ButtonLeft'):GetComponent("Button").onClick:AddListener(function () OnRoomPageOnClick(false) end )
    transform:Find('PaijuNode/ButtonRight'):GetComponent("Button").onClick:AddListener(function () OnRoomPageOnClick(true) end)

    -- 成员模块
    mMemberNodeGameObject = transform:Find('MemberNode').gameObject
    mMemberPageText = transform:Find('MemberNode/PageText'):GetComponent('Text')
    mBtnUpGameObject = transform:Find('MemberNode/ButtonUp').gameObject
    mBtnNewGameObject = transform:Find('MemberNode/ButtonNew').gameObject
    mBtnNewApplyTag = transform:Find('MemberNode/ButtonNew/HongDianImage').gameObject
    
    mBtnQuitGameObject = transform:Find('MemberNode/ButtonQuit').gameObject

    transform:Find('MemberNode/ButtonUp'):GetComponent('Button').onClick:AddListener(OnBtnUpClick)
    transform:Find('MemberNode/ButtonNew'):GetComponent('Button').onClick:AddListener(OnBtnNewClick)
    transform:Find('MemberNode/ButtonQuit'):GetComponent('Button').onClick:AddListener(OnBtnQuitClick)
    transform:Find('MemberNode/ButtonLeft'):GetComponent("Button").onClick:AddListener(function () OnMemberPageOnClick(false) end )
    transform:Find('MemberNode/ButtonRight'):GetComponent("Button").onClick:AddListener(function () OnMemberPageOnClick(true) end )

    GameObjectSetActive(mApplyFlag,false)

end

-- 设置茶馆基础信息
function SetTeaHouseBaseInfo()
    mTeaNameText.text = TeaHouseMgr.TeaName
    mTeaIDText.text = tostring(TeaHouseMgr.TeaHouseID)
    mTeaCityText.text = string.format("茶馆地址:%s", TeaHouseMgr.TeaAddress)
    mTeaCountText.text = string.format("%d",TeaHouseMgr.TeaMember)
    GameObjectSetActive(mTeaLvGameObject1, TeaHouseMgr.TeaLevel >= 1)
    GameObjectSetActive(mTeaLvGameObject2, TeaHouseMgr.TeaLevel >= 2)
end

function TeaNodeOnValueChanged( isOn, nodeType )
    if isOn then
        GameObjectSetActive(mPaijuNodeGameObject, nodeType == 1)
        GameObjectSetActive(mMemberNodeGameObject, nodeType == 2)
        if nodeType == 1 then
            InitRoomItems()
            ShowRoomListInfo()
            NetMsgHandler.Send_CS_TEA_ROOMLIST()
        else
            InitMemberItems()
            ShowMemberListInfo()
            GameObjectSetActive(mBtnNewApplyTag, TeaHouseMgr.IsNewApplyMessage)
            GameObjectSetActive(mApplyFlag,TeaHouseMgr.IsNewApplyMessage)
            GameObjectSetActive(mBtnUpGameObject, TeaHouseMgr.TeaOwnerID == GameData.RoleInfo.AccountID)
            GameObjectSetActive(mBtnNewGameObject, TeaHouseMgr.TeaOwnerID == GameData.RoleInfo.AccountID)
            GameObjectSetActive(mBtnQuitGameObject, TeaHouseMgr.TeaOwnerID ~= GameData.RoleInfo.AccountID)
            NetMsgHandler.Send_CS_TEA_MEMBER()
        end
    end
end

-------------------------------茶馆房间

local mRoomCurrentPage = 1
local mRoomPageMax = 1
local mRoomPageCell = 10
local mRoomCurrentData = {}

function BtnCreateRoomOnClick()
    GameConfig.OpenCreateRoomUI(1, 2)
end

function BtnUpdateOnClick()
    NetMsgHandler.Send_CS_TEA_ROOMLIST()
end

-- 牌局翻页
function OnRoomPageOnClick(isAdd)
    local newPage = mRoomCurrentPage
    if isAdd then
        newPage = mRoomCurrentPage + 1
    else
        newPage = mRoomCurrentPage - 1
    end

    if newPage < 1 then
        newPage = 1
    end
    if newPage > mRoomPageMax then
        newPage = mRoomPageMax 
    end

    if newPage ~= mRoomCurrentPage then
        mRoomCurrentPage = newPage
        ShowRoomListInfo()
    end
end

function InitRoomItems()
    if mRoomItemsInit == false then
        local paijuNodeParent = MyTransform:Find('Canvas/TeaNode/PaijuNode/RoomViewport/RoomMask/Content')
        local paijuNode = MyTransform:Find('Canvas/TeaNode/PaijuNode/RoomViewport/RoomMask/Content/PaiJuItem1')
        GameObjectSetActive(paijuNode.gameObject, true)
        mRoomUINodes[1] = paijuNode
        for i = 2, 10 do
            local newNode = CS.UnityEngine.Object.Instantiate(paijuNode)
            CS.Utility.ReSetTransform(newNode, paijuNodeParent)
            newNode.name = 'PaiJuItem'..i
            mRoomUINodes[i] = newNode
        end
        for index = 1, 10 do
            mRoomUINodes[index]:GetComponent('Button').onClick:AddListener(function () EnterTeaRoom(index)  end)
            mRoomUINodes[index]:Find('BtnGuanZhu'):GetComponent('Button').onClick:AddListener(function () BtnGuanZhuOnClick(index)  end)
            mRoomUINodes[index]:Find('BtnCost'):GetComponent('Button').onClick:AddListener(function () BtnGuanZhuCostOnClick(index)  end)
            
        end
    end
    mRoomItemsInit = true
end

-- 茶馆房间列表
function OnNotifyTeaRoomEvent()
    ShowRoomListInfo()
end

function ShowRoomListInfo()
    mRoomCurrentData, mRoomCurrentPage, mRoomPageMax = TeaHouseMgr:GetPageNodesByPage(TeaHouseMgr.RoomNodes, mRoomCurrentPage,mRoomPageCell)
    local dataCount = #mRoomCurrentData
    for i = 1, mRoomPageCell do
        if i <= dataCount then
            GameObjectSetActive(mRoomUINodes[i].gameObject, true)
            SetRoomUINodeInfo(mRoomUINodes[i],mRoomCurrentData[i])        
        else
            GameObjectSetActive(mRoomUINodes[i].gameObject, false)
        end
    end
    mRoomPageText.text = string.format( "%d/%d", mRoomCurrentPage, mRoomPageMax)
end

local function GetRoomDescribe(roomType, subType)
    local strRoomName = '赢三张'
    local strRoomType = '激情'

    if roomType == ROOM_TYPE.ZuJu then
        strRoomName = '赢三张'
        strRoomType = data.GetString("ZUJU_GameModel_" .. subType)
    elseif roomType == ROOM_TYPE.ZuJuNN then
        strRoomName = '牛牛'
        strRoomType = '抢庄牛牛'
    elseif roomType == ROOM_TYPE.HongBao then
        strRoomName = '红包接龙'
        strRoomType = data.GetString("HongBao_GameModel_" .. subType)
    elseif roomType == ROOM_TYPE.ZuJuTTZ then
        strRoomName = '推筒子'
        strRoomType = data.GetString("TTZ_GameModel_" .. subType)
    elseif roomType == ROOM_TYPE.ZuJuMaJiang then
        strRoomName = '麻将'
        strRoomType = '血战到底'
    end

    return strRoomName, strRoomType
end

-- 设置成员Item信息
function SetRoomUINodeInfo(transformParam, dataParam)
    local headImage = transformParam:Find('RoleIcon'):GetComponent('Image')
    headImage:ResetSpriteByName(GameData.GetRoleIconSpriteName(dataParam.HeadIcon))

    transformParam:Find('BetText'):GetComponent('Text').text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(dataParam.Bet))
    transformParam:Find('EnrerText'):GetComponent('Text').text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(dataParam.BetEnter))
    transformParam:Find('LeaveText'):GetComponent('Text').text = lua_NumberToStyle1String(GameConfig.GetFormatColdNumber(dataParam.BetLeave))
    transformParam:Find('OnlineText'):GetComponent('Text').text = string.format( "%d/%d", dataParam.OnlineNO, dataParam.OnlineMax)

    local roomName, subRoom = GetRoomDescribe(dataParam.RoomType,dataParam.SubType)
    transformParam:Find('TypeText'):GetComponent('Text').text = subRoom

    local btnGZ = transformParam:Find('BtnGuanZhu').gameObject
    local btnCost = transformParam:Find('BtnCost').gameObject
    GameObjectSetActive(btnGZ, dataParam.GuanZhuRoom == 1)
    if dataParam.GuanZhuRoom == 1 then
        transformParam:Find('BtnCost/Text'):GetComponent('Text').text = string.format( "馆主抽水:%d%s", dataParam.OwnerCost,'%')
    end
    GameObjectSetActive(btnCost, false)
    local tRoomType = {}
    for i = 1, 5 do
        tRoomType[i] = transformParam:Find("ImageType"..i).gameObject
    end
    GameObjectSetActive(tRoomType[1], dataParam.RoomType == ROOM_TYPE.ZuJu)
    GameObjectSetActive(tRoomType[2], dataParam.RoomType == ROOM_TYPE.ZuJuNN)
    GameObjectSetActive(tRoomType[3], dataParam.RoomType == ROOM_TYPE.ZuJuMaJiang)
    GameObjectSetActive(tRoomType[4], dataParam.RoomType == ROOM_TYPE.ZuJuTTZ)
    GameObjectSetActive(tRoomType[5], dataParam.RoomType == ROOM_TYPE.HongBao)
end

function OnMemberValueChanged(isOn, memberIndex)
    local tButton = mMemberUINodes[memberIndex]:Find('ButtonDel').gameObject
    GameObjectSetActive(tButton, isOn)
end

-- 进入房间call
function EnterTeaRoom(roomIndex)
    local tData = mRoomCurrentData[roomIndex]
    if tData == nil then
        print('茶馆房间数据异常:',roomIndex)
        return
    end
    if tData.RoomType == ROOM_TYPE.ZuJu then
        NetMsgHandler.Send_CS_JH_Enter_Room1(tData.RoomID)
    elseif tData.RoomType == ROOM_TYPE.ZuJuNN then
        NetMsgHandler.Send_CS_NN_Enter_Room(tData.RoomID)
    elseif tData.RoomType == ROOM_TYPE.HongBao then
        NetMsgHandler.Send_CS_HB_Enter_Room1(tData.RoomID,0)
    elseif tData.RoomType == ROOM_TYPE.ZuJuTTZ then
        NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(tData.RoomID,0)
    elseif tData.RoomType == ROOM_TYPE.ZuJuMaJiang then
        NetMsgHandler.Send_CS_MJ_ZUJU_ENTER_ROOM(tData.RoomID)
    end
end

-- 查阅馆主房间信息
function BtnGuanZhuOnClick(roomIndex)
    mRoomUINodes[roomIndex]:Find('BtnCost').gameObject:SetActive(true)
end

function BtnGuanZhuCostOnClick(roomIndex)
    mRoomUINodes[roomIndex]:Find('BtnCost').gameObject:SetActive(false)
end

--=====================================成员管理

local mMemberCurrentPage = 1
local mMemberPageMax = 1
local mMemberPageCell = 10
local mMemberCurrentData = {}

function OnBtnUpClick()
    GameObjectSetActive(mTeaUPGameObject,true)
    GameObjectSetActive(mTeaNodeGameObject,false)
    SetTeaUpgradeInfo()
end

function OnBtnNewClick()
    NetMsgHandler.Send_CS_TEA_APPLY()
end

function OnBtnQuitClick()
    local boxData = CS.MessageBoxData()
    boxData.Title = "提示"
    boxData.Content = data.GetString("T_Quit_Tips")
    boxData.Style = 2
    boxData.OKButtonName = "放弃"
    boxData.CancelButtonName = "确定"
    boxData.LuaCallBack = QuitMessageBoxCallBack
    local parentWindow = CS.WindowManager.Instance:FindWindowNodeByName("TeaHouseUI")
    CS.MessageBoxUI.Show(boxData, parentWindow)

    
end
-- 推出提示确认call
function QuitMessageBoxCallBack(result)
    if result == 2 then
        NetMsgHandler.Send_CS_TEA_QUIT()
    end
end

function OnMemberPageOnClick(isAdd)
    local newPage = mMemberCurrentPage
    if isAdd then
        newPage = mMemberCurrentPage + 1
    else
        newPage = mMemberCurrentPage - 1
    end

    if newPage < 1 then
        newPage = 1
    end
    if newPage > mMemberPageMax then
        newPage = mMemberPageMax 
    end

    if newPage ~= mMemberCurrentPage then
        mMemberCurrentPage = newPage
        ShowMemberListInfo()
    end
end

function InitMemberItems()
    if mMemberItemsInit == false then
        local memberNodeParent = MyTransform:Find('Canvas/TeaNode/MemberNode/MemberList/MemberViewport/Content')
        local memberNode = MyTransform:Find('Canvas/TeaNode/MemberNode/MemberList/MemberViewport/Content/MemberItem1')
        mMemberUINodes[1] = memberNode
        for i = 2, 10 do
            local newNode = CS.UnityEngine.Object.Instantiate(memberNode)
            CS.Utility.ReSetTransform(newNode, memberNodeParent)
            newNode.name = 'MemberItem'..i
            mMemberUINodes[i] = newNode
        end
        for index = 1, 10 do
            mMemberUINodes[index]:Find('ButtonDel'):GetComponent('Button').onClick:AddListener(function () OnBtnMemberDelClick(index)  end)
            mMemberUINodes[index]:Find('Toggle'):GetComponent('Toggle').onValueChanged:AddListener( function(isOn) OnMemberValueChanged(isOn, index) end)
        end
    end
    mMemberItemsInit = true
end

function OnNotifyTeaMemberEvent()
    ShowMemberListInfo()
end

function ShowMemberListInfo()
    mMemberCurrentData, mMemberCurrentPage, mMemberPageMax = TeaHouseMgr:GetPageNodesByPage(TeaHouseMgr.MemberNodes, mMemberCurrentPage,mMemberPageCell)
    local dataCount = #mMemberCurrentData
    for i = 1, mMemberPageCell do
        if i <= dataCount then
            GameObjectSetActive(mMemberUINodes[i].gameObject, true)
            SetMmberUINodeInfo(mMemberUINodes[i],mMemberCurrentData[i])        
        else
            GameObjectSetActive(mMemberUINodes[i].gameObject, false)
        end
    end
    mMemberPageText.text = string.format( "%d/%d", mMemberCurrentPage, mMemberPageMax)
end

-- 设置成员Item信息
function SetMmberUINodeInfo(transformParam, dataParam)
    local headImage = transformParam:Find('HeadIcon'):GetComponent('Image')
    headImage:ResetSpriteByName(GameData.GetRoleIconSpriteName(dataParam.HeadIcon))
    transformParam:Find('AccountName'):GetComponent('Text').text = dataParam.strName
    transformParam:Find('AccountID'):GetComponent('Text').text = tostring(dataParam.AccountID)
    transformParam:Find('HeadIcon/VipLevel/Value'):GetComponent('Text').text = 'VIP'..dataParam.VIPLV
    local strJob = dataParam.Job == 1 and '成员' or '馆主'
    transformParam:Find('Job'):GetComponent('Text').text = strJob
    local Online,Offline1,Offline2
    Online = transformParam:Find('Online')
    Offline1 = transformParam:Find('Offline1')
    Offline2 = transformParam:Find('Offline2')
    GameObjectSetActive(Online.gameObject, dataParam.Online == 1)
    GameObjectSetActive(Offline1.gameObject, dataParam.Online == 2)
    GameObjectSetActive(Offline2.gameObject, dataParam.Online == 2)
    if dataParam.Online ~= 1 then
        Offline2:GetComponent('Text').text = OfflineDescribe(dataParam.OfflineTime)
    end
    transformParam:Find('Toggle'):GetComponent('Toggle').isOn = false
    transformParam:Find('ButtonDel').gameObject:SetActive(false)

    if TeaHouseMgr.TeaOwnerID ~= GameData.RoleInfo.AccountID then
        transformParam:Find('Toggle').gameObject:SetActive(false)
    else
        transformParam:Find('Toggle').gameObject:SetActive(true)
    end
    if TeaHouseMgr.TeaOwnerID  == dataParam.AccountID then
        transformParam:Find('Toggle').gameObject:SetActive(false)
    end
end

function OfflineDescribe(offlineTime)
    local strDesc = "离线"
    local oneDay = 86400
    if offlineTime < oneDay then
        strDesc = "一天以内"
    elseif offlineTime < oneDay * 3 then
        strDesc = "一天以上"
    elseif offlineTime < oneDay * 7 then
        strDesc = "三天以上"
    elseif offlineTime < oneDay * 30 then
        strDesc = "七天以上"
    elseif offlineTime < oneDay * 60 then
        strDesc = "一个月以上"
    else
        strDesc = "长期"
    end
    return strDesc 
end

function OnMemberValueChanged(isOn, memberIndex)
    local tButton = mMemberUINodes[memberIndex]:Find('ButtonDel').gameObject
    GameObjectSetActive(tButton, isOn)
end


local requireDelMemberID = 0
-- 馆主踢出成员
function OnBtnMemberDelClick(memberIndex)
    local tData = mMemberCurrentData[memberIndex]
    if tData == nil then
        return
    end
    requireDelMemberID = tData.AccountID
    local boxData = CS.MessageBoxData()
    boxData.Title = "提示"
    boxData.Content = string.format( data.GetString("T_DelMember_Desc"), tData.strName) 
    boxData.Style = 2
    boxData.OKButtonName = "放弃"
    boxData.CancelButtonName = "确定"
    boxData.LuaCallBack = DelMemberMessageBoxCallBack
    local parentWindow = CS.WindowManager.Instance:FindWindowNodeByName("TeaHouseUI")
    CS.MessageBoxUI.Show(boxData, parentWindow)
end

-- 踢出成员call
function DelMemberMessageBoxCallBack(result)
    if result == 2 then
        -- 取消和确定位置反向了的
        NetMsgHandler.Send_CS_TEA_DEL_MEMBER(requireDelMemberID)
        requireDelMemberID = 0
    end
end

-- 馆主踢出成员反馈
function OnNotifyTeaDelMemberEvent(memberid)
    local memberPos = 0
    for i = 1, #mMemberCurrentData do
        if mMemberCurrentData[i].AccountID == memberid then
            memberPos = i
            break
        end
    end
    if mMemberUINodes[memberPos] ~= nil then
        GameObjectSetActive(mMemberUINodes[memberPos].gameObject, false)
    end
end

-- 玩家收到被提出茶馆消息
function OnNotifyTeaKickoutEvent()
    CS.WindowManager.Instance:CloseWindow('TeaHouseUI', false)
end

-- 玩家主动退出茶馆 馆主收到通知
function OnNotifyTeaMemberQuitEvent(tData)
    
end

--=============================茶馆模块 END========================

--=============================茶馆升级 START========================
local mUPCondition1Text = nil
local mUPCondition2Text = nil
local mUPBtnGameObject = nil
local mUPBtnScript = nil
local mUpSuccessGameObject = nil

function InitUIElement3()
    -- 茶馆升级模块
    local transform = MyTransform:Find('Canvas/TeaUP')
    mTeaUPGameObject = transform.gameObject
    mUPCondition1Text = transform:Find('Viewport/Content/Rule02/Image01/Text02'):GetComponent('Text')
    mUPCondition2Text = transform:Find('Viewport/Content/Rule02/Image01/Text03'):GetComponent('Text')
    mUPBtnGameObject = transform:Find('Viewport/Content/Rule03/Image01/ButtonUp').gameObject
    mUPBtnScript = mUPBtnGameObject.transform:GetComponent('Button')
    mUPBtnScript.onClick:AddListener(OnConfirmUpClick)
    mUpSuccessGameObject = transform:Find('UpSuccess').gameObject
    mUpSuccessGameObject.transform:GetComponent('Button').onClick:AddListener(function () GameObjectSetActive(mUpSuccessGameObject, false)  end)
    transform:Find('ButtonReturn3'):GetComponent('Button').onClick:AddListener(OnBtnUpReturnClick)
end

function OnConfirmUpClick()
    NetMsgHandler.Send_CS_TEA_UPGRADE()
end

-- 升级成功反馈
function OnNotifyTeaUpgradeEvent()
    SetTeaUpgradeInfo()
    GameObjectSetActive(mUpSuccessGameObject, true)
    SetTeaHouseBaseInfo()
end

function OnBtnUpReturnClick()
    GameObjectSetActive(mTeaUPGameObject,false)
    GameObjectSetActive(mUpSuccessGameObject, false)
    GameObjectSetActive(mTeaNodeGameObject,true)
end

function SetTeaUpgradeInfo()
    local strDesc1,strDesc2
    mUPBtnScript.interactable = true
    GameObjectSetActive(mUPBtnGameObject,true)
    if TeaHouseMgr.TeaLevel ~= 2 then
        -- 1星茶馆
        if GameData.RoleInfo.VipLevel >= 8 then
            strDesc1 = string.format( data.GetString('T_UP_1'), "<color=#00ff00>已达成</color>" )
        else
            strDesc1 = string.format( data.GetString('T_UP_1'), "<color=#ff0000>未达成</color>" )
            --mUPBtnScript.interactable = false
        end
        if TeaHouseMgr.TeaMember >= 50 then
            strDesc2 = string.format( data.GetString('T_UP_2'), "<color=#00ff00>已达成</color>" )
        else
            strDesc2 = string.format( data.GetString('T_UP_2'), "<color=#ff0000>未达成</color>" ) 
            --mUPBtnScript.interactable = false
        end
    else
        -- 2星茶馆
        GameObjectSetActive(mUPBtnGameObject,false)
        strDesc1 = string.format( data.GetString('T_UP_1'), "<color=#00ff00>已达成</color>" ) 
        strDesc2 = string.format( data.GetString('T_UP_2'), "<color=#00ff00>已达成</color>" ) 
    end

    mUPCondition1Text.text = strDesc1
    mUPCondition2Text.text = strDesc2
end

--=============================茶馆升级 END========================
-- 茶馆详情信息
function OnNotifyTeaInfoEvent()
    ShowTeaHouseBase()
end

function ShowTeaHouseBase()
    GameObjectSetActive(mNoTeaGameObject, lua_NOT_BOLEAN(TeaHouseMgr.IsHaveTea))
    GameObjectSetActive(mTeaNodeGameObject, TeaHouseMgr.IsHaveTea)
    GameObjectSetActive(mApplyFlag,TeaHouseMgr.IsNewApplyMessage)
    if TeaHouseMgr.IsHaveTea then
        mPaiJuToggle.isOn = true
        SetTeaHouseBaseInfo()
    else
        GameObjectSetActive(mNoTeaCreateGameObject, false)
        GameObjectSetActive(mNoTeaJoinGameObject, false)
    end
end

-- 有新的加入申请
function OnNotifyTeaNewApplyEvent()
    GameObjectSetActive(mBtnNewApplyTag, TeaHouseMgr.IsNewApplyMessage)
    GameObjectSetActive(mApplyFlag,TeaHouseMgr.IsNewApplyMessage)
end

function OnNotifyEnterGameEvent()
    --CS.WindowManager.Instance:CloseWindow('TeaHouseUI', false)
end


-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    MyTransform = this.transform
    MyTransform:Find('Canvas/ButtonClose'):GetComponent("Button").onClick:AddListener(BtnCloseOnClick)
    InitUIElement1()
    InitUIElement2()
    InitUIElement3()

    GameObjectSetActive(mNoTeaGameObject,true)
    GameObjectSetActive(mTeaNodeGameObject,false)
    GameObjectSetActive(mTeaUPGameObject,false)
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaInfoEvent, OnNotifyTeaInfoEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaNewApplyEvent, OnNotifyTeaNewApplyEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaMemberEvent, OnNotifyTeaMemberEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaUpgradeEvent, OnNotifyTeaUpgradeEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaDelMemberEvent, OnNotifyTeaDelMemberEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaKickoutEvent, OnNotifyTeaKickoutEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaRoomEvent, OnNotifyTeaRoomEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyTeaMemberQuitEvent, OnNotifyTeaMemberQuitEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyEnterGameEvent, OnNotifyEnterGameEvent)

end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaInfoEvent, OnNotifyTeaInfoEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaNewApplyEvent, OnNotifyTeaNewApplyEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaMemberEvent, OnNotifyTeaMemberEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaUpgradeEvent, OnNotifyTeaUpgradeEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaDelMemberEvent, OnNotifyTeaDelMemberEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaKickoutEvent, OnNotifyTeaKickoutEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaRoomEvent, OnNotifyTeaRoomEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyTeaMemberQuitEvent, OnNotifyTeaMemberQuitEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyEnterGameEvent, OnNotifyEnterGameEvent)

end

-- 对应脚本的刷新数据方法
function RefreshWindowData(windowData)
    if windowData == nil then
       return 
    end
    if windowData.RefreshType == 1 then
        if mTeaNodeGameObject.activeSelf == true then
            -- 刷新茶馆牌局列表
            NetMsgHandler.Send_CS_TEA_ROOMLIST()
        end
    end
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    ShowTeaHouseBase()
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()

end