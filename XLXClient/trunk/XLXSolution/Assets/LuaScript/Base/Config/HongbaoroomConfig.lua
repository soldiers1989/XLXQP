--Export by excel config file, don't modify this file!
--[[
TemplateID(Column[A] Type[int] Desc[房间编号]
Type(Column[C] Type[int] Desc[房间类型]
BeginPlayer(Column[D] Type[int] Desc[开始最低人数]
MaxPlayer(Column[E] Type[int] Desc[人数上限]
HongBaoCount(Column[F] Type[int] Desc[红包数量]
RoomLevel(Column[G] Type[int] Desc[房间等级]
Antes(Column[H] Type[int] Desc[底注]
EnterLimit(Column[I] Type[int] Desc[入场金币下限]
OutLimit(Column[J] Type[int] Desc[入场金币上限]
IsOpen(Column[K] Type[int] Desc[是否开启]
Name(Column[L] Type[string] Desc[名字]
]]--

data.HongbaoroomConfig =
{
    [1] =
    {
        TemplateID = 1,
        Type = 6,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 1,
        Antes = 100,
        EnterLimit = 1000,
        OutLimit = 10000,
        IsOpen = 1,
        Name = "平民场",
    },
    [2] =
    {
        TemplateID = 2,
        Type = 6,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 2,
        Antes = 200,
        EnterLimit = 2000,
        OutLimit = 20000,
        IsOpen = 1,
        Name = "小资场",
    },
    [3] =
    {
        TemplateID = 3,
        Type = 6,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 3,
        Antes = 1000,
        EnterLimit = 10000,
        OutLimit = 100000,
        IsOpen = 1,
        Name = "老板场",
    },
    [4] =
    {
        TemplateID = 4,
        Type = 6,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 4,
        Antes = 2000,
        EnterLimit = 20000,
        OutLimit = 200000,
        IsOpen = 1,
        Name = "土豪场",
    },
    [5] =
    {
        TemplateID = 5,
        Type = 6,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 5,
        Antes = 10000,
        EnterLimit = 100000,
        OutLimit = 99999999,
        IsOpen = 1,
        Name = "贵族场",
    },
    [6] =
    {
        TemplateID = 6,
        Type = 6,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 6,
        Antes = 20000,
        EnterLimit = 200000,
        OutLimit = 99999999,
        IsOpen = 1,
        Name = "皇家场",
    },
    [7] =
    {
        TemplateID = 7,
        Type = 7,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 1,
        Antes = 10,
        EnterLimit = 50,
        OutLimit = 1000,
        IsOpen = 1,
        Name = "平民场",
    },
    [8] =
    {
        TemplateID = 8,
        Type = 7,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 2,
        Antes = 50,
        EnterLimit = 250,
        OutLimit = 5000,
        IsOpen = 1,
        Name = "小资场",
    },
    [9] =
    {
        TemplateID = 9,
        Type = 7,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 3,
        Antes = 100,
        EnterLimit = 500,
        OutLimit = 4500000,
        IsOpen = 1,
        Name = "老板场",
    },
    [10] =
    {
        TemplateID = 10,
        Type = 7,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 4,
        Antes = 500,
        EnterLimit = 1000,
        OutLimit = 4500000,
        IsOpen = 1,
        Name = "土豪场",
    },
    [11] =
    {
        TemplateID = 11,
        Type = 7,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 5,
        Antes = 1000,
        EnterLimit = 5000,
        OutLimit = 99999999,
        IsOpen = 1,
        Name = "贵族场",
    },
    [12] =
    {
        TemplateID = 12,
        Type = 7,
        BeginPlayer = 5,
        MaxPlayer = 8,
        HongBaoCount = 5,
        RoomLevel = 6,
        Antes = 2000,
        EnterLimit = 10000,
        OutLimit = 99999999,
        IsOpen = 1,
        Name = "皇家场",
    },
}

