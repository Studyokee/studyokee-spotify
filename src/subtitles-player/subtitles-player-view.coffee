define [
  'backbone',
  'subtitles.scroller.model',
  'master.subtitles.scroller.model',
  'subtitles.scroller.view',
  'subtitles.upload.model',
  'subtitles.upload.view'
], (Backbone, SubtitlesScrollerModel, MasterSubtitlesScrollerModel, SubtitlesScrollerView, SubtitlesUploadModel, SubtitlesUploadView) ->

  ####################################################################
  #
  # SubtitlesPlayerView
  #
  # The view for the collection of original subtitles, translated
  # subtitles, controls, and dictionary lookup
  #
  ####################################################################
  SubtitlesPlayerView = Backbone.View.extend(
    tagName:  "div"
    className: "skee-subtitlesPlayer"
    
    initialize: () ->
      this.listenTo(this.model, 'change:subtitles', () ->
        this.showSubtitles()
      )
      this.listenTo(this.model, 'change:isLoading', () ->
        if this.model.get('isLoading')
          this.showSpinner()
      )
      this.model.get('musicPlayer').onChange(() =>
        this.syncPlayButton()
        #model.syncView() for model in this.model.get('subtitlesModels')
      )

    render: () ->
      this.$el.html(_.template($( "script.subtitlesPlayer" ).html()))
      this.showSpinner()

      this.enableButtons()
      this.enableKeyboard()

      this.$('.skee-upload').on('click', (event) =>
        this.upload()
      )

      return this

    showSpinner: () ->
      spinner = _.template($( "script.spinner" ).html())
      this.$('.skee-subtitlesContainer').html(spinner)

    showSubtitles: () ->
      # destroy any old subtitles scrollers
      subtitlesModels = this.model.get('subtitlesModels')
      if subtitlesModels?
        model.destroy() for model in subtitlesModels
      this.$('.skee-subtitlesContainer').html('')

      subtitles = this.model.get('subtitles')
      musicPlayer = this.model.get('musicPlayer')

      # show original subtitles
      originalSubtitlesModel = new MasterSubtitlesScrollerModel(
        subtitles: subtitles.originalSubtitles
        musicPlayer: musicPlayer
        linkWords: true
        class: 'skee-originalSubtitles'
      )
      originalSubtitlesView = new SubtitlesScrollerView(
        model: originalSubtitlesModel
      )
      this.$('.skee-subtitlesContainer').append(originalSubtitlesView.render().el)

      originalSubtitlesView.on("lookup", (word) =>
        this.lookup(word)
      )

      # show translated subtitles
      translatedSubtitlesModel = new SubtitlesScrollerModel(
        subtitles: subtitles.translatedSubtitles
        musicPlayer: musicPlayer
        linkWords: false
        class: 'skee-translatedSubtitles'
      )
      translatedSubtitlesView = new SubtitlesScrollerView(
        model: translatedSubtitlesModel
      )
      this.$('.skee-subtitlesContainer').append(translatedSubtitlesView.render().el)

      this.model.set(
        subtitlesModels: [originalSubtitlesModel, translatedSubtitlesModel]
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
      onKeyDown = (event) =>
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
          when 70
            # f
            this.$('.skee-toggleRepeatOne').addClass('active')
            this.toggleRepeatOne()
          when 27
            # esc
            this.$('.skee-dictionaryContainer').hide()
          else
            console.log(event.keyCode)

      this.on('enableKeyboard', () ->
        $(window).on('keydown', onKeyDown)
      )
      this.on('disableKeyboard', () ->
        $(window).unbind('keydown', onKeyDown)
      )
      this.trigger('enableKeyboard')

      $(window).on('keyup', (event) =>
        this.$('.skee-control').removeClass('active')
      )

    next: () ->
      model.next() for model in this.model.get('subtitlesModels')

    prev: () ->
      model.prev() for model in this.model.get('subtitlesModels')

    togglePlay: () ->
      if this.model.get('musicPlayer').isPlaying()
        model.pause() for model in this.model.get('subtitlesModels')
      else
        model.play() for model in this.model.get('subtitlesModels')

      this.syncPlayButton()

    toggleRepeatOne: () ->
      repeatOneButton = this.$('.skee-toggleRepeatOne')
      if repeatOneButton.hasClass('selected')
        repeatOneButton.removeClass('selected')
        this.model.get('originalSubtitlesModel').removeRepeatone()
      else
        repeatOneButton.addClass('selected')
        this.model.get('originalSubtitlesModel').addRepeatone()

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
      
      this.$('.skee-close').on('click', () =>
        this.$('.skee-dictionaryContainer').hide()
      )

      dictionary = this.model.get('dictionary')
      fromLanguage = this.model.get('fromLanguage')
      toLanguage = this.model.get('toLanguage')
      dictionary.lookup(word, fromLanguage, toLanguage, (result) ->
        this.$('.skee-dictionaryResults').html(result)
      )

    upload: () ->
      this.trigger('disableKeyboard')

      musicPlayer = this.model.get('musicPlayer')
      dataProvider = this.model.get('dataProvider')
      subtitlesUploadModel = new SubtitlesUploadModel(
        artist: musicPlayer.getArtist()
        song: musicPlayer.getSong()
        language: "en"
        musicPlayer: musicPlayer
        dataProvider: dataProvider
      )

      subtitlesUploadView = new SubtitlesUploadView(
        model: subtitlesUploadModel
      )
      subtitlesUploadView.on("subtitlesUploaded", (word) =>
        console.log('upload complete')
        this.$('.skee-subtitlesUploadContainer').hide()
        this.model.trigger('subtitlesUpdated')
        this.trigger('enableKeyboard')
      )

      this.$('.skee-close').on('click', () =>
        this.$('.skee-subtitlesUploadContainer').hide()
        this.trigger('enableKeyboard')
      )

      this.$('.skee-subtitlesUpload').html(subtitlesUploadView.render().el)
      this.$('.skee-subtitlesUploadContainer').show()
  )

  return SubtitlesPlayerView