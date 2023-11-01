#!/bin/zsh
#SBATCH --job-name=SEP
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=4:00:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=yz4281@princeton.edu

let i=$1
let dx=100
let dy=100
let dt=100
let pdf=0.25
let pdr=0.25
let panh=1
let pgen=0.01
let nsim=10000

let id=0+i
let date=231025

julia run_expCoor.jl $dx $dy $dt $pdf $pdr $panh $pgen $nsim data/${date}/${date}_d${id}_