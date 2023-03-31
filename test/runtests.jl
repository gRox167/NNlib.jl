using NNlib, Test, Statistics, Random
using ChainRulesCore, ChainRulesTestUtils
using Base.Broadcast: broadcasted
import FiniteDifferences
import ForwardDiff
import Zygote
using Zygote: gradient
using StableRNGs
using Documenter
DocMeta.setdocmeta!(NNlib, :DocTestSetup, :(using NNlib, UnicodePlots); recursive=true)

const rng = StableRNG(123)
include("test_utils.jl")

@testset verbose=true "NNlib.jl" begin
    if get(ENV, "NNLIB_TEST_CUDA", "false") == "true"
        using CUDA
        if CUDA.functional()
            import Pkg
            using NNlibCUDA
            @testset "CUDA" begin
                Pkg.test("NNlibCUDA")
            end
        else
            @info "Insufficient version or CUDA not found; Skipping CUDA tests"
        end
    else
        @info "Skipping CUDA tests, set NNLIB_TEST_CUDA=true to run them"
    end

    if get(ENV, "NNLIB_TEST_AMDGPU", "false") == "true"
        # Hack to add MIOpen_jll to AMDGPU.
        import Pkg
        test_info = Pkg.project()
        Pkg.develop("AMDGPU")
        Pkg.activate(joinpath(Pkg.devdir(), "AMDGPU"))
        Pkg.add("MIOpen_jll")
        Pkg.update()
        Pkg.activate(test_info.path)
        Pkg.update()

        using AMDGPU
        AMDGPU.versioninfo()
        if AMDGPU.functional() && AMDGPU.functional(:MIOpen)
            @show AMDGPU.MIOpen.version()
            @testset "AMDGPU" begin
                include("ext_amdgpu/runtests.jl")
            end
        else
            @info "AMDGPU.jl package is not functional. Skipping AMDGPU tests."
        end
    else
        @info "Skipping AMDGPU tests, set NNLIB_TEST_CUDA=true to run them."
    end

    @testset "Doctests" begin
        doctest(NNlib, manual=false)
    end

    @testset "Activation Functions" begin
        include("activations.jl")
    end

    @testset "Attention" begin
        include("attention.jl")
    end

    @testset "Batched Multiplication" begin
        include("batchedmul.jl")
    end

    @testset "Convolution" begin
        include("conv.jl")
        include("conv_bias_act.jl")
    end

    @testset "CTC Loss" begin
        include("ctc.jl")
    end

    @testset "Dropout" begin
        include("dropout.jl")
    end

    @testset "Fold/Unfold" begin
        include("fold.jl")
    end

    @testset "Inference" begin
        include("inference.jl")
    end

    @testset "Pooling" begin
        include("pooling.jl")
    end

    @testset "Padding" begin
        include("padding.jl")
    end

    @testset "Softmax" begin
        include("softmax.jl")
    end

    @testset "Upsampling" begin
        include("upsample.jl")
    end

    @testset "Gather" begin
        include("gather.jl")
    end

    @testset "Scatter" begin
        include("scatter.jl")
    end

    @testset "Utilities" begin
        include("utils.jl")
    end

    @testset "Grid Sampling" begin
        include("sampling.jl")
    end

    @testset "Functions" begin
        include("functions.jl")
    end
end
