

local mHBRoomTable = { }
local mHBRoomTable2 = { }

-- 当前房间列表类型
local NowRoomType = 0

-- 当前查看组局厅房间页面
local mRoomPageCurrent = 1
local mRoomPageMax = 1
local mRoomOnePageNumber = 4
-- 自动刷新组局房间列表CD
local mAutoRefreshRoomListCD = 60
local mAutoRefreshRoomListPassTime = 0
local mIsAutoRefreshRoomList = false

--火爆特效(小) TUDOU
local particleEffect_Hot_Small;
-- 火爆特效父节点
local particleEffect_Hot_SmallPrint = {}

-- 房间按钮
local RoomObjectTable = {}
local RoomImageTable = {}
local RoomNameTable1 ={}
local RoomNameTable2 ={}
local RoomName3 = nil
local RoomInfoObjectTable ={}
local RoomInfoTextTable = {}
local DiFenObjectTable = {}
local DiFenTextTable = {}
local RoomButtonTable = {}
local RoomButtonSizeTable = {}
local FluentTable = {}
local HotTable = {}
local RoomTextObject = {}
-- 房间列表名字
local TileNameTable = {}
-- 四人间房间位置
local FourPositionSchemeTable = {}
-- 三人间房间位置
local ThreePositionSchemeTable = {}
-- 二人间房间位置
local TwoPositionSchemeTable = {}

-- 房间按钮
local RoomObjectTable = {}
-- 房间玩家数量文本
local RoomPlayerNumberText = {}
-- 房间Hot
local RoomHotTable = {}
-- 房间Fluent
local RoomFluentTable = {}
-- 房间维护
local RoomMaintainTable = {}

-- 房间玩状态
local RoomType = 
{
    [1] = 0,        -- 未选择
    [2] = 1,        -- 敬请期待
    [3] = 2,        -- 上架
    [4] = 3,        -- 下架
    [5] = 4,        -- 无本档次
}

-- 房间标签状态
local RoomLable = 
{
    [1] = 0,        -- 未选择
    [2] = 1,        -- 无
    [3] = 2,        -- 流畅
    [4] = 3,        -- 火爆
    [5] = 4,        -- 无本场次
    [6] = 5,        -- 维护
}

-- 房间类型索引
--[[local RoomTypeIndex =
{
     -- 焖鸡厅       五人房
     [2] = 8,
     -- 牛牛匹配     六人房
     [5] = 9,
     -- 红包接龙     匹配场
     [7] = 10,
     -- 推筒子匹配
     [9] = 11,
     --幸运转盘
     [11] = 7,
     --宝马奔驰
     [12] = 6,
     -- 时时彩
     [13] = 5,
     -- 匹配跑的快
     [14] = 13,
}--]]

-- 服务器玩法排序
local SeverGameType = 
{
    [7] = 9,
    [9] = 10,
    [14] = 13,

}

-- 上一次刷新按钮点击时间
local ClickTime=os.time()

-- 房间类型名字索引
local GameTypeIndex =
{
    [ROOM_TYPE.MenJi] = 1,
    [ROOM_TYPE.PiPeiNN] = 2,
    [ROOM_TYPE.PPHongBao] = 3,
    [ROOM_TYPE.PiPeiTTZ] = 4,
    [ROOM_TYPE.LuckyWheel] = 5,
    [ROOM_TYPE.BMWBENZ] = 6,
    [ROOM_TYPE.PiPeiPDK] = 7,
}

-- 处理页面刷新
function HandleRefreshRoomInfo()
    NowRoomType = GameData.RoomInfo.RoomList_Type
    RoomListIsOpen(NowRoomType)
    TrySend_CS_NNRoom_RoomList(false)
    RefreshHongBaoRoomOnlineCount()
    RefreshHongBaoRoomBaseInfo()
    mIsAutoRefreshRoomList = true
end

-- 尝试请求组局厅房间列表
function TrySend_CS_NNRoom_RoomList(autoParam)

    print("*****Room List Auto refresh:", autoParam)
    if NowRoomType == ROOM_TYPE.LuckyWheel then
        mRoomOnePageNumber=7
    else
        mRoomOnePageNumber=4
    end
    if NowRoomType == ROOM_TYPE.MenJi then
        NetMsgHandler.Send_CS_JH_ZuJuRoomList()
        NetMsgHandler.Send_CS_JH_MenJiRoomOnlineCount(1, 2, 3, 4)
    elseif NowRoomType == ROOM_TYPE.PiPeiNN then
        NetMsgHandler.Send_CS_NNRoom_RoomList()
        Send_CS_NNPP_Room_OnLine()
    elseif NowRoomType == ROOM_TYPE.PPHongBao then
        NetMsgHandler.Send_CS_HB_Room_List()
        NetMsgHandler.Send_CS_PP_HongBaoRoomOnlineCount(1, 2, 3, 4)
    elseif NowRoomType == ROOM_TYPE.PiPeiTTZ then
        NetMsgHandler.Send_CS_TTZRoom_RoomList()
        NetMsgHandler.Send_CS_TTZPP_Room_OnLine()
    elseif NowRoomType == ROOM_TYPE.LuckyWheel then
        NetMsgHandler.Send_CS_JH_XYZPRoomList()
    elseif NowRoomType == ROOM_TYPE.BMWBENZ then
        NetMsgHandler.Send_CS_JH_BMBCRoomList()
    elseif NowRoomType == ROOM_TYPE.PiPeiPDK then
        NetMsgHandler.Send_CS_PDKPP_Room_OnLine() 
    end
    
    if autoParam == false then
        mAutoRefreshRoomListPassTime = 0
    end
end

-- 房间列表刷新
function HandleNotifyNNRoomInfoEvent()

end

-- 按钮回调call绑定
function ButtonAddListener()
    
    this.transform:Find('TypeContent_1/Viewport/Content/Image_1'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(1) end)
    this.transform:Find('TypeContent_1/Viewport/Content/Image_2'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(2) end)
    this.transform:Find('TypeContent_1/Viewport/Content/Image_3'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(3) end)
    this.transform:Find('TypeContent_1/Viewport/Content/Image_4'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(4) end)
    this.transform:Find('TypeContent_1/Viewport/Content/Image_5'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(5) end)
    this.transform:Find('TypeContent_1/Viewport/Content/Image_6'):GetComponent("Button").onClick:AddListener( function() EnterNPiPeiRoom(6) end)
end

function RoomListIsOpen(index)
    ClickTime=os.time()
    
    local showIndex= GameTypeIndex[index]
    for num = 1,7 do
        if num == showIndex then
            GameObjectSetActive(TileNameTable[num],true)
        else
            GameObjectSetActive(TileNameTable[num],false)
        end
    end
    
    if NowRoomType ~= ROOM_TYPE.LuckyWheel and NowRoomType ~= ROOM_TYPE.BMWBENZ then
        for Index=1, 4, 1 do
            RoomObjectTable[Index].transform.localPosition = CS.UnityEngine.Vector3(FourPositionSchemeTable[Index].x, FourPositionSchemeTable[Index].y, FourPositionSchemeTable[Index].z)
            GameObjectSetActive(RoomObjectTable[Index],true)
        end
    end
    if NowRoomType == ROOM_TYPE.LuckyWheel then
        GameObjectSetActive(RoomObjectTable[4],false)
        for Index = 1, 3 ,1 do
            RoomObjectTable[Index].transform.localPosition = CS.UnityEngine.Vector3(ThreePositionSchemeTable[Index].x, ThreePositionSchemeTable[Index].y, ThreePositionSchemeTable[Index].z)
            RoomObjectTable[Index]:SetActive(true)
        end
    end
    if NowRoomType == ROOM_TYPE.BMWBENZ then
        GameObjectSetActive(RoomObjectTable[3],false)
        GameObjectSetActive(RoomObjectTable[4],false)
        for Index = 1, 2 ,1 do
            RoomObjectTable[Index].transform.localPosition = CS.UnityEngine.Vector3(TwoPositionSchemeTable[Index].x, TwoPositionSchemeTable[Index].y, TwoPositionSchemeTable[Index].z)
            RoomObjectTable[Index]:SetActive(true)
        end
    end
    
end

-- 刷新匹配房间基础数据
function RefreshHongBaoRoomBaseInfo()
    GameObjectSetActive(RoomName3,false)
    
    if NowRoomType ~= ROOM_TYPE.LuckyWheel or NowRoomType ~= ROOM_TYPE.BMWBENZ then
        for index = 1, 4, 1 do
            GameObjectSetActive(RoomNameTable1[index],true)
            GameObjectSetActive(RoomNameTable2[index],false)
            GameObjectSetActive(RoomInfoObjectTable[index],true)
            GameObjectSetActive(DiFenObjectTable[index],true)
            local config = nil
            if NowRoomType == ROOM_TYPE.MenJi then
                --config = GameConfig.GetPublicRoomConfigDataByTypeLevel(1,index)
                config = GameData.RoleInfo.RoomConfiguration[index]
            elseif NowRoomType == ROOM_TYPE.PiPeiNN then
                --config = GameConfig.GetPublicRoomConfigDataByTypeLevel(4,index)
                config = GameData.RoleInfo.RoomConfiguration[index]
            elseif NowRoomType == ROOM_TYPE.PPHongBao then
                --config = GameConfig.HongbaoroomConfigDataByTypeLevel(7,index)
                config = GameData.RoleInfo.RoomConfiguration[index]
            elseif NowRoomType == ROOM_TYPE.PiPeiTTZ then
                --config = GameConfig.GetPublicRoomConfigDataByTypeLevel(9,index)
                config = GameData.RoleInfo.RoomConfiguration[index]
            elseif NowRoomType == ROOM_TYPE.PiPeiPDK then
                --config = GameConfig.GetPublicRoomConfigDataByTypeLevel(11,index)
                config = GameData.RoleInfo.RoomConfiguration[index]
            end
            local childTransform = RoomObjectTable[index]
            if config ~= nil and childTransform ~= nil then
                if NowRoomType == ROOM_TYPE.PPHongBao then
                    --PPRoomDiZhuZhunRuDisplay(index,childTransform,config.Antes,config.EnterLimit)
                    PPRoomDiZhuZhunRuDisplay(index,childTransform,config.BetValueMin,config.EnterGoldMin)
                else
                    --PPRoomDiZhuZhunRuDisplay(index,childTransform,config.LowLimit,config.EnterLimit)
                    PPRoomDiZhuZhunRuDisplay(index,childTransform,config.BetValueMin,config.EnterGoldMin)
                end
            end
        end
        local mNowRoomType = RoomTypeIndex[NowRoomType]
        FivePeopleRoomDisplay(mNowRoomType)
    end
    if NowRoomType == ROOM_TYPE.LuckyWheel then
        local config = nil
        for Index=1,3,1 do
            local LowLimit = 0
            local EnterLimit = 0
            local EnterLimitMax = 0
            local Count = Index*8
            --LowLimit = data.TurnTableConfig[Count].Gold
            --EnterLimit = data.TurnTableConfig[Count].EnterLimit[1]
            LowLimit = GameData.RoleInfo.RoomConfiguration[Index].BetValueMin
            EnterLimit = GameData.RoleInfo.RoomConfiguration[Index].EnterGoldMin
            CZGRoomDisplay(Index,LowLimit,EnterLimit,NowRoomType)
        end
        local mNowRoomType = RoomTypeIndex[NowRoomType]
        ThreePeopleRoomDisplayLable(mNowRoomType)
    end

    if NowRoomType == ROOM_TYPE.BMWBENZ then
        local config = nil
        for Index=1,2,1 do
            local LowLimit = 0
            local EnterLimit = 0
            local EnterLimitMax = 0
            --LowLimit = data.BenchibaomaConfig.BET_LIMIT[Index]
            --EnterLimit = data.BenchibaomaConfig.ENTER_LIMIT[Index][1]
            --EnterLimitMax = data.BenchibaomaConfig.ENTER_LIMIT[Index][2]
            LowLimit = GameData.RoleInfo.RoomConfiguration[Index].BetValueMin
            EnterLimit = GameData.RoleInfo.RoomConfiguration[Index].EnterGoldMin
            twoRoomCZGDisplay(Index,LowLimit,EnterLimit,NowRoomType)
        end
        local mNowRoomType = RoomTypeIndex[NowRoomType]
        TwoPeopleRoomDisplayLable(mNowRoomType)
    end
end

-- 两个匹配房间初中高显示
function  twoRoomCZGDisplay(Index,Antes,EnterLimit,mNowRoomType)
    GameObjectSetActive(RoomNameTable1[Index],false)
    GameObjectSetActive(RoomNameTable2[Index],true)
    GameObjectSetActive(RoomInfoObjectTable[Index],true)
    GameObjectSetActive(DiFenObjectTable[Index],true)
    RoomInfoTextTable[Index].text = lua_NumberToStyle1String(EnterLimit)
    DiFenTextTable[Index].text = lua_NumberToStyle1String(Antes)
end

-- 三个匹配房间初中高显示
function CZGRoomDisplay(Index,Antes,EnterLimit,mNowRoomType)
    GameObjectSetActive(RoomNameTable1[Index],false)
    GameObjectSetActive(RoomNameTable2[Index],true)
    GameObjectSetActive(RoomInfoObjectTable[Index],true)
    GameObjectSetActive(DiFenObjectTable[Index],true)
    RoomInfoTextTable[Index].text = lua_NumberToStyle1String(EnterLimit)
    DiFenTextTable[Index].text = lua_NumberToStyle1String(Antes)
end

-- 匹配房间底注和准入显示
function PPRoomDiZhuZhunRuDisplay(Index,childTransform,LowLimit,EnterLimit)
    RoomInfoTextTable[Index].text = lua_NumberToStyle1String(EnterLimit)
    DiFenTextTable[Index].text = lua_NumberToStyle1String(LowLimit)
end
--TUDOU
function InstinateObjects(index)
    lua_Transform_ClearChildren(particleEffect_Hot_SmallPrint[index].transform, true);
    local particleObj = CS.UnityEngine.Object.Instantiate(particleEffect_Hot_Small);
    CS.Utility.ReSetTransform(particleObj.transform, particleEffect_Hot_SmallPrint[index].transform);
    particleObj.gameObject:SetActive(true);
end

-- 两人匹配房间标签
function TwoPeopleRoomDisplayLable(mNowRoomType)
    for Index = 1,4,1 do
        if this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Canvas/Hot/huobao_icon_small(Clone)')~=nil then
            local DestoryObject = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Canvas/Hot/huobao_icon_small(Clone)').gameObject
            CS.UnityEngine.Object.Destroy(DestoryObject)
        end
        GameObjectSetActive(RoomHotTable[Index],false)
        GameObjectSetActive(RoomMaintainTable[Index],false)
        GameObjectSetActive(RoomFluentTable[Index],false)
        GameObjectSetActive(RoomTextObject[Index],false)
        GameObjectSetActive(RoomNameTable2[Index],false)
    end
    GameObjectSetActive(RoomName3,false)
    if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[3] then
            GameObjectSetActive(RoomFluentTable[1],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[4] then
            GameObjectSetActive(RoomHotTable[1],true)
            InstinateObjects(1);
        elseif GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[1],true)
        end
        RoomButtonTable[1].enabled = true
        RoomButtonSizeTable[1].enabled = true
        RoomButtonTable[1].interactable = true
        RoomImageTable[1].color = CS.UnityEngine.Color.white
        GameObjectSetActive(RoomNameTable2[1],true)
        GameObjectSetActive(DiFenObjectTable[1],true)
    else
        RoomButtonTable[1].enabled = false
        RoomButtonSizeTable[1].enabled = false
        RoomButtonTable[1].interactable = false
        RoomImageTable[1].color = CS.UnityEngine.Color.grey
        GameObjectSetActive(RoomTextObject[1],true)
        GameObjectSetActive(RoomInfoObjectTable[1],false)
        GameObjectSetActive(DiFenObjectTable[1],false)
    end
    
    if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[3] then
            GameObjectSetActive(RoomFluentTable[2],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[4] then
            GameObjectSetActive(RoomHotTable[2],true)
            InstinateObjects(2);
        elseif GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[2],true)
        end
        RoomButtonTable[2].enabled = true
        RoomButtonSizeTable[2].enabled = true
        RoomButtonTable[2].interactable = true
        RoomImageTable[2].color = CS.UnityEngine.Color.white
        GameObjectSetActive(RoomName3,true)
        GameObjectSetActive(DiFenObjectTable[2],true)
    else
        RoomButtonTable[2].enabled = false
        RoomButtonSizeTable[2].enabled = false
        RoomButtonTable[2].interactable = false
        RoomImageTable[2].color = CS.UnityEngine.Color.grey
        GameObjectSetActive(RoomTextObject[2],true)
        RoomPlayerNumberText[2].text=""
        GameObjectSetActive(RoomInfoObjectTable[2],false)
        GameObjectSetActive(DiFenObjectTable[2],false)
    end
end

-- 三人匹配房间标签
function ThreePeopleRoomDisplayLable(mNowRoomType)
    for Index = 1,4,1 do
        if this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Canvas/Hot/huobao_icon_small(Clone)')~=nil then
            local DestoryObject = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Canvas/Hot/huobao_icon_small(Clone)').gameObject
            CS.UnityEngine.Object.Destroy(DestoryObject)
        end
        GameObjectSetActive(RoomFluentTable[Index],false)
        GameObjectSetActive(RoomHotTable[Index],false)
        GameObjectSetActive(RoomTextObject[Index],false)
        GameObjectSetActive(RoomNameTable2[Index],false)
        GameObjectSetActive(RoomMaintainTable[Index],false)
    end
    GameObjectSetActive(RoomName3,false)
    if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[3] then
            GameObjectSetActive(RoomFluentTable[1],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[4] then
            GameObjectSetActive(RoomHotTable[1],true)
            InstinateObjects(1);
        elseif GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[1],true)
        end
        RoomButtonTable[1].enabled = true
        RoomButtonSizeTable[1].enabled = true
        RoomButtonTable[1].interactable = true
        RoomImageTable[1].color = CS.UnityEngine.Color.white
        GameObjectSetActive(RoomNameTable2[1],true)
        GameObjectSetActive(DiFenObjectTable[1],true)
    else
        RoomButtonTable[1].enabled = false
        RoomButtonSizeTable[1].enabled = false
        RoomButtonTable[1].interactable = false
        RoomImageTable[1].color = CS.UnityEngine.Color.grey
        GameObjectSetActive(RoomTextObject[1],true)
        GameObjectSetActive(RoomInfoObjectTable[1],false)
        GameObjectSetActive(DiFenObjectTable[1],false)
    end
    if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[3] then
            GameObjectSetActive(RoomFluentTable[2],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[4] then
            GameObjectSetActive(RoomHotTable[1],true)
            InstinateObjects(2);
        elseif GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[2],true)
        end
        RoomButtonTable[2].enabled = true
        RoomButtonSizeTable[2].enabled = true
        RoomButtonTable[2].interactable = true
        RoomImageTable[2].color = CS.UnityEngine.Color.white
        GameObjectSetActive(RoomNameTable2[2],true)
        GameObjectSetActive(DiFenObjectTable[2],true)
    else
        RoomButtonTable[2].enabled = false
        RoomButtonSizeTable[2].enabled = false
        RoomButtonTable[2].interactable = false
        RoomImageTable[2].color = CS.UnityEngine.Color.grey
        GameObjectSetActive(RoomTextObject[2],true)
        RoomPlayerNumberText[2].text=""
        GameObjectSetActive(RoomInfoObjectTable[2],false)
        GameObjectSetActive(DiFenObjectTable[2],false)
    end
    if GameData.GameTypeListInfo[mNowRoomType].SeniorRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].SeniorRoomLabel == RoomLable[3] then
            GameObjectSetActive(RoomFluentTable[3],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].SeniorRoomLabel == RoomLable[4] then
            GameObjectSetActive(RoomHotTable[3],true)
            InstinateObjects(2);
        elseif GameData.GameTypeListInfo[mNowRoomType].SeniorRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[3],true)
        end
        RoomButtonTable[3].enabled = true
        RoomButtonSizeTable[3].enabled = true
        RoomButtonTable[3].interactable = true
        RoomImageTable[3].color = CS.UnityEngine.Color.white
        GameObjectSetActive(RoomNameTable2[3],true)
        GameObjectSetActive(DiFenObjectTable[3],true)
    else
        RoomButtonTable[3].enabled = false
        RoomButtonSizeTable[3].enabled = false
        RoomButtonTable[3].interactable = false
        RoomImageTable[3].color = CS.UnityEngine.Color.grey
        GameObjectSetActive(RoomTextObject[3],true)
        RoomPlayerNumberText[3].text=""
        GameObjectSetActive(RoomInfoObjectTable[3],false)
        GameObjectSetActive(DiFenObjectTable[3],false)
    end
end

-- 四人匹配房间标签
function FivePeopleRoomDisplay(mNowRoomType)
    for Index = 1,4,1 do
        if RoomObjectTable[Index].transform:Find('RoomInfo/PlayerNumber/Canvas/Hot/huobao_icon_small(Clone)')~=nil then
            local DestoryObject = RoomObjectTable[Index].transform:Find('RoomInfo/PlayerNumber/Canvas/Hot/huobao_icon_small(Clone)').gameObject
            CS.UnityEngine.Object.Destroy(DestoryObject)
        end
        GameObjectSetActive(FluentTable[Index],false)
        GameObjectSetActive(HotTable[Index],false)
        GameObjectSetActive(RoomTextObject[Index],false)
        GameObjectSetActive(RoomMaintainTable[Index],false)
    end
    if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[3] then
            GameObjectSetActive(FluentTable[1],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[4] then
            GameObjectSetActive(HotTable[1],true)
            InstinateObjects(1);
        elseif GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[1],true)
        end
        RoomButtonTable[1].interactable = true
        RoomButtonSizeTable[1].enabled = true
        RoomImageTable[1].color =CS.UnityEngine.Color.white
    else
        GameObjectSetActive(RoomTextObject[1],true)
        RoomPlayerNumberText[1].text=""
        DiFenTextTable.text = ""
        GameObjectSetActive(DiFenObjectTable[1],false)
        GameObjectSetActive(RoomInfoObjectTable[1],false)
        RoomButtonTable[1].interactable = false
        RoomButtonSizeTable[1].enabled = false
        RoomImageTable[1].color =CS.UnityEngine.Color.grey
    end
    if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[3] then
            GameObjectSetActive(RoomFluentTable[2],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[4] then
            GameObjectSetActive(RoomHotTable[2],true)
            InstinateObjects(2);
        elseif GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[2],true)
        end
        RoomButtonTable[2].interactable = true
        RoomButtonSizeTable[2].enabled = true
        RoomImageTable[2].color =CS.UnityEngine.Color.white
    else
        GameObjectSetActive(RoomTextObject[2],true)
        RoomPlayerNumberText[2].text=""
        DiFenTextTable.text = ""
        GameObjectSetActive(DiFenObjectTable[2],false)
        GameObjectSetActive(RoomInfoObjectTable[2],false)
        RoomButtonTable[2].interactable = false
        RoomButtonSizeTable[2].enabled = false
        RoomImageTable[2].color =CS.UnityEngine.Color.grey
    end
    if GameData.GameTypeListInfo[mNowRoomType].SeniorRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].SeniorRoomLabel == RoomLable[3] then
            GameObjectSetActive(RoomFluentTable[3],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].SeniorRoomLabel == RoomLable[4] then
            GameObjectSetActive(RoomHotTable[3],true)
            InstinateObjects(3);
        elseif GameData.GameTypeListInfo[mNowRoomType].SeniorRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[3],true)
        end
        RoomButtonTable[3].interactable = true
        RoomButtonSizeTable[3].enabled = true
        RoomImageTable[3].color =CS.UnityEngine.Color.white
    else
        GameObjectSetActive(RoomTextObject[3],true)
        RoomPlayerNumberText[3].text=""
        DiFenTextTable[3].text = ""
        GameObjectSetActive(DiFenObjectTable[3],false)
        GameObjectSetActive(RoomInfoObjectTable[3],false)
        RoomButtonTable[3].interactable = false
        RoomButtonSizeTable[3].enabled = false
        RoomImageTable[3].color =CS.UnityEngine.Color.grey
    end
    if GameData.GameTypeListInfo[mNowRoomType].TycoonRoomState == RoomType[3] then
        if GameData.GameTypeListInfo[mNowRoomType].TycoonRoomLabel == RoomLable[3] then
            GameObjectSetActive(RoomFluentTable[4],true)
        elseif GameData.GameTypeListInfo[mNowRoomType].TycoonRoomLabel == RoomLable[4] then
            GameObjectSetActive(RoomHotTable[4],true)
            InstinateObjects(4);
        elseif GameData.GameTypeListInfo[mNowRoomType].TycoonRoomLabel == RoomLable[6] then
            GameObjectSetActive(RoomMaintainTable[4],true)
        end
        RoomButtonTable[4].interactable = true
        RoomButtonSizeTable[4].enabled = true
        RoomImageTable[4].color =CS.UnityEngine.Color.white
    else
        GameObjectSetActive(RoomTextObject[4],true)
        RoomPlayerNumberText[4].text=""
        DiFenTextTable[4].text = ""
        GameObjectSetActive(DiFenObjectTable[4],false)
        GameObjectSetActive(RoomInfoObjectTable[4],false)
        RoomButtonTable[4].interactable = false
        RoomButtonSizeTable[4].enabled = false
        RoomImageTable[4].color =CS.UnityEngine.Color.grey
    end
    
end

-- 刷新匹配房间在线人数
function RefreshHongBaoRoomOnlineCount()
    local mNowRoomType = RoomTypeIndex[NowRoomType] 
    local  number=4
    if NowRoomType == ROOM_TYPE.LuckyWheel  then
        number=3
    end
    if NowRoomType == ROOM_TYPE.BMWBENZ then
        number = 2
    end
    for index = 1, number, 1 do
        local  _data  = nil
        if NowRoomType == ROOM_TYPE.MenJi then
            _data  = GameData.MJRoomOnlineCount[index]
        elseif NowRoomType == ROOM_TYPE.PiPeiNN then
            _data  = NNGameMgr.NNRoomPPOnline[index]
        elseif NowRoomType == ROOM_TYPE.PPHongBao then 
            _data  = GameData.PPHBRoomOnlineCount[index]
        elseif NowRoomType == ROOM_TYPE.PiPeiTTZ then 
            _data  = TTZGameMgr.TTZRoomPPOnline[index]
        elseif NowRoomType == ROOM_TYPE.LuckyWheel then 
            --幸运转盘
            _data  = GameData.OnlineCount[index]
        elseif NowRoomType == ROOM_TYPE.BMWBENZ then 
            --宝马奔驰
            _data  = GameData.BMBCOnlineCount[index]
        elseif NowRoomType == ROOM_TYPE.PiPeiPDK then
            _data = PDKGameMgr.PDKRoomPPOnline[index]
        end

        local childTransform = RoomObjectTable[index]
        if _data ~= nil and childTransform ~= nil then
            if NowRoomType == ROOM_TYPE.LuckyWheel then
                RoomPlayerNumberText[index].text = tostring(_data.OnlineCount)
                if index == 1 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomState ~= 2 then
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                elseif index == 2 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomState ~= 2 then
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                elseif index == 3 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].SeniorRoomState ~= 2 then
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                end
            elseif NowRoomType == ROOM_TYPE.BMWBENZ then
                RoomPlayerNumberText[index].text = tostring(_data.OnlineCount)
                if index == 1 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomState ~= 2 then
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                elseif index == 2 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomState ~= 2 then
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                end
            elseif NowRoomType ~= ROOM_TYPE.LuckyWheel and NowRoomType ~= ROOM_TYPE.BMWBENZ then
                RoomPlayerNumberText[index].text = tostring(_data.OnlineCount)
                
                if index == 1 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].PrimaryRoomState ~= 2 then
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                elseif index == 2 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].IntermediateRoomState ~= 2 then
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                elseif index == 3 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].SeniorRoomState ~= 2 then 
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                elseif index == 4 then
                    if GameData.GameTypeListInfo[mNowRoomType] ~= nil  then
                        if GameData.GameTypeListInfo[mNowRoomType].TycoonRoomState ~= 2 then
                            RoomPlayerNumberText[index].text = ""
                        end
                    end
                end
            end
        else
            
            --刷新在线人数
            RoomPlayerNumberText[index].text = tostring(0)
        end

    end
end

function EnterNPiPeiRoom(subTypeParam)
    if NowRoomType > ROOM_TYPE.BJLRoom then
        CS.BubblePrompt.Show("敬请期待", "HallUI")
        return
    end
    local _canEnter = true
    if subTypeParam > 0 then
        local _config = nil
        local tGoldCount =  GameConfig.GetFormatColdNumber(GameData.RoleInfo.GoldCount)
        if NowRoomType == ROOM_TYPE.MenJi then
            --_config = GameConfig.GetPublicRoomConfigDataByTypeLevel(1,subTypeParam)
            _config = GameData.RoleInfo.RoomConfiguration[subTypeParam]
        elseif NowRoomType == ROOM_TYPE.PiPeiNN then
            --_config = GameConfig.GetPublicRoomConfigDataByTypeLevel(4,subTypeParam)
            _config = GameData.RoleInfo.RoomConfiguration[subTypeParam]
        elseif NowRoomType == ROOM_TYPE.PPHongBao then
            --_config = GameConfig.HongbaoroomConfigDataByTypeLevel(7,subTypeParam)
            _config = GameData.RoleInfo.RoomConfiguration[subTypeParam]
        elseif NowRoomType == ROOM_TYPE.PiPeiTTZ then
            --_config = GameConfig.GetPublicRoomConfigDataByTypeLevel(9,subTypeParam)
            _config = GameData.RoleInfo.RoomConfiguration[subTypeParam]
        elseif NowRoomType == ROOM_TYPE.PiPeiPDK then
            --_config = GameConfig.GetPublicRoomConfigDataByTypeLevel(11,subTypeParam)
            _config = GameData.RoleInfo.RoomConfiguration[subTypeParam]
        elseif NowRoomType == ROOM_TYPE.BMWBENZ then
            --local tData = data.BenchibaomaConfig.ENTER_LIMIT[subTypeParam]
            _config = GameData.RoleInfo.RoomConfiguration[subTypeParam]
            --_config = {}
            --_config.EnterLimit = tData[1]
            --_config.OutLimit = tData[2]
            --_config.Name = ""
        elseif NowRoomType == ROOM_TYPE.LuckyWheel then
            --_config = GameConfig.GetPublicRoomConfigDataByTypeLevel(13,subTypeParam)
            _config = GameData.RoleInfo.RoomConfiguration[subTypeParam]
        end
        if _config ~= nil then
            if tGoldCount < _config.EnterGoldMin then
                _canEnter = false
                local boxData = CS.MessageBoxData()
                boxData.Title = "温馨提示"
                boxData.Content = string.format(data.GetString("JH_Enter_MJRoom_Tips"),lua_NumberToStyle1String(_config.EnterGoldMin),_config.RoomName)
                boxData.Style = 1
                boxData.OKButtonName = "确定"
                Exit_MoneyNotEnough = true;
                boxData.LuaCallBack = RoomList_GoldNotEnoughConfirmOnClick
                CS.MessageBoxUI.Show(boxData)
            elseif tGoldCount > _config.EnterGoldMax then
                _canEnter = false
                local desc = string.format(data.GetString("JH_Enter_MJRoom_Tips2"),lua_NumberToStyle1String(_config.EnterGoldMax))
                CS.BubblePrompt.Show(desc ,"HallUI")
            end
        else
            
        end
    end
    if _canEnter then
        PlaySoundEffect("2")
        if NowRoomType == ROOM_TYPE.MenJi then
            NetMsgHandler.Send_CS_JH_Enter_Room2(subTypeParam,0)
        elseif NowRoomType == ROOM_TYPE.PiPeiNN then
            Send_CS_NNPP_Enter_Room(subTypeParam,0)
        elseif NowRoomType == ROOM_TYPE.PPHongBao then
            subTypeParam=subTypeParam+6
            NetMsgHandler.Send_CS_HB_Enter_Room1(0,subTypeParam)
        elseif NowRoomType == ROOM_TYPE.PiPeiTTZ then
            NetMsgHandler.Send_CS_TTZ_ZUJU_ENTER_ROOM(0,subTypeParam)
        elseif NowRoomType == ROOM_TYPE.LuckyWheel then
            --请求转盘房间等级
            NetMsgHandler.Send_CS_Daily_Wheel_Info(subTypeParam)
        elseif NowRoomType == ROOM_TYPE.BMWBENZ then
            NetMsgHandler.Send_CS_CarInfo(subTypeParam)
        elseif NowRoomType == ROOM_TYPE.PiPeiPDK then
            --CS.WindowManager.Instance:OpenWindow("PDKGameUI")
            --CS.BubblePrompt.Show("敬请期待", "HallUI")
            --subTypeParam=math.ceil(subTypeParam/2) 
            NetMsgHandler.Send_CS_PDKPP_Enter_Room(subTypeParam,0)
        end
    end
end

    -- 金币不足提示按钮操作call
function RoomList_GoldNotEnoughConfirmOnClick( resultType )
    if resultType == 1 then
        GameData.Exit_MoneyNotEnough = true;
        GameConfig.OpenStoreUI()
    end
end

-- 音效播放
function PlaySoundEffect(musicid)
    MusicMgr:PlaySoundEffect(tostring( musicid ))
end

-- fixed 大厅停留期间 切出去 切回来 大厅房间列表未刷新
-- 大厅刷新房间列表
function OnNotifyHallUpdateEvent()
    if this.gameObject.activeSelf == true then
        TrySend_CS_NNRoom_RoomList(false)
    end
end

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    
    NowRoomType = GameData.RoomInfo.RoomList_Type
    GetAllObjects()
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHongBaoRoomListUpdateEvent, HandleNotifyNNRoomInfoEvent)--更新房间列表
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHongBaoRoomOnlineEvent, RefreshHongBaoRoomOnlineCount)
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyHallUpdateEvent, OnNotifyHallUpdateEvent)
end

function GetAllObjects()
    RoomName3 = this.transform:Find('TypeContent_1/Viewport/Content/Image_2/Name3').gameObject
    particleEffect_Hot_Small = this.transform:Find("huobao_icon_small");
    for Index = 1,6 , 1 do
        RoomObjectTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index).gameObject
        RoomImageTable[Index] = RoomObjectTable[Index].transform:GetComponent('Image')
        RoomNameTable1[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/Name').gameObject
        RoomNameTable2[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/Name2').gameObject
        RoomInfoObjectTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo').gameObject
        DiFenObjectTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/DiFen').gameObject
        RoomInfoTextTable[Index] = RoomInfoObjectTable[Index].transform:Find('Gold/Text'):GetComponent('Text')
        DiFenTextTable[Index] = DiFenObjectTable[Index].transform:Find('Text'):GetComponent('Text')
        FluentTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Fluent').gameObject
        HotTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Canvas/Hot').gameObject
        RoomTextObject[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/Text').gameObject
        RoomButtonTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index):GetComponent("Button")
        RoomButtonSizeTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index):GetComponent("ButtonSizeChange")
        RoomPlayerNumberText[Index] = RoomObjectTable[Index].transform:Find('RoomInfo/PlayerNumber/Text'):GetComponent('Text')
        particleEffect_Hot_SmallPrint[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Canvas/Hot')
        RoomHotTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Canvas/Hot').gameObject
        RoomFluentTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Fluent').gameObject
        RoomMaintainTable[Index] = this.transform:Find('TypeContent_1/Viewport/Content/Image_'..Index..'/RoomInfo/PlayerNumber/Maintain').gameObject
    end
    for num=1,7 do
        TileNameTable[num] = this.transform:Find('TileName_'..num).gameObject
    end
    for Index= 1,4,1 do
        FourPositionSchemeTable[Index] = this.transform:Find('TypeContent_1/Viewport/PositionScheme2/position'..Index).gameObject.transform.localPosition
    end
    for Index = 1, 3, 1 do
        ThreePositionSchemeTable[Index] = this.transform:Find('TypeContent_1/Viewport/PositionScheme3/position'..Index).gameObject.transform.localPosition
    end
    for Index = 1, 2, 1 do
        TwoPositionSchemeTable[Index] = this.transform:Find('TypeContent_1/Viewport/PositionScheme4/position'..Index).gameObject.transform.localPosition
    end
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    ButtonAddListener()
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHongBaoRoomListUpdateEvent, HandleNotifyNNRoomInfoEvent)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHongBaoRoomOnlineEvent, RefreshHongBaoRoomOnlineCount)
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyHallUpdateEvent, OnNotifyHallUpdateEvent)
end