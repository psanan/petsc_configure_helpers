#!/bin/bash

# This a convenience script to submit the job required for PETSc using the batch system. You could also use salloc and aprun, or write your own batch file
rm -f conftest-arch-cray-xc30-daint-32bitind.out tmp.batch
echo '#!/bin/bash'                                         >  tmp.batch
echo '#SBATCH --ntasks=1'                                  >> tmp.batch
echo '#SBATCH --output=conftest-arch-cray-xc30-daint-32bitind.out'  >> tmp.batch
echo '#SBATCH --time=00:00:30'                             >> tmp.batch
if [ $USER == schnepp ]; then
  echo '#SBATCH --account=c05'                               >> tmp.batch #SMS has incluce this line
fi;
echo 'aprun -n 1 ./conftest-arch-cray-xc30-daint-32bitind'          >> tmp.batch
sbatch tmp.batch
echo "To see if this did anything (once the job finishes):"
echo "  cat conftest-arch-cray-xc30-daint-32bitind.out"
rm -f tmp.batch
