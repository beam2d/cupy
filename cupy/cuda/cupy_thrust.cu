#include <thrust/device_ptr.h>
#include <thrust/device_vector.h>
#include <thrust/sequence.h>
#include <thrust/sort.h>
#include "cupy_common.h"
#include "cupy_thrust.h"

using namespace thrust;


/*
 * sort
 */

template <typename T>
void cupy::thrust::_sort(void *start, size_t ndim, size_t *shape) {

    size_t size;
    device_ptr<T> dp_first, dp_last;

    // Compute the total size of the array.
    size = shape[0];
    for (size_t i = 1; i < ndim; ++i) {
        size *= shape[i];
    }

    dp_first = device_pointer_cast(static_cast<T*>(start));
    dp_last  = device_pointer_cast(static_cast<T*>(start) + size);

    if (ndim == 1) {
        stable_sort(dp_first, dp_last);
    } else {
        device_vector<size_t> d_keys(size);

        // Generate key indices.
        transform(make_counting_iterator<size_t>(0),
                  make_counting_iterator<size_t>(size),
                  make_constant_iterator<size_t>(shape[ndim-1]),
                  d_keys.begin(),
                  divides<size_t>());

        // Sorting with back-to-back approach.
        stable_sort_by_key(dp_first,
                           dp_last,
                           d_keys.begin(),
                           less<T>());

        stable_sort_by_key(d_keys.begin(),
                           d_keys.end(),
                           dp_first,
                           less<size_t>());
    }
}

template void cupy::thrust::_sort<cpy_byte>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_ubyte>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_short>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_ushort>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_int>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_uint>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_long>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_ulong>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_float>(void *, size_t, size_t *);
template void cupy::thrust::_sort<cpy_double>(void *, size_t, size_t *);


/*
 * argsort
 */

template <typename T>
class elem_less {
public:
    elem_less(void *data):_data((const T*)data) {}
    __device__ bool operator()(size_t i, size_t j) { return _data[i] < _data[j]; }
private:
    const T *_data;
};

template <typename T>
void cupy::thrust::_argsort(size_t *idx_start, void *data_start, size_t num) {
    /* idx_start is the beggining of the output array where the indexes that
       would sort the data will be placed. The original contents of idx_start
       will be destroyed. */
    device_ptr<size_t> dp_first = device_pointer_cast(idx_start);
    device_ptr<size_t> dp_last  = device_pointer_cast(idx_start + num);
    sequence(dp_first, dp_last);
    stable_sort< device_ptr<size_t> >(dp_first, dp_last, elem_less<T>(data_start));
}

template void cupy::thrust::_argsort<cpy_byte>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_ubyte>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_short>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_ushort>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_int>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_uint>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_long>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_ulong>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_float>(size_t *, void *, size_t);
template void cupy::thrust::_argsort<cpy_double>(size_t *, void *, size_t);
