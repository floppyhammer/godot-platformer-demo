local nk = require("nakama")

local M = {}

-- Notes:
-- Enabling this module (by registering) will disable relayed coomunication between matched users
-- That means send_match_state_async() will not work

-- Custom operation codes. Nakama specific codes are <= 0.
local OpCodes = {
  update_ship = 1,
  update_turret = 2,
  method_call = 3,
  system = 4,
  update_ship_state = 5,
}

-- Op pattern table for dealing with updates that uses data and state.
local op_handlers = {}

-- Update ship commands
op_handlers[OpCodes.update_ship] = function(data, tick_commands, dispatcher)
  local id = data.user_id

  if tick_commands[id] == nil then
    tick_commands[id] = {}
  end

  -- pairs for random string key table, ipair for ordered number key table
  -- Only update received states
  for k, v in pairs(data.properties) do
    tick_commands[id][k] = v
  end
end

-- Update ship state
op_handlers[OpCodes.update_ship_state] = function(data, state, dispatcher)
  local id = data.user_id

  -- pairs for random string key table, ipair for ordered number key table
  -- Only update received states
  for k, v in pairs(data.properties) do
    state.ships[id][k] = v
  end
end

-- Update turret state
op_handlers[OpCodes.update_turret] = function(data, state, dispatcher)
  local id = data.node_path

  -- Create if it does not exist
  if state.turrets[id] == nil then
    state.turrets[id] = {}
  end
  
  -- Update states
  for k, v in pairs(data.properties) do
    state.turrets[id][k] = v
  end
end

-- Method call
op_handlers[OpCodes.method_call] = function(data, state, dispatcher)
  local encoded = nk.json_encode(data)

  dispatcher.broadcast_message(OpCodes.method_call, encoded)
end

-- Register matchmaker
local function makematch(context, matched_users)
  -- print matched users
  for _, user in ipairs(matched_users) do
      local presence = user.presence
      nk.logger_info(("Matched user '%s' named '%s'"):format(presence.user_id, presence.username))
      for k, v in pairs(user.properties) do
          nk.logger_info(("Matched on '%s' value '%s'"):format(k, v))
      end
  end

  -- Create a new authoritative realtime multiplayer match running on the given runtime module name
  local module = "match_handler"
  local params = { invited = matched_users }
  local match_id = nk.match_create(module, params)

  return match_id
end
nk.register_matchmaker_matched(makematch)


function M.match_init(context, params)
  -- Initial in-memory state of the match
  local state  = {
    -- Record player presences
    presences = {},
    command_sequence = {},
  }

  -- Tick rate representing the desired number of match_loop() calls per second
  local tick_rate = 10

  -- String label that can be used to filter matches in listing operations
  local label = "rank=1"

  return state, tick_rate, label
end


function M.match_join_attempt(context, dispatcher, tick, state, presence, metadata)
  local accept_user = true
  return state, accept_user
end


function M.match_join(context, dispatcher, tick, state, presences)
  -- Presences is a list of users that have just JOINED the match.

  -- Add joined presences to state
  for _, presence in ipairs(presences) do
    state.presences[presence.user_id] = presence
  end

  return state
end


function M.match_leave(context, dispatcher, tick, state, presences)
  -- Presences is a list of users that have just LEFT the match.

  -- Remove left presences from state
  for _, presence in ipairs(presences) do
    state.presences[presence.user_id] = nil
  end

  -- Check if there are players left
  for k, v in pairs(state.presences) do
    if v ~= nil then
      return state
    end
  end
  
  -- All players left, end match
  nk.logger_info("All players have left the match, remove this match from server storage.")
  --local result = update_server_address(context.match_id, true)
  return nil
end


function M.match_loop(context, dispatcher, tick, state, messages)
  -- Start sending commands after 10 ticks
  if tick < 50 then
    return state
  end

  -- Collected inputs in the current tick
  local tick_commands = {}

  -- Handle state updates sent by clients
  for _, message in ipairs(messages) do
    --nk.logger_info(message.data)

    -- Identify operation code
    local op_code = message.op_code

    -- Decode JSON into dictionary
    local decoded = nk.json_decode(message.data)

    -- Run boiler plate commands (state updates.)
    local handler = op_handlers[op_code]
    if handler ~= nil then
      op_handlers[op_code](decoded, tick_commands, dispatcher)
    end
  end

  -- Record commands
  state.command_sequence[tick] = tick_commands

  -- Broadcast inputs collected in the current tick to clients
  local data2send = {tick = tick, commands = tick_commands}
  
  local encoded = nk.json_encode(data2send)
  dispatcher.broadcast_message(OpCodes.update_ship, encoded)

  -- Broadcast correction states to clients
  --encoded = nk.json_encode(state.turrets)
  --dispatcher.broadcast_message(OpCodes.update_turret, encoded)

  return state
end


function M.match_terminate(context, dispatcher, tick, state, grace_seconds)
  local message = "Server shutting down in " .. grace_seconds .. " seconds"
  dispatcher.broadcast_message(OpCodes.system, message)
  return nil
end


return M
