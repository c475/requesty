local json = require("cjson")
local r = require("resty.redis")
local redis = r:new()

redis:set_timeout(1000)

ngx.req.get_body_data()

local ok, error = redis:connect("127.0.0.1", 6379)

if not ok then
    ngx.say("failed to connect to redis server: ", error)
    return
end

local lib = {}
local ret = {}

function lib.try(f, args)
    if pcall(f) then return f() end
end


function lib.get_headers()
    return ngx.req.get_headers()
end

function lib.get_uri()
    return ngx.req.get_uri_args()
end

function lib.get_body()
    return ngx.req.get_post_args()
end

function lib.get_file()
    return ngx.req.get_body_file()
end


ret.headers = lib.try(lib.get_headers)
ret.get     = lib.try(lib.get_uri)
ret.post    = lib.try(lib.get_body)
ret.file    = lib.try(lib.get_file)

local exists = redis:get(ngx.var.remote_addr)

if type(exists) == "string" then
    prior_records = json.decode(exists)
    prior_records[#prior_records] = ret
    redis:set(ngx.var.remote_addr, json.encode(prior_records))
else
    redis:set(ngx.var.remote_addr, json.encode({ret}))
end


redis:close()

ngx.header.content_type = "application/json"

if prior_records then
    ngx.say(json.encode(prior_records))
else
    nxg.say(json.encode({ret}))
end
