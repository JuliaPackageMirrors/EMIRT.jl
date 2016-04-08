export Tchk

# type of size
typealias Tsz Tuple{Integer}

# type of coordinate
# since we do a lot of coordinate computation using Float, to facilitate type transformation, just use float as the data type
typealias Tcrdt Vector

# type of segmentation
typealias Tseg Array{UInt32,3}

# type of affinity map
typealias Taffs Array{Float32,4}


# type of chunk
type Tchk
    # chunk volume
    arr::Array
    # coordinate of chunk origin
    crdt::Tcrdt
    Tchk( arr::Array, crdt::Tcrdt ) = new( arr, crdt )
end

function Tchk( tp::DataType, sz::Tuple, crdt::Tcrdt=[0,0,0] )
    return Tchk( Array{tp,sz}([]), crdt )
end
