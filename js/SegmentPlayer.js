/**
* Given a list of translation segments with a 'start' value in milliseconds and a 
* MusicPlayer, maintain the correct current segment index given the song position.
*/
function SegmentPlayer(segments, musicPlayer) {
      var currentIndex = null;
      var showNext = null;

      // Sync the player to the current music player track position
      var sync = function() {
            var i = getSegmentIndex(musicPlayer.getTrackPosition());
            setCurrentIndex(i);
      };

      // Get the segment that corresponds to the given trackPosition.  A segment corresponds 
      // to a given position if its start is less than or equal to the track position and the
      // next segment has no start or a start time greater than it.
      var getSegmentIndex = function(trackPosition) {
            var match = null;
            for (var i = 0; i < segments.length; i++) {
                  var segment = segments[i];
                  if (segment.start === null || segment.start > trackPosition) {
                        return match;
                  }
                  match = i;
            }

            return match;
      };

      // Set the current index to the given value.  Also, if the music is playing and the next
      // segment has a start, set a timeout to show the next segment.
      var setCurrentIndex = function(i) {
            clearTimeout(showNext);

            if (i === null || i < 0) {
                  currentIndex = null;
                  return;
            }

            currentIndex = Math.min(segments.length - 1, i);

            // If the music is playing and there is a next segment with a start time, show it later
            var nextSegment = segments[i+1];
            if (musicPlayer.isPlaying() && nextSegment && nextSegment.start !== null) {
                  var delta = nextSegment.start - musicPlayer.getTrackPosition();
                  showNext = setTimeout(next, Math.max(delta, 0));
            }
            
            // TODO: test code, remove later
            print();
      };

      // Increment the current segment to the next segment
      var next = function() {
            setCurrentIndex(currentIndex + 1);
      };

      // TODO: test code, remove later
      var print = function() {
            var segment = segments[currentIndex];
            console.log("Lyrics: " + segment.lyrics);
            console.log("Translation (lang: " + LANG + "): " + segment.translations[LANG]);
            console.log("SegmentPlayer time: " + segment.start + " MusicPlayer time: " + musicPlayer.getTrackPosition());
      };

      sync();
      musicPlayer.onChange(sync);
}