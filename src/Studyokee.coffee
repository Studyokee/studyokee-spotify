# requires Lyrics.coffee

AppView = Backbone.View.extend(
  el: $("#skee")
  
  initialize: () ->
    this.enableButtons()
    this.enableKeyboard()

    this.$('#skee-original').append(this.model.get('originalLyricsView').render().el)
    this.$('#skee-translation').append(this.model.get('translatedLyricsView').render().el)

    this.$('.skee-closeDictionary').on('click', () =>
      this.model.set(
        showDictionary: false
      )
    )
    this.listenTo(this.model, 'change:showDictionary', this.toggleDictionary)
    this.listenTo(this.model, 'change:dictionaryMarkup', this.showLookup)

  toggleDictionary: () ->
    if this.model.get('showDictionary')
      this.showDictionary()
    else
      this.hideDictionary()

  showLookup: () ->
    templateModel = 
      text: this.model.get('dictionaryMarkup')
    dictionaryMarkup = _.template("<div><%= text %></div>", templateModel)
    this.$('.skee-dictionaryResults').html(dictionaryMarkup)

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
    if not this.model.get('musicPlayer').isPlaying()
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
      when 27
        this.hideDictionary()
      else
        console.log(event.keyCode)

  showDictionary: () ->
    this.$('.skee-dictionaryContainer').show()
    this.$('.skee-lyricsContainer').hide() 

  hideDictionary: () ->
    this.$('.skee-dictionaryContainer').hide()
    this.$('.skee-lyricsContainer').show() 
)
AppModel = Backbone.Model.extend(

  initialize: () ->
    musicPlayer = new SpotifyPlayer()
    dataProvider = new TuneWikiDataProvider()
    #dataProvider = new TestTranslationDataProvider()

    lyricsModels = []

    originalLyricsModel = new MasterLyricsModel(
      musicPlayer: musicPlayer
      linkWords: true
    )
    originalLyricsView = new LyricsView(
      model: originalLyricsModel
    )
    originalLyricsView.on("lookup", (word) =>
      musicPlayer.pause()
      this.lookup(word)
    )

    lyricsModels.push(originalLyricsModel)

    translatedLyricsModel = new LyricsModel(
      musicPlayer: musicPlayer
      linkWords: false
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
      dictionaryMarkup: null
      showDictionary: false
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

  lookup: (word) ->
    this.set(showDictionary: true)
    onSuccess = (result) =>
      dictionaryMarkup = eval('(' + result + ')').text
      this.set(dictionaryMarkup: dictionaryMarkup)

    $.ajax(
      url: 'http://yabla.com/player_service.php?action=lookup&word=' + word + '&word_lang_id=es&output_lang_id=en'
      type: 'GET'
      success: onSuccess
    )


)
app = new AppModel
appView = new AppView(
  model: app
)