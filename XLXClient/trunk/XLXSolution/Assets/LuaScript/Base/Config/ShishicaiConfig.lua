--Export by excel config file, don't modify this file!
--[[
ID(Column[A] Type[int] Desc[序号]
PAY_RATE(Column[F] Type[array] Desc[押中赔付比例]
ENTER_LIMIT(Column[Q] Type[int] Desc[玩家入场限制]
BET_LIMIT(Column[R] Type[int] Desc[玩家投注限制]
HISTORY_TYPE_SPRITE(Column[V] Type[array] Desc[牌型图片]
HISTORY_TYPE(Column[W] Type[array] Desc[牌型]
HISTORY_TYPE_SPRITE(Column[X] Type[array] Desc[牌型对应的图片]
POKER_IMAGE_NAME(Column[Y] Type[array] Desc[扑克图片名称]
BET_GOLD(Column[Z] Type[array] Desc[筹码值]
BET_NUMBER(Column[AA] Type[array] Desc[单次可押次数]
]]--

data.ShishicaiConfig =
{
    PAY_RATE = { 3, 4, 5, 6, 10, 0.2 },
    ENTER_LIMIT = 1,
    BET_LIMIT = 50,
    HISTORY_TYPE_SPRITE = { "text_sanpai", "text_duizi", "text_shunzi", "text_jinhua", "text_shunjin", "text_baozi" },
    HISTORY_TYPE = { "散牌", "对子", "顺子", "金花", "顺金", "豹子" },
    HISTORY_TYPE_SPRITE = { "text_sanpai", "text_duizi", "text_shunzi", "text_jinhua", "text_shunjin", "text_baozi" },
    POKER_IMAGE_NAME = { "Diamond", "Club", "Hearts", "Spade" },
    BET_GOLD = { 1, 10, 100, 1000 },
    BET_NUMBER = { 1, 5, 10 },
}

