function genLatticeHistSim(dx,dy,dt,nsim)
    return zeros(Bool, (dx,dy,dt,nsim)), zeros(Bool, (dx,dy,dt,nsim))
end

function genLattice(dx,dy)
    return zeros(Bool, (dx, dy)), zeros(Bool, (dx, dy))
end

function genLatticeHist(dx,dy,dt)
    return zeros(Bool, (dx,dy,dt)), zeros(Bool, (dx,dy,dt))
    # return rand(Bool, (dx,dy,dt)), rand(Bool, (dx,dy,dt))
end

function genLatticeHistWarm(dx,dy,dt,pdr,panh,pgen,tempr)
    plattice = zeros(Bool,(dx, dy))
    nlattice = zeros(Bool,(dx, dy))
        for t = 2:dt
            platticeN = zeros(Bool,(dx, dy))
            nlatticeN = zeros(Bool,(dx, dy))
            updateParticleRndField(plattice,nlattice,platticeN,nlatticeN,dx,dy,pdr,pgen,panh,tempr)
            plattice = platticeN
            nlattice = nlatticeN
        end

    platticeHist = zeros(Bool, (dx,dy,dt))
    platticeHist[:,:,1] = plattice
    nlatticeHist = zeros(Bool, (dx,dy,dt))
    nlatticeHist[:,:,1] = nlattice
    return platticeHist, nlatticeHist
end

function genField(pLattice,nLattice,dx,dy)
    kernel = zeros(dx,dy)
    for y = 1:dy
        for x = 1:dx
            xoff = x - (dx+1)/2
            yoff = y - (dy+1)/2
            kernel[x,y] = -log(sqrt(xoff^2+yoff^2+0.001))
        end
    end
    field = imfilter(Float64.(pLattice), kernel, "circular")
    field -= imfilter(Float64.(nLattice), kernel, "circular")
    return field
end

function updateParticle(pLattice,nLattice,pLatticeN,nLatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
    # pup = pdf
    # pdown = pup + pdf
    # pdrive = pdown + pdr
    for y = 1:dy,x = 1:dx
        walkParticle(pLattice,nLattice,pLatticeN,nLatticeN,x,y,pup,pdown,pdrive)
        annhilateParticle(pLatticeN,nLatticeN,x,y,panh)
        genParticle(pLatticeN,nLatticeN,x,y,pgen)
    end
end

function updateParticleChecker(pLattice,nLattice,pLatticeN,nLatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
    # pup = pdf
    # pdown = pup + pdf
    # pdrive = pdown + pdr
    for y = 1:dy,x = 1:dx
        walkParticleChecker(pLattice,nLattice,pLatticeN,nLatticeN,x,y,pup,pdown,pdrive)
        annhilateParticle(pLatticeN,nLatticeN,x,y,panh)
        genParticle(pLatticeN,nLatticeN,x,y,pgen)
    end
end

function updateParticleRnd(pLattice,nLattice,pLatticeN,nLatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
    walkParticleRnd(pLattice,pLatticeN,pup,pdown,pdrive,+1)
    walkParticleRnd(nLattice,nLatticeN,pup,pdown,pdrive,-1)
    for y = 1:dy,x = 1:dx
        annhilateParticle(pLatticeN,nLatticeN,x,y,panh)
        genParticle(pLatticeN,nLatticeN,x,y,pgen)
    end
end

function updateParticleRndField(pLattice,nLattice,pLatticeN,nLatticeN,dx,dy,pdrive,pgen,panh,tempr)
    field = genField(pLattice,nLattice,dx,dy)
    walkParticleRndField(pLattice,pLatticeN,field,pdrive,+1,tempr)
    walkParticleRndField(nLattice,nLatticeN,field,pdrive,-1,tempr)
    for y = 1:dy,x = 1:dx
        annhilateParticle(pLatticeN,nLatticeN,x,y,panh)
        genParticle(pLatticeN,nLatticeN,x,y,pgen)
    end
end

function updateParticleRndField(pLattice,nLattice,pLatticeN,nLatticeN,current,dx,dy,pdrive,pgen,panh,tempr)
    field = genField(pLattice,nLattice,dx,dy)
    walkParticleRndField(pLattice,pLatticeN,field,current,pdrive,+1,tempr)
    walkParticleRndField(nLattice,nLatticeN,field,current,pdrive,-1,tempr)
    for y = 1:dy,x = 1:dx
        annhilateParticle(pLatticeN,nLatticeN,x,y,panh)
        genParticle(pLatticeN,nLatticeN,x,y,pgen)
    end
end

function updateParticleRndChecker(pLattice,nLattice,pLatticeN,nLatticeN,dx,dy,pup,pdown,pdrive,pgen,panh)
    walkParticleRndChecker(pLattice,pLatticeN,pup,pdown,pdrive,+1)
    walkParticleRndChecker(nLattice,nLatticeN,pup,pdown,pdrive,-1)
    for y = 1:dy,x = 1:dx
        annhilateParticle(pLatticeN,nLatticeN,x,y,panh)
        genParticle(pLatticeN,nLatticeN,x,y,pgen)
    end
end

function walkParticleChecker(pLattice,nLattice,pLatticeN,nLatticeN,x,y,pup,pdown,pdrive)
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
    # if pLattice[x,y]
    #     rnd = rand()
    #     if rnd < 1/8 + pdrive && !pLatticeN[x,mod1(y+1,end)]# && !pLattice[x,mod1(y+1,end)]
    #         pLatticeN[x,mod1(y+1,end)] = true
    #     elseif rnd < 2/8 && !pLatticeN[x,mod1(y-1,end)]# && !pLattice[x,mod1(y-1,end)]
    #         pLatticeN[x,mod1(y-1,end)] = true
    #     elseif rnd < 3/8 && !pLatticeN[mod1(x-1,end),y]# && !pLattice[mod1(x-1,end),y]
    #         pLatticeN[mod1(x-1,end),y] = true
    #     elseif rnd < 4/8 && !pLatticeN[mod1(x+1,end),y]# && !pLattice[mod1(x+1,end),y]
    #         pLatticeN[mod1(x+1,end),y] = true
    #     elseif rnd < 5/8 - pdrive && !pLatticeN[mod1(x-1,end),mod1(y-1,end)]# && !pLattice[x,mod1(y-1,end)]
    #         pLatticeN[mod1(x-1,end),mod1(y-1,end)] = true
    #     elseif rnd < 6/8 && !pLatticeN[mod1(x-1,end),mod1(y+1,end)]# && !pLattice[x,mod1(y-1,end)]
    #         pLatticeN[mod1(x-1,end),mod1(y+1,end)] = true
    #     elseif rnd < 7/8 - pdrive && !pLatticeN[mod1(x+1,end),mod1(y-1,end)]# && !pLattice[x,mod1(y-1,end)]
    #         pLatticeN[mod1(x+1,end),mod1(y-1,end)] = true
    #     elseif rnd < 8/8 && !pLatticeN[mod1(x+1,end),mod1(y+1,end)]# && !pLattice[x,mod1(y-1,end)]
    #         pLatticeN[mod1(x+1,end),mod1(y+1,end)] = true
    #     else
    #         pLatticeN[x,y] = true
    #     end
    # end
    # if nLattice[x,y]
    #     rnd = rand()
    #     if rnd < 1/8 - pdrive && !nLatticeN[x,mod1(y+1,end)]# && !nLattice[x,mod1(y+1,end)]
    #         nLatticeN[x,mod1(y+1,end)] = true
    #     elseif rnd < 2/8 && !nLatticeN[x,mod1(y-1,end)]# && !nLattice[x,mod1(y-1,end)]
    #         nLatticeN[x,mod1(y-1,end)] = true
    #     elseif rnd < 3/8 && !nLatticeN[mod1(x-1,end),y]# && !nLattice[mod1(x-1,end),y]
    #         nLatticeN[mod1(x-1,end),y] = true
    #     elseif rnd < 4/8 && !nLatticeN[mod1(x+1,end),y]# && !nLattice[mod1(x+1,end),y]
    #         nLatticeN[mod1(x+1,end),y] = true
    #     elseif rnd < 5/8 + pdrive && !nLatticeN[mod1(x-1,end),mod1(y-1,end)]# && !nLattice[x,mod1(y-1,end)]
    #         nLatticeN[mod1(x-1,end),mod1(y-1,end)] = true
    #     elseif rnd < 6/8 && !nLatticeN[mod1(x-1,end),mod1(y+1,end)]# && !nLattice[x,mod1(y-1,end)]
    #         nLatticeN[mod1(x-1,end),mod1(y+1,end)] = true
    #     elseif rnd < 7/8 + pdrive && !nLatticeN[mod1(x+1,end),mod1(y-1,end)]# && !nLattice[x,mod1(y-1,end)]
    #         nLatticeN[mod1(x+1,end),mod1(y-1,end)] = true
    #     elseif rnd < 8/8 && !nLatticeN[mod1(x+1,end),mod1(y+1,end)]# && !nLattice[x,mod1(y-1,end)]
    #         nLatticeN[mod1(x+1,end),mod1(y+1,end)] = true
    #     else
    #         nLatticeN[x,y] = true
    #     end
    # end
end

function walkParticle(pLattice,nLattice,pLatticeN,nLatticeN,x,y,pup,pdown,pdrive)
    # if pLattice[x,y]
    #     rnd = rand()
    #     if rnd < pup && !pLatticeN[x,mod1(y+1,end)]# && !pLattice[x,mod1(y+1,end)]
    #         pLatticeN[x,mod1(y+1,end)] = true
    #     elseif rnd < pdown && !pLatticeN[x,mod1(y-1,end)]# && !pLattice[x,mod1(y-1,end)]
    #         pLatticeN[x,mod1(y-1,end)] = true
    #     elseif rnd < pdrive && !pLatticeN[mod1(x-1,end),y]# && !pLattice[mod1(x-1,end),y]
    #         pLatticeN[mod1(x-1,end),y] = true
    #     elseif !pLatticeN[mod1(x+1,end),y]# && !pLattice[mod1(x+1,end),y]
    #         pLatticeN[mod1(x+1,end),y] = true
    #     else
    #         pLatticeN[x,y] = true
    #     end
    # end
    # if nLattice[x,y]
    #     rnd = rand()
    #     if rnd < pup && !nLatticeN[x,mod1(y+1,end)]# && !nLattice[x,mod1(y+1,end)]
    #         nLatticeN[x,mod1(y+1,end)] = true
    #     elseif rnd < pdown && !nLatticeN[x,mod1(y-1,end)]# && !nLattice[x,mod1(y-1,end)]
    #         nLatticeN[x,mod1(y-1,end)] = true
    #     elseif rnd < pdrive && !nLatticeN[mod1(x+1,end),y]# && !nLattice[mod1(x+1,end),y]
    #         nLatticeN[mod1(x+1,end),y] = true
    #     elseif !nLatticeN[mod1(x-1,end),y]# && !nLattice[mod1(x-1,end),y]
    #         nLatticeN[mod1(x-1,end),y] = true
    #     else
    #         nLatticeN[x,y] = true
    #     end
    # end
    if pLattice[x,y]
        rnd = rand()
        if rnd < 1/8 + pdrive && !pLatticeN[x,mod1(y+1,end)]# && !pLattice[x,mod1(y+1,end)]
            pLatticeN[x,mod1(y+1,end)] = true
        elseif rnd < 2/8 && !pLatticeN[x,mod1(y-1,end)]# && !pLattice[x,mod1(y-1,end)]
            pLatticeN[x,mod1(y-1,end)] = true
        elseif rnd < 3/8 && !pLatticeN[mod1(x-1,end),y]# && !pLattice[mod1(x-1,end),y]
            pLatticeN[mod1(x-1,end),y] = true
        elseif rnd < 4/8 && !pLatticeN[mod1(x+1,end),y]# && !pLattice[mod1(x+1,end),y]
            pLatticeN[mod1(x+1,end),y] = true
        elseif rnd < 5/8 - pdrive && !pLatticeN[mod1(x-1,end),mod1(y-1,end)]# && !pLattice[x,mod1(y-1,end)]
            pLatticeN[mod1(x-1,end),mod1(y-1,end)] = true
        elseif rnd < 6/8 && !pLatticeN[mod1(x-1,end),mod1(y+1,end)]# && !pLattice[x,mod1(y-1,end)]
            pLatticeN[mod1(x-1,end),mod1(y+1,end)] = true
        elseif rnd < 7/8 - pdrive && !pLatticeN[mod1(x+1,end),mod1(y-1,end)]# && !pLattice[x,mod1(y-1,end)]
            pLatticeN[mod1(x+1,end),mod1(y-1,end)] = true
        elseif rnd < 8/8 && !pLatticeN[mod1(x+1,end),mod1(y+1,end)]# && !pLattice[x,mod1(y-1,end)]
            pLatticeN[mod1(x+1,end),mod1(y+1,end)] = true
        else
            pLatticeN[x,y] = true
        end
    end
    if nLattice[x,y]
        rnd = rand()
        if rnd < 1/8 - pdrive && !nLatticeN[x,mod1(y+1,end)]# && !nLattice[x,mod1(y+1,end)]
            nLatticeN[x,mod1(y+1,end)] = true
        elseif rnd < 2/8 && !nLatticeN[x,mod1(y-1,end)]# && !nLattice[x,mod1(y-1,end)]
            nLatticeN[x,mod1(y-1,end)] = true
        elseif rnd < 3/8 && !nLatticeN[mod1(x-1,end),y]# && !nLattice[mod1(x-1,end),y]
            nLatticeN[mod1(x-1,end),y] = true
        elseif rnd < 4/8 && !nLatticeN[mod1(x+1,end),y]# && !nLattice[mod1(x+1,end),y]
            nLatticeN[mod1(x+1,end),y] = true
        elseif rnd < 5/8 + pdrive && !nLatticeN[mod1(x-1,end),mod1(y-1,end)]# && !nLattice[x,mod1(y-1,end)]
            nLatticeN[mod1(x-1,end),mod1(y-1,end)] = true
        elseif rnd < 6/8 && !nLatticeN[mod1(x-1,end),mod1(y+1,end)]# && !nLattice[x,mod1(y-1,end)]
            nLatticeN[mod1(x-1,end),mod1(y+1,end)] = true
        elseif rnd < 7/8 + pdrive && !nLatticeN[mod1(x+1,end),mod1(y-1,end)]# && !nLattice[x,mod1(y-1,end)]
            nLatticeN[mod1(x+1,end),mod1(y-1,end)] = true
        elseif rnd < 8/8 && !nLatticeN[mod1(x+1,end),mod1(y+1,end)]# && !nLattice[x,mod1(y-1,end)]
            nLatticeN[mod1(x+1,end),mod1(y+1,end)] = true
        else
            nLatticeN[x,y] = true
        end
    end
end

function walkParticleRnd(Lattice,LatticeN,pup,pdown,pdrive,sign)
    # row, col, val = findnz(Lattice)
    # perm_idx = collect(1:length(row))
    # row = row[perm_idx]
    # col = col[perm_idx]
    indices = findall(!iszero, Lattice)
    shuffle!(indices)

    LatticeN[indices] .= true
    for index in indices
        x = index[1]
        y = index[2]
        rnd = rand()
        if rnd < 1/8 + (sign*pdrive) && !LatticeN[x,mod1(y+1,end)]# && !Lattice[x,mod1(y+1,end)]
            LatticeN[x,y] = false
            LatticeN[x,mod1(y+1,end)] = true
        elseif rnd < 2/8 && !LatticeN[x,mod1(y-1,end)]# && !Lattice[x,`mod1(y-1,end)]
            LatticeN[x,y] = false
            LatticeN[x,mod1(y-1,end)] = true
        elseif rnd < 3/8 && !LatticeN[mod1(x-1,end),y]# && !Lattice[mod1(x-1,end),y]
            LatticeN[x,y] = false
            LatticeN[mod1(x-1,end),y] = true
        elseif rnd < 4/8 && !LatticeN[mod1(x+1,end),y]# && !Lattice[mod1(x+1,end),y]
            LatticeN[x,y] = false
            LatticeN[mod1(x+1,end),y] = true
        elseif rnd < 5/8 - (sign*pdrive) && !LatticeN[mod1(x-1,end),mod1(y-1,end)]# && !Lattice[x,mod1(y-1,end)]
            LatticeN[x,y] = false
            LatticeN[mod1(x-1,end),mod1(y-1,end)] = true
        elseif rnd < 6/8 && !LatticeN[mod1(x-1,end),mod1(y+1,end)]# && !Lattice[x,mod1(y-1,end)]
            LatticeN[x,y] = false
            LatticeN[mod1(x-1,end),mod1(y+1,end)] = true
        elseif rnd < 7/8 - (sign*pdrive) && !LatticeN[mod1(x+1,end),mod1(y-1,end)]# && !Lattice[x,mod1(y-1,end)]
            LatticeN[x,y] = false
            LatticeN[mod1(x+1,end),mod1(y-1,end)] = true
        elseif rnd < 8/8 && !LatticeN[mod1(x+1,end),mod1(y+1,end)]# && !Lattice[x,mod1(y-1,end)]
            LatticeN[x,y] = false
            LatticeN[mod1(x+1,end),mod1(y+1,end)] = true
        else
            LatticeN[x,y] = true
        end
    end
    # return LatticeN
end

function walkParticleRndField(Lattice,LatticeN,field,pdrive,sign,tempr)
    # row, col, val = findnz(Lattice)
    # perm_idx = collect(1:length(row))
    # row = row[perm_idx]
    # col = col[perm_idx]
    indices = findall(!iszero, Lattice)
    shuffle!(indices)

    LatticeN[indices] .= true
    for index in indices
        x = index[1]
        y = index[2]

        weight_1 = exp(-sign*field[x,mod1(y+1,end)]/tempr)
        weight_2 = weight_1 + exp(-sign*field[x,mod1(y-1,end)]/tempr)
        weight_3 = weight_2 + exp(-sign*field[mod1(x-1,end),y]/tempr)
        weight_4 = weight_3 + exp(-sign*field[mod1(x+1,end),y]/tempr)
        weight_5 = weight_4 + exp(-sign*field[mod1(x-1,end),mod1(y-1,end)]/tempr)
        weight_6 = weight_5 + exp(-sign*field[mod1(x-1,end),mod1(y+1,end)]/tempr)
        weight_7 = weight_6 + exp(-sign*field[mod1(x+1,end),mod1(y-1,end)]/tempr)
        weight_8 = weight_7 + exp(-sign*field[mod1(x+1,end),mod1(y+1,end)]/tempr)
        # weight_sum = ( 
        #     exp(field[x,mod1(y+1,end)]/tempr) + exp(field[x,mod1(y-1,end)]/tempr)
        #     + exp(field[mod1(x-1,end),y]/tempr) + exp(field[mod1(x+1,end),y]/tempr)
        #     + exp(field[mod1(x-1,end),mod1(y-1,end)]/tempr)
        #     + exp(field[mod1(x-1,end),mod1(y+1,end)]/tempr)
        #     + exp(field[mod1(x+1,end),mod1(y-1,end)]/tempr)
        #     + exp(field[mod1(x+1,end),mod1(y+1,end)]/tempr)
        # )
        rnd_dr = rand()
        if rnd_dr < pdrive && !LatticeN[x,mod1(y+sign,end)]
            LatticeN[x,y] = false
            LatticeN[x,mod1(y+sign,end)] = true
        else
            rnd = rand()
            if rnd < weight_1/weight_8 && !LatticeN[x,mod1(y+1,end)]
                LatticeN[x,y] = false
                LatticeN[x,mod1(y+1,end)] = true
            elseif rnd < weight_2/weight_8 && !LatticeN[x,mod1(y-1,end)]
                LatticeN[x,y] = false
                LatticeN[x,mod1(y-1,end)] = true
            elseif rnd < weight_3/weight_8 && !LatticeN[mod1(x-1,end),y]
                LatticeN[x,y] = false
                LatticeN[mod1(x-1,end),y] = true
            elseif rnd < weight_4/weight_8 && !LatticeN[mod1(x+1,end),y]
                LatticeN[x,y] = false
                LatticeN[mod1(x+1,end),y] = true
            elseif rnd < weight_5/weight_8 && !LatticeN[mod1(x-1,end),mod1(y-1,end)]
                LatticeN[x,y] = false
                LatticeN[mod1(x-1,end),mod1(y-1,end)] = true
            elseif rnd < weight_6/weight_8 && !LatticeN[mod1(x-1,end),mod1(y+1,end)]
                LatticeN[x,y] = false
                LatticeN[mod1(x-1,end),mod1(y+1,end)] = true
            elseif rnd < weight_7/weight_8 && !LatticeN[mod1(x+1,end),mod1(y-1,end)]
                LatticeN[x,y] = false
                LatticeN[mod1(x+1,end),mod1(y-1,end)] = true
            elseif !LatticeN[mod1(x+1,end),mod1(y+1,end)]
                LatticeN[x,y] = false
                LatticeN[mod1(x+1,end),mod1(y+1,end)] = true
            else
                LatticeN[x,y] = true
            end
        end
    end
end

function walkParticleRndField(Lattice,LatticeN,field,current,pdrive,sign,tempr)
    indices = findall(!iszero, Lattice)
    shuffle!(indices)

    LatticeN[indices] .= true
    for index in indices
        x = index[1]
        y = index[2]

        weight_1 = exp(-sign*field[x,mod1(y+1,end)]/tempr)
        weight_2 = weight_1 + exp(-sign*field[x,mod1(y-1,end)]/tempr)
        weight_3 = weight_2 + exp(-sign*field[mod1(x-1,end),y]/tempr)
        weight_4 = weight_3 + exp(-sign*field[mod1(x+1,end),y]/tempr)
        weight_5 = weight_4 + exp(-sign*field[mod1(x-1,end),mod1(y-1,end)]/tempr)
        weight_6 = weight_5 + exp(-sign*field[mod1(x-1,end),mod1(y+1,end)]/tempr)
        weight_7 = weight_6 + exp(-sign*field[mod1(x+1,end),mod1(y-1,end)]/tempr)
        weight_8 = weight_7 + exp(-sign*field[mod1(x+1,end),mod1(y+1,end)]/tempr)
        rnd_dr = rand()
        if rnd_dr < pdrive && !LatticeN[x,mod1(y+sign,end)]
            LatticeN[x,y] = false
            LatticeN[x,mod1(y+sign,end)] = true
            current[x,y] += 1
        else
            rnd = rand()
            if rnd < weight_1/weight_8 && !LatticeN[x,mod1(y+1,end)]
                LatticeN[x,y] = false
                LatticeN[x,mod1(y+1,end)] = true
                current[x,y] += sign
            elseif rnd < weight_2/weight_8 && !LatticeN[x,mod1(y-1,end)]
                LatticeN[x,y] = false
                LatticeN[x,mod1(y-1,end)] = true
                current[x,y] -= sign
            elseif rnd < weight_3/weight_8 && !LatticeN[mod1(x-1,end),y]
                LatticeN[x,y] = false
                LatticeN[mod1(x-1,end),y] = true
            elseif rnd < weight_4/weight_8 && !LatticeN[mod1(x+1,end),y]
                LatticeN[x,y] = false
                LatticeN[mod1(x+1,end),y] = true
            elseif rnd < weight_5/weight_8 && !LatticeN[mod1(x-1,end),mod1(y-1,end)]
                LatticeN[x,y] = false
                LatticeN[mod1(x-1,end),mod1(y-1,end)] = true
                current[x,y] -= sign
            elseif rnd < weight_6/weight_8 && !LatticeN[mod1(x-1,end),mod1(y+1,end)]
                LatticeN[x,y] = false
                LatticeN[mod1(x-1,end),mod1(y+1,end)] = true
                current[x,y] += sign
            elseif rnd < weight_7/weight_8 && !LatticeN[mod1(x+1,end),mod1(y-1,end)]
                LatticeN[x,y] = false
                LatticeN[mod1(x+1,end),mod1(y-1,end)] = true
                current[x,y] -= sign
            elseif !LatticeN[mod1(x+1,end),mod1(y+1,end)]
                LatticeN[x,y] = false
                LatticeN[mod1(x+1,end),mod1(y+1,end)] = true
                current[x,y] += sign
            else
                LatticeN[x,y] = true
            end
        end
    end
end

function walkParticleRndChecker(Lattice,LatticeN,pup,pdown,pdrive,sign)
    # row, col, val = findnz(Lattice)
    # perm_idx = collect(1:length(row))
    # row = row[perm_idx]
    # col = col[perm_idx]
    indices = findall(!iszero, Lattice)
    shuffle!(indices)

    LatticeN[indices] .= true
    for index in indices
        x = index[1]
        y = index[2]
        rnd = rand()
        if rnd < pup && !LatticeN[x,mod1(y+1,end)]
            LatticeN[x,y] = false
            LatticeN[x,mod1(y+1,end)] = true
        elseif rnd < pdown && !LatticeN[x,mod1(y-1,end)]
            LatticeN[x,y] = false
            LatticeN[x,mod1(y-1,end)] = true
        elseif rnd < pdrive && !LatticeN[mod1(x-sign*1,end),y]
            LatticeN[x,y] = false
            LatticeN[mod1(x-sign*1,end),y] = true
        elseif !LatticeN[mod1(x+sign*1,end),y]
            LatticeN[x,y] = false
            LatticeN[mod1(x+sign*1,end),y] = true
        end
    end
    # return LatticeN
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

function updateCurrent(current,plattice,nlattice,platticeN,nlatticeN,dx,dy)
    for y = 1:dy
        for x = 1:dx 
            if (platticeN[x,mod1(y+1,end)] && !platticeN[x,y] & !plattice[x,mod1(y+1,end)] && plattice[x,y])
                current[x,y] += 1
            elseif (!platticeN[x,mod1(y+1,end)] && platticeN[x,y] & plattice[x,mod1(y+1,end)] && !plattice[x,y])
                current[x,y] -= 1
            end
            if (nlatticeN[x,mod1(y+1,end)] && !nlatticeN[x,y] & !nlattice[x,mod1(y+1,end)] && nlattice[x,y])
                current[x,y] -= 1
            elseif (!nlatticeN[x,mod1(y+1,end)] && nlatticeN[x,y] & nlattice[x,mod1(y+1,end)] && !nlattice[x,y])
                current[x,y] += 1
            end
        end
    end
end