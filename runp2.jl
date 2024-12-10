using Distributed
addprocs(8)
@everywhere using SharedArrays
using Dates

@everywhere include("dependencies.jl")
@everywhere include("sim.jl")
@everywhere include("exp.jl")
@everywhere include("pp.jl")

@sync @distributed for i = 1:8
    dx = 100
    dy = 100
    dt = 200
    pdr = 0.5
    panh = 1
    pgen = 0.01
    tempr = 10^(range(1,stop=2,length=8)[i])
    nsim = 100
    idx_start = 60

    pcoor,ncoor,scoor = expCoorRndField(dx,dy,dt,pdr,panh,pgen,nsim,tempr,true)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    save3DData(x_l,y_l,t_l,pcoor,string("data/241030/241030_",(idx_start+i),"_pcoor"))
    save3DData(x_l,y_l,t_l,ncoor,string("data/241030/241030_",(idx_start+i),"_ncoor"))
    save3DData(x_l,y_l,t_l,scoor,string("data/241030/241030_",(idx_start+i),"_scoor"))
end