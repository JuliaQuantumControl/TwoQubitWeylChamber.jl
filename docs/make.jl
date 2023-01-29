using TwoQubitWeylChamber
using Documenter

DocMeta.setdocmeta!(
    TwoQubitWeylChamber,
    :DocTestSetup,
    :(using TwoQubitWeylChamber);
    recursive=true
)

makedocs(;
    modules=[TwoQubitWeylChamber],
    authors="Michael Goerz <mail@michaelgoerz.net>",
    repo="https://github.com/JuliaQuantumControl/TwoQubitWeylChamber.jl/blob/{commit}{path}#{line}",
    sitename="TwoQubitWeylChamber.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaQuantumControl.github.io/TwoQubitWeylChamber.jl",
        edit_link="master",
        assets=String[]
    ),
    pages=["Home" => "index.md",]
)

deploydocs(;
    repo="github.com/JuliaQuantumControl/TwoQubitWeylChamber.jl",
    devbranch="master"
)
