define [
  'backbone'
], (Backbone) ->

  ####################################################################
  #
  # SubtitlesPlayerModel
  #
  # The model for the collection of original subtitles, translated
  # subtitles, controls, and dictionary lookup
  #
  ####################################################################
  SubtitlesPlayerModel = Backbone.Model.extend(

    initialize: () ->
      this.updateSubtitles()

      musicPlayer = this.get('musicPlayer')
      musicPlayer.onSongChange(() =>
        this.updateSubtitles()
      )
      this.on('subtitlesUpdated', () =>
        this.updateSubtitles()
        musicPlayer.setTrackPosition(0)
      )

    updateSubtitles: () ->
      musicPlayer = this.get('musicPlayer')
      dataProvider = this.get('dataProvider')

      artist = musicPlayer.getArtist()
      song = musicPlayer.getSong()
      language = this.get('toLanguage')

      @lastCallbackId = lastCallbackId = artist + ':' + song + ':' + language

      callback = (subtitles) =>
        if @lastCallbackId is lastCallbackId
          this.set(
            subtitles: subtitles
            isLoading: false
          )

      this.set(
        subtitles: {}
        isLoading: true
      )
      dataProvider.getSegments(artist, song, language, callback)
  )

  return SubtitlesPlayerModel