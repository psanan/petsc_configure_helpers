#!/usr/bin/env python
# Test with SciATH (github.com/sciath/sciath)
# This is supposed to work with any PETSC_DIR and PETSC_ARCH, on any system!

import os
import sys
import traceback
srcDir = os.path.split(os.path.abspath(__file__))[0]    # directory of this file
sys.path.append(os.path.join(srcDir,'sciath'))  # overrides
try:
  from sciath.harness import Harness
  from sciath.test import Test
  from sciath.job import Job
except Exception:
  if not sys.exc_info()[-1].tb_next:     # Check that the traceback has depth 1
    traceback.print_exc()
    print('********************')
    print('The required python library SciATH was not found. Exiting.')
    print('If SciATH is installed on your system, ensure it is included in the environment variable PYTHONPATH.')
    print('If SciATH is not installed, obtain the source by executing the following:')
    print('  git submodule init && git submodule update')
    print('********************')
    sys.exit(1)
  raise

PETSC_DIR = os.environ.get('PETSC_DIR')
PETSC_ARCH = os.environ.get('PETSC_ARCH')
PETSC_SRC_DIR = os.environ.get('PETSC_SRC_DIR') # to get example source from
if not PETSC_DIR or not (PETSC_ARCH or PETSC_SRC_DIR):
  raise Exception('You must define PETSC_DIR and one of PETSC_ARCH or PETSC_SRC_DIR (to get example source with prefix build)')
if not PETSC_SRC_DIR:
  PETSC_SRC_DIR = PETSC_DIR
snes_ex_dir = os.path.join(PETSC_SRC_DIR,'src','snes','examples','tutorials')

def main():
  os.system('make -C ' +  snes_ex_dir + ' clean')
  os.system('make -C ' +  snes_ex_dir + ' ex19')

  Harness([ex19test(1),ex19test(2)]).run_from_args()

  print("Only error codes are currently checked, so consider examining the test output directly")

def ex19test(ranks):
  test_name = 'ex19'+'_'+str(ranks)
  command = [os.path.join(snes_ex_dir,'ex19'),'-da_refine','3','-snes_monitor_short','-pc_type mg','-ksp_type fgmres','-pc_mg_type full']
  test = Test(Job(command),test_name)
  # TODO: compare to ex19.expected with smart diff, once that feature is properly updated
  return(test)

if __name__ == '__main__':
  main()
