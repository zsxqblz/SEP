#!/bin/zsh
#SBATCH --job-name=SEP
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --mem-per-cpu=4G         # memory per cpu-core (4G is default)
#SBATCH --time=23:59:59          # total run time limit (HH:MM:SS)
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=yz4281@princeton.edu

let i=$1
T0=$((i*0.5))
let dx=20
let dy=20
let dt=100
let pdf=0.25
let pdr=0.25
let panh=1
let pgen=0.01
let nsim=5000
let trunc=10

let id=0+i
let date=231025

julia run_expBruteCoor.jl $dx $dy $dt $pdf $pdr $panh $pgen $nsim $trunc data/${date}/${date}_d${id}_