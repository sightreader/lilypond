\version "1.7.18"

\header {
texidoc="show trill line type"
}

\paper { raggedright = ##t} 

\score {
  \context RhythmicStaff \notes {
    \stemDown
    \property Voice.Stem \override #'transparent = ##t
    \property Voice.TextSpanner \set #'type = #'dotted-line
    \property Voice.TextSpanner \set #'edge-height = #'(0 . 1.5)
    \property Voice.TextSpanner \set #'edge-text = #'("bla " . "")
    a#(ly:export (make-span-event 'TextSpanEvent START)) b c a #(ly:export (make-span-event 'TextSpanEvent STOP))

    %\property Voice.TextSpanner \set #'font-family = #'music
    \property Voice.TextSpanner \set #'type = #'trill
    \property Voice.TextSpanner \set #'edge-height = #'(0 . 0)
    \property Voice.TextSpanner \set #'edge-text
     = #(cons (make-musicglyph-markup "scripts-trill")  "")
    a#(ly:export (make-span-event 'TextSpanEvent START)) b c a #(ly:export (make-span-event 'TextSpanEvent STOP))
  }
  \paper { }  
}

%% new-chords-done %%
