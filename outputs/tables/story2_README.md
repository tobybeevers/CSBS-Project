# Story 2 — Board Priority by Org Size: Variable Definitions

## File: `story2_board_priority_by_size.csv`

**Scope:** Businesses only (`samptype == 1`). Excludes charities and education institutions as `sizeb` is not meaningful for them.

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

### `board_priority_pct`
Weighted proportion of businesses in this size band and year where senior management rates cyber security as **Very high** or **Fairly high** priority (`priority` = 1 or 2). This is the binary version of the priority indicator.

A value of `0.75` means 75% of that size band's weighted population rated cyber as a high priority.

---

### `board_priority_mean_norm`
Weighted mean of priority normalised to a 0–1 scale using `(4 − priority) / 3`:

| Raw `priority` | Label | Normalised value |
|---|---|---|
| 1 | Very high | 1.000 |
| 2 | Fairly high | 0.667 |
| 3 | Fairly low | 0.333 |
| 4 | Very low | 0.000 |

This is the continuous alternative to `board_priority_pct`. A higher value means higher average priority. Use this if you want to show gradual shifts rather than a threshold-based proportion.
