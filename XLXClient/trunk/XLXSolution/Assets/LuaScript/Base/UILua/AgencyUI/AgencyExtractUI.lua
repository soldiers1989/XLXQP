local  MyTransform=nil

local mContentTransform = nil
local mRankItem = nil
local Prompt = nil

-- 返回按钮call
function ReturnButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('AgencyExtractUI', false)
end

-- 提取详情记录
function On_NotifyAgencyExtractEvent()
    lua_Transform_ClearChildren(mContentTransform, true)
    local tDataTables = GameData.AgencyInfo.ExtractData
    if tDataTables ~= nil then
        local newRankItem = nil
        if #tDataTables == 0 then
            GameObjectSetActive(Prompt,true)
        else
            GameObjectSetActive(Prompt,false)
        end
        for key, rankInfo in ipairs(tDataTables) do
            newRankItem = CS.UnityEngine.Object.Instantiate(mRankItem)
            CS.Utility.ReSetTransform(newRankItem, mContentTransform)
            newRankItem.gameObject:SetActive(true)
            newRankItem:Find("TimeValue"):GetComponent("Text").text = rankInfo.Time 
            newRankItem:Find("RichValue"):GetComponent("Text").text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(rankInfo.Money))
        end
    end
end

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    MyTransform = this.transform
    --找到 提取详情 界面的Button组件
    MyTransform:Find('Canvas/Window/Title/ReturnButton'):GetComponent("Button").onClick:AddListener(ReturnButtonOnClick)
    mContentTransform = MyTransform:Find("Canvas/Window/ScrollView/Viewport/Content")
    mRankItem = MyTransform:Find("Canvas/Window/ScrollView/Viewport/Content/RankItem")
    Prompt = MyTransform:Find('Canvas/Window/Prompt').gameObject
    GameObjectSetActive(mRankItem.gameObject, false)
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAgencyExtractEvent, On_NotifyAgencyExtractEvent)
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAgencyExtractEvent, On_NotifyAgencyExtractEvent)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    NetMsgHandler.Send_CS_Agency_Extract_Data()
end
