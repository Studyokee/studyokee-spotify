LyricsModel = Backbone.Model.extend()

LyricsView = Backbone.View.extend(
  tagName:  "ul"
  className: "skee-lyricsPlayer"

  initialize: () ->
    dataProvider = this.model.get('dataProvider')
    musicPlayer = this.model.get('musicPlayer')
    language = this.model.get('language')

    onSuccess = (segments) =>
      lyrics = []
      i = 1
      while segments[i]?
        lyrics.push(segments[i])
        i++

      this.model.set(
        lyrics: lyrics
      )

      timer = new LyricsTimer(lyrics)
      timer.addListener((i) =>
        topMargin = -(i * 60) + 180
        this.$el.css('margin-top', topMargin + 'px')

        this.$('.lyricLine').each((index, el) ->
          if index is i
            $(el).addClass('selected')
          else 
            $(el).removeClass('selected')
        )
      )
      timer.start(musicPlayer.getTrackPosition())

    dataProvider.getSegments(musicPlayer.getArtist(), musicPlayer.getSong(), language, onSuccess)

    this.listenTo(this.model, 'change', this.render)

  render: () ->
    lyricsList = "<% _.each(lyrics, function(lyricLine) { %> <li class='lyricLine'><%= lyricLine.text %></li> <% }); %>"
    this.$el.html(_.template(lyricsList, {lyrics : this.model.get('lyrics')}))

    return this
)

AppView = Backbone.View.extend(
  el: $("#skee"),

  initialize: () ->
    musicPlayer = new SpotifyPlayer()
    dataProvider = new TuneWikiDataProvider()

    originalLyricsModel = new LyricsModel(
      musicPlayer: musicPlayer
      dataProvider: dataProvider
      language: 'en'
    )
    this.originalLyricsView = new LyricsView(
      model: originalLyricsModel
    )

    translatedLyricsModel = new LyricsModel(
      musicPlayer: musicPlayer
      dataProvider: dataProvider
      language: 'fr'
    )
    this.translatedLyricsView = new LyricsView(
      model: translatedLyricsModel
    )

    this.$('#skee-original').append(this.originalLyricsView.render().el)
    this.$('#skee-translation').append(this.translatedLyricsView.render().el)

)

app = new Backbone.Model
appView = new AppView(
  model: app
)