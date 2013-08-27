####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(artist, song, language, onSuccess)
#
####################################################################

class TuneWikiDataProvider
  getSegments: (artist, song, language, onSuccess) ->
    success = (lyrics) ->
      lyricsArray = []
      i = 0
      while lyrics[i+1]?
        lyricsArray.push(lyrics[i+1])
        i++

      onSuccess(lyricsArray)

    $.ajax(
      url: 'http://localhost:3000/lyrics?artist=' + artist + '&song=' + song + '&language=' + language
      type: 'GET'
      success: success
    )

window.TuneWikiDataProvider = TuneWikiDataProvider