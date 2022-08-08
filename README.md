# KEGGModuleParser.jl
This is a simple package to get KEGG module information. 

You can list all KEGG modules:
```julia
list_KEGG_module_names()
```

And look at the module's associated EC numbers:
```julia
get_module_ECs("md:M00035") # KEGG module id md:M00035
```

As well as getting all of the module information
```julia
get_module_info("M00035") #KEGG module id M00035
```

Note that both of the previous functions work regardless of whether the id is prefixed by `md:`.

