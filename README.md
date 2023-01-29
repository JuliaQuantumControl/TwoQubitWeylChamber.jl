# TwoQubitWeylChamber

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaQuantumControl.github.io/TwoQubitWeylChamber.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaQuantumControl.github.io/TwoQubitWeylChamber.jl/dev/)
[![Build Status](https://github.com/JuliaQuantumControl/TwoQubitWeylChamber.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/JuliaQuantumControl/TwoQubitWeylChamber.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/JuliaQuantumControl/TwoQubitWeylChamber.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaQuantumControl/TwoQubitWeylChamber.jl)

Julia package for analyzing two-qubit gates in the Weyl chamber.

This is a partial port of the [Python `weylchamber` package](https://github.com/qucontrol/weylchamber).

The methods provided with these packages allow to do an optimization for the entangling power of a two-qubit gate within the [QuantumControl](https://github.com/JuliaQuantumControl/QuantumControl.jl#readme) framework. See the examples for the optimization of a perfect entangler with the [Krotov](https://juliaquantumcontrol.github.io/Krotov.jl/stable/examples/perfect_entanglers/#Example-4:-Optimization-for-a-perfect-entangler) and [GRAPE](https://juliaquantumcontrol.github.io/GRAPE.jl/stable/examples/perfect_entanglers/#Optimizing-for-a-general-perfect-entangler) methods.


## Documentation

The documentation of `TwoQubitWeylChamber.jl` is available at <https://juliaquantumcontrol.github.io/TwoQubitWeylChamber.jl>.


## Installation

The `TwoQubitWeylChamber` package can be installed with [Pkg][] as

~~~
pkg> add TwoQubitWeylChamber
~~~

[Pkg]: https://pkgdocs.julialang.org/v1/
