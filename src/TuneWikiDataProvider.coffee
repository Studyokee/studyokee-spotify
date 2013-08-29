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

    url = 'http://localhost:3000/lyrics?'
    url += 'artist=' + artist
    url += '&song=' + song
    if language
      url += '&language=' + language

    $.ajax(
      url: url
      type: 'GET'
      success: success
    )

window.TuneWikiDataProvider = TuneWikiDataProvider