% paper16.ly



\version "1.3.59";

paper_sixteen = \paper {
	staffheight = 16.0\pt;
	font_Large = 12.;
	font_large = 10.;
	font_normal = 8.;
	font_script = 7.;

	magnification_dynamic = 1.0;
	font_finger = 4.;
	font_volta = 5.;
	font_number = 8.;
	font_timesig = 8.;
	font_dynamic = 10.;
	font_mark = 10.;
	font_msam = 8.;

	0 = \font "feta16" 
	-1 = \font "feta13"
	-2 = \font "feta11"
	-3 = \font "feta11"
	
	"font_feta" = 16.;
	"font_feta-1" = 13.;
	"font_feta-2" = 11.;
	"font_feta-3" = 11.;

	\include "params.ly";
}

\paper {\paper_sixteen }
