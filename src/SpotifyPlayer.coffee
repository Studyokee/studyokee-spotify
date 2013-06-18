####################################################################
# Interface:
# function MusicPlayer() {
#      this.getTrackName()
#      this.getTrackPosition()
#      this.isPlaying()
# }
####################################################################

class SpotifyPlayer

  constructor: () ->
    models = getSpotifyApi().require("$api/models")
    @player = models.player

  getTrackPosition: () ->
    return @player.position

  isPlaying: () ->
    return @player.playing

  getTrackName: () ->
    return @player.track.toString()

window.SpotifyPlayer = SpotifyPlayer