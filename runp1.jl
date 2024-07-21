using Distributed
addprocs(3)
@everywhere using SharedArrays
using Dates

@everywhere include("dependencies.jl")
@everywhere include("sim.jl")
@everywhere include("exp.jl")
@everywhere include("pp.jl")

@sync @distributed for i = 1:10
    dx = 100
    dy = 100
    dt = 400
    pdf = 0.25
    pdr = 0.25
    panh = 1
    pgen = 0.001*i
    nsim = 1000
    idx_start = 0

    pcoor,ncoor,scoor = expCoorRndChecker(dx,dy,dt,pdr,pdf,panh,pgen,nsim,true)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    save3DData(x_l,y_l,t_l,pcoor,string("data/240718/240718_",(idx_start+i),"_pcoor"))
    save3DData(x_l,y_l,t_l,ncoor,string("data/240718/240718_",(idx_start+i),"_ncoor"))
    save3DData(x_l,y_l,t_l,scoor,string("data/240718/240718_",(idx_start+i),"_scoor"))
end