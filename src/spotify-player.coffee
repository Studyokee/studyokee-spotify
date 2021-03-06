define () ->
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
      @models = getSpotifyApi().require("$api/models")
      @player = @models.player
      
    getTrackPosition: () ->
      return @player.position

    setTrackPosition: (ts) ->
      @player.position = ts

    play: () ->
      @player.playing = true

    pause: () ->
      @player.playing = false

    isPlaying: () ->
      return @player.playing

    getSong: () ->
      return @player.track.name

    getArtist: () ->
      return @player.track.artists[0].name

    onSongChange: (callback) ->
      @currentSong = @player.track
      fn = () =>
        if @player.track.toString() isnt @currentSong.toString()
          @currentSong = @player.track
          callback()
      @player.observe(@models.EVENT.CHANGE, fn)

    onChange: (callback) ->
      @player.observe(@models.EVENT.CHANGE, callback)

  return SpotifyPlayer