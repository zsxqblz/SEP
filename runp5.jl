using Distributed
addprocs(10)
@everywhere using SharedArrays
using Dates

@everywhere include("dependencies.jl")
@everywhere include("sim.jl")
@everywhere include("exp_dist.jl")
@everywhere include("pp.jl")

println("Current date and time: ", now())

@everywhere dx = 150
@everywhere dy = 150
@everywhere dt = 400
@everywhere pdr = 0.
@everywhere panh = 1
@everywhere pgen = 0.01
@everywhere tempr = 1000
@everywhere nsim = 200
@everywhere idx_start = 4

# Shared memory arrays
pcoor = SharedArray{Float64}(dx, dy, dt)
ncoor = SharedArray{Float64}(dx, dy, dt)
scoor = SharedArray{Float64}(dx, dy, dt)

@everywhere function run_simulation(dx, dy, dt, pdr, panh, pgen, tempr)
    pLatticeHist, nLatticeHist = genLatticeHistWarm(dx, dy, dt, pdr, panh, pgen, tempr)
    for t = 2:dt
        plattice = @view pLatticeHist[:, :, t-1]
        nlattice = @view nLatticeHist[:, :, t-1]
        platticeN = @view pLatticeHist[:, :, t]
        nlatticeN = @view nLatticeHist[:, :, t]
        updateParticleRndField(plattice,nlattice,platticeN,nlatticeN,dx,dy,pdr,pgen,panh,tempr)
    end
    pcoor_local = real(findCorrelationFFT(Int.(pLatticeHist)))
    ncoor_local = real(findCorrelationFFT(Int.(nLatticeHist)))
    scoor_local = real(findCorrelationFFT(Int.(pLatticeHist) - Int.(nLatticeHist)))
    return pcoor_local, ncoor_local, scoor_local
end

# Parallel computation with reduction
results = @distributed (+) for sim_i = 1:nsim
    pcoor_local, ncoor_local, scoor_local = run_simulation(dx, dy, dt, pdr, panh, pgen, tempr)
    # pcoor += pcoor_local
    # ncoor += ncoor_local
    # scoor += scoor_local
    [pcoor_local, ncoor_local, scoor_local]
end

pcoor .+= results[1]
ncoor .+= results[2]
scoor .+= results[3]

pcoor = pcoor / nsim
ncoor = ncoor / nsim
scoor = scoor / nsim

x_l = collect(1:dx)
y_l = collect(1:dy)
t_l = collect(1:dt)
save3DData(x_l,y_l,t_l,pcoor,string("data/241210/241210_",(idx_start),"_pcoor"))
save3DData(x_l,y_l,t_l,ncoor,string("data/241210/241210_",(idx_start),"_ncoor"))
save3DData(x_l,y_l,t_l,scoor,string("data/241210/241210_",(idx_start),"_scoor"))

println("Current date and time: ", now())