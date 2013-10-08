define () ->
  
  ####################################################################
  #
  # SubtitlesTimer
  #
  # Given an array of subtitles objects with a "ts" field, notifies
  # listeners when the segment updates.  Must manually start and
  # stop the timer on user events.  It will naturally terminate
  # when it runs out of segments.
  #
  ####################################################################
  class SubtitlesTimer

    constructor: (subtitlesSegments, callback) ->
      # purify data
      @timestamps = []
      i = 0
      while subtitlesSegments[i]
        ts = parseInt(subtitlesSegments[i].ts)
        if not ts?
          throw new Error "no timestamp"
        #if i > 0 and ts <= @timestamps[i - 1]
        #  throw new Error "timestamp not greater than previous"

        @timestamps.push(ts)
        i++

      @callback = callback
      @timeoutId = null

    start: (i, currentTime) ->
      nextTime = @timestamps[i+1]
      if not nextTime?
        return

      delta = nextTime - currentTime
      next = () =>
        @callback()

      @timeoutId = setTimeout(next, Math.max(delta, 0))

    clear: () ->
      clearTimeout(@timeoutId)

    setCallback: (callback) ->
      @callback = callback