\header{
filename = 	 "viola-i.ly";
title = 	 	 "Vier Duette";
description = 	 "Four duets for Violino and Violoncello (Viola)";
opus =            "BWV";
composer = 	 "Johann Sebastian Bach (1685-1750)";
enteredby = 	 "jcn";
copyright = 	 "Public Domain";
}

\version "1.3.117";

\include "global-i.ly"
\include "violoncello-i.ly";

violaIStaff =  \context Staff = viola <
  \property Staff.instrument = "viola"
  %\property Staff.instrument = "violin"
  \notes\transpose c'' \violoncelloI
  \clef alto;
  \globalI
>
