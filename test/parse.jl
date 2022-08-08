@testset "Methionine degradation" begin
    #=
    ENTRY       M00035            Pathway   Module
    NAME        Methionine degradation
    DEFINITION  K00789 (K00558,K17398,K17399) K01251 (K01697,K10150)
    ORTHOLOGY   K00789  S-adenosylmethionine synthetase [EC:2.5.1.6] [RN:R00177]
                K00558,K17398,K17399  DNA (cytosine-5-)-methyltransferase [EC:2.1.1.37] [RN:R04858]
                K01251  adenosylhomocysteinase [EC:3.13.2.1] [RN:R00192]
                K01697,K10150  cystathionine beta-synthase [EC:4.2.1.22] [RN:R01290]
    CLASS       Pathway modules; Amino acid metabolism; Cysteine and methionine metabolism
    PATHWAY     map00270  Cysteine and methionine metabolism
                map01100  Metabolic pathways
    REACTION    R00177  C00073 -> C00019
                R04858  C00019 -> C00021
                R00192  C00021 -> C00155
                R01290  C00065 + C00155 -> C02291
    COMPOUND    C00073  L-Methionine
                C00019  S-Adenosyl-L-methionine
                C00021  S-Adenosyl-L-homocysteine
                C00155  L-Homocysteine
                C00065  L-Serine
                C02291  L-Cystathionine
    =#
    id = "M00035"
    mod = get_module_info(id)

    @test mod.Entry == Dict("M00035" => "Pathway Module")
    @test mod.Name == "Methionine degradation"
    @test mod.Definition == ["K00789", "(K00558,K17398,K17399)", "K01251", "(K01697,K10150)"]
    @test mod.Orthology == Dict(
        "K00558,K17398,K17399" => ["[EC:2.1.1.37]", "[RN:R04858]", " DNA (cytosine-5-)-methyltransferase"],
        "K01697,K10150"        => ["[EC:4.2.1.22]", "[RN:R01290]", " cystathionine beta-synthase"],
        "K00789"               => ["[EC:2.5.1.6]", "[RN:R00177]", " S-adenosylmethionine synthetase"],
        "K01251"               => ["[EC:3.13.2.1]", "[RN:R00192]", " adenosylhomocysteinase"])
    @test mod.Class ==  ["Pathway modules",
                        "Amino acid metabolism",
                        "Cysteine and methionine metabolism"]
    @test mod.Pathway == Dict(
        "map01100" => "Metabolic pathways",
        "map00270" => "Cysteine and methionine metabolism")
    @test mod.Reaction == Dict(
        "R00177" => "C00073 -> C00019",
        "R00192" => "C00021 -> C00155",
        "R01290" => "C00065 + C00155 -> C02291",
        "R04858" => "C00019 -> C00021")
    @test mod.Compound == Dict(
        "C00073" => "L-Methionine",
        "C00021" => "S-Adenosyl-L-homocysteine",
        "C00019" => "S-Adenosyl-L-methionine",
        "C00155" => "L-Homocysteine",
        "C00065" => "L-Serine",
        "C02291" => "L-Cystathionine")
    @test mod.EC == [
        "ec:2.5.1.6",
        "ec:2.1.1.37",
        "ec:3.13.2.1",
        "ec:4.2.1.22",
        "ec:2.5.1.47",
        "ec:2.5.1.65"]
end


