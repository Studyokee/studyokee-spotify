####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(artist, song, language, onSuccess)
#
####################################################################

class TuneWikiDataProvider
  getSegments: (artist, song, language, onSuccess) ->
    $.ajax(
      url: 'http://localhost:3000/lyrics?artist=' + artist + '&song=' + song + '&language=' + language
      type: 'GET'
      success: onSuccess
    )

window.TuneWikiDataProvider = TuneWikiDataProvider