function calcVortices(numt,dx,dy,latticeHist,PBC=true)
    vorticeHist=zeros(Int64,numt,dx,dy)
    if PBC
        for y=1:dy,x=1:dx,t=1:numt
            winding = (
                rem2pi(latticeHist[t,mod1(x+1,end),y]-latticeHist[t,x,y],RoundNearest)
                +rem2pi(latticeHist[t,mod1(x+1,end),mod1(y+1,end)]-latticeHist[t,mod1(x+1,end),y],RoundNearest)
                +rem2pi(latticeHist[t,x,mod1(y+1,end)]-latticeHist[t,mod1(x+1,end),mod1(y+1,end)],RoundNearest)
                +rem2pi(latticeHist[t,x,y]-latticeHist[t,x,mod1(y+1,end)],RoundNearest)
            )
            vorticeHist[t,x,y]=round(winding/2/pi)
        end 
    end
    return vorticeHist
end

function findCorrelationFFT(latticeHist)
    latticeFFT = fft(latticeHist)
    return ifft(abs.(latticeFFT).^2)
    # return ifft(abs.(latticeFFT).^2) - latticeHist.^2
    # return latticeHist
end

function findCorrelation(latticeHist,numt,dx,dy,trunc=0)
    corr=zeros(ComplexF64,dx,dy,numt-trunc)
    for y=1:dx, dely=0:dx-1, x=1:dx, delx=0:dy-1
        for delt=0:numt-trunc-1
            cnt = 0
            for t=trunc+1:numt
                if t+delt > numt 
                    continue
                else
                    cnt = cnt + 1
                    corr[delx+1,dely+1,delt+1] += (
                        latticeHist[x,y,t]
                        *latticeHist[mod1(x+delx,end),mod1(y+dely,end),t+delt]
                    )
                end
            end
            corr[delx+1,dely+1,delt+1] = corr[delx+1,dely+1,delt+1]/cnt/dx/dy
        end
    end
    return corr
end

function findVorticeCorrelation(numt,dx,dy,vorticeHist,trunc=10,PBC=true)
    corr=zeros(ComplexF64,numt-trunc,dx,dy)
    if PBC
        for y=1:dx, dely=0:dy-1, x=1:dx, delx=0:dx-1
            for delt=0:numt-trunc-1
                cnt = 0
                for t=trunc+1:numt
                    if t+delt > numt 
                        continue
                    else
                        cnt = cnt + 1
                        corr[delt+1,delx+1,dely+1]=(
                            corr[delt+1,delx+1,dely+1]+
                            vorticeHist[t,x,y]*vorticeHist[t+delt,mod1(x+delx,end),mod1(y+dely,end)]
                        )
                    end
                end
                corr[delt+1,delx+1,dely+1] = corr[delt+1,delx+1,dely+1]/cnt/dx/dy
            end
        end
    end
    return corr
end

function save3DData(scanx_l,scany_l,scanz_l,data,file_name)
    df_scanx = DataFrame()
    df_scany = DataFrame()
    df_scanz = DataFrame()
    df_data = DataFrame()
    df_scanx.scanx_l = scanx_l
    df_scany.scany_l = scany_l
    df_scanz.scany_l = scanz_l
    df_data.data = collect(Iterators.flatten(data))

    CSV.write(file_name*"_scanx.csv", df_scanx)
    CSV.write(file_name*"_scany.csv", df_scany)
    CSV.write(file_name*"_scanz.csv", df_scanz)
    CSV.write(file_name*"_data.csv", df_data)
end

function save4DData(scanw_l,scanx_l,scany_l,scanz_l,data,file_name)
    df_scanw = DataFrame()
    df_scanx = DataFrame()
    df_scany = DataFrame()
    df_scanz = DataFrame()
    df_data = DataFrame()
    df_scanw.scanx_l = scanw_l
    df_scanx.scanx_l = scanx_l
    df_scany.scany_l = scany_l
    df_scanz.scany_l = scanz_l
    df_data.data = collect(Iterators.flatten(data))

    CSV.write(file_name*"_scanw.csv", df_scanw)
    CSV.write(file_name*"_scanx.csv", df_scanx)
    CSV.write(file_name*"_scany.csv", df_scany)
    CSV.write(file_name*"_scanz.csv", df_scanz)
    CSV.write(file_name*"_data.csv", df_data)
end

function saveComplex3DData(scanx_l,scany_l,scanz_l,data,file_name)
    df_scanx = DataFrame()
    df_scany = DataFrame()
    df_scanz = DataFrame()
    df_data = DataFrame()
    df_scanx.scanx_l = scanx_l
    df_scany.scany_l = scany_l
    df_scanz.scany_l = scanz_l
    df_data.real = collect(Iterators.flatten(real(data)))
    df_data.imag = collect(Iterators.flatten(imag(data)))

    CSV.write(file_name*"_scanx.csv", df_scanx)
    CSV.write(file_name*"_scany.csv", df_scany)
    CSV.write(file_name*"_scanz.csv", df_scanz)
    CSV.write(file_name*"_data.csv", df_data)
end