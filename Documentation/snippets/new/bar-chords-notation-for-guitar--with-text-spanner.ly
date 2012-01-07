\version "2.15.20"

\header {
  lsrtags = "chords, fretted-strings"

  texidoc = "
Here is how to print bar chords, or half-bar chords (just uncomment the
appropriate line for to select either one).

The syntax is @code{\\bbarre #'fret_number' @{ notes @} }




"
  doctitle = "Bar chords notation for Guitar ( with Text Spanner)"
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%  Cut here ----- Start 'bbarred.ly'

%% PostScript -------------------------------
pScript= \markup {
	\with-dimensions #'(0 . 0.8) #'(0 . 2.0)
	\postscript	#"
	0.15 setlinewidth
	/Times-Roman findfont
	2.0 scalefont
	setfont
	(C)show %%change with B if you prefer
       %(B)show %%change with C if you prefer
	stroke
	0.7 -0.5 moveto
	0.7  1.7 lineto
	stroke"
}
%% Span -----------------------------------
%% Syntax: \bbarre #"text" { notes } - text = any number of box
bbarre= #(define-music-function (barre location str music) (string? ly:music?)
           (let ((spanned-music
                   (let ((first-element #f)
                         (last-element #f)
                         (first-found? #f))
                     (music-map (lambda (m)
                                  (if (eqv? (ly:music-property m 'name) 'EventChord)
                                      (begin
                                        (if (not first-found?)
                                            (begin
                                              (set! first-found? #t)
                                              (set! first-element m)))
                                        (set! last-element m)))
                                  m)
                                music)
                     (if first-found?
                         (begin
                           (set! (ly:music-property first-element 'elements)
                                 (cons (make-music 'TextSpanEvent 'span-direction -1)
                                       (ly:music-property first-element 'elements)))
                           (set! (ly:music-property last-element 'elements)
                                 (cons (make-music 'TextSpanEvent 'span-direction 1)
                                       (ly:music-property last-element 'elements)))))
                     music)))
             (make-music 'SequentialMusic
               'origin location
               'elements (list #{
			\once \override TextSpanner #'font-size = #-2
			\once \override TextSpanner #'font-shape = #'upright
			\once \override TextSpanner #'staff-padding = #3
			\once \override TextSpanner #'style = #'line
                        \once \override TextSpanner #'to-barline = ##f
                        \once \override TextSpanner #'bound-details =  #'((left (Y . 0) (padding . 0.25) (attach-dir . -2)) (right (Y . 0) (padding . 0.25) (attach-dir . 2)))
                        \once  \override TextSpanner #'bound-details #'right #'text = \markup { \draw-line #'( 0 . -.5) }
                        \once  \override TextSpanner #'bound-details #'left #'text =  \markup { \pScript #str }
%% uncomment this line for make full barred
                       % \once  \override TextSpanner #'bound-details #'left #'text =  \markup { "B" #str }
                          #}
    spanned-music))))

%% %%%%%%%  Cut here ----- End 'bbarred.ly'
%% Copy and change the last line for full barred. Rename in 'fbarred.ly'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntaxe: \bbarre #"text" { notes } - text = any number of box
\relative c'{ \clef "G_8" \stemUp \bbarre #"III" { <f a'>16[  c' d c d8] } }
