http = require('http')
url = require('url')
xml2js = require('xml2js')

getAndParseXML = (address, cb) ->
  addr = url.parse(address)
  parser = new xml2js.Parser()

  resBody = ""

  req = http.request(
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
  return {
    title: item.title[0]
    description: item.description[0]
    date: item.pubDate[0]
    guid: item.guid[0]['_']
    feed: {
      address: feedAddress
    }
  }

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
          date: channel.pubDate
          items: items
        }
        for item in channel.item
          items.push transformFeedItem(item, mFeed)
        cb(mFeed)
  
exports.pullFeed = pullFeed
