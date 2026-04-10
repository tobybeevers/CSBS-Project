// =============================================================================
// Story 1 — UK Cyber Security Posture Has Changed, 2018–2025
// Node9 Consulting | CSBS Infographic Series
// Canvas: A4 landscape, 3508 × 2480 px @ 300 dpi
//
// Saves both versions in one run:
//   story1_uk_posture_full.png  — title, chart, annotations, footer
//   story1_uk_posture_chart.png — chart, axes, legend only
//
// Data source: outputs/tables/story1_uk_posture_trends.csv
// =============================================================================

// --- Colour palette (IBM colour-blind safe) ---
final color BG     = #FAFAFA;
final color C_GOV  = #648FFF;   // governance bars
final color C_BRE  = #DC267F;   // breach bars
final color C_LINE = #1A1A2E;   // participant line + all text
final color C_GRID = #CCCCCC;   // grid lines

// --- Data (story1_uk_posture_trends.csv) ---
// governance_score_B: continuous composite (priority_norm + manage_prop + policy_prop) / 3
final int N = 8;
final int[]   YEARS = { 2018,  2019,  2020,  2021,  2022,  2023,  2024,  2025  };
final float[] GOV   = { 0.374, 0.438, 0.491, 0.467, 0.516, 0.460, 0.479, 0.505 };
final float[] BRE   = { 0.373, 0.304, 0.453, 0.399, 0.432, 0.354, 0.480, 0.434 };
final int[]   PARTS = { 2088,  2080,  1900,  2284,  2157,  3991,  3434,  3835  };
final int     MAXP  = 4500;

// --- Layout variables (set per version) ---
int   CX, CY, CW, CH, CR, CB;
float GW, BW, BGAP;
boolean isFull;

// =============================================================================
void setup() {
  size(3508, 2480);
  noLoop();
}

void draw() {
  // --- Render full version ---
  setupFull();
  background(BG);
  drawGrid();
  drawMethodologyMarkers();
  drawBars();
  drawParticipantLine();
  drawAxes();
  drawTitle();
  drawLegend();
  drawAnnotations();
  drawFooter();
  save("../../outputs/figures/processing.org outputs/story1_uk_posture_full.png");
  println("Saved: story1_uk_posture_full.png");

  // --- Render chart-only version ---
  setupChart();
  background(BG);
  drawGrid();
  drawMethodologyMarkers();
  drawBars();
  drawParticipantLine();
  drawAxes();
  drawLegend();
  save("../../outputs/figures/processing.org outputs/story1_uk_posture_chart.png");
  println("Saved: story1_uk_posture_chart.png");

  exit();
}

// =============================================================================
// LAYOUT SETUP
// =============================================================================
void setupFull() {
  isFull = true;
  CX = 380; CY = 490; CW = 2740; CH = 1660;
  CR = CX + CW; CB = CY + CH;
  GW = CW / (float) N; BW = 96; BGAP = 18;
}

void setupChart() {
  isFull = false;
  CX = 380; CY = 160; CW = 2740; CH = 2020;
  CR = CX + CW; CB = CY + CH;
  GW = CW / (float) N; BW = 110; BGAP = 20;
}

// =============================================================================
// GRID  (tick labels only — no horizontal lines)
// =============================================================================
void drawGrid() {
  textAlign(RIGHT, CENTER);
  textSize(isFull ? 46 : 50);
  noStroke();
  for (int pct = 0; pct <= 100; pct += 20) {
    fill(C_LINE);
    text(pct + "%", CX - 24, yL(pct / 100.0));
  }
}

// =============================================================================
// METHODOLOGY CHANGE MARKERS  (dashed vertical lines at 2021 and 2024)
// =============================================================================
void drawMethodologyMarkers() {
  int[] methIdx = { 3, 6 };
  strokeWeight(4);
  for (int idx : methIdx) {
    stroke(C_LINE, 55);
    dashedLine(gx(idx), CY - 50, gx(idx), CB + 50, 22, 12);
  }
  noStroke();
}

// =============================================================================
// BARS  (governance + breach, grouped per year)
// =============================================================================
void drawBars() {
  for (int i = 0; i < N; i++) {
    float cx = gx(i);

    // Governance bar (blue, horizontal line pattern)
    float x1 = cx - BGAP / 2 - BW;
    float h1 = GOV[i] * CH;
    noStroke();
    fill(C_GOV, 215);
    rect(x1, CB - h1, BW, h1);
    drawHLines(x1, CB - h1, BW, h1, C_GOV);

    // Breach bar (magenta, diagonal line pattern)
    float x2 = cx + BGAP / 2;
    float h2 = BRE[i] * CH;
    noStroke();
    fill(C_BRE, 215);
    rect(x2, CB - h2, BW, h2);
    drawDiagLines(x2, CB - h2, BW, h2, C_BRE);

    // Data labels — rotated, inside base of each bar
    float labelSize = isFull ? 36 : 40;
    textSize(labelSize);
    textAlign(CENTER, BOTTOM);
    fill(255, 220);
    pushMatrix();
    translate(x1 + BW / 2, CB - 14);
    rotate(-HALF_PI);
    text(nf(GOV[i] * 100, 0, 1) + "%", 0, 0);
    popMatrix();
    pushMatrix();
    translate(x2 + BW / 2, CB - 14);
    rotate(-HALF_PI);
    text(nf(BRE[i] * 100, 0, 1) + "%", 0, 0);
    popMatrix();
  }
  noStroke();
}

// =============================================================================
// PARTICIPANT LINE  (right axis)
// =============================================================================
void drawParticipantLine() {
  stroke(C_LINE);
  strokeWeight(isFull ? 6 : 7);
  for (int i = 0; i < N - 1; i++) {
    line(gx(i), yR(PARTS[i]), gx(i + 1), yR(PARTS[i + 1]));
  }
  noStroke();
  fill(C_LINE);
  for (int i = 0; i < N; i++) {
    float px = gx(i);
    float py = yR(PARTS[i]);
    ellipse(px, py, isFull ? 26 : 28, isFull ? 26 : 28);
    textSize(isFull ? 38 : 40);
    textAlign(CENTER, BOTTOM);
    fill(C_LINE, 170);
    text(nfc(PARTS[i]), px, py - 16);
    fill(C_LINE);
  }
  noStroke();
}

// =============================================================================
// AXES
// =============================================================================
void drawAxes() {
  stroke(C_LINE);
  strokeWeight(4);
  line(CX, CY, CX, CB);
  line(CX, CB, CR, CB);
  line(CR, CY, CR, CB);
  noStroke();

  // X axis — year labels
  textSize(isFull ? 50 : 54);
  textAlign(CENTER, TOP);
  fill(C_LINE);
  for (int i = 0; i < N; i++) {
    String lbl = str(YEARS[i]);
    if (YEARS[i] == 2021 || YEARS[i] == 2024) lbl += "*";
    text(lbl, gx(i), CB + 20);
  }

  // Right axis — participant tick labels
  textSize(isFull ? 40 : 44);
  textAlign(LEFT, CENTER);
  fill(C_LINE, 160);
  for (int p = 0; p <= MAXP; p += 1000) {
    float y = yR(p);
    stroke(C_GRID);
    strokeWeight(1);
    line(CR, y, CR + 16, y);
    noStroke();
    text(p == 0 ? "0" : (p / 1000) + "k", CR + 28, y);
  }
  noStroke();

  // Left axis title
  pushMatrix();
  translate(CX - 280, CY + CH / 2);
  rotate(-HALF_PI);
  textAlign(CENTER, CENTER);
  textSize(isFull ? 46 : 50);
  fill(C_LINE);
  text("% of organisations report a", 0, 0);
  popMatrix();

  // Right axis title
  pushMatrix();
  translate(CR + 290, CY + CH / 2);
  rotate(HALF_PI);
  textAlign(CENTER, CENTER);
  textSize(isFull ? 46 : 50);
  fill(C_LINE, 160);
  text("Survey participants", 0, 0);
  popMatrix();

  // Methodology footnote
  textAlign(LEFT, TOP);
  textSize(isFull ? 36 : 38);
  fill(C_LINE, 120);
  text("* methodology change — interpret with caution", CX, CB + 88);
}

// =============================================================================
// TITLE  (full version only)
// =============================================================================
void drawTitle() {
  textAlign(LEFT, TOP);
  fill(C_LINE);
  textSize(96);
  text("UK cyber security posture has changed over the past 8 years —", CX, 36);
  text("here's what the data shows.", CX, 148);

  textSize(44);
  fill(C_LINE, 130);
  text("Cyber Security Breaches Survey 2018–2025  |  Story 1 of 5: Overview", CX, 270);

  textAlign(RIGHT, TOP);
  textSize(52);
  fill(C_LINE);
  text("NODE9", 3508 - 80, 50);
}

// =============================================================================
// LEGEND
// =============================================================================
void drawLegend() {
  // Full: legend sits between title and chart; Chart: legend sits below chart
  float lx  = CX + 40;
  float ly  = isFull ? CY - 108 : CB + 190;
  float sw  = isFull ? 54 : 58;
  float sh  = isFull ? 34 : 36;
  float gap = 22;

  textSize(isFull ? 43 : 46);
  textAlign(LEFT, CENTER);

  // Governance swatch
  noStroke();
  fill(C_GOV, 215);
  rect(lx, ly, sw, sh);
  fill(C_LINE);
  text("Governance maturity score", lx + sw + gap, ly + sh / 2);

  // Breach swatch
  lx += isFull ? 840 : 900;
  noStroke();
  fill(C_BRE, 215);
  rect(lx, ly, sw, sh);
  fill(C_LINE);
  text("Breach prevalence", lx + sw + gap, ly + sh / 2);

  // Participant line swatch
  lx += isFull ? 570 : 620;
  stroke(C_LINE);
  strokeWeight(isFull ? 5 : 6);
  line(lx, ly + sh / 2, lx + sw, ly + sh / 2);
  fill(C_LINE);
  noStroke();
  ellipse(lx + sw / 2, ly + sh / 2, isFull ? 18 : 20, isFull ? 18 : 20);
  fill(C_LINE);
  text("Survey participants (right axis)", lx + sw + gap, ly + sh / 2);
  noStroke();
}

// =============================================================================
// ANNOTATIONS  (full version only)
// =============================================================================
void drawAnnotations() {
  int last = N - 1;

  // Callout above 2025 breach bar
  float bx = gx(last) + BGAP / 2 + BW / 2;
  textAlign(CENTER, BOTTOM);
  textSize(58);
  fill(C_BRE);
  text(int(BRE[last] * 100 + 0.5) + "% of UK organisations recorded a breach in 2025",
       bx, yL(BRE[last]) - 20);

  // Callout above 2025 governance bar
  float gxPos = gx(last) - BGAP / 2 - BW / 2;
  textAlign(CENTER, BOTTOM);
  textSize(48);
  fill(C_GOV);
  text("Governance: " + nf(GOV[last] * 100, 0, 0) + "%", gxPos, yL(GOV[last]) - 20);

  // Insight statement below chart
  textAlign(CENTER, TOP);
  textSize(52);
  fill(C_LINE, 175);
  text("In 2025, governance maturity has improved — but breach prevalence hasn't fallen to match.",
       CX + CW / 2, CB + 158);
}

// =============================================================================
// FOOTER  (full version only)
// =============================================================================
void drawFooter() {
  textAlign(LEFT, BOTTOM);
  textSize(36);
  fill(C_LINE, 100);
  text(
    "Source: UK Cyber Security Breaches Survey (CSBS), DSIT / Home Office, 2018–2025.  Open Government Licence v3.0.   node9.co.uk",
    CX, 2480 - 44
  );
}

// =============================================================================
// PATTERN FILL HELPERS
// =============================================================================
void drawHLines(float x, float y, float w, float h, color c) {
  stroke(lerpColor(c, color(255), 0.45), 150);
  strokeWeight(2.5);
  for (float py = y + 7; py < y + h; py += 12) {
    line(x, py, x + w, py);
  }
  noStroke();
}

void drawDiagLines(float x, float y, float w, float h, color c) {
  stroke(lerpColor(c, color(255), 0.45), 150);
  strokeWeight(2.5);
  for (float off = -h; off < w + h; off += 13) {
    clipAndLine(x + off, y + h, x + off + h, y, x, y, x + w, y + h);
  }
  noStroke();
}

void clipAndLine(float ax, float ay, float bx, float by,
                 float rx, float ry, float rr, float rb) {
  float dx = bx - ax;
  float dy = by - ay;
  float[] t = { 0.0, 1.0 };
  if (!clipAxis(ax, dx, rx, rr, t)) return;
  if (!clipAxis(ay, dy, ry, rb, t)) return;
  line(ax + t[0] * dx, ay + t[0] * dy, ax + t[1] * dx, ay + t[1] * dy);
}

boolean clipAxis(float a, float d, float lo, float hi, float[] t) {
  if (abs(d) < 0.001) return (a >= lo && a <= hi);
  float t1 = (lo - a) / d;
  float t2 = (hi - a) / d;
  if (t1 > t2) { float tmp = t1; t1 = t2; t2 = tmp; }
  t[0] = max(t[0], t1);
  t[1] = min(t[1], t2);
  return t[0] <= t[1];
}

// =============================================================================
// COORDINATE HELPERS
// =============================================================================
float gx(int i)   { return CX + (i + 0.5) * GW; }
float yL(float v) { return CB - v * CH; }
float yR(float p) { return CB - (p / (float) MAXP) * CH; }

// =============================================================================
// DASHED LINE UTILITY
// =============================================================================
void dashedLine(float x1, float y1, float x2, float y2, float dash, float gap) {
  float dx  = x2 - x1;
  float dy  = y2 - y1;
  float len = sqrt(dx * dx + dy * dy);
  dx /= len; dy /= len;
  float pos = 0;
  boolean on = true;
  while (pos < len) {
    float seg = on ? dash : gap;
    float end = min(pos + seg, len);
    if (on) line(x1 + dx * pos, y1 + dy * pos, x1 + dx * end, y1 + dy * end);
    pos = end;
    on  = !on;
  }
}
