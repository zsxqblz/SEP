include("dependencies.jl")
include("sim.jl")
include("exp.jl")
include("pp.jl")

# run & save one simulation
let 
    run(`clear`)
    dx = 20
    dy = 20
    dt = 100
    pdf = 0.25
    pdr = 0.4
    panh = 1
    pgen = 0.01
    nsim = 1

    pLatticeHistSim,nLatticeHistSim = expOnceRndChecker(dx,dy,dt,pdr,pdf,panh,pgen,nsim)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    sim_l = collect(1:nsim)
    save4DData(x_l,y_l,t_l,sim_l,Int.(pLatticeHistSim),"data/240718/240718_rndChecker_1_p")
    save4DData(x_l,y_l,t_l,sim_l,Int.(nLatticeHistSim),"data/240718/240718_rndChecker_1_n")
end


# scan pdr
let 
    for i = 1:10
        run(`clear`)
        dx = 100
        dy = 100
        dt = 200
        pdf = 0.25
        pdr = 0.25
        panh = 1
        pgen = 0.01*i
        nsim = 100
        idx_start = 0

        pcoor,ncoor,scoor = expCoorRndChecker(dx,dy,dt,pdr,pdf,panh,pgen,nsim,true)

        x_l = collect(1:dx)
        y_l = collect(1:dy)
        t_l = collect(1:dt)
        save3DData(x_l,y_l,t_l,pcoor,string("data/240718/240718_",(idx_start+i),"_pcoor"))
        save3DData(x_l,y_l,t_l,ncoor,string("data/240718/240718_",(idx_start+i),"_ncoor"))
        save3DData(x_l,y_l,t_l,scoor,string("data/240718/240718_",(idx_start+i),"_scoor"))
    end
end

# scan pdr RndField
let 
    run(`clear`)
    for i = 1:1
        dx = 100
        dy = 100
        dt = 200
        pdr = 0.
        panh = 1
        pgen = 0.01
        tempr = 1000
        nsim = 1000
        idx_start = 50

        pcoor,ncoor,scoor,currentHistSum = expCoorRndField(dx,dy,dt,pdr,panh,pgen,nsim,tempr,true)

        x_l = collect(1:dx)
        y_l = collect(1:dy)
        t_l = collect(1:dt)
        save3DData(x_l,y_l,t_l,pcoor,string("data/241030/241030_",(idx_start+i),"_pcoor"))
        save3DData(x_l,y_l,t_l,ncoor,string("data/241030/241030_",(idx_start+i),"_ncoor"))
        save3DData(x_l,y_l,t_l,scoor,string("data/241030/241030_",(idx_start+i),"_scoor"))
        save3DData(x_l,y_l,t_l,currentHistSum,string("data/241030/241030_",(idx_start+i),"_current"))
    end
end

# run & save correlation
let 
    run(`clear`)
    dx = 100
    dy = 100
    dt = 300
    pdf = 0.25
    pdr = 0.
    panh = 1
    pgen = 0.001
    nsim = 100

    pcoor,ncoor,scoor = expCoor(dx,dy,dt,pdr,pdf,panh,pgen,nsim,true)

    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    save3DData(x_l,y_l,t_l,pcoor,"data/240627/240627_3_pcoor")
    save3DData(x_l,y_l,t_l,ncoor,"data/240627/240627_3_ncoor")
    save3DData(x_l,y_l,t_l,scoor,"data/240627/240627_3_scoor")
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

let 
    X = collect(1:3)
    X= shuffle(X)
    @show X
    a = ['a','b','c']
    @show a[X]
end

let 
    pLattice = zeros(Bool,5,5)
    pLattice[2,3] = true
    indices = findall(!iszero, pLattice)
    @show indices[1]
end