using HTTP

"""
list_KEGG_module_names()

Get a dictionary of kegg module ID against the given name to each module
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

"""
get_module_ECs(id::String)

Get a list of the ECs for a module from the KEGG API 'link' operation.
"""
function get_module_ECs(id::String)
    ECs = String[]
    req = HTTP.request("GET","https://rest.kegg.jp/link/ec/$id")
    lines = split(String(req.body),"\n")
    for ln in lines
        if ln == ""
            return ECs
        else
            ec = split(ln,"\t")
            push!(ECs,ec[2])
        end
    end
end

"""
get_module_info(id::String)

Parse the KEGG API 'get' operation to collect all given data for a module.
"""
function get_module_info(id::String)
    req = nothing
    try 
        req = HTTP.request("GET","https://rest.kegg.jp/get/$id")
    catch 
        req = nothing
        print("No module matching this ID: $id ")
    end
    lines = split(String(req.body),"\n")
    headers = ["ENTRY","NAME","DEFINITION","ORTHOLOGY","CLASS","PATHWAY","REACTION","COMPOUND"]
    entry = Dict{String,String}()
    name = string()
    definition = string()
    class = String[]
    orth = Dict{String,Vector{String}}()
    pathway = Dict{String,String}()
    reaction = Dict{String,String}()
    compound = Dict{String,String}()
    ECs = get_module_ECs(id)
    for ln in lines
        if ln == ""
            return KEGGModule(entry,name,definition,orth,class,pathway,reaction,compound,ECs)
        else
            data = split(ln) 
            if data[1] == "ENTRY"
                entry[data[2]] = string(data[3]," ")*data[4]
            elseif data[1] == "NAME"
                name = strip(split(ln,limit=2)[2])
            elseif data[1] == "DEFINITION"
                definition = [String(x) for x in data[2:end]]
            elseif data[1] == "ORTHOLOGY"
                orth[data[2]] = String[]
                orth_name = string()
                for x in data[3:end]
                    if !startswith(x,"[")
                        orth_name = string(orth_name," ")*x
                    else 
                        push!(orth[data[2]],x)
                    end
                end
                push!(orth[data[2]],orth_name)
            elseif data[1] ∉ headers && startswith(data[1],"K")
                orth[data[1]] = String[]
                orth_name = string()
                for x in data[2:end]
                    if !startswith(x,"[")
                        orth_name = string(orth_name," ")*x
                    else
                        push!(orth[data[1]],x)
                    end
                end
                push!(orth[data[1]],orth_name)
            elseif data[1] == "CLASS"
                class = String[]
                temp_class = split(ln,";")
                push!(class,strip(split(temp_class[1],limit=2)[2]))
                for x in temp_class[2:end]
                    push!(class,strip(x))
                end
            elseif data[1] == "PATHWAY"
                pway = split(ln,limit=3)
                pathway[pway[2]]=strip(pway[3])
            elseif data[1] ∉ headers && startswith(data[1],"map")
                pway = split(ln,limit=2)
                pathway[pway[1]] = strip(pway[2])
            elseif data[1] == "REACTION"
                rxn = split(ln,limit=3)
                reaction[rxn[2]] = strip(rxn[3])
            elseif data[1] ∉ headers && startswith(data[1],"R")
                reaction[split(ln,limit=2)[1]] = strip(split(ln,limit=2)[2])
            elseif data[1] == "COMPOUND"
                cmpnd = split(ln,limit=3)
                compound[cmpnd[2]] = strip(cmpnd[3])
            elseif data[1] ∉ headers && startswith(data[1],"C")
                cmpnd = split(ln,limit=2)
                compound[cmpnd[1]] = strip(cmpnd[2])
            end
        end
    end
end



