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

#ifndef SCORE_EMBOSSER_HH
#define SCORE_EMBOSSER_HH

#include "moment.hh"
#include "embosser-group.hh"

class Score_embosser : public Embosser_group
{
public:
  DECLARE_CLASSNAME (Score_embosser);
  Embossing *embossing_;

  ~Score_embosser ();
  Score_embosser ();

protected:
  void finish (SCM);
  void prepare (SCM);
  void one_time_step (SCM);

  /* Engraver_group_engraver interface */
  virtual void connect_to_context (Context *);
  virtual void disconnect_from_context ();
  virtual void initialize ();
  virtual void derived_mark () const;

};

#endif // SCORE_EMBOSSER_HH
