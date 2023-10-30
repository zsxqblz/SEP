function expOnce(dx,dy,dt,pdr,pdf,panh,pgen,nsim)
    pup = pdf
    pdown = pup + pdf
    pdrive = pdown + pdr

    pLatticeHistSim, nLatticeHistSim = genLatticeHistSim(dx,dy,dt,nsim)

    for sim_i = 1:nsim, t = 2:dt
        # @show size(pLatticeHistSim)
        plattice = @view pLatticeHistSim[sim_i,t-1,:,:]
        nlattice = @view nLatticeHistSim[sim_i,t-1,:,:]
        platticeN = @view pLatticeHistSim[sim_i,t,:,:]
        nlatticeN = @view nLatticeHistSim[sim_i,t,:,:]
        updateParticle(plattice,nlattice,platticeN,nlatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
    end
    return pLatticeHistSim,nLatticeHistSim
end

function expCoor(dx,dy,dt,pdr,pdf,panh,pgen,nsim)
    pup = pdf
    pdown = pup + pdf
    pdrive = pdown + pdr

    pcoor = zeros(Float64,(dx, dy, dt))
    ncoor = zeros(Float64,(dx, dy, dt))
    scoor = zeros(Float64,(dx, dy, dt))
    for sim_i = 1:nsim
        pLatticeHist, nLatticeHist = genLatticeHist(dx,dy,dt)
        for t = 2:dt
            plattice = @view pLatticeHist[:,:,t-1]
            nlattice = @view nLatticeHist[:,:,t-1]
            platticeN = @view pLatticeHist[:,:,t]
            nlatticeN = @view nLatticeHist[:,:,t]
            updateParticle(plattice,nlattice,platticeN,nlatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
        end
        pcoor += real(findCorrelationFFT(Int.(pLatticeHist)))
        ncoor += real(findCorrelationFFT(Int.(nLatticeHist)))
        scoor += real(findCorrelationFFT(Int.(pLatticeHist)-Int.(nLatticeHist)))
    end
    pcoor = pcoor / nsim
    ncoor = ncoor / nsim
    scoor = scoor / nsim
    return pcoor,ncoor,scoor
end

function expCoor(dx,dy,dt,pdr,pdf,panh,pgen,nsim,showProg::Bool)
    pup = pdf
    pdown = pup + pdf
    pdrive = pdown + pdr

    pcoor = zeros(Float64,(dx, dy, dt))
    ncoor = zeros(Float64,(dx, dy, dt))
    scoor = zeros(Float64,(dx, dy, dt))
    @showprogress for sim_i = 1:nsim
        pLatticeHist, nLatticeHist = genLatticeHist(dx,dy,dt)
        for t = 2:dt
            plattice = @view pLatticeHist[:,:,t-1]
            nlattice = @view nLatticeHist[:,:,t-1]
            platticeN = @view pLatticeHist[:,:,t]
            nlatticeN = @view nLatticeHist[:,:,t]
            updateParticle(plattice,nlattice,platticeN,nlatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
        end
        pcoor += real(findCorrelationFFT(Int.(pLatticeHist)))
        ncoor += real(findCorrelationFFT(Int.(nLatticeHist)))
        scoor += real(findCorrelationFFT(Int.(pLatticeHist)-Int.(nLatticeHist)))
    end
    pcoor = pcoor / nsim
    ncoor = ncoor / nsim
    scoor = scoor / nsim
    return pcoor,ncoor,scoor
end

function expBruteCoor(dx,dy,dt,pdr,pdf,panh,pgen,nsim,trunc,showProg::Bool)
    pup = pdf
    pdown = pup + pdf
    pdrive = pdown + pdr

    pcoor = zeros(Float64,(dx, dy, dt-trunc))
    ncoor = zeros(Float64,(dx, dy, dt-trunc))
    scoor = zeros(Float64,(dx, dy, dt-trunc))
    @showprogress for sim_i = 1:nsim
        pLatticeHist, nLatticeHist = genLatticeHist(dx,dy,dt)
        for t = 2:dt
            plattice = @view pLatticeHist[:,:,t-1]
            nlattice = @view nLatticeHist[:,:,t-1]
            platticeN = @view pLatticeHist[:,:,t]
            nlatticeN = @view nLatticeHist[:,:,t]
            updateParticle(plattice,nlattice,platticeN,nlatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
        end

        pcoor += findCorrelation(Int.(pLatticeHist),dt,dx,dy,trunc)
        ncoor += findCorrelation(Int.(nLatticeHist),dt,dx,dy,trunc)
        scoor += findCorrelation(Int.(pLatticeHist)-Int.(nLatticeHist),dt,dx,dy,trunc)
    end
    pcoor = pcoor / nsim
    ncoor = ncoor / nsim
    scoor = scoor / nsim
    return pcoor,ncoor,scoor
end