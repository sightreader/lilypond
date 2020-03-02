%% DO NOT EDIT this file manually; it is automatically
%% generated from LSR http://lsr.di.unimi.it
%% Make any changes in LSR itself, or in Documentation/snippets/new/ ,
%% and then run scripts/auxiliar/makelsr.py
%%
%% This file is in the public domain.
\version "2.20.0"

\header {
  lsrtags = "pitches, version-specific, world-music"

  texidoc = "
Makam is a type of melody from Turkey using 1/9th-tone microtonal
alterations. Consult the initialization file @samp{ly/makam.ly} for
details of pitch names and alterations.

"
  doctitle = "Makam example"
} % begin verbatim

% Initialize makam settings
\include "makam.ly"

\relative c' {
  \set Staff.keyAlterations = #`((6 . ,(- KOMA)) (3 . ,BAKIYE))
  c4 cc db fk
  gbm4 gfc gfb efk
  fk4 db cc c
}
