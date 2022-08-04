module KEGGModuleParser

using HTTP

get_mod_list = HTTP.request("GET", "https://rest.kegg.jp/list/module")

KEGG_module_names = Dict{String,String}()
lines = split(String(get_mod_list.body),"\n")
for ln in lines
    mod = split(ln,"\t")
    if length(mod)<2
        KEGG_module_names[mod[1]]=""
    else
        KEGG_module_names[mod[1]]=mod[2]
    end
end

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
