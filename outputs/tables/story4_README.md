# Story 4 — Control Adoption Over Time: Variable Definitions

## File: `story4_control_adoption.csv`

**Scope:** All org types. All percentages are weighted.

---

### `year`
Survey wave (2018–2025).

---

### `ce_adoption_pct`
Weighted proportion of organisations that have achieved **Cyber Essentials** certification or equivalent (`allessentials == 1`).

Source: derived variable `allessentials` — present and stable across all 8 waves.

---

### `ten_steps_pct`
Weighted proportion of organisations that have implemented **any** of the 10 Steps to Cyber Security (`any10steps == 1`).

Source: derived variable `any10steps` — present and stable across all 8 waves.

Note: `any10steps` is a low bar (at least one of the 10 steps adopted). For depth of adoption, see `sum10steps` in the raw data.

---

### `breach_nonadopter_pct`
Weighted breach rate among organisations that have adopted **neither** Cyber Essentials (`allessentials == 0`) **nor** any of the 10 Steps (`any10steps == 0`).

This is the overlay line for the visualisation: it shows how the breach risk among the least-protected organisations changes over time, independent of the adoption trend lines.
