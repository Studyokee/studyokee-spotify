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
    for i in [0..300]
      switch language
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
    setTimeout(fn, 100)
    
window.TestTranslationDataProvider = TestTranslationDataProvider