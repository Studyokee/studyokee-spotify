LyricsModel = Backbone.Model.extend(
  timer: null

  initialize: () ->
    dataProvider = this.get('dataProvider')
    musicPlayer = this.get('musicPlayer')
    language = this.get('language')

    onSuccess = (lyrics) =>
      this.setLyrics(lyrics)

    dataProvider.getSegments(musicPlayer.getArtist(), musicPlayer.getSong(), language, onSuccess)

  setLyrics: (lyrics) ->
    this.set(
      lyrics: lyrics
    )

    this.timer = new LyricsTimer(lyrics, () =>
      this.syncView()
    )

    this.syncView()

  syncView: () ->
    this.set(
      i: this.getPosition()
    )
    this.startTimer()

  getPosition: () ->
    lyrics = this.get('lyrics')
    i = 0
    currentTime = this.get('musicPlayer').getTrackPosition()
    while lyrics[i]? and lyrics[i].ts < currentTime
      i++

    return i - 1

  startTimer: () ->
    i = this.get('i')
    musicPlayer = this.get('musicPlayer')

    # Create timer for automatic update
    if this.timer?
      this.timer.stop()

    this.timer.start(i, musicPlayer.getTrackPosition())
)

LyricsView = Backbone.View.extend(
  tagName:  "ul"
  className: "skee-lyrics"

  initialize: () ->
    this.listenTo(this.model, 'change:lyrics', this.render)
    this.listenTo(this.model, 'change:i', this.onPositionChange)

  render: () ->
    lyricsList = "<% _.each(lyrics, function(lyricLine) { %> <li class='lyricLine'><%= lyricLine.text %></li> <% }); %>"
    this.$el.html(_.template(lyricsList, {lyrics : this.model.get('lyrics')}))

    return this

  onPositionChange: (i) ->
    i = this.model.get('i')
    # Set view
    topMargin = -(i * 60) + 180
    this.$el.css('margin-top', topMargin + 'px')

    this.$('.lyricLine').each((index, el) ->
      if index is i
        $(el).addClass('selected')
      else 
        $(el).removeClass('selected')
    )
)

MasterLyricsModel = LyricsModel.extend(
  prev: () ->
    i = this.get('i') - 1
    if i < 0
      i = 0

    this.set(
      i: i
    )
    this.syncTrackPosition()

  next: () ->
    i = this.get('i') + 1
    lyrics = this.get('lyrics')

    if i >= lyrics.length
      i = lyrics.length - 1

    this.set(
      i: i
    )
    this.syncTrackPosition()

  syncTrackPosition: () ->
    i = this.get('i')
    lyrics = this.get('lyrics')
    musicPlayer = this.get('musicPlayer')

    trackPosition = lyrics[i]
    if trackPosition?
      musicPlayer.setTrackPosition(trackPosition.ts)
)

AppView = Backbone.View.extend(
  el: $("#skee"),

  initialize: () ->
    musicPlayer = new SpotifyPlayer()
    #dataProvider = new TuneWikiDataProvider()
    dataProvider = new TestTranslationDataProvider()

    originalLyricsModel = new MasterLyricsModel(
      musicPlayer: musicPlayer
      dataProvider: dataProvider
      language: 'en'
    )
    originalLyricsView = new LyricsView(
      model: originalLyricsModel
    )

    this.$('#skee-original').append(originalLyricsView.render().el)

    translatedLyricsModel = new LyricsModel(
      musicPlayer: musicPlayer
      dataProvider: dataProvider
      language: 'fr'
    )
    translatedLyricsView = new LyricsView(
      model: translatedLyricsModel
    )
    this.$('#skee-translation').append(translatedLyricsView.render().el)

    # Add controls
    prev = () =>
      originalLyricsModel.prev()
    this.$('#skee-prev').on('click', prev)

    next = () =>
      originalLyricsModel.next()
    this.$('#skee-next').on('click', next)

)

app = new Backbone.Model
appView = new AppView(
  model: app
)