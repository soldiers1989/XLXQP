

local mTime = CS.UnityEngine.Time
-- 当前房间信息数据
local mRoomData = { }
-- 主角数据
local mMasterData = {}
-- UI组件根节点
local mMyTransform = nil

local mReturnGameObject = nil                   -- 返回菜单组件
local mExitButtonScript = nil                   -- 退出房间按钮组件Script
local mGameTimeText = nil                       -- 游戏进行时间文本
local mGaldValueText = nil                      -- 金币值文本
local mVictoryInterface = nil                   -- 胜利面板
local mVictoryText = nil                       -- 胜利金币
local mGoldValue = 0
-- 是否点击过扑克牌
local IsClickPoker=false

-- 完成数量
local CompleteValue = 0

-- 完成的扑克牌
local CompletePokers = {}

-- 空白组件
local BlankButtonObject = {}

-- 完成的扑克牌位置
local CompletePokerPosition={110.1,1,-108,-214.7,-321.5,-429.3,-534.5,-642.3,-750.2,-856}

-- 添加第几个牌堆
local AddPokerTable=0

-- 牌堆
local HeapPokersObject={}

-- 玩家移动扑克牌记录
local MoveRecord = 
                    {
                        InitialPosition = 0,
                        ChangePosition = 0,
                        MovePokerInfo={},
                    }

-- 游戏进行时间
local GameTime=0

local PokerObjectTable1={}
local PokerObjectTable2={}
local PokerObjectTable3={}
local PokerObjectTable4={}
local PokerObjectTable5={}
local PokerObjectTable6={}
local PokerObjectTable7={}
local PokerObjectTable8={}
local PokerObjectTable9={}
local PokerObjectTable10={}

local PokerImageTable1={}
local PokerImageTable2={}
local PokerImageTable3={}
local PokerImageTable4={}
local PokerImageTable5={}
local PokerImageTable6={}
local PokerImageTable7={}
local PokerImageTable8={}
local PokerImageTable9={}
local PokerImageTable10={}

-- 背面扑克牌数量
local BankPokerNumber={6,6,6,6,5,5,5,5,5,5}

-- Unity MonoBehavior Awake 时调用此方法
function Awake()
    mMyTransform = this.transform
    InitUIElement()
    AddButtonHandlers()
    mGoldValue = GameData.RoleInfo.GoldCount 
    mGaldValueText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(mGoldValue))
end

-- 对应脚本的界面打开（Unity OnEnable）方法
function WindowOpened( )
    CS.EventDispatcher.Instance:AddEventListener(EventDefine.NotifyGoldUpdateEvent, onNotifyGoldUpdateEvent2)
end

-- 对应脚本的界面关闭（Unity OnDisable）方法
function WindowClosed()
    CS.EventDispatcher.Instance:RemoveEventListener(EventDefine.NotifyGoldUpdateEvent, onNotifyGoldUpdateEvent2)
end

-- Unity MonoBehavior Start 时调用此方法
function Start()
    CS.MatchLoadingUI.Hide()
    DisruptGivePokerTable()
    InitializationPokerDiplay()
    
end

-- Unity MonoBehavior Update 时调用此方法
function Update()
    UpdateGameTime()
end

-- Unity MonoBehavior OnDestroy 时调用此方法
function OnDestroy()
    lua_Call_GC()
end



function InitUIElement()
    mReturnGameObject = mMyTransform:Find('Canvas/MenuButton/ReturnButton1').gameObject
    mMyTransform:Find('Canvas/MenuButton/ReturnButton1/MaskButton').gameObject:SetActive(true)
    mExitButtonScript = mMyTransform:Find('Canvas/MenuButton/ReturnButton1/RenounceButton'):GetComponent('Button')
    mGameTimeText = mMyTransform:Find('Canvas/BottomInfo/back/Time'):GetComponent('Text')
    mGaldValueText = mMyTransform:Find('Canvas/BottomInfo/back/GoldInfo/Gold/Valur'):GetComponent('Text')
    mVictoryInterface = mMyTransform:Find('Canvas/VictoryInterface').gameObject
    mVictoryText = mVictoryInterface.transform:Find('Image/Gold/Value'):GetComponent('Text')

    for Index=1,30,1 do
        PokerObjectTable1[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable1/Poker'..Index).gameObject
        PokerObjectTable2[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable2/Poker'..Index).gameObject
        PokerObjectTable3[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable3/Poker'..Index).gameObject
        PokerObjectTable4[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable4/Poker'..Index).gameObject
        PokerObjectTable5[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable5/Poker'..Index).gameObject
        PokerObjectTable6[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable6/Poker'..Index).gameObject
        PokerObjectTable7[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable7/Poker'..Index).gameObject
        PokerObjectTable8[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable8/Poker'..Index).gameObject
        PokerObjectTable9[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable9/Poker'..Index).gameObject
        PokerObjectTable10[Index] = mMyTransform:Find('Canvas/Pokers/PokerTable10/Poker'..Index).gameObject
        PokerImageTable1[Index] = PokerObjectTable1[Index].transform:GetComponent('Image')
        PokerImageTable2[Index] = PokerObjectTable2[Index].transform:GetComponent('Image')
        PokerImageTable3[Index] = PokerObjectTable3[Index].transform:GetComponent('Image')
        PokerImageTable4[Index] = PokerObjectTable4[Index].transform:GetComponent('Image')
        PokerImageTable5[Index] = PokerObjectTable5[Index].transform:GetComponent('Image')
        PokerImageTable6[Index] = PokerObjectTable6[Index].transform:GetComponent('Image')
        PokerImageTable7[Index] = PokerObjectTable7[Index].transform:GetComponent('Image')
        PokerImageTable8[Index] = PokerObjectTable8[Index].transform:GetComponent('Image')
        PokerImageTable9[Index] = PokerObjectTable9[Index].transform:GetComponent('Image')
        PokerImageTable10[Index] = PokerObjectTable10[Index].transform:GetComponent('Image')
    end

    for Index=1,10,1 do
        BlankButtonObject[Index]=mMyTransform:Find('Canvas/Pokers/PokerTable'..Index..'/GameObject').gameObject
    end

    for Index=1,8,1 do
        CompletePokers[Index]=mMyTransform:Find('Canvas/CompletePoker/Bank/PokerTable1/Poker'..Index).gameObject
    end

    for Index=1,5,1 do
        HeapPokersObject[Index]=mMyTransform:Find('Canvas/CardHeap/GameObject/Image'..Index).gameObject
    end

    mReturnGameObject:SetActive(false)
end

function AddButtonHandlers()
    mMyTransform:Find('Canvas/MenuButton'):GetComponent("Button").onClick:AddListener( function() ReturnTransformSetActive(true) end )
    mMyTransform:Find('Canvas/MenuButton/ReturnButton1'):GetComponent("Button").onClick:AddListener(function() ReturnTransformSetActive(false) end)
    mMyTransform:Find('Canvas/MenuButton/ReturnButton1/MaskButton'):GetComponent("Button").onClick:AddListener(function() ReturnTransformSetActive(false) end)
    mMyTransform:Find('Canvas/MenuButton/ReturnButton1/AgainButton'):GetComponent("Button").onClick:AddListener(RestartButtonOnClick)
    mMyTransform:Find('Canvas/MenuButton/ReturnButton1/NewButton'):GetComponent("Button").onClick:AddListener(NewGameButtonOnClick)
    mMyTransform:Find('Canvas/MenuButton/ReturnButton1/RenounceButton'):GetComponent("Button").onClick:AddListener(ExitButton_OnClick)
    mMyTransform:Find('Canvas/ReturnButton'):GetComponent("Button").onClick:AddListener(ExitButton_OnClick)
    mMyTransform:Find('Canvas/CardHeap/GameObject'):GetComponent('Button').onClick:AddListener(AddPokerInfo)
    mMyTransform:Find('Canvas/VictoryInterface/Image/Close'):GetComponent('Button').onClick:AddListener(CloseVictoryInterface)
    mMyTransform:Find('Canvas/VictoryInterface/Image/AgainButton'):GetComponent('Button').onClick:AddListener(ClickVictoryAgainNewGame)
    mMyTransform:Find('Canvas/BottomInfo/back/PromptButton'):GetComponent('Button').onClick:AddListener(PromptButtonOnClick)
    mMyTransform:Find('Canvas/BottomInfo/back/RevokeButton'):GetComponent('Button').onClick:AddListener(RevokeButtonOnClick)

    for Index=1,10,1 do
        for j=1,30,1 do
            mMyTransform:Find('Canvas/Pokers/PokerTable'..Index..'/Poker'..j..'/GameObject'):GetComponent('Button').onClick:AddListener(function () PokerButtonOnClick(Index,j) end)
        end
        mMyTransform:Find('Canvas/Pokers/PokerTable'..Index..'/GameObject'):GetComponent('Button').onClick:AddListener(function () BlankButtonOnClick(Index) end)
    end
end

--==============================--
--desc:返回菜单显示状态
--time:2018-03-01 09:46:42
--@isShow:
--@return 
--==============================--
function ReturnTransformSetActive(isShow)
    GameObjectSetActive(mReturnGameObject, isShow)
end


function ExitButton_OnClick()
    CS.WindowManager.Instance:OpenWindow("SpiderPokerHallUI")
    this:DelayInvoke(1,function ()
        CS.WindowManager.Instance:CloseWindow("SpiderPokerGameUI",false)
    end)
    
end

--==============================--
--desc:音效播放接口
--time:2018-02-28 09:14:54
--@musicid:
--@return 
--==============================--
function PlayAudioClip(musicid)
    if true == canPlaySoundEffect then
        MusicMgr:PlaySoundEffect(musicid)
    end
end

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local newObject = {}
        lookup_table[object] = newObject
        for key, value in pairs(object) do
            newObject[_copy(key)] = _copy(value)
        end
        return setmetatable(newObject, getmetatable(object))
    end
    return _copy(object)
end

local PokerTable=
{
    1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,
    3,3,3,3,3,3,3,3,
    4,4,4,4,4,4,4,4,
    5,5,5,5,5,5,5,5,
    6,6,6,6,6,6,6,6,
    7,7,7,7,7,7,7,7,
    8,8,8,8,8,8,8,8,
    9,9,9,9,9,9,9,9,
    10,10,10,10,10,10,10,10,
    11,11,11,11,11,11,11,11,
    12,12,12,12,12,12,12,12,
    13,13,13,13,13,13,13,13,
}
local GivePokerTable={}
local CloneGivePokerTable={}
local PokerTable1={}
local PokerTable2={}
local PokerTable3={}
local PokerTable4={}
local PokerTable5={}
local PokerTable6={}
local PokerTable7={}
local PokerTable8={}
local PokerTable9={}
local PokerTable10={}
local PokerHeap1={}
local PokerHeap2={}
local PokerHeap3={}
local PokerHeap4={}
local PokerHeap5={}

-- 打乱牌堆
function DisruptGivePokerTable()
    GivePokerTable={}
    GivePokerTable = clone(PokerTable)
    local Count = #GivePokerTable
    for i = 1, Count do
        local j = math.random(i, Count)
        if j > i then
            GivePokerTable[i], GivePokerTable[j] = GivePokerTable[j], GivePokerTable[i]
        end
    end
    GivePokerValue()

end

-- 分发扑克牌
function GivePokerValue()
    CloneGivePokerTable = clone(GivePokerTable)
    PokerTable1={}
    PokerTable2={}
    PokerTable3={}
    PokerTable4={}
    PokerTable5={}
    PokerTable6={}
    PokerTable7={}
    PokerTable8={}
    PokerTable9={}
    PokerTable10={}
    PokerHeap1={}
    PokerHeap2={}
    PokerHeap3={}
    PokerHeap4={}
    PokerHeap5={}
    for Index=1,6,1 do
        table.insert(PokerTable1,GivePokerTable[Index] )
        --table.insert(PokerTable1,Index )
    end

    for Index=7,12,1 do
        table.insert(PokerTable2,GivePokerTable[Index] )
        --table.insert(PokerTable2,Index )
    end

    for Index=13,18,1 do
        table.insert(PokerTable3,GivePokerTable[Index] )
    end
    --PokerTable3[#PokerTable3]=13

    for Index=19,24,1 do
        table.insert(PokerTable4,GivePokerTable[Index] )
    end

    for Index=25,29,1 do
        table.insert(PokerTable5,GivePokerTable[Index] )
    end

    for Index=30,34,1 do
        table.insert(PokerTable6,GivePokerTable[Index] )
    end

    for Index=35,39,1 do
        table.insert(PokerTable7,GivePokerTable[Index] )
    end

    for Index=40,44,1 do
        table.insert(PokerTable8,GivePokerTable[Index] )
    end

    for Index=45,49,1 do
        table.insert(PokerTable9,GivePokerTable[Index] )
    end

    for Index=500,54,1 do
        table.insert(PokerTable10,GivePokerTable[Index] )
    end

    for Index=55,64,1 do
        table.insert(PokerHeap1,GivePokerTable[Index] )
    end

    for Index=65,74,1 do
        table.insert(PokerHeap2,GivePokerTable[Index] )
    end

    for Index=75,84,1 do
        table.insert(PokerHeap3,GivePokerTable[Index] )
    end

    for Index=85,94,1 do
        table.insert(PokerHeap4,GivePokerTable[Index] )
    end

    for Index=95,104,1 do
        table.insert(PokerHeap5,GivePokerTable[Index] )
    end
end

-- 添加扑克牌
function AddPokerInfo()
    AddPokerTable=AddPokerTable+1
    local CloneTable={}
    if AddPokerTable == 1 then
        CloneTable=clone(PokerHeap1)
    elseif AddPokerTable == 2 then
        CloneTable=clone(PokerHeap2)
    elseif AddPokerTable == 3 then
        CloneTable=clone(PokerHeap3)
    elseif AddPokerTable == 4 then
        CloneTable=clone(PokerHeap4)
    elseif AddPokerTable == 5 then
        CloneTable=clone(PokerHeap5)
    end
    if AddPokerTable >= 1 and AddPokerTable <= 5 then
        GameObjectSetActive(HeapPokersObject[AddPokerTable],false) 
        table.insert(PokerTable1,CloneTable[1])
        table.insert(PokerTable2,CloneTable[2])
        table.insert(PokerTable3,CloneTable[3])
        table.insert(PokerTable4,CloneTable[4])
        table.insert(PokerTable5,CloneTable[5])
        table.insert(PokerTable6,CloneTable[6])
        table.insert(PokerTable7,CloneTable[7])
        table.insert(PokerTable8,CloneTable[8])
        table.insert(PokerTable9,CloneTable[9])
        table.insert(PokerTable10,CloneTable[10])
        mMyTransform:Find('Canvas/Pokers/PokerTable1/Poker'..#PokerTable1):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable1[#PokerTable1]))
        mMyTransform:Find('Canvas/Pokers/PokerTable2/Poker'..#PokerTable2):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable2[#PokerTable2]))
        mMyTransform:Find('Canvas/Pokers/PokerTable3/Poker'..#PokerTable3):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable3[#PokerTable3]))
        mMyTransform:Find('Canvas/Pokers/PokerTable4/Poker'..#PokerTable4):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable4[#PokerTable4]))
        mMyTransform:Find('Canvas/Pokers/PokerTable5/Poker'..#PokerTable5):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable5[#PokerTable5]))
        mMyTransform:Find('Canvas/Pokers/PokerTable6/Poker'..#PokerTable6):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable6[#PokerTable6]))
        mMyTransform:Find('Canvas/Pokers/PokerTable7/Poker'..#PokerTable7):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable7[#PokerTable7]))
        mMyTransform:Find('Canvas/Pokers/PokerTable8/Poker'..#PokerTable8):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable8[#PokerTable8]))
        mMyTransform:Find('Canvas/Pokers/PokerTable9/Poker'..#PokerTable9):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable9[#PokerTable9]))
        mMyTransform:Find('Canvas/Pokers/PokerTable10/Poker'..#PokerTable10):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable10[#PokerTable10]))
        GameObjectSetActive(PokerObjectTable1[#PokerTable1],true)
        GameObjectSetActive(PokerObjectTable2[#PokerTable2],true)
        GameObjectSetActive(PokerObjectTable3[#PokerTable3],true)
        GameObjectSetActive(PokerObjectTable4[#PokerTable4],true)
        GameObjectSetActive(PokerObjectTable5[#PokerTable5],true)
        GameObjectSetActive(PokerObjectTable6[#PokerTable6],true)
        GameObjectSetActive(PokerObjectTable7[#PokerTable7],true)
        GameObjectSetActive(PokerObjectTable8[#PokerTable8],true)
        GameObjectSetActive(PokerObjectTable9[#PokerTable9],true)
        GameObjectSetActive(PokerObjectTable10[#PokerTable10],true)
    end
end

-- 调取扑克牌资源图片
function GetPokerCardBackSpriteName(pokerNum)
    local cardSpriteName = "sprite_Spade" .. "_" .. pokerNum;
    return cardSpriteName
end

-- 初始化扑克牌显示
function InitializationPokerDiplay()
    OpenBankPoker()
end

-- 点击扑克牌
function PokerButtonOnClick(mPrintIndex,mIndex)
    if IsClickPoker then
        MoveClickPoker(mPrintIndex,mIndex)
    else
        IsClickPoker = true
        PokerLightDisplay(mPrintIndex,mIndex)
        PromptLight(mPrintIndex,mIndex)
    end
end

local ChoicePokerIndex=0
local ChoicePokerPrintIndedx=0
local ChoicePokerValue = 0

-- 扑克牌亮起
function PokerLightDisplay(mPrintIndex,mIndex)
    local cloneTable={}
    if mPrintIndex==1 then
        cloneTable=PokerTable1
    elseif mPrintIndex == 2 then
        cloneTable=PokerTable2
    elseif mPrintIndex == 3 then
        cloneTable=PokerTable3
    elseif mPrintIndex == 4 then
        cloneTable=PokerTable4
    elseif mPrintIndex == 5 then
        cloneTable=PokerTable5
    elseif mPrintIndex == 6 then
        cloneTable=PokerTable6
    elseif mPrintIndex == 7 then
        cloneTable=PokerTable7
    elseif mPrintIndex == 8 then
        cloneTable=PokerTable8
    elseif mPrintIndex == 9 then
        cloneTable=PokerTable9
    elseif mPrintIndex == 10 then
        cloneTable=PokerTable10
    end
    ChoicePokerValue = cloneTable[mIndex]
    ChoicePokerIndex=mIndex
    ChoicePokerPrintIndedx = mPrintIndex
    for Index=mIndex,#cloneTable,1 do
        local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index..'/Image').gameObject
        GameObjectSetActive(mLight,true)
    end
end

-- 移动扑克牌
function MoveClickPoker(mPrintIndex,mIndex)
    if ChoicePokerIndex ~= 0 and ChoicePokerPrintIndedx ~= 0 then
        
        local ChoicePokerTable = PokerPositionTable(ChoicePokerPrintIndedx)
        local MoveePokerPrintTable = PokerPositionTable(mPrintIndex)
        
        local CanMove=true
        for Index=ChoicePokerIndex, #ChoicePokerTable-1, 1 do
            if ChoicePokerTable[Index]-1 ~= ChoicePokerTable[Index+1] then
                CanMove = false
            end
        end
        if CanMove == true then
            if (ChoicePokerValue+1) ~= MoveePokerPrintTable[#MoveePokerPrintTable] then
                CanMove = false
            end
        end
        
        if CanMove == true then
            MoveRecord.MovePokerInfo={}
            MoveRecord.InitialPosition = ChoicePokerPrintIndedx
            MoveRecord.ChangePosition = mPrintIndex
            for Index=ChoicePokerIndex,#ChoicePokerTable,1 do
                table.insert(MoveePokerPrintTable,ChoicePokerTable[Index])
                table.insert(MoveRecord.MovePokerInfo,ChoicePokerTable[Index] )
            end
            for Index=#ChoicePokerTable,ChoicePokerIndex,-1 do
                table.remove(ChoicePokerTable,Index)
            end
            if #ChoicePokerTable == 0 then
                GameObjectSetActive(BlankButtonObject[ChoicePokerPrintIndedx],true)
            end
            for Index=1,#MoveePokerPrintTable,1 do
                local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index..'/Image').gameObject
                local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index).gameObject
                mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(MoveePokerPrintTable[Index]))
                GameObjectSetActive(mLight,false)
                GameObjectSetActive(mObject,true)
            end
            for Index=#ChoicePokerTable+1,30,1 do
                local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..ChoicePokerPrintIndedx..'/Poker'..Index).gameObject
                GameObjectSetActive(mObject,false)
            end
            if #MoveePokerPrintTable >= 13 then
                MoveRecord.MovePokerInfo={}
                MoveRecord.InitialPosition = 0
                MoveRecord.ChangePosition = 0
                local Count=1
                local IsClear = false
                for Index=#MoveePokerPrintTable,2,-1 do
                    if MoveePokerPrintTable[Index]+1==MoveePokerPrintTable[Index-1] then
                        Count=Count+1
                        if Count==13 then
                            IsClear = true
                        end
                    else
                        Count = 1
                    end
                end
                if IsClear then
                    for Index=#MoveePokerPrintTable,#MoveePokerPrintTable-12,-1 do
                        local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index..'/Image').gameObject
                        local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index).gameObject
                        GameObjectSetActive(mLight,false)
                        GameObjectSetActive(mObject,false)
                        table.remove(MoveePokerPrintTable,Index)
                    end
                    if #MoveePokerPrintTable == 0 then
                        GameObjectSetActive(BlankButtonObject[mPrintIndex],true)
                    end
                    CompleteValue=CompleteValue+1
                    local Index=#MoveePokerPrintTable
                    if Index == 0 then
                        Index = 1
                    end
                    CompletePokerFlyAnimation(mPrintIndex,Index)
                end
            end
            OpenBankPoker()
        end
        for Index=1,30,1 do
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..ChoicePokerPrintIndedx..'/Poker'..Index..'/Image').gameObject
            GameObjectSetActive(mLight,false)
        end
        ClosePromprLight()
        ChoicePokerIndex=0
        ChoicePokerPrintIndedx=0
        ChoicePokerValue = 0
        IsClickPoker=false
    end
end

-- 点击空白的牌
function BlankButtonOnClick(mPrintIndex)
    if ChoicePokerIndex ~= 0 and ChoicePokerPrintIndedx ~= 0 then
        local ChoicePokerTable = PokerPositionTable(ChoicePokerPrintIndedx)
        local MoveePokerPrintTable = PokerPositionTable(mPrintIndex)
        local CanMove=true
        for Index=ChoicePokerIndex, #ChoicePokerTable-1, 1 do
            if ChoicePokerTable[Index]-1 ~= ChoicePokerTable[Index+1] then
                CanMove = false
            end
        end
        if CanMove == true then
            MoveRecord.MovePokerInfo={}
            MoveRecord.InitialPosition = ChoicePokerPrintIndedx
            MoveRecord.ChangePosition = mPrintIndex
            GameObjectSetActive(BlankButtonObject[mPrintIndex],false)
            for Index=ChoicePokerIndex,#ChoicePokerTable,1 do
                table.insert(MoveePokerPrintTable,ChoicePokerTable[Index])
                table.insert(MoveRecord.MovePokerInfo,ChoicePokerTable[Index])
            end
            for Index=#ChoicePokerTable,ChoicePokerIndex,-1 do
                table.remove(ChoicePokerTable,Index)
            end
            if #ChoicePokerTable == 0 then
                GameObjectSetActive(BlankButtonObject[ChoicePokerPrintIndedx],true)
            end
            for Index=1,#MoveePokerPrintTable,1 do
                local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index..'/Image').gameObject
                local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index).gameObject
                mMyTransform:Find('Canvas/Pokers/PokerTable'..mPrintIndex..'/Poker'..Index):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(MoveePokerPrintTable[Index]))
                GameObjectSetActive(mLight,false)
                GameObjectSetActive(mObject,true)
            end
            for Index=#ChoicePokerTable+1,30,1 do
                local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..ChoicePokerPrintIndedx..'/Poker'..Index).gameObject
                GameObjectSetActive(mObject,false)
            end
        end
        for Index=1,30,1 do
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..ChoicePokerPrintIndedx..'/Poker'..Index..'/Image').gameObject
            GameObjectSetActive(mLight,false)
        end
        OpenBankPoker()
        ClosePromprLight()
        ChoicePokerIndex=0
        ChoicePokerPrintIndedx=0
        ChoicePokerValue = 0
        IsClickPoker=false
    end
end

-- 获取扑克牌所在位置
function PokerPositionTable(mPrintIndex)
    local MoveePokerPrintTable={}
    if mPrintIndex == 1 then
        MoveePokerPrintTable = PokerTable1
    elseif mPrintIndex == 2 then
        MoveePokerPrintTable = PokerTable2
    elseif mPrintIndex == 3 then
        MoveePokerPrintTable = PokerTable3
    elseif mPrintIndex == 4 then
        MoveePokerPrintTable = PokerTable4
    elseif mPrintIndex == 5 then
        MoveePokerPrintTable = PokerTable5
    elseif mPrintIndex == 6 then
        MoveePokerPrintTable = PokerTable6
    elseif mPrintIndex == 7 then
        MoveePokerPrintTable = PokerTable7
    elseif mPrintIndex == 8 then
        MoveePokerPrintTable = PokerTable8
    elseif mPrintIndex == 9 then
        MoveePokerPrintTable = PokerTable9
    elseif mPrintIndex == 10 then
        MoveePokerPrintTable = PokerTable10
    end
    return MoveePokerPrintTable
end

-- 提示光圈
function PromptLight(mPrintIndex,mIndex)
    local MoveePokerPrintTable = PokerPositionTable(mPrintIndex)
    if mPrintIndex~=1 and #PokerTable1 >=1 then
        if PokerTable1[#PokerTable1] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable1/Poker'..#PokerTable1..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=2 and #PokerTable2 >=1 then
        if PokerTable2[#PokerTable2] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable2/Poker'..#PokerTable2..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=3 and #PokerTable3 >=1 then
        if PokerTable3[#PokerTable3] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable3/Poker'..#PokerTable3..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=4 and #PokerTable4 >=1 then
        if PokerTable4[#PokerTable4] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable4/Poker'..#PokerTable4..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=5 and #PokerTable5 >=1 then
        if PokerTable5[#PokerTable5] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable5/Poker'..#PokerTable5..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=6 and #PokerTable6 >=1 then
        if PokerTable6[#PokerTable6] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable6/Poker'..#PokerTable6..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=7 and #PokerTable7 >=1 then
        if PokerTable7[#PokerTable7] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable7/Poker'..#PokerTable7..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=8 and #PokerTable8 >=1 then
        if PokerTable8[#PokerTable8] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable8/Poker'..#PokerTable8..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=9 and #PokerTable9 >=1 then
        if PokerTable9[#PokerTable9] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable9/Poker'..#PokerTable9..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
    if mPrintIndex ~=10 and #PokerTable10 >=1 then
        if PokerTable10[#PokerTable10] -1 == MoveePokerPrintTable[mIndex] then
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable10/Poker'..#PokerTable10..'/LightImage').gameObject
            GameObjectSetActive(mLight,true)
        end
    end
end

-- 关闭提示光圈
function ClosePromprLight()
    for i=1,10,1 do
        for j=1,30,1 do
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j..'/LightImage').gameObject
            GameObjectSetActive(mLight,false)
        end
    end
end

-- 扑克牌完成动画
function CompletePokerFlyAnimation(mPrintIndex,Index)
    local FlyPoker = mMyTransform:Find('Canvas/PokersFly/PokerTable'..mPrintIndex..'/Poker'..Index).gameObject
    local FlyTweenPosition = FlyPoker.transform:GetComponent("TweenPosition")
    local position_x = CompletePokerPosition[mPrintIndex]+((CompleteValue-1)*28)
    FlyTweenPosition.to = CS.UnityEngine.Vector3(position_x,285,0)
    FlyTweenPosition.duration=0.6
    GameObjectSetActive(FlyPoker,true)
    FlyTweenPosition:ResetToBeginning()
    FlyTweenPosition:Play(true)
    this:DelayInvoke(1,function ()
        GameObjectSetActive(FlyPoker,false)
        CompleteOnePokers()
    end)

    if CompleteValue >= 8 then
        this:DelayInvoke(2,function ()
            OpenVictoryInterface()
        end)
    end
end

-- 完成一列
function CompleteOnePokers()
    for Index=1,CompleteValue,1 do
        GameObjectSetActive(CompletePokers[Index],true)
    end
end

-- 重置完成数量
function ResetCompleteValue()
    CompleteValue=0
    for Index=1,8,1 do
        GameObjectSetActive(CompletePokers[Index],false)
    end
end

-- 点击重新开始
function RestartButtonOnClick()
    GivePokerValue()
    ChoicePokerIndex=0
    ChoicePokerPrintIndedx=0
    ChoicePokerValue = 0
    AddPokerTable = 0
    IsClickPoker=false
    ResetCompleteValue()
    for i=1,10,1 do
        for j=1,30,1 do
            local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j).gameObject
            local mPromptLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j..'/LightImage').gameObject
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j..'/Image').gameObject
            GameObjectSetActive(mObject,false)
            GameObjectSetActive(mPromptLight,false)
            GameObjectSetActive(mLight,false)
        end
    end
    for i=1,10,1 do
        for j=1,5,1 do
            local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j).gameObject
            mObject.transform:GetComponent('Image'):ResetSpriteByName("sprite_Poker_Back_01")
            GameObjectSetActive(mObject,true)
        end
    end
    for i=1,4,1 do
        local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker6').gameObject
        mObject.transform:GetComponent('Image'):ResetSpriteByName("sprite_Poker_Back_01")
        GameObjectSetActive(mObject,true)
    end
    for Index=1,5,1 do
        GameObjectSetActive(HeapPokersObject[Index],true) 
    end
    BankPokerNumber={6,6,6,6,5,5,5,5,5,5}
    OpenBankPoker()
    GameTime=0
end

-- 点击新游戏
function NewGameButtonOnClick()
    if mGoldValue < 500 then
        local TextObject = mMyTransform:Find('Canvas/PromptText3').gameObject
        GameObjectSetActive(TextObject,false)
        GameObjectSetActive(TextObject,true)
        this:DelayInvoke(1.5,function ()
            GameObjectSetActive(TextObject,false)
        end)
    end
    DisruptGivePokerTable()
    AddPokerTable=0
    ChoicePokerIndex=0
    ChoicePokerPrintIndedx=0
    ChoicePokerValue = 0
    IsClickPoker=false
    BankPokerNumber={6,6,6,6,5,5,5,5,5,5}
    IsClickPoker=false
    ResetCompleteValue()
    for i=1,10,1 do
        for j=1,30,1 do
            local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j).gameObject
            local mPromptLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j..'/LightImage').gameObject
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j..'/Image').gameObject
            GameObjectSetActive(mObject,false)
            GameObjectSetActive(mPromptLight,false)
            GameObjectSetActive(mLight,false)
        end
    end
    for i=1,10,1 do
        for j=1,5,1 do
            local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker'..j).gameObject
            mObject.transform:GetComponent('Image'):ResetSpriteByName("sprite_Poker_Back_01")
            GameObjectSetActive(mObject,true)
        end
    end
    for i=1,4,1 do
        local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..i..'/Poker6').gameObject
        mObject.transform:GetComponent('Image'):ResetSpriteByName("sprite_Poker_Back_01")
        GameObjectSetActive(mObject,true)
    end
    for Index=1,5,1 do
        GameObjectSetActive(HeapPokersObject[Index],true) 
    end
    OpenBankPoker()
    -- 开始新的一局游戏
    GameTime=0
    mGoldValue = GameData.RoleInfo.GoldCount 
    mGoldValue = mGoldValue - 500
    mGaldValueText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(mGoldValue))
    NetMsgHandler.Send_CS_Update_FreeGold(-500)
end

-- 盖住牌
function CloseBankPoker()
    for Index=1,BankPokerNumber[1],1 do
        PokerImageTable1[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[2],1 do
        PokerImageTable2[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[3],1 do
        PokerImageTable3[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[4],1 do
        PokerImageTable4[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[5],1 do
        PokerImageTable5[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[6],1 do
        PokerImageTable6[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[7],1 do
        PokerImageTable7[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[8],1 do
        PokerImageTable8[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[9],1 do
        PokerImageTable9[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
    for Index=1,BankPokerNumber[10],1 do
        PokerImageTable10[Index]:ResetSpriteByName("sprite_Poker_Back_01")
    end
end

-- 翻开扑克牌
function OpenBankPoker()
    CloseBankPoker()
    if #PokerTable1 == BankPokerNumber[1] and #PokerTable1 ~=0 then
        
        PokerImageTable1[#PokerTable1]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable1[#PokerTable1]))
        GameObjectSetActive(PokerObjectTable1[#PokerTable1],true)
        BankPokerNumber[1]=BankPokerNumber[1]-1
    end
    if #PokerTable2 == BankPokerNumber[2] and #PokerTable2 ~=0 then
        PokerImageTable2[#PokerTable2]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable2[#PokerTable2]))
        GameObjectSetActive(PokerObjectTable2[#PokerTable2],true)
        BankPokerNumber[2]=BankPokerNumber[2]-1
    end
    if #PokerTable3 == BankPokerNumber[3] and #PokerTable3 ~=0 then
        PokerImageTable3[#PokerTable3]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable3[#PokerTable3]))
        GameObjectSetActive(PokerObjectTable3[#PokerTable3],true)
        BankPokerNumber[3]=BankPokerNumber[3]-1
    end
    if #PokerTable4 == BankPokerNumber[4] and #PokerTable4 ~=0 then
        PokerImageTable4[#PokerTable4]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable4[#PokerTable4]))
        GameObjectSetActive(PokerObjectTable4[#PokerTable4],true)
        BankPokerNumber[4]=BankPokerNumber[4]-1
    end
    if #PokerTable5 == BankPokerNumber[5] and #PokerTable5 ~=0 then
        PokerImageTable5[#PokerTable5]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable5[#PokerTable5]))
        GameObjectSetActive(PokerObjectTable5[#PokerTable5],true)
        BankPokerNumber[5]=BankPokerNumber[5]-1
    end
    if #PokerTable6 == BankPokerNumber[6] and #PokerTable6 ~=0 then
        PokerImageTable6[#PokerTable6]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable6[#PokerTable6]))
        GameObjectSetActive(PokerObjectTable6[#PokerTable6],true)
        BankPokerNumber[6]=BankPokerNumber[6]-1
    end
    if #PokerTable7 == BankPokerNumber[7] and #PokerTable7 ~=0 then
        PokerImageTable7[#PokerTable7]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable7[#PokerTable7]))
        GameObjectSetActive(PokerObjectTable7[#PokerTable7],true)
        BankPokerNumber[7]=BankPokerNumber[7]-1
    end
    if #PokerTable8 == BankPokerNumber[8] and #PokerTable8 ~=0 then
        PokerImageTable8[#PokerTable8]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable8[#PokerTable8]))
        GameObjectSetActive(PokerObjectTable8[#PokerTable8],true)
        BankPokerNumber[8]=BankPokerNumber[8]-1
    end
    if #PokerTable9 == BankPokerNumber[9] and #PokerTable9 ~=0 then
        PokerImageTable9[#PokerTable9]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable9[#PokerTable9]))
        GameObjectSetActive(PokerObjectTable9[#PokerTable9],true)
        BankPokerNumber[9]=BankPokerNumber[9]-1
    end
    if #PokerTable10 == BankPokerNumber[10] and #PokerTable10 ~=0 then
        PokerImageTable10[#PokerTable10]:ResetSpriteByName(GetPokerCardBackSpriteName(PokerTable10[#PokerTable10]))
        GameObjectSetActive(PokerObjectTable10[#PokerTable10],true)
        BankPokerNumber[10]=BankPokerNumber[10]-1
    end
end

function UpdateGameTime()
    if mGameTimeText ~= nil then
        GameTime=GameTime+mTime.deltaTime
        local timeHour = math.fmod(math.floor(GameTime/3600), 24)
        local timeMinute = math.fmod(math.floor(GameTime/60), 60)
        local timeSecond = math.fmod(GameTime, 60)
        timeSecond = math.ceil( GameTime )
        if timeHour < 10 then
            timeHour="0"..timeHour
        end
        if timeMinute < 10 then
            timeMinute="0"..timeMinute
        end
        if timeSecond < 10 then
            timeSecond="0"..timeSecond
        end
        mGameTimeText.text = timeHour..":"..timeMinute..":"..timeSecond
    end
    
end

-- 打开胜利界面
function OpenVictoryInterface()
    GameObjectSetActive(mVictoryInterface,true)
    mGoldValue = GameData.RoleInfo.GoldCount 
    mGoldValue = mGoldValue + 600
    mVictoryText.text = "0.06"
    mGaldValueText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(mGoldValue))
    NetMsgHandler.Send_CS_Update_FreeGold(600)
    PlayAudioClip('PDK_WIN')
end

-- 关闭胜利面板
function CloseVictoryInterface()
    GameObjectSetActive(mVictoryInterface,false)
end

-- 点击胜利面板再来一局
function ClickVictoryAgainNewGame()
    CloseVictoryInterface()
    NewGameButtonOnClick()
end

-- 点击提示
function PromptButtonOnClick()
    local HaveMovePoker = PromptTestPoker()
    if HaveMovePoker == false then
        local TextObject = mMyTransform:Find('Canvas/PromptText1').gameObject
        GameObjectSetActive(TextObject,false)
        GameObjectSetActive(TextObject,true)
        this:DelayInvoke(1.5,function ()
            GameObjectSetActive(TextObject,false)
        end)
    end
end

-- 点击撤销
function RevokeButtonOnClick()
    if #MoveRecord.MovePokerInfo == 0 then
        local TextObject = mMyTransform:Find('Canvas/PromptText2').gameObject
        GameObjectSetActive(TextObject,false)
        GameObjectSetActive(TextObject,true)
        this:DelayInvoke(1.5,function ()
            GameObjectSetActive(TextObject,false)
        end)
    else
        local ChoicePokerTable = PokerPositionTable(MoveRecord.ChangePosition)
        local MoveePokerPrintTable = PokerPositionTable(MoveRecord.InitialPosition)
        for Index=1,#MoveRecord.MovePokerInfo,1 do
            table.insert(MoveePokerPrintTable,MoveRecord.MovePokerInfo[Index])
        end
        for Index=#ChoicePokerTable,#ChoicePokerTable-#MoveRecord.MovePokerInfo+1,-1 do
            table.remove(ChoicePokerTable,Index)
        end
        for Index=1,#MoveePokerPrintTable,1 do
            local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..MoveRecord.InitialPosition..'/Poker'..Index..'/Image').gameObject
            local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..MoveRecord.InitialPosition..'/Poker'..Index).gameObject
            mMyTransform:Find('Canvas/Pokers/PokerTable'..MoveRecord.InitialPosition..'/Poker'..Index):GetComponent('Image'):ResetSpriteByName(GetPokerCardBackSpriteName(MoveePokerPrintTable[Index]))
            GameObjectSetActive(mLight,false)
            GameObjectSetActive(mObject,true)
        end
        for Index=#ChoicePokerTable+1,30,1 do
            local mObject = mMyTransform:Find('Canvas/Pokers/PokerTable'..MoveRecord.ChangePosition..'/Poker'..Index).gameObject
            GameObjectSetActive(mObject,false)
        end
        OpenBankPoker()
        ClosePromprLight()
        ChoicePokerIndex=0
        ChoicePokerPrintIndedx=0
        ChoicePokerValue = 0
        IsClickPoker=false
        MoveRecord.MovePokerInfo={}
        MoveRecord.InitialPosition = 0
        MoveRecord.ChangePosition = 0
    end
end


-- 提示
function PromptTestPoker()
    for Index=1,10,1 do
        local TextPokerTable = PokerPositionTable(Index)
        if #TextPokerTable > 0 then
            for Count=1,10,1 do
                if Count ~= Index then
                    local ContrastPokerTable = PokerPositionTable(Count)
                    if #ContrastPokerTable > 0 then
                        local PokerMaxValue = TextPokerTable[#TextPokerTable]
                        if PokerMaxValue > ContrastPokerTable[#ContrastPokerTable] then
                            if PokerMaxValue-1 == ContrastPokerTable[#ContrastPokerTable] then
                                if ContrastPokerTable[#ContrastPokerTable]+1 ~= ContrastPokerTable[#ContrastPokerTable-1] then
                                    local mLight = mMyTransform:Find('Canvas/Pokers/PokerTable'..Count..'/Poker'..#ContrastPokerTable..'/Image').gameObject
                                    local mLightImage = mMyTransform:Find('Canvas/Pokers/PokerTable'..Index..'/Poker'..#TextPokerTable..'/LightImage').gameObject
                                    GameObjectSetActive(mLight,true)
                                    GameObjectSetActive(mLightImage,true)
                                    return true
                                end
                                
                            end
                        end

                    end
                end
                
            end
        end
    end
    return false
end

function onNotifyGoldUpdateEvent2()
    mGoldValue = GameData.RoleInfo.GoldCount 
    mGaldValueText.text = lua_CommaSeperate(GameConfig.GetFormatColdNumber(mGoldValue))
end



