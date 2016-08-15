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

#include "embosser.hh"
#include "global-context.hh"
#include "stream-event.hh"
#include "warn.hh"
#include "translator.icc"
#include "international.hh"

class Note_embosser : public Embosser
{
public:
  TRANSLATOR_DECLARATIONS (Note_embosser);

protected:
  void stop_translation_timestep ();
  void process_music ();

  void listen_note (Stream_event *);
private:
};

void
Note_embosser::process_music ()
{
  warning(_ ("Embosser::process_music"));
}

void
Note_embosser::stop_translation_timestep ()
{
  warning(_ ("Embosser::stop_translation_timestep"));
}

void
Note_embosser::listen_note (Stream_event *ev)
{
  warning(_ ("Embosser::listen_note"));
}


void
Note_embosser::boot ()
{
  ADD_LISTENER (Note_embosser, note);
}

ADD_TRANSLATOR (Note_embosser,
                /* doc */
                "",

                /* create */
                "",

                /* read */
                "",

                /* write */
                ""
               );


Note_embosser::Note_embosser ()
{
  warning(_ ("Note_embosser::Note_embosser"));

}
