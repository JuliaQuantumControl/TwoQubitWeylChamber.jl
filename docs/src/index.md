```@meta
CurrentModule = TwoQubitWeylChamber
```

# TwoQubitWeylChamber

```@eval
using Markdown
using Pkg

VERSION = Pkg.dependencies()[Base.UUID("cad078a0-0012-46f4-b55e-a945d44e115b")].version

github_badge = "[![Github](https://img.shields.io/badge/JuliaQuantumControl-TwoQubitWeylChamber.jl-blue.svg?logo=github)](https://github.com/JuliaQuantumControl/TwoQubitWeylChamber.jl)"

version_badge = "![v$VERSION](https://img.shields.io/badge/version-v$VERSION-green.svg)"

Markdown.parse("$github_badge $version_badge")
```

[TwoQubitWeylChamber](https://github.com/JuliaQuantumControl/TwoQubitWeylChamber.jl) is a Julia package for analyzing two-qubit gates in the Weyl chamber.  It is a partial port of the [Python `weylchamber` package](https://github.com/qucontrol/weylchamber).

The methods provided here allow to do an optimization for the entangling power of a two-qubit gate within the [QuantumControl](https://github.com/JuliaQuantumControl/QuantumControl.jl#readme) framework. See the examples for the optimization of a perfect entangler with the [Krotov](https://juliaquantumcontrol.github.io/Krotov.jl/stable/examples/perfect_entanglers/#Example-4:-Optimization-for-a-perfect-entangler) and [GRAPE](https://juliaquantumcontrol.github.io/GRAPE.jl/stable/examples/perfect_entanglers/#Optimizing-for-a-general-perfect-entangler) methods.

## API

```@index
```

``\gdef\tr{\operatorname{tr}}``
``\gdef\Re{\operatorname{Re}}``

```@autodocs
Modules = [TwoQubitWeylChamber]
```

## References

```@bibliography
```
