# Processing.org Visualisation Specification
## ICL-3006 — Node9 Cyber Security Infographic Series
### CSBS 2018–2025 | Five-Part LinkedIn Infographic Series

---

## Project Overview

This document defines the complete specification for five static infographics built in Processing.org. Each infographic is one story in a series published on Node9 Consulting's LinkedIn company page. The target audience is SME decision-makers, IT leads, and business owners who lack specialist cyber security expertise.

All data comes from the UK Cyber Security Breaches Survey (CSBS), 2018–2025, published by DSIT and the Home Office. Data is pre-aggregated and weighted in Python/Jupyter before being passed to Processing as clean CSV files.

---

## Global Design Specification

### Format
- Output: PNG static image
- Dimensions: 3508 x 2480px (A4 landscape at 300dpi)
- Background: `#FAFAFA`
- Font: Use a clean sans-serif — Processing default or loaded .ttf

### Colour System — IBM Colour Blind Safe Palette
These colours are fixed and must be used consistently across all five sketches:

| Concept | Hex | Usage |
|---|---|---|
| Breach prevalence | `#DC267F` | Wherever breach data appears |
| Governance | `#648FFF` | Wherever governance/board priority appears |
| Policy | `#785EF0` | Wherever policy data appears |
| Controls | `#FE6100` | Wherever CE/10 Steps data appears |
| Text / axes | `#1A1A2E` | All labels, axis lines, annotations |
| Background | `#FAFAFA` | All chart backgrounds |
| Neutral / no data | `#CCCCCC` | No policy, unclassified segments |

### Pattern Fills — Secondary Accessibility Encoding
Pattern fills must be applied IN ADDITION to colour, not instead of it. Use clipped repeating shapes drawn within the bounds of bars, areas, or bubbles.

| Organisation Size | Pattern | Code approach |
|---|---|---|
| Micro | Diagonal lines `////` | Repeating angled lines at 45 degrees |
| Small | Dots `....` | Repeating small ellipses on grid |
| Medium | Crosshatch `####` | Repeating horizontal + vertical lines |
| Large | Horizontal lines `----` | Repeating horizontal lines |

### Typography
- Chart headlines: Large, bold, dark charcoal `#1A1A2E`
- Axis labels: Medium weight, `#1A1A2E`
- Annotations: Smaller, coloured to match relevant data series
- Source footer: Small, `#888888`
- Bold callout numbers: Very large, coloured to match relevant data series

### Methodology Change Markers
- Mark 2021 and 2024 on all time series charts
- Use dashed vertical line in `#1A1A2E` at 30% opacity
- Add asterisk to X axis label
- Add footnote: `* methodology change — interpret with caution`

---

## Data Pipeline

All data preparation happens in Python/Jupyter notebooks BEFORE Processing.
Processing.org only handles rendering — no computation, no weighting, no filtering.

### Loading data in Processing
```java
Table data;
data = loadTable("filename.csv", "header");
```

### Excluded values (handled in Python, not Processing)
- Routing values: -1, -9
- Non-substantive: 997 (don't know), 999 (refused)
- All percentages are weighted population estimates

---

## Story 1 — Overview: Bar and Line Combo

**Insight question:** "UK cyber security posture has changed over 8 years — here's what the data shows"

### CSV specification
Filename: `story1_overview.csv`

| Column | Type | Description |
|---|---|---|
| year | int | Survey wave year 2018–2025 |
| governance_pct | float | Weighted % with governance maturity composite |
| breach_pct | float | Weighted % experiencing at least one breach |
| participant_count | int | Raw number of survey respondents that wave |

### Chart specification
- Two bars per year cluster: governance_pct and breach_pct
- Bar 1: `#648FFF` blue with horizontal line pattern
- Bar 2: `#DC267F` magenta with diagonal line pattern
- Line overlay: participant_count mapped to right Y axis — `#1A1A2E` dashed
- Y axis left: 0–100% label "% of organisations"
- Y axis right: participant count label "survey participants"
- X axis: years 2018–2025

### Key annotations
- Bracket highlighting gap between bars in 2025: *"Governance has improved — breach prevalence hasn't fallen to match"*
- Bold callout: *"50% of UK organisations breached in 2025"* (replace with actual value)
- Asterisk markers at 2021 and 2024

### Processing implementation notes
```java
// Bar drawing
rect(x, y, barWidth, barHeight); // repeat for each year, each metric

// Pattern fill — horizontal lines for governance bars
for (int i = y; i < y + barHeight; i += patternSpacing) {
  line(x, i, x + barWidth, i);
}

// Pattern fill — diagonal lines for breach bars
for (int i = -barHeight; i < barWidth; i += patternSpacing) {
  line(x + i, y, x + i + barHeight, y + barHeight);
}

// Participant line
for (int i = 0; i < years.length - 1; i++) {
  line(xPos[i], map(participants[i], minP, maxP, bottomY, topY),
       xPos[i+1], map(participants[i+1], minP, maxP, bottomY, topY));
}
```

---

## Story 2 — Governance Priority: Slope Chart

**Insight question:** "Do organisations that treat cyber security as a board priority see different outcomes?"

### CSV specification
Filename: `story2_governance.csv`

| Column | Type | Description |
|---|---|---|
| year | int | Survey wave year — filter to 2018 and 2025 only |
| org_size | string | micro / small / medium / large |
| board_priority_pct | float | Weighted % where cyber security is a board priority |

### Chart specification
- Two vertical axes: left = 2018 values, right = 2025 values
- Four slope lines, one per org_size
- Colours: Micro `#DC267F`, Small `#FE6100`, Medium `#648FFF`, Large `#785EF0`
- Pattern fill dots at each endpoint matching org size pattern
- Line thickness proportional to org_count
- Secondary breach prevalence slope line in `#DC267F` dashed

### Key annotations
- Label steepest upward slope: *"Biggest improvement"* with `+X%` callout
- Label flattest slope: *"Least progress"*
- Bold callout number: largest percentage point change

### Processing implementation notes
```java
// Slope line per org size
line(leftAxisX, map(val2018, 0, 100, bottomY, topY),
     rightAxisX, map(val2025, 0, 100, bottomY, topY));

// Endpoint circles with pattern fill
ellipse(leftAxisX, yPos2018, dotSize, dotSize);
// apply pattern fill clipped to circle bounds

// Line weight mapped to org count
strokeWeight(map(orgCount, minCount, maxCount, 1, 6));
```

---

## Story 3 — Policy & Management: Sankey Diagram

**Insight question:** "Is having a policy enough, or is it what you do with it that matters?"

### CSV specification
Filename: `story3_policy.csv`

| Column | Type | Description |
|---|---|---|
| has_policy | int | 1 = has policy, 0 = no policy |
| actively_managed | int | 1 = actively managed, 0 = not managed |
| breached | int | 1 = breached, 0 = not breached |
| proportion | float | Weighted proportion of organisations on this pathway |

### Chart specification
- Three columns left to right: Policy Status → Management Activity → Breach Outcome
- Node colours:
  - Has Policy: `#785EF0` purple
  - No Policy: `#CCCCCC` grey
  - Actively Managed: `#785EF0` purple
  - Not Managed: `#785EF0` at 30% opacity
  - Breached: `#DC267F` magenta
  - Not Breached: `#648FFF` blue
- Flow width proportional to proportion value
- Flow colour transitions from source to destination using lerpColor()
- Flows at 40% opacity

### Key annotations
- Bold plain language headline ABOVE chart: *"Having a policy isn't enough — what you do with it is what matters"*
- Label widest flow to Breached: *"Highest risk pathway"*
- Label widest flow to Not Breached: *"Lowest risk pathway"*
- How to read: *"wider flow = more organisations following that pathway"*

### Processing implementation notes
```java
// Bezier flow between nodes
beginShape();
vertex(sourceX + nodeWidth, sourceYMid);
bezierVertex(
  sourceX + nodeWidth + controlOffset, sourceYMid,
  destX - controlOffset, destYMid,
  destX, destYMid
);
// close shape for filled flow
endShape();

// Colour transition along flow
color flowColor = lerpColor(sourceColor, destColor, 0.5);
fill(red(flowColor), green(flowColor), blue(flowColor), 100); // 40% opacity
```

---

## Story 4 — Technical Controls: Area Chart

**Insight question:** "Does Cyber Essentials adoption tell a story about organisational readiness?"

### CSV specification
Filename: `story4_controls.csv`

| Column | Type | Description |
|---|---|---|
| year | int | Survey wave year 2018–2025 |
| ce_adoption_pct | float | Weighted % with Cyber Essentials |
| ten_steps_pct | float | Weighted % implementing 10 Steps |
| breach_nonadopter_pct | float | Weighted % breach prevalence among non-adopters |

### Chart specification
- Area 1 bottom: ce_adoption_pct — `#FE6100` orange with dot pattern at 40% opacity
- Area 2 stacked: ten_steps_pct added to ce_adoption_pct — `#FE6100` at 60% opacity with crosshatch
- Dashed line: breach_nonadopter_pct — `#DC267F` magenta dashed, 2px weight
- Shaded protection gap band between stacked area top and breach line — `#DC267F` at 10% opacity
- Methodology change markers at 2021 and 2024

### Key annotations
- Label shaded band: *"Protection gap — non-adopters remain consistently exposed"*
- Bold callout: *"X% of UK organisations have Cyber Essentials in 2025"*
- Second annotation on growth trend: *"Adoption growing — but the gap persists"*

### Processing implementation notes
```java
// Area 1 — Cyber Essentials
beginShape();
for (int i = 0; i < years.length; i++) {
  vertex(xPos[i], map(ce_pct[i], 0, 100, bottomY, topY));
}
vertex(xPos[years.length-1], bottomY);
vertex(xPos[0], bottomY);
endShape(CLOSE);

// Area 2 — stacked 10 Steps
beginShape();
for (int i = 0; i < years.length; i++) {
  vertex(xPos[i], map(ce_pct[i] + ten_pct[i], 0, 100, bottomY, topY));
}
// trace back along Area 1 top
for (int i = years.length-1; i >= 0; i--) {
  vertex(xPos[i], map(ce_pct[i], 0, 100, bottomY, topY));
}
endShape(CLOSE);

// Protection gap band
beginShape();
for (int i = 0; i < years.length; i++) {
  vertex(xPos[i], map(breach_pct[i], 0, 100, bottomY, topY));
}
for (int i = years.length-1; i >= 0; i--) {
  vertex(xPos[i], map(ce_pct[i] + ten_pct[i], 0, 100, bottomY, topY));
}
endShape(CLOSE);
```

---

## Story 5 — Incident Experience: Bubble Chart

**Insight question:** "Who gets breached — and does governance change that?"

### CSV specification
Filename: `story5_incidents.csv`

| Column | Type | Description |
|---|---|---|
| year | int | Survey wave year 2018–2025 |
| org_size | string | micro / small / medium / large |
| governance_score | float | Composite governance maturity score 0–100 |
| breach_pct | float | Weighted % experiencing at least one breach |
| org_count | int | Weighted count of organisations in this segment |

### Chart specification
- X axis: governance_score (0–100) label "Governance Maturity →"
- Y axis: breach_pct (0–100%) label "Breach Prevalence % →"
- Bubble size: proportional to org_count using square root scaling
- Bubble colours with pattern fills:
  - Micro: `#DC267F` magenta, diagonal `////`
  - Small: `#FE6100` orange, dots `....`
  - Medium: `#648FFF` blue, crosshatch `####`
  - Large: `#785EF0` purple, horizontal `----`
- Bubble opacity: 50%
- Trail lines connecting same org_size bubbles across years — `#1A1A2E` at 20% opacity
- Year label at edge of each bubble — small charcoal text
- Diagonal reference band top-left to bottom-right — `#CCCCCC` at 15% opacity

### Key annotations
- Label reference band: *"Expected relationship — stronger governance, fewer breaches"*
- Arrow to bubbles above band: *"High governance but still breached"*
- Arrow to bubbles tracking bottom-right: *"Improving — governance up, breaches down"*
- Bold callout: *"Micro organisations X% more likely to be breached"*
- Legend box: bubble size = org count, position = governance vs breach, colour/pattern = org size, trails = movement over time

### Processing implementation notes
```java
// Square root bubble scaling
float bubbleRadius = map(sqrt(orgCount), sqrt(minCount), sqrt(maxCount), minRadius, maxRadius);

// Draw trail lines first (lowest layer)
for (int i = 0; i < years.length - 1; i++) {
  stroke(26, 26, 46, 50); // #1A1A2E at 20% opacity
  line(xPos[i], yPos[i], xPos[i+1], yPos[i+1]);
}

// Draw bubbles (middle layer)
fill(r, g, b, 127); // 50% opacity
ellipse(xPos, yPos, bubbleRadius*2, bubbleRadius*2);

// Apply pattern fill clipped to bubble bounds
// Draw pattern shapes only where they intersect the circle

// Draw year labels (top layer)
fill(26, 26, 46);
textSize(18);
text(year, xPos + bubbleRadius + 5, yPos);

// Reference band
fill(204, 204, 204, 38); // #CCCCCC at 15% opacity
noStroke();
quad(leftX, topY, rightX, topY - bandHeight,
     rightX, bottomY, leftX, bottomY + bandHeight);
```

---

## Pattern Fill Helper Function

Use this reusable function for all pattern fills. Call before drawing each shape, then clip using Processing's graphics masking or draw patterns within computed bounds.

```java
void drawPatternFill(String patternType, float x, float y, float w, float h, color c) {
  stroke(c);
  strokeWeight(1.5);
  noFill();

  if (patternType.equals("diagonal")) {
    // Micro — diagonal lines ////
    for (float i = x - h; i < x + w; i += 8) {
      line(i, y + h, i + h, y);
    }
  } else if (patternType.equals("dots")) {
    // Small — dots ....
    for (float px = x + 4; px < x + w; px += 8) {
      for (float py = y + 4; py < y + h; py += 8) {
        ellipse(px, py, 3, 3);
      }
    }
  } else if (patternType.equals("crosshatch")) {
    // Medium — crosshatch ####
    for (float i = y; i < y + h; i += 8) {
      line(x, i, x + w, i);
    }
    for (float i = x; i < x + w; i += 8) {
      line(i, y, i, y + h);
    }
  } else if (patternType.equals("horizontal")) {
    // Large — horizontal lines ----
    for (float i = y; i < y + h; i += 8) {
      line(x, i, x + w, i);
    }
  }
}
```

---

## Export Specification

All sketches must export as PNG at full resolution:

```java
void setup() {
  size(3508, 2480);
  // draw chart
  save("story1_overview.png");
  exit();
}
```

Alternatively use `saveFrame()` for a single frame export.

---

## File Structure

```
project/
├── data_processed/
│   ├── story1_overview.csv
│   ├── story2_governance.csv
│   ├── story3_policy.csv
│   ├── story4_controls.csv
│   └── story5_incidents.csv
├── processing_sketches/
│   ├── story1_overview/
│   │   └── story1_overview.pde
│   ├── story2_governance/
│   │   └── story2_governance.pde
│   ├── story3_policy/
│   │   └── story3_policy.pde
│   ├── story4_controls/
│   │   └── story4_controls.pde
│   └── story5_incidents/
│       └── story5_incidents.pde
└── outputs/
    ├── story1_overview.png
    ├── story2_governance.png
    ├── story3_policy.png
    ├── story4_controls.png
    └── story5_incidents.png
```

---

## Academic Notes for A6 Report

When writing the Visualisation Report (A6), reference this specification document as evidence of implementation planning. Key points to address:

- Weighted percentages justify population-level claims about UK organisations
- IBM colour blind safe palette addresses accessibility requirement
- Pattern fills provide dual encoding for colour blind users
- Progressive disclosure narrative (simple → complex) is a deliberate design decision
- Pre-aggregated CSVs maintain separation between analytical work (ICL-3005) and visualisation work (ICL-3006)
- Square root bubble scaling in Story 5 prevents large organisations dominating visual space disproportionately
- All charts are static — no interactivity — appropriate for LinkedIn consumption context

*Dataset: UK Cyber Security Breaches Survey (CSBS), DSIT / Home Office, 2018–2025, Open Government Licence v3.0*