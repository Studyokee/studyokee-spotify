####################################################################
#Interface:
#
# TranslationDataProvider = () ->
#   getSegments(artist, song, language, onSuccess)
#
####################################################################

class TestTranslationDataProvider
  getSegments: (artist, song, language, onSuccess) ->
    segments = {}
    for i in [1..30]
      switch lang
        when "en"
          segment = 
            ts: (i-1) * 1000
            text: "Lyriques " + i
        else
          segment = 
            ts: (i-1) * 1000
            text: "Test Lyric " + i

      segments[i] = segment
    fn = () ->
      onSuccess(segments)
    setTimeout(fn, 500)
    
window.TestTranslationDataProvider = TestTranslationDataProvider