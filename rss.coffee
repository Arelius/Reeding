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

transformFeedItem = (item) ->
  return {
    title: item.title[0]
    description: item.description[0]
    date: item.pubDate[0]
  }

pullFeed = (address, cb) ->
  getAndParseXML address,
    (err, result) ->
      if !err
        channel = result.rss.channel[0]
        items = []
        for item in channel.item
          items.push transformFeedItem(item)
        cb(
          address: address
          title: channel.title[0]
          description: channel.description[0]
          date: channel.pubDate
          items: items
        )

feeds = {}

updateFeed = (address) ->
  pullFeed address,
    (feed) ->
      feeds[feed.address] = feed
      for item in feed.items
        console.log "XXX", "item:", item
  
  

updateFeed("http://feeds.gawker.com/kotaku/full")