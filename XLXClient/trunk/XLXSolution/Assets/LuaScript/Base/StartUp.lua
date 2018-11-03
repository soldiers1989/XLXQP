StartUp = {}

require 'Base/DataManagers/CustomList'
require 'Base/LuaUtility'
require 'Base/EnumDefine'
require 'Base/EventDefine'
require 'Base/GameConfig'
require 'Base/GameData'
require 'Base/DataManagers/EmailMgr'
require 'Base/DataManagers/MusicMgr'
require 'Base/DataManagers/PlatformBridge'
require 'Base/DataManagers/LoginMgr'

require 'Base/Network/HubServerClient'
require 'Base/Network/NetMsgHandler'

require 'Subsets/CLNN/NNGameMgr.lua'
require 'Subsets/CLNN/NNRoom.lua'
require 'Subsets/CLJH/JHGameMgr.lua'
require 'Subsets/CLJH/JHZuJuRoom.lua'

require 'Subsets/CLTTZ/TTZGameMgr.lua'
require 'Subsets/CLTTZ/TTZRoom.lua'

require 'Subsets/CLMJ/MJGameMgr.lua'
require 'Subsets/CLMJ/MJRoom.lua'

require 'Base/UILua/HBJL/HBGameMgr.lua'
require 'Base/LBS/LBSMgr.lua'

require 'Base/TeaHouse/TeaHouseMgr.lua'

require 'Subsets/CLPDK/PDKGameMgr.lua'
require 'Subsets/CLPDK/PDKRoom.lua'

require "Subsets/LHD/LHDGameMgr.lua"
require "Subsets/LHD/LHDRoom.lua"

require "Subsets/BJL/BJLGameMgr.lua"
require "Subsets/BJL/BJLRoom.lua"

--VSCode lua 调试代码
if GameConfig.IsDebug == true then
    -- body
    --local breakSocketHandle, debugXpCall = require("LuaDebugjit")("localhost", 7003)
end


--主入口函数。从这里开始lua逻辑
function StartUp.Main()
    -- 初始化游戏配置脚本
    GameConfig.Init()
    -- 初始化游戏数据
    GameData.Init()
    -- 初始化网络处理
    NetMsgHandler.Init()
    -- 初始化音乐管理器
    MusicMgr:Init()
    -- 初始化平台连接桥
    PlatformBridge:Init()
    -- 初始化登录管理器
    LoginMgr:Init()
    -- 开始IP检查
    GameConfig.ReqIPAddress()
    -- 预加载
    StartUp.PreOpenHallUI()

    StartUp.PreloadJPushUI()

    -- 打开登陆界面
    local loginUI = "WXLogin"
    local openparam = CS.WindowNodeInitParam(loginUI)
    openparam.NodeType = 0
    openparam.LoadComplatedCallBack =
    function(windowNode)
        CS.LoadingUI.Hide()
    end
    CS.WindowManager.Instance:OpenWindow(openparam)

    -- 切换状态为登陆
    GameData.GameState = GAME_STATE.LOGIN
    -- 跑马灯速度调整
    CS.MoveNotice.MoveSpeed = 150
    CS.JPushManager.SetDebug(false)
    -- local JPushID = CS.JPushManager.GetRegistrationId()
    -- print("*****JPush RegistrationID:", JPushID )
end

function StartUp.PreOpenHallUI()
    -- 预加载时 刷新数据不设置 默认为nil 便于后续操作
    local openparam = CS.WindowNodeInitParam("HallUI", true)
    openparam.NodeType = 0
    CS.WindowManager.Instance:OpenWindow(openparam)
end

function StartUp.PreloadJPushUI()
    local jpushNode = CS.WindowManager.Instance:FindWindowNodeByName("JPushUI")
    if jpushNode ~= nil then
        jpushNode.WindowGameObject:SetActive(true)
    else
        local openparam = CS.WindowNodeInitParam("JPushUI", false)
        openparam.NodeType = 0
        CS.WindowManager.Instance:OpenWindow(openparam)
    end
end

function StartUp.Shutdown()
    MusicMgr:Destory()
end 