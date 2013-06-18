class LyricsTimer

  constructor: (@musicPlayer, @lyrics) ->
    @listeners = []

  addListener: (fn) ->
    @listeners.push(fn)

  notifyListeners: (i) ->
    fn(i) for fn in @listeners

  setCurrentIndex: (i) ->
    # only update index if the segment exists
    if not @lyrics[i]?
      return

    @notifyListeners(i)

    # if music is playing and there is a valid next segment, start timer
    nextSegment = @lyrics[i+1]
    if @musicPlayer.isPlaying() and nextSegment and nextSegment.ts?
      delta = nextSegment.ts - @musicPlayer.getTrackPosition()
      next = () =>
        @setCurrentIndex(i+1)
      setTimeout(next, Math.max(delta, 0))

  init: () ->
    @setCurrentIndex(0)

window.LyricsTimer = LyricsTimer