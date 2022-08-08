struct KEGGModule
    Entry::Dict{String,String}
    Name::String
    Definition::Vector{String}
    Orthology::Dict{String,Vector{String}}
    Class::Vector{String}
    Pathway::Dict{String,String}
    Reaction::Dict{String,String}
    Compound::Dict{String,String}
    EC::Vector{String}
end
