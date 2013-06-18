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
    scope: {
      lang: '@'
    }
    
    controller: ($scope) ->
      musicPlayer = new SpotifyPlayer()
      dataProvider = new TestTranslationDataProvider()

      getLines = (lyrics, currentLine, before=5, after=5) ->
        lines = []
        start = currentLine - before
        end = currentLine + after
        for i in [start..end]
          lines.push(lyrics[i])

        return lines

      init = (lang) ->
        $scope.lyrics = dataProvider.getSegments(musicPlayer.getTrackName(), lang)
        $scope.i = null
        $scope.toDisplay = []

        timer = new LyricsTimer(musicPlayer, $scope.lyrics)
        timer.addListener((i) ->
          safeApply($scope, () ->
            $scope.i = i
            $scope.lines = getLines($scope.lyrics, $scope.i)
          )
        )
        timer.init()

      $scope.$watch('lang', () ->
        init($scope.lang)
      )

    template: 
      '<ul>' +
        '<li ng-repeat="line in lines">' +
          '{{line.text}}' +
        '</li>' +
      '</ul>'
  )