\header{
filename =	 "bassi-part.ly";
% %title =	 "Ouvert\\"ure zu Collins Trauerspiel \\"Coriolan\\" Opus 62";
description =	 "";
composer =	 "Ludwig van Beethoven (1770-1827)";
enteredby =	 "JCN";
copyright =	 "public domain";
}

\version "1.3.59";

\include "global.ly"
\include "violoncello.ly"
\include "contrabasso.ly"

bassiGroup = \context GrandStaff = bassi_group <
	\context Staff=one { 
		\clef "bass"; 
		\context Voice
		\property Voice.soloADue = ##f 
		\skip 1*314; 
		\bar "|."; 
	}
	\context Staff=two { 
		\clef "bass"; 
		\context Voice
		\property Voice.soloADue = ##f 
		\skip 1*314; 
		\bar "|."; 
	}
	\context Staff=one \partcombine Staff
		\context Thread=one \violoncello
		\context Thread=two \contrabasso
>

%\include "coriolan-part-paper.ly"
\include "coriolan-part-combine-paper.ly"

\score{
	\bassiGroup
	\paper{
		\translator { \HaraKiriStaffContext }
		\translator {
			\StaffContext
			\consists "Slur_engraver";
			\consists "Rest_engraver";
			\consists "Tie_engraver";
		}
		\translator{
			\VoiceContext
			\remove "Rest_engraver";
			\remove "Slur_engraver";
			\remove "Tie_engraver";
		}
	}
	\include "coriolan-midi.ly"
}

