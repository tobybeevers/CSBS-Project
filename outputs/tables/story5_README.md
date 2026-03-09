# Story 5 — Governance Score vs Breach by Org Size: Variable Definitions

## File: `story5_governance_vs_breach_size.csv`

**Scope:** Businesses only (`samptype == 1`). Excludes charities and education institutions as `sizeb` is not meaningful for them. All percentages are weighted.

---

### `year`
Survey wave (2018–2025).

### `org_size`
Business size band label derived from `sizeb`:

| `org_size_order` | `org_size` | Employee range |
|---|---|---|
| 1 | Micro | Under 10 |
| 2 | Small | 10–49 |
| 3 | Medium | 50–249 |
| 4 | Large | 250+ |

### `org_size_order`
Numeric sort key for `org_size` (1–4). Use this for ordering in visualisations.

---

### `governance_score_A` — Binary sum composite
Weighted mean of the respondent-level binary governance score for this size band and year. Score is computed as the sum of 10 binary governance indicators divided by 10 (range 0–1):
- 1 pt: `priority <= 2` (high/fairly high priority)
- 4 pts max: `manage1–4` (governance arrangements in place)
- 5 pts max: `policy1–5` (policy coverage areas)

See `story1_README.md` for full indicator definitions.

---

### `governance_score_B` — Three-component average
Weighted mean of the respondent-level continuous governance score for this size band and year. Computed as the average of three equally-weighted components (each 0–1):
- Priority normalised: `(4 − priority) / 3`
- Management proportion: share of `manage1–4` present
- Policy proportion: share of `policy1–5` present (orgs without a policy score 0)

See `story1_README.md` for full details and the key difference between Score A and Score B.

---

### `breach_pct`
Weighted proportion of businesses in this size band and year that experienced at least one cyber breach or attack (`type11 == 0`).

---

### `org_count`
Unweighted number of business respondents in this size band and year. Use as a confidence indicator — cells with low `org_count` should be interpreted cautiously.
