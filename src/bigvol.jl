include("types.jl")

# type of big volume in disk
type Tbigvol
    # IO stream
    f::IO
    # data type
    tp::DataType
    # total volume size
    tvsz::Tsz
    # chunk size
    chksz::Tsz
    # number of chunks in each dimension
    nchk::Vector{Float32}
    # construction function
    Tbigvol(f::IO, tp::DataType=UInt32, tvsz::Tsz, chksz::Tsz, nchk::Vector{Float32}) = new(f, tp, tvsz, chksz, nchk)
end

function Tbigvol(f::IO, tp::DataType, tvsz::Tsz, chksz::Tsz)
    # transform tuple to vector
    arrtvsz = Vector{Float32}( collect(tvsz) )
    arrchksz = Vector{Float32}( collect(chksz) )
    # compute the number of chunks in each dimension
    nchk = ceil( arrtvsz ./ arrchksz )
    # construct big volume
    Tbigvol(f, tp, tvsz, chksz, nchk)
end

function Tbigvol(fname::ASCIIString, tp::DataType=UInt32, tvsz::Tsz, chksz::Tsz)
    # read write create append
    f = open(fname, "a+")
    Tbigvol(f, tp, tvsz, chksz)
end


import Base.read
function read(bv::Tbigvol, start::Tcoord, sz::Tsz)
    # compute the end coordinate
    stop = start + collect(sz) - 1
    # get the array
    read(bv, start, stop)
end

function read(bv::Tbigvol, start::Tcoord, stop::Tcoord)
    # chunk size in array form
    chksz = collect(bv.chksz)
    # number of voxels of each chunk
    Nvc = prod( chksz )
    # the chunk ID range start and end
    ks = floor( (start-1) ./ chksz ) + 1
    ke = ceil(  stop  ./ chksz )

    # memory allocation of a temporal chunk
    chk = Array{bv.tp}(bv.chksz)
    # read each chunk
    for kz in ks[3]:ke[3]
        for ky in ks[2]:ke[2]
            for kx in ks[1]:ke[1]
                pos = (kx-1+ (ky-1)*bv.nchk[1] + (kz-1)*bv.nchk[2]*bv.nchk[1]) * Nvc + 1
                f = seek(f, pos)
                # read chunk
                read!(f, chk)
                # get chunk global start and end coordinate of this chunk
                chkstart = (ks-1).*chksz + 1
                chkstop  = chkstart + chksz - 1
                # real global coordinate in this chunk
                rlstart = max( chkstart, start )
                rlstop  = min( chkstop,  stop  )
                # the start and stop inside chunk
                instart = rlstart - chkstart + 1
                instop  = chksz - (chkstop - rlstop)
                # the start and stop inside returned array
                rtstart = max(chkstart - rlstart, [0,0,0]) + 1




                rtstop  = min(chkstop - rlstart)
                # assign element values to the temporal volume
            end
        end
    end
end
