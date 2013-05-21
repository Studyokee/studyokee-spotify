// depends on SegmentPlayer.js, SpotifyPlayer.js, and TestTranslationDataProvider.js

// GLOBAL VARIABLES
LANG = 'en';

var segments = new TestTranslationDataProvider().getSegments();
var musicPlayer = new SpotifyPlayer();
var lyricsPlayer = new SegmentPlayer(segments, musicPlayer);
