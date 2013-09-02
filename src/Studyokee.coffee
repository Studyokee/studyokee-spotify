# requires Lyrics.coffee

AppView = Backbone.View.extend(
  el: $("#skee")
  
  initialize: () ->
    this.enableButtons()
    this.enableKeyboard()

    this.$('#skee-original').append(this.model.get('originalLyricsView').render().el)
    this.$('#skee-translation').append(this.model.get('translatedLyricsView').render().el)

  enableButtons: () ->
    this.$('.skee-prev').on('click', () =>
      model.prev() for model in this.model.get('lyricsModels'))
    this.$('.skee-next').on('click', () =>
      model.next() for model in this.model.get('lyricsModels'))

    this.$('.skee-togglePlay').on('click', () =>
      this.togglePlay())
    this.syncPlayButton()

    this.$('.skee-toggleRepeatOne').on('click', () =>
      this.toggleRepeatOne())

  enableKeyboard: () ->
    window.onkeydown = (event) =>
      this.handleKeyEvents(event)
    window.onkeyup = (event) =>
      this.$('.skee-control').removeClass('active')

  togglePlay: () ->
    if this.model.get('musicPlayer').isPlaying()
      model.pause() for model in this.model.get('lyricsModels')
    else
      model.play() for model in this.model.get('lyricsModels')

    this.syncPlayButton()

  toggleRepeatOne: () ->
    repeatOneButton = this.$('.skee-toggleRepeatOne')
    if repeatOneButton.hasClass('selected')
      repeatOneButton.removeClass('selected')
      this.model.get('originalLyricsModel').removeRepeatone()
    else
      repeatOneButton.addClass('selected')
      this.model.get('originalLyricsModel').addRepeatone()

  syncPlayButton: () ->
    togglePlayButton = this.$('.skee-togglePlay')
    if this.model.get('musicPlayer').isPlaying()
      togglePlayButton.removeClass('skee-paused')
    else
      togglePlayButton.addClass('skee-paused')

  handleKeyEvents: (event) ->
    switch event.keyCode
      when 65, 37
        # a or left arrow
        this.$('.skee-prev').addClass('active')
        model.prev() for model in this.model.get('lyricsModels')
      when 83, 32
        # s or space
        this.$('.skee-togglePlay').addClass('active')
        this.togglePlay()
        event.preventDefault()
      when 68, 39
        # d or right arrow
        this.$('.skee-next').addClass('active')
        model.next() for model in this.model.get('lyricsModels')
      when 70, 13
        # f or enter
        this.$('.skee-toggleRepeatOne').addClass('active')
        this.toggleRepeatOne()
      else
        console.log(event.keyCode)

)
AppModel = Backbone.Model.extend(

  initialize: () ->
    musicPlayer = new SpotifyPlayer()
    #dataProvider = new TuneWikiDataProvider()
    dataProvider = new TestTranslationDataProvider()

    lyricsModels = []

    originalLyricsModel = new MasterLyricsModel(
      musicPlayer: musicPlayer
    )
    originalLyricsView = new LyricsView(
      model: originalLyricsModel
    )

    lyricsModels.push(originalLyricsModel)

    translatedLyricsModel = new LyricsModel(
      musicPlayer: musicPlayer
    )
    translatedLyricsView = new LyricsView(
      model: translatedLyricsModel
    )
    lyricsModels.push(translatedLyricsModel)

    this.set(
      originalLyricsView: originalLyricsView
      translatedLyricsView: translatedLyricsView
      musicPlayer: musicPlayer
      lyricsModels: [originalLyricsModel, translatedLyricsModel]
      originalLyricsModel: originalLyricsModel
    )

    callback = (lyrics) =>
      originalLyricsModel.set(
        lyrics: lyrics.originalLyrics
      )
      translatedLyricsModel.set(
        lyrics: lyrics.translatedLyrics
      )

    language = 'en'
    dataProvider.getSegments(musicPlayer.getArtist(), musicPlayer.getSong(), language, callback)

    musicPlayer.onSongChange(() ->
      dataProvider.getSegments(musicPlayer.getArtist(), musicPlayer.getSong(), language, callback)
    )

)
app = new AppModel
appView = new AppView(
  model: app
)