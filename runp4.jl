using Distributed
addprocs(10)
@everywhere using SharedArrays
using Dates

@everywhere include("dependencies.jl")
@everywhere include("sim.jl")
@everywhere include("exp_dist.jl")
@everywhere include("pp.jl")

println("Current date and time: ", now())

@everywhere dx = 100
@everywhere dy = 100
@everywhere dt = 200
@everywhere pdr = 0.
@everywhere panh = 1
@everywhere pgen = 0.01
@everywhere tempr = 1000
@everywhere nsim = 50
@everywhere idx_start = 1


pcoor = SharedArray{Float64}(dx, dy, dt)
ncoor = SharedArray{Float64}(dx, dy, dt)
scoor = SharedArray{Float64}(dx, dy, dt)
currentHistSum = SharedArray{Float64}(dx, dy, dt)

results = expDistCoorRndField(dx,dy,dt,pdr,panh,pgen,nsim,tempr,true)

pcoor .+= results[1]
ncoor .+= results[2]
scoor .+= results[3]
currentHistSum .+= results[4]

pcoor = pcoor / nsim
ncoor = ncoor / nsim
scoor = scoor / nsim
currentHistSum = currentHistSum / nsim

x_l = collect(1:dx)
y_l = collect(1:dy)
t_l = collect(1:dt)
save3DData(x_l,y_l,t_l,pcoor,string("data/241210/241210_",(idx_start),"_pcoor"))
save3DData(x_l,y_l,t_l,ncoor,string("data/241210/241210_",(idx_start),"_ncoor"))
save3DData(x_l,y_l,t_l,scoor,string("data/241210/241210_",(idx_start),"_scoor"))
save3DData(x_l,y_l,t_l,currentHistSum,string("data/241210/241210_",(idx_start),"_current"))

println("Current date and time: ", now())