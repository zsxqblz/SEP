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

function expOnceRndChecker(dx,dy,dt,pdr,pdf,panh,pgen,nsim)
    pup = pdf
    pdown = pup + pdf
    pdrive = pdown + pdr

    pLatticeHistSim, nLatticeHistSim = genLatticeHistSim(dx,dy,dt,nsim)

    for sim_i = 1:nsim, t = 2:dt
        plattice = @view pLatticeHistSim[:,:,t-1,sim_i]
        nlattice = @view nLatticeHistSim[:,:,t-1,sim_i]
        platticeN = @view pLatticeHistSim[:,:,t,sim_i]
        nlatticeN = @view nLatticeHistSim[:,:,t,sim_i]
        updateParticleRndChecker(plattice,nlattice,platticeN,nlatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
    end
    return pLatticeHistSim,nLatticeHistSim
end

function expCoor(dx,dy,dt,pdr,pdf,panh,pgen,nsim)
    pup = pdf
    pdown = pup + pdf
    # pdrive = pdown + pdr
    pdrive = pdr

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
    # pdrive = pdown + pdr
    pdrive = pdr

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
    # return Int.(pLatticeHist), Int.(nLatticeHist), Int.(pLatticeHist)-Int.(nLatticeHist)
end

function expCoorChecker(dx,dy,dt,pdr,pdf,panh,pgen,nsim,showProg::Bool)
    pup = pdf
    pdown = pup + pdf
    pdrive = pdown + pdr
    # pdrive = pdr

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
            updateParticleChecker(plattice,nlattice,platticeN,nlatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
        end
        pcoor += real(findCorrelationFFT(Int.(pLatticeHist)))
        ncoor += real(findCorrelationFFT(Int.(nLatticeHist)))
        scoor += real(findCorrelationFFT(Int.(pLatticeHist)-Int.(nLatticeHist)))
    end
    pcoor = pcoor / nsim
    ncoor = ncoor / nsim
    scoor = scoor / nsim
    return pcoor,ncoor,scoor
    # return Int.(pLatticeHist), Int.(nLatticeHist), Int.(pLatticeHist)-Int.(nLatticeHist)
end

function expCoorRndChecker(dx,dy,dt,pdr,pdf,panh,pgen,nsim,showProg::Bool)
    pup = pdf
    pdown = pup + pdf
    pdrive = pdown + pdr
    # pdrive = pdr

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
            updateParticleRndChecker(plattice,nlattice,platticeN,nlatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
        end
        pcoor += real(findCorrelationFFT(Int.(pLatticeHist)))
        ncoor += real(findCorrelationFFT(Int.(nLatticeHist)))
        scoor += real(findCorrelationFFT(Int.(pLatticeHist)-Int.(nLatticeHist)))
    end
    pcoor = pcoor / nsim
    ncoor = ncoor / nsim
    scoor = scoor / nsim
    return pcoor,ncoor,scoor
    # return Int.(pLatticeHist), Int.(nLatticeHist), Int.(pLatticeHist)-Int.(nLatticeHist)
end

function expCoorRnd(dx,dy,dt,pdr,pdf,panh,pgen,nsim,showProg::Bool)
    pup = pdf
    pdown = pup + pdf
    # pdrive = pdown + pdr
    pdrive = pdr-0.25

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
            updateParticleRnd(plattice,nlattice,platticeN,nlatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
        end
        pcoor += real(findCorrelationFFT(Int.(pLatticeHist)))
        ncoor += real(findCorrelationFFT(Int.(nLatticeHist)))
        scoor += real(findCorrelationFFT(Int.(pLatticeHist)-Int.(nLatticeHist)))
    end
    pcoor = pcoor / nsim
    ncoor = ncoor / nsim
    scoor = scoor / nsim
    return pcoor,ncoor,scoor
    # return Int.(pLatticeHist), Int.(nLatticeHist), Int.(pLatticeHist)-Int.(nLatticeHist)
end

function expCoorRndField(dx,dy,dt,pdr,panh,pgen,nsim,tempr,showProg::Bool)
    pcoor = zeros(Float64,(dx, dy, dt))
    ncoor = zeros(Float64,(dx, dy, dt))
    scoor = zeros(Float64,(dx, dy, dt))
    currentHistSum = zeros(Float64,(dx, dy, dt))
    @showprogress for sim_i = 1:nsim
        # pLatticeHist, nLatticeHist = genLatticeHist(dx,dy,dt)
        pLatticeHist, nLatticeHist = genLatticeHistWarm(dx,dy,dt,pdr,panh,pgen,tempr)
        currentHist = zeros(Float64,(dx, dy, dt))
        for t = 2:dt
            plattice = @view pLatticeHist[:,:,t-1]
            nlattice = @view nLatticeHist[:,:,t-1]
            platticeN = @view pLatticeHist[:,:,t]
            nlatticeN = @view nLatticeHist[:,:,t]
            current = @view currentHist[:,:,t]
            # updateParticleRndField(plattice,nlattice,platticeN,nlatticeN,dx,dy,pdr,pgen,panh,tempr)
            updateParticleRndField(plattice,nlattice,platticeN,nlatticeN,current,dx,dy,pdr,pgen,panh,tempr)
            updateCurrent(current,plattice,nlattice,platticeN,nlatticeN,dx,dy)
        end
        pcoor += real(findCorrelationFFT(Int.(pLatticeHist)))
        ncoor += real(findCorrelationFFT(Int.(nLatticeHist)))
        scoor += real(findCorrelationFFT(Int.(pLatticeHist)-Int.(nLatticeHist)))
        currentHistSum += currentHist
    end
    pcoor = pcoor / nsim
    ncoor = ncoor / nsim
    scoor = scoor / nsim
    currentHistSum = currentHistSum / nsim
    return pcoor,ncoor,scoor,currentHistSum
    # return Int.(pLatticeHist), Int.(nLatticeHist), Int.(pLatticeHist)-Int.(nLatticeHist)
end

function expDistCoorRndField(dx,dy,dt,pdr,panh,pgen,nsim,tempr,showProg::Bool)
    pcoor = zeros(Float64,(dx, dy, dt))
    ncoor = zeros(Float64,(dx, dy, dt))
    scoor = zeros(Float64,(dx, dy, dt))
    currentHistSum = zeros(Float64,(dx, dy, dt))
    @distributed for sim_i = 1:nsim
        pLatticeHist, nLatticeHist = genLatticeHist(dx,dy,dt)
        currentHist = zeros(Float64,(dx, dy, dt))
        for t = 2:dt
            plattice = @view pLatticeHist[:,:,t-1]
            nlattice = @view nLatticeHist[:,:,t-1]
            platticeN = @view pLatticeHist[:,:,t]
            nlatticeN = @view nLatticeHist[:,:,t]
            current = @view currentHist[:,:,t]
            # updateParticleRndField(plattice,nlattice,platticeN,nlatticeN,dx,dy,pdr,pgen,panh,tempr)
            updateParticleRndField(plattice,nlattice,platticeN,nlatticeN,current,dx,dy,pdr,pgen,panh,tempr)
            updateCurrent(current,plattice,nlattice,platticeN,nlatticeN,dx,dy)
        end
        pcoor += real(findCorrelationFFT(Int.(pLatticeHist)))
        ncoor += real(findCorrelationFFT(Int.(nLatticeHist)))
        scoor += real(findCorrelationFFT(Int.(pLatticeHist)-Int.(nLatticeHist)))
        currentHistSum += currentHist
    end
    pcoor = pcoor / nsim
    ncoor = ncoor / nsim
    scoor = scoor / nsim
    currentHistSum = currentHistSum / nsim
    return pcoor,ncoor,scoor,currentHistSum
    # return Int.(pLatticeHist), Int.(nLatticeHist), Int.(pLatticeHist)-Int.(nLatticeHist)
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