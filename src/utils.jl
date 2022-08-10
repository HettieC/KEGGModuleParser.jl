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
    Entry = Dict{String,String}()
    Name = string()
    Definition = string()
    Class = String[]
    orth = Dict{String,Vector{String}}()
    Pathway = Dict{String,String}()
    Reaction = Dict{String,String}()
    Compound = Dict{String,String}()
    ECs = get_module_ECs(id)
    for ln in lines
        if ln == ""
            return KEGGModule(Entry,Name,Definition,orth,Class,Pathway,Reaction,Compound,ECs)
        else
            data = split(ln) 
            if data[1] == "ENTRY"
                Entry[data[2]] = string(data[3]," ")*data[4]
            elseif data[1] == "NAME"
                Name = strip(split(ln,limit=2)[2])
            elseif data[1] == "DEFINITION"
                Definition = [String(x) for x in data[2:end]]
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
                Class = String[]
                temp_class = split(ln,";")
                push!(Class,strip(split(temp_class[1],limit=2)[2]))
                for x in temp_class[2:end]
                    push!(Class,strip(x))
                end
            elseif data[1] == "PATHWAY"
                pway = split(ln,limit=3)
                Pathway[pway[2]]=strip(pway[3])
            elseif data[1] ∉ headers && startswith(data[1],"map")
                pway = split(ln,limit=2)
                Pathway[pway[1]] = strip(pway[2])
            elseif data[1] == "REACTION"
                rxn = split(ln,limit=3)
                Reaction[rxn[2]] = strip(rxn[3])
            elseif data[1] ∉ headers && startswith(data[1],"R")
                Reaction[split(ln,limit=2)[1]] = strip(split(ln,limit=2)[2])
            elseif data[1] == "COMPOUND"
                cmpnd = split(ln,limit=3)
                Compound[cmpnd[2]] = strip(cmpnd[3])
            elseif data[1] ∉ headers && startswith(data[1],"C")
                cmpnd = split(ln,limit=2)
                Compound[cmpnd[1]] = strip(cmpnd[2])
            end
        end
    end
end

"""
get_reaction_name(id::String)

Get the reaction info from its KEGG id.
"""
function get_reaction_info(rxn_id::String)
    req = nothing
    try 
        req = HTTP.request("GET","https://rest.kegg.jp/get/$rxn_id")
    catch 
        req = nothing
        print("No reaction matching this ID: $rxn_id ")
    end
    lines = split(String(req.body),"\n")
    headers = ["ENTRY","NAME","DEFINITION","EQUATION","COMMENT","RCLASS","ENZYME",
        "PATHWAY","ORTHOLOGY","DBLINKS","REFERENCE","AUTHORS","TITLE","JOURNAL"]
    Name = String[]
    Def = string()
    Eqn = string()
    ec = Vector{String}()
    DBlinks = String[]
    for ln in lines
        if ln == "" 
            return KEGGReaction(rxn_id,Name,Def,Eqn,ec,DBlinks)
        else
            data = split(ln)
            if data[1] == "ENTRY" && "Reaction" ∉ data
                println("$rxn_id does not correspond to a reaction.")
            elseif data[1] == "NAME"
                push!(Name,strip(split(ln,limit=2)[2]))
            elseif data[1] == "DEFINITION"
                Def = strip(split(ln,limit=2)[2])
            elseif data[1] == "EQUATION"
                Eqn = strip(split(ln,limit=2)[2])
            elseif data[1] == "ENZYME"
                push!(ec,data[2])
                if length(data)>2
                    println(data)
                end
            elseif data[1] ∉ headers
                continue
            elseif data[1] == "DBLINKS"
                DBlinks = split(strip(split(ln,limit=2)[2]),";")
            else
                println(ln)
            end
        end
    end
end


function make_pathway(mod_id::String)
    mod = get_module_info(mod_id)
    if mod.entry[mod_id] != "Pathway Module"
        return println("$mod_id is not a pathway module")
    else
        return KEGGPathwayModule(mod_id,mod.name,[r for r in keys(mod.reaction)])
    end
end