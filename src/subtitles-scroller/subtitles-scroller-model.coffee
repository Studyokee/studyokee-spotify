define [
  'backbone',
  'subtitles.timer'
], (Backbone, SubtitlesTimer) ->
  
  ####################################################################
  #
  # SubtitlesScrollerModel
  #
  # The model for a scrolling view of subtitles
  #
  ####################################################################
  SubtitlesScrollerModel = Backbone.Model.extend(
    timer: null

    initialize: () ->
      subtitles = this.get('subtitles')
      if not subtitles?
        return

      this.timer = new SubtitlesTimer(subtitles, () =>
        this.syncView()
      )

      this.syncView()

    # Matches the view to the song playing
    syncView: () ->
      this.set(
        i: this.getPosition()
      )
      this.startTimer()

    # Get the index of the line of subtitles corresponding to the current track position
    getPosition: () ->
      subtitles = this.get('subtitles')
      i = 0
      currentTime = this.get('musicPlayer').getTrackPosition()
      while subtitles[i]? and subtitles[i].ts <= currentTime
        i++

      return i - 1

    startTimer: () ->
      if this.timer?
        this.timer.clear()
        if this.get('musicPlayer').isPlaying()
          this.timer.start(this.get('i'), this.get('musicPlayer').getTrackPosition())

    clearTimer: () ->
      if this.timer?
        this.timer.clear()

    # Controls
    prev: () ->
      this.set(
        i: Math.max(this.get('i') - 1, 0)
      )
      this.startTimer()

    next: () ->
      this.set(
        i: Math.min(this.get('i') + 1, this.get('subtitles').length - 1)
      )
      this.startTimer()

    play: () ->
      this.startTimer()

    pause: () ->
      this.clearTimer()

    destroy: () ->
      this.clearTimer()
  )

  return SubtitlesScrollerModel