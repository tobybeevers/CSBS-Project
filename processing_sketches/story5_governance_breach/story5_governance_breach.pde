// =============================================================================
// Story 5 — Governance Score vs Breach Prevalence by Org Size
// Node9 Consulting | CSBS Infographic Series
// Canvas: A4 landscape, 3508 × 2480 px @ 300 dpi  |  Small multiples 2×2
//
// Each panel shows one org size — 8 bubbles (one per wave 2018–2025)
// connected by a graduated trail. Shared axes enable cross-panel comparison.
//
// Data source: outputs/tables/story5_governance_vs_breach_size.csv
// =============================================================================

// --- Colour palette (IBM colour-blind safe) ---
final color BG       = #FAFAFA;
final color C_MICRO  = #DC267F;
final color C_SMALL  = #FE6100;
final color C_MEDIUM = #648FFF;
final color C_LARGE  = #785EF0;
final color C_TEXT   = #1A1A2E;
final color C_GRID   = #CCCCCC;

// --- Data (governance_score_B, breach_pct, org_count  2018–2025) ---
final int N = 8;
final int[] YEARS = { 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025 };

final float[] GOV_MICRO  = { 0.358, 0.402, 0.421, 0.389, 0.390, 0.370, 0.385, 0.377 };
final float[] BRE_MICRO  = { 0.403, 0.278, 0.436, 0.380, 0.366, 0.329, 0.482, 0.420 };
final int[]   CNT_MICRO  = { 655, 770, 644, 746, 698, 1411, 1060, 1014 };

final float[] GOV_SMALL  = { 0.479, 0.520, 0.583, 0.556, 0.492, 0.504, 0.506, 0.582 };
final float[] BRE_SMALL  = { 0.475, 0.413, 0.617, 0.396, 0.505, 0.336, 0.588, 0.511 };
final int[]   CNT_SMALL  = { 349, 330, 286, 275, 272, 456, 506, 565 };

final float[] GOV_MED    = { 0.597, 0.662, 0.678, 0.674, 0.593, 0.618, 0.665, 0.674 };
final float[] BRE_MED    = { 0.644, 0.441, 0.695, 0.625, 0.619, 0.541, 0.739, 0.681 };
final int[]   CNT_MED    = { 263, 301, 223, 219, 154, 310, 264, 413 };

final float[] GOV_LARGE  = { 0.688, 0.765, 0.685, 0.696, 0.733, 0.745, 0.709, 0.802 };
final float[] BRE_LARGE  = { 0.758, 0.464, 0.759, 0.729, 0.586, 0.707, 0.813, 0.796 };
final int[]   CNT_LARGE  = { 252, 214, 221, 208, 141, 236, 170, 188 };

// --- Per-panel axis ranges (zoomed to each group's data + padding) ---
// Order: [Micro, Small, Medium, Large]
final float[] XMIN_P = { 0.30, 0.42, 0.52, 0.62 };
final float[] XMAX_P = { 0.47, 0.64, 0.73, 0.85 };
final float[] YMIN_P = { 0.22, 0.28, 0.38, 0.42 };
final float[] YMAX_P = { 0.55, 0.68, 0.78, 0.86 };

// --- Bubble sizing ---
final float R_MIN  = 20,  R_MAX  = 65;
final float SQ_MIN = sqrt(141), SQ_MAX = sqrt(1411);

// --- Panel layout (computed in setup) ---
float PW, PH;           // outer panel width / height
float P_CW, P_CH;       // chart area within each panel
float PANEL_LX, PANEL_RX, PANEL_TY, PANEL_BY;  // panel origins

// --- Current panel chart area + axis ranges (set by setPanel) ---
float PCX, PCY, PCW, PCH, PCR, PCB;
float PX_MIN, PX_MAX, PY_MIN, PY_MAX;

boolean isFull;

// =============================================================================
void setup() {
  size(3508, 2480);
  noLoop();
}

void draw() {
  setupFull();
  background(BG);
  drawTitle();
  drawAllPanels();
  drawSharedAxisTitles();
  drawFooter();
  save("../../outputs/figures/processing.org outputs/story5_governance_breach_full.png");
  println("Saved: story5_governance_breach_full.png");

  setupChart();
  background(BG);
  drawAllPanels();
  drawSharedAxisTitles();
  save("../../outputs/figures/processing.org outputs/story5_governance_breach_chart.png");
  println("Saved: story5_governance_breach_chart.png");

  exit();
}

// =============================================================================
// LAYOUT SETUP
// =============================================================================
void setupFull() {
  isFull = true;
  float margin = 100, gapH = 80, gapV = 60;
  float titleH = 350, footerH = 80;
  PW = (3508 - 2*margin - gapH) / 2;
  PH = (2480 - titleH - footerH - gapV) / 2;
  PANEL_LX = margin;
  PANEL_RX = margin + PW + gapH;
  PANEL_TY = titleH;
  PANEL_BY = titleH + PH + gapV;
  P_CW = PW - 210 - 50;   // chart width inside panel (minus y-label space + right pad)
  P_CH = PH - 80 - 110;   // chart height inside panel (minus panel title + x-label space)
}

void setupChart() {
  isFull = false;
  float margin = 100, gapH = 80, gapV = 60;
  float topMargin = 80, bottomMargin = 80;
  PW = (3508 - 2*margin - gapH) / 2;
  PH = (2480 - topMargin - bottomMargin - gapV) / 2;
  PANEL_LX = margin;
  PANEL_RX = margin + PW + gapH;
  PANEL_TY = topMargin;
  PANEL_BY = topMargin + PH + gapV;
  P_CW = PW - 210 - 50;
  P_CH = PH - 80 - 110;
}

// =============================================================================
// PANEL COORD HELPERS  (use current panel globals set by setPanel)
// =============================================================================
void setPanel(float cx, float cy, float cw, float ch, int pIdx) {
  PCX = cx; PCY = cy; PCW = cw; PCH = ch;
  PCR = cx + cw; PCB = cy + ch;
  PX_MIN = XMIN_P[pIdx]; PX_MAX = XMAX_P[pIdx];
  PY_MIN = YMIN_P[pIdx]; PY_MAX = YMAX_P[pIdx];
}

float xGp(float gov) { return map(gov, PX_MIN, PX_MAX, PCX, PCR); }
float yBp(float bre) { return map(bre, PY_MIN, PY_MAX, PCB, PCY); }
float bubbleR(int n)  { return map(sqrt(n), SQ_MIN, SQ_MAX, R_MIN, R_MAX); }

// =============================================================================
// DRAW ALL PANELS
// =============================================================================
void drawAllPanels() {
  drawPanel(GOV_MICRO, BRE_MICRO, CNT_MICRO, C_MICRO,  0, "Micro",  "<10 employees",
            PANEL_LX, PANEL_TY, true,  false, 0);
  drawPanel(GOV_SMALL, BRE_SMALL, CNT_SMALL, C_SMALL,  1, "Small",  "10–49 employees",
            PANEL_RX, PANEL_TY, false, false, 1);
  drawPanel(GOV_MED,   BRE_MED,   CNT_MED,   C_MEDIUM, 2, "Medium", "50–249 employees",
            PANEL_LX, PANEL_BY, true,  true,  2);
  drawPanel(GOV_LARGE, BRE_LARGE, CNT_LARGE, C_LARGE,  3, "Large",  "250+ employees",
            PANEL_RX, PANEL_BY, false, true,  3);
}

// px, py = outer top-left corner of the panel
// showYLabels = left column panels only  |  showXLabels = bottom row panels only
void drawPanel(float[] gov, float[] bre, int[] cnt, color c, int sizeIdx,
               String sizeName, String sizeDesc,
               float px, float py, boolean showYLabels, boolean showXLabels,
               int pIdx) {

  // --- Chart area origin within this panel ---
  float cx = px + 210;
  float cy = py + 80;
  setPanel(cx, cy, P_CW, P_CH, pIdx);

  // --- Panel background card ---
  noStroke();
  fill(248);
  rect(px, py, PW, PH, 6);

  // --- Panel title (size name left, employee count right) ---
  textAlign(LEFT, CENTER);
  textSize(isFull ? 52 : 58);
  fill(red(c), green(c), blue(c), 230);
  text(sizeName, px + 55, py + 26);
  textAlign(RIGHT, CENTER);
  textSize(isFull ? 36 : 40);
  fill(C_TEXT, 140);
  text(sizeDesc, px + PW - 18, py + 26);

  // --- Grid ---
  drawPanelGrid();

  // --- Trail then bubbles ---
  drawPanelTrail(gov, bre, c);
  drawPanelBubbles(gov, bre, cnt, c, sizeIdx);

  // --- Axes ---
  drawPanelAxes();
}

// =============================================================================
// GRID  (labels on every panel; min/max ticks larger to highlight scale diff)
// =============================================================================
void drawPanelGrid() {
  float tsNorm    = isFull ? 32 : 36;   // inner tick label size
  float tsExtreme = isFull ? 40 : 44;   // min/max tick label size (emphasised)

  // Vertical lines + X tick labels (below chart, every panel)
  float xStep = (PX_MAX - PX_MIN) / 4.0;
  for (int ti = 0; ti <= 4; ti++) {
    float g = PX_MIN + ti * xStep;
    stroke(C_GRID);
    strokeWeight(1.2);
    line(xGp(g), PCY, xGp(g), PCB);
    noStroke();
    if (ti == 0) continue;   // skip leftmost X label — clashes with bottom Y label at corner
    boolean extreme = (ti == 4);
    textSize(extreme ? tsExtreme : tsNorm);
    fill(C_TEXT, extreme ? 200 : 120);
    textAlign(CENTER, TOP);
    String lbl = int(round(g*100)) + "%";
    if (extreme) text(lbl, xGp(g) + 1, PCB + 10);
    text(lbl, xGp(g), PCB + 10);
  }

  // Horizontal lines + Y tick labels (left of chart, every panel)
  float yStep = (PY_MAX - PY_MIN) / 4.0;
  for (int ti = 0; ti <= 4; ti++) {
    float b = PY_MIN + ti * yStep;
    stroke(C_GRID);
    strokeWeight(1.2);
    line(PCX, yBp(b), PCR, yBp(b));
    noStroke();
    boolean extreme = (ti == 0 || ti == 4);
    textSize(extreme ? tsExtreme : tsNorm);
    fill(C_TEXT, extreme ? 200 : 120);
    textAlign(RIGHT, CENTER);
    String lbl = int(round(b*100)) + "%";
    if (extreme) text(lbl, PCX - 11, yBp(b));
    text(lbl, PCX - 12, yBp(b));
  }
  noStroke();
}

// =============================================================================
// TRAIL
// =============================================================================
void drawPanelTrail(float[] gov, float[] bre, color c) {
  for (int i = 0; i < N - 1; i++) {
    float a = map(i, 0, N-2, 50, 190);
    stroke(red(c), green(c), blue(c), a);
    strokeWeight(isFull ? 5 : 6);
    line(xGp(gov[i]), yBp(bre[i]), xGp(gov[i+1]), yBp(bre[i+1]));
  }
  // Arrowhead at 2025
  float ex = xGp(gov[N-1]), ey = yBp(bre[N-1]);
  float ang = atan2(ey - yBp(bre[N-2]), ex - xGp(gov[N-2]));
  noStroke();
  fill(red(c), green(c), blue(c), 210);
  pushMatrix();
  translate(ex, ey);
  rotate(ang);
  triangle(16, 0, -10, -8, -10, 8);
  popMatrix();
}

// =============================================================================
// BUBBLES + YEAR LABELS
// =============================================================================
void drawPanelBubbles(float[] gov, float[] bre, int[] cnt, color c, int sizeIdx) {
  for (int i = 0; i < N; i++) {
    float bx = xGp(gov[i]);
    float by = yBp(bre[i]);
    float br = bubbleR(cnt[i]);
    int   al = int(map(i, 0, N-1, 40, 210));  // graduated: ghost 2018 → solid 2025

    noStroke();
    fill(red(c), green(c), blue(c), al);
    ellipse(bx, by, br*2, br*2);

    drawCirclePattern(bx, by, br, sizeIdx, c, al);

    // Year label on every bubble
    textSize(isFull ? 30 : 34);
    textAlign(LEFT, CENTER);
    fill(C_TEXT, min(al + 70, 230));
    text("'" + nf(YEARS[i]-2000, 2), bx + br + 8, by);
  }
}

// =============================================================================
// CIRCLE PATTERN FILLS
// =============================================================================
void drawCirclePattern(float cx, float cy, float r, int sizeIdx, color c, int alpha) {
  color pc = lerpColor(c, color(255), 0.4);
  stroke(red(pc), green(pc), blue(pc), min(alpha + 40, 200));
  strokeWeight(1.8);

  if (sizeIdx == 0) {
    // Micro — diagonal ////
    for (float off = -r*2; off < r*2; off += 10) {
      float[] pts = circleLineClip(cx, cy, r, cx+off, cy+r, cx+off+r*2, cy-r*2);
      if (pts != null) line(pts[0], pts[1], pts[2], pts[3]);
    }
  } else if (sizeIdx == 1) {
    // Small — dots ....
    noStroke();
    fill(red(pc), green(pc), blue(pc), min(alpha + 40, 200));
    for (float px = cx-r+6; px < cx+r; px += 12) {
      for (float py = cy-r+6; py < cy+r; py += 12) {
        if (dist(px, py, cx, cy) < r-4) ellipse(px, py, 5, 5);
      }
    }
    stroke(red(pc), green(pc), blue(pc), min(alpha+40, 200));
    strokeWeight(1.8);
    noFill();
  } else if (sizeIdx == 2) {
    // Medium — crosshatch ####
    for (float off = -r; off < r; off += 10) {
      float[] h = circleLineClip(cx, cy, r, cx-r, cy+off, cx+r, cy+off);
      if (h != null) line(h[0], h[1], h[2], h[3]);
      float[] v = circleLineClip(cx, cy, r, cx+off, cy-r, cx+off, cy+r);
      if (v != null) line(v[0], v[1], v[2], v[3]);
    }
  } else {
    // Large — horizontal ----
    for (float off = -r+5; off < r; off += 10) {
      float[] h = circleLineClip(cx, cy, r, cx-r, cy+off, cx+r, cy+off);
      if (h != null) line(h[0], h[1], h[2], h[3]);
    }
  }
  noStroke();
}

float[] circleLineClip(float cx, float cy, float r,
                       float x1, float y1, float x2, float y2) {
  float dx=x2-x1, dy=y2-y1, fx=x1-cx, fy=y1-cy;
  float a=dx*dx+dy*dy, b=2*(fx*dx+fy*dy), c=fx*fx+fy*fy-r*r;
  float disc=b*b-4*a*c;
  if (disc<0) return null;
  float sq=sqrt(disc);
  float t0=max((-b-sq)/(2*a),0), t1=min((-b+sq)/(2*a),1);
  if (t0>t1) return null;
  return new float[]{x1+t0*dx, y1+t0*dy, x1+t1*dx, y1+t1*dy};
}

// =============================================================================
// PANEL AXES  (borders only — ticks drawn in grid)
// =============================================================================
void drawPanelAxes() {
  stroke(C_TEXT);
  strokeWeight(3);
  line(PCX, PCY, PCX, PCB);
  line(PCX, PCB, PCR, PCB);
  noStroke();
}

// =============================================================================
// SHARED AXIS TITLES  (drawn once, centred across the full grid)
// =============================================================================
void drawSharedAxisTitles() {
  float gridMidX = PANEL_LX + PW + (PANEL_RX - PANEL_LX - PW) / 2 + PW / 2;
  float gridMidY = PANEL_TY + PH + (PANEL_BY - PANEL_TY - PH) / 2 + PH / 2;

  // X axis title — below bottom panels
  textAlign(CENTER, TOP);
  textSize(isFull ? 46 : 52);
  fill(C_TEXT);
  text("Governance Maturity Score →",
       (PANEL_LX + PANEL_RX + PW) / 2,
       PANEL_BY + P_CH + 80 + (isFull ? 55 : 60));

  // Y axis title — left of left panels
  pushMatrix();
  translate(PANEL_LX - 60, (PANEL_TY + PANEL_BY + PH) / 2);
  rotate(-HALF_PI);
  textAlign(CENTER, CENTER);
  textSize(isFull ? 46 : 52);
  fill(C_TEXT);
  text("Breach Prevalence % →", 0, 0);
  popMatrix();

  // How-to-read note
  textAlign(LEFT, TOP);
  textSize(isFull ? 34 : 38);
  fill(C_TEXT, 100);
  text("Bubble size ∝ estimated UK org count  ·  Pale = 2018  →  Solid = 2025  ·  Note: axes are zoomed per panel — bold labels show each panel's scale range",
       PANEL_LX, PANEL_BY + P_CH + 80 + (isFull ? 108 : 118));
}

// =============================================================================
// TITLE  (full version only)
// =============================================================================
void drawTitle() {
  textAlign(LEFT, TOP);
  fill(C_TEXT);
  textSize(92);
  text("Better governance doesn't guarantee fewer breaches —", 200, 36);
  text("but it changes who gets hit.", 200, 148);

  textSize(44);
  fill(C_TEXT, 130);
  text("Cyber Security Breaches Survey 2018–2025  |  Story 5 of 5: Governance & Breach  |  Each panel = one org size, axes zoomed to data",
       200, 270);

  textAlign(RIGHT, TOP);
  textSize(52);
  fill(C_TEXT);
  text("NODE9", 3508 - 80, 50);
}

// =============================================================================
// FOOTER  (full version only)
// =============================================================================
void drawFooter() {
  textAlign(LEFT, BOTTOM);
  textSize(36);
  fill(C_TEXT, 100);
  text(
    "Source: UK Cyber Security Breaches Survey (CSBS), DSIT / Home Office, 2018–2025.  Open Government Licence v3.0.   node9.co.uk",
    200, 2480 - 44
  );
}
