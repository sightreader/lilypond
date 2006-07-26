/*
  instrument-name-engraver.cc -- implement Instrument_name_engraver

  source file of the GNU LilyPond music typesetter

  (c) 2000--2006 Han-Wen Nienhuys <hanwen@xs4all.nl>
*/

#include "engraver.hh"
#include "spanner.hh"
#include "pointer-group-interface.hh"
#include "side-position-interface.hh"
#include "axis-group-interface.hh"
#include "align-interface.hh"
#include "text-interface.hh"
#include "system.hh"

#include "translator.icc"

class Instrument_name_engraver : public Engraver
{
public:
  TRANSLATOR_DECLARATIONS (Instrument_name_engraver);

protected:
  Spanner *text_spanner_;

  virtual void finalize ();
  DECLARE_ACKNOWLEDGER (axis_group);
  void process_music ();
};

Instrument_name_engraver::Instrument_name_engraver ()
{
  text_spanner_ = 0;
}

void
Instrument_name_engraver::process_music ()
{
  if (!text_spanner_)
    {
      SCM long_text = get_property ("instrument");
      SCM short_text = get_property ("shortInstrumentName");

      if (!(Text_interface::is_markup (long_text)
	    || Text_interface::is_markup (short_text)))
	{
	  long_text = get_property ("vocalName");
	  short_text = get_property ("shortVocalName");
	}
  
      if (Text_interface::is_markup (long_text)
	  || Text_interface::is_markup (short_text))
	{
	  text_spanner_ = make_spanner ("InstrumentName", SCM_EOL);
	  
	  Grob *col = unsmob_grob (get_property ("currentCommandColumn"));
	  text_spanner_->set_bound (LEFT, col);
	  text_spanner_->set_property ("text", short_text);
	  text_spanner_->set_property ("long-text", long_text);
	}
    }
}

void
Instrument_name_engraver::acknowledge_axis_group (Grob_info info)
{
  if (text_spanner_ 
      && dynamic_cast<Spanner *> (info.grob ())
      && Axis_group_interface::has_axis (info.grob (), Y_AXIS)
      && (!Align_interface::has_interface (info.grob ())))
    {
      Grob *staff = info.grob();
      Pointer_group_interface::add_grob (text_spanner_, ly_symbol2scm ("elements"), staff);
    }
}

void
Instrument_name_engraver::finalize ()
{
  if (text_spanner_)
    {
      text_spanner_->set_bound (RIGHT,
				unsmob_grob (get_property ("currentCommandColumn")));

      Pointer_group_interface::set_ordered (text_spanner_, ly_symbol2scm ("elements"), false);

      System *system = get_root_system (text_spanner_);

      /*
	UGH, should handle this in Score_engraver.
       */
      if (system)
	Axis_group_interface::add_element (system, text_spanner_);
      else
	text_spanner_->programming_error ("can't find root system");
    }
}

#include "translator.icc"

ADD_ACKNOWLEDGER (Instrument_name_engraver, axis_group);

ADD_TRANSLATOR (Instrument_name_engraver,

		/* doc */
		"Creates a system start text for instrument or vocal names.",
		
		/* create */
		"InstrumentName ",
		
		/* accept */
		"",
		
		/* read */
		"currentCommandColumn "
		"shortInstrumentName "
		"instrumentName "
		"shortVocalName "
		"vocalName "
		,

		/* write */ "");
