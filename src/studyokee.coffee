require [
  'spotify.player',
  'studyokee.translation.data.provider',
  'yabla.dictionary.data.provider',
  'subtitles.player.model',
  'subtitles.player.view',
  'backbone'
], (SpotifyPlayer, StudyokeeTranslationDataProvider, YablaDictionaryDataProvider, SubtitlesPlayerModel, SubtitlesPlayerView, Backbone) ->
  StudyokeeModel = Backbone.Model.extend(

    initialize: () ->
      musicPlayer = new SpotifyPlayer()
      dataProvider = new StudyokeeTranslationDataProvider()
      dictionary = new YablaDictionaryDataProvider()

      subtitlesPlayerModel = new SubtitlesPlayerModel(
        dataProvider: dataProvider
        musicPlayer: musicPlayer
        dictionary: dictionary
        fromLanguage: 'es'
        toLanguage: 'en'
      )
      subtitlesPlayerView = new SubtitlesPlayerView(
        model: subtitlesPlayerModel
      )

      this.set(
        subtitlesPlayerView: subtitlesPlayerView
      )

  )

  StudyokeeView = Backbone.View.extend(
    el: $("#skee")
    
    initialize: () ->
      subtitlesPlayer = this.model.get('subtitlesPlayerView').render().el
      this.$('.skee-main').append(subtitlesPlayer)
  )

  app = new StudyokeeModel()
  appView = new StudyokeeView(
    model: app
  )