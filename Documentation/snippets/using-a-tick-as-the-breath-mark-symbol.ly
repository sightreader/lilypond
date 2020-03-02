%% DO NOT EDIT this file manually; it is automatically
%% generated from LSR http://lsr.di.unimi.it
%% Make any changes in LSR itself, or in Documentation/snippets/new/ ,
%% and then run scripts/auxiliar/makelsr.py
%%
%% This file is in the public domain.
\version "2.21.0"

\header {
  lsrtags = "expressive-marks"

  texidoc = "
Vocal and wind music frequently uses a tick mark as a breathing sign.
This indicates a breath that subtracts a little time from the previous
note rather than causing a short pause, which is indicated by the comma
breath mark.  The mark can be moved up a little to take it away from
the stave.

"
  doctitle = "Using a tick as the breath mark symbol"
} % begin verbatim

\relative c'' {
  c2
  \breathe
  d2
  \override BreathingSign.Y-offset = #2.6
  \override BreathingSign.text =
    \markup { \musicglyph "scripts.tickmark" }
  c2
  \breathe
  d2
}
