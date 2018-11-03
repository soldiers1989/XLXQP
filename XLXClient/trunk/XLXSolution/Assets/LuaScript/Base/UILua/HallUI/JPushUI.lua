
local mCurrentAlias = ""            -- 当前别名
local mIsReturn = true              -- 是否已经返回结果


function Awake()
    for i = 1, 15 do
        this.transform:Find("Canvas/Button".. i):GetComponent("Button").onClick:AddListener(function() OnButtonClick(i) end)
    end
    this.transform:Find("Canvas/ButtonClose"):GetComponent("Button").onClick:AddListener(OnCloseBtnClick)
    this.transform:Find("Canvas/ContentOK2/ButtonSave"):GetComponent("Button").onClick:AddListener(OnSave)
end

function Start()
    
end

function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener('JPushReceiveMessageEvent', On_JPushReceiveMessageEvent)
    CS.EventDispatcher.Instance:AddEventListener('JPushReceiveNotificationEvent', On_JPushReceiveNotificationEvent)
    CS.EventDispatcher.Instance:AddEventListener('JPushOpenNotificationEvent', On_JPushOpenNotificationEvent)
    CS.EventDispatcher.Instance:AddEventListener('JPushTagOperateResultEvent', On_JPushTagOperateResultEvent)
    CS.EventDispatcher.Instance:AddEventListener('JPushAliasOperateResultEvent', On_JPushAliasOperateResultEvent)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyLoginSuccessEvent, On_NotifyLoginSuccessEvent)

end

function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener('JPushReceiveMessageEvent', On_JPushReceiveMessageEvent)
    CS.EventDispatcher.Instance:RemoveEventListener('JPushReceiveNotificationEvent', On_JPushReceiveNotificationEvent)
    CS.EventDispatcher.Instance:RemoveEventListener('JPushOpenNotificationEvent', On_JPushOpenNotificationEvent)
    CS.EventDispatcher.Instance:RemoveEventListener('JPushTagOperateResultEvent', On_JPushTagOperateResultEvent)
    CS.EventDispatcher.Instance:RemoveEventListener('JPushAliasOperateResultEvent', On_JPushAliasOperateResultEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyLoginSuccessEvent, On_NotifyLoginSuccessEvent)

end

function OnCloseBtnClick()
    CS.WindowManager.Instance:CloseWindow('JPushUI', false)
end

function OnButtonClick(index)
    print("=====Click Index:", index)
    if index == 1 then
        CS.JPushManager.SetTags(10, {'111'}) 
    elseif index == 2 then
        CS.JPushManager.AddTags(20, {'333', '444'}) 
    elseif index == 3 then
        CS.JPushManager.DeleteTags(30, {'333', '555'}) 
    elseif index == 4 then
        CS.JPushManager.CleanTags(40) 
    elseif index == 5 then
        CS.JPushManager.GetAllTags(50) 
    elseif index == 6 then
        CS.JPushManager.CheckTagBindState(60, '333') 
    elseif index == 7 then
        CS.JPushManager.SetAlias(70, 'Online') 
    elseif index == 8 then
        CS.JPushManager.DeleteAlias(80) 
    elseif index == 9 then
        CS.JPushManager.GetAlias(90) 
    elseif index == 10 then
        CS.JPushManager.SetBadge(100)
    elseif index == 11 then
        local count = CS.JPushManager.GetApplicationIconBadgeNumber()
        print("=====IOS Badge:", count)
        CS.JPushManager.SetApplicationIconBadgeNumber(110)
    elseif index == 12 then
        local count = CS.JPushManager.GetApplicationIconBadgeNumber()
        print("=====IOS Badge:", count)
        CS.JPushManager.SetApplicationIconBadgeNumber(0)
    elseif index == 13 then

    elseif index == 14 then
        
    elseif index == 15 then

    end
end

function On_JPushReceiveMessageEvent(jsonStr)
    print("===111==:", jsonStr)
end

function On_JPushReceiveNotificationEvent(jsonStr)
    print("===222==:", jsonStr)
    
end

-- 点开推送消息
function On_JPushOpenNotificationEvent(jsonStr)
    CS.JPushManager.SetBadge(0)
    CS.JPushManager.SetApplicationIconBadgeNumber(0)
    print("===333==:", jsonStr)
end

function On_JPushTagOperateResultEvent(jsonStr)
    mIsReturn = true
    print("===444==:", jsonStr)

    local tJsonData = CS.LuaAsynFuncMgr.Instance:ParseJsonToLuaTable(jsonStr)
    print("=====sequence 1:", tJsonData)
    print("=====sequence 1:", tJsonData['sequence'])
    print("=====code     1:", tJsonData['code'])
    if tJsonData['tag'] ~= nil then
        print("=====tag      1:", tJsonData['tag'])
        print("=====tag      1:", tJsonData['tag'].Count)
        if tJsonData['tag'].Count ~= nil then
            -- 有很多tag
            for i = 0, tJsonData['tag'].Count - 1 do
                print("=====tag      1:", tJsonData['tag'][i])
            end
        else
            -- 只有一个tag
        end
        
    end
end

function On_JPushAliasOperateResultEvent(jsonStr)
    mIsReturn = true
    print("===555==:", jsonStr)
    local tJsonData = CS.LuaAsynFuncMgr.Instance:ParseJsonToLuaTable(jsonStr)
    local tSequence = tJsonData['sequence']
    local tCode = tJsonData['code']
    print("=====sequence 2:", tSequence)
    print("=====code 2:", tCode)
    print("=====alias 2:", tJsonData['alias'])
    if tSequence == '9999' then
        if tCode == '0' then
            mCurrentAlias = tJsonData['alias']
            print("别名设置成功:", mCurrentAlias)
        else
            -- 别名设置错误
            print("别名设置错误,请重试...", tCode)
        end
    end
end


-- 登陆成功消息
function On_NotifyLoginSuccessEvent()
    local tAccountid =  tostring( GameData.RoleInfo.AccountID )
    if mCurrentAlias ~= tAccountid then
        if mIsReturn then
            mIsReturn = false
            CS.JPushManager.SetAlias(9999, tAccountid)
        end
    end
    --QRCOde()
end

local mQRCodeRawImage = nil         -- 二维码Image

function QRCOde()
    mQRCodeRawImage = this.transform:Find("Canvas/ContentOK2/QRCode/Icon"):GetComponent("RawImage")
    local url = string.format("%s?GameID=%d&referralsID=%d&sid=%d&referralsChannel=%d", GameConfig.InviteUrl, CS.AppDefine.GameID, 0, 0, GameData.ChannelCode)
    CS.Utility.CreateBarcode(mQRCodeRawImage, url, 256, 256)
end

function OnSave()
    this:DelayInvoke(0.6 , function()
        CS.BubblePrompt.Show("个人二维码已保存至系统相册！", "QRCCodeUI")
    end)
    CS.Utility.SaveImg()
end
