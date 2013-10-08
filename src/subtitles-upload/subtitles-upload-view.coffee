define [
  'backbone'
], (Backbone) ->

  SubtitlesUploadView = Backbone.View.extend(
    tagName:  "div"
    className: "skee-upload"

    render: () ->
      subtitlesUploadTemplate = $( "script.subtitlesUpload" ).html()

      templateModel =
        artist : this.model.get('artist')
        song: this.model.get('song')
        language: this.model.get('language')
      this.$el.html(_.template(subtitlesUploadTemplate, templateModel))

      this.renderEditStage()

      # Activate buttons
      this.$('.skee-saveText').on('click', () =>
        this.saveLyrics()
        this.renderSyncStage()
      )
      this.$('.skee-syncNext').on('click', () =>
        this.next()
      )
      this.$('.skee-syncPrev').on('click', () =>
        this.prev()
      )
      this.$('.skee-saveSubtitles').on('click', () =>
        this.saveSubtitles()
      )

      return this

    renderEditStage: () ->
      this.$('.skee-syncSubtitles').hide()
      this.$('.skee-uploadText').show()

    renderSyncStage: () ->
      subtitlesTemplate = $( "script.subtitles" ).html()

      originalModel =
        subtitles : this.model.get('originalSubtitles')
      this.$('.skee-syncOriginal').html(_.template(subtitlesTemplate, originalModel))

      translatedModel =
        subtitles : this.model.get('translatedSubtitles')
      this.$('.skee-syncTranslation').html(_.template(subtitlesTemplate, translatedModel))

      this.selectLine(0)

      this.model.get('musicPlayer').setTrackPosition(0)

      this.$('.skee-uploadText').hide()
      this.$('.skee-syncSubtitles').show()

    saveLyrics: () ->
      originalSubtitles = this.createSubtitles(this.$('.skee-editOriginal').val().trim())
      translatedSubtitles = this.createSubtitles(this.$('.skee-editTranslation').val().trim())

      this.model.set(
        originalSubtitles: originalSubtitles
        translatedSubtitles: translatedSubtitles
      )

    createSubtitles: (lyrics) ->
      lines = lyrics.split('\n')
      subtitles = []
      for line in lines
        subtitle =
          text: line
          ts: 0
        subtitles.push(subtitle)
      return subtitles

    next: () ->
      originalSubtitles = this.model.get('originalSubtitles')
      translatedSubtitles = this.model.get('translatedSubtitles')
      currentIndex = this.model.get('currentIndex')
      currentIndex++

      if originalSubtitles[currentIndex]? or translatedSubtitles[currentIndex]?
        this.selectLine(currentIndex)

        ts = this.model.get('musicPlayer').getTrackPosition()

        if originalSubtitles[currentIndex]?
          originalSubtitles[currentIndex].ts = ts

        if translatedSubtitles[currentIndex]?
          translatedSubtitles[currentIndex].ts = ts

    prev: () ->
      currentIndex = this.model.get('currentIndex')
      currentIndex--

      if currentIndex >= 0
        this.selectLine(currentIndex)

        originalSubtitles = this.model.get('originalSubtitles')
        this.model.get('musicPlayer').setTrackPosition(originalSubtitles[currentIndex].ts)

    selectLine: (i) ->
      console.log('select line: ' + i)
      this.model.set(
        currentIndex: i
      )
      topMargin = -(i * 32) + 180
      this.$('.skee-subtitles').css('margin-top', topMargin + 'px')

      this.$('.skee-syncOriginal .skee-subtitle').each((index, el) ->
        console.log('index: ' + index + ' i: ' + i)
        if index is i
          $(el).addClass('selected')
        else
          $(el).removeClass('selected')
      )
      this.$('.skee-syncTranslation .skee-subtitle').each((index, el) ->
        if index is i
          $(el).addClass('selected')
        else
          $(el).removeClass('selected')
      )

    saveSubtitles: () ->
      originalSubtitles = this.model.get('originalSubtitles')
      translatedSubtitles = this.model.get('translatedSubtitles')
      artist = this.model.get('artist')
      song = this.model.get('song')
      language = this.model.get('language')
      dataProvider = this.model.get('dataProvider')

      spinner = _.template($( "script.spinner" ).html())
      this.$('.skee-syncSubtitles').html(spinner)

      returnedCount = 0
      onSuccess = () =>
        returnedCount++
        if returnedCount is 2
          this.trigger('subtitlesUploaded')

      dataProvider.saveSubtitles(artist, song, null, originalSubtitles, onSuccess)
      dataProvider.saveSubtitles(artist, song, language, translatedSubtitles, onSuccess)
  )

  return SubtitlesUploadView