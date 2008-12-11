%% Do not edit this file; it is auto-generated from input/new
%% This file is in the public domain.
\version "2.11.64"

\header {
  texidoces = "
Para las improvisaciones o @emph{taqasim} que son libres durante unos
momentos, se puede omitir la indicación de compás y se puede usar
@code{\cadenzaOn}.  Podría ser necesario ajustar el estilo de
alteraciones accidentales, porque la ausencia de líneas divisorias
hará que la alteración aparezca una sola vez.  He aquí un ejemplo de
cómo podría ser el comienzo de una improvisación @emph{hijaz}:

"
doctitlees = "Improvisación de música árabe"

  lsrtags = "world-music"
  texidoc = "For improvisations or @emph{taqasim} which are
temporarily free, the time signature can be omitted and
@code{\cadenzaOn} can be used.  Adjusting the accidental style
might be required, since the absence of bar lines will cause the
accidental to be marked only once.  Here is an example of what
could be the start of a @emph{hijaz} improvisation:"
doctitle = "Arabic improvisation"
} % begin verbatim


\include "arabic.ly"

\relative sol' {
  \key re \kurd
  #(set-accidental-style 'forget)
  \cadenzaOn
  sol4 sol sol sol fad mib sol1 fad8 mib re4. r8 mib1 fad sol
}
