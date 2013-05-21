/**********************************************************************
Interface:
function MusicPlayer() {
      this.getTrackPosition()
      this.isPlaying()
      this.onChange(callback)
}
***********************************************************************/

function SpotifyPlayer() {
      var sp = getSpotifyApi();
      var models = sp.require("$api/models");
      var player = models.player;

      this.getTrackPosition = function() {
            return player.position;
      };

      this.isPlaying = function() {
            return player.playing;
      }

      this.onChange = function(callback) {
            player.observe(models.EVENT.CHANGE, function(event) {
                  callback(event);
            });
      };
}