/*   
  group-interface.hh -- declare Group_interface
  
  source file of the GNU LilyPond music typesetter
  
  (c) 1999--2005 Han-Wen Nienhuys <hanwen@cs.uu.nl>
  
 */

#ifndef GROUP_INTERFACE_HH
#define GROUP_INTERFACE_HH

#include "grob.hh"
#include "string.hh"
/**
   Look at Score element ELT as thing which has a list property called
   NAME_. Normally the list would contain Grobs, but
   sometimes it can be different things.

   todo: reename as list_interface?
*/

struct Group_interface
{
public:
  static int count (Grob*, SCM);
  static void add_thing (Grob*, SCM, SCM);
};

struct Pointer_group_interface : public Group_interface {
public:
  static void add_grob (Grob*, SCM nm, Grob*e);
};

template<class T>
Link_array<T>
Pointer_group_interface__extract_grobs (Grob const *elt, T *, const char* name)
{
  Link_array<T> arr;

  for (SCM s = elt->get_property (name); scm_is_pair (s); s = scm_cdr (s))
    {
      SCM e = scm_car (s);
      arr.push (dynamic_cast<T*> (unsmob_grob (e)));
    }

  arr.reverse ();
  return arr;
}




#endif /* GROUP_INTERFACE_HH */

