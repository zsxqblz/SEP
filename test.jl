include("dependencies.jl")
include("sim.jl")
include("exp.jl")
include("pp.jl")

let 
    x = LinRange(-5,5,100)
    y = [0]
    t = LinRange(0.1,10,50)
    data = [1]./sqrt.(t') .* exp.(-(x.^2) ./ t')
    coor = findCorrelationFFT(data)
    save3DData(x,y,t,real(data),"data/231025/231025_2_testData")
    save3DData(x,y,t,real(coor),"data/231025/231025_2_testFFT")
end

let 
    temp = Int.([true,false])
    @show ifft(fft(temp))
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

# scan pdr
let 
    for i = 1:10
        run(`clear`)
        dx = 100
        dy = 100
        dt = 300
        pdf = 0.25
        pdr = 0.0
        panh = 1
        pgen = 0.001*i
        nsim = 100
        idx_start = 20

        pcoor,ncoor,scoor = expCoor(dx,dy,dt,pdr,pdf,panh,pgen,nsim,true)

        x_l = collect(1:dx)
        y_l = collect(1:dy)
        t_l = collect(1:dt)
        save3DData(x_l,y_l,t_l,pcoor,string("data/240627/240627_",(idx_start+i),"_pcoor"))
        save3DData(x_l,y_l,t_l,ncoor,string("data/240627/240627_",(idx_start+i),"_ncoor"))
        save3DData(x_l,y_l,t_l,scoor,string("data/240627/240627_",(idx_start+i),"_scoor"))
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