http = require('http')
url = require('url')
fs = require('fs')

responseHeaders = (type) ->
  return {
    'Content-Type': type,
    'Access-Control-Allow-Origin' : '*'
  }

fileResponse = (filename, type) ->
  return (res) ->
    fs.readFile(
      filename,
      (e, data) ->
        if(!e)
          res.writeHead(
            200,
            responseHeaders(type))
          res.end(data)
        else
          res.writeHead(404, {'Content-Type': "text/plain"});
          res.end("Error reading file");
    )


httpServer = http.createServer (req, res) ->
  urlParts = url.parse(req.url, true)

  if(req.url.match(/^\/.*\.coffee/))
    fileResponse("pub/" + req.url.replace(/\//g, ""), "application/javascript")(res)

httpServer.listen(8880, '127.0.0.1')
