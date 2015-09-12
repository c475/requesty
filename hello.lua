local json = require("cjson")
local r = require("resty.redis")
local redis = r:new()

ngx.req.get_body_data()

local ok, error = redis:connect("127.0.0.1", 6379)

if not ok then
    ngx.say("failed to connect to redis server: ", error)
    return
end


local ret = {}

function try(f)
    local status, exception = pcall(f)

    if not status then
        return
    else
        return f()
    end
end


function get_headers()
    return ngx.req.get_headers()
end

function get_uri()
    return ngx.req.get_uri_args()
end

function get_body()
    return ngx.req.get_post_args
end

function get_file()
    return ngx.req.get_body_file()
end


ret.headers = try(get_headers)
ret.get = try(get_uri)
ret.post = try(get_body)
ret.file = try(get_file)


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
