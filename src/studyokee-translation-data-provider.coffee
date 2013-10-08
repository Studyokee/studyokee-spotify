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
      @url = 'http://localhost:3000/lyrics'

    getSegments: (artist, song, language, callback) ->
      cacheKey = artist + ':' + song
      console.log('Retrieving lyrics for song: \'' + cacheKey + '\'')
      @lastSong = cacheKey

      originalLyrics = null
      translatedLyrics = null
      originalLyricsRetrieved = false
      translatedLyricsRetrieved = false

      currentSong = @lastSong

      onSuccess = () =>
        if currentSong is not @lastSong
          return
          
        if originalLyricsRetrieved and translatedLyricsRetrieved
          lyrics =
            originalLyrics: originalLyrics
            translatedLyrics: translatedLyrics

          callback(lyrics)

      $.ajax(
        type: 'GET'
        url: @url
        data:
          artist: artist
          song: song
        success: (lyrics) ->
          originalLyrics = lyrics
          originalLyricsRetrieved = true
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
        success: (lyrics) ->
          translatedLyrics = lyrics
          translatedLyricsRetrieved = true
          onSuccess()
        failure: () ->
          onSuccess()
      )

    saveLyrics: (artist, song, language, lyrics, callback) ->
      postUrl = '?artist=' + escape(artist) + '&song=' + escape(song)

      if language?
        postUrl += '&language=' + escape(language)

      $.ajax(
        type: 'POST'
        url: @url + postUrl
        data: lyrics: lyrics
        success: () ->
          callback()
      )

  return StudyokeeTranslationDataProvider