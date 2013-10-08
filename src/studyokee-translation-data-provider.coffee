define () ->
  ####################################################################
  #Interface:
  #
  # TranslationDataProvider = () ->
  #   getSegments(artist, song, language, onSuccess)
  #
  ####################################################################

  class StudyokeeTranslationDataProvider

    constructor: () ->
      @lastSong = ''
      @url = 'http://localhost:3000/subtitles'

    getSegments: (artist, song, language, callback) ->
      cacheKey = artist + ':' + song
      console.log('Retrieving subtitles for song: \'' + cacheKey + '\'')
      @lastSong = cacheKey

      originalSubtitles = null
      translatedSubtitles = null
      originalSubtitlesRetrieved = false
      translatedSubtitlesRetrieved = false

      currentSong = @lastSong

      onSuccess = () =>
        if currentSong is not @lastSong
          return
          
        if originalSubtitlesRetrieved and translatedSubtitlesRetrieved
          subtitles =
            originalSubtitles: originalSubtitles
            translatedSubtitles: translatedSubtitles

          callback(subtitles)

      $.ajax(
        type: 'GET'
        url: @url
        data:
          artist: artist
          song: song
        success: (subtitles) ->
          originalSubtitles = subtitles
          originalSubtitlesRetrieved = true
          onSuccess()
        failure: () ->
          onSuccess()
      )

      $.ajax(
        type: 'GET'
        url: @url
        data:
          artist: artist
          song: song
          language: language
        success: (subtitles) ->
          translatedSubtitles = subtitles
          translatedSubtitlesRetrieved = true
          onSuccess()
        failure: () ->
          onSuccess()
      )

    saveSubtitles: (artist, song, language, subtitles, callback) ->
      postUrl = '?artist=' + escape(artist) + '&song=' + escape(song)

      if language?
        postUrl += '&language=' + escape(language)

      $.ajax(
        type: 'POST'
        url: @url + postUrl
        data: subtitles: subtitles
        success: () ->
          callback()
      )

  return StudyokeeTranslationDataProvider