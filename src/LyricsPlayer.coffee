window.LyricsPlayerModel = Backbone.Model.extend(

  initialize: () ->
    musicPlayer = this.get('musicPlayer')
    dataProvider = this.get('dataProvider')

    lyricsModels = []

    originalLyricsModel = new MasterLyricsModel(
      musicPlayer: musicPlayer
      linkWords: true
    )
    lyricsModels.push(originalLyricsModel)

    translatedLyricsModel = new LyricsModel(
      musicPlayer: musicPlayer
      linkWords: false
    )
    lyricsModels.push(translatedLyricsModel)

    originalLyricsView = new LyricsView(
      model: originalLyricsModel
    )
    translatedLyricsView = new LyricsView(
      model: translatedLyricsModel
    )

    this.set(
      lyricsModels: [originalLyricsModel, translatedLyricsModel]
      originalLyricsModel: originalLyricsModel
      originalLyricsView: originalLyricsView
      translatedLyricsView: translatedLyricsView
    )

    callback = (lyrics) =>
      originalLyricsModel.set(
        lyrics: lyrics.originalLyrics
      )
      translatedLyricsModel.set(
        lyrics: lyrics.translatedLyrics
      )

    dataProvider.getSegments(musicPlayer.getArtist(), musicPlayer.getSong(), this.get('toLanguage'), callback)

    musicPlayer.onSongChange(() =>
      dataProvider.getSegments(musicPlayer.getArtist(), musicPlayer.getSong(), this.get('toLanguage'), callback)
    )
)

window.LyricsPlayerView = Backbone.View.extend(
  tagName:  "div"
  className: "skee-lyricsPlayer"
  
  initialize: () ->
    this.model.get('originalLyricsView').on("lookup", (word) =>
      this.lookup(word)
    )

  render: () ->
    this.$el.html(_.template($( "script.lyricsPlayer" ).html()))

    originalLyrics = this.model.get('originalLyricsView').render().el
    this.$('.skee-originalLyrics .skee-viewport').append(originalLyrics)
    translatedLyrics = this.model.get('translatedLyricsView').render().el
    this.$('.skee-translatedLyrics .skee-viewport').append(translatedLyrics)

    this.enableButtons()
    this.enableKeyboard()

    return this

  enableButtons: () ->
    this.$('.skee-prev').on('click', () =>
      this.prev())
    this.$('.skee-next').on('click', () =>
      this.next())
    this.$('.skee-togglePlay').on('click', () =>
      this.togglePlay())
    this.$('.skee-toggleRepeatOne').on('click', () =>
      this.toggleRepeatOne())

  enableKeyboard: () ->
    $(window).on('keydown', (event) =>
      switch event.keyCode
        when 65, 37
          # a or left arrow
          this.$('.skee-prev').addClass('active')
          this.prev()
        when 83, 32
          # s or space
          this.$('.skee-togglePlay').addClass('active')
          this.togglePlay()

          event.preventDefault()
        when 68, 39
          # d or right arrow
          this.$('.skee-next').addClass('active')
          this.next()
        when 70, 13
          # f or enter
          this.$('.skee-toggleRepeatOne').addClass('active')
          this.toggleRepeatOne()
        when 27
          # esc
          this.$('.skee-dictionaryContainer').hide()
        else
          console.log(event.keyCode)
    )

    $(window).on('keyup', (event) =>
      this.$('.skee-control').removeClass('active')
    )

  next: () ->
    model.next() for model in this.model.get('lyricsModels')

  prev: () ->
    model.prev() for model in this.model.get('lyricsModels')

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
    if not this.model.get('musicPlayer').isPlaying()
      togglePlayButton.removeClass('skee-paused')
    else
      togglePlayButton.addClass('skee-paused')

  lookup: (word) ->
    musicPlayer = this.model.get('musicPlayer')
    musicPlayer.pause()

    spinner = _.template($( "script.spinner" ).html())
    this.$('.skee-dictionaryResults').html(spinner)
    this.$('.skee-dictionaryContainer').show()
    
    this.$('.skee-closeDictionary').on('click', () =>
      this.$('.skee-dictionaryContainer').hide()
    )

    dictionary = this.model.get('dictionary')
    fromLanguage = this.model.get('fromLanguage')
    toLanguage = this.model.get('toLanguage')
    dictionary.lookup(word, fromLanguage, toLanguage, (result) ->
      this.$('.skee-dictionaryResults').html(result)
    )
)