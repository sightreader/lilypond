\version "2.4.0"
\header {

    texidoc = "When too few alternatives are present, the first
alternative is repeated, by printing a range for the 1st repeat."

}

\paper { raggedright = ##t } 


\relative c'' \context Voice {
  \repeat volta 3 c1
    \alternative { d f } e4
} 

