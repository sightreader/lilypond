/*
  This file is part of LilyPond, the GNU music typesetter.

  Copyright (C) 1997--2015 Han-Wen Nienhuys <hanwen@xs4all.nl>

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

#include "translator.hh"

#include "international.hh"
#include "scm-hash.hh"
#include "warn.hh"
#include "protected-scm.hh"

const char * const Translator_creator::type_p_name_ = 0;

SCM
Translator_creator::mark_smob () const
{
  scm_gc_mark (name_);
  scm_gc_mark (description_);
  return listener_list_;
}

Translator *
Translator_creator::get_translator (Context *c)
{
  return allocate_ (this, c);
}

Translator_creator::Translator_creator (SCM name, SCM description, SCM listener_list,
                                        Translator * (*allocate)
                                        (Translator_creator const *, Context *))
  : name_ (name), description_ (description), listener_list_ (listener_list),
    allocate_ (allocate)
{
  smobify_self ();
}

Protected_scm global_translator_dict;

LY_DEFINE (get_all_translators, "ly:get-all-translators", 0, 0, 0, (),
           "Return a list of all translator objects that may be"
           " instantiated.")
{
  Scheme_hash_table *dict = unsmob<Scheme_hash_table> (global_translator_dict);
  SCM l = dict ? dict->to_alist () : SCM_EOL;

  // Ok, this is a bit of a crutch: so far, the Scheme code base has
  // no idea about the Translator_creator type and uses of
  // ly:get-all-translators rely on the output being translators.
  for (SCM s = l; scm_is_pair (s); s = scm_cdr (s))
    scm_set_car_x (s, unsmob <Translator_creator> (scm_cdar (s))
                        ->get_translator (0)->unprotect ());

  return l;
}

void
add_translator_creator (Translator_creator *t)
{
  Scheme_hash_table *dict = unsmob<Scheme_hash_table> (global_translator_dict);
  if (!dict)
    {
      global_translator_dict = Scheme_hash_table::make_smob ();
      dict = unsmob<Scheme_hash_table> (global_translator_dict);
    }

  dict->set (t->get_name (), t->unprotect ());
}

Translator_creator *
get_translator_creator (SCM sym)
{
  SCM v = SCM_BOOL_F;
  Scheme_hash_table *dict = unsmob<Scheme_hash_table> (global_translator_dict);
  if (dict)
    dict->try_retrieve (sym, &v);

  if (scm_is_false (v))
    {
      warning (_f ("unknown translator: `%s'", ly_symbol2string (sym).c_str ()));
      return 0;
    }

  return unsmob<Translator_creator> (v);
}
