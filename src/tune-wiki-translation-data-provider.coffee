define () ->
  ####################################################################
  #Interface:
  #
  # TranslationDataProvider = () ->
  #   getSegments(artist, song, language, onSuccess)
  #
  ####################################################################

  class TuneWikiTranslationDataProvider

    constructor: () ->
      @lastSong = ""

    getSegments: (artist, song, language, callback) ->
      cacheKey = artist + ":" + song
      if @lastSong is cacheKey
        return
      @lastSong = cacheKey

      originalSubtitles = null
      translatedSubtitles = null
      currentSong = @lastSong

      onSuccess = () =>
        if currentSong is not @lastSong
          return
          
        if originalSubtitles? and translatedSubtitles?
          subtitles =
            originalSubtitles: originalSubtitles
            translatedSubtitles: translatedSubtitles

          callback(this.purifyData(subtitles))

      createArrayFromObject = (obj) ->
        subtitlesArray = []
        i = 0
        while obj[i+1]?
          subtitlesArray.push(obj[i+1])
          i++

        return subtitlesArray

      onSuccessOriginal = (subtitles) ->
        originalSubtitles = createArrayFromObject(subtitles)
        onSuccess()

      onSuccessTranslated = (subtitles) ->
        translatedSubtitles = createArrayFromObject(subtitles)
        onSuccess()

      $.ajax(
        type: 'GET'
        url: 'http://d378swyygivki.cloudfront.net/subtitles',
        data:
          artist: artist
          song: song
        success: onSuccessOriginal
      )

      $.ajax(
        type: 'GET'
        url: 'http://d378swyygivki.cloudfront.net/subtitles'
        data:
          artist: artist
          song: song
          language: language
        success: onSuccessTranslated
      )

    purifyData: (subtitles) ->
      offset = this.getBestOffset(subtitles)

      # For lyric line in original subtitles add matching translated lyric using adjusted offset
      translatedSubtitles = []
      for i in [0...subtitles.originalSubtitles.length]
        subtitle = subtitles.translatedSubtitles[i+offset]
        translatedSubtitles.push(
          ts: subtitles.originalSubtitles[i].ts
          text: if subtitle? then subtitle.text else ""
        )

      subtitles.translatedSubtitles = translatedSubtitles

      return subtitles

    getBestOffset: (subtitles) ->
      minDiff = null
      offset = 0

      for i in [-10...10]
        avgDiff = this.compareWordCounts(subtitles.originalSubtitles, subtitles.translatedSubtitles, i)

        if not minDiff?
          minDiff = avgDiff
        else if avgDiff < minDiff
          minDiff = avgDiff
          offset = i

      return offset

    compareWordCounts: (originalSubtitles, translatedSubtitles, offset) ->
      totalDelta = 0
      totalDelta += this.getWordDelta(originalSubtitles[i], translatedSubtitles[i + offset]) for i in [0...originalSubtitles.length]

      return totalDelta / (originalSubtitles.length - Math.abs(offset))

    getWordDelta: (subtitles1, subtitles2) ->
      if not subtitles1? or not subtitles2?
        return 0

      words1 = subtitles1.text.split(' ')
      words2 = subtitles2.text.split(' ')

      return Math.abs(words1.length - words2.length)

  return TuneWikiTranslationDataProvider