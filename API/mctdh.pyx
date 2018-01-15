from libcpp.string cimport string
from libcpp cimport bool

cdef extern from "<iostream>" namespace "std":
    cdef cppclass ostream:
        ostream& write(const char*, int) except +
    ostream cout

cdef extern from "../MCTDH/ControlParameters.h":
    cdef cppclass ControlParameters:
        ControlParameters() except +
        void Initialize(string, ostream&)
        double Eps_CMF()
        double Regularization()

cdef extern from "../MCTDH/mctdhBasis.h":
    cdef cppclass mctdhBasis:
        mctdhBasis() except +
        void Initialize(string, ControlParameters&)
        double RegularizationDensity()
        size_t nPhysNodes()
        const mctdhNode & MCTDHNode(size_t i)

cdef extern from "../MCTDH/mctdhNode.h":
    cdef cppclass mctdhNode:
        mctdhNode() except +
        void info(ostream&)
        bool IsBottomlayer()

cdef class PyControlParameters:
    cdef ControlParameters *control_ptr
    def __cinit__(self):
        self.control_ptr = new ControlParameters()
    def __dealloc__(self):
        del self.control_ptr
    def PyInitialize(self, a):
            self.control_ptr.Initialize(a, cout)
    def PyEps_CMF(self):
        return self.control_ptr.Eps_CMF()
    def PyRegularization(self):
        return self.control_ptr.Regularization()

cdef ControlParameters * PyToCpp(PyControlParameters py_obj):
    return py_obj.control_ptr

cdef class PymctdhBasis:
  cdef mctdhBasis *basis_ptr
  def __cinit__(self):
      self.basis_ptr = new mctdhBasis()
  def __dealloc__(self):
      del self.basis_ptr
  cpdef PyInitialize(self, filename, py_config_obj):
      cdef ControlParameters * new_config_ptr = PyToCpp(py_config_obj)
      self.basis_ptr.Initialize(filename, new_config_ptr[0])
  cpdef PyRegularizationDensity(self):
      return self.basis_ptr.RegularizationDensity()
  cpdef PynPhysNodes(self):
      return self.basis_ptr.nPhysNodes()

cdef mctdhBasis * PyToCpp2(PymctdhBasis py_obj):
    return py_obj.basis_ptr

cdef class PyMctdhNode:
  cdef mctdhNode * node_ptr
  def __cinit__(self):
      self.node_ptr = new mctdhNode()
#  def __dealloc__(self):
#      del self.node_ptr
  cpdef PyInitialize(py_basis_obj):
      cdef mctdhBasis * new_basis_ptr = PyToCpp2(py_basis_obj)
      cdef const mctdhNode * new_node_ptr
      new_node_ptr = &(new_basis_ptr.MCTDHNode(1))
