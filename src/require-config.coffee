requirejs.config(
  enforceDefine: true
  paths:
    backbone: '/components/backbone/backbone'
    jquery: '/components/jquery/jquery'
    underscore: '/components/underscore/underscore'
    'subtitles.timer': '/lib/subtitles-timer'
    'subtitles.scroller.model': '/lib/subtitles-scroller/subtitles-scroller-model'
    'master.subtitles.scroller.model': '/lib/subtitles-scroller/master-subtitles-scroller-model'
    'subtitles.scroller.view': '/lib/subtitles-scroller/subtitles-scroller-view'
    'subtitles.player.model': '/lib/subtitles-player/subtitles-player-model'
    'subtitles.player.view': '/lib/subtitles-player/subtitles-player-view'
    'subtitles.upload.model': '/lib/subtitles-upload/subtitles-upload-model'
    'subtitles.upload.view': '/lib/subtitles-upload/subtitles-upload-view'
    'spotify.player': '/lib/spotify-player'
    'test.translation.data.provider': '/lib/test-translation-data-provider'
    'tune.wiki.translation.data.provider': '/lib/tune-wiki-translation-data-provider'
    'studyokee.translation.data.provider': '/lib/studyokee-translation-data-provider'
    'yabla.dictionary.data.provider': '/lib/yabla-dictionary-data-provider'
  shim:
    backbone:
      deps: [ 'underscore', 'jquery' ]
      exports: 'Backbone'
    underscore:
      exports: '_'
)