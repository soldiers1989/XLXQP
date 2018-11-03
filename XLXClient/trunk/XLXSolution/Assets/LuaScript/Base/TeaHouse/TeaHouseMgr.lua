--[[
   文件名称:TeaHouseMgr.lua
   创 建 人: 
   创建时间：2018.04
   功能描述：
]]--

if TeaHouseMgr == nil then
    TeaHouseMgr =
    {
        TeaHouseID = 0,                 -- 茶馆ID
        TeaOwnerID = 0,                 -- 馆主ID
        TeaLevel = 1,                   -- 茶馆等级
        TeaMember = 0,                  -- 茶馆人数
        TeaMemberMax = 50,              -- 茶馆最大人数
        TeaName = '*****俱乐部',              -- 茶馆名称
        TeaAddress = "北京.北京",       -- 茶馆

        IsHaveTea = false,              -- 是否拥有茶馆
        IsNewApplyMessage = false,      -- 是否有新的申请消息
        QuitTime = 0,                   -- 离开茶馆时间

        MemberNodes = {},               -- 茶馆成员列表
        ApplyNodes = {},                -- 茶馆申请列表
        RoomNodes = {},                 -- 茶馆房间列表
    }
end

--==============================--
--desc:请求加入茶馆
--time:
--@dataNodes:数据源
--@page:哪一页
--@pageCell:每页单位数据
--@return : 本页数据,当前页,最大页
--==============================--
function TeaHouseMgr:GetPageNodesByPage(dataNodes, page, pageCell)
    -- 参数校正
    if pageCell <= 0 then
        pageCell = 1 
    end
    if page < 1 then
       page = 1 
    end

    local pageNodes = {}
    local dataCount = #dataNodes

    local pageMax = math.ceil( dataCount / pageCell )
    if pageMax < 1 then
       pageMax = 1 
    end
    if page > pageMax then
       page = pageMax 
    end

    local beginIndex = (page - 1) * pageCell + 1
    local endIndex = page * pageCell
    for index = beginIndex, endIndex, 1 do
        if index <= dataCount then
            table.insert(pageNodes, dataNodes[index])
        end
    end

    return pageNodes, page, pageMax
end

--==============================--
--desc:获取申请者位置
--time:
--@accountid:申请者ID
--@return : 
--==============================--
function TeaHouseMgr:FindApplyPositionByAccount(accountid)
    local position = 0
    for key, tData in ipairs(TeaHouseMgr.ApplyNodes) do
        if tData.AccountID == accountid then
            position = key
            break
        end
    end
    return position
end

--==============================--
--desc:能否创建馆主房间
--time:
--@return : 0 不能 1 能
--==============================--
function TeaHouseMgr:CanCreateOwnerTeaRoom()
    if TeaHouseMgr.TeaHouseID == 0 then
        return 0 
    end
    if TeaHouseMgr.TeaOwnerID == GameData.RoleInfo.AccountID and TeaHouseMgr.TeaLevel >= 2  then
        return 1
    end
    return 0
end

-----------------CS_TEA_JOIN  218-------------------------------------
-------------------请求加入茶馆----------------------------------------

--==============================--
--desc:请求加入茶馆
--time:
--@teahouseid:茶馆ID
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_JOIN(teahouseid)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    message:PushUInt32(teahouseid)                      --茶馆ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_JOIN, message, true)
end


function NetMsgHandler.Received_CS_TEA_JOIN(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()        --结果
    if result == 0 then

    end
    CS.BubblePrompt.Show(data.GetString('T_218_' .. result), "TeaHouseUI")
end

-----------------S_TEA_JOIN_NOTIFY  219-------------------------------------
------------------通知馆主有人申请加入茶馆-----------------------------------

function NetMsgHandler.Received_S_TEA_JOIN_NOTIFY(message)
    local applyID = message:PopUInt32()         --申请者ID
    local applyName = message:PopString()       --申请者名字
    TeaHouseMgr.IsNewApplyMessage = true
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaNewApplyEvent, nil)
end

-----------------CS_TEA_CREATE  220-----------------------------------
---------------------请求创建茶馆-------------------------------------

--==============================--
--desc:请求创建茶馆
--time:
--@name:茶馆Name
--@address:茶馆地址
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_CREATE(name, address)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    message:PushString(name)                            --茶馆Name
    message:PushString(address)                         --茶馆地址
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_CREATE, message, true)
end

function NetMsgHandler.Received_CS_TEA_CREATE(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()            --结果
    if result == 0 then
        NetMsgHandler.Send_CS_TEA_INFO()
    end
    CS.BubblePrompt.Show(data.GetString('T_220_' .. result), "TeaHouseUI")
end

-----------------CS_TEA_INFO  221-----------------------------------
---------------------茶馆详情---------------------------------------

--==============================--
--desc:请求茶馆详情
--time:
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_INFO()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_INFO, message, true)
end

function NetMsgHandler.Received_CS_TEA_INFO(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()                        --结果
    if result == 0 then
        local haveTea = message:PopByte()                   --是否拥有茶馆(0: 没有 1: 有)
        if haveTea == 0 then
            TeaHouseMgr.IsHaveTea = false
            TeaHouseMgr.QuitTime = message:PopUInt32()
        else
            TeaHouseMgr.IsHaveTea = true
            TeaHouseMgr.TeaHouseID = message:PopUInt32()    --茶馆ID
            TeaHouseMgr.TeaOwnerID = message:PopUInt32()    --馆主ID
            TeaHouseMgr.TeaLevel = message:PopByte()        --茶馆等级
            TeaHouseMgr.TeaMember = message:PopUInt32()     --茶馆人数
            TeaHouseMgr.TeaName = message:PopString()       --茶馆名称
            TeaHouseMgr.TeaAddress = message:PopString()    --茶馆地址
        end

    else
        TeaHouseMgr.IsHaveTea = false
        CS.BubblePrompt.Show(data.GetString('T_221_' .. result), "TeaHouseUI")
    end

    local tUINode = CS.WindowManager.Instance:FindWindowNodeByName('TeaHouseUI')
    if tUINode == nil then
        local openparam = CS.WindowNodeInitParam("TeaHouseUI")
        openparam.NodeType = 0
        CS.WindowManager.Instance:OpenWindow(openparam)
    else
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaInfoEvent, nil)
    end 

end


-----------------CS_TEA_MEMBER  222-----------------------------------
--------------------茶馆成员列表---------------------------------------

--==============================--
--desc:茶馆成员列表
--time:
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_MEMBER()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_MEMBER, message, false)
end

local function _CompTeaMember( tA, tB)
    return tA.Online < tB.Online and 1 or  tA.OfflineTime < tB.OfflineTime
end

function NetMsgHandler.Received_CS_TEA_MEMBER(message)
    local result = message:PopByte()                    --结果
    if result == 0  then
        TeaHouseMgr.MemberNodes = {}
        local memberCount = message:PopUInt16()         --茶馆人数
        for i = 1, memberCount do
            local memberData = {}
            memberData.AccountID = message:PopUInt32()  --成员ID
            memberData.strName  = message:PopString()   --成员Name
            memberData.HeadIcon = message:PopByte()     --成员头像ID
            memberData.VIPLV = message:PopByte()        --成员VIP等级
            memberData.Job = message:PopByte()          --成员职位(1: 普通 2: 馆主)
            memberData.Online = message:PopByte()       --在线状态
            memberData.OfflineTime = message:PopUInt32()--离线事件
            memberData.strLoginIP = message:PopString() --登陆IP
            table.insert(TeaHouseMgr.MemberNodes, memberData)
        end
        if #TeaHouseMgr.MemberNodes > 1 then
            table.sort(TeaHouseMgr.MemberNodes, _CompTeaMember)
        end
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaMemberEvent, nil)
    else
        CS.BubblePrompt.Show(data.GetString('T_222_' .. result), "TeaHouseUI")
    end
end

-----------------CS_TEA_UPGRADE  223-----------------------------------
---------------------馆主升级茶馆---------------------------------------

--==============================--
--desc:馆主升级茶馆
--time:
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_UPGRADE()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_UPGRADE, message, true)
end

function NetMsgHandler.Received_CS_TEA_UPGRADE(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()            --结果 (0: 成功)
    if result == 0 then
       local starLv = message:PopByte()         --茶馆当前等级
       TeaHouseMgr.TeaLevel = starLv
       CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaUpgradeEvent, nil)
    else
        CS.BubblePrompt.Show(data.GetString('T_223_' .. result), "TeaHouseUI")
    end
end

-----------------CS_TEA_APPLY  224-----------------------------------
----------------馆主获取申请加入列表----------------------------------

--==============================--
--desc:馆主获取申请加入列表
--time:
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_APPLY()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_APPLY, message, true)
end

function NetMsgHandler.Received_CS_TEA_APPLY(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()                    --结果 ( 0: 成功 )
    if result == 0 then
        TeaHouseMgr.ApplyNodes = {}
        local applyCount = message:PopUInt16()          --茶馆申请人数
        for i = 1, applyCount do
            local  tData = {}
            tData.AccountID = message:PopUInt32()       --成员ID
            tData.strName = message:PopString()         --成员Name
            tData.HeadIcon = message:PopByte()          --成员头像ID
            tData.VIPLv = message:PopByte()             --成员VIP等级
            tData.strLoginIP = message:PopString()      --登陆IP
            table.insert(TeaHouseMgr.ApplyNodes, tData)
        end
        local tUINode = CS.WindowManager.Instance:FindWindowNodeByName('TeaApplyUI')
        if tUINode == nil then
            local openparam = CS.WindowNodeInitParam("TeaApplyUI")
            openparam.NodeType = 0
            CS.WindowManager.Instance:OpenWindow(openparam)
        else
            CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaApplyListEvent, nil)
        end
        TeaHouseMgr.IsNewApplyMessage = false
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaNewApplyEvent, nil)
    else
        CS.BubblePrompt.Show(data.GetString('T_224_' .. result), "TeaHouseUI")
    end
end

-----------------CS_TEA_APPLY_HANDLE  225-----------------------------------
--------------------(馆主)处理申请列表---------------------------------------

--==============================--
--desc:馆主逐条处理申请信息
--time:
--@accountid : 申请者账号 
--@agree : 处理意见 1同意 2 拒绝 
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_APPLY_HANDLE(accountid, agree)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID) --账号ID
    message:PushUInt32(accountid)                   --申请者ID
    message:PushByte(agree)                         --处理意见 (1:同意 2:拒绝)
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_APPLY_HANDLE, message, true)
end

function NetMsgHandler.Received_CS_TEA_APPLY_HANDLE(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()            --结果
    local arguments = {}
    arguments.Result = result
    arguments.Agree = message:PopByte()         --处理意见
    arguments.ApplyID = message:PopUInt32()     --申请者ID
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaApplyHandleEvent, arguments)
    CS.BubblePrompt.Show(data.GetString('T_225_' .. result), "TeaHouseUI")
end

-----------------S_TEA_APPLY_FEEDBACK  226----------------------------
------------------(申请者)收到申请处理反馈-----------------------------
function NetMsgHandler.Received_S_TEA_APPLY_FEEDBACK(message)
    local tAgree = message:PopByte()            --处理意见
    local tTeaName = message:PopString()        --茶馆Name

    CS.BubblePrompt.Show(string.format(data.GetString('T_226_' .. tAgree),tTeaName) , "TeaHouseUI")
end

-----------------S_TEA_NEW_MEMBER  227--------------------------------
----------------------新人加入工会-------------------------------------
function NetMsgHandler.Received_S_TEA_NEW_MEMBER(message)
    local memberID = message:PopUInt32()        --新人ID
    local memberName = message:PopString()      --新人Name
    local teaID = message:PopUInt32()           --茶馆ID
    local teaName = message:PopString()         --茶馆Name

    local strDesc = ""
    if memberID == GameData.RoleInfo.AccountID then
        strDesc = string.format(data.GetString('T_New_Member_1'),teaName)
    else
        strDesc = string.format(data.GetString('T_New_Member_2'),memberName)
    end
    CS.BubblePrompt.Show(strDesc, "TeaHouseUI")
end

-----------------CS_TEA_APPLY_ALL  228--------------------------------
-----------------(馆主)全部同意加入申请--------------------------------

--==============================--
--desc:馆主一次性全部处理申请信息
--time:
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_APPLY_ALL()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_APPLY_ALL, message, true)
end

function NetMsgHandler.Received_CS_TEA_APPLY_ALL(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()        --结果 ( 0: 结果 )
    if result == 0 then
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaApplyAllEvent, nil)
    end
    CS.BubblePrompt.Show(data.GetString('T_228_' .. result), "TeaHouseUI")
end

-----------------CS_TEA_DEL_MEMBER  229--------------------------------
-------------------(馆主)踢出某位成员-----------------------------------

--==============================--
--desc:馆主踢出成员
--time:
--@kickoutID:被提出者ID
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_DEL_MEMBER(kickoutID)
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    message:PushUInt32(kickoutID)                       --被踢出者
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_DEL_MEMBER, message, true)
end


function NetMsgHandler.Received_CS_TEA_DEL_MEMBER(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()            --结果 ( 0: 成功 1: 账号不存在 )
    if  result == 0 then
        local memberID = message:PopUInt32()    --被踢出者ID

        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaDelMemberEvent, memberID)
    else
        CS.BubblePrompt.Show(data.GetString('T_229_' .. result), "TeaHouseUI")
    end
end

-----------------S_TEA_KICKOUT  230-----------------------------------
--------------------玩家被提出工会-------------------------------------

function NetMsgHandler.Received_S_TEA_KICKOUT(message)
    local teaName = message:PopString()     --茶馆Name
    CS.BubblePrompt.Show(string.format(data.GetString('T_KICKOUT'), teaName), "TeaHouseUI")
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaKickoutEvent, nil)
    TeaHouseMgr.IsHaveTea = false
    TeaHouseMgr.TeaHouseID = 0
    TeaHouseMgr.TeaOwnerID = 0
end


-----------------CS_TEA_QUIT  231-------------------------------------
-------------------玩家退出公会----------------------------------------

--==============================--
--desc:成员退出茶馆
--time:
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_QUIT()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)         --账号ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_QUIT, message, true)
end

function NetMsgHandler.Received_CS_TEA_QUIT(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()        --结果 ( 0: 成功 1: 账号不存在  2: 没有茶馆 3: 茶馆不能退出 )
    if result == 0 then
        CS.WindowManager.Instance:CloseWindow('TeaHouseUI', false)
        TeaHouseMgr.IsHaveTea = false
        TeaHouseMgr.TeaHouseID = 0
        TeaHouseMgr.TeaOwnerID = 0
    end
    CS.BubblePrompt.Show(data.GetString('T_231_' .. result), "TeaHouseUI")
end


-----------------CS_TEA_ROOMLIST  232---------------------------------
---------------------茶馆牌局列表--------------------------------------

--==============================--
--desc:茶馆牌局列表请求
--time:
--@return 
--==============================--
function NetMsgHandler.Send_CS_TEA_ROOMLIST()
    local message = CS.Net.PushMessage()
    message:PushUInt32(GameData.RoleInfo.AccountID)     --账号ID
    NetMsgHandler.SendMessageToGame(ProtrocolID.CS_TEA_ROOMLIST, message, true)
end

local function _CompTeaRoom( tA, tB)
    return tA.CreateTime > tB.CreateTime
end

function NetMsgHandler.Received_CS_TEA_ROOMLIST(message)
    CS.LoadingDataUI.Hide()
    local result = message:PopByte()                --结果 ( 0:成功 1:账号不存在 2:没有茶馆)
    if result == 0 then
        TeaHouseMgr.RoomNodes = {}
        local memberCount = message:PopUInt16()     --牌局数量
        for i = 1, memberCount do
            local tData = {}
            tData.RoomID = message:PopUInt32()      --房间ID
            tData.RoomType = message:PopByte()      --房间大类型
            tData.SubType = message:PopByte()       --房间模式 (各类房间子类型)
            tData.Bet = message:PopInt64()          --房间底注
            tData.BetEnter = message:PopInt64()     --房间入场金币
            tData.BetLeave = message:PopInt64()     --房间立场金币
            tData.OnlineNO = message:PopByte()      --房间在线人数
            tData.OnlineMax = message:PopByte()     --房间最大人数
            tData.OwnerID = message:PopUInt32()     --房主ID
            tData.HeadIcon = message:PopByte()      --房主头像ID
            tData.SystemCost = message:PopUInt32()  --系统手续费比例
            tData.GuanZhuRoom = message:PopByte()   --是否馆主(0:普通局 1:馆主局)
            tData.OwnerCost = message:PopUInt32()   --馆主抽取比例
            tData.CreateTime = message:PopUInt32()  --茶馆创建时间

            table.insert(TeaHouseMgr.RoomNodes, tData)
        end
        if #TeaHouseMgr.RoomNodes then
            table.sort(TeaHouseMgr.RoomNodes, _CompTeaRoom)    
        end
        
        CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaRoomEvent, nil)
    else
        CS.BubblePrompt.Show(data.GetString('T_232_' .. result), "TeaHouseUI")
    end
end

function NetMsgHandler.Received_S_TEA_QUIT_MEMBER(message)
    local memberid = message:PopUInt32()        --退出者账号
    local memberName = message:PopString()      --退出者名称
    CS.BubblePrompt.Show(data.GetString('T_233_Tips' .. memberName), "TeaHouseUI")
    CS.EventDispatcher.Instance:TriggerEvent(EventDefine.NotifyTeaMemberQuitEvent, memberid)
end
