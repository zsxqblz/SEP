#!/bin/zsh
#SBATCH --job-name=T0
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=4:00:00          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=yz4281@princeton.edu

let i=$1
T0=$((i*0.5))
let dx=20
let dy=20
let Gamma0=1
let time=10
let dt=0.1
let trunc=10
let nsim=100

let id=0+i
let date=230830

julia run_exp.jl $dx $dy $Gamma0 $T0 $time $dt $trunc $nsim data/${date}/${date}_d${id}_