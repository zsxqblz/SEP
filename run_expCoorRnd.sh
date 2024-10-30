#!/bin/zsh
#SBATCH --job-name=SEP
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=10G         # memory per cpu-core (4G is default)
#SBATCH --time=23:59:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --array=0-49
#SBATCH --mail-user=yz4281@princeton.edu

let "i=$SLURM_ARRAY_TASK_ID+1"
# let "i=$1+1"
let dx=200
let dy=200
let dt=800
let pdf=0.25
let "pdr=0.35"
let panh=1
let "pgen=0.1"
let nsim=5000
# let nsim=1

let "id=8100+i"
let date=240922

julia run_expCoorRnd.jl $dx $dy $dt $pdf $pdr $panh $pgen $nsim data/${date}/${date}_d${id}_