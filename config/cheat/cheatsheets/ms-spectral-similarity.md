# MS spectral similarity measures

Ways to score how alike two mass spectra are. A spectrum is a set of
`(m/z, intensity)` peaks; most measures first turn the two spectra into
aligned intensity vectors `u`, `v` (one entry per m/z bin, `0` where a peak
is absent) and then compare the vectors. Peaks are "aligned"/matched within
an m/z tolerance (e.g. 0.02 Da or some ppm).

Terminology note used throughout:
  - single-spectrum measure  -> describes ONE spectrum (e.g. spectral entropy)
  - comparison / similarity   -> compares TWO spectra (e.g. cosine, entropy similarity)


## Cosine similarity (dot product score)

Treat each spectrum as a vector of peak intensities over shared
m/z positions. The score is the cosine of the angle between the two vectors:
1.0 = identical directions (same relative peak pattern), 0.0 = no shared
peaks. Intensity magnitude cancels out (it is normalized away), so only the
relative pattern of peaks matters. Only peaks at the SAME m/z can match.

```
              u . v              sum_i (u_i * v_i)
cos(u,v) = ----------- = --------------------------------------
           |u| * |v|      sqrt(sum_i u_i^2) * sqrt(sum_i v_i^2)

  u_i, v_i = intensity of matched peak i in spectrum A, B
             (u_i = 0 if that m/z is absent in A)
```


## Weighted cosine similarity

Same as cosine, but each peak's contribution is re-weighted by a
function of its m/z and intensity before the dot product, typically
`m/z^a * I^b`. Rationale (Stein & Scott): high-m/z fragments are usually
low-intensity but structurally informative, so up-weighting them by m/z
improves identification. This is the DEFAULT "cosine" in most library-search
tools (matchms `mz_power=a`, `intensity_power=b`; NIST/MassBank presets).

```
                    sum_i (w_ui * w_vi)
weighted_cos = --------------------------------------
                sqrt(sum_i w_ui^2) * sqrt(sum_i w_vi^2)

  w_ui = (mz_i)^a * (I_ui)^b      (weighted intensity of peak i)

Common (a, b) presets:
  None       m/z^0 * I^1      (plain intensities)
  SQRT       m/z^0 * I^0.5
  MassBank   m/z^2 * I^0.5
  NIST11 LC  m/z^1.3 * I^0.53
  NIST GC    m/z^3 * I^0.6
```


## Modified cosine similarity

Like cosine, but built for comparing spectra of RELATED molecules
that differ by some modification (mass shift). A fragment in spectrum A is
allowed to match a fragment in B either at the same m/z OR at an m/z shifted
by the precursor-mass difference `dm = precursor_A - precursor_B`. This
catches shifted analogues of the same substructure that plain cosine misses.
Matching is greedy one-to-one (each peak used at most once) chosen to
maximize the total score. Formula is identical to cosine once the shifted
alignment is done.

```
dm = precursor_mz(A) - precursor_mz(B)

peak i in A matches peak j in B  if
    | mz_i - mz_j | <= tol            (direct match)
 OR | mz_i - (mz_j + dm) | <= tol     (neutral-loss / shifted match)

modified_cos = sum over matched pairs (u . v) / (|u| * |v|)
   with each peak assigned to at most one pair (greedy max-score matching)
```


## Spectral entropy (single spectrum)  --  NOT a comparison

A property of ONE spectrum. Normalize the peak intensities so they
sum to 1 (treat them as a probability distribution over peaks), then take the
Shannon entropy. Low entropy = a few dominant peaks (clean, informative
spectrum); high entropy = intensity spread flat across many peaks (noisy /
uninformative). Li et al. 2021 showed clean high-quality spectra tend to have
low entropy. This is a QUALITY / complexity descriptor, not a similarity.

```
p_i = I_i / sum_k I_k          (intensities normalized to sum to 1)

S = - sum_i ( p_i * ln p_i )   (Shannon spectral entropy of one spectrum)
```


## Spectral entropy similarity (entropy similarity score) -- comparison

THE two-spectrum counterpart of spectral entropy, from Li et al.,
Nature Methods 2021 ("Spectral entropy outperforms MS/MS dot product
similarity..."). Its formal name is "spectral entropy similarity" (a.k.a.
"entropy similarity score"); it is essentially a Jensen-Shannon-style
divergence turned into a 0..1 similarity. Idea: merge the two spectra into
one mixed spectrum (matched peaks add, then renormalize), take entropies of
each spectrum and of the merged spectrum. If the two spectra are identical
the merged entropy equals the individuals and similarity = 1; the more they
differ, the more the merge raises entropy, driving similarity toward 0.

Contrast with plain spectral entropy above:
  - spectral entropy      : S computed on ONE spectrum (a descriptor)
  - entropy similarity     : combines S_A, S_B, S_AB to SCORE a PAIR

```
S_A  = entropy of spectrum A       (peaks normalized to sum 1)
S_B  = entropy of spectrum B
S_AB = entropy of the merged spectrum A+B
       (align peaks, sum matched intensities, renormalize to sum 1)

                    2 * S_AB - S_A - S_B
entropy_sim = 1 -  ----------------------
                           ln(4)

  range 0 (dissimilar) .. 1 (identical);  ln(4) normalizes to [0,1]
```

Weighted spectral entropy (Li 2021 refinement): low-entropy spectra
over-weight their few big peaks, so before scoring, if a spectrum's entropy
`S < 3`, reweight every intensity by exponent `w` and renormalize. This is
the "weighted" vs "unweighted" entropy-similarity distinction.

```
if S < 3:   w = 0.25 + 0.25 * S      (S in [0,3) -> w in [0.25, 1))
            I_i  ->  I_i^w   then renormalize
if S >= 3:  w = 1 (unchanged)
```


## DWCS -- Diagnostic Weighted Cosine similarity

The "Deep MDRB" score (Shi et al. 2026). It fuses cosine AND
modified cosine, then up-weights the DIAGNOSTIC ions. Two kinds of peak
matches are summed: (1) direct matches at the same m/z (the cosine part) and
(2) neutral-loss matches -- fragment pairs sharing the same precursor-minus-
product mass difference `dm` (the modified-cosine part). Every matched term
is multiplied by a weight coefficient `k` that is raised for high-abundance
"diagnostic" ions (the top-3 most intense fragments), so structurally
decisive peaks dominate the score. This sharpens discrimination of structural
analogues that plain/modified cosine confuse. Spectra are normalized to the
strongest fragment before scoring.

```
        sum_i(k_i * A_i * B_i)  +  sum_j(k_j * A_j * B_j)
DWCS = ------------------------------------------------------------------------
        sqrt( sum_i k_i*A_i^2 + sum_j k_j*A_j^2 )
          * sqrt( sum_i k_i*B_i^2 + sum_j k_j*B_j^2 )

  A_i, B_i = intensity of i-th fragment pair with IDENTICAL m/z
             (i = 1..n1, direct matches -> cosine part)
  A_j, B_j = intensity of j-th fragment pair sharing equal precursor-product
             mass diff dm (j = 1..n2, neutral-loss matches -> mod-cosine part)
  k        = per-ion weight coefficient
             k = 2.0 for the top-3 (diagnostic) ions, 1.0 otherwise
  spectra normalized to strongest fragment intensity first

Defaults (Deep MDRB): diagnostic ions = top 3, k = 2.0,
  score threshold 0.6 (levels 1-3), 0.7 for unpredictable metabolites.
```
Relation to the others: set all `k = 1` and drop the neutral-loss `j` sum
=> plain cosine. Keep `k = 1` and keep both sums => modified cosine. DWCS =
modified cosine + diagnostic-ion weighting.


## Quick chooser

```
same compound, same instrument (GC-EI)  : weighted / composite cosine
same compound, LC-MS/MS                 : cosine or entropy similarity
related analogues (mass-shifted)        : modified cosine
best small-molecule ID accuracy (2021+) : spectral entropy similarity
judge quality of ONE spectrum           : spectral entropy (single)
```

Refs:
  - Li et al., Nat. Methods 18, 1524 (2021). doi:10.1038/s41592-021-01331-z
    (spectral entropy + entropy similarity); MSEntropy pkg:
    github.com/YuanyueLi/SpectralEntropy
  - mzmine spectral-similarity docs (weighted / composite cosine)
  - modified cosine: Watrous et al. / GNPS; cf. JASMS 10.1021/jasms.2c00153
  - DWCS: Shi et al., "Deep MDRB...", Acta Pharm. Sin. B (2026).
    doi:10.1016/j.apsb.2026.07.026 ; code: github.com/XMU-Wulab/DeepMDRB
