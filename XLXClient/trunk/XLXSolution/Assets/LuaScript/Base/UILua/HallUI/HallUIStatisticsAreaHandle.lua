-- 是否初始化
local isInited = false
-- 关联的房间ID和统计信息
local m_RelativeRoomID = 0

-- 右侧统计数据
local m_R_LastPos = 0
local m_R_LastUpdateValue = 0
local m_R_OffsetY = 6               -- 1列6个元素
local m_R_OffsetX = 20              -- 显示20列(64列)
local m_R_DisplayColumnCount = 20
local m_R_CurrentMaxDisplayPos = 20
local m_R_TrendTable = { }
local m_R_IsDeflected = false

-- 左侧统计数据
local m_L_OffsetY = 6            -- 1列多少个
local m_L_OffsetX = 8           -- 显示9列(总共64个元素需要13列,现阶段调整为元素显示不超过35个)
local m_L_DisplayColumnCount = 9

local m_R_ItemCount = 0
local m_L_ItemCount = 0          -- 左侧

local m_L_StatisticsRoot = nil
local m_R_StatisticsRoot = nil
-- 左右两侧Items
local m_L_RoundItems = {}
local m_R_RoundItems = {}

-- 上次处理到的回合数
local m_LastHandleRound_L = 0
local m_LastHandleRound_R = 0

-- 统计大小
local m_L_ItemSize = 0
local m_R_ItemSize = 0

local mCurrentRoomType = ROOM_TYPE.BRJH

-- 右侧信息栏
local RightBottomInfo = 
{
    BRJH = {},
    LHD = {},
    BJL = {},

    lines = nil,
    linesLHD = nil,
}

function Awake()
    m_L_ItemCount = m_L_OffsetX * m_L_OffsetY
    m_R_ItemCount = m_R_OffsetX * m_R_OffsetY

    m_L_StatisticsRoot = this.transform:Find('StatisticsLeft/Viewport/Content')
    m_R_StatisticsRoot = this.transform:Find('StatisticsRight/Viewport/Content')
    local leftGridLayoutGroup = m_L_StatisticsRoot:GetComponent("GridLayoutGroup")
    m_L_ItemSize = leftGridLayoutGroup.cellSize.x + leftGridLayoutGroup.spacing.x
    local rightGridLayoutGroup = m_R_StatisticsRoot:GetComponent("GridLayoutGroup")
    m_R_ItemSize = rightGridLayoutGroup.cellSize.x + rightGridLayoutGroup.spacing.x

    local rightBottom = this.transform:Find('RightBottom')
    RightBottomInfo.BRJH.RootObject = rightBottom.gameObject
    RightBottomInfo.BRJH.ValueText11 = rightBottom:Find('Row1/Item1/Value'):GetComponent("Text")
    RightBottomInfo.BRJH.ValueText12 = rightBottom:Find('Row1/Item2/Value'):GetComponent("Text")
    RightBottomInfo.BRJH.ValueText13 = rightBottom:Find('Row1/Item3/Value'):GetComponent("Text")
    RightBottomInfo.BRJH.ValueText14 = rightBottom:Find('Row1/Item4/Value'):GetComponent("Text")
    RightBottomInfo.BRJH.ValueText21 = rightBottom:Find('Row2/Item1/Value'):GetComponent("Text")
    RightBottomInfo.BRJH.ValueText22 = rightBottom:Find('Row2/Item2/Value'):GetComponent("Text")
    RightBottomInfo.BRJH.ValueText23 = rightBottom:Find('Row2/Item3/Value'):GetComponent("Text")

    local rightBottom = this.transform:Find('RightBottomLHD')
    RightBottomInfo.LHD.RootObject = rightBottom.gameObject
    RightBottomInfo.LHD.ValueText11 = rightBottom:Find('Row1/Item1/Value'):GetComponent("Text")
    RightBottomInfo.LHD.ValueText12 = rightBottom:Find('Row1/Item2/Value'):GetComponent("Text")
    RightBottomInfo.LHD.ValueText13 = rightBottom:Find('Row1/Item3/Value'):GetComponent("Text")
    RightBottomInfo.LHD.ValueText14 = rightBottom:Find('Row1/Item4/Value'):GetComponent("Text")

    local rightBottom = this.transform:Find('RightBottomBJL')
    RightBottomInfo.BJL.RootObject = rightBottom.gameObject
    RightBottomInfo.BJL.ValueText11 = rightBottom:Find('Row1/Item1/Value'):GetComponent("Text")
    RightBottomInfo.BJL.ValueText12 = rightBottom:Find('Row1/Item2/Value'):GetComponent("Text")
    RightBottomInfo.BJL.ValueText13 = rightBottom:Find('Row1/Item3/Value'):GetComponent("Text")
    RightBottomInfo.BJL.ValueText14 = rightBottom:Find('Row1/Item4/Value'):GetComponent("Text")
    RightBottomInfo.BJL.ValueText21 = rightBottom:Find('Row2/Item1/Value'):GetComponent("Text")
    RightBottomInfo.BJL.ValueText22 = rightBottom:Find('Row2/Item2/Value'):GetComponent("Text")
    RightBottomInfo.BJL.ValueText23 = rightBottom:Find('Row2/Item3/Value'):GetComponent("Text")

    RightBottomInfo.lines = this.transform:Find('lines').gameObject
    RightBottomInfo.linesLHD = this.transform:Find('linesLHD').gameObject

    CreateStatisticsTrendItems(m_L_StatisticsRoot, m_L_ItemCount, m_L_OffsetY * m_L_DisplayColumnCount, 1)
    CreateStatisticsTrendItems(m_R_StatisticsRoot, m_R_ItemCount, m_R_OffsetY * m_R_DisplayColumnCount, 2)
    isInited = true
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.UpdateStatistics, HandleUpdateStatisticsInfo)
    ResetRelativeRoomID(m_RelativeRoomID)
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
end

-- 处理更新统计信息
function HandleUpdateStatisticsInfo(eventArgs)
    if GameData.GameState ~= GAME_STATE.HALL then
        return
    end
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

-- 重置统计信息
function ResetStatisticsInfo(statistics)
    m_RelativeRoomID = statistics.RoomID
    m_LastHandleRound_L = #statistics.Trend
    m_LastHandleRound_R = #statistics.Trend_R
    if isInited == true then
        RefreshStatisticsTrendByStatistics(statistics)
    end
end

-- 追加统计信息
function AppendStatisticsInfo(statistics)
    if statistics.RoomID ~= m_RelativeRoomID then
        ResetStatisticsInfo(statistics)
    else
        local tCurrentRound = #statistics.Trend
        local tCurrentRound_R = #statistics.Trend_R
        if m_LastHandleRound_L < tCurrentRound then
            -- 刷新左侧的统计图
            for roundIndex = m_LastHandleRound_L + 1, math.ceil(tCurrentRound / m_L_OffsetY) * m_L_OffsetY, 1 do
                local roundItem = m_L_RoundItems[roundIndex]
                if roundItem ~= nil then
                    SetTrendItemResult(roundItem, statistics.Trend[roundIndex])
                else
                    print("左侧数据nil 222:", roundIndex)
                end
            end
            -- 刷新右侧的统计图
            if m_LastHandleRound_R == tCurrentRound_R then
                -- 追加路单可能是和局 需要更新之前路单信息
                UpdateRightStatisticsTrendValue(m_R_LastPos, statistics.Trend_R[m_LastHandleRound_R])
            end
            for	roundIndex = m_LastHandleRound_R + 1, tCurrentRound_R, 1 do
                AppendRightStatisticsTrendValue(statistics.Trend_R[roundIndex])
            end
            
            ResetStatisticsRootToRightVisible(tCurrentRound)
            RefreshStatisticsCountsByStatistics(statistics)
            m_LastHandleRound_L = tCurrentRound
            m_LastHandleRound_R = tCurrentRound_R
        else
            ResetStatisticsInfo(statistics)
        end
    end
end

-- 刷新统计趋势图，数量
function RefreshStatisticsTrendByStatistics(statistics)
    RefreshLeftStatisticsTrendByStatistics(statistics)
    RefreshRightStatisticsTrendByStatistics(statistics)
    RefreshStatisticsCountsByStatistics(statistics)
    ResetStatisticsRootToRightVisible(#statistics.Trend)
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
            print("左侧数据nil 111:", roundIndex)
        end
        if roundIndex > displayCount then
            GameObjectSetActive(roundItem.ValueIcon.gameObject, false)
        else
            local roundResult = statistics.Trend[roundIndex]
            SetTrendItemResult(roundItem, roundResult)
        end
    end
end

function SetTrendItemResult(roundItem, roundResult)
    GameObjectSetActive(roundItem.RootObject, true)
    if roundResult ~= nil then
        GameObjectSetActive(roundItem.ValueIcon.gameObject, true)
        local spriteName = GetTrendResultSpriteOfTrendItem(roundResult)
        roundItem.ValueIcon:ResetSpriteByName(spriteName)
        
        local tRoomType = GameData.HallData.SelectType
        if tRoomType == ROOM_TYPE.LHDRoom then
            
        elseif tRoomType == ROOM_TYPE.BJLRoom then
            GameObjectSetActive(roundItem.LongJinHua, CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.LONGDUIZI) == BJL_WIN_CODE.LONGDUIZI)
            GameObjectSetActive(roundItem.HuJinHua, CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.HUDUIZI) == BJL_WIN_CODE.HUDUIZI)
        else
            GameObjectSetActive(roundItem.BaoZi, CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.LONGHUBAOZI) == WIN_CODE.LONGHUBAOZI)
            GameObjectSetActive(roundItem.LongJinHua, CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.LONGJINHUA) == WIN_CODE.LONGJINHUA)
            GameObjectSetActive(roundItem.HuJinHua, CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.HUJINHUA) == WIN_CODE.HUJINHUA)
        end
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
    m_R_TrendTable = { }
    m_R_LastPos = 0
    m_R_LastUpdateValue = 0
    m_R_IsDeflected = false
    local initDisplayCount = m_R_DisplayColumnCount * m_R_OffsetY
    m_R_CurrentMaxDisplayPos = initDisplayCount
    for index = 1, m_R_ItemCount, 1 do
        local trendItem = m_R_RoundItems[index]
        if trendItem ~= nil then
            if index > initDisplayCount then
                GameObjectSetActive(trendItem.RootObject, true)
            end
            GameObjectSetActive(trendItem.ValueIcon.gameObject, false)
            GameObjectSetActive(trendItem.BaoZi, false)
            GameObjectSetActive(trendItem.LongJinHua, false)
            GameObjectSetActive(trendItem.HuJinHua, false)
            GameObjectSetActive(trendItem.HeText.gameObject, false)
        else
            print("右侧数据nil 333:", index)
        end
    end

    for roundIndex = 1, #statistics.Trend_R, 1 do
        AppendRightStatisticsTrendValue(statistics.Trend_R[roundIndex])
    end
end

function ResetStatisticsRootToRightVisible(roundCount)
    local leftDisplayCount = math.max(math.ceil(roundCount / m_L_OffsetY), m_L_DisplayColumnCount)
    local leftPosX = m_L_StatisticsRoot.parent.rect.size.x - leftDisplayCount * m_L_ItemSize
    local leftLocalPos = m_L_StatisticsRoot.localPosition
    leftLocalPos.x = leftPosX
    -- 位置偏远 屏蔽
    --m_L_StatisticsRoot.localPosition = leftLocalPos

    local rightDisplayCount = math.max(math.ceil(m_R_CurrentMaxDisplayPos / m_R_OffsetY))
    local rightPosX =(m_R_StatisticsRoot.parent.rect.size.x - rightDisplayCount * m_R_ItemSize)
    local rightLocalPos = m_R_StatisticsRoot.localPosition
    rightLocalPos.x = rightPosX
    -- 位置偏远屏蔽
    --m_R_StatisticsRoot.localPosition = rightLocalPos
end

-- 追加统计值
function AppendRightStatisticsTrendValue(newValue)
    if m_R_LastPos == 0 then
        m_R_LastPos = 1
        m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
        m_R_LastUpdateValue = GetTrend2UpdateValue(newValue.TrendRValue)
    else
        -- 下一个坐标点的valueIcon 是否显示，显示则转向
        if CS.Utility.GetLogicAndValue(newValue.TrendRValue, m_R_LastUpdateValue) == m_R_LastUpdateValue then
            if m_R_IsDeflected or m_R_LastPos % m_R_OffsetY == 0 then
                m_R_IsDeflected = true
                m_R_LastPos = m_R_LastPos + m_R_OffsetY
                m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
            else
                if m_R_TrendTable[m_R_LastPos + 1] == nil then
                    m_R_LastPos = m_R_LastPos + 1
                    m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
                else
                    m_R_LastPos = m_R_LastPos + m_R_OffsetY
                    m_R_TrendTable[m_R_LastPos] = newValue.TrendRValue
                    m_R_IsDeflected = true
                end
            end
        else
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
        local columnMax = math.ceil(m_R_LastPos / m_R_OffsetY) * m_R_OffsetY
        for index = columnMax - m_R_OffsetY, columnMax, 1 do
            if m_R_RoundItems[index] ~= nil then
                GameObjectSetActive(m_R_RoundItems[index].RootObject, true)
            else
                --print("右侧数据nil 111:", index)
            end
        end
    end
    -- 刷新当前最大的显示位置
    m_R_CurrentMaxDisplayPos = math.max(m_R_CurrentMaxDisplayPos, m_R_LastPos)

    local trendItem = m_R_RoundItems[m_R_LastPos]
    if trendItem ~= nil then
        trendItem.ValueIcon:ResetSpriteByName(GetTrend2IconNameByValue(newValue.TrendRValue))
        GameObjectSetActive(trendItem.ValueIcon.gameObject, true)

        local tRoomType = GameData.HallData.SelectType
        if tRoomType == ROOM_TYPE.LHDRoom then
            
        elseif tRoomType == ROOM_TYPE.BJLRoom then
            GameObjectSetActive(trendItem.LongJinHua, CS.Utility.GetLogicAndValue(newValue.TrendRValue, BJL_WIN_CODE.LONGDUIZI) == BJL_WIN_CODE.LONGDUIZI)
            GameObjectSetActive(trendItem.HuJinHua, CS.Utility.GetLogicAndValue(newValue.TrendRValue, BJL_WIN_CODE.HUDUIZI) == BJL_WIN_CODE.HUDUIZI)
        else
            GameObjectSetActive(trendItem.BaoZi, CS.Utility.GetLogicAndValue(newValue, WIN_CODE.LONGHUBAOZI) == WIN_CODE.LONGHUBAOZI)
            GameObjectSetActive(trendItem.LongJinHua, CS.Utility.GetLogicAndValue(newValue, WIN_CODE.LONGJINHUA) == WIN_CODE.LONGJINHUA)
            GameObjectSetActive(trendItem.HuJinHua, CS.Utility.GetLogicAndValue(newValue, WIN_CODE.HUJINHUA) == WIN_CODE.HUJINHUA)
        end
        local tIsHe = newValue.TrendRHeCount > 0
        GameObjectSetActive(trendItem.HeText.gameObject, tIsHe)
        if tIsHe then
            trendItem.HeText.text = tostring(newValue.TrendRHeCount)
        end
    end
end

-- 右侧路单信息显示刷新
function UpdateRightStatisticsTrendValue(trendPos, newValue)
    local trendItem = m_R_RoundItems[trendPos]
    if trendItem == nil then
        return
    end
    trendItem.ValueIcon:ResetSpriteByName(GetTrend2IconNameByValue(newValue.TrendRValue))
    GameObjectSetActive(trendItem.ValueIcon.gameObject, true)
    GameObjectSetActive(trendItem.BaoZi, CS.Utility.GetLogicAndValue(newValue.TrendRValue, WIN_CODE.LONGHUBAOZI) == WIN_CODE.LONGHUBAOZI)
    GameObjectSetActive(trendItem.LongJinHua, CS.Utility.GetLogicAndValue(newValue.TrendRValue, WIN_CODE.LONGJINHUA) == WIN_CODE.LONGJINHUA)
    GameObjectSetActive(trendItem.HuJinHua, CS.Utility.GetLogicAndValue(newValue.TrendRValue, WIN_CODE.HUJINHUA) == WIN_CODE.HUJINHUA)
    local tIsHe = newValue.TrendRHeCount > 0
    GameObjectSetActive(trendItem.HeText.gameObject, tIsHe)
    if tIsHe then
        trendItem.HeText.text = tostring(newValue.TrendRHeCount)
    end
end

-- 刷新统计数量相关内容
function RefreshStatisticsCountsByStatistics(statistics)
    local tRoomType = GameData.HallData.SelectType
    GameObjectSetActive(RightBottomInfo.lines, tRoomType ~= ROOM_TYPE.LHDRoom)
    GameObjectSetActive(RightBottomInfo.linesLHD, tRoomType == ROOM_TYPE.LHDRoom)
    GameObjectSetActive(RightBottomInfo.BRJH.RootObject, tRoomType == ROOM_TYPE.BRJH)
    GameObjectSetActive(RightBottomInfo.LHD.RootObject, tRoomType == ROOM_TYPE.LHDRoom)
    GameObjectSetActive(RightBottomInfo.BJL.RootObject, tRoomType == ROOM_TYPE.BJLRoom)
    
    if tRoomType == ROOM_TYPE.BRJH then
        RightBottomInfo.BRJH.ValueText11.text = tostring(statistics.Counts.LongWin)
        RightBottomInfo.BRJH.ValueText12.text = tostring(statistics.Counts.HuWin)
        RightBottomInfo.BRJH.ValueText13.text = tostring(statistics.Counts.HeJu)
        RightBottomInfo.BRJH.ValueText14.text = string.format("%d/%d", statistics.Round.CurrentRound, statistics.Round.MaxRound)
        RightBottomInfo.BRJH.ValueText21.text = tostring(statistics.Counts.LongJinHua)
        RightBottomInfo.BRJH.ValueText22.text = tostring(statistics.Counts.HuJinHua)
        RightBottomInfo.BRJH.ValueText23.text = tostring(statistics.Counts.LongHuBaoZi)
    elseif tRoomType == ROOM_TYPE.LHDRoom then
        RightBottomInfo.LHD.ValueText11.text = tostring(statistics.Counts.LongWin)
        RightBottomInfo.LHD.ValueText12.text = tostring(statistics.Counts.HuWin)
        RightBottomInfo.LHD.ValueText13.text = tostring(statistics.Counts.HeJu)
        RightBottomInfo.LHD.ValueText14.text = string.format("%d/%d", statistics.Round.CurrentRound, statistics.Round.MaxRound)
    else
        RightBottomInfo.BJL.ValueText11.text = tostring(statistics.Counts.HuWin)
        RightBottomInfo.BJL.ValueText12.text = tostring(statistics.Counts.LongWin)
        RightBottomInfo.BJL.ValueText13.text = tostring(statistics.Counts.HeJu)
        RightBottomInfo.BJL.ValueText14.text = tostring(statistics.Round.CurrentRound)
        RightBottomInfo.BJL.ValueText21.text = tostring(statistics.Counts.HuJinHua)
        RightBottomInfo.BJL.ValueText22.text = tostring(statistics.Counts.LongJinHua)
        RightBottomInfo.BJL.ValueText23.text = tostring(statistics.Counts.LongHuBaoZi)
    end
end

function GetTrendResultSpriteOfTrendItem(roundResult)
    local tRoomType = GameData.HallData.SelectType
    if tRoomType == ROOM_TYPE.BJLRoom then
        if CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.LONG) == BJL_WIN_CODE.LONG then
            return 'sprite_Trend_bjl_1'
        elseif CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.HU) == BJL_WIN_CODE.HU then
            return 'sprite_Trend_bjl_2'
        elseif CS.Utility.GetLogicAndValue(roundResult, BJL_WIN_CODE.HE) == BJL_WIN_CODE.HE then
            return 'sprite_Trend_bjl_4'
        else
            return 'sprite_Trend_bjl_1'
        end
    else
        if CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.LONG) == WIN_CODE.LONG then
            return 'sprite_Trend_Icon_1'
        elseif CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.HU) == WIN_CODE.HU then
            return 'sprite_Trend_Icon_2'
        elseif CS.Utility.GetLogicAndValue(roundResult, WIN_CODE.HE) == WIN_CODE.HE then
            return 'sprite_Trend_Icon_4'
        else
            return 'sprite_Trend_Icon_1'
        end
    end
end

function GetTrend2IconNameByValue(value)
    local tRoomType = GameData.HallData.SelectType
    if tRoomType == ROOM_TYPE.BJLRoom then
        if CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.LONG) == BJL_WIN_CODE.LONG then
            return 'sprite_lan'
        elseif CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.HU) == BJL_WIN_CODE.HU then
            return 'sprite_hong'
        elseif CS.Utility.GetLogicAndValue(value, BJL_WIN_CODE.HE) == BJL_WIN_CODE.HE then
            return 'sprite_lv'
        else
            return 'sprite_lv'
        end
    else
        if CS.Utility.GetLogicAndValue(value, WIN_CODE.LONG) == WIN_CODE.LONG then
            return 'sprite_hong'
        elseif CS.Utility.GetLogicAndValue(value, WIN_CODE.HU) == WIN_CODE.HU then
            return 'sprite_lan'
        elseif CS.Utility.GetLogicAndValue(value, WIN_CODE.HE) == WIN_CODE.HE then
            return 'sprite_lv'
        else
            return 'sprite_lv'
        end
    end
end

-- 获取更新的值
function GetTrend2UpdateValue(value)
    if CS.Utility.GetLogicAndValue(value, WIN_CODE.LONG) == WIN_CODE.LONG then
        return WIN_CODE.LONG
    elseif CS.Utility.GetLogicAndValue(value, WIN_CODE.HU) == WIN_CODE.HU then
        return WIN_CODE.HU
    else
        return WIN_CODE.HE
    end
end