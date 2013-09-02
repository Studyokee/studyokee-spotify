####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(artist, song, language, onSuccess)
#
####################################################################

class TuneWikiDataProvider

  constructor: () ->
    @lastSong = ""

  getSegments: (artist, song, language, callback) ->
    cacheKey = artist + ":" + song
    if @lastSong is cacheKey
      return
    @lastSong = cacheKey

    originalLyrics = null
    translatedLyrics = null

    onSuccess = () =>
      if originalLyrics? and translatedLyrics?
        lyrics =
          originalLyrics: originalLyrics
          translatedLyrics: translatedLyrics

        callback(this.purifyData(lyrics))

    createArrayFromObject = (obj) ->
      lyricsArray = []
      i = 0
      while obj[i+1]?
        lyricsArray.push(obj[i+1])
        i++

      return lyricsArray

    onSuccessOriginal = (lyrics) ->
      originalLyrics = createArrayFromObject(lyrics)
      onSuccess()

    onSuccessTranslated = (lyrics) ->
      translatedLyrics = createArrayFromObject(lyrics)
      onSuccess()

    $.ajax(
      type: 'GET'
      url: 'http://localhost:3000/lyrics',
      data:
        artist: artist
        song: song
      success: onSuccessOriginal
    )

    $.ajax(
      type: 'GET'
      url: 'http://localhost:3000/lyrics'
      data:
        artist: artist
        song: song
        language: language
      success: onSuccessTranslated
    )

  purifyData: (lyrics) ->
    offset = this.getBestOffset(lyrics)

    # For lyric line in original lyrics add matching translated lyric using adjusted offset
    translatedLyrics = []
    for i in [0...lyrics.originalLyrics.length]
      lyricLine = lyrics.translatedLyrics[i+offset]
      translatedLyrics.push(
        ts: lyrics.originalLyrics[i].ts
        text: if lyricLine? then lyricLine.text else ""
      )

    lyrics.translatedLyrics = translatedLyrics

    return lyrics

  getBestOffset: (lyrics) ->
    minDiff = null
    offset = 0

    for i in [-10...10]
      avgDiff = this.compareWordCounts(lyrics.originalLyrics, lyrics.translatedLyrics, i)
      console.log(avgDiff)

      if not minDiff?
        minDiff = avgDiff
      else if avgDiff < minDiff
        minDiff = avgDiff
        offset = i

    return offset

  compareWordCounts: (originalLyrics, translatedLyrics, offset) ->
    totalDelta = 0
    totalDelta += this.getWordDelta(originalLyrics[i], translatedLyrics[i + offset]) for i in [0...originalLyrics.length]

    return totalDelta / (originalLyrics.length - Math.abs(offset))

  getWordDelta: (lyrics1, lyrics2) ->
    if not lyrics1? or not lyrics2?
      return 0

    words1 = lyrics1.text.split(' ')
    words2 = lyrics2.text.split(' ')

    return Math.abs(words1.length - words2.length)

window.TuneWikiDataProvider = TuneWikiDataProvider