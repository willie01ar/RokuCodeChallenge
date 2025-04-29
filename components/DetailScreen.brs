sub init()
  m.poster = m.top.findNode("poster")
  m.titleLabel = m.top.findNode("titleLabel")
  m.yearLabel = m.top.findNode("yearLabel")
  m.movieType = m.top.findNode("movieType")
  m.playButton = m.top.findNode("playButton")

  ' Observe play button click
  m.playButton.observeField("buttonSelected", "onPlayButtonPressed")

  ' Load movie details into UI
  loadMovieData()
end sub

sub loadMovieData()
  if m.top.payload <> invalid
    movie = m.top.movieData

    m.poster.uri = movie.posterUri
    m.titleLabel.text = movie.title
    m.yearLabel.text = "Year: " + movie.year
    m.movieType.text = movie.type
  end if
end sub

sub onPlayButtonPressed()
  ConsoleLog.info("Play button pressed")
  ' Create and push the PlaybackScreen
  ' playbackScreen = createObject("roSGNode", "PlaybackScreen")
  ' playbackScreen.videoUrl = "https://stream.mux.com/1xUrx61Z02Ve00a0qZrK00Y00.m3u8" ' Example HLS sample

  ' m.global.screenManager.pushScreen(playbackScreen)
end sub