% paper13-init.ly


\version "1.7.18"

paperThirteen = \paper {
	staffheight = 13.0\pt
	#(define fonts (make-font-list 'paper13))
	
	\include "params-init.ly"
}

\paper { \paperThirteen }
