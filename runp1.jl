using Distributed
addprocs(10)
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
    pdr = 0.25+0.01*i
    panh = 1
    pgen = 0.01
    nsim = 100
    idx_start = 20

    pcoor,ncoor,scoor = expCoorRnd(dx,dy,dt,pdr,pdf,panh,pgen,nsim,true)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    save3DData(x_l,y_l,t_l,pcoor,string("data/240919/240919_",(idx_start+i),"_pcoor"))
    save3DData(x_l,y_l,t_l,ncoor,string("data/240919/240919_",(idx_start+i),"_ncoor"))
    save3DData(x_l,y_l,t_l,scoor,string("data/240919/240919_",(idx_start+i),"_scoor"))
end