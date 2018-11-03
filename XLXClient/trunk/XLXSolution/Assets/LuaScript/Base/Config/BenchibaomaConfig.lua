--Export by excel config file, don't modify this file!
--[[
ID(Column[A] Type[int] Desc[序号]
PAY_RATE(Column[I] Type[array] Desc[押中赔付比例]
ENTER_LIMIT(Column[P] Type[group] Desc[玩家入场限制]
BET_LIMIT(Column[Q] Type[array] Desc[玩家投注金币限制]
PLAYER_UPBANKER_GOLD(Column[R] Type[array] Desc[玩家上庄所需金币]
LOGO_NAME(Column[W] Type[array] Desc[LOGO名称]
BET_GOLD(Column[X] Type[group] Desc[筹码值]
]]--

data.BenchibaomaConfig =
{
    PAY_RATE = { 40, 30, 20, 12, 6, 6, 3, 3 },
    ENTER_LIMIT = { { 1, 50000 }, { 500, 4500000 }, { 1000, 4500000 } },
    BET_LIMIT = { 50, 500, 5000 },
    PLAYER_UPBANKER_GOLD = { 20000, 50000, 500000 },
    LOGO_NAME = { "法拉利", "兰博基尼", "玛莎拉蒂", "保时捷", "奔驰", "宝马", "本田", "大众" },
    BET_GOLD = { { 1, 10, 50, 100 }, { 100, 200, 500, 1000 }, { 1000, 2000, 5000, 10000 } },
}

