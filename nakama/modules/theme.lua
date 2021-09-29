local nk = require("nakama")

-- owned by the system
local user_id = nil

local new_objects = {
  { collection = "system", key = "broadcast", user_id = user_id, value = {theme="default"}, permission_read = 2, permission_write = 0 }
}

nk.storage_write(new_objects)
