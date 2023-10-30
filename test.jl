include("dependencies.jl")
include("sim.jl")
include("exp.jl")
include("pp.jl")

let 
    real([1,2im])
end

# run & save one simulation
let 
    run(`clear`)
    dx = 20
    dy = 20
    dt = 100
    pdf = 0.05
    pdr = 0.8
    panh = 1
    pgen = 0.01
    nsim = 1

    pLatticeHistSim,nLatticeHistSim = expOnce(dx,dy,dt,pdr,pdf,panh,pgen,nsim)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    sim_l = collect(1:nsim)
    save4DData(sim_l,t_l,x_l,y_l,Int.(pLatticeHistSim),"data/231019/test_p")
    save4DData(sim_l,t_l,x_l,y_l,Int.(nLatticeHistSim),"data/231019/test_n")
end

# run & save correlation
let 
    run(`clear`)
    dx = 20
    dy = 20
    dt = 100
    pdf = 0.25
    pdr = 0.25
    panh = 1
    pgen = 0.01
    nsim = 10000

    pcoor,ncoor,scoor = expCoor(dx,dy,dt,pdr,pdf,panh,pgen,nsim,true)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    save3DData(x_l,y_l,t_l,pcoor,"data/231019/1_pcoor")
    save3DData(x_l,y_l,t_l,ncoor,"data/231019/1_ncoor")
    save3DData(x_l,y_l,t_l,scoor,"data/231019/1_scoor")
end

# run & save brute force correlation
let 
    run(`clear`)
    dx = 20
    dy = 20
    dt = 100
    pdf = 0.25
    pdr = 0.25
    panh = 1
    pgen = 0.01
    nsim = 100
    trunc = 10

    pcoor,ncoor,scoor = expBruteCoor(dx,dy,dt,pdr,pdf,panh,pgen,nsim,trunc,true)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt-trunc)
    save3DData(x_l,y_l,t_l,pcoor,"data/231025/231025_1_pcoor")
    save3DData(x_l,y_l,t_l,ncoor,"data/231025/231025_1_ncoor")
    save3DData(x_l,y_l,t_l,scoor,"data/231025/231025_1_scoor")
end