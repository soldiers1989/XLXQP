local  MyTransform=nil

local mMemberNodes = {}                 -- 直属会员节点

local mMemberPageText = nil             -- 成员页
local mZSMemberText1 = nil              -- 直属会员新增-周
local mZSMemberText2 = nil              -- 直属会员新增-月
local mQTMemberText1 = nil              -- 其他会员新增-周
local mQTMemberText2 = nil              -- 其他会员新增-月
local Prompt = nil

-- 刷新基础数据
function RefreshBaseData()
    mZSMemberText1.text = tostring(GameData.AgencyInfo.ZSWeekMember)
    mZSMemberText2.text = tostring(GameData.AgencyInfo.ZSMonthMember)
    mQTMemberText1.text = tostring(GameData.AgencyInfo.QTWeekMember)
    mQTMemberText2.text = tostring(GameData.AgencyInfo.QTMonthMember)
end

--需要用到的数据 当前页 总页数 一页最大数 总条数 好多页
local mPageCurrent = 1
local mPageMax = 1
local mOnePageNumber = 15
local mTotalNumber = 0

--刷新提取页面的数据
function PagesShow()
    mMemberPageText.text = mPageCurrent .. "/" .. mPageMax
end

function On_NotifyAgencyMemberEvent()

    local tMemberCount = #GameData.AgencyInfo.ZSMemberDetails
    mPageMax = math.ceil( tMemberCount / mOnePageNumber )
    if mPageMax < 1 then
        mPageMax = 1
    end
    mPageCurrent = 1

    RefreshMemberData()
end

-- 刷新会员列表信息
function RefreshMemberData()
    local tPageData = GetCurrentPageData()
    local tCount = #tPageData
    if tCount == 0 then
        GameObjectSetActive(Prompt,true)
    else
        GameObjectSetActive(Prompt,false)
    end
    for i = 1, mOnePageNumber do
        if i <= tCount then
            GameObjectSetActive(mMemberNodes[i].RootGameObject, true)
            mMemberNodes[i].NameText.text = tPageData[i].Name
            mMemberNodes[i].RichText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(tPageData[i].TotalCommission))
            mMemberNodes[i].TimeText.text = OfflineDescribe(tPageData[i].LoginTime)
        else
            GameObjectSetActive(mMemberNodes[i].RootGameObject, false)
        end
    end
    PagesShow()
end

function OfflineDescribe(nTime)
    local offlineTime = GameData.AgencyInfo.ServerTime - nTime
    local strDesc = "离线"
    local oneDay = 86400
    if offlineTime < oneDay then
        local hour = math.ceil(offlineTime / 3600)
        if hour >= 24 then
            hour = 23
        end
        strDesc = string.format( "%d小时前", hour )
    elseif offlineTime < oneDay * 3 then
        strDesc = "一天前"
    elseif offlineTime < oneDay * 7 then
        strDesc = "三天前"
    elseif offlineTime < oneDay * 30 then
        strDesc = "七天前"
    elseif offlineTime < oneDay * 60 then
        strDesc = "一月前"
    else
        strDesc = "长期离线"
    end
    return strDesc 
end

--==============================--
--desc:获取当前页数据
--@return 
--==============================--
function GetCurrentPageData()
    local tDataCount = #GameData.AgencyInfo.ZSMemberDetails
    local currentPage = { }

    if mPageCurrent > mPageMax then
        mPageCurrent = mPageMax
    end

    local beginIndex =(mPageCurrent - 1) * mOnePageNumber + 1
    local endIndex = mPageCurrent * mOnePageNumber

    for index = beginIndex, endIndex, 1 do
        if index <= tDataCount then
            table.insert(currentPage, GameData.AgencyInfo.ZSMemberDetails[index])
        end
    end
    return currentPage
end

--返回到主界面
function ReturnButtonOnClick()
    CS.WindowManager.Instance:CloseWindow('AgencyMemberUI', false)
end

--向左边翻页
function LeftArrowOnClick()
    local tPage = mPageCurrent
    tPage = tPage -1
    if tPage <= 1 then
        tPage = 1
    end
    if tPage ~= mPageCurrent then
        mPageCurrent = tPage
        RefreshMemberData()
    end
end

--向右边翻页
function RightArrowOnClick()
    local tPage = mPageCurrent
    tPage = tPage + 1
    if tPage >= mPageMax then
        tPage = mPageMax
    end
    if tPage ~= mPageCurrent then
        mPageCurrent = tPage
        RefreshMemberData()
    end
end

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    MyTransform = this.transform
    -- 成员列表
    local tMemberRoot = MyTransform:Find("Canvas/Window/ScrollView/Viewport/Content")
    for i = 1, 15 do
        local tItem  = tMemberRoot:Find("MemberItem"..i)
        local tData = {}
        tData.RootGameObject = tItem.gameObject
        tData.NameText = tItem:Find("NameText"):GetComponent("Text")
        tData.RichText = tItem:Find("RichText"):GetComponent("Text")
        tData.TimeText = tItem:Find("TimeText"):GetComponent("Text")
        mMemberNodes[i] = tData
        tItem.gameObject:SetActive(false)
    end

    mMemberPageText = MyTransform:Find('Canvas/Window/ScrollView/PageText'):GetComponent("Text")
    mZSMemberText1 = MyTransform:Find('Canvas/Window/Botttoms/Botttom1/NumText'):GetComponent("Text")
    mZSMemberText2 = MyTransform:Find('Canvas/Window/Botttoms/Botttom2/NumText'):GetComponent("Text")
    mQTMemberText1 = MyTransform:Find('Canvas/Window/Botttoms/Botttom3/NumText'):GetComponent("Text")
    mQTMemberText2 = MyTransform:Find('Canvas/Window/Botttoms/Botttom4/NumText'):GetComponent("Text")
    Prompt = MyTransform:Find('Canvas/Window/Prompt').gameObject

    MyTransform:Find('Canvas/Window/Title/ReturnButton'):GetComponent("Button").onClick:AddListener(ReturnButtonOnClick)
    MyTransform:Find('Canvas/Window/ScrollView/LeftBtn'):GetComponent("Button").onClick:AddListener(LeftArrowOnClick)
    MyTransform:Find('Canvas/Window/ScrollView/RightBtn'):GetComponent("Button").onClick:AddListener(RightArrowOnClick)

    RefreshBaseData()
    PagesShow()
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyAgencyMemberEvent, On_NotifyAgencyMemberEvent)
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyAgencyMemberEvent, On_NotifyAgencyMemberEvent)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    NetMsgHandler.Send_CS_MemberDetails()
end