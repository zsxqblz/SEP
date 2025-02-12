include("dependencies.jl")
include("sim.jl")
include("exp.jl")
include("pp.jl")

dx = parse(Int64,ARGS[1])
dy = parse(Int64,ARGS[2])
dt = parse(Int64,ARGS[3])
tempr = parse(Float64,ARGS[4])
pdr = parse(Float64,ARGS[5])
panh = parse(Float64,ARGS[6])
pgen = parse(Float64,ARGS[7])
nsim = parse(Int64,ARGS[8])
filename = ARGS[9]

pcoor,ncoor,scoor,currentHistSum = expCoorRndField(dx,dy,dt,pdr,panh,pgen,nsim,tempr,true)

x_l = collect(1:dx)
y_l = collect(1:dy)
t_l = collect(1:dt)
save3DData(x_l,y_l,t_l,pcoor,filename*"pcoor")
save3DData(x_l,y_l,t_l,ncoor,filename*"ncoor")
save3DData(x_l,y_l,t_l,scoor,filename*"scoor")
save3DData(x_l,y_l,t_l,currentHistSum,filename*"current")
