using Distributed
addprocs(10)
@everywhere using SharedArrays
using Dates

@everywhere include("dependencies.jl")
@everywhere include("sim.jl")
@everywhere include("exp_dist.jl")
@everywhere include("pp.jl")

@everywhere Je_l = [1,2,3,4,5,6,7,8]
@everywhere Rv_l = [5.7e20, 6.4e21, 2.7e22, 7.8e22, 1.8e23, 2.9e23, 5.3e23, 8.9e23]

println("Current date and time: ", now())
@everywhere i = 8
println("iteration ", i)

@everywhere Je = Je_l[i]
@everywhere Rv = Rv_l[i]

@everywhere dx = 100
@everywhere dy = 100
@everywhere dt = 300
@everywhere pdr = 0.0511217 * Je
@everywhere panh = 1
@everywhere pgen = 3.65155e-26 * Rv
@everywhere tempr = 1000
@everywhere nsim = 100
@everywhere idx_start = 10


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
# save3DData(x_l,y_l,t_l,pcoor,string("data/250211/250211_",(idx_start+i),"_pcoor"))
# save3DData(x_l,y_l,t_l,ncoor,string("data/250211/250211_",(idx_start+i),"_ncoor"))
save3DData(x_l,y_l,t_l,scoor,string("data/250211/250211_",(idx_start+i),"_scoor"))
# save3DData(x_l,y_l,t_l,currentHistSum,string("data/250211/250211_",(idx_start+i),"_current"))

println("Current date and time: ", now())
rmprocs(workers())