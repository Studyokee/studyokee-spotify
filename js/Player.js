// GLOBAL VARIABLES
var LANG = 'en';

/*
Given a TranslationDataProvider and MusicPlayer, this will show lyrics and translations from 
the data provider that are synced to the track and current position being played by the music player.  
*/
function LyricsPlayer(translationDataProvider, musicPlayer) {
      var that = this;
      var nextSegmentTimer = null;

      // Sync the player to the track and position
      var sync = function() {
            // Reset player to new track
            clearTimeout(nextSegmentTimer);

            if (!musicPlayer.isPlaying()) {
                  return;
            }

            var track = musicPlayer.getCurrentTrack();
            var segments = translationDataProvider.getSegments(track);

            // Start playing from current position
            var trackPosition = musicPlayer.getTrackPosition();
            var i = getSegment(segments, trackPosition);
            showSegment(segments, i);
      };

      // Get the segment that corresponds to the given trackPosition
      var getSegment = function(segments, trackPosition) {
            if (segments.length === 0) {
                  return null;
            }
            if (segments.length === 1) {
                  return 0;
            }

            // Otherwise search until you find a segment that starts after the current position, and return the previous one
            for (var i = 1; i < segments.length; i++) {
                  var segment = segments[i];
                  if (segment.start > trackPosition) {
                        return i - 1;
                  }
            }
            // None found, return last one
            return segments.length - 1;
      };

      // Start showing segments in order starting from the given index and timed to the musicPlayer
      var showSegment = function(segments, i) {
            if (segments.length <= i) {
                  return;
            }

            var segment = segments[i];
            showText(segment);

            // If there are more segments, set a timeout to show the next one
            if (segments.length > (i+1)) {
                  var nextSegment = segments[i+1];
                  var delta = nextSegment.start - musicPlayer.getTrackPosition();

                  var next = function() {
                        showSegment(segments, i+1);
                  };
                  nextSegmentTimer = setTimeout(next, Math.max(delta, 0));
            }
            
      };

      // Update the view to the current segment
      var showText = function(segment) {
            console.log("Lyrics: " + segment.lyrics);
            console.log("Translation (lang: " + LANG + "): " + segment.translations[LANG]);
            console.log("LyricsPlayer time: " + segment.start + " Song time: " + musicPlayer.getTrackPosition());
      };

      sync();
      musicPlayer.onChange(sync);
};

/**********************************************************************
Interfaces:
function MusicPlayer() {
      this.getTrackPosition()
      this.getCurrentTrack()
      this.isPlaying()
      this.onChange(callback)
}

function TranslationDataProvider() {
      getSegments(track)
}
***********************************************************************/

function SpotifyPlayer() {
      var sp = getSpotifyApi();
      var models = sp.require("$api/models");
      var player = models.player;

      this.getTrackPosition = function() {
            return player.position;
      };

      this.getCurrentTrack = function() {
            var track = player.track;
            return {
                  name: track.name
            }
      };

      this.isPlaying = function() {
            return player.playing;
      }

      this.onChange = function(callback) {
            models.player.observe(models.EVENT.CHANGE, function(event) {
                  callback();
            });
      };
};

function TestTranslationDataProvider() {
      this.getSegments = function(track) {
            var segments = [];
            for (var i = 0; i < 1000; i++) {
                  segments.push({
                        start: i * 1000,
                        lyrics: "Test Lyric " + i,
                        translations: {
                              en: "Test Translation " + i
                        } 
                  });
            }
            return segments;
      };
}

var musicPlayer = new SpotifyPlayer();
var translationDataProvider = new TestTranslationDataProvider();
var lyricsPlayer = new LyricsPlayer(translationDataProvider, musicPlayer);