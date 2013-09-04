AppModel = Backbone.Model.extend(

  initialize: () ->
    musicPlayer = new SpotifyPlayer()
    #dataProvider = new TuneWikiDataProvider()
    dataProvider = new TestTranslationDataProvider()
    dictionary = new YablaDictionaryDataProvider()

    lyricsPlayerModel = new LyricsPlayerModel(
      dataProvider: dataProvider
      musicPlayer: musicPlayer
      dictionary: dictionary
      fromLanguage: 'fr'
      toLanguage: 'en'
    )
    lyricsPlayerView = new LyricsPlayerView(
      model: lyricsPlayerModel
    )

    this.set(
      lyricsPlayerView: lyricsPlayerView
    )

)

AppView = Backbone.View.extend(
  el: $("#skee")
  
  initialize: () ->
    lyricsPlayer = this.model.get('lyricsPlayerView').render().el
    this.$('.skee-main').append(lyricsPlayer)
)

app = new AppModel
appView = new AppView(
  model: app
)