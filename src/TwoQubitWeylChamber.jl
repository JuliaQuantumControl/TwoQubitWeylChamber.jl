module TwoQubitWeylChamber

export D_PE,
    canonical_gate,
    gate_concurrence,
    in_weyl_chamber,
    local_invariants,
    unitarity,
    weyl_chamber_coordinates,
    weyl_chamber_region


using LinearAlgebra


const 𝕚 = 1im

const Q_magic = [
    1  0  0  𝕚
    0  𝕚  1  0
    0  𝕚 -1  0
    1  0  0 -𝕚
]

const SxSx = ComplexF64[
    0  0  0  1
    0  0  1  0
    0  1  0  0
    1  0  0  0
]

const SySy = ComplexF64[
     0  0  0 -1
     0  0  1  0
     0  1  0  0
    -1  0  0  0
]


const SzSz = ComplexF64[
    1  0  0  0
    0 -1  0  0
    0  0 -1  0
    0  0  0  1
]


"""Calculate the local invariants g₁, g₂, g₃ for a two-qubit gate.

```julia
g₁, g₂, g₃ = local_invariants(U)
```
"""
function local_invariants(U)
    Q = Q_magic
    UB = Q' * U * Q  # "to-magic"
    detU = det(UB)
    m = transpose(UB) * UB
    g₁₂ = tr(m)^2 / 16detU
    g₁ = real(g₁₂)
    g₂ = imag(g₁₂)
    g₃ = real((tr(m)^2 - tr(m * m)) / 4detU)
    return g₁, g₂, g₃
end


"""Calculate the Weyl chamber coordinates c₁, c₂, c₃ for a two-qubit gate.

```julia
c₁, c₂, c₃ = weyl_chamber_coordinates(U)
```

calculates the Weyl chamber coordinates using the algorithm described in
[ChildsPRA2003](@citet).

# Reference

* [ChildsPRA2003](@cite) Childs *et al.*. Phys. Rev. A 68, 052311 (2003)
"""
function weyl_chamber_coordinates(U)

    @assert size(U) == (4, 4)
    detU = Complex(det(U))
    Ũ = SySy * transpose(U) * SySy
    two_S = [angle(z) / π for z in eigvals(U * Ũ / √detU)]

    # Check whether the argument of the eigenvalues are on correct branch. If
    # not, put them on correct branch: `angle` returns values in (-π,π] whereas
    # we need values on the branch (-π/2,3π/2]. This implies that those
    # arguments which are between -π and -π/2 need to be shifted by 2π
    two_S = [(ϕⱼ + 0.5 < -1e-10 ? ϕⱼ + 2 : ϕⱼ) for ϕⱼ ∈ two_S]

    p = sortperm(two_S, rev = true)  # Zygote can't handle a direct `sort`
    S = [two_S[p[1]] / 2, two_S[p[2]] / 2, two_S[p[3]] / 2, two_S[p[4]] / 2]
    n = Int(round(sum(S)))  # number of ϕⱼ ≤ -π/4
    @assert n ≥ 0
    if n > 0
        S = [j <= n ? ϕⱼ - 1.0 : ϕⱼ for (j, ϕⱼ) in enumerate(S)]
        S = circshift(S, -n)
    end
    c₁ = S[1] + S[2]
    c₂ = S[1] + S[3]
    c₃ = S[2] + S[3]
    if c₃ < 0
        c₁ = 1 - c₁
        c₃ = -c₃
    end
    return c₁, c₂, c₃

end


"""Calculate the maximum gate concurrence.

```julia
C = gate_concurrence(U)
C = gate_concurrence(c₁, c₂, c₃)
```

calculates that maximum concurrence ``C ∈ [0, 1]`` that the two two-qubit gate `U`,
respectively the gate described by the Weyl chamber coordinates `c₁`, `c₂`,
`c₃` (see [`weyl_chamber_coordinates`](@ref)) can generate.

# Reference

* [KrausPRA2001](@cite) Kraus and Cirac, Phys. Rev. A 63, 062309 (2001)
"""
function gate_concurrence(c₁, c₂, c₃)
    if (c₁ + c₂ ≥ 0.5) && (c₁ - c₂ ≤ 0.5) && (c₂ + c₃ ≤ 0.5)
        # If we're inside the perfect-entangler polyhedron in the Weyl chamber
        # the concurrence is 1 by definition. The "regular" formula gives wrong
        # results in this case.
        C = 1.0
    else
        # Outside of the polyhedron, the Formula of Eq (21) in PRA 63, 062309
        # is valid
        return max(
            abs(sin(π * (c₁ + c₃))),
            abs(sin(π * (c₂ + c₁))),
            abs(sin(π * (c₃ + c₂))),
            abs(sin(π * (c₁ - c₃))),
            abs(sin(π * (c₂ - c₁))),
            abs(sin(π * (c₃ - c₂))),
        )
    end
end

gate_concurrence(U) = gate_concurrence(weyl_chamber_coordinates(U)...)



@doc raw"""Construct the canonical gate for the given Weyl chamber coordinates.

```julia
Û = canonical_gate(c₁, c₂, c₃)
```

constructs the two qubit gate ``Û`` as

```math
Û = \exp\left[i\frac{π}{2} (c_1 σ̂_x σ̂_x + c_2 σ̂_y σ̂_y + c_3 σ̂_z σ̂_z)\right]
```

where ``σ̂_{x,y,z}`` are the Pauli matrices.
"""
function canonical_gate(c₁, c₂, c₃)
    return exp(𝕚 * π / 2 * (c₁ * SxSx + c₂ * SySy + c₃ * SzSz))
end


"""Identify which region of the Weyl chamber a given gate is located in.

```julia
region = weyl_chamber_region(U)
region = weyl_chamber_region(c₁, c₂, c₃)
```

identifies which region of the Weyl chamber the given two-qubit gate `U`,
respectively the gate identified by the Weyl chamber coordinates `c₁`, `c₂`,
`c₃` (see [`weyl_chamber_coordinates`](@ref)) is in, as a string. Possible
outputs are:

* `"PE"`: gate is in the polyhedron of perfect entanglers.
* `"W0"`: gate is between the identity and the perfect entanglers.
* `"W0*"`: gate is between CPHASE(2π) and the perfect entanglers.
* `"W1"`: gate is between SWAP and the perfect entanglers.

For invalid Weyl chamber coordinates, an empty string is returned.
"""
function weyl_chamber_region(c₁, c₂, c₃)
    in_weyl_chamber = (
        ((0 ≤ c₁ < 0.5) && (0 ≤ c₂ ≤ c₁) && (0 ≤ c₃ ≤ c₂)) ||
        ((0.5 ≤ c₁ ≤ 1.0) && (0 ≤ c₂ ≤ (1 - c₁)) && (0 ≤ c₃ ≤ c₂))
    )
    if in_weyl_chamber
        if ((c₁ + c₂) ≥ 0.5) && ((c₁ - c₂) ≤ 0.5) && ((c₂ + c₃) ≤ 0.5)
            return "PE"
        elseif (c₁ + c₂) < 0.5
            return "W0"
        elseif (c₁ - c₂) > 0.5
            return "W0*"
        elseif (c₂ + c₃) > 0.5
            return "W1"
        else
            throw(ErrorException("Internal Error: ($c₁, $c₂, $c₃) not handled"))
        end
    else
        return ""
    end
end

weyl_chamber_region(U) = weyl_chamber_region(weyl_chamber_coordinates(U)...)


"""Check whether a given gate is in (a specific region of) the Weyl chamber.

```
in_weyl_chamber(c₁, c₂, c₃)
```

checks whether `c₁`, `c₂`, `c₃` are valid Weyl chamber coordinates.

```
in_weyl_chamber(U; region="PE")
in_weyl_chamber(c₁, c₂, c₃; region="PE")
```

checks whether the two-qubit gate `U`, respectively the gate described by the
Weyl chamber coordinates `c₁`, `c₂`, `c₃` (see
[`weyl_chamber_coordinates`](@ref)) is a perfect entangler. The `region` can be
any other of the regions returned by [`weyl_chamber_region`](@ref).
"""
function in_weyl_chamber(c₁, c₂, c₃; region = "W")
    regions = ["W", "PE", "W0", "W0*", "W1"]
    if region ∉ regions
        throw(ArgumentError("Invalid region $(repr(region)), must be one of $regions"))
    end
    found_region = weyl_chamber_region(c₁, c₂, c₃)
    if region == "W"
        return found_region ≠ ""
    else
        return found_region == region
    end
end


in_weyl_chamber(U; region) = in_weyl_chamber(weyl_chamber_coordinates(U)...; region)


@doc raw"""Unitarity of a matrix.

```
pop_loss = 1 - unitarity(U)
```

measures the loss of population from the subspace described by
`U`. E.g., for a two-qubit gate, `U` is a 4×4 matrix. The `unitarity` is
defined as ``\Re[\tr(Û^†Û) / N]`` where ``N`` is the dimension of ``Û``.
"""
function unitarity(U)
    N = size(U)[1]
    return real(tr(U' * U) / N)
end


@doc raw"""Perfect-entanglers distance measure.

```julia
D = D_PE(U; unitarity_weight=0.0, absolute_square=false)
```

For a given two-qubit gate ``Û``, this is defined via the
[`local_invariants`](@ref) ``g_1``, ``g_2``, ``g_3`` as

```math
D = g_3 \sqrt{g_1^2 + g_2^2} - g_1
```

This describes the geometric distance of the quantum gate from the polyhedron
of perfect entanglers in the Weyl chamber.

This equation is only meaningful under the assumption that ``Û`` is unitary. If
the two-qubit level are a logical subspace embedded in a larger physical
Hilbert space, loss of population from the logical subspace may lead to a
non-unitary ``Û``. In this case, the [`unitarity`](@ref) measure can be added
to the functional by giving a `unitary_weight` ∈ [0, 1) that specifies the
relative proportion of the ``D`` term and the unitarity term.

By specifying `absolute_square=true`, the functional is modified as ``D →
|D|²``, optimizing specifically for the *boundary* of the perfect entanglers
polyhedron. This accounts for the fact that ``D`` can take negative values
inside the polyhedron, as well as the `W1` region of the Weyl chamber (the one
adjacent to SWAP). This may be especially useful in a system with population
loss (`unitarity_weight` > 0), as it avoids situations where the optimization
goes deeper into the perfect entanglers while *increasing* population loss.

!!! warning

    The functional does not check which region of the Weyl chamber the quantum
    gate is in. When using this for an optimization where the guess leads to a
    point in the `W1` region of the Weyl chamber (close to SWAP), the sign of
    the functional must be flipped, or else it will optimize for SWAP.
    Alternatively, use `absolute_square=true`.

!!! tip

    The functional can be converted into the correct form for an optimization
    that uses one trajectory for each logical basis state by using
    `QuantumControl.Functionals.gate_functional`.
"""
function D_PE(U; unitarity_weight = 0.0, absolute_square = false)
    w::Float64 = clamp(1.0 - unitarity_weight, 0.0001, 1.0)
    N = 4
    @assert size(U) == (N, N)
    g₁, g₂, g₃ = local_invariants(U)
    if absolute_square
        D = abs2(g₃ * sqrt(g₁^2 + g₂^2) - g₁)
    else
        D = g₃ * sqrt(g₁^2 + g₂^2) - g₁
    end
    pop_loss = 1 - unitarity(U)
    return w * D + (1 - w) * pop_loss
end

end
