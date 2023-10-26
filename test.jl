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

let 
    rnd = rand()
end

let 
    run(`clear`)
    dx = 2
    dy = 2
    dt = 10
    pdf = 0.25
    pdr = 0.4
    panh = 1
    pgen = 0.1
    nsim = 1
    pLatticeHistSim, nLatticeHistSim = genLatticeHistSim(dx,dy,dt,nsim)
    plattice = @view pLatticeHistSim[1,1,:,:]
end

# run one exp
let 
    run(`clear`)
    dx = 20
    dy = 20
    Gamma0 = 1
    T0 = 5
    time = 10
    dt = 0.1
    trunc = 10
    nsim = 1

    numt = convert(Int64,time/dt)

    lattice_corr, vortice_corr = expOnce(dx,dy,Gamma0,T0,time,dt,trunc,nsim,true,true)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(range(dt,time,step=dt))
    saveComplex3DData(t_l[1:numt-trunc],x_l,y_l,lattice_corr,"data/230829/lattice_corr_1")
    saveComplex3DData(t_l[1:numt-trunc],x_l,y_l,vortice_corr,"data/230829/vortice_corr_1")
end