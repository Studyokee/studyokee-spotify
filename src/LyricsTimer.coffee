####################################################################
# 
# LyricsTimer.coffee
#
# Given an array of lyrics objects with a "ts" field, notifies
# listeners when the segment updates.  Must manually start and
# stop the timer on user events.  It will naturally terminate
# when it runs out of segments.
#
####################################################################

class LyricsTimer

  constructor: (lyricsSegments) ->
    # purify data
    @timestamps = []
    i = 0
    while lyricsSegments[i]
      if not lyricsSegments[i].ts?
        throw "no timestamp"
      if i > 0 and lyricsSegments[i].ts <= @timestamps[i - 1]
        throw "timestamp not greater than previous"

      @timestamps.push(lyricsSegments[i].ts)
      i++

    @listeners = []
    @timeoutId = null

  addListener: (fn) ->
    @listeners.push(fn)

  start: (currentTime) ->
    @sync(currentTime)

  stop: () ->
    clearTimeout(@timeoutId)

  sync: (currentTime) ->
    # find correct timestamp    
    i = 0
    while @timestamps[i] < currentTime
      i++

    # notifyListeners
    fn(i) for fn in @listeners

    # set next expected time to find segment and update listeners
    nextTime = @timestamps[i+1]
    if not nextTime?
      return

    delta = nextTime - currentTime
    next = () =>
      @sync(currentTime + delta)
    clearTimeout(@timeoutId)
    @timeoutId = setTimeout(next, Math.max(delta, 0))

window.LyricsTimer = LyricsTimer