require [
  'spotify.player',
  'studyokee.translation.data.provider',
  'yabla.dictionary.data.provider',
  'lyrics',
  'lyrics.upload'
  'backbone'
], (SpotifyPlayer, StudyokeeTranslationDataProvider, YablaDictionaryDataProvider, Lyrics, LyricsUpload, Backbone) ->
  StudyokeeModel = Backbone.Model.extend(

    initialize: () ->
      musicPlayer = new SpotifyPlayer()
      dataProvider = new StudyokeeTranslationDataProvider()
      dictionary = new YablaDictionaryDataProvider()

      lyricsPlayerModel = new Lyrics.model(
        dataProvider: dataProvider
        musicPlayer: musicPlayer
        dictionary: dictionary
        fromLanguage: 'es'
        toLanguage: 'en'
      )
      lyricsPlayerView = new Lyrics.view(
        model: lyricsPlayerModel
      )

      this.set(
        lyricsPlayerView: lyricsPlayerView
      )

  )

  StudyokeeView = Backbone.View.extend(
    el: $("#skee")
    
    initialize: () ->
      lyricsPlayer = this.model.get('lyricsPlayerView').render().el
      this.$('.skee-main').append(lyricsPlayer)
  )

  app = new StudyokeeModel()
  appView = new StudyokeeView(
    model: app
  )