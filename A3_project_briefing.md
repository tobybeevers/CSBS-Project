# Assessment 3 — Project Briefing for Claude

## What this document is

This document summarises the analytical work completed on the CSBS Project so that Claude can assist with writing, reviewing, or extending the Assessment 3 report. It covers the project background, the data, the analytical techniques applied, and the key findings. Read this before asking Claude to write anything — it contains the facts and decisions that need to be reflected accurately.

---

## Project Context

**Dataset:** UK Cyber Security Breaches Survey (CSBS), published annually by DSIT (formerly DCMS) and the Home Office. Eight waves: 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025.

**Professional context:** Node9 Consulting — a cyber security consultancy. The analysis supports a five-part LinkedIn infographic series for SME decision-makers and IT leads, as well as academic outputs for modules ICL-3005 (analysis) and ICL-3006 (visualisation).

**Research question:** How has the UK's cyber security posture changed across 8 years, and which governance and control factors are associated with breach outcomes?

**Why this data:** DSIT publishes annual CSBS reports but provides no longitudinal analysis. This project creates that analysis for the first time from the raw microdata.

---

## Data Description

| Wave | Respondents | Variables |
|------|-------------|-----------|
| 2018 | 2,089 | 461 |
| 2019 | 2,081 | 461 |
| 2020 | 1,901 | 312 |
| 2021 | 2,285 | 420 |
| 2022 | 2,158 | 446 |
| 2023 | 3,992 | 567 |
| 2024 | 3,435 | 498 |
| 2025 | 3,836 | 527 |

- **Format:** Tab-delimited flat files, one per wave.
- **Population:** UK businesses, charities, and education institutions. Three org types coded in `samptype` (1=Business, 2=Charity, 3=Education).
- **Missing value codes:** Negative integers, not NaN. `-1` = routing/not applicable, `-97` = don't know/refused, `-99` = other missing. These must always be filtered before analysis.
- **Survey weights:** The `weight` variable corrects for sampling imbalance and must be applied to produce nationally representative estimates. All published figures in this project use weighted percentages.
- **Stable longitudinal core:** 172 variables are present and consistently named across all 8 waves. These were identified in notebook 01 by computing the intersection of column names across all wave files.

### Key variable conventions

- `sizeb`: business size (1=Micro <10, 2=Small 10–49, 3=Medium 50–249, 4=Large 250+). Only meaningful for businesses (`samptype == 1`).
- `priority` (Q9): board/senior management cyber priority. 4-point ordinal scale. **Lower code = higher priority** (1=Very high, 4=Very low).
- `type11`: "None of these" at breach question Q53A. `type11 == 0` means breached; `type11 == 1` means not breached. Stable across all 8 waves.
- `manage1`–`manage7`: governance arrangements in place (binary).
- `policy1`–`policy9`: specific policy areas covered (binary). Routing: `policy1–5` are coded `-1` when `manage3 == 0` (no formal policy) — these are recoded to `0`, not treated as missing.
- `step1`–`step10`: 10 Steps to Cyber Security controls in place (binary).
- `allessentials`: Cyber Essentials certification (binary).
- `trained`: cybersecurity training provided to staff. Only available in waves 2021–2025.

### Known data quality issues

- **2025 wave quirks:** `priority` uses code `997` (not `-97`) for don't know; `type11` uses `-9` (not `-1`) for missing. Standard missing-code sweeps miss these. Fix: whitelist `priority` to `{1,2,3,4}` and `type11` to `{0,1}`. Failure to do this inflates breach prevalence from ~49.6% (correct) to >95% (wrong).
- **`sector_comb2` coding change:** Non-business respondents are `-1` in 2024/2025 vs blank string in earlier waves.
- **Sample size doubled mid-series:** ~2,000 respondents in 2018–2022; ~4,000 from 2023. Aggregate trends must account for this composition change.
- **Methodology changes:** Flagged at 2021 and 2024. Cross-wave comparisons across these points should be interpreted cautiously.

---

## Analytical Work Completed

### Notebook 01 — Variable Validation

Cross-wave column consistency analysis across all 8 `.tab` files. Output: `variable_presence_summary.csv` documenting which variables are present in which waves. Identified the 172-variable stable longitudinal core by computing column-name intersection. Column normalisation applied: strip whitespace, remove BOM (`\ufeff`), lowercase.

### Notebook 02 — Weighted Aggregation

Produces five pre-aggregated summary CSVs in `outputs/tables/`, one per visualisation story. All figures use weighted percentages. Pre-weighting filters applied throughout: missing codes excluded, 2025 quirks handled via whitelisting.

### Notebook 03/04 — Visualisation Exploration

Exploratory charts for each of the five stories (2–3 design options each), saved as PNG to `outputs/figures/`. These inform the final Processing.org renders.

### Machine Learning — K-Means Cluster Analysis (`machine learning/csbs_cluster_analysis.ipynb`)

**Technique:** Unsupervised K-Means clustering using scikit-learn.

**Scope:** Businesses only (`samptype == 1`), all 8 waves pooled. ~13,800 organisation-wave observations.

**Feature matrix:** 26 variables from the stable longitudinal core:

| Group | Variables | Count |
|---|---|---|
| Priority score | `priority_score` (derived: `5 − priority`) | 1 |
| Governance | `manage1, manage2, manage3, manage4, manage6, manage7` | 6 |
| Policy | `policy1–5, policy8, policy9` | 7 |
| Technical controls | `step1–step10` (10-Steps framework) | 10 |
| Breach outcome | `breached` (derived: `type11 == 0`) | 1 |
| **Total** | | **25** |

**Preprocessing pipeline:**
1. Filter to businesses, fix policy routing (`-1` → `0` when `manage3 == 0`), handle 2025 quirks.
2. Replace all remaining missing codes with NaN.
3. Median imputation for remaining NaN values.
4. StandardScaler normalisation (mean=0, std=1) — required for distance-based clustering.

**Model selection:** Elbow method plotting inertia for K=2–10. Default K=4 selected based on elbow curve and theoretical fit with four expected archetypes.

**Cluster archetypes (theoretical, to be confirmed by profile inspection):**

| Archetype | Expected characteristics |
|---|---|
| Security Leaders | High governance, high policy, high controls, low breach rate |
| Compliance Driven | High policy, moderate controls, moderate breach rate |
| Reactive | Low governance, low policy, moderate controls, higher breach rate |
| Low Awareness | Low across all dimensions, high breach rate |

**Outputs produced:**
- `ml_elbow.png` — inertia vs K
- `ml_profile_heatmap.png` — feature heatmap by cluster
- `ml_radar.png` — radar chart of normalised cluster profiles
- `ml_cluster_share.png` — cluster distribution by year (stacked bar)
- `ml_pca.png` — PCA 2D scatter coloured by cluster
- `ml_breach_trends.png` — six-panel trend charts
- `ml_breach_overlay.png` — breach rate + driver lines + org size composition overlay

**Important academic note:** CSBS is repeated cross-sectional data — different respondents each year. Clustering identifies *types of organisations*, not longitudinal change of the same organisations. However, cluster distribution over time (cluster share by year) can reveal whether the UK business population is shifting towards higher or lower maturity.

---

## Five Visualisation Stories and Their Outputs

### Story 1 — UK Posture Over 8 Years

**Research question:** How has the aggregate cyber security posture of UK organisations changed over 8 years?

**CSV:** `story1_uk_posture_trends.csv` — columns: `year, governance_score_A, governance_score_B, breach_pct, participant_count`

**Governance Score A (binary sum composite):** 10 binary indicators summed (board priority, 4 management indicators, 5 policy indicators), divided by 10. Weighted mean per year. Implicit assumption: all 10 indicators equally important.

**Governance Score B (three-component average):** Equal weight to three governance dimensions — board priority (normalised 0–1), management practices (proportion of 4 indicators), and policy coverage (proportion of 5 policy areas). Weighted mean per year. More sensitive to board-level priority than Score A.

**Key data:**

| Year | Governance Score B | Breach Prevalence | Participants |
|------|-------------------|-------------------|--------------|
| 2018 | 37.4% | 37.3% | 2,088 |
| 2019 | 43.8% | 30.4% | 2,080 |
| 2020 | 49.1% | 45.3% | 1,900 |
| 2021 | 46.7% | 39.9% | 2,284 |
| 2022 | 51.6% | 43.2% | 2,157 |
| 2023 | 46.0% | 35.4% | 3,991 |
| 2024 | 47.9% | 48.0% | 3,434 |
| 2025 | 50.5% | 43.4% | 3,835 |

**Core tension:** Governance activity has increased across the period. Breach prevalence has not fallen — it has ranged between 30% and 48%, peaking at 48% in 2024. Whatever organisations are doing more of, it is not consistently reducing breach exposure. This sets up the question for Stories 2–5: does it matter *what kind* of governance activity, not just *how much*?

---

### Story 2 — Board Priority vs Outcomes by Org Size

**Research question:** Do organisations that treat cyber security as a board priority see different breach outcomes? Does this differ by size?

**CSV:** `story2_board_priority_by_size.csv` — columns: `year, org_size, org_size_order, board_priority_pct, board_priority_mean_norm`

**Scope:** Businesses only.

- `board_priority_pct`: % where `priority` is 1 or 2 (Very/Fairly high). Binary threshold measure.
- `board_priority_mean_norm`: weighted mean of `(4 − priority) / 3`. Continuous 0–1 scale where 1 = all Very high.

---

### Story 3 — Policy → Management → Breach Pathway

**Research question:** Is having a formal policy enough, or does active management matter?

**CSV:** `story3_pathway_analysis.csv` — columns: `has_policy, actively_managed, breached, weighted_n, proportion`

**Scope:** All org types, all years pooled. This is a weighted contingency table across three binary flags.

- `has_policy`: `manage3 == 1`
- `actively_managed`: `manage1 == 1` (board/senior manager with personal cyber responsibility)
- `breached`: `type11 == 0`
- `proportion`: flow volume for Sankey diagram (sums to 1.0 across all 8 pathway combinations)

---

### Story 4 — Technical Controls Adoption

**Research question:** Does Cyber Essentials and 10 Steps adoption track breach prevalence?

**CSV:** `story4_control_adoption.csv` — columns: `year, ce_adoption_pct, ten_steps_pct, breach_nonadopter_pct`

- `ce_adoption_pct`: % with Cyber Essentials certification (`allessentials == 1`)
- `ten_steps_pct`: % implementing 10-Steps framework (`any10steps == 1`)
- `breach_nonadopter_pct`: breach prevalence among non-adopters of Cyber Essentials

---

### Story 5 — Governance Score vs Breach, Segmented by Size

**Research question:** Do organisations with higher governance maturity experience fewer breaches? Is this consistent across org sizes?

**CSV:** `story5_governance_vs_breach_size.csv` — columns: `year, org_size, org_size_order, governance_score_A, governance_score_B, breach_pct, org_count`

**Scope:** Businesses only. One row per year × size band combination.

---

## Techniques Applied — Assessment 3 Mapping

| Technique | Where applied | Justification |
|---|---|---|
| Longitudinal weighted aggregation | All 5 stories | Population-representative trend estimation from complex survey data |
| Composite index construction | Governance Score A and B | Dimensionality reduction of multi-item governance indicators into interpretable summary measure |
| Cross-tabulation / pathway analysis | Story 3 | Contingency table to decompose organisational pathways from governance to outcome |
| K-Means clustering | ML notebook | Unsupervised classification of ~13,800 org-wave observations into behaviour-based archetypes |
| StandardScaler preprocessing | ML notebook | Required normalisation for distance-based clustering across variables with different scales |
| PCA dimensionality reduction | ML notebook (visualisation) | 2D projection of 25-variable feature space for cluster separation visualisation |
| Elbow method | ML notebook | Data-driven cluster count selection (K=4) |
| Trend analysis over time | ML notebook, Story 1 | Year-on-year change in breach rate, governance activity, and controls adoption |

---

## Important Caveats to Reflect in the Report

1. **Repeated cross-sectional design** — different respondents each year. Cannot track the same organisations over time. All longitudinal claims are about *population-level patterns*, not individual trajectories.

2. **Governance scores are constructed measures** — not self-reported maturity ratings. Score A and B make different assumptions about indicator weighting and produce different values. Both are reported and contrasted.

3. **Sample composition shift** — participant count approximately doubled from 2023. Some apparent changes in aggregate scores reflect who is being surveyed, not purely behavioural change.

4. **Methodology changes at 2021 and 2024** — structural breaks in the data. Year-on-year comparisons across these points should be treated with caution and marked on charts.

5. **Weighting** — all published percentages use the CSBS `weight` variable. Unweighted figures are used only in the ML cluster analysis (noted in the README as a limitation; weighted clustering is listed as a possible extension).

6. **2020 context** — smallest sample, COVID-19 disruption to remote working patterns and cyber threat exposure. Treat 2020 estimates as noisier and contextually distinct.

---

## File Locations

```
CSBS Project/
├── data_raw/                          # Immutable raw .tab files (2018–2025)
├── notebooks/
│   ├── 01_variable_validation_tab_waves.ipynb
│   ├── 02_aggregation.ipynb
│   ├── 03_visualisation_exploration.ipynb
│   └── 04_visualisation_exploration.ipynb   ← active version
├── machine learning/
│   ├── csbs_cluster_analysis.ipynb
│   └── cluster_analysis_README.md
├── outputs/
│   ├── tables/
│   │   ├── story1_uk_posture_trends.csv
│   │   ├── story2_board_priority_by_size.csv
│   │   ├── story3_pathway_analysis.csv
│   │   ├── story4_control_adoption.csv
│   │   ├── story5_governance_vs_breach_size.csv
│   │   ├── story{1–5}_README.md           ← variable definitions
│   │   └── variable_presence_summary.csv
│   └── figures/
│       ├── s1_option_{a,b,c}*.png          ← Story 1 chart options
│       ├── s2_option_{a,b,c}*.png
│       ├── s3_option_{a,b}*.png
│       ├── s4_option_{a,b}*.png
│       ├── s5_option_{a,b}*.png
│       └── ml_*.png                        ← ML outputs
├── processing_sketches/
│   ├── story1_uk_posture/story1_uk_posture.pde
│   ├── story2_board_priority/story2_board_priority.pde
│   ├── story3_pathway/story3_pathway.pde
│   ├── story4_controls/story4_controls.pde
│   └── story5_governance_breach/story5_governance_breach.pde
└── visualisations/vis.md                   ← Full Processing.org design spec
```
