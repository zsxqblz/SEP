using Distributed
addprocs(10)
@everywhere using SharedArrays
using Dates

@everywhere include("dependencies.jl")
@everywhere include("sim.jl")
@everywhere include("exp_dist.jl")
@everywhere include("pp.jl")

println("Current date and time: ", now())

# Paired arrays to scan over (Je and Rv come in pairs)
@everywhere Je_array = [0.01, 0.0221, 0.0304, 0.0418, 0.0489, 0.0574, 0.0672, 0.0788, 0.0924, 0.108]
@everywhere Rv_array = [1.9e12, 2.1e13, 1.3e14, 4.5e14, 8.4e14, 1.6e15, 2.9e15, 5.4e15, 1.0e16, 1.9e16]

# Fixed parameters
@everywhere dx = 100
@everywhere dy = 100
@everywhere dt = 300
@everywhere panh = 1
@everywhere tempr = 1000
@everywhere nsim = 100
@everywhere idx_start = 21
@everywhere date = "250629"

# Function to run simulation for given Je and Rv
@everywhere function run_simulation_for_params(Je_val, Rv_val, dx, dy, dt, panh, tempr, nsim)
    pdr = 5.11217 * Je_val
    pgen = 3.65155e-18 * Rv_val
    
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
    
    return pcoor, ncoor, scoor, currentHistSum
end

# Main scanning loop - single loop for paired Je and Rv values
# @everywhere current_idx = idx_start

for i in 1:length(Je_array)
    Je_val = Je_array[i]
    Rv_val = Rv_array[i]
    current_idx = idx_start + i - 1
    
    println("Running simulation ", current_idx, " with Je=", Je_val, ", Rv=", Rv_val)
    println("Current date and time: ", now())
    
    # Run the simulation
    pcoor, ncoor, scoor, currentHistSum = run_simulation_for_params(Je_val, Rv_val, dx, dy, dt, panh, tempr, nsim)
    
    # Save results
    x_l = collect(1:dx)
    y_l = collect(1:dy)
    t_l = collect(1:dt)
    
    save3DData(x_l,y_l,t_l,pcoor,string("data/", date, "/", date, "_", current_idx, "_pcoor"))
    save3DData(x_l,y_l,t_l,ncoor,string("data/", date, "/", date, "_", current_idx, "_ncoor"))
    save3DData(x_l, y_l, t_l, scoor, string("data/", date, "/", date, "_", current_idx, "_scoor"))
    save3DData(x_l, y_l, t_l, currentHistSum, string("data/", date, "/", date, "_", current_idx, "_current"))
    
    println("Saved simulation ", current_idx, " with Je=", Je_val, ", Rv=", Rv_val)
    
    # Increment index for next simulation
    current_idx += 1
end

println("All simulations completed. Current date and time: ", now())
rmprocs(workers())
