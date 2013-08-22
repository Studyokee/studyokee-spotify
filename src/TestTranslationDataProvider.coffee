####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(track, lang, onSuccess)
#
####################################################################

class TestTranslationDataProvider
  getSegments: (track, lang, onSuccess) ->
    segments = {}
    for i in [0..1000]
      switch lang
        when "EN"
          segment = 
            ts: i * 1000
            text: "Lyriques " + i
        else
          segment = 
            ts: i * 1000
            text: "Test Lyric " + i

      segments[i] = segment

    onSuccess(segments)

window.TestTranslationDataProvider = TestTranslationDataProvider