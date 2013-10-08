requirejs.config(
  enforceDefine: true
  paths:
    backbone: '/components/backbone/backbone'
    jquery: '/components/jquery/jquery'
    underscore: '/components/underscore/underscore'
    lyrics: '/lib/lyrics'
    'lyrics.upload': '/lib/lyrics-upload'
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