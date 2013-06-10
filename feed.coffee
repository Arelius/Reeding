rss = require('./rss')

feeds = {}

updateFeedData = (feed) ->
  feeds[feed.address] = feed

updateFeed = (address) ->
  rss.pullFeed address,
    (mFeed) ->
      updateFeedData(mFeed)

exports.updateFeed = updateFeed
