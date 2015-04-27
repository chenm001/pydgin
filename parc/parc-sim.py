#=========================================================================
# parc-sim.py
#=========================================================================

import os
import sys

# ensure we know where the pypy source code is
try:
  sys.path.append( os.environ['PYDGIN_PYPY_SRC_DIR'] )
except KeyError as e:
  raise ImportError( 'Please define the PYDGIN_PYPY_SRC_DIR '
                     'environment variable!')

# need to add parent directory to get access to pydgin package
# TODO: cleaner way to do this?
sys.path.append('..')

from pydgin.sim     import Sim, init_sim
from pydgin.storage import Memory
from pydgin.misc    import load_program
from bootstrap      import syscall_init, test_init, memory_size
from instruction    import Instruction
from isa            import decode, reg_map

#-------------------------------------------------------------------------
# ParcSim
#-------------------------------------------------------------------------
# PARC Simulator

class ParcSim( Sim ):

  def __init__( self ):
    Sim.__init__( self, "PARC", jit_enabled=True )

  #-----------------------------------------------------------------------
  # decode
  #-----------------------------------------------------------------------
  # The simulator calls architecture-specific decode to decode the
  # instruction bits

  def decode( self, bits ):
    # TODO add decode inside instruction:
    #return decode( bits )
    inst_str, exec_fun = decode( bits )
    return Instruction( bits, inst_str ), exec_fun

  #-----------------------------------------------------------------------
  # init_state
  #-----------------------------------------------------------------------
  # This method is called to load the program and initialize architectural
  # state

  def init_state( self, exe_file, run_argv, run_envp ):

    # Load the program into a memory object

    mem = Memory( size=memory_size, byte_storage=False )
    entrypoint, breakpoint = load_program( exe_file, mem  )

    # Insert bootstrapping code into memory and initialize processor state

    # TODO: testbin is hardcoded false right now
    testbin = False

    if testbin: self.state = test_init   ( mem, debug )
    else:       self.state = syscall_init( mem, breakpoint, run_argv,
                                           run_envp, self.debug )

  #---------------------------------------------------------------------
  # run
  #---------------------------------------------------------------------
  # Override sim's run to print stat_ncycles on exit

  def run( self ):
    Sim.run( self )
    print "Instructions Executed in Stat Region =", self.state.stat_ncycles
    # we also calculate the stat instructions
    for j in xrange( 16 ):
      # first check if the stat was enabled
      if self.state.stat_inst_en[ j ]:
        # calculate the final value
        self.state.stat_inst_ncycles[ j ] += self.state.ncycles - \
                                        self.state.stat_inst_begin[j]

      # print the stat if it's greater than 0
      if self.state.stat_inst_ncycles[ j ] > 0:
        print "  Stat %d = %d" % ( j, self.state.stat_inst_ncycles[ j ] )


# this initializes similator and allows translation and python
# interpretation

init_sim( ParcSim() )

