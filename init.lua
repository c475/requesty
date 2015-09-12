local r = require("resty.redis")
local json = require("cjson")

local redis = r:new()

-- 1 second timeout
redis.timeout(1000)

local ok, error = redis:connect("127.0.0.1", 6379)

if not ok then
    ngx.say("failed to connect to redis server: ", err)
    return
end
