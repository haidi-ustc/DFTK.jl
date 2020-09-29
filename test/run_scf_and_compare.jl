using Test
using DFTK

function run_scf_and_compare(T, basis, ref_evals, ref_etot;
                             n_ignored=0, test_tol=1e-6, scf_tol=1e-6, test_etot=true,
                             n_ep_extra=3)
    n_kpt = length(ref_evals)
    n_bands = length(ref_evals[1])
    n_spin = length(DFTK.spin_components(basis.model))

    scfres = self_consistent_field(basis, tol=scf_tol, n_bands=n_bands, n_ep_extra=n_ep_extra)
    for ik in 1:length(silicon.kcoords) * n_spin
        @test eltype(scfres.eigenvalues[ik]) == T
        @test eltype(scfres.ψ[ik]) == Complex{T}
        # println(ik, "  ", abs.(ref_evals[mod1(ik, n_kpt)] - scfres.eigenvalues[ik][1:n_bands]))
    end
    for ik in 1:length(silicon.kcoords) * n_spin
        # Ignore last few bands, because these eigenvalues are hardest to converge
        # and typically a bit random and unstable in the LOBPCG
        diff = abs.(ref_evals[mod1(ik, n_kpt)] - scfres.eigenvalues[ik][1:n_bands])
        @test maximum(diff[1:n_bands - n_ignored]) < test_tol
    end

    @test eltype(scfres.energies.total) == T
    test_etot && (@test scfres.energies.total ≈ ref_etot atol=test_tol)
end
