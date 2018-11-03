-- 是否初始化
local isInited = false
-- 关联的房间ID和统计信息
local m_RelativeRoomID = 0

-- 左侧统计数据
local m_L_OffsetY = 6
local m_L_OffsetX = 16
local m_L_DisplayColumnCount = 8
local m_L_ItemCount = 0
local m_L_ItemSize = 0                      -- 单个Node大小
local m_LastHandleRound_L = 0               -- 上次处理到的回合数
local m_L_StatisticsRoot = nil              -- Node父节点
local m_L_RoundItems = {}                   -- Node缓存节点

-- 右侧统计数据
local m_R_LastPos = 0
local m_R_LastUpdateValue = 0
local m_R_OffsetY = 6
local m_R_OffsetX = 80
local m_R_DisplayColumnCount = 24           -- 全屏一页显示列数
local m_R_CurrentMaxDisplayPos = 19         -- 当前需要显示的最大pos参数
local m_R_ItemCount = 0                     -- Node总数量
local m_R_ItemSize = 0                      -- 单个Node大小
local m_LastHandleRound_R = 0               -- 上次处理到的回合数
local m_R_StatisticsRoot = nil              -- Node父节点
local m_R_RoundItems = {}                   -- Node缓存节点
local m_R_TrendTable = {}                   -- trend缓存
local m_R_IsDeflected = false

-- 右侧大眼仔路
local m_R1_LastPos = 0
local m_R1_LastUpdateValue = 0
local m_R1_OffsetY = 3
local m_R1_OffsetX = 40
local m_R1_DisplayColumnCount = 12           -- 全屏一页显示列数
local m_R1_CurrentMaxDisplayPos = 12         -- 当前需要显示的最大pos参数
local m_R1_ItemCount = 0                     -- Node总数量
local m_R1_ItemSize = 0                      -- 单个Node大小
local m_LastHandleRound_R1 = 0               -- 上次处理到的回合数
local m_R1_StatisticsRoot = nil              -- Node父节点
local m_R1_RoundItems = {}                   -- Node缓存 120个节点
local m_R1_RealItems = {}                    -- Node缓存 480个节点
local m_R1_TrendTable = {}                   -- trend缓存
local m_R1_IsDeflected = false               -- 是否转向

-- 右侧小眼路单
local m_R2_LastPos = 0
local m_R2_LastUpdateValue = 0
local m_R2_OffsetY = 3
local m_R2_OffsetX = 40
local m_R2_DisplayColumnCount = 12           -- 全屏一页显示列数
local m_R2_CurrentMaxDisplayPos = 12         -- 当前需要显示的最大pos参数
local m_R2_ItemCount = 0                     -- Node总数量
local m_R2_ItemSize = 0                      -- 单个Node大小
local m_LastHandleRound_R2 = 0               -- 上次处理到的回合数
local m_R2_StatisticsRoot = nil              -- Node父节点
local m_R2_RoundItems = {}                   -- Node缓存 120个节点
local m_R2_RealItems = {}                    -- Node缓存 480个节点
local m_R2_TrendTable = {}                   -- trend缓存
local m_R2_IsDeflected = false               -- 是否转向

-- 右侧甲虫路单
local m_R3_LastPos = 0
local m_R3_LastUpdateValue = 0
local m_R3_OffsetY = 3
local m_R3_OffsetX = 40
local m_R3_DisplayColumnCount = 12           -- 全屏一页显示列数
local m_R3_CurrentMaxDisplayPos = 12         -- 当前需要显示的最大pos参数
local m_R3_ItemCount = 0                     -- Node总数量
local m_R3_ItemSize = 0                      -- 单个Node大小
local m_LastHandleRound_R3 = 0               -- 上次处理到的回合数
local m_R3_StatisticsRoot = nil              -- Node父节点
local m_R3_RoundItems = {}                   -- Node缓存 120个节点
local m_R3_RealItems = {}                    -- Node缓存 480个节点
local m_R3_TrendTable = {}                   -- trend缓存
local m_R3_IsDeflected = false               -- 是否转向

-- 滑动区域脚本
local m_L_ScrollRect = nil
local m_R_ScrollRect = nil
local m_R1_ScrollRect = nil
local m_R2_ScrollRect = nil
local m_R3_ScrollRect = nil

local mTime = CS.UnityEngine.Time


function Awake()
    m_L_ItemCount = m_L_OffsetX * m_L_OffsetY
    m_R_ItemCount = m_R_OffsetX * m_R_OffsetY
    m_R1_ItemCount = m_R1_OffsetX * m_R1_OffsetY
    m_R2_ItemCount = m_R2_OffsetX * m_R2_OffsetY
    m_R3_ItemCount = m_R3_OffsetX * m_R3_OffsetY
    
    m_L_ScrollRect = this.transform:Find('StatisticsLeft'):GetComponent("ScrollRect")
    m_R_ScrollRect = this.transform:Find('StatisticsRight'):GetComponent("ScrollRect")
    m_R1_ScrollRect = this.transform:Find('StatisticsRight1'):GetComponent("ScrollRect")
    m_R2_ScrollRect = this.transform:Find('StatisticsRight2'):GetComponent("ScrollRect")
    m_R3_ScrollRect = this.transform:Find('StatisticsRight3'):GetComponent("ScrollRect")

    m_L_StatisticsRoot = this.transform:Find('StatisticsLeft/Viewport/Content')
    m_R_StatisticsRoot = this.transform:Find('StatisticsRight/Viewport/Content')
    local leftGridLayoutGroup = m_L_StatisticsRoot:GetComponent("GridLayoutGroup")
    m_L_ItemSize = leftGridLayoutGroup.cellSize.x + leftGridLayoutGroup.spacing.x
    local rightGridLayoutGroup = m_R_StatisticsRoot:GetComponent("GridLayoutGroup")
    m_R_ItemSize = rightGridLayoutGroup.cellSize.x + rightGridLayoutGroup.spacing.x
    
    CreateStatisticsTrendItems(m_L_StatisticsRoot, m_L_ItemCount, m_L_OffsetY * m_L_DisplayColumnCount, 1)
    CreateStatisticsTrendItems(m_R_StatisticsRoot, m_R_ItemCount, m_R_OffsetY * m_R_DisplayColumnCount, 2)

    m_R1_StatisticsRoot = this.transform:Find('StatisticsRight1/Viewport/Content')
    m_R2_StatisticsRoot = this.transform:Find('StatisticsRight2/Viewport/Content')
    m_R3_StatisticsRoot = this.transform:Find('StatisticsRight3/Viewport/Content')
    local tGridLayoutGroup = m_R1_StatisticsRoot:GetComponent("GridLayoutGroup")
    m_R1_ItemSize = tGridLayoutGroup.cellSize.x + tGridLayoutGroup.spacing.x
    tGridLayoutGroup = m_R2_StatisticsRoot:GetComponent("GridLayoutGroup")
    m_R2_ItemSize = tGridLayoutGroup.cellSize.x + tGridLayoutGroup.spacing.x
    tGridLayoutGroup = m_R3_StatisticsRoot:GetComponent("GridLayoutGroup")
    m_R3_ItemSize = tGridLayoutGroup.cellSize.x + tGridLayoutGroup.spacing.x
    
    CreateStatisticsRightTrendItems(m_R1_StatisticsRoot, m_R1_ItemCount, m_R1_OffsetY * m_R1_DisplayColumnCount, 1)
    CreateStatisticsRightTrendItems(m_R2_StatisticsRoot, m_R2_ItemCount, m_R2_OffsetY * m_R2_DisplayColumnCount, 2)
    CreateStatisticsRightTrendItems(m_R3_StatisticsRoot, m_R3_ItemCount, m_R3_OffsetY * m_R3_DisplayColumnCount, 3)

    InitPrediction()

    isInited = true
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateStatistics, HandleUpdateStatisticsInfo)
    ResetRelativeRoomID(m_RelativeRoomID)
end

function Update()
    UpdatePredictionTrendCD(mTime.deltaTime)
end

function OnDestroy()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.UpdateStatistics, HandleUpdateStatisticsInfo)
end

-- 重置关联的房间ID
function ResetRelativeRoomID(roomID)
    m_RelativeRoomID = roomID
    if not isInited then
        return
    end
    local statistics = GameData.RoomInfo.StatisticsInfo[roomID]
    if statistics ~= nil then
        ResetStatisticsInfo(statistics)
    end
    RefreshPreZXBtnState()
end

-- 处理更新统计信息
function HandleUpdateStatisticsInfo(eventArgs)
    local updateRoomID = eventArgs.RoomID
    -- 不是关联的房间ID
    if updateRoomID ~= m_RelativeRoomID then
        return
    end
    local operationType = eventArgs.OperationType
    local statistics = GameData.RoomInfo.StatisticsInfo[updateRoomID]
    if operationType == 1 then
        AppendStatisticsInfo(statistics)
    else
        ResetStatisticsInfo(statistics)
    end

    RefreshPreZXBtnState()
end

-- 创建统计趋势的元素
function CreateStatisticsTrendItems(trendParent, childCount, displayCount, typeParam)
    local roundItem = trendParent:GetChild(0)
    roundItem.gameObject:SetActive(false)
    lua_Transform_ClearChildren(trendParent, true)
    for index = 1, childCount, 1 do
        local instanceItem = CS.UnityEngine.Object.Instantiate(roundItem)
        instanceItem.gameObject.name = 'Item' .. tostring(index)
        CS.Utility.ReSetTransform(instanceItem, trendParent)
        if index > displayCount then
            instanceItem.gameObject:SetActive(false)
        else
            instanceItem.gameObject:SetActive(true)
        end
        local tItemData = {}
        tItemData.RootObject = instanceItem.gameObject
        tItemData.ValueIcon = instanceItem.transform:Find('ValueIcon'):GetComponent("Image")
        tItemData.BaoZi = instanceItem:Find("BaoZi").gameObject
        tItemData.LongJinHua = instanceItem:Find("LongJinHua").gameObject
        tItemData.HuJinHua = instanceItem:Find("HuJinHua").gameObject
        tItemData.HeText = instanceItem:Find("HeText"):GetComponent('Text')
        if typeParam == 1 then
            m_L_RoundItems[index] = tItemData
        else
            m_R_RoundItems[index] = tItemData
        end
    end
end

-- 创建右侧3个小路单元素
function CreateStatisticsRightTrendItems(trendParent, childCount, displayCount, typeParam)
    local tmpRoundItems = nil
    if typeParam == 1 then
        tmpRoundItems = m_R1_RoundItems
    elseif typeParam == 2 then
        tmpRoundItems = m_R2_RoundItems
    else
        tmpRoundItems = m_R3_RoundItems
    end

    local roundItem = trendParent:GetChild(0)
    roundItem.gameObject:SetActive(false)
    -- 屏幕元素
    for index = 1, 36, 1 do
        local instanceItem = trendParent:GetChild(index)
        instanceItem.gameObject.name = 'Item' .. tostring(index)
        if index > displayCount then
            instanceItem.gameObject:SetActive(false)
        else
            instanceItem.gameObject:SetActive(true)
        end
        local tItemData = {}
        tItemData.RootObject = instanceItem.gameObject
        tItemData.Values = {}
        for i = 1, 4 do
            tItemData.Values[i] = {}
            tItemData.Values[i].RootObject = instanceItem.transform:Find('Value'.. i).gameObject
            tItemData.Values[i].RootObject:SetActive(true)
            tItemData.Values[i].Value1 = instanceItem.transform:Find('Value'.. i..'/Image1').gameObject
            tItemData.Values[i].Value2 = instanceItem.transform:Find('Value'.. i..'/Image2').gameObject
            tItemData.Values[i].Value1:SetActive(false)
            tItemData.Values[i].Value2:SetActive(false)
        end
        tmpRoundItems[index] = tItemData
    end
    -- 超出屏幕元素
    for index = 37, childCount, 1 do
        local instanceItem = CS.UnityEngine.Object.Instantiate(roundItem)
        instanceItem.gameObject.name = 'Item' .. tostring(index)
        CS.Utility.ReSetTransform(instanceItem, trendParent)
        if index > displayCount then
            instanceItem.gameObject:SetActive(false)
        else
            instanceItem.gameObject:SetActive(true)
        end
        local tItemData = {}
        tItemData.RootObject = instanceItem.gameObject
        tItemData.Values = {}
        for i = 1, 4 do
            tItemData.Values[i] = {}
            tItemData.Values[i].RootObject = instanceItem.transform:Find('Value'.. i).gameObject
            tItemData.Values[i].RootObject:SetActive(true)
            tItemData.Values[i].Value1 = instanceItem.transform:Find('Value'.. i..'/Image1').gameObject
            tItemData.Values[i].Value2 = instanceItem.transform:Find('Value'.. i..'/Image2').gameObject
            tItemData.Values[i].Value1:SetActive(false)
            tItemData.Values[i].Value2:SetActive(false)
        end
        tmpRoundItems[index] = tItemData
    end

    -- 处理3*40 矩阵详细数据
    -- 3*40 个格子 每个格子4个数据 3*40*4 = 480个格子
    local tmpItems = {}
    if typeParam == 1 then
        tmpItems = m_R1_RealItems
    elseif typeParam == 2 then
        tmpItems = m_R2_RealItems
    else
        tmpItems = m_R3_RealItems
    end

    for i = 1, 40, 1 do
        local tmpData = {}
        tmpData[1] = tmpRoundItems[i * 3 - 2]
        tmpData[2] = tmpRoundItems[i * 3 - 1]
        tmpData[3] = tmpRoundItems[i * 3 - 0]
        for pos = 1, 3 do
            -- 每一大列==>2小列 index 需要冯2进1
            local index = ((i*2 - 1) - 1)*3 + pos
            local pos1, pos2, pos3, pos4
            pos1 = index*2 - 1
            pos2 = (index+3)*2 - 1
            pos3 = index*2
            pos4 = (index+3)*2
            
            tmpItems[pos1] = tmpData[pos].Values[1]
            tmpItems[pos2] = tmpData[pos].Values[2]
            tmpItems[pos3] = tmpData[pos].Values[3]
            tmpItems[pos4] = tmpData[pos].Values[4]
        end
    end
    -- 将480个元素组成6*80 (6行80列的矩阵)
    -- 实现创建n行m列的矩阵：
    local N = 6
    local M = 80
    local tmpCount = 0
    local tmpMatrix = {}
    for i = 1, M do
        for j = 1,N do
            tmpCount = tmpCount + 1
            if tmpMatrix[j] == nil then
                tmpMatrix[j] = {}
            end
            if tmpMatrix[j][i] == nil then
                tmpMatrix[j][i] = {}
            end
            tmpMatrix[j][i] = {}
            tmpMatrix[j][i] = tmpItems[tmpCount]
        end
    end
    -- Node 重新命名
    for k, v in pairs(tmpMatrix) do
        for k2,v2 in pairs(v) do
            v2.RootObject.name = string.format("[%d,%d]",k,k2)
        end
    end
end


-- 重置统计信息
function ResetStatisticsInfo(statistics)

    m_RelativeRoomID = statistics.RoomID
    m_LastHandleRound_L = #statistics.Trend
    m_LastHandleRound_R = #statistics.Trend_R
    m_LastHandleRound_R1 = #statistics.Trend_BigEye
    m_LastHandleRound_R2 = #statistics.Trend_Small
    m_LastHandleRound_R3 = #statistics.Trend_YueYou
    if isInited == true then
        RefreshStatisticsTrendByStatistics(statistics)
    end
end

-- 追加统计信息
function AppendStatisticsInfo(statistics)
    if statistics.RoomID ~= m_RelativeRoomID then
        ResetStatisticsInfo(statistics)
    else
        local tCurrentRound_L = #statistics.Trend
        local tCurrentRound_R = #statistics.Trend_R
        local tCurrentRound_R1 = #statistics.Trend_BigEye
        local tCurrentRound_R2 = #statistics.Trend_Small
        local tCurrentRound_R3 = #statistics.Trend_YueYou

        if m_LastHandleRound_L < tCurrentRound_L then
            -- 刷新左侧的统计图
            for roundIndex = m_LastHandleRound_L + 1, math.ceil(tCurrentRound_L / m_L_OffsetY) * m_L_OffsetY , 1 do
                local roundItem = m_L_RoundItems[roundIndex]
                SetTrendItemResult(roundItem, statistics.Trend[roundIndex])
            end
            -- 刷新右侧的统计图
            if m_LastHandleRound_R == tCurrentRound_R then
                -- 追加路单可能是和局 需要更新之前路单信息
                UpdateRightStatisticsTrendValue(m_R_LastPos, statistics.Trend_R[m_LastHandleRound_R])
            end
            -- [大路]刷新
            for	roundIndex = m_LastHandleRound_R + 1, tCurrentRound_R, 1 do
                AppendRightStatisticsTrendValue(statistics.Trend_R[roundIndex])
            end
            -- [大眼仔]刷新
            for	roundIndex = m_LastHandleRound_R1 + 1, tCurrentRound_R1, 1 do
                AppendBigEyeTrendValue(statistics.Trend_BigEye[roundIndex])
            end
            -- [小路]刷新
            for	roundIndex = m_LastHandleRound_R2 + 1, tCurrentRound_R2, 1 do
                AppendSmallTrendValue(statistics.Trend_Small[roundIndex])
            end
            -- [曱甴路]刷新
            for	roundIndex = m_LastHandleRound_R3 + 1, tCurrentRound_R3, 1 do
                AppendYueYouTrendValue(statistics.Trend_YueYou[roundIndex])
            end

            ResetStatisticsRootToRightVisible(tCurrentRound_L)
            RefreshStatisticsCountsByStatistics(statistics)
            m_LastHandleRound_L = tCurrentRound_L
            m_LastHandleRound_R = tCurrentRound_R

            m_LastHandleRound_R1 = tCurrentRound_R1
            m_LastHandleRound_R2 = tCurrentRound_R2
            m_LastHandleRound_R3 = tCurrentRound_R3
        else
            ResetStatisticsInfo(statistics)
        end
    end
end

-- 刷新统计趋势图，数量
function RefreshStatisticsTrendByStatistics(statistics)
    RefreshLeftStatisticsTrendByStatistics(statistics)
    RefreshRightStatisticsTrendByStatistics(statistics)
    RefreshBigEyeTrendByStatistics(statistics)
    RefreshSmallTrendByStatistics(statistics)
    RefreshYueYouTrendByStatistics(statistics)
    ResetStatisticsRootToRightVisible(#statistics.Trend)
    RefreshStatisticsCountsByStatistics(statistics)
end

-- 刷新左侧统计趋势图
function RefreshLeftStatisticsTrendByStatistics(statistics)
    local roundCount = #statistics.Trend
    local displayCount = math.ceil(roundCount / m_L_OffsetY) * m_L_OffsetY
    if displayCount < m_L_DisplayColumnCount * m_L_OffsetY then
        displayCount = m_L_DisplayColumnCount * m_L_OffsetY
    end
    for roundIndex = 1, m_L_ItemCount, 1 do
        local roundItem = m_L_RoundItems[roundIndex]
        if roundItem == nil then
            print("BJL=111左侧数据 nil index:", roundIndex)
        else
            if roundIndex > displayCount then
                GameObjectSetActive(roundItem.RootObject, false)
            else
                local roundResult = statistics.Trend[roundIndex]
                SetTrendItemResult(roundItem, roundResult)
            end
        end
    end
end

function SetTrendItemResult(roundItem, roundResult)
    GameObjectSetActive(roundItem.RootObject, true)
    if roundResult ~= nil then
        GameObjectSetActive(roundItem.ValueIcon.gameObject, true)
        local spriteName = GetTrendResultSpriteOfTrendItem(roundResult)
        roundItem.ValueIcon:ResetSpriteByName(spriteName)
        GameObjectSetActive(roundItem.LongJinHua, CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.LONGDUIZI) == BJL_WIN_CODE.LONGDUIZI)
        GameObjectSetActive(roundItem.HuJinHua, CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.HUDUIZI) == BJL_WIN_CODE.HUDUIZI)
    else
        GameObjectSetActive(roundItem.ValueIcon.gameObject, false)
        GameObjectSetActive(roundItem.BaoZi, false)
        GameObjectSetActive(roundItem.LongJinHua, false)
        GameObjectSetActive(roundItem.HuJinHua, false)
        GameObjectSetActive(roundItem.HeText.gameObject, false)
    end
end

-- 刷新右侧统计趋势图
function RefreshRightStatisticsTrendByStatistics(statistics)
    m_R_TrendTable = {}
    m_R_LastPos = 0
    m_R_LastUpdateValue = 0
    m_R_IsDeflected = false
    local initDisplayCount = m_R_DisplayColumnCount * m_R_OffsetY
    m_R_CurrentMaxDisplayPos = initDisplayCount

    for index = 1, m_R_ItemCount, 1 do
        local trendItem = m_R_RoundItems[index]
        if trendItem ~= nil then
            if index > initDisplayCount then
                GameObjectSetActive(trendItem.RootObject, false)
            end
            GameObjectSetActive(trendItem.ValueIcon.gameObject, false)
            GameObjectSetActive(trendItem.BaoZi, false)
            GameObjectSetActive(trendItem.LongJinHua, false)
            GameObjectSetActive(trendItem.HuJinHua, false)
            GameObjectSetActive(trendItem.HeText.gameObject, false)
        else
            print("BJL=222右侧数据 nil index:", index)
        end
    end
    
    for roundIndex = 1, #statistics.Trend_R, 1 do
        AppendRightStatisticsTrendValue(statistics.Trend_R[roundIndex])
    end
end

-- 刷新大路 屏幕显示位置
function ResetStatisticsRootToRightVisible(roundCount)
    ResetScrollRectLVisible(roundCount)
    -- [大路]刷新屏幕位置
    ResetScrollRectVisible2R(m_R_CurrentMaxDisplayPos)
    ResetScrollRectVisible2R1(m_R1_CurrentMaxDisplayPos)
    ResetScrollRectVisible2R2(m_R2_CurrentMaxDisplayPos)
    ResetScrollRectVisible2R3(m_R3_CurrentMaxDisplayPos)
end

-- [左侧]屏显区域刷新
function ResetScrollRectLVisible(countParam)
    m_L_ScrollRect.enabled = false
    local leftDisplayCount = math.max(math.ceil(countParam/ m_L_OffsetY), m_L_DisplayColumnCount)
    local leftPosX = m_L_StatisticsRoot.parent.rect.size.x - leftDisplayCount * m_L_ItemSize
    local leftLocalPos = m_L_StatisticsRoot.localPosition
    leftLocalPos.x = leftPosX
    m_L_StatisticsRoot.localPosition = leftLocalPos
    m_L_ScrollRect.enabled = true
end

-- [大路]屏显区域刷新
function ResetScrollRectVisible2R(countParam)
    local rightDisplayCount = math.max(math.ceil(countParam /  m_R_OffsetY))
    if rightDisplayCount > m_R_DisplayColumnCount then
        m_R_ScrollRect.enabled = false
        local rightPosX = (m_R_StatisticsRoot.parent.rect.size.x - rightDisplayCount * m_R_ItemSize)
        local rightLocalPos = m_R_StatisticsRoot.localPosition
        rightLocalPos.x = rightPosX
        m_R_StatisticsRoot.localPosition = rightLocalPos
        m_R_ScrollRect.enabled = true
    end
end

-- [大眼仔]屏显区域刷新
function ResetScrollRectVisible2R1(countParam)
    local rightDisplayCount = math.max(math.ceil(countParam /  m_R1_OffsetY))
    rightDisplayCount = math.ceil(rightDisplayCount / 4)
    if rightDisplayCount > m_R1_DisplayColumnCount then
        m_R1_ScrollRect.enabled = false
        local rightPosX = (m_R1_StatisticsRoot.parent.rect.size.x - rightDisplayCount * m_R1_ItemSize)
        local rightLocalPos = m_R1_StatisticsRoot.localPosition
        rightLocalPos.x = rightPosX
        m_R1_StatisticsRoot.localPosition = rightLocalPos
        m_R1_ScrollRect.enabled = true
    end
end

-- [小路]屏显区域刷新
function ResetScrollRectVisible2R2(countParam)
    local rightDisplayCount = math.max(math.ceil(countParam /  m_R2_OffsetY))
    rightDisplayCount = math.ceil(rightDisplayCount / 4)
    if rightDisplayCount > m_R2_DisplayColumnCount then
        m_R2_ScrollRect.enabled = false
        local rightPosX = (m_R2_StatisticsRoot.parent.rect.size.x - rightDisplayCount * m_R2_ItemSize)
        local rightLocalPos = m_R2_StatisticsRoot.localPosition
        rightLocalPos.x = rightPosX
        m_R2_StatisticsRoot.localPosition = rightLocalPos
        m_R2_ScrollRect.enabled = true
    end
end

-- [曱甴路]屏显区域刷新
function ResetScrollRectVisible2R3(countParam)
    local rightDisplayCount = math.max(math.ceil(countParam /  m_R3_OffsetY))
    rightDisplayCount = math.ceil(rightDisplayCount / 4)
    if rightDisplayCount > m_R3_DisplayColumnCount then
        m_R3_ScrollRect.enabled = false
        local rightPosX = (m_R3_StatisticsRoot.parent.rect.size.x - rightDisplayCount * m_R3_ItemSize)
        local rightLocalPos = m_R3_StatisticsRoot.localPosition
        rightLocalPos.x = rightPosX
        m_R3_StatisticsRoot.localPosition = rightLocalPos
        m_R3_ScrollRect.enabled = true
    end
end

-- (右侧)追加统计值
function AppendRightStatisticsTrendValue(newValue)
    if m_R_LastPos == 0 then
        m_R_LastPos = 1
        m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
        m_R_LastUpdateValue = GetTrend2UpdateValue(newValue.TrendRValue)
        -- print("=====BJL 路单走势 111-0:", m_R_LastPos, m_R_IsDeflected)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue.TrendRValue, m_R_LastUpdateValue) == m_R_LastUpdateValue then
            if m_R_IsDeflected or m_R_LastPos % m_R_OffsetY == 0 then
                --print("=====BJL 路单走势 111-1:", m_R_LastPos, m_R_IsDeflected)
                m_R_IsDeflected = true
                m_R_LastPos = m_R_LastPos + m_R_OffsetY
                m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
            else
                if m_R_TrendTable[m_R_LastPos + 1] == nil then
                    --print("=====BJL 路单走势 111-2:", m_R_LastPos, m_R_IsDeflected)
                    m_R_LastPos = m_R_LastPos + 1
                    m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
                else
                    --print("=====BJL 路单走势 111-3:", m_R_LastPos, m_R_IsDeflected)
                    m_R_LastPos = m_R_LastPos + m_R_OffsetY
                    m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
                    m_R_IsDeflected = true
                end
            end
        else
            -- print("=====BJL 路单走势 222:", m_R_LastPos, m_R_IsDeflected)
            m_R_IsDeflected = false
            -- 开辟新行
            local columnIndex = math.ceil(m_R_LastPos / m_R_OffsetY) + 1
            for i = columnIndex, 1, -1 do
                if m_R_TrendTable[i * m_R_OffsetY + 1] ~= nil then
                    break
                end
                columnIndex = i
            end
            m_R_LastPos = columnIndex * m_R_OffsetY + 1
            m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
            m_R_LastUpdateValue = GetTrend2UpdateValue(newValue.TrendRValue)
        end
    end
    
    if m_R_LastPos > m_R_DisplayColumnCount * m_R_OffsetY then
        -- 当前位置已经超出一屏显示的位置
        local columnMax = math.ceil(m_R_LastPos / m_R_OffsetY) * m_R_OffsetY
        for index = columnMax - m_R_OffsetY, columnMax, 1 do
            GameObjectSetActive(m_R_RoundItems[index].RootObject, true)
        end
    end
    -- 刷新当前最大的显示位置
    m_R_CurrentMaxDisplayPos = math.max(m_R_CurrentMaxDisplayPos, m_R_LastPos)

    UpdateRightStatisticsTrendValue(m_R_LastPos, newValue)
end

-- 右侧路单信息显示刷新
function UpdateRightStatisticsTrendValue(trendPos, newValue)
    local trendItem = m_R_RoundItems[trendPos]
    if trendItem == nil then
        return
    end
    trendItem.ValueIcon:ResetSpriteByName(GetTrend2IconNameByValue(newValue.TrendRValue))
    GameObjectSetActive(trendItem.ValueIcon.gameObject, true)
    GameObjectSetActive(trendItem.LongJinHua, CS.Utility.GetLogicAndValue(newValue.TrendRValue, BJL_WIN_CODE.LONGDUIZI) == BJL_WIN_CODE.LONGDUIZI)
    GameObjectSetActive(trendItem.HuJinHua, CS.Utility.GetLogicAndValue(newValue.TrendRValue, BJL_WIN_CODE.HUDUIZI) == BJL_WIN_CODE.HUDUIZI)
    local tIsHe = newValue.TrendRHeCount > 0
    GameObjectSetActive(trendItem.HeText.gameObject, tIsHe)
    if tIsHe then
        trendItem.HeText.text = tostring(newValue.TrendRHeCount)
    end
end

-- [大眼仔]刷新趋势图
function RefreshBigEyeTrendByStatistics(statistics)
    m_R1_TrendTable = {}
    m_R1_LastPos = 0
    m_R1_LastUpdateValue = 0
    m_R1_IsDeflected = false
    local initDisplayCount = m_R1_DisplayColumnCount * m_R1_OffsetY
    m_R1_CurrentMaxDisplayPos = initDisplayCount

    for index = 1, m_R1_ItemCount, 1 do
        local trendItem = m_R1_RoundItems[index]
        if trendItem ~= nil then
            -- 超出一屏的元素先隐藏
            if index > initDisplayCount then
                GameObjectSetActive(trendItem.RootObject, false)
            end
            -- 每个格子4个元素隐藏
            for i = 1, 4 do
                GameObjectSetActive(trendItem.Values[i].Value1, false)
                GameObjectSetActive(trendItem.Values[i].Value2, false)
            end
        else
            print("BJL=333大眼仔 nil index:", index)
        end
    end
    for roundIndex = 1, #statistics.Trend_BigEye, 1 do
        AppendBigEyeTrendValue(statistics.Trend_BigEye[roundIndex])
    end
end

-- [大眼仔]路单追加统计
function AppendBigEyeTrendValue(newValue)
    if m_R1_LastPos == 0 then
        m_R1_LastPos = 1
        m_R1_TrendTable[m_R1_LastPos] = newValue
        m_R1_LastUpdateValue = GetTrend2UpdateValue(newValue)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue, m_R1_LastUpdateValue) == m_R1_LastUpdateValue then
            -- 本次结果与上一次结果保持一致
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            if m_R1_IsDeflected or m_R1_LastPos % m_R_OffsetY == 0 then
                -- 需要拐弯L(1 偏转因子 2位置达到底部的位置)
                m_R1_IsDeflected = true
                m_R1_LastPos = m_R1_LastPos + m_R_OffsetY
                m_R1_TrendTable[m_R1_LastPos] = newValue
            else
                if m_R1_TrendTable[m_R1_LastPos + 1] == nil then
                    -- 上次记录位置的下一个还没有记录 则继续向下记录
                    m_R1_LastPos = m_R1_LastPos + 1
                    m_R1_TrendTable[m_R1_LastPos] = newValue
                else
                    -- 上次记录的位置的Next 已经有数据(表示有数据已经走出L形态) 需要继续换新的行
                    m_R1_LastPos = m_R1_LastPos + m_R_OffsetY
                    m_R1_TrendTable[m_R1_LastPos] = newValue
                    m_R1_IsDeflected = true
                end
            end
        else
            m_R1_IsDeflected = false
            -- 开辟新行
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            local columnIndex = math.ceil(m_R1_LastPos / m_R_OffsetY) + 1
            for i = columnIndex, 1, -1 do
                if m_R1_TrendTable[i * m_R_OffsetY + 1] ~= nil then
                    break
                end
                columnIndex = i
            end
            m_R1_LastPos = columnIndex * m_R_OffsetY + 1
            m_R1_TrendTable[m_R1_LastPos] = newValue
            m_R1_LastUpdateValue = GetTrend2UpdateValue(newValue)
        end
    end
    -- 当前位置已经超出一屏显示的位置
    if m_R1_LastPos > m_R1_DisplayColumnCount * m_R_OffsetY then
        -- 先换算出480个格子时的列
        local columnMax = math.ceil(m_R1_LastPos / m_R_OffsetY) * m_R_OffsetY
        -- 替换为120个格子的列
        columnMax = math.ceil(columnMax / 4)
        for index = columnMax - m_R1_OffsetY, columnMax, 1 do
            GameObjectSetActive(m_R1_RoundItems[index].RootObject, true)
        end
    end

    -- 刷新当前最大的显示位置
    m_R1_CurrentMaxDisplayPos = math.max(m_R1_CurrentMaxDisplayPos, m_R1_LastPos)
    
    local trendItem = m_R1_RealItems[m_R1_LastPos]
    GameObjectSetActive(trendItem.RootObject, true)
    GameObjectSetActive(trendItem.Value1, newValue == 1)
    GameObjectSetActive(trendItem.Value2, newValue == 2)
end

-- [小路]刷新趋势图
function RefreshSmallTrendByStatistics(statistics)
    m_R2_TrendTable = {}
    m_R2_LastPos = 0
    m_R2_LastUpdateValue = 0
    m_R2_IsDeflected = false
    local initDisplayCount = m_R2_DisplayColumnCount * m_R2_OffsetY
    m_R2_CurrentMaxDisplayPos = initDisplayCount

    for index = 1, m_R2_ItemCount, 1 do
        local trendItem = m_R2_RoundItems[index]
        if trendItem ~= nil then
            -- 超出一屏的元素先隐藏
            if index > initDisplayCount then
                GameObjectSetActive(trendItem.RootObject, false)
            end
            -- 每个格子4个元素隐藏
            for i = 1, 4 do
                GameObjectSetActive(trendItem.Values[i].Value1, false)
                GameObjectSetActive(trendItem.Values[i].Value2, false)
            end
        else
            print("BJL=333大眼仔 nil index:", index)
        end
    end
    for roundIndex = 1, #statistics.Trend_Small, 1 do
        AppendSmallTrendValue(statistics.Trend_Small[roundIndex])
    end
end

-- [小路]路单追加统计
function AppendSmallTrendValue(newValue)
    if m_R2_LastPos == 0 then
        m_R2_LastPos = 1
        m_R2_TrendTable[m_R2_LastPos] = newValue
        m_R2_LastUpdateValue = GetTrend2UpdateValue(newValue)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue, m_R2_LastUpdateValue) == m_R2_LastUpdateValue then
            -- 本次结果与上一次结果保持一致
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            if m_R2_IsDeflected or m_R2_LastPos % m_R_OffsetY == 0 then
                -- 需要拐弯L(1 偏转因子 2位置达到底部的位置)
                m_R2_IsDeflected = true
                m_R2_LastPos = m_R2_LastPos + m_R_OffsetY
                m_R2_TrendTable[m_R2_LastPos] = newValue
            else
                if m_R2_TrendTable[m_R2_LastPos + 1] == nil then
                    -- 上次记录位置的下一个还没有记录 则继续向下记录
                    m_R2_LastPos = m_R2_LastPos + 1
                    m_R2_TrendTable[m_R2_LastPos] = newValue
                else
                    -- 上次记录的位置的Next 已经有数据(表示有数据已经走出L形态) 需要继续换新的行
                    m_R2_LastPos = m_R2_LastPos + m_R_OffsetY
                    m_R2_TrendTable[m_R2_LastPos] = newValue
                    m_R2_IsDeflected = true
                end
            end
        else
            m_R2_IsDeflected = false
            -- 开辟新行
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            local columnIndex = math.ceil(m_R2_LastPos / m_R_OffsetY) + 1
            for i = columnIndex, 1, -1 do
                if m_R2_TrendTable[i * m_R_OffsetY + 1] ~= nil then
                    break
                end
                columnIndex = i
            end
            m_R2_LastPos = columnIndex * m_R_OffsetY + 1
            m_R2_TrendTable[m_R2_LastPos] = newValue
            m_R2_LastUpdateValue = GetTrend2UpdateValue(newValue)
        end
    end
    -- 当前位置已经超出一屏显示的位置
    if m_R2_LastPos > m_R2_DisplayColumnCount * m_R_OffsetY then
        -- 先换算出480个格子时的列
        local columnMax = math.ceil(m_R2_LastPos / m_R_OffsetY) * m_R_OffsetY
        -- 替换为120个格子的列
        columnMax = math.ceil(columnMax / 4)
        for index = columnMax - m_R2_OffsetY, columnMax, 1 do
            GameObjectSetActive(m_R2_RoundItems[index].RootObject, true)
        end
    end

    -- 刷新当前最大的显示位置
    m_R2_CurrentMaxDisplayPos = math.max(m_R2_CurrentMaxDisplayPos, m_R2_LastPos)
    
    local trendItem = m_R2_RealItems[m_R2_LastPos]
    GameObjectSetActive(trendItem.RootObject, true)
    GameObjectSetActive(trendItem.Value1, newValue == 1)
    GameObjectSetActive(trendItem.Value2, newValue == 2)
end

-- [曱甴路]刷新趋势图
function RefreshYueYouTrendByStatistics(statistics)
    m_R3_TrendTable = {}
    m_R3_LastPos = 0
    m_R3_LastUpdateValue = 0
    m_R3_IsDeflected = false
    local initDisplayCount = m_R3_DisplayColumnCount * m_R3_OffsetY
    m_R3_CurrentMaxDisplayPos = initDisplayCount

    for index = 1, m_R3_ItemCount, 1 do
        local trendItem = m_R3_RoundItems[index]
        if trendItem ~= nil then
            -- 超出一屏的元素先隐藏
            if index > initDisplayCount then
                GameObjectSetActive(trendItem.RootObject, false)
            end
            -- 每个格子4个元素隐藏
            for i = 1, 4 do
                GameObjectSetActive(trendItem.Values[i].Value1, false)
                GameObjectSetActive(trendItem.Values[i].Value2, false)
            end
        else
            print("BJL=333大眼仔 nil index:", index)
        end
    end
    for roundIndex = 1, #statistics.Trend_YueYou, 1 do
        AppendYueYouTrendValue(statistics.Trend_YueYou[roundIndex])
    end
end

-- [曱甴路]路单追加统计
function AppendYueYouTrendValue(newValue)
    if m_R3_LastPos == 0 then
        m_R3_LastPos = 1
        m_R3_TrendTable[m_R3_LastPos] = newValue
        m_R3_LastUpdateValue = GetTrend2UpdateValue(newValue)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue, m_R3_LastUpdateValue) == m_R3_LastUpdateValue then
            -- 本次结果与上一次结果保持一致
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            if m_R3_IsDeflected or m_R3_LastPos % m_R_OffsetY == 0 then
                -- 需要拐弯L(1 偏转因子 2位置达到底部的位置)
                m_R3_IsDeflected = true
                m_R3_LastPos = m_R3_LastPos + m_R_OffsetY
                m_R3_TrendTable[m_R3_LastPos] = newValue
            else
                if m_R3_TrendTable[m_R3_LastPos + 1] == nil then
                    -- 上次记录位置的下一个还没有记录 则继续向下记录
                    m_R3_LastPos = m_R3_LastPos + 1
                    m_R3_TrendTable[m_R3_LastPos] = newValue
                else
                    -- 上次记录的位置的Next 已经有数据(表示有数据已经走出L形态) 需要继续换新的行
                    m_R3_LastPos = m_R3_LastPos + m_R_OffsetY
                    m_R3_TrendTable[m_R3_LastPos] = newValue
                    m_R3_IsDeflected = true
                end
            end
        else
            m_R3_IsDeflected = false
            -- 开辟新行
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            local columnIndex = math.ceil(m_R3_LastPos / m_R_OffsetY) + 1
            for i = columnIndex, 1, -1 do
                if m_R3_TrendTable[i * m_R_OffsetY + 1] ~= nil then
                    break
                end
                columnIndex = i
            end
            m_R3_LastPos = columnIndex * m_R_OffsetY + 1
            m_R3_TrendTable[m_R3_LastPos] = newValue
            m_R3_LastUpdateValue = GetTrend2UpdateValue(newValue)
        end
    end
    -- 当前位置已经超出一屏显示的位置
    if m_R3_LastPos > m_R3_DisplayColumnCount * m_R_OffsetY then
        -- 先换算出480个格子时的列
        local columnMax = math.ceil(m_R3_LastPos / m_R_OffsetY) * m_R_OffsetY
        -- 替换为120个格子的列
        columnMax = math.ceil(columnMax / 4)
        for index = columnMax - m_R3_OffsetY, columnMax, 1 do
            GameObjectSetActive(m_R3_RoundItems[index].RootObject, true)
        end
    end

    -- 刷新当前最大的显示位置
    m_R3_CurrentMaxDisplayPos = math.max(m_R3_CurrentMaxDisplayPos, m_R3_LastPos)
    
    local trendItem = m_R3_RealItems[m_R3_LastPos]
    GameObjectSetActive(trendItem.RootObject, true)
    GameObjectSetActive(trendItem.Value1, newValue == 1)
    GameObjectSetActive(trendItem.Value2, newValue == 2)
end

-- 刷新统计数量相关内容
function RefreshStatisticsCountsByStatistics(statistics)
    local rightBottom = this.transform:Find('RightBottom')
    rightBottom:Find('Row1/Item1/Value'):GetComponent("Text").text = tostring(statistics.Counts.HuWin)
    rightBottom:Find('Row1/Item2/Value'):GetComponent("Text").text = tostring(statistics.Counts.LongWin)
    rightBottom:Find('Row1/Item3/Value'):GetComponent("Text").text = tostring(statistics.Counts.HeJu)
    rightBottom:Find('Row1/Item4/Value'):GetComponent("Text").text = tostring(statistics.Round.CurrentRound)
    rightBottom:Find('Row2/Item1/Value'):GetComponent("Text").text = tostring(statistics.Counts.HuJinHua)
    rightBottom:Find('Row2/Item2/Value'):GetComponent("Text").text = tostring(statistics.Counts.LongJinHua)
    rightBottom:Find('Row2/Item3/Value'):GetComponent("Text").text = tostring(statistics.Counts.LongHuBaoZi)
end

function GetTrendResultSpriteOfTrendItem(roundResult)
    if CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.LONG) == BJL_WIN_CODE.LONG then
        return 'sprite_Trend_bjl_1'
    elseif CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.HU) == BJL_WIN_CODE.HU then
        return 'sprite_Trend_bjl_2'
    elseif CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.HE) == BJL_WIN_CODE.HE then
        return 'sprite_Trend_bjl_4'
    else
        return 'sprite_Trend_bjl_1'
    end
end

function GetTrend2IconNameByValue(value)
    if CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.LONG) == BJL_WIN_CODE.LONG then
        return 'sprite_lan'
    elseif CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.HU) == BJL_WIN_CODE.HU then
        return 'sprite_hong'
    elseif CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.HE) == BJL_WIN_CODE.HE then
        return 'sprite_lv'
    else
        return 'sprite_lv'
    end
end

-- 获取更新的值
function GetTrend2UpdateValue(value)
    if CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.LONG) == BJL_WIN_CODE.LONG then
        return BJL_WIN_CODE.LONG
    elseif CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.HU) == BJL_WIN_CODE.HU then
        return BJL_WIN_CODE.HU
    else
        return BJL_WIN_CODE.HE
    end
end

-- ========================================================
-- ================路单预测模块 Start=======================
-- 预测区域GameObject
local m_Zhuang_1 = nil
local m_Zhuang_2 = nil
local m_Zhuang_3 = nil
local m_XianJia_1 = nil
local m_XianJia_2 = nil
local m_XianJia_3 = nil

local m_Zhuang_1_1 = nil
local m_Zhuang_2_1 = nil
local m_Zhuang_3_1 = nil
local m_XianJia_1_1 = nil
local m_XianJia_2_1 = nil
local m_XianJia_3_1 = nil

function InitPrediction()
    m_Zhuang_1 = this.transform:Find('button01/Image1').gameObject
    m_Zhuang_1_1 = this.transform:Find('button01/Image1/Image').gameObject
    m_Zhuang_2 = this.transform:Find('button01/Image2').gameObject
    m_Zhuang_2_1 = this.transform:Find('button01/Image2/Image').gameObject
    m_Zhuang_3 = this.transform:Find('button01/Image3').gameObject
    m_Zhuang_3_1 = this.transform:Find('button01/Image3/Image').gameObject
    m_XianJia_1 = this.transform:Find('button02/Image1').gameObject
    m_XianJia_1_1 = this.transform:Find('button02/Image1/Image').gameObject
    m_XianJia_2 = this.transform:Find('button02/Image2').gameObject
    m_XianJia_2_1 = this.transform:Find('button02/Image2/Image').gameObject
    m_XianJia_3 = this.transform:Find('button02/Image3').gameObject
    m_XianJia_3_1 = this.transform:Find('button02/Image3/Image').gameObject

    GameObjectSetActive(m_Zhuang_1, false)
    GameObjectSetActive(m_Zhuang_2, false)
    GameObjectSetActive(m_Zhuang_3, false)
    GameObjectSetActive(m_XianJia_1, false)
    GameObjectSetActive(m_XianJia_2, false)
    GameObjectSetActive(m_XianJia_3, false)
    this.transform:Find('button01'):GetComponent("Button").onClick:AddListener(function () OnPredictionOnClick(2) end )
    this.transform:Find('button02'):GetComponent("Button").onClick:AddListener(function () OnPredictionOnClick(1) end )
end

-- 能否开始预测 大眼仔 小路 悦游路
local mCanPreBigEye = false
local mCanPreSmall = false
local mCanPreYueYou = false

-- 庄闲预测提示icon显示
function RefreshPreZXBtnState()
    local tStatisticData = GameData.RoomInfo.StatisticsInfo[m_RelativeRoomID]
    mCanPreBigEye = BJLGameMgr.CanPredictionTrendByType(tStatisticData, 1)
    mCanPreSmall = BJLGameMgr.CanPredictionTrendByType(tStatisticData, 2)
    mCanPreYueYou = BJLGameMgr.CanPredictionTrendByType(tStatisticData, 3)

    GameObjectSetActive(m_Zhuang_1, mCanPreBigEye)
    GameObjectSetActive(m_Zhuang_2, mCanPreSmall)
    GameObjectSetActive(m_Zhuang_3, mCanPreYueYou)
    GameObjectSetActive(m_XianJia_1, mCanPreBigEye)
    GameObjectSetActive(m_XianJia_2, mCanPreSmall)
    GameObjectSetActive(m_XianJia_3, mCanPreYueYou)
    
    if mCanPreBigEye then
        local tHeadIndex = #tStatisticData.Trend_List
        local tPreData = tStatisticData.Trend_List[tHeadIndex]
        local tResultData = { value = 2, x = tPreData.x, y = tPreData.y, pos = tPreData.pos}
        local tResult = BJLGameMgr.PredictionTrendBigEye(tStatisticData.Trend_Matrix, tPreData, tResultData)
        tResultData.value = 1
        local tResult2 = BJLGameMgr.PredictionTrendBigEye(tStatisticData.Trend_Matrix, tPreData, tResultData)
        GameObjectSetActive(m_Zhuang_1_1, tResult == 1) 
        GameObjectSetActive(m_XianJia_1_1, tResult2 == 2) 
    end

    if mCanPreSmall then
        local tHeadIndex = #tStatisticData.Trend_List
        local tPreData = tStatisticData.Trend_List[tHeadIndex]
        local tResultData = { value = 2, x = tPreData.x, y = tPreData.y, pos = tPreData.pos}
        local tResult = BJLGameMgr.PredictionTrendSmall(tStatisticData.Trend_Matrix, tPreData, tResultData)
        tResultData.value = 1
        local tResult2 = BJLGameMgr.PredictionTrendSmall(tStatisticData.Trend_Matrix, tPreData, tResultData)

        GameObjectSetActive(m_Zhuang_2_1, tResult == 1) 
        GameObjectSetActive(m_XianJia_2_1, tResult2 == 2) 
    end
    
    if mCanPreYueYou then
        local tHeadIndex = #tStatisticData.Trend_List
        local tPreData = tStatisticData.Trend_List[tHeadIndex]
        local tResultData = { value = 2, x = tPreData.x, y = tPreData.y, pos = tPreData.pos}
        local tResult = BJLGameMgr.PredictionTrendYueYou(tStatisticData.Trend_Matrix, tPreData, tResultData)
        tResultData.value = 1
        local tResult2 = BJLGameMgr.PredictionTrendYueYou(tStatisticData.Trend_Matrix, tPreData, tResultData)
        GameObjectSetActive(m_Zhuang_3_1, tResult == 1) 
        GameObjectSetActive(m_XianJia_3_1, tResult2 == 2) 
    end
end

local mCanClick = true
local mPreShowItems = {}                        -- 预测显示的item
local mPredictionTrendCD = 3                    -- CD相关信息
local mPredictionTrendCDPassTime = 0
local mPredictionTrendActiveTime = 0.5
local mPredictionTrendActivePass = 0
local mPredictionTrendActive = true

function OnPredictionOnClick(paramType)
    print("=====点击:", paramType)
    if not mCanClick then
        return
    end
    mCanClick = false
    mPredictionTrendActive = true
    mPredictionTrendCDPassTime = 0
    mPredictionTrendActivePass = 0
    local preValue = paramType
    PreShowLeftTrend(preValue)
    PreShowRightTrend(preValue)
    PreShowRightTrendBigEye(preValue)
    PreShowRightTrendSmall(preValue)
    PreShowRightTrendYueYou(preValue)
end

-- 更新预测节点显示状态
function UpdatePredictionTrendActive(isActiveParam)
    for i = 1, 5 do
        local trendItem = mPreShowItems[i]
        if trendItem ~= nil then
            if i == 1 then
                GameObjectSetActive(trendItem.ValueIcon.gameObject, isActiveParam)
            elseif i == 2 then
                GameObjectSetActive(trendItem.ValueIcon.gameObject, isActiveParam)
            else
                GameObjectSetActive(trendItem.RootObject, isActiveParam)
            end
        end
    end
end

-- 预测结果显示更新
function UpdatePredictionTrendCD(deltaTime)
    if not mCanClick then
        -- 间歇式显示隐藏
        mPredictionTrendActivePass = mPredictionTrendActivePass + deltaTime
        if mPredictionTrendActivePass >= mPredictionTrendActiveTime then
            mPredictionTrendActivePass = 0
            mPredictionTrendActive = not mPredictionTrendActive
            UpdatePredictionTrendActive(mPredictionTrendActive)
        end
        -- 总的显示控制
        mPredictionTrendCDPassTime = mPredictionTrendCDPassTime + deltaTime
        if mPredictionTrendCDPassTime > mPredictionTrendCD then
            mCanClick = true
            UpdatePredictionTrendActive(false)
        end
    end
end

-- [左侧大路]预显示1
function PreShowLeftTrend(preValue)
    local tStatisticsData = GameData.RoomInfo.StatisticsInfo[m_RelativeRoomID]
    local roundIndex = m_LastHandleRound_L + 1
    local roundItem = m_L_RoundItems[roundIndex]
    SetTrendItemResult(roundItem, preValue)
    ResetScrollRectLVisible(#tStatisticsData.Trend + 1)
    mPreShowItems[1] = roundItem
end

-- [大路]预显示1
function PreShowRightTrend(preValue)
    local tData = {TrendRValue = preValue, TrendRHeCount = 0}
    mPreShowItems[2] = PreAppendRightTrend(tData)
end

-- [大路]预显示2
function PreAppendRightTrend(newValue)
    local tLastPos = m_R_LastPos
    local tLastUpdateValue = m_R_LastUpdateValue
    if tLastPos == 0 then
        tLastPos = 1
        tLastUpdateValue = GetTrend2UpdateValue(newValue.TrendRValue)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue.TrendRValue, m_R_LastUpdateValue) == m_R_LastUpdateValue then
            if m_R_IsDeflected or tLastPos % m_R_OffsetY == 0 then
                tLastPos = tLastPos + m_R_OffsetY
            else
                if m_R_TrendTable[tLastPos + 1] == nil then
                    tLastPos = tLastPos + 1
                else
                    tLastPos = tLastPos + m_R_OffsetY
                end
            end
        else
            -- 开辟新行
            local columnIndex = math.ceil(tLastPos / m_R_OffsetY) + 1
            for i = columnIndex, 1, -1 do
                if m_R_TrendTable[i * m_R_OffsetY + 1] ~= nil then
                    break
                end
                columnIndex = i
            end
            tLastPos = columnIndex * m_R_OffsetY + 1
        end
    end
    
    if tLastPos > m_R_DisplayColumnCount * m_R_OffsetY then
        -- 当前位置已经超出一屏显示的位置
        local columnMax = math.ceil(tLastPos / m_R_OffsetY) * m_R_OffsetY
        for index = columnMax - m_R_OffsetY, columnMax, 1 do
            GameObjectSetActive(m_R_RoundItems[index].RootObject, true)
        end
    end
    -- 刷新当前最大的显示位置
    local tCurrentMaxDisplayPos = math.max(m_R_CurrentMaxDisplayPos, tLastPos)
    
    UpdateRightStatisticsTrendValue(tLastPos,newValue)
    ResetScrollRectVisible2R(tCurrentMaxDisplayPos)
    local trendItem = m_R_RoundItems[tLastPos]
    return trendItem
end

-- [大眼仔]预显示1
function PreShowRightTrendBigEye(preValue)
    if not mCanPreBigEye then
        return
    end
    mPreShowItems[3] = PreAppendBigEyeTrend(preValue)
end

-- [大眼仔]预显示2
function PreAppendBigEyeTrend(newValue)
    
    local tStatisticData = GameData.RoomInfo.StatisticsInfo[m_RelativeRoomID]
    local tHeadIndex = #tStatisticData.Trend_List
    local tPreData = tStatisticData.Trend_List[tHeadIndex]
    local tResultData = { value = newValue, x = tPreData.x, y = tPreData.y, pos = tPreData.pos}
    -- 得到预测结果
    newValue = BJLGameMgr.PredictionTrendBigEye(tStatisticData.Trend_Matrix, tPreData, tResultData)

    local tLastPos = m_R1_LastPos
    local tLastUpdateValue = m_R1_LastUpdateValue
    if tLastPos == 0 then
        tLastPos = 1
        tLastUpdateValue = GetTrend2UpdateValue(newValue)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue, tLastUpdateValue) == tLastUpdateValue then
            -- 本次结果与上一次结果保持一致
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            if m_R1_IsDeflected or m_R1_LastPos % m_R_OffsetY == 0 then
                -- 需要拐弯L(1 偏转因子 2位置达到底部的位置)
                tLastPos = m_R1_LastPos + m_R_OffsetY
            else
                if m_R1_TrendTable[m_R1_LastPos + 1] == nil then
                    -- 上次记录位置的下一个还没有记录 则继续向下记录
                    tLastPos = m_R1_LastPos + 1
                else
                    -- 上次记录的位置的Next 已经有数据(表示有数据已经走出L形态) 需要继续换新的行
                    tLastPos = m_R1_LastPos + m_R_OffsetY
                end
            end
        else
            -- 开辟新行
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            local columnIndex = math.ceil(m_R1_LastPos / m_R_OffsetY) + 1
            for i = columnIndex, 1, -1 do
                if m_R1_TrendTable[i * m_R_OffsetY + 1] ~= nil then
                    break
                end
                columnIndex = i
            end
            tLastPos = columnIndex * m_R_OffsetY + 1
        end
    end
    -- 当前位置已经超出一屏显示的位置
    if tLastPos > m_R1_DisplayColumnCount * m_R_OffsetY then
        -- 先换算出480个格子时的列
        local columnMax = math.ceil(tLastPos / m_R_OffsetY) * m_R_OffsetY
        -- 替换为120个格子的列
        columnMax = math.ceil(columnMax / 4)
        for index = columnMax - m_R1_OffsetY, columnMax, 1 do
            GameObjectSetActive(m_R1_RoundItems[index].RootObject, true)
        end
    end

    -- 刷新当前最大的显示位置
    local tCurrentMaxDisplayPos = math.max(m_R1_CurrentMaxDisplayPos, tLastPos)
    
    local trendItem = m_R1_RealItems[tLastPos]
    GameObjectSetActive(trendItem.RootObject, true)
    GameObjectSetActive(trendItem.Value1, newValue == 1)
    GameObjectSetActive(trendItem.Value2, newValue == 2)
    ResetScrollRectVisible2R1(tCurrentMaxDisplayPos)
    return trendItem
end

-- [小路]预显示1
function PreShowRightTrendSmall(preValue)
    if not mCanPreSmall then
        return 
    end
    mPreShowItems[4] = PreAppendSmallTrend(preValue)
end

-- [小路]预显示2
function PreAppendSmallTrend(newValue)
    local tStatisticData = GameData.RoomInfo.StatisticsInfo[m_RelativeRoomID]
    local tHeadIndex = #tStatisticData.Trend_List
    local tPreData = tStatisticData.Trend_List[tHeadIndex]
    local tResultData = { value = newValue, x = tPreData.x, y = tPreData.y, pos = tPreData.pos}
    -- 得到预测结果
    newValue = BJLGameMgr.PredictionTrendSmall(tStatisticData.Trend_Matrix, tPreData, tResultData)

    local tLastPos = m_R2_LastPos
    local tLastUpdateValue = m_R2_LastUpdateValue
    if tLastPos == 0 then
        tLastPos = 1
        tLastUpdateValue = GetTrend2UpdateValue(newValue)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue, tLastUpdateValue) == tLastUpdateValue then
            -- 本次结果与上一次结果保持一致
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            if m_R2_IsDeflected or tLastPos % m_R_OffsetY == 0 then
                -- 需要拐弯L(1 偏转因子 2位置达到底部的位置)
                tLastPos = m_R2_LastPos + m_R_OffsetY
            else
                if m_R2_TrendTable[tLastPos + 1] == nil then
                    -- 上次记录位置的下一个还没有记录 则继续向下记录
                    tLastPos = m_R2_LastPos + 1
                else
                    -- 上次记录的位置的Next 已经有数据(表示有数据已经走出L形态) 需要继续换新的行
                    tLastPos = m_R2_LastPos + m_R_OffsetY
                end
            end
        else
            -- 开辟新行
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            local columnIndex = math.ceil(tLastPos / m_R_OffsetY) + 1
            for i = columnIndex, 1, -1 do
                if m_R2_TrendTable[i * m_R_OffsetY + 1] ~= nil then
                    break
                end
                columnIndex = i
            end
            tLastPos = columnIndex * m_R_OffsetY + 1
        end
    end
    -- 当前位置已经超出一屏显示的位置
    if tLastPos > m_R2_DisplayColumnCount * m_R_OffsetY then
        -- 先换算出480个格子时的列
        local columnMax = math.ceil(tLastPos / m_R_OffsetY) * m_R_OffsetY
        -- 替换为120个格子的列
        columnMax = math.ceil(columnMax / 4)
        for index = columnMax - m_R2_OffsetY, columnMax, 1 do
            GameObjectSetActive(m_R2_RoundItems[index].RootObject, true)
        end
    end

    -- 刷新当前最大的显示位置
    local tCurrentMaxDisplayPos = math.max(m_R2_CurrentMaxDisplayPos, tLastPos)
    
    local trendItem = m_R2_RealItems[tLastPos]
    GameObjectSetActive(trendItem.RootObject, true)
    GameObjectSetActive(trendItem.Value1, newValue == 1)
    GameObjectSetActive(trendItem.Value2, newValue == 2)
    ResetScrollRectVisible2R2(tCurrentMaxDisplayPos)
    return trendItem
end

-- [曱甴路]预显示1
function PreShowRightTrendYueYou(preValue)
    if not mCanPreYueYou then
        return
    end
    mPreShowItems[5] = PreAppendYueYouTrend(preValue)
end

-- [曱甴路]预显示2
function PreAppendYueYouTrend(newValue)
    local tStatisticData = GameData.RoomInfo.StatisticsInfo[m_RelativeRoomID]
    local tHeadIndex = #tStatisticData.Trend_List
    local tPreData = tStatisticData.Trend_List[tHeadIndex]
    local tResultData = { value = newValue, x = tPreData.x, y = tPreData.y, pos = tPreData.pos}
    -- 得到预测结果
    newValue = BJLGameMgr.PredictionTrendYueYou(tStatisticData.Trend_Matrix, tPreData, tResultData)

    local tLastPos = m_R3_LastPos
    local tLastUpdateValue = m_R3_LastUpdateValue
    if tLastPos == 0 then
        tLastPos = 1
        tLastUpdateValue = GetTrend2UpdateValue(newValue)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue, tLastUpdateValue) == tLastUpdateValue then
            -- 本次结果与上一次结果保持一致
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            if m_R3_IsDeflected or tLastPos % m_R_OffsetY == 0 then
                -- 需要拐弯L(1 偏转因子 2位置达到底部的位置)
                m_R3_IsDeflected = true
                tLastPos = tLastPos + m_R_OffsetY
            else
                if m_R3_TrendTable[tLastPos + 1] == nil then
                    -- 上次记录位置的下一个还没有记录 则继续向下记录
                    tLastPos = tLastPos + 1
                else
                    -- 上次记录的位置的Next 已经有数据(表示有数据已经走出L形态) 需要继续换新的行
                    tLastPos = tLastPos + m_R_OffsetY
                end
            end
        else
            m_R3_IsDeflected = false
            -- 开辟新行
            -- 注意每一列还是6个元素 使用m_R_OffsetY 作为换行偏转因子
            local columnIndex = math.ceil(tLastPos / m_R_OffsetY) + 1
            for i = columnIndex, 1, -1 do
                if m_R3_TrendTable[i * m_R_OffsetY + 1] ~= nil then
                    break
                end
                columnIndex = i
            end
            tLastPos = columnIndex * m_R_OffsetY + 1
        end
    end
    -- 当前位置已经超出一屏显示的位置
    if tLastPos > m_R3_DisplayColumnCount * m_R_OffsetY then
        -- 先换算出480个格子时的列
        local columnMax = math.ceil(tLastPos / m_R_OffsetY) * m_R_OffsetY
        -- 替换为120个格子的列
        columnMax = math.ceil(columnMax / 4)
        for index = columnMax - m_R3_OffsetY, columnMax, 1 do
            GameObjectSetActive(m_R3_RoundItems[index].RootObject, true)
        end
    end

    -- 刷新当前最大的显示位置
    local tCurrentMaxDisplayPos = math.max(m_R3_CurrentMaxDisplayPos, tLastPos)
    
    local trendItem = m_R3_RealItems[tLastPos]
    GameObjectSetActive(trendItem.RootObject, true)
    GameObjectSetActive(trendItem.Value1, newValue == 1)
    GameObjectSetActive(trendItem.Value2, newValue == 2)
    ResetScrollRectVisible2R3(tCurrentMaxDisplayPos)
    return trendItem
end

-- ================路单预测模块 End=========================