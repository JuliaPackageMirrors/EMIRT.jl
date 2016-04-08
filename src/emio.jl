using HDF5
#using PyCall
#using Compose

include("types.jl")

export img2svg, imread, imsave, ecread

function imread(fname)
    print("reading file: $(fname) ......")
    if ishdf5(fname)
        ret =  h5read(fname, "/main")
        println("done :)")
        return ret
#=    elseif contains(fname, ".tif")
        @pyimport tifffile
        vol = tifffile.imread(fname)
        # transpose the dims from z,y,x to x,y,z
        vol = permutedims(vol, Array(ndims(vol):-1:1))
        println("done :)")
        return vol =#
    else
        error("invalid file type! only support hdf5 and tif now.")
    end
end

"""
read a chunk from a big hdf5 file
`Inputs:`
fname: file name of hdf5 file
start: start coordinate of chunk
stop:  stop coordinate of the chunk
path: the dataset path inside the hdf5 file

`Outputs:`
chk: the cutout chunk
"""
function imread(fname, start::Tcrdt, stop::Tcrdt, path="/main")
    @assert ishdf5(fname)
    @assert length(start) == length(stop)
    f = h5open(fname, "r")
    # the dataset
    vol = f[path]
    @assert ndims(vol)==length(start)
    # number of dimension
    nd = length(start)
    # get the chunk
    if nd==1
        chk = vol[start[1]:stop[1]]
    elseif nd==2
        chk = vol[start[1]:stop[1], start[2]:stop[2]]
    elseif nd==3
        chk = vol[start[1]:stop[1], start[2]:stop[2], start[3]:stop[3]]
    elseif nd==4
        chk = vol[start[1]:stop[1], start[2]:stop[2], start[3]:stop[3], start[4]:stop[4]]
    else
        error("unsupported volume dimension: $(nd)")
    end
    close(f)
    # return a chunk type
    return Tchk(chk, start)
end

function imsave(vol::Array, fname, is_overwrite=true)
    print("saving file: $(fname); ......")
    # remove existing file
    if isfile(fname) && is_overwrite
        rm(fname)
    end

    if contains(fname, ".h5") || contains(fname, ".hdf5")
        h5write(fname, "/main", vol)
#=    elseif contains(fname, ".tif")

        @pyimport tifffile
        tifffile.imsave(fname, vol)
        # emio.imsave(vol, fname) =#
    else
        error("invalid image format! only support hdf5 and tif now.")
    end
    println("done!")
end

#=
"""
save image as svg file

"""
function img2svg( img::Array, fname )
    # reshape to vector
    v = reshape( img, length(img))
    draw(SVG(fname, 3inch, 3inch), compose(context(), bitmap("image/png", Array{UInt8}(v), 0, 0, 1, 1)))
end
=#

"""
read the evaluation curve in a hdf5 file
`Inputs`:
fname: ASCIIString, file name which contains the evaluation curve

`Outputs`:
dec: Dict of evaluation curve
"""
function ecread(fname)
    ret = Dict{ASCIIString, Vector{Float32}}()
    f = h5open(fname)
    a = f["/processing/znn/forward/"]
    b = a[names(a)[1]]
    c = b[names(b)[1]]
    d = c["evaluate_curve"]
    for key in names(d)
        ret[key] = read(d[key])
    end
    return ret
end
