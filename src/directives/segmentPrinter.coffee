angular.module('components', []).
  directive('segmentprinter', ->
    replace: true
    restrict: 'E'
    scope: {}

    controller: ['$scope', ($scope) ->

      $scope.segment = null

      segments = new TestTranslationDataProvider().getSegments()
      musicPlayer = new SpotifyPlayer()
      currentIndex = null;
      showNext = null;

      # Sync the player to the current music player track position
      sync = () ->
        i = getSegmentIndex(musicPlayer.getTrackPosition())
        setCurrentIndex(i)

      # Get the segment that corresponds to the given trackPosition.  A segment corresponds 
      # to a given position if its start is less than or equal to the track position and the
      # next segment has no start or a start time greater than it.
      getSegmentIndex = (trackPosition) ->
        match = -1

        for segment in segments
          if not segment.start? or segment.start > trackPosition
            return match
          match++

        return match

      # Set the current index to the given value.  Also, if the music is playing and the next
      # segment has a start, set a timeout to show the next segment.
      setCurrentIndex = (i) ->
        clearTimeout(showNext)

        if not i? or i < 0
          currentIndex = null
        else
          currentIndex = Math.min(segments.length - 1, i)

          # If the music is playing and there is a next segment with a start time, show it later
          nextSegment = segments[i+1]
          if musicPlayer.isPlaying() and nextSegment and nextSegment.start?
            delta = nextSegment.start - musicPlayer.getTrackPosition()
            showNext = setTimeout(next, Math.max(delta, 0))

        segment = segments[currentIndex]
        safeApply(() ->
          $scope.lyrics = segment.lyrics
          $scope.translation = segment.translations.en
        )

        return currentIndex

      # Increment the current segment to the next segment
      next = () ->
        setCurrentIndex(currentIndex + 1)

      safeApply = (fn) =>
        phase = $scope.$root.$$phase
        if phase == '$apply' or phase == '$digest'
          if fn and (typeof(fn) == 'function')
            fn()
        else
          $scope.$apply(fn)

      sync()
      musicPlayer.onChange(sync)

    ]
    template: 
      '<div>' +
        '<div>{{lyrics}}</div>' +
        '<div>{{translation}}</div>' +
      '</div>'
  )