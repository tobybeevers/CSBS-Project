# Story 1 — UK Posture Trends: Variable Definitions

## File: `story1_uk_posture_trends.csv`

### `breach_pct`
Weighted proportion of organisations that experienced at least one cyber breach or attack in the past 12 months. Derived from `type11 == 0` (where `type11 = 1` means "None of these" at Q53A). A value of `0.32` means 32% of the weighted population reported a breach that year.

---

### `governance_score_A` — Binary sum composite

For each respondent, a score out of 10 is computed by summing the following binary indicators:

| Indicator | Source | Max points |
|---|---|---|
| Board rates cyber as Very/Fairly high priority | `priority <= 2` | 1 |
| Board/senior manager with cyber responsibility | `manage1 == 1` | 1 |
| Outsourced provider managing cyber security | `manage2 == 1` | 1 |
| Formal cyber security policy in place | `manage3 == 1` | 1 |
| Business continuity plan covers cyber | `manage4 == 1` | 1 |
| Policy covers removable devices | `policy1 == 1` | 1 |
| Policy covers remote/mobile working | `policy2 == 1` | 1 |
| Policy covers permitted use of IT devices | `policy3 == 1` | 1 |
| Policy covers personally-owned devices | `policy4 == 1` | 1 |
| Policy covers cloud computing | `policy5 == 1` | 1 |

Raw score (0–10) is divided by 10 to give a 0–1 value per respondent. `governance_score_A` is the weighted mean of those respondent-level scores across the year.

**Implicit assumption:** all 10 indicators are equally important.

---

### `governance_score_B` — Three-component average

Instead of treating all indicators equally, this gives equal weight to three governance *dimensions*, each scored 0–1:

| Component | Calculation |
|---|---|
| **Priority** | `(4 − priority) / 3` → Very high = 1.0, Fairly high = 0.667, Fairly low = 0.333, Very low = 0.0 |
| **Management** | Proportion of `manage1–4` present (0–4 positives ÷ 4) |
| **Policy coverage** | Proportion of `policy1–5` present (0–5 positives ÷ 5). Orgs without a policy score 0 on all items. |

Respondent score = average of the three components. `governance_score_B` is the weighted mean across the year.

**Key difference from Score A:** in Score A, policy dominates (5 of 10 points). In Score B, priority, management, and policy each contribute one third regardless of how many items each contains. Score B is more sensitive to shifts in board-level priority; Score A is more sensitive to policy coverage breadth.

---

### `participant_count`
Unweighted number of survey respondents in that wave (all org types combined).
