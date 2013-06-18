class LyricsTimer
  musicPlayer = null
  lyrics = null
  listeners = []

  constructor: (_musicPlayer, _lyrics) ->
    musicPlayer = _musicPlayer
    lyrics = _lyrics

  addListener: (fn) ->
    listeners.push(fn)

  notifyListeners = (i) ->
    fn(i) for fn in listeners

  setCurrentIndex = (i) ->
    if not lyrics[i]?
      return

    notifyListeners(i)

    if not musicPlayer.isPlaying()
      return

    nextSegment = lyrics[i+1]
    if nextSegment and nextSegment.ts?
      delta = nextSegment.ts - musicPlayer.getTrackPosition()
      next = () ->
        setCurrentIndex(i+1)
      setTimeout(next, Math.max(delta, 0))

  init = () ->
    setCurrentIndex(0)

  setTimeout(init, 0)

window.LyricsTimer = LyricsTimer