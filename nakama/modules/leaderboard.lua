local nk = require("nakama")

local id = "金币"
local authoritative = false
local sort = "desc"
local operator = "best"
local reset = "0 0 * * 1"
local metadata = {
  placeholder = "nothing"
}

nk.leaderboard_create(id, authoritative, sort, operator, reset, metadata)
