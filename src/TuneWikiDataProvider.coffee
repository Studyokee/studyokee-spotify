####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(track, lang, onSuccess)
#
####################################################################

class TuneWikiDataProvider
  getSegments: (track, lang, onSuccess) ->
    url = '/lyrics/' + track
    header =
      'Accept': 'JSON'
      'Accept-Language': lang

    success = (response) ->
      debugger
      onSuccess(response)

    $.ajax(
      url: url
      type: 'GET'
      header: header
      success: success
    )

window.TuneWikiDataProvider = TuneWikiDataProvider