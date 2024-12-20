#!/bin/zsh
#SBATCH --job-name=SEP
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=23:00:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --array=0-9
#SBATCH --mail-user=yz4281@princeton.edu

let "i=$SLURM_ARRAY_TASK_ID+1"
# let "i=$1+1"
let dx=100
let dy=100
let dt=300
let pdf=0.25
let "pdr=0.01*i"
let panh=1
let "pgen=0.001"
let nsim=30000

let "id=40+i"
let date=240630

julia run_expCoor.jl $dx $dy $dt $pdf $pdr $panh $pgen $nsim data/${date}/${date}_d${id}_