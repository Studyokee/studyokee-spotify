####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(track, lang)
#
####################################################################

class TestTranslationDataProvider
  getSegments: (track, lang) ->
    segments = {}
    for i in [0..1000]
      switch lang
        when "FR"
          segment = 
            ts: i * 3000
            text: "Lyriques " + i
        else
          segment = 
            ts: i * 3000
            text: "Test Lyric " + i

      segments[i] = segment

    return segments

window.TestTranslationDataProvider = TestTranslationDataProvider