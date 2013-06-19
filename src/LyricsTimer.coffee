class LyricsTimer

  constructor: (@musicPlayer, @lyrics) ->
    @listeners = []

  addListener: (fn) ->
    @listeners.push(fn)

  notifyListeners: (i) ->
    fn(i) for fn in @listeners

  sync: () ->
    trackPosition = @musicPlayer.getTrackPosition()
    
    # find correct segment    
    i = 0
    while @lyrics[i+1] and @lyrics[i+1].ts < trackPosition
      i++

    @notifyListeners(i)

    nextSegment = @lyrics[i+1]
    if not nextSegment? or not @musicPlayer.isPlaying()
      return

    # set next expected time to sync
    delta = nextSegment.ts - trackPosition
    next = () =>
      @sync()
    setTimeout(next, Math.max(delta, 0))

window.LyricsTimer = LyricsTimer