# Cyber Security Breaches Survey (CSBS) – Cluster Analysis Workflow

Author: Toby Beevers
Purpose: Exploratory machine learning clustering of organisations across CSBS waves (2018–2025)

---

## Overview

This workflow performs **unsupervised machine learning (K-Means clustering)** to identify types of organisations based on cyber security behaviours and controls across all 8 CSBS waves.

Each organisation is represented as a vector of 26 survey response variables drawn from the stable 172-variable longitudinal core. The analysis is restricted to **businesses only** (`samptype == 1`), as org size (`sizeb`) is only meaningful for this group.

### Pipeline

| Step | Description |
|---|---|
| 1. Load | Read `.tab` files from `data_raw/`, normalise column names |
| 2. Clean | Filter to businesses, fix policy routing, handle missing codes and 2025 wave quirks |
| 3. Feature matrix | Select 26 defined cluster features + metadata; combine all waves |
| 4. Impute | Median imputation for remaining NaN values |
| 5. Standardise | `StandardScaler` to mean=0, std=1 (required for distance-based clustering) |
| 6. Elbow method | Plot inertia for K=2–10 to choose optimal number of clusters |
| 7. K-Means | Fit with chosen K (default K=4), assign cluster labels |
| 8. Profiles | Summarise clusters by grouped dimension means |
| 9. Visualisations | Radar, cluster share by year, PCA scatter, feature heatmap, org size breakdown |
| 10. Trend analysis | Breach rate and potential drivers over time; overlay chart |

---

## Data and Scope

- **Source files:** `data_raw/{year}.tab` (2018–2025, 8 waves)
- **Population:** Businesses only (`samptype == 1`)
- **Sample sizes:** ~1,200–2,400 businesses per wave; ~13,800 pooled across all waves
- **Note:** CSBS is repeated cross-sectional data — different respondents each year. Clustering identifies *types of organisations*, not longitudinal change of the same organisations.

---

## Feature Groups

26 variables used for clustering, all stable across all 8 waves:

| Group | Variables | Count |
|---|---|---|
| Priority score | `priority_score` (derived: `5 − priority`) | 1 |
| Governance | `manage1, manage2, manage3, manage4, manage6, manage7` | 6 |
| Policy | `policy1, policy2, policy3, policy4, policy5, policy8, policy9` | 7 |
| Technical controls | `step1–step10` (10-Steps framework) | 10 |
| Breach outcome | `breached` (derived from `type11`) | 1 |
| **Total** | | **25** |

Metadata carried alongside but **not used in clustering:** `year`, `sizeb`

---

## Survey Missing Codes

| Code | Meaning | Treatment |
|---|---|---|
| `-1` | Routing / not applicable | Replace with NaN (except `policy1–5` when `manage3==0` → recode to 0) |
| `-97` | Don't know / refused | Replace with NaN |
| `-98` | Not asked | Replace with NaN |
| `-99` | Missing | Replace with NaN |

### 2025 Wave Quirks

Two variables use non-standard codes in the 2025 wave that are not caught by the standard missing-code sweep:

- **`priority`** — don't-know responses coded `997` (not `-97`). Fix: whitelist to `{1, 2, 3, 4}`.
- **`type11`** — missing values coded `-9` (not `-1`). Fix: whitelist to `{0, 1}`.

Failure to handle these inflates breach prevalence from ~49% (correct) to >95% (wrong).

---

## Derived Variables

| Variable | Source | Logic |
|---|---|---|
| `priority_score` | `priority` | `5 − priority` → higher score = higher board priority |
| `breached` | `type11` | `type11 == 0` → `breached = 1` (experienced a breach) |

---

## Policy Routing Fix

`policy1–policy5` are coded `-1` (routing) when `manage3 == 0` (no formal security policy). These are *not* missing — they indicate the policy does not exist. They are recoded to `0` before the missing-code sweep.

---

## ML Approach

**Algorithm:** K-Means Clustering
**Why:** Works well with structured numeric data; produces interpretable, labelled clusters; easy to visualise.

**Elbow method:** Inertia is plotted for K=2–10. The bend in the curve indicates the optimal K — the point where additional clusters give diminishing returns. Default is K=4 based on the four theoretical archetypes below.

**Initialisation:** `n_init=10` — runs 10 random initialisations and takes the best result to reduce sensitivity to starting conditions.

### Theoretical Cluster Archetypes

| Archetype | Characteristics |
|---|---|
| Security Leaders | High governance, high policy, high controls, low breach rate |
| Compliance Driven | High policy, moderate controls, moderate breach rate |
| Reactive | Low governance, low policy, moderate controls, higher breach rate |
| Low Awareness | Low across all dimensions, high breach rate |

Cluster numbers (0–3) are arbitrary — assign archetype labels after inspecting the profiles and feature heatmap.

---

## Outputs

All figures saved to `outputs/figures/`:

| File | Description |
|---|---|
| `ml_elbow.png` | Inertia vs K — used to choose optimal cluster count |
| `ml_profile_heatmap.png` | Heatmap of mean dimension scores per cluster |
| `ml_radar.png` | Radar chart of normalised cluster profiles |
| `ml_cluster_share.png` | Stacked bar: cluster distribution by year |
| `ml_pca.png` | PCA 2D scatter coloured by cluster |
| `ml_breach_trends.png` | Six-panel trends: breach rate and potential drivers |
| `ml_breach_overlay.png` | Overlay: driver lines + org size stacked bars |

---

## Trend Analysis (Section 10)

In addition to clustering, the notebook analyses how breach rate and potential drivers change over time across waves:

- **Breach rate** — % of businesses reporting a breach each year
- **Board priority** — % rating cyber security as high or very high priority
- **Policy adoption** — mean across 7 policy variables (converted to %)
- **Technical controls** — mean across 10-Steps variables (converted to %)
- **Staff training** — % trained (2021–2025 only; `trained` not available in earlier waves)
- **Sample composition** — % micro / small / medium / large each year

> These are **unweighted** figures. For nationally representative estimates use the weighted aggregations in `outputs/tables/`.

The overlay chart combines all four driver lines on a single 0–100% axis with the org-size stacked bars as background context, making it easy to spot whether breach rate movements track sample composition changes or genuine behavioural trends.

---

## Academic Interpretation

Because CSBS is **repeated cross-sectional data**, clustering should be interpreted as:

> *Types of organisations observed in the survey — not longitudinal change of the same organisations.*

However, cluster **distribution over time** (section 9, cluster share by year) can reveal whether the population of UK businesses is shifting towards higher or lower cyber security maturity across the 8 waves.

---

## Running the Notebook

```
notebooks: csbs_cluster_analysis.ipynb
```

Run cells sequentially. The notebook must be run with the kernel CWD set to the `machine learning/` directory, or adjust `PROJECT_ROOT` accordingly.

Dependencies: `pandas`, `numpy`, `matplotlib`, `scikit-learn`

---

## Possible Extensions

- Weighted clustering using survey `weight` variable for nationally representative cluster proportions
- Hierarchical clustering to explore dendrogram structure
- Sector-specific cluster analysis (`sector_comb2`)
- Cyber Security Maturity Index — composite score derived from cluster centroids
- Logistic regression using cluster membership as a predictor of breach outcome
