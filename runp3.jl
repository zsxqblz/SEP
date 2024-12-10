using Distributed
addprocs(10)
@everywhere using SharedArrays
using Dates

@everywhere include("dependencies.jl")
@everywhere include("sim.jl")
@everywhere include("exp_dist.jl")
@everywhere include("pp.jl")

for i = 1:1
    @show i
    println("Current date and time: ", now())

    dx = 100
    dy = 100
    dt = 200
    pdr = 0.
    panh = 1
    pgen = 0.01
    tempr = 100
    nsim = 1000
    idx_start = 51

    # pcoor,ncoor,scoor,currentHistSum = expDistCoorRndField(dx,dy,dt,pdr,panh,pgen,nsim,tempr,true)
    pdr = 0.25
    pdf = 0.25
    pcoor,ncoor,scoor, = expDistCoorRndChecker(dx,dy,dt,pdr,pdf,panh,pgen,nsim,true)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    save3DData(x_l,y_l,t_l,pcoor,string("data/241030/241030_",(idx_start+i),"_pcoor"))
    save3DData(x_l,y_l,t_l,ncoor,string("data/241030/241030_",(idx_start+i),"_ncoor"))
    save3DData(x_l,y_l,t_l,scoor,string("data/241030/241030_",(idx_start+i),"_scoor"))
    # save3DData(x_l,y_l,t_l,currentHistSum,string("data/241030/241030_",(idx_start+i),"_current"))
end
println("Current date and timeW: ", now())