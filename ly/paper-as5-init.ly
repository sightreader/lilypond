% paper-as5-init.ly

\version "1.7.18"

paperAsFive = \paper {
	staffheight = 5.\char

	\stylesheet #(as-make-font-list 'as5)
	
	\translator { \StaffContext barSize = #5 }

	% no beam-slope
	%\translator { \VoiceContext beamHeight = #0 }
	\include "params-as-init.ly"
}

\paper { \paperAsFive }
