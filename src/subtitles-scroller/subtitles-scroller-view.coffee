define [
  'backbone'
], (Backbone) ->

  ####################################################################
  #
  # SubtitlesScrollerView
  #
  # The view for a scrolling view of subtitles
  #
  ####################################################################
  SubtitlesScrollerView = Backbone.View.extend(
    tagName:  "div"
    className: "skee-pane"

    render: () ->
      this.$el.html(_.template($( "script.subtitlesScroller" ).html()))
      this.$el.addClass(this.model.get('class'))

      subtitles = this.model.get('subtitles')
      if not subtitles? or subtitles.length == 0
        noSubtitles = this.showNoSubtitlesMessage()
        this.$('.skee-viewport').html(noSubtitles)
        return this

      if this.model.get('linkWords')
        items = this.getLinkedWordsMarkup()
      else
        items = this.getWithoutLinkedWordsMarkup()

      this.$('.skee-viewport').html(items)

      this.onPositionChange()
      this.listenTo(this.model, 'change:i', () =>
        this.onPositionChange()
      )

      this.$('.skee-lookup').on('click', (event) =>
        this.trigger('lookup', event.target.innerHTML)
      )

      return this

    showNoSubtitlesMessage: () ->
      return _.template($( "script.noSubtitles" ).html())

    getLinkedWordsMarkup: () ->
      subtitles = this.model.get('subtitles')
      subtitlesAsSegments = []
      for line in subtitles
        subtitlesAsSegments.push(line.text.split(' '))

      linkedSubtitlesTemplate = $( "script.linkedSubtitles" ).html()

      templateModel =
        subtitlesAsSegments : subtitlesAsSegments
      return _.template(linkedSubtitlesTemplate, templateModel)

    getWithoutLinkedWordsMarkup: () ->
      subtitles = this.model.get('subtitles')
      subtitlesTemplate = $( "script.subtitles" ).html()

      templateModel =
        subtitles : subtitles
      return _.template(subtitlesTemplate, templateModel)

    # Update the lines shown in the window and the highlighted line
    onPositionChange: () ->
      i = this.model.get('i')
      if not i?
        return

      topMargin = -(i * 32) + 180
      this.$('.skee-subtitles').css('margin-top', topMargin + 'px')

      this.$('.skee-subtitle').each((index, el) ->
        if index is i
          $(el).addClass('selected')
        else
          $(el).removeClass('selected')
      )
  )

  return SubtitlesScrollerView