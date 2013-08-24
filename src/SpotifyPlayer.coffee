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

  getSong: () ->
    return @player.track.name

  getArtist: () ->
    return @player.track.artists[0].name

window.SpotifyPlayer = SpotifyPlayer