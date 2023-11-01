function genLatticeHistSim(dx,dy,dt,nsim)
    return zeros(Bool, (dx,dy,dt,nsim)), zeros(Bool, (dx,dy,dt,nsim))
end

function genLattice(dx,dy)
    return zeros(Bool, (dx, dy)), zeros(Bool, (dx, dy))
end

function genLatticeHist(dx,dy,dt)
    return zeros(Bool, (dx,dy,dt)), zeros(Bool, (dx,dy,dt))
end

function updateParticle(pLattice,nLattice,pLatticeN,nLatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
    # pup = pdf
    # pdown = pup + pdf
    # pdrive = pdown + pdr
    for y = 1:dy, x = 1:dx
        walkParticle(pLattice,nLattice,pLatticeN,nLatticeN,x,y,pup,pdown,pdrive)
        annhilateParticle(pLatticeN,nLatticeN,x,y,panh)
        genParticle(pLatticeN,nLatticeN,x,y,pgen)
    end
end

function walkParticle(pLattice,nLattice,pLatticeN,nLatticeN,x,y,pup,pdown,pdrive)
    if pLattice[x,y]
        rnd = rand()
        if rnd < pup && !pLatticeN[x,mod1(y+1,end)]# && !pLattice[x,mod1(y+1,end)]
            pLatticeN[x,mod1(y+1,end)] = true
        elseif rnd < pdown && !pLatticeN[x,mod1(y-1,end)]# && !pLattice[x,mod1(y-1,end)]
            pLatticeN[x,mod1(y-1,end)] = true
        elseif rnd < pdrive && !pLatticeN[mod1(x-1,end),y]# && !pLattice[mod1(x-1,end),y]
            pLatticeN[mod1(x-1,end),y] = true
        elseif !pLatticeN[mod1(x+1,end),y]# && !pLattice[mod1(x+1,end),y]
            pLatticeN[mod1(x+1,end),y] = true
        else
            pLatticeN[x,y] = true
        end
    end
    if nLattice[x,y]
        rnd = rand()
        if rnd < pup && !nLatticeN[x,mod1(y+1,end)]# && !nLattice[x,mod1(y+1,end)]
            nLatticeN[x,mod1(y+1,end)] = true
        elseif rnd < pdown && !nLatticeN[x,mod1(y-1,end)]# && !nLattice[x,mod1(y-1,end)]
            nLatticeN[x,mod1(y-1,end)] = true
        elseif rnd < pdrive && !nLatticeN[mod1(x+1,end),y]# && !nLattice[mod1(x+1,end),y]
            nLatticeN[mod1(x+1,end),y] = true
        elseif !nLatticeN[mod1(x-1,end),y]# && !nLattice[mod1(x-1,end),y]
            nLatticeN[mod1(x-1,end),y] = true
        else
            nLatticeN[x,y] = true
        end
    end
end

function annhilateParticle(pLatticeN,nLatticeN,x,y,panh)
    rnd = rand()
    if pLatticeN[x,y] && nLatticeN[x,y] && (rnd < panh)
        pLatticeN[x,y] = false
        nLatticeN[x,y] = false
    end
end   

function genParticle(pLatticeN,nLatticeN,x,y,pgen)
    rnd = rand()
    if !pLatticeN[x,y] && !nLatticeN[x,y] && (rnd < pgen)
        pLatticeN[x,y] = true
        nLatticeN[x,y] = true
    end
end    

function delxy(dx,dy,lattice,pbc=true)
    delx = zeros(Float64,dx,dy)
    dely = zeros(Float64,dx,dy)
    if pbc
        for y = 1:dy
            for x = 1:dx
                delx[x,y] = (
                    rem2pi(lattice[mod1(x+1,end),y]-lattice[mod1(x,end),y], RoundNearest)
                    +rem2pi(lattice[mod1(x,end),y]-lattice[mod1(x-1,end),y], RoundNearest)
                )
                dely[x,y] = (
                    rem2pi(lattice[x,mod1(y,end)]-lattice[x,mod1(y,end)], RoundNearest)
                    +rem2pi(lattice[x,mod1(y,end)]-lattice[x,mod1(y-1,end)], RoundNearest)
                )
            end
        end
    else
        for xy = 1:dy
            for x = 1:dx
                delx[x,y] = (
                    rem2pi(lattice[mod1(x+1,end),y]-lattice[mod1(x,end),y], RoundNearest)
                    +rem2pi(lattice[mod1(x,end),y]-lattice[mod1(x-1,end),y], RoundNearest)
                )
                dely[x,y] = (
                    rem2pi(lattice[x,mod1(y,end)]-lattice[x,mod1(y,end)], RoundNearest)
                    +rem2pi(lattice[x,mod1(y,end)]-lattice[x,mod1(y-1,end)], RoundNearest)
                )
            end
        end
    end
    return delx, dely
end