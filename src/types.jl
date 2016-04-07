
# type of size
typealias Tsz Tuple{Integer}

# type of coordinate
# since we do a lot of coordinate computation using Float, to facilitate type transformation, just use float as the data type
typealias Tcoord Vector{Float32}

# type of segmentation
typealias Tseg Array{UInt32,3}

# type of affinity map
typealias Taffs Array{Float32,4}
