# requires Lyrics.coffee

AppView = Backbone.View.extend(
  el: $("#skee")
  
  initialize: () ->
    this.$('#skee-original').append(this.model.get('originalLyricsView').render().el)
    this.$('#skee-translation').append(this.model.get('translatedLyricsView').render().el)

    # Add controls
    this.enableButtons()
    this.enableKeyboard()

  enableButtons: () ->
    this.$('#skee-prev').on('click', () =>
      model.prev() for model in this.model.get('lyricsModels'))
    this.$('#skee-next').on('click', () =>
      model.next() for model in this.model.get('lyricsModels'))

    this.$('#skee-togglePlay').on('click', () =>
      this.togglePlay())
    this.syncPlayButton()

    this.$('#skee-toggleRepeatOne').on('click', () =>
      this.toggleRepeatOne())

  enableKeyboard: () ->
    window.onkeypress = (event) =>
      this.handleKeyEvents(event)

  togglePlay: () ->
    if this.model.get('musicPlayer').isPlaying()
      model.pause() for model in this.model.get('lyricsModels')
    else
      model.play() for model in this.model.get('lyricsModels')

    this.syncPlayButton()

  toggleRepeatOne: () ->
    repeatOneButton = this.$('#skee-toggleRepeatOne')
    if repeatOneButton.hasClass('selected')
      repeatOneButton.removeClass('selected')
      this.model.get('originalLyricsModel').removeRepeatone()
    else 
      repeatOneButton.addClass('selected')
      this.model.get('originalLyricsModel').addRepeatone()

  syncPlayButton: () ->
    text = if this.model.get('musicPlayer').isPlaying() then 'pause' else 'play'
    this.$('#skee-togglePlay').html(text)

  handleKeyEvents: (event) ->
    switch event.keyCode
      when 97
        # a (left arrow)
        model.prev() for model in this.model.get('lyricsModels')
      when 100
        # d (right arrow)
        model.next() for model in this.model.get('lyricsModels')
      when 115
        # s (down arrow)
        this.togglePlay()
      when 102
        # f 
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