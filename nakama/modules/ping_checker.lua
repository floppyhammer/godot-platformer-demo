local nk = require("nakama")

local function check_ping(context, payload)
    local user_id = context.user_id

    local content = nk.json_decode(payload)

    -- Ping back
    return nk.json_encode(content)
end

nk.register_rpc(check_ping, "check_ping")
