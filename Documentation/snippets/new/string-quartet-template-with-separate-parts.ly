\version "2.19.56"

\header {
  lsrtags = "preparing-parts, template, unfretted-strings"

  texidoc = "
The @qq{String quartet template} snippet produces a nice string
quartet, but what if you needed to print parts? This new template
demonstrates how to use the @code{\\tag} feature to easily split a
piece into individual parts.

You need to split this template into separate files; the filenames are
contained in comments at the beginning of each file. @code{piece.ly}
contains all the music definitions. The other files – @code{score.ly},
@code{vn1.ly}, @code{vn2.ly}, @code{vla.ly}, and @code{vlc.ly} –
produce the appropriate part.


Do not forget to remove specified comments when using separate files!

"
  doctitle = "String quartet template with separate parts"
}

%%%%% piece.ly
%%%%% (This is the global definitions file)

global= {
  \time 4/4
  \key c \major
}


Violinone = \new Voice {
  \relative c'' {
    c2 d e1
    \bar "|."
  }
}


Violintwo = \new Voice {
  \relative c'' {
    g2 f e1
    \bar "|."
  }
}


Viola = \new Voice {
  \relative c' {
    \clef alto
    e2 d c1
    \bar "|."
  }
}


Cello = \new Voice {
  \relative c' {
    \clef bass
    c2 b a1
    \bar "|."
  }
}


music = {
  <<
    \tag #'score \tag #'vn1
    \new Staff \with { instrumentName = "Violin 1" }
    << \global \Violinone >>

    \tag #'score \tag #'vn2
    \new Staff \with { instrumentName = "Violin 2" }
    << \global \Violintwo>>

    \tag #'score \tag #'vla
    \new Staff \with { instrumentName = "Viola" }
    << \global \Viola>>

    \tag #'score \tag #'vlc
    \new Staff \with { instrumentName = "Cello" }
    << \global \Cello >>
  >>
}

% These are the other files you need to save on your computer

% score.ly
% (This is the main file)

% uncomment the line below when using a separate file
%\include "piece.ly"

#(set-global-staff-size 14)

\score {
  \new StaffGroup \keepWithTag #'score \music
  \layout { }
  \midi { }
}


%{ Uncomment this block when using separate files

% vn1.ly
% (This is the Violin 1 part file)

\include "piece.ly"
\score {
  \keepWithTag #'vn1 \music
  \layout { }
}


% vn2.ly
% (This is the Violin 2 part file)

\include "piece.ly"
\score {
  \keepWithTag #'vn2 \music
  \layout { }
}


% vla.ly
% (This is the Viola part file)

\include "piece.ly"
\score {
  \keepWithTag #'vla \music
  \layout { }
}


% vlc.ly
% (This is the Cello part file)

\include "piece.ly"
\score {
  \keepWithTag #'vlc \music
  \layout { }
}

%}
