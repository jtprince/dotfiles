# Missing values & limits of detection in MS differential stats

How to handle zeros / blanks in an MS feature table when testing for
differential abundance. Core question: is a missing value random noise, or
is it biological truth (the analyte was really below the limit of detection
in that sample)? The answer decides whether you should impute, drop, or
MODEL the missingness. Motivation: get the most out of sparse data without
leaning on imputation (which distorts variance and power).

Notation used throughout:
  y      = true (log) intensity of a feature in a sample (may be unobserved)
  R, d   = detection indicator: d=1 observed, d=0 missing
  LOD    = limit of detection (a left-censoring threshold, call it c)
  mu,sig = mean, sd of the intensity distribution
  phi,Phi= standard normal pdf, cdf
  expit  = logistic function: expit(x) = 1/(1+e^-x)


## 1. The missingness taxonomy (Rubin) -- decide this FIRST

Everything downstream hinges on WHY a value is missing. Let Y split
into observed part Y_obs and missing part Y_mis, and R = which entries are
observed. Three mechanisms:

  MCAR  missing completely at random -- missingness independent of ALL data.
        (e.g. a sample tube dropped.) Dropping rows is unbiased, just wasteful.
  MAR   missing at random -- missingness depends only on OBSERVED data, not
        on the missing value itself. Standard imputation is valid here.
  MNAR  missing not at random -- missingness depends on the UNOBSERVED value.
        LOD-driven missingness is MNAR: low true intensity -> more likely
        missing. This is the metabolomics/proteomics default after peak-
        filling / match-between-runs. Ignoring it biases estimates.

```
MCAR:  P(R | Y_obs, Y_mis) = P(R)
MAR:   P(R | Y_obs, Y_mis) = P(R | Y_obs)
MNAR:  P(R | Y_obs, Y_mis)  depends on Y_mis        <-- LOD case
```

Key insight (Li & Smyth 2023): real LC-MS missingness is INTERMEDIATE between
pure MNAR left-censoring (a hard step at LOD) and MAR -- detection rises
GRADUALLY with intensity, it is not a clean cliff. So neither "impute" nor
"hard-censor" is exactly right; a detection-probability model (section 5) fits.


## 2. Baseline: complete-case analysis (drop missing)

Run the t-test / limma only on samples where the feature was
detected. Unbiased ONLY under MCAR. Under MNAR it throws away the fact that
"missing = low", losing power and biasing group means upward (you only keep
the high, detected values).

```
per feature, per group g:  use only { y_i : d_i = 1 }
mean_g_hat = mean of observed y  ->  biased HIGH under MNAR (drops the lows)
```


## 3. Naive substitution (what makes you nervous -- rightly)

Replace every missing with one fixed low number. Fast, ubiquitous,
statistically dangerous: it fabricates zero-variance clumps, shrinks the
within-group variance, and inflates false positives (or kills power).

```
zero          x_mis <- 0
half-min      x_mis <- 0.5 * min(observed feature value)
LOD/2         x_mis <- LOD / 2
LOD/sqrt2     x_mis <- LOD / sqrt(2)      (matrix-effect flavored)

Failure mode: k missing in a group all get the SAME value
  -> group variance underestimated -> t-stat inflated -> FDR blows up
```


## 4. MNAR-aware imputation (better, still imputation)

Instead of one constant, draw each missing value from a low,
left-truncated distribution so the imputed cloud has realistic spread. Still
invents data, but respects "missing = low and variable". Use when a
downstream tool NEEDS a complete matrix (PCA, clustering, ML).

  QRILC  Quantile Regression Imputation of Left-Censored data. Fit the low
         tail of the observed distribution by quantile regression to get
         (mu_hat, sig_hat); draw imputed values from a Gaussian truncated
         above at the censoring quantile.
  MinProb draw from a Gaussian centered at a low value (~ min), fixed small sd.
  GSimp  Gibbs sampler: iteratively predict each missing value from the others
         via a regression model, redrawing from the left-truncated conditional
         until convergence. Best-in-class MNAR imputer in benchmarks.

```
QRILC:   x_mis ~ TruncNormal(mu_hat, sig_hat ; upper = LOD)
         (mu_hat, sig_hat estimated by quantile regression on the low tail)

Contrast with MCAR/MAR imputers (kNN, SVD, BPCA/PPCA, randomForest):
  those borrow from the OBSERVED (high) values -> wrong for MNAR,
  they impute too HIGH. RF good for MCAR/MAR, QRILC/GSimp for MNAR.
```


## 5. Detection-probability / selection models  (NO imputation)  *** best fit ***

The modern answer. Don't fill anything in. Instead write the
probability that a feature is DETECTED as an explicit function of its own
(unobserved) true intensity, and fold that term into the likelihood used for
differential testing. Missingness becomes informative data, not a hole.
This is a "selection model" (Heckman-style): one sub-model for the intensity,
one for whether it is seen.

```
intensity model:   y_i = mu_group + error
detection model:   P(d_i = 1 | y_i) = g( beta0 + beta1 * y_i ),  beta1 > 0
                     g = logistic  (Li & Smyth)   or   probit (O'Brien)
joint likelihood combines BOTH -> estimate group means using observed
values AND the pattern of which values are missing.
```

### 5a. Li & Smyth (2023) "Neither random nor censored" -- protDP  [the paper Corey liked]

Models the Detection Probability Curve (DPC): detection is
logit-linear in the underlying log-intensity, with an asymptote cap < 100%
to allow a small rate of intensity-unrelated (MAR) misses. Fit by a zero-
truncated binomial likelihood over replicates. Once beta0, beta1 are known,
the distribution of the UNOBSERVED intensities is an exponentially-tilted
(mean-shifted) version of the observed one -- so you can quantify the bias
from ignoring missing values and recover power in DE testing.

```
DPC (probability a value is detected given its true log-intensity y):
    logit P(d = 1 | y) = beta0 + beta1 * y            (beta1 > 0)

capped logit-linear (alpha = asymptotic max detection, 0 < alpha <= 1):
                 alpha * exp(beta0 + beta1 * ybar)
    p_i = --------------------------------------------
                 1 + exp(beta0 + beta1 * ybar)

count of detections for a feature over n replicates (zero-truncated, since a
feature seen in 0 samples is absent from the table):
    d_i ~ ZeroTruncatedBinomial(n, p_i)
    P(d_i = k) = C(n,k) p_i^k (1-p_i)^(n-k) / (1 - (1-p_i)^n),  k=1..n

consequence -- the unobserved intensities are shifted DOWN, same variance:
    mu_mis = mu_obs - beta1 * sigma_obs^2
(beta1 * sigma_obs^2 = how many SDs the missing values sit below the observed)

marginal detection odds (what you can estimate from observed data alone):
    logit P(d=1) = beta0 + beta1 * mu_obs - 0.5 * beta1^2 * sigma_obs^2
```
Result from the paper: this likelihood approach RECOVERS statistical power vs
dropping missing values; imputation methods instead lose power or inflate FDR.
Interpretation of beta1: beta1 ~ 0 => MAR (flat DPC); very large beta1 =>
hard left-censoring (step function). Real data sits in between.

### 5b. Karpievitch et al. (2009) -- foundational, DAnTE

First model-based treatment for label-free/label-based proteomics.
A mixture missingness model (some misses random, some censored below LOD) fit
by maximum likelihood / EM, giving protein-level abundances + variances and
handling peptide->protein rollup. Beat complete-case ANOVA and mean-imputation
ANOVA on ROC. Analyzing only observed intensities overestimates abundance and
underestimates variance -- the model corrects both.

```
each peptide intensity is either observed (contributes its density) or
missing with probability that INCREASES as true abundance decreases:
    P(missing | abundance a) = decreasing function of a
fit intensity params + missingness params jointly by ML (EM over the
censored/random mixture).
```

### 5c. O'Brien et al. (2018), Ann. Appl. Stat. -- Bayesian probit selection

Same selection idea, fully Bayesian, with a probit detection link.
Puts priors on everything and samples the posterior of differential abundance
while the missingness model runs jointly.

```
    P(d = 1 | y) = Phi( gamma0 + gamma1 * y )        (probit link)
    priors on (mu_group, gamma0, gamma1, sigma) ; posterior via MCMC
```


## 6. Censored-likelihood (Tobit / AFT) models  (NO imputation)

The strict-MNAR cousin of section 5. Treat every missing value as
KNOWN to be below the threshold c = LOD (left-censored) rather than unknown.
An observed value contributes its normal density; a censored value contributes
only the probability mass below c. No number is substituted. This is a Tobit
model (equivalently an accelerated-failure-time / survival model on intensity).
Used by MSstats (its AFT / censored option).

```
per feature, log-likelihood over samples:

  logL = sum_{observed}  log[ (1/sig) phi( (y_i - mu)/sig ) ]
       + sum_{missing }  log[      Phi( (c   - mu)/sig ) ]
                                       ^ prob the true value < LOD

(right-censoring at a saturation limit is the mirror term, 1 - Phi(...);
 rare in practice.)
```
Difference vs section 5: Tobit assumes a HARD cliff at c (pure MNAR /
left-censoring); detection-probability models allow a SOFT, gradual cliff
(intermediate MNAR<->MAR). Li & Smyth argue the soft version fits LC-MS better.


## 7. Bayesian hierarchical joint models

Generalize 5c -- one big hierarchical model where the probability of
a missing intensity depends on both the unknown abundance AND observable
covariates (e.g. m/z), with informative priors, all sampled together by
MCMC (Gibbs / Hamiltonian). Most flexible, most expensive; gives full
posteriors on differential abundance with missingness uncertainty propagated.

```
    y_ij      ~ Normal(mu_i + group/effects, sigma_i^2)
    P(d_ij=0) = h( abundance y_ij , m/z , ... )     (logistic missingness)
    priors on all params ; joint posterior via MCMC
```


## Chooser

```
Why are values missing?
  tube lost / injection failure (MCAR) ...... drop rows, or any imputer
  depends on observed covariate only (MAR) .. kNN / RF / BPCA imputation
  below LOD, "missing = low" (MNAR) ......... model it, don't impute:
      want DIFFERENTIAL test, keep power ..... detection-prob model  (Li & Smyth / protDP)  [sec 5]
      strict below-threshold assumption ...... censored/Tobit likelihood (MSstats AFT)      [sec 6]
      need a COMPLETE matrix (PCA/ML) ........ QRILC or GSimp (MNAR imputers)                [sec 4]
      full uncertainty / covariates ......... Bayesian hierarchical joint model             [sec 7]
never (for MNAR): zero / half-min / mean substitution as your ONLY strategy   [sec 3]
```

Refs (from the enveda #? thread + follow-ups):
  - Li & Smyth (2023) "Neither random nor censored...", Bioinformatics 39(5)
    btad200. doi:10.1093/bioinformatics/btad200 ; R pkg: protDP
    (mengbo-li.github.io/protDP)
  - Karpievitch et al. (2009) Bioinformatics 25(16):2028. DAnTE.
    (hybrid/EigenMS follow-up: Karpievitch 2012, Bioinformatics 28(12):1586)
  - O'Brien et al. (2018) Ann. Appl. Stat. 12:2075 (Bayesian probit selection)
  - MSstats: Choi et al. (2014) Bioinformatics 30:2524 (AFT / censored option)
  - Tobit/AFT theory: Jin, Lin, Wei, Ying (2003) Biometrika 90:341
  - Wei et al. / Wieczorek et al. (2017) DAPAR&ProStaR (MNAR imputers)
  - QRILC (imputeLCMD); GSimp: Wei et al. (2018) PLoS Comput Biol 14:e1005973
  - Penalized censored-likelihood: Biostatistics (2025) 26(1) kxaf006
  - MCAR/MAR/MNAR taxonomy: Rubin (1976) Biometrika 63:581
