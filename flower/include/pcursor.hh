/*
  pcursor.hh -- part of flowerlib

  (c) 1996 Han-Wen Nienhuys&Jan Nieuwenhuizen
*/

#ifndef PCURSOR_HH
#define PCURSOR_HH

#include "plist.hh"
#include "cursor.hh"

/**  cursor to go with Pointer_list. 
  don't create Pointer_list<void*>'s.
  This cursor is just an interface class for Cursor. It takes care of the
  appropriate type casts
 */
template<class T>
class PCursor : private Cursor<void *> {
    friend class IPointer_list<T>;

    /// delete contents
    void junk();
public:
    Cursor<void*>::ok;
    Cursor<void*>::del;
    Cursor<void*>::backspace;
    T remove_p() {
	T p = ptr();
	Cursor<void*>::del();
	return p;
    }
    T remove_prev_p() {
    	assert( ok() );
	(*this)--;
	return remove_p();
    }
    
    Pointer_list<T> &list() { return (Pointer_list<T>&)Cursor<void*>::list(); }
    PCursor<T> operator++(int) { return Cursor<void*>::operator++(0);}
    PCursor<T> operator--(int) { return Cursor<void*>::operator--(0); }
    PCursor<T> operator+=(int i) { return Cursor<void*>::operator+=(i);}
    PCursor<T> operator-=(int i) { return Cursor<void*>::operator-=(i); }    
    PCursor<T> operator -(int no) const { return Cursor<void*>::operator-(no);}
    int operator -(PCursor<T> op) const { return Cursor<void*>::operator-(op);}
    PCursor<T> operator +( int no) const {return Cursor<void*>::operator+(no);}    PCursor(const Pointer_list<T> & l) : Cursor<void*> (l) {}
    PCursor() : Cursor<void*> () {}
    PCursor( const Cursor<void*>& cursor ) : Cursor<void*>(cursor) { }
    void* vptr() const { return *((Cursor<void*> &) *this); }

    // should return T& ?
    T ptr() const { return (T) vptr(); }
    T operator ->() const { return  ptr(); }
    operator T() { return ptr(); }
    T operator *() { return ptr(); }
    void add(T const & p ) { Cursor<void*>::add((void*) p); }
    void insert(T const & p ) { Cursor<void*>::insert((void*) p);}    
    static int compare(PCursor<T> a,PCursor<T>b) {
	return Cursor<void*>::compare(a,b);
    }
};



#include "compare.hh"
template_instantiate_compare(PCursor<T>, PCursor<T>::compare, template<class T>);

#endif
