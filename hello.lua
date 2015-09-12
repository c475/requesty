local ret = {}

ngx.req.get_body_data()

ret.headers = ngx.req.get_headers()
ret.get = ngx.req.get_uri_args()
ret.post = ngx.req.get_post_args()
ret.file = ngx.req.get_body_file()

redis:set(ngx.var.remote_addr, json.encode(ret))

ngx.say([[

    <!doctype html>

    <html>

    <head>
        <title>My Website</title>
    </head>

    <body>
        <h1>This is my new website</h1>
    </body>

    </html>

]])
