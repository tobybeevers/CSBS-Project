# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Python/Jupyter data analysis project that builds a harmonized longitudinal dataset from 8 waves of the UK Cyber Security Breaches Survey (CSBS), 2018–2025. The goal is to identify variables comparable across all years and support longitudinal research into cybersecurity trends.

## Running Notebooks

Notebooks must be run from within the `notebooks/` directory (or with the kernel CWD set there), because they use `Path.cwd().parent` to derive `PROJECT_ROOT`. Run them in numeric order:

```bash
# Start Jupyter from the notebooks directory
cd notebooks
jupyter notebook
```

Or run a specific notebook non-interactively:
```bash
jupyter nbconvert --to notebook --execute notebooks/01_cleaning.ipynb
```

## Architecture

### Data Flow
```
data_raw/{year}.tab  →  notebooks/  →  data_processed/  →  outputs/
```
- Raw `.tab` files are **immutable** — never modify them. All transformations happen in notebooks.
- Notebooks write processed outputs to `data_processed/` (parquet) and `outputs/tables/` (CSV).

### Notebook Pipeline (run in order)
| Notebook | Role |
|---|---|
| `01_cleaning.ipynb` | Loads raw waves, type profiling, negative value exploration |
| `02_variable_validation_tab_waves.ipynb` | Cross-wave variable consistency; identifies stable 172-variable core |
| `03_aggregation.ipynb` | Weighted aggregations → 5 summary CSVs for Processing |
| `04_visualisation_exploration.ipynb` | Exploratory chart options for each story (2–3 options each); saves figures to `outputs/figures/` |

Notebooks produce **pre-aggregated summary CSVs** in `outputs/tables/` — one per visualisation story. All aggregation, weighting, and derived indicator construction happens in Python. The Processing sketches receive clean numbers only and handle rendering only.

## Five Visualisation Stories

| # | Title | Output CSV columns |
|---|---|---|
| 1 | UK posture over 8 years (trends) | `year, governance_score_A, governance_score_B, breach_pct, participant_count` |
| 2 | Board priority vs outcomes (by org size) | `year, org_size, org_size_order, board_priority_pct, board_priority_mean_norm` |
| 3 | Policy → management → breach pathway | `has_policy, actively_managed, breached, weighted_n, proportion` |
| 4 | Technical controls adoption | `year, ce_adoption_pct, ten_steps_pct, breach_nonadopter_pct` |
| 5 | Governance score vs breach (segmented) | `year, org_size, org_size_order, governance_score_A, governance_score_B, breach_pct, org_count` |

Each CSV has a corresponding `story{n}_README.md` in `outputs/tables/` documenting all variables.

> The "four poster narratives" reference in older notebooks is outdated. There are five stories.

## Weighting Rules

All aggregations must use **weighted percentages** (the `weight` variable) to produce nationally representative estimates. Unweighted figures must not be used in outputs.

**Critical pre-weighting filters — apply before every aggregation:**
1. Exclude routing/missing values: drop rows where the target variable is `-1`, `-97`, or `-99`.
2. For `priority` and `type11` specifically, use **valid-value whitelisting** rather than missing-code blacklisting — the 2025 wave uses `997` for DK at `priority` and `-9` at `type11`, which are not in the standard missing codes. Whitelist: `priority` → `{1,2,3,4}`; `type11` → `{0,1}`.
3. Only then apply weights and compute percentages.

Failure to do this inflates breach prevalence from ~49.6% (correct) to >95% (wrong) — confirmed data quality issue from A2 report.

### Key Data Conventions
- **Missing value codes** (negative integers, not NaN): `-1` = not applicable/routing, `-97` = don't know/refused, `-99` = other missing. Always filter/handle these before analysis.
- **Column normalisation** (applied in notebook 02): strip whitespace, remove BOM (`\ufeff`), lowercase. Use `normalise_columns()` pattern when loading raw files.
- **`year` column** is a synthetic derived field added during load — exclude it from variable intersection/core computations.
- **`sector_comb2`** has a coding change between 2023 and 2024 waves — non-business respondents are `-1` in 2024/2025 vs blank string in earlier waves.
- **`sizeb`** codes: 1=Micro (<10), 2=Small (10–49), 3=Medium (50–249), 4=Large (250+). Only meaningful for `samptype == 1` (businesses).
- **`samptype`** codes: 1=Business, 2=Charity, 3=Education.
- **`priority`** (Q9): ordinal 4-point scale. 1=Very high, 2=Fairly high, 3=Fairly low, 4=Very low. **Lower code = higher priority.**
- **`type11`**: "None of these" at Q53A. `type11 == 0` = experienced a breach. `type11 == 1` = no breach. Stable across all 8 waves.
- **Policy routing**: `policy1`–`policy5` are `-1` (routing) when `manage3 == 0` (no formal policy). Treat routing `-1` as 0 for composite scoring.
- **`trained`** (cybersecurity training) only exists in waves 2021–2025.
- **`typex`**: business classification question (profit-seeking/social enterprise/charity). Not a breach flag.

### Stable Longitudinal Core
172 variables are present and consistently named across all 8 waves. Key stable families:
- Segmentation: `samptype`, `sizeb`, `sector_comb2`, `weight`
- Governance: `priority`, `manage1/2/3/4/6/7` (6 vars), `policy1/2/3/4/5/8/9` (7 vars)
- Controls: `step1`–`step10`, `any10steps`, `sum10steps`, `allessentials`
- Breach types: `type1`–`type12`, `typex` (13 stable; later waves add more)
- Reporting: `reporta`, `reportb1`–`reportb24` subset (21 stable vars)
