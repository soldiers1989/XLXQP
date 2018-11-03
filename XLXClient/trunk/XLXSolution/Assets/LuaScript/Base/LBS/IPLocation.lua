--[[
   文件名称:IPLocation.lua
   创 建 人: 
   创建时间：2017.12
   功能描述：
]]--

local mAccount = ""
local mLoginIP = ""
local mIsRobot = false
local mIPLocationText = nil
local misInit = false
local misUpdate = false

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    mIPLocationText = this.transform:GetComponent("Text")
    misInit = true
   if misUpdate then
        SetIPLocation() 
   end
end

function UpdateIPLocation(accountParam, loginIPParam, isRobotParam)
    mAccount = accountParam
    mLoginIP = loginIPParam
    mIsRobot = isRobotParam
    misUpdate = true
    if misInit then
        SetIPLocation()    
    end
end

-- 设置IP地理位置信息
function SetIPLocation()
    if mIsRobot == true then
        mIPLocationText.text = mLoginIP
    else
        GetMoblieIPLocation()
    end
end

-- IP地址查询
function  GetMoblieIPLocation()
    local IPURL = GameConfig.MobileIPLocationUrl
    local paramTable = {}
    paramTable['accountid'] = mAccount
    paramTable['ip'] = mLoginIP
	CS.LuaAsynFuncMgr.Instance:HttpPost(IPURL, paramTable, CallMobileIPLocation)
end

function CallMobileIPLocation(paramResult)
    print("IP Location===== 1:", paramResult)
    if nil == paramResult then
        mIPLocationText.text = "未知区域"
		return
    end
    local index1 = string.find(paramResult, 'ipinfo=')
    if index1 == 0 or index1 == nil  then
        mIPLocationText.text = "未知区域."
    else
        -- IP信息：1:code 2:account 3:ip 4:country 5:region(省) 6:city(市) 7:county(郡县) 8:country_id
        -- {"code":0,"data":{"ip":"62.164.192.0","country":"英国","region":"XX","city":"XX","county":"XX","country_id":"GB"}}
        -- 0,99887765412,110.165.63.255,    香港,香港,XX,XX,HK
        -- 0,99887765412,052.000.000.000,   美国,弗吉尼亚,阿什本,XX,US
        -- 0,99887765412,38.31.145.0,       美国,XX,XX,XX,US
        -- 0,99887765412,43.229.0.1,        印度,古吉拉特,XX,XX,IN
        -- 0,99887765412,219.144.25.5,      中国,陕西,延安,XX,CN
        -- 0,99887765412,212.63.191.40,     德国,XX,XX,XX,DE
        -- 0,99887765412,130.153.0.0,       日本,XX,XX,XX,JP
        -- 0,99887765412,203.79.132.0,      台湾,台湾,XX,XX,TW
        -- 0,99887765412,192.168.0.1,       XX,XX,内网IP,内网IP,xx
        local ipinfo = string.sub(paramResult, index1+7)
        local tLocation = lua_string_split(ipinfo,',')
        if #tLocation ~= 8 then
            mIPLocationText.text = "未知区域.."
        else
            
            if tLocation[4] == "xx" or tLocation[4] == "XX" then
                mIPLocationText.text = "未知区域..."
            elseif tLocation[5] == "xx" or tLocation[5] == "XX" then
                mIPLocationText.text = tLocation[4]
            elseif tLocation[6] == "xx" or tLocation[6] == "XX" then
                mIPLocationText.text = tLocation[4]..tLocation[5]
                mIPLocationText.text = string.format( "%s.%s",  tLocation[4], tLocation[5])
            elseif tLocation[7] == "xx" or tLocation[7] == "XX" then
                mIPLocationText.text = string.format( "%s.%s",  tLocation[5], tLocation[6])
            else
                mIPLocationText.text = tLocation[4]
            end
        end
    end
end