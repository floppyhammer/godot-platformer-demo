local nk = require("nakama")

local function check_session(context, payload)
    local count = nk.stream_count({ mode = 0, subject = context.user_id })
    if (count > 1) then
        nk.logger_info(("User already active: %q"):format(count))

        -- Notice the already logged in user
        local sender_id = nil -- "nil" for server sent.
        local content = {
            text = "Someone tried to log in with this account on another device when you are still online.",
        }
        local subject = "Attempt to log in from another device"
        local code = 1
        local persistent = false
        nk.notification_send(context.user_id, subject, content, code, sender_id, persistent)
    end

    return nk.json_encode({["session_count"] = count})
end

nk.register_rpc(check_session, "check_session")
