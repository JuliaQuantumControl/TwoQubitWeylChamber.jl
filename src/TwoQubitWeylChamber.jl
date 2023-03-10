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


const π = 1im

const Q_magic = [
    1  0  0  π
    0  π  1  0
    0  π -1  0
    1  0  0 -π
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


"""Calculate the local invariants gβ, gβ, gβ for a two-qubit gate.

```julia
gβ, gβ, gβ = local_invariants(U)
```
"""
function local_invariants(U)
    Q = Q_magic
    UB = Q' * U * Q  # "to-magic"
    detU = det(UB)
    m = transpose(UB) * UB
    gββ = tr(m)^2 / 16detU
    gβ = real(gββ)
    gβ = imag(gββ)
    gβ = real((tr(m)^2 - tr(m * m)) / 4detU)
    return gβ, gβ, gβ
end


"""Calculate the Weyl chamber coordinates cβ, cβ, cβ for a two-qubit gate.

```julia
cβ, cβ, cβ = weyl_chamber_coordinates(U)
```

calculates the Weyl chamber coordinates using the algorithm described in
[ChildsPRA2003](@citet).

# Reference

* [ChildsPRA2003](@cite) Childs *et al.*. Phys. Rev. A 68, 052311 (2003)
"""
function weyl_chamber_coordinates(U)

    @assert size(U) == (4, 4)
    detU = Complex(det(U))
    UΜ = SySy * transpose(U) * SySy
    two_S = [angle(z) / Ο for z in eigvals(U * UΜ / βdetU)]

    # Check whether the argument of the eigenvalues are on correct branch. If
    # not, put them on correct branch: `angle` returns values in (-Ο,Ο] whereas
    # we need values on the branch (-Ο/2,3Ο/2]. This implies that those
    # arguments which are between -Ο and -Ο/2 need to be shifted by 2Ο
    two_S = [(Οβ±Ό + 0.5 < -1e-10 ? Οβ±Ό + 2 : Οβ±Ό) for Οβ±Ό β two_S]

    p = sortperm(two_S, rev=true)  # Zygote can't handle a direct `sort`
    S = [two_S[p[1]] / 2, two_S[p[2]] / 2, two_S[p[3]] / 2, two_S[p[4]] / 2]
    n = Int(round(sum(S)))  # number of Οβ±Ό β€ -Ο/4
    @assert n β₯ 0
    if n > 0
        S = [j <= n ? Οβ±Ό - 1.0 : Οβ±Ό for (j, Οβ±Ό) in enumerate(S)]
        S = circshift(S, -n)
    end
    cβ = S[1] + S[2]
    cβ = S[1] + S[3]
    cβ = S[2] + S[3]
    if cβ < 0
        cβ = 1 - cβ
        cβ = -cβ
    end
    return cβ, cβ, cβ

end


"""Calculate the maximum gate concurrence.

```julia
C = gate_concurrence(U)
C = gate_concurrence(cβ, cβ, cβ)
```

calculates that maximum concurrence ``C β [0, 1]`` that the two two-qubit gate `U`,
respectively the gate described by the Weyl chamber coordinates `cβ`, `cβ`,
`cβ` (see [`weyl_chamber_coordinates`](@ref)) can generate.

# Reference

* [KrausPRA2001](@cite) Kraus and Cirac, Phys. Rev. A 63, 062309 (2001)
"""
function gate_concurrence(cβ, cβ, cβ)
    if (cβ + cβ β₯ 0.5) && (cβ - cβ β€ 0.5) && (cβ + cβ β€ 0.5)
        # If we're inside the perfect-entangler polyhedron in the Weyl chamber
        # the concurrence is 1 by definition. The "regular" formula gives wrong
        # results in this case.
        C = 1.0
    else
        # Outside of the polyhedron, the Formula of Eq (21) in PRA 63, 062309
        # is valid
        return max(
            abs(sin(Ο * (cβ + cβ))),
            abs(sin(Ο * (cβ + cβ))),
            abs(sin(Ο * (cβ + cβ))),
            abs(sin(Ο * (cβ - cβ))),
            abs(sin(Ο * (cβ - cβ))),
            abs(sin(Ο * (cβ - cβ))),
        )
    end
end

gate_concurrence(U) = gate_concurrence(weyl_chamber_coordinates(U)...)



@doc raw"""Construct the canonical gate for the given Weyl chamber coordinates.

```julia
UΜ = canonical_gate(cβ, cβ, cβ)
```

constructs the two qubit gate ``UΜ`` as

```math
UΜ = \exp\left[i\frac{Ο}{2} (c_1 ΟΜ_x ΟΜ_x + c_2 ΟΜ_y ΟΜ_y + c_3 ΟΜ_z ΟΜ_z)\right]
```

where ``ΟΜ_{x,y,z}`` are the Pauli matrices.
"""
function canonical_gate(cβ, cβ, cβ)
    return exp(π * Ο / 2 * (cβ * SxSx + cβ * SySy + cβ * SzSz))
end


"""Identify which region of the Weyl chamber a given gate is located in.

```julia
region = weyl_chamber_region(U)
region = weyl_chamber_region(cβ, cβ, cβ)
```

identifies which region of the Weyl chamber the given two-qubit gate `U`,
respectively the gate identified by the Weyl chamber coordinates `cβ`, `cβ`,
`cβ` (see [`weyl_chamber_coordinates`](@ref)) is in, as a string. Possible
outputs are:

* `"PE"`: gate is in the polyhedron of perfect entanglers.
* `"W0"`: gate is between the identity and the perfect entanglers.
* `"W0*"`: gate is between CPHASE(2Ο) and the perfect entanglers.
* `"W1"`: gate is between SWAP and the perfect entanglers.

For invalid Weyl chamber coordinates, an empty string is returned.
"""
function weyl_chamber_region(cβ, cβ, cβ)
    in_weyl_chamber = (
        ((0 β€ cβ < 0.5) && (0 β€ cβ β€ cβ) && (0 β€ cβ β€ cβ)) ||
        ((0.5 β€ cβ β€ 1.0) && (0 β€ cβ β€ (1 - cβ)) && (0 β€ cβ β€ cβ))
    )
    if in_weyl_chamber
        if ((cβ + cβ) β₯ 0.5) && ((cβ - cβ) β€ 0.5) && ((cβ + cβ) β€ 0.5)
            return "PE"
        elseif (cβ + cβ) < 0.5
            return "W0"
        elseif (cβ - cβ) > 0.5
            return "W0*"
        elseif (cβ + cβ) > 0.5
            return "W1"
        else
            throw(ErrorException("Internal Error: ($cβ, $cβ, $cβ) not handled"))
        end
    else
        return ""
    end
end

weyl_chamber_region(U) = weyl_chamber_region(weyl_chamber_coordinates(U)...)


"""Check whether a given gate is in (a specific region of) the Weyl chamber.

```
in_weyl_chamber(cβ, cβ, cβ)
```

checks whether `cβ`, `cβ`, `cβ` are valid Weyl chamber coordinates.

```
in_weyl_chamber(U; region="PE")
in_weyl_chamber(cβ, cβ, cβ; region="PE")
```

checks whether the two-qubit gate `U`, respectively the gate described by the
Weyl chamber coordinates `cβ`, `cβ`, `cβ` (see
[`weyl_chamber_coordinates`](@ref)) is a perfect entangler. The `region` can be
any other of the regions returned by [`weyl_chamber_region`](@ref).
"""
function in_weyl_chamber(cβ, cβ, cβ; region="W")
    regions = ["W", "PE", "W0", "W0*", "W1"]
    if region β regions
        throw(ArgumentError("Invalid region $(repr(region)), must be one of $regions"))
    end
    found_region = weyl_chamber_region(cβ, cβ, cβ)
    if region == "W"
        return found_region β  ""
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
`U`. E.g., for a two-qubit gate, `U` is a 4Γ4 matrix. The `unitarity` is
defined as ``\Re[\tr(UΜ^β UΜ) / N]`` where ``N`` is the dimension of ``UΜ``.
"""
function unitarity(U)
    N = size(U)[1]
    return real(tr(U' * U) / N)
end


@doc raw"""Perfect-entanglers distance measure.

```julia
D = D_PE(U; unitarity_weight=0.0, absolute_square=false)
```

For a given two-qubit gate ``UΜ``, this is defined via the
[`local_invariants`](@ref) ``g_1``, ``g_2``, ``g_3`` as

```math
D = g_3 \sqrt{g_1^2 + g_2^2} - g_1
```

This describes the geometric distance of the quantum gate from the polyhedron
of perfect entanglers in the Weyl chamber.

This equation is only meaningful under the assumption that ``UΜ`` is unitary. If
the two-qubit level are a logical subspace embedded in a larger physical
Hilbert space, loss of population from the logical subspace may lead to a
non-unitary ``UΜ``. In this case, the [`unitarity`](@ref) measure can be added
to the functional by giving a `unitary_weight` β [0, 1) that specifies the
relative proportion of the ``D`` term and the unitarity term.

By specifying `absolute_square=true`, the functional is modified as ``D β
|D|Β²``, optimizing specifically for the *boundary* of the perfect entanglers
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
    that uses one objective for each logical basis state by using
    `QuantumControl.Functionals.gate_functional`.
"""
function D_PE(U; unitarity_weight=0.0, absolute_square=false)
    w::Float64 = clamp(1.0 - unitarity_weight, 0.0001, 1.0)
    N = 4
    @assert size(U) == (N, N)
    gβ, gβ, gβ = local_invariants(U)
    if absolute_square
        D = abs2(gβ * sqrt(gβ^2 + gβ^2) - gβ)
    else
        D = gβ * sqrt(gβ^2 + gβ^2) - gβ
    end
    pop_loss = 1 - unitarity(U)
    return w * D + (1 - w) * pop_loss
end

end
