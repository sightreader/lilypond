\version "1.7.18"
\header {
    texidoc = "The layout of the major 7 can be tuned with
@code{majorSevenSymbol}."
}

\score {\context ChordNames \chords {
      c:7+
      \property ChordNames.majorSevenSymbol = \markup { "j7" }
      c:7+ }
}
