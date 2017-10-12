#!/usr/bin/env python
################################################################################
# Test with pyTestHarness (bitbucket.org/dmay/pythontestharness)               #
#------------------------------------------------------------------------------#
# This is supposed to work with any PETSC_DIR and PETSC_ARCH, on any system!   #
################################################################################

import os
import sys
srcDir = os.path.split(os.path.abspath(__file__))[0]    # directory of this file
sys.path.append(os.path.join(srcDir,'pythontestharness','lib'))  # overrides
try :
    import pyTestHarness.harness as pthharness
    import pyTestHarness.test as pthtest
except ImportError :
    print("********************")
    print("pyTestHarness was not found. Exiting.")
    print("If you already have this somewhere on your system, add pythontestharness/lib to your PYTHONPATH.")
    print("Otherwise, you may clone as follows:")
    print("  git clone https://bitbucket.org/dmay/pythontestharness " + os.path.join(srcDir,'pythontestharness'))
    print("********************")
    sys.exit(1)

PETSC_DIR = os.environ.get('PETSC_DIR')
PETSC_ARCH = os.environ.get('PETSC_ARCH')
PETSC_SRC_DIR = os.environ.get('PETSC_SRC_DIR') # to get executables from
if not PETSC_DIR or not (PETSC_ARCH or PETSC_SRC_DIR) :
  raise Exception('You must define PETSC_DIR and one of PETSC_ARCH or PETSC_SRC_DIR (to get example with prefix build)')
SNESExDir = os.path.join(PETSC_SRC_DIR,'src','snes','examples','tutorials')
if not PETSC_SRC_DIR :
  PETSC_SRC_DIR = PETSC_DIR

#------------------------------------------------------------------------------#
def main():
  os.system('make -C ' +  SNESExDir + ' clean')
  os.system('make -C ' +  SNESExDir + ' ex19')

  registeredTests = [ex19test(1),ex19test(2)]

  h = pthharness.Harness(registeredTests)
  h.execute()
  h.verify()

#------------------------------------------------------------------------------#
def ex19test(ranks) :
  testName = 'ex19'+'_'+str(ranks)
  launch = os.path.join(SNESExDir,'ex19') + ' -da_refine 3 -snes_monitor_short -pc_type mg -ksp_type fgmres -pc_mg_type full'
  expected_file = os.path.join(srcDir,'ex19.expected')

  def comparefunc(test) :
    test.compareFloatingPoint('0 SNES Function norm ',1.0e-5)
    test.compareFloatingPoint('1 SNES Function norm ',1.0e-5)
    test.compareFloatingPoint('2 SNES Function norm ',1.0e-5)
    test.compareInteger('Number of SNES iterations ',0)

  test = pthtest.Test(testName,ranks,launch,expected_file)
  test.setVerifyMethod(comparefunc)
  test.setUseSandbox()
  return(test)
  pass

#------------------------------------------------------------------------------#
if __name__ == "__main__":
  main()
