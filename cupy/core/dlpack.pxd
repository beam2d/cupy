# DLPACK_VERSION: 010

from cupy.core.core cimport ndarray

cpdef object toDlpack(ndarray array) except +
