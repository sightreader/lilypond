\version "2.1.7"
\header {

texidoc = "Tie engraver uses @code{busyGrobs} to keep track of
note heads. Test if this queue works by throwing many  mixed tuplets at it." 

}

\score
{
\notes \context Staff \relative c'' 
 <<
 {  \times 2/3 { c'8~  c8~ c8~ c8~ c8~ c8 } }
 \\
  { \voiceTwo \times 2/5 { a,4 ~a4 ~a4~ a4~ a4 }}
 \\
  { \voiceThree  { b,8 ~ b8 ~ b8 ~  b8 }}
 >>
}

