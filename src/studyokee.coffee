require [
  'spotify.player',
  'tune.wiki.translation.data.provider',
  'test.translation.data.provider',
  'yabla.dictionary.data.provider',
  'lyrics',
  'backbone'
], (SpotifyPlayer, TuneWikiTranslationDataProvider, TestTranslationDataProvider, YablaDictionaryDataProvider, Lyrics, Backbone) ->
  StudyokeeModel = Backbone.Model.extend(

    initialize: () ->
      musicPlayer = new SpotifyPlayer()
      #dataProvider = new TuneWikiTranslationDataProvider()
      dataProvider = new TestTranslationDataProvider()
      dictionary = new YablaDictionaryDataProvider()

      lyricsPlayerModel = new Lyrics.model(
        dataProvider: dataProvider
        musicPlayer: musicPlayer
        dictionary: dictionary
        fromLanguage: 'fr'
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