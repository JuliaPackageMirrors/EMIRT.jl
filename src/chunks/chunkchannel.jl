#doc"""
#chunk channel is for maintaining a channel to deliver chu#nks
#"""
import Base: put!, wait, isready, take!, fetch

# type of chunk
type Tchk
    # chunk volume
    chk::Array
    # coordinate of chunk origin
    crdt = Vector{Integer}
    Tchk( tp::DataType, sz::Tuple, crdt::Vector{Integer}=[0,0,0] ) = new( Array{tp,sz}([]), crdt )
end

type ChunkChannel <: AbstractChannel
    # maximum number of chunks
    maxnum::UInt32
    # list of chunks
    lc::Vector{Tchk}
    cond_take::Condition
    # type and size
    ChunkChannel(maxnum::UInt32, tp::DataType, sz::Tuple, crdt::Vector{Integer}) = new(maxnum, Vector{Tchk}([]), Condition())
end

function put!(C::ChunkChannel, chk::Tchk)
    waitposition(C)
    push!(C.lc, chk)
    notify(C.cond_take)
    return C
end

isfull(C::ChunkChannel) = length(C.lc)>=C.maxnum

"""
wait for a position to put in the channel
"""
function waitposition(C::ChunkChannel)
    while !isfull(C)
        wait(C.cond_take)
    end
end

function take!(C::ChunkChannel)
    wait(C)
    pop!(C.lc)
end

isready(C::ChunkChannel) = length(C.lc)>1
isready(C::ChunkChannel, k) = length(C.lc)>=k

function fetch(C::ChunkChannel)
    wait(C)
    C.lc[end]
end

function wait(C::ChunkChannel)
    while !isready(C)
        wait(C.cond_take)
    end
end
