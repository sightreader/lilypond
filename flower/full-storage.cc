/*
  full-storage.cc -- implement Full_storage

  source file of the Flower Library

  (c) 1997 Han-Wen Nienhuys <hanwen@stack.nl>
*/

#include "full-storage.hh"

void
Full_storage::operator=(Full_storage const &fs)
{
    resize(fs.height_i_, fs.width_i_);
    OK();
    fs.OK();
    for (int i=0; i<height_i_; i++)
	for (int j=0; j<width_i_; j++)
	    els_p_p_[i][j]= fs.els_p_p_[i][j];
}

void
Full_storage::OK() const
{
#ifndef NDEBUG
    //    static Real dummy;		
    assert(max_height_i_ >= height_i_ && max_width_i_ >= width_i_);
    assert(height_i_ >= 0 && width_i_ >= 0);
    assert(els_p_p_||!max_height_i_);
#endif
}
void
Full_storage::resize_cols(int newh)
{
    if (newh <= max_height_i_) {
	height_i_=newh;
	return;
    }
   
    Real ** newa=new Real*[newh];
    int j=0;
    for (; j < height_i_; j++)
	newa[j] = els_p_p_[j];
    for (; j < newh; j++)
	newa[j] = new Real[max_width_i_];
    delete[] els_p_p_;
    els_p_p_=newa;

    height_i_ = max_height_i_ = newh;
}

void
Full_storage::resize_rows(int neww)
{
    if (neww <= max_width_i_) {
	width_i_=neww;
	return;
    }
    for (int i=0; i < max_height_i_ ; i++) {
	Real* newa = new Real[neww];
	for (int k=0; k < width_i_; k++)
	    newa[k] = els_p_p_[i][k];

	delete[] els_p_p_[i];
	els_p_p_[i] = newa;
    }
    width_i_ = max_width_i_ = neww;	
}

Full_storage::~Full_storage() {
    for (int i=0; i < max_height_i_; i++)
	delete [] els_p_p_[i];
    delete[] els_p_p_;
}

void
Full_storage::resize(int rows, int cols)
{
    OK();
    resize_cols(rows);
    resize_rows(cols);

}


bool
Full_storage::mult_ok(int i, int j) const
{
    return valid(i,j);
}

bool
Full_storage::trans_ok(int i, int j) const
{
       return valid(i,j);
} 


void
Full_storage::trans_next(int &i, int &j) const
{
    assert(trans_ok(i,j));
    i++;
    if (i >= height_i_) {
	i=0;
	j ++;
    }
}

void
Full_storage::mult_next(int &i, int &j) const
{
    assert(mult_ok(i,j));
    j++;
    if (j >= width_i_) {
	j=0;
	i++;
    }
}

void
Full_storage::delete_column(int k)
{
    assert(0 <= k &&k<width_i_);    
    for (int i=0; i< height_i_ ; i++)
	for (int j=k+1; j <width_i_; j++)
	    els_p_p_[i][j-1]=els_p_p_[i][j];
    width_i_--;
}
void
Full_storage::delete_row(int k)
{
    assert(0 <= k &&k<height_i_);
    for (int i=k+1; i < height_i_ ; i++)
	for (int j=0; j < width_i_; j++)
	    els_p_p_[i-1][j]=els_p_p_[i][j];
    height_i_--;
}


void
Full_storage::insert_row(int k)
{
    assert(0 <= k&& k <=height_i_);
    resize_cols(height_i_+1);
    for (int i=height_i_-1; i > k ; i--)
	for (int j=0; j <width_i_; j++)
	    els_p_p_[i][j]=els_p_p_[i-1][j];

}


Array<Real>
Full_storage::row(int n) const
{
    Array<Real> r;
    for (int j = 0; j < width_i_; j++)
	r.push(els_p_p_[n][j]);
    return r;
}

Array<Real>
Full_storage::column(int n) const
{
    
    Array<Real> r;
    for (int i = 0; i<height_i_; i++)
	r.push(els_p_p_[i][n]);
    return r;
}


Full_storage::Full_storage(Full_storage&s)
{
    init();
    (*this) = s;
}
Matrix_storage*
Full_storage::clone()
{
    return new Full_storage(*this);
}


Matrix_storage *
Matrix_storage::get_full(int n, int m)
{
    return new Full_storage(n,m);
}

bool
Full_storage::try_right_multiply(Matrix_storage * dest, Matrix_storage const * right)
{
    if (dest->name() != Full_storage::static_name() ||
	right->name() != Full_storage::static_name())
	return false;

    Full_storage *d_l = (Full_storage*)dest;
    Full_storage *r_l = (Full_storage*)right;
    
    d_l->set_size(height_i_, r_l->width_i_);
    for (int i=0; i < d_l->height_i_; i++)
	for (int j = 0; j < d_l->width_i_; j++) {
	    Real &r(d_l->els_p_p_[i][j]);
	    r=0.0;
	    for (int k = 0; k < width_i_; k++)
		r += els_p_p_[i][k] * r_l->els_p_p_[k][j];
	    
	}
    return true;
    
    
}
IMPLEMENT_STATIC_NAME(Full_storage);
IMPLEMENT_STATIC_NAME(Matrix_storage);
