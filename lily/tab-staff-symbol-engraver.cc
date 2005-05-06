/*
  tab-staff-symbol-engraver.cc -- implement Tab_staff_symbol_engraver

  source file of the GNU LilyPond music typesetter

  (c) 2005 Han-Wen Nienhuys <hanwen@xs4all.nl>

*/

#include "staff-symbol-engraver.hh"
#include "spanner.hh"

class Tab_staff_symbol_engraver : public Staff_symbol_engraver
{
public:
  TRANSLATOR_DECLARATIONS (Tab_staff_symbol_engraver);
protected:
  virtual void start_spanner ();
};

void
Tab_staff_symbol_engraver::start_spanner ()
{
  bool init = !span_;
  Staff_symbol_engraver::start_spanner ();
  if (init)
    {
      int k = scm_ilength (get_property ("stringTunings"));
      if (k >= 0)
	span_->set_property ("line-count", scm_int2num (k));
    }
}

Tab_staff_symbol_engraver::Tab_staff_symbol_engraver ()
{
}

ADD_TRANSLATOR (Tab_staff_symbol_engraver,
		/* descr */ "Create a staff-symbol, but look at stringTunings for the number of lines."
		"staff lines.",
		/* creats*/ "StaffSymbol",
		/* accepts */ "staff-span-event",
		/* acks  */ "grob-interface",
		/* reads */ "stringTunings",
		/* write */ "");
