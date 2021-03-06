local json = require("cjson")
local r = require("resty.redis")
local redis = r:new()

ngx.req.read_body()

redis:set_timeout(1000)

local ok, error = redis:connect("127.0.0.1", 6379)

if not ok then
    ngx.say("go away")
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

function lib.get_raw_body()
    return ngx.req.get_body_data()
end

function lib.get_full_url()
    return ngx.var.scheme .. "://" .. ngx.var.host .. ngx.var.request_uri
end

ret.method  = ngx.var.request_method
ret.headers = lib.try(lib.get_headers)
ret.args    = lib.try(lib.get_uri)
ret.body    = ngx.req.get_body_data()
ret.file    = lib.try(lib.get_file)
ret.rawbody = lib.try(lib.get_raw_body)
ret.url     = lib.try(lib.get_full_url)
ret.date    = os.date("%Y-%m-%dT%H:%M:%S")


local exists = redis:get(ngx.var.remote_addr)

if type(exists) == "string" then
    prior_records = json.decode(exists)
    prior_records[#prior_records+1] = ret
    redis:set(ngx.var.remote_addr, json.encode(prior_records))
else
    redis:set(ngx.var.remote_addr, json.encode({ret}))
end


redis:close()

ngx.header.content_type = "application/json"

if prior_records then
    ngx.say(json.encode(prior_records))
else
    ngx.say(json.encode({ret}))
end

ngx.exit(ngx.OK)
