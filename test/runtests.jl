using Test
using SafeTestsets

# Note: comment outer @testset to stop after first @safetestset failure
@time @testset verbose = true "TwoQubitWeylChamber" begin


    print("\n* Weyl Chamber (test_weyl_chamber.jl):")
    @time @safetestset "Weyl Chamber" begin
        include("test_weyl_chamber.jl")
    end

end
