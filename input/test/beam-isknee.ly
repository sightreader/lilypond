\score{
	\type GrandStaff <
	\type Staff=one \notes\relative c'{
		s1
	}
	\type Staff=two \notes\relative c'{
		\clef bass;
% no knee
		\stemup [c8 \translator Staff=one \stemdown g'16 f]
		s8
		s2
	}
	>
	\paper{
		\translator{
			\GrandStaffContext
			minVerticalAlign = 2.8*\staffheight;
			maxVerticalAlign = 2.8*\staffheight;
		}
		linewidth=-1.;
	}
}
