using TwoQubitWeylChamber
using Pkg
using Documenter

DocMeta.setdocmeta!(
    TwoQubitWeylChamber,
    :DocTestSetup,
    :(using TwoQubitWeylChamber);
    recursive=true
)

PROJECT_TOML = Pkg.TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
VERSION = PROJECT_TOML["version"]
NAME = PROJECT_TOML["name"]
AUTHORS = join(PROJECT_TOML["authors"], ", ") * " and contributors"
GITHUB = "https://github.com/JuliaQuantumControl/TwoQubitWeylChamber.jl"

println("Starting makedocs")


makedocs(;
    authors=AUTHORS,
    sitename="TwoQubitWeylChamber.jl",
    format=Documenter.HTML(;
        prettyurls=true,
        canonical="https://JuliaQuantumControl.github.io/TwoQubitWeylChamber.jl",
        edit_link="master",
        assets=String[],
        footer="[$NAME.jl]($GITHUB) v$VERSION docs powered by [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl)."
    ),
    pages=["Home" => "index.md",]
)

println("Finished makedocs")

deploydocs(;
    repo="github.com/JuliaQuantumControl/TwoQubitWeylChamber.jl",
    devbranch="master"
)
