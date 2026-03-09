# Story 3 — Pathway Analysis: Variable Definitions

## File: `story3_pathway_analysis.csv`

**Scope:** All org types, all years pooled. Respondents with missing/routing values on any of the three pathway variables are excluded.

This file represents a weighted contingency table across three binary governance/outcome stages. It is designed for a Sankey or flow diagram showing how organisations move from policy adoption through active management to breach outcome.

---

### `has_policy`
Whether the organisation has a formal cyber security policy in place.
- `1` = Yes (`manage3 == 1`)
- `0` = No (`manage3 == 0`)

Source: Q29 "Which governance arrangements do you have in place? — A formal policy or policies covering cyber security risks."

---

### `actively_managed`
Whether a board member or senior manager has personal responsibility for cyber security.
- `1` = Yes (`manage1 == 1`)
- `0` = No (`manage1 == 0`)

Source: Q29 "— Board members/trustees/a governor or senior manager with responsibility for cyber security."

Note: this is defined independently of `has_policy`. An organisation can have board ownership without a formal policy, and vice versa.

---

### `breached`
Whether the organisation experienced at least one cyber breach or attack in the past 12 months.
- `1` = Yes (`type11 == 0`)
- `0` = No (`type11 == 1`)

Source: Q53A "Have any of the following happened to your organisation in the last 12 months?" — "None of these" not selected.

---

### `weighted_n`
Sum of survey weights for respondents in this combination of the three flags. Represents the estimated number of organisations in the UK population in this pathway cell (all years pooled).

### `proportion`
`weighted_n` divided by the total weighted population across all 8 pathway cells. Sums to 1.0 across all rows. Use this as the flow volume for Sankey rendering.
