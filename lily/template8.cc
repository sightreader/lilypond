/*
  template8.cc -- instantiate audio List classes

  source file of the GNU LilyPond music typesetter

  (c) 1996,1997 Han-Wen Nienhuys <hanwen@stack.nl>
*/

#include "proto.hh"
#include "plist.hh"
#include "audio-column.hh"
#include "audio-item.hh"
#include "cursor.tcc"
#include "list.tcc"
#include "pcursor.tcc"
#include "plist.tcc"


IPL_instantiate(Audio_item);
IPL_instantiate(Audio_column);

