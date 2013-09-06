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
        ts = parseInt(lyricsSegments[i].ts)
        if not ts?
          throw new Error "no timestamp"
        if i > 0 and ts <= @timestamps[i - 1]
          throw new Error "timestamp not greater than previous"

        @timestamps.push(ts)
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
      lyrics = this.get('lyrics')
      if not lyrics?
        return

      this.timer = new LyricsTimer(lyrics, () =>
        this.syncView()
      )

      this.syncView()

    # Matches the view to the song playing
    syncView: () ->
      this.set(
        i: this.getPosition()
      )
      this.startTimer()

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
    tagName:  "div"
    className: "skee-pane"

    render: () ->
      this.$el.html(_.template($( "script.lyricsScroller" ).html()))

      lyrics = this.model.get('lyrics')
      if not lyrics? or lyrics.length == 0
        noLyrics = this.showNoLyricsMessage()
        this.$('.skee-viewport').html(noLyrics)
        return this

      if this.model.get('linkWords')
        items = this.getLinkedWordsMarkup()
      else
        items = this.getWithoutLinkedWordsMarkup()

      this.$('.skee-viewport').html(items)

      this.onPositionChange()
      this.listenTo(this.model, 'change:i', () =>
        this.onPositionChange()
      )

      this.$('.skee-lookup').on('click', (event) =>
        this.trigger('lookup', event.target.innerHTML)
      )
      return this

    showNoLyricsMessage: () ->
      return _.template($( "script.noLyrics" ).html())

    getLinkedWordsMarkup: () ->
      lyrics = this.model.get('lyrics')
      lyricsAsSegments = []
      for line in lyrics
        lyricsAsSegments.push(line.text.split(' '))

      linkedLyricsTemplate = $( "script.linkedLyrics" ).html()

      templateModel =
        lyricsAsSegments : lyricsAsSegments
      return _.template(linkedLyricsTemplate, templateModel)

    getWithoutLinkedWordsMarkup: () ->
      lyrics = this.model.get('lyrics')
      lyricsTemplate = $( "script.lyrics" ).html()

      templateModel =
        lyrics : lyrics
      return _.template(lyricsTemplate, templateModel)

    # Update the lines shown in the window and the highlighted line
    onPositionChange: () ->
      i = this.model.get('i')
      if not i?
        return

      topMargin = -(i * 32) + 180
      this.$('.skee-lyrics').css('margin-top', topMargin + 'px')

      this.$('.skee-lyricLine').each((index, el) ->
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
      this.updateLyrics()

      musicPlayer = this.get('musicPlayer')
      musicPlayer.onSongChange(() =>
        this.updateLyrics()
      )

    updateLyrics: () ->
      musicPlayer = this.get('musicPlayer')
      dataProvider = this.get('dataProvider')

      artist = musicPlayer.getArtist()
      song = musicPlayer.getSong()
      language = this.get('toLanguage')

      @lastCallbackId = lastCallbackId = artist + ':' + song + ':' + language

      callback = (lyrics) =>
        if @lastCallbackId is lastCallbackId
          this.set(
            lyrics: lyrics
            isLoading: false
          )

      this.set(
        lyrics: {}
        isLoading: true
      )
      dataProvider.getSegments(artist, song, language, callback)
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
      this.listenTo(this.model, 'change:lyrics', () ->
        this.showLyrics()
      )
      this.listenTo(this.model, 'change:isLoading', () ->
        if this.model.get('isLoading')
          this.showSpinner()
      )
      this.model.get('musicPlayer').onChange(() =>
        this.syncPlayButton()
      )

    render: () ->
      this.$el.html(_.template($( "script.lyricsPlayer" ).html()))
      this.showSpinner()

      this.enableButtons()
      this.enableKeyboard()

      return this

    showSpinner: () ->
      spinner = _.template($( "script.spinner" ).html())
      this.$('.skee-lyricsContainer').html(spinner)

    showLyrics: () ->

      lyrics = this.model.get('lyrics')
      musicPlayer = this.model.get('musicPlayer')

      lyricsModels = []
      this.$('.skee-lyricsContainer').html('')

      # show original lyrics
      originalLyricsModel = new MasterLyricsScrollerModel(
        lyrics: lyrics.originalLyrics
        musicPlayer: musicPlayer
        linkWords: true
      )
      lyricsModels.push(originalLyricsModel)
      originalLyricsView = new LyricsScrollerView(
        model: originalLyricsModel
      )
      originalLyrics = originalLyricsView.render().$el
      originalLyrics.addClass('skee-originalLyrics')
      this.$('.skee-lyricsContainer').append(originalLyrics[0])
      originalLyricsView.on("lookup", (word) =>
        this.lookup(word)
      )

      # show translated lyrics
      translatedLyricsModel = new LyricsScrollerModel(
        lyrics: lyrics.translatedLyrics
        musicPlayer: musicPlayer
        linkWords: false
      )
      lyricsModels.push(translatedLyricsModel)
      translatedLyricsView = new LyricsScrollerView(
        model: translatedLyricsModel
      )
      translatedLyrics = translatedLyricsView.render().$el
      translatedLyrics.addClass('skee-translatedLyrics')
      this.$('.skee-lyricsContainer').append(translatedLyrics[0])

      this.model.set(
        lyricsModels: [originalLyricsModel, translatedLyricsModel]
      )

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
