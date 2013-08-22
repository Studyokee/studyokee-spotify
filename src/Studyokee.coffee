safeApply = ($scope, fn) ->
  phase = $scope.$root.$$phase
  if phase is '$apply' or phase is '$digest'
    if fn and typeof(fn) is 'function'
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
      timer = null

      $scope.$watch('lyrics', () ->
        if timer?
          timer.stop()
        if $scope.lyrics?
          timer = new LyricsTimer($scope.lyrics)
          timer.addListener((i) ->
            safeApply($scope, () ->
              # update current div focus
              $scope.topMargin = -(i * 30) + 180
              $scope.i = i
            )
          )
          timer.start(musicPlayer.getTrackPosition())
      )

      $scope.$watch('lang', () ->
        onSuccess = (segments) ->
          lyrics = []
          i = 0
          while segments[i]?
            lyrics.push(segments[i])
            i++
          $scope.lyrics = lyrics
        dataProvider.getSegments(musicPlayer.getTrackName(), $scope.lang, onSuccess)
      )

    template: 
      '<ul style="margin-top:{{topMargin}}px;">' +
        '<li ng-repeat="line in lyrics">' +
          '<div ng-class="{selected: $index==i}">' +
            '{{line.text}}' +
          '</div>' +
        '</li>' +
      '</ul>'
  )