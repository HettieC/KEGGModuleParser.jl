module KEGGModuleParser

using HTTP

include("types.jl")
include("utils.jl")

export list_KEGG_module_names, get_module_ECs, get_module_info

end
