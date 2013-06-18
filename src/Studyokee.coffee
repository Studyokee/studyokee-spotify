angular.module('studyokee', []).
  directive('lyricsplayer', ->
    replace: true
    restrict: 'E'
    scope: {}
    
    controller: ($scope) ->

      $scope.i = null

      update = (i) ->
        $scope.$apply(() ->
          # Do all segment updates here
          $scope.i = i
        )

      init = () ->
        musicPlayer = new SpotifyPlayer()

        dataProvider = new TestTranslationDataProvider()
        lyrics = dataProvider.getSegments(musicPlayer.getTrackName())

        timer = new LyricsTimer(musicPlayer, lyrics)

        timer.addListener(update)

      init()

    template: 
      '<div>' +
        '{{i}}' +
      '</div>'
  )