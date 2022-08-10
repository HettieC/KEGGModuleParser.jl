struct KEGGModule
    entry::Dict{String,String}
    name::String
    definition::Vector{String}
    orthology::Dict{String,Vector{String}}
    class::Vector{String}
    pathway::Dict{String,String}
    reaction::Dict{String,String}
    compound::Dict{String,String}
    ec::Vector{String}
end


struct KEGGReaction
    id::String
    name::Vector{String}
    definition::String
    equation::String
    enzyme::Vector{String}
    dblinks::Vector{String}
end



struct KEGGPathwayModule
    id::String
    name::String
    reactions::Vector{String}
end

