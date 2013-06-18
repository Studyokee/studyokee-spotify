####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(track)
#
####################################################################

class TestTranslationDataProvider
  getSegments: (track) ->
    segments = {}
    for i in [0..1000]
      segment = 
        ts: i * 3000
        text: "Test Lyric " + i

      segments[i] = segment
    return segments

window.TestTranslationDataProvider = TestTranslationDataProvider