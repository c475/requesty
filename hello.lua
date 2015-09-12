local r = require("resty.redis")
local redis = r:new()

-- 1 second timeout
redis.timeout(1000)

local ok, error = redis:connect("127.0.0.1", 6379)

if not ok then
    ngx.say("failed to connect to redis server: ", error)
    return
end


local ret = {}

ngx.req.get_body_data()

ret.headers = ngx.req.get_headers()
ret.get = ngx.req.get_uri_args()
ret.post = ngx.req.get_post_args()
ret.file = ngx.req.get_body_file()

local ok, error = redis:set(ngx.var.remote_addr, json.encode(ret))

if not ok then
    ngx.say("unable to set in redis: ", error)
    return
end


ngx.say([[

    <!doctype html>

    <html>

    <head>
        <title>My Website</title>
    </head>

    <body>
        <h1>This is my new website</h1>
        <p>]] .. json.encode(ret) .. [[</p>
    </body>

    </html>

]])
