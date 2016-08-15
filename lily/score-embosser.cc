/*
  This file is part of LilyPond, the GNU music typesetter.

  Copyright (C) 2016 Ralph Little

  LilyPond is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  LilyPond is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with LilyPond.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "score-embosser.hh"

#include "context-def.hh"
#include "dispatcher.hh"
#include "global-context.hh"
#include "embosser-output.hh"
#include "output-def.hh"
#include "string-convert.hh"
#include "warn.hh"

ADD_TRANSLATOR_GROUP (Score_embosser,
                      /* doc */
                      "",

                      /* create */
                      "",

                      /* read */
                      "",

                      /* write */
                      ""
                     );

Score_embosser::Score_embosser ()
{
}

Score_embosser::~Score_embosser ()
{
}

void
Score_embosser::connect_to_context (Context *c)
{
  Embosser_group::connect_to_context (c);

  Dispatcher *d = c->get_global_context ()->event_source ();
  d->add_listener (GET_LISTENER (Score_embosser, one_time_step), ly_symbol2scm ("OneTimeStep"));
  d->add_listener (GET_LISTENER (Score_embosser, prepare), ly_symbol2scm ("Prepare"));
  d->add_listener (GET_LISTENER (Score_embosser, finish), ly_symbol2scm ("Finish"));
}

void
Score_embosser::disconnect_from_context ()
{
  Dispatcher *d = context ()->get_global_context ()->event_source ();
  d->remove_listener (GET_LISTENER (Score_embosser, one_time_step), ly_symbol2scm ("OneTimeStep"));
  d->remove_listener (GET_LISTENER (Score_embosser, prepare), ly_symbol2scm ("Prepare"));
  d->remove_listener (GET_LISTENER (Score_embosser, finish), ly_symbol2scm ("Finish"));

  Embosser_group::disconnect_from_context ();
}

void
Score_embosser::prepare (SCM sev)
{
  precomputed_recurse_over_translators (context (), START_TRANSLATION_TIMESTEP, UP);
}

void
Score_embosser::finish (SCM)
{
  recurse_over_translators
    (context (),
     Callback0_wrapper::make_smob<Translator, &Translator::finalize> (),
     Callback0_wrapper::make_smob<Translator_group, &Translator_group::finalize> (),
     UP);
}

void
Score_embosser::one_time_step (SCM)
{
  if (!to_boolean (context ()->get_property ("skipTypesetting")))
    {
      precomputed_recurse_over_translators (context (), PROCESS_MUSIC, UP);
      do_announces ();
    }

  precomputed_recurse_over_translators (context (), STOP_TRANSLATION_TIMESTEP, UP);
}

void
Score_embosser::derived_mark () const
{
  if (embossing_)
    scm_gc_mark (embossing_->self_scm ());


  Embosser_group::derived_mark ();
}

void
Score_embosser::initialize ()
{
	Translator_group::initialize ();
}


