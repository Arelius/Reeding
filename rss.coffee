http = require('http')
https = require('https')
url = require('url')
xml2js = require('xml2js')

getAndParseXML = (address, cb) ->
  addr = url.parse(address)
  parser = new xml2js.Parser()

  resBody = ""
  proto = http
  if addr.protocol == "https:"
    proto = https
  req = proto.request(
    {
      host: addr.hostname
      port: addr.port
      path: addr.pathname
      method: 'GET'
    },
    (res) ->
      switch(res.statusCode)
        when 200
          res.on 'error', (err) ->
          res.on 'data', (chunk) ->
            resBody += chunk
          res.on 'end', () ->
            parser.parseString(resBody, cb)
  )
  req.end()

transformFeedItem = (item, feedAddress) ->
  ret = {
    title: item.title[0]
    description: item.description[0]
    feed: feedAddress
  }
  date = item.pubDate?[0]
  guid = item.guid?[0]['_']
  return ret

pullFeed = (address, cb) ->
  getAndParseXML address,
    (err, result) ->
      if !err
        channel = result.rss.channel[0]
        items = []
        mFeed = {
          address: address
          title: channel.title[0]
          description: channel.description[0]
          items: items
        }
        if channel.pubDate?
          mFeed.date = channel.pubDate
        for item in channel.item
          items.push transformFeedItem(item, mFeed)
        cb(mFeed)
  
exports.pullFeed = pullFeed
