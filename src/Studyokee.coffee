safeApply = ($scope, fn) =>
  phase = $scope.$root.$$phase
  if phase == '$apply' or phase == '$digest'
    if fn and (typeof(fn) == 'function')
      fn()
  else
    $scope.$apply(fn)

angular.module('studyokee', []).
  directive('lyricsplayer', ->
    replace: true
    restrict: 'E'
    scope: {}
    
    controller: ($scope) ->
      update = (i) ->
        safeApply($scope, () ->
          # Do all segment updates here
          $scope.i = i
        )

      init = () ->
        $scope.i = null

        musicPlayer = new SpotifyPlayer()
        lyrics = new TestTranslationDataProvider().getSegments(musicPlayer.getTrackName())

        timer = new LyricsTimer(musicPlayer, lyrics)
        timer.addListener(update)
        timer.init()

      init()

    template: 
      '<div>' +
        '{{i}}' +
      '</div>'
  )