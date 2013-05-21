/**********************************************************************
Interface:

function TranslationDataProvider() {
      getSegments(track)
}
***********************************************************************/

function TestTranslationDataProvider() {
      this.getSegments = function(track) {
            var segments = [];
            for (var i = 0; i < 1000; i++) {
                  segments.push({
                        start: i * 3000,
                        lyrics: "Test Lyric " + i,
                        translations: {
                              en: "Test Translation " + i
                        } 
                  });
            }
            return segments;
      };
}