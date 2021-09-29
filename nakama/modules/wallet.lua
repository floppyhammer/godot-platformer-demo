local nk = require("nakama")

local function update_wallet(context, payload)
  local user_id = context.user_id

  -- we'll assume payload was sent as JSON and decode it.
  local content = nk.json_decode(payload)
  
  -- log data sent to RPC call.
  nk.logger_info(string.format("[Wallet] Payload: %q", content))

  local status, err = pcall(nk.wallet_update, user_id, content)

  if (not status) then
      nk.logger_error(("[Wallet] User wallet update error: %q"):format(err))
  end
end

nk.register_rpc(update_wallet, "update_wallet")
