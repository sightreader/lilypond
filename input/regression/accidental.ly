\version "1.7.18"

\header{
texidoc="
Accidentals work: the second note does not get a sharp. The third and
fourth show forced and courtesy accidentals.
"
}

foo = \notes\relative c''   {   \key as \major dis4 dis dis!^"force" dis? }

\score {
  < \foo 
   \context NoteNames \foo
  >
}
%% new-chords-done %%