window.LyricsModel = Backbone.Model.extend(
  timer: null

  initialize: () ->
    fn = () ->
      this.onSongChange()
    this.listenTo(this, 'change:lyrics', fn)

  onSongChange: () ->
    if this.timer?
      this.timer.clear()
    this.timer = new LyricsTimer(this.get('lyrics'), () =>
      this.syncView()
      this.startTimer()
    )

    this.syncView()
    this.startTimer()

  # Matches the view to the song playing
  syncView: () ->
    this.set(
      i: this.getPosition()
    )

  # Get the index of the line of lyrics corresponding to the current track position
  getPosition: () ->
    lyrics = this.get('lyrics')
    i = 0
    currentTime = this.get('musicPlayer').getTrackPosition()
    while lyrics[i]? and lyrics[i].ts < currentTime
      i++

    return i - 1

  startTimer: () ->
    this.timer.clear()
    if this.get('musicPlayer').isPlaying()
      this.timer.start(this.get('i'), this.get('musicPlayer').getTrackPosition())

  clearTimer: () ->
    this.timer.clear()

  # Controls
  prev: () ->
    this.set(
      i: Math.max(this.get('i') - 1, 0)
    )
    this.startTimer()

  next: () ->
    this.set(
      i: Math.min(this.get('i') + 1, this.get('lyrics').length - 1)
    )
    this.startTimer()

  play: () ->
    this.startTimer()

  pause: () ->
    this.clearTimer()
)

window.MasterLyricsModel = LyricsModel.extend(
  # Sync the music playing to the current index
  syncTrackPosition: () ->
    trackPosition = this.get('lyrics')[this.get('i')]
    if trackPosition?
      this.get('musicPlayer').setTrackPosition(trackPosition.ts)

  # Controls
  prev: () ->
    this.set(
      i: Math.max(this.get('i') - 1, 0)
    )
    this.syncTrackPosition()
    this.startTimer()

  next: () ->
    this.set(
      i: Math.min(this.get('i') + 1, this.get('lyrics').length - 1)
    )
    this.syncTrackPosition()
    this.startTimer()

  play: () ->
    this.get('musicPlayer').play()
    this.startTimer()

  pause: () ->
    this.get('musicPlayer').pause()
    this.clearTimer()

  addRepeatone: () ->
    this.timer.setCallback(() =>
      this.syncTrackPosition()
      this.startTimer()
    )

  removeRepeatone: () ->
    this.timer.setCallback(() =>
      this.syncView()
      this.startTimer()
    )
)

window.LyricsView = Backbone.View.extend(
  tagName:  "ul"
  className: "skee-lyrics"

  initialize: () ->
    this.listenTo(this.model, 'change:lyrics', this.render)
    this.listenTo(this.model, 'change:i', this.onPositionChange)

  render: () ->
    lyricsList = "<% _.each(lyrics, function(lyricLine) { %> <li class='lyricLine'><%= lyricLine.text %></li> <% }); %>"
    this.$el.html(_.template(lyricsList, {lyrics : this.model.get('lyrics')}))

    this.onPositionChange()

    return this

  # Update the lines shown in the window and the highlighted line
  onPositionChange: () ->
    i = this.model.get('i')
    topMargin = -(i * 48) + 180
    this.$el.css('margin-top', topMargin + 'px')

    this.$('.lyricLine').each((index, el) ->
      if index is i
        $(el).addClass('selected')
      else 
        $(el).removeClass('selected')
    )
)
