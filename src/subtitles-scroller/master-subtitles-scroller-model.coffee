define [
  'subtitles.scroller.model'
], (SubtitlesScrollerModel) ->

  ####################################################################
  #
  # MasterSubtitlesScrollerModel
  #
  # The model for a scrolling view of subtitles that has controls that
  # accompany it
  #
  ####################################################################
  MasterSubtitlesScrollerModel = SubtitlesScrollerModel.extend(
    # Sync the music playing to the current index
    syncTrackPosition: () ->
      trackPosition = this.get('subtitles')[this.get('i')]
      if trackPosition?
        this.get('musicPlayer').setTrackPosition(trackPosition.ts)

    # Controls
    prev: () ->
      this.set(
        i: Math.max(this.get('i') - 1, 0)
      )
      this.syncTrackPosition()
      this.startTimer()

    next: () ->
      this.set(
        i: Math.min(this.get('i') + 1, this.get('subtitles').length - 1)
      )
      this.syncTrackPosition()
      this.startTimer()

    play: () ->
      this.get('musicPlayer').play()
      this.startTimer()

    pause: () ->
      this.get('musicPlayer').pause()
      this.clearTimer()

    addRepeatone: () ->
      this.timer.setCallback(() =>
        this.syncTrackPosition()
        this.startTimer()
      )

    removeRepeatone: () ->
      this.timer.setCallback(() =>
        this.syncView()
      )
  )

  return MasterSubtitlesScrollerModel