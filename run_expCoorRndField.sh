#!/bin/zsh
#SBATCH --job-name=SEP
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=10G         # memory per cpu-core (4G is default)
#SBATCH --time=23:59:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --array=0-9
#SBATCH --mail-user=yz4281@princeton.edu

let "i=$SLURM_ARRAY_TASK_ID+1"
# let "i=$1+1"
let dx=3
let dy=1600
let dt=6000
let "pdr=0."
let panh=1
let "pgen=0.01"
let tempr=1000
let nsim=50
# let nsim=1

let "id=12100+i"
let date=241210

julia run_expCoorRndField.jl $dx $dy $dt $tempr $pdr $panh $pgen $nsim data/${date}/${date}_d${id}_