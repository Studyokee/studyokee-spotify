define [
  'backbone'
], (Backbone) ->

  ####################################################################
  #
  # LyricsTimer
  #
  # Given an array of lyrics objects with a "ts" field, notifies
  # listeners when the segment updates.  Must manually start and
  # stop the timer on user events.  It will naturally terminate
  # when it runs out of segments.
  #
  ####################################################################
  class LyricsTimer

    constructor: (lyricsSegments, callback) ->
      # purify data
      @timestamps = []
      i = 0
      while lyricsSegments[i]
        if not lyricsSegments[i].ts?
          throw new Error "no timestamp"
        if i > 0 and lyricsSegments[i].ts <= @timestamps[i - 1]
          throw new Error "timestamp not greater than previous"

        @timestamps.push(lyricsSegments[i].ts)
        i++

      @callback = callback
      @timeoutId = null

    start: (i, currentTime) ->
      nextTime = @timestamps[i+1]
      if not nextTime?
        return

      delta = nextTime - currentTime
      next = () =>
        @callback()

      @timeoutId = setTimeout(next, Math.max(delta, 0))

    clear: () ->
      clearTimeout(@timeoutId)

    setCallback: (callback) ->
      @callback = callback

  ####################################################################
  #
  # LyricsScrollerModel
  #
  # The model for a scrolling view of lyrics
  #
  ####################################################################
  LyricsScrollerModel = Backbone.Model.extend(
    timer: null

    initialize: () ->
      fn = () ->
        this.onSongChange()
      this.listenTo(this, 'change:lyrics', fn)

    onSongChange: () ->
      if this.timer?
        this.timer.clear()
      this.timer = new LyricsTimer(this.get('lyrics'), () =>
        this.syncView()
        this.startTimer()
      )

      this.syncView()
      this.startTimer()

    # Matches the view to the song playing
    syncView: () ->
      this.set(
        i: this.getPosition()
      )

    # Get the index of the line of lyrics corresponding to the current track position
    getPosition: () ->
      lyrics = this.get('lyrics')
      i = 0
      currentTime = this.get('musicPlayer').getTrackPosition()
      while lyrics[i]? and lyrics[i].ts < currentTime
        i++

      return i - 1

    startTimer: () ->
      this.timer.clear()
      if this.get('musicPlayer').isPlaying()
        this.timer.start(this.get('i'), this.get('musicPlayer').getTrackPosition())

    clearTimer: () ->
      this.timer.clear()

    # Controls
    prev: () ->
      this.set(
        i: Math.max(this.get('i') - 1, 0)
      )
      this.startTimer()

    next: () ->
      this.set(
        i: Math.min(this.get('i') + 1, this.get('lyrics').length - 1)
      )
      this.startTimer()

    play: () ->
      this.startTimer()

    pause: () ->
      this.clearTimer()
  )

  ####################################################################
  #
  # MasterLyricsScrollerModel
  #
  # The model for a scrolling view of lyrics that has controls that
  # accompany it
  #
  ####################################################################
  MasterLyricsScrollerModel = LyricsScrollerModel.extend(
    # Sync the music playing to the current index
    syncTrackPosition: () ->
      trackPosition = this.get('lyrics')[this.get('i')]
      if trackPosition?
        this.get('musicPlayer').setTrackPosition(trackPosition.ts)

    # Controls
    prev: () ->
      this.set(
        i: Math.max(this.get('i') - 1, 0)
      )
      this.syncTrackPosition()
      this.startTimer()

    next: () ->
      this.set(
        i: Math.min(this.get('i') + 1, this.get('lyrics').length - 1)
      )
      this.syncTrackPosition()
      this.startTimer()

    play: () ->
      this.get('musicPlayer').play()
      this.startTimer()

    pause: () ->
      this.get('musicPlayer').pause()
      this.clearTimer()

    addRepeatone: () ->
      this.timer.setCallback(() =>
        this.syncTrackPosition()
        this.startTimer()
      )

    removeRepeatone: () ->
      this.timer.setCallback(() =>
        this.syncView()
        this.startTimer()
      )
  )

  ####################################################################
  #
  # LyricsScrollerView
  #
  # The view for a scrolling view of lyrics
  #
  ####################################################################
  LyricsScrollerView = Backbone.View.extend(
    tagName:  "ul"
    className: "skee-lyrics"

    initialize: () ->
      this.listenTo(this.model, 'change:lyrics', this.render)
      this.listenTo(this.model, 'change:i', this.onPositionChange)

    render: () ->
      lyrics = this.model.get('lyrics')
      if not lyrics?
        return this

      if this.model.get('linkWords')
        this.renderWithLinkedWords()
      else
        this.renderWithoutLinkedWords()

      this.onPositionChange()

      this.$('.skee-lookup').on('click', (event) =>
        this.trigger('lookup', event.target.innerHTML)
      )

      return this

    renderWithLinkedWords: () ->
      lyrics = this.model.get('lyrics')
      lyricsAsSegments = []
      for line in lyrics
        lyricsAsSegments.push(line.text.split(' '))

      linkedLyricsTemplate = $( "script.linkedLyrics" ).html()

      templateModel =
        lyricsAsSegments : lyricsAsSegments
      this.$el.html(_.template(linkedLyricsTemplate, templateModel))

    renderWithoutLinkedWords: () ->
      lyrics = this.model.get('lyrics')
      lyricsTemplate = $( "script.lyrics" ).html()

      templateModel =
        lyrics : lyrics
      this.$el.html(_.template(lyricsTemplate, templateModel))

    # Update the lines shown in the window and the highlighted line
    onPositionChange: () ->
      i = this.model.get('i')
      topMargin = -(i * 48) + 180
      this.$el.css('margin-top', topMargin + 'px')

      this.$('.lyricLine').each((index, el) ->
        if index is i
          $(el).addClass('selected')
        else
          $(el).removeClass('selected')
      )
  )

  ####################################################################
  #
  # LyricsPlayerModel
  #
  # The model for the collection of original lyrics, translated
  # lyrics, controls, and dictionary lookup
  #
  ####################################################################
  LyricsPlayerModel = Backbone.Model.extend(

    initialize: () ->
      musicPlayer = this.get('musicPlayer')
      dataProvider = this.get('dataProvider')

      lyricsModels = []

      originalLyricsModel = new MasterLyricsScrollerModel(
        musicPlayer: musicPlayer
        linkWords: true
      )
      lyricsModels.push(originalLyricsModel)

      translatedLyricsModel = new LyricsScrollerModel(
        musicPlayer: musicPlayer
        linkWords: false
      )
      lyricsModels.push(translatedLyricsModel)

      originalLyricsView = new LyricsScrollerView(
        model: originalLyricsModel
      )
      translatedLyricsView = new LyricsScrollerView(
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

  ####################################################################
  #
  # LyricsPlayerView
  #
  # The view for the collection of original lyrics, translated
  # lyrics, controls, and dictionary lookup
  #
  ####################################################################
  LyricsPlayerView = Backbone.View.extend(
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

  module =
    model: LyricsPlayerModel
    view: LyricsPlayerView

  return module
