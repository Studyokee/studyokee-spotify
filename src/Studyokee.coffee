# requires Lyrics.coffee

AppView = Backbone.View.extend(
  el: $("#skee")
  
  initialize: () ->
    this.musicPlayer = new SpotifyPlayer()
    dataProvider = new TuneWikiDataProvider()
    #dataProvider = new TestTranslationDataProvider()

    this.lyricsModels = []

    this.originalLyricsModel = new MasterLyricsModel(
      musicPlayer: this.musicPlayer
      dataProvider: dataProvider
    )
    originalLyricsView = new LyricsView(
      model: this.originalLyricsModel
    )

    this.$('#skee-original').append(originalLyricsView.render().el)
    this.lyricsModels.push(this.originalLyricsModel)

    translatedLyricsModel = new LyricsModel(
      musicPlayer: this.musicPlayer
      dataProvider: dataProvider
      language: 'en'
    )
    translatedLyricsView = new LyricsView(
      model: translatedLyricsModel
    )
    this.$('#skee-translation').append(translatedLyricsView.render().el)
    this.lyricsModels.push(translatedLyricsModel)

    # Add controls
    this.enableButtons()
    this.enableKeyboard()


  enableButtons: () ->
    this.$('#skee-prev').on('click', () =>
      model.prev() for model in this.lyricsModels)
    this.$('#skee-next').on('click', () =>
      model.next() for model in this.lyricsModels)

    this.$('#skee-togglePlay').on('click', () =>
      this.togglePlay())
    this.syncPlayButton()

    this.$('#skee-toggleRepeatOne').on('click', () =>
      this.toggleRepeatOne())

  enableKeyboard: () ->
    window.onkeypress = (event) =>
      this.handleKeyEvents(event)

  togglePlay: () ->
    if this.musicPlayer.isPlaying()
      model.pause() for model in this.lyricsModels
    else
      model.play() for model in this.lyricsModels

    this.syncPlayButton()

  toggleRepeatOne: () ->
    repeatOneButton = this.$('#skee-toggleRepeatOne')
    if repeatOneButton.hasClass('selected')
      repeatOneButton.removeClass('selected')
      this.originalLyricsModel.removeRepeatone()
    else 
      repeatOneButton.addClass('selected')
      this.originalLyricsModel.addRepeatone()

  syncPlayButton: () ->
    text = if this.musicPlayer.isPlaying() then 'pause' else 'play'
    this.$('#skee-togglePlay').html(text)

  handleKeyEvents: (event) ->
    switch event.keyCode
      when 97
        # a (left arrow)
        model.prev() for model in this.lyricsModels
      when 100
        # d (right arrow)
        model.next() for model in this.lyricsModels
      when 115
        # s (down arrow)
        this.togglePlay()
      when 102
        # f 
        this.toggleRepeatOne()
      else
        console.log(event.keyCode)

)

app = new Backbone.Model
appView = new AppView(
  model: app
)