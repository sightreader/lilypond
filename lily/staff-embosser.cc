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

#include "warn.hh"
#include "embosser-group.hh"
#include "context.hh"

#include "translator.icc"

class Staff_embosser : public Embosser
{
public:
  TRANSLATOR_DECLARATIONS (Staff_embosser);
  ~Staff_embosser ();

protected:
  virtual void finalize ();
  virtual void initialize ();
  void process_music ();
  void stop_translation_timestep ();

private:
};

void
Staff_embosser::boot ()
{
}

ADD_TRANSLATOR (Staff_embosser,
                /* doc */
                "",

                /* create */
                "",

                /* read */
                "",

                /* write */
                "");

Staff_embosser::Staff_embosser ()
{
}

Staff_embosser::~Staff_embosser ()
{
}

void
Staff_embosser::initialize ()
{
}

void
Staff_embosser::process_music ()
{
}

void
Staff_embosser::stop_translation_timestep ()
{
}

void
Staff_embosser::finalize ()
{
}

