using HTTP

# ASK MO: !!!!!!!!!!
# is it better to do a function that takes the input as the module id or 
# better to just get ec numbers and names of all modules in one go?
# !!!!!!!!!!!

"""
function list_KEGG_module_names()
    get a dictionary of kegg module ID against the given name to each module
"""
function list_KEGG_module_names()
    get_mod_list = HTTP.request("GET", "https://rest.kegg.jp/list/module")
    KEGG_module_names = Dict{String,String}()
    lines = split(String(get_mod_list.body),"\n")
    for ln in lines[1:end-1]
        mod = split(ln,"\t")
        if length(mod) == 2
            KEGG_module_names[mod[1]]=mod[2]
        else
            println("Module $ln has no name")
        end
    end
    return KEGG_module_names
end

function list_module_ECs(moduleid::String)
KEGG_modules = Dict{String,Vector{String}}()
for m in keys(KEGG_module_names)
    x = split(m,":")
    if length(x)<2
        print(x)
    else
        md = x[2]
        get_mod_ECs = HTTP.request("GET","https://rest.kegg.jp/link/ec/$md")
        KEGG_modules[md] = String[]
        EC_lines = split(String(get_mod_ECs.body),"\n")
        for ln in EC_lines
            if ln != ""
                EC = split(ln,"\t")
                push!(KEGG_modules[md],EC[2])
            end
        end
    end
end
end
