// =============================================================================
// Story 4 — Technical Controls Adoption
// Node9 Consulting | CSBS Infographic Series
// Canvas: A4 landscape, 3508 × 2480 px @ 300 dpi
//
// Saves both versions in one run:
//   story4_controls_full.png  — title, chart, annotations, footer
//   story4_controls_chart.png — chart, axes, legend only
//
// Data source: outputs/tables/story4_control_adoption.csv
//
// Three series:
//   ten_steps_pct    — large background area (organisations following 10 Steps)
//   ce_adoption_pct  — solid foreground area (organisations with Cyber Essentials)
//   breach_nonadopter_pct — dashed magenta line (breach rate among CE non-adopters)
//
// The shaded band between ce_adoption and ten_steps top = "protection gap":
// organisations following 10 Steps guidance but without formal CE certification.
// =============================================================================

// --- Colour palette (IBM colour-blind safe) ---
final color BG       = #FAFAFA;
final color C_CTRL   = #FE6100;   // controls / CE — orange
final color C_BREACH = #DC267F;   // breach prevalence — magenta
final color C_TEXT   = #1A1A2E;
final color C_GRID   = #CCCCCC;

// --- Data (story4_control_adoption.csv) ---
final int N = 8;
final int[] YEARS = { 2018,   2019,   2020,   2021,   2022,   2023,   2024,   2025   };
final float[] CE   = { 0.4508, 0.5198, 0.5311, 0.3123, 0.2997, 0.2245, 0.2459, 0.2344 };
final float[] STEPS= { 0.9446, 0.9583, 0.9649, 0.9238, 0.9401, 0.8871, 0.9111, 0.8885 };
final float[] BRE  = { 0.0475, 0.0682, 0.1433, 0.1104, 0.1158, 0.1355, 0.1458, 0.1153 };

// --- Layout variables (set per version) ---
int   CX, CY, CW, CH, CR, CB;
boolean isFull;

// =============================================================================
void setup() {
  size(3508, 2480);
  noLoop();
}

void draw() {
  // --- Full version ---
  setupFull();
  background(BG);
  drawGrid();
  drawTenStepsArea();
  drawProtectionGap();
  drawCEArea();
  drawBreachLine();
  drawMethodologyMarkers();
  drawAxes();
  drawLegend();
  drawTitle();
  drawAnnotations();
  drawFooter();
  save("../../outputs/figures/processing.org outputs/story4_controls_full.png");
  println("Saved: story4_controls_full.png");

  // --- Chart-only version ---
  setupChart();
  background(BG);
  drawGrid();
  drawTenStepsArea();
  drawProtectionGap();
  drawCEArea();
  drawBreachLine();
  drawMethodologyMarkers();
  drawAxes();
  drawLegend();
  save("../../outputs/figures/processing.org outputs/story4_controls_chart.png");
  println("Saved: story4_controls_chart.png");

  exit();
}

// =============================================================================
// LAYOUT SETUP
// =============================================================================
void setupFull() {
  isFull = true;
  CX = 380; CY = 490; CW = 2740; CH = 1660;
  CR = CX + CW; CB = CY + CH;
}

void setupChart() {
  isFull = false;
  CX = 380; CY = 160; CW = 2740; CH = 2020;
  CR = CX + CW; CB = CY + CH;
}

// =============================================================================
// COORDINATE HELPERS
// =============================================================================
float gx(int i) { return CX + i * (float) CW / (N - 1); }
float yC(float v) { return CB - v * CH; }   // proportion → pixel y

// =============================================================================
// GRID  (horizontal lines + y-axis tick labels)
// =============================================================================
void drawGrid() {
  stroke(C_GRID);
  strokeWeight(1.5);
  textAlign(RIGHT, CENTER);
  textSize(isFull ? 44 : 48);
  fill(C_TEXT, 140);

  for (int pct = 0; pct <= 100; pct += 20) {
    float y = yC(pct / 100.0);
    line(CX, y, CR, y);
    noStroke();
    text(pct + "%", CX - 20, y);
    stroke(C_GRID);
    strokeWeight(1.5);
  }
  noStroke();
}

// =============================================================================
// AREA: 10 STEPS  (large background fill — organisations following the framework)
// =============================================================================
void drawTenStepsArea() {
  fill(C_CTRL, 55);   // pale orange background
  noStroke();
  beginShape();
  for (int i = 0; i < N; i++) vertex(gx(i), yC(STEPS[i]));
  vertex(CR, CB);
  vertex(CX, CB);
  endShape(CLOSE);

  // Horizontal line pattern for accessibility
  stroke(C_CTRL, 40);
  strokeWeight(1.8);
  for (float py = CY + 8; py < CB; py += 14) {
    line(CX, py, CR, py);
  }
  noStroke();
}

// =============================================================================
// PROTECTION GAP  (band between CE top and 10 Steps top)
// =============================================================================
void drawProtectionGap() {
  fill(C_BREACH, 18);
  noStroke();
  beginShape();
  for (int i = 0; i < N; i++)        vertex(gx(i), yC(STEPS[i]));
  for (int i = N - 1; i >= 0; i--)   vertex(gx(i), yC(CE[i]));
  endShape(CLOSE);
}

// =============================================================================
// AREA: CYBER ESSENTIALS  (solid foreground fill)
// =============================================================================
void drawCEArea() {
  fill(C_CTRL, 200);
  noStroke();
  beginShape();
  for (int i = 0; i < N; i++) vertex(gx(i), yC(CE[i]));
  vertex(CR, CB);
  vertex(CX, CB);
  endShape(CLOSE);

  // Dot pattern for accessibility
  noStroke();
  fill(lerpColor(C_CTRL, color(255), 0.35), 160);
  for (int i = 0; i < N; i++) {
    float x0 = (i == 0) ? CX : gx(i - 1);
    float x1 = gx(i);
    float y0 = (i == 0) ? yC(CE[0]) : yC(CE[i - 1]);
    float y1 = yC(CE[i]);
    for (float px = x0 + 8; px < x1; px += 18) {
      for (float py = CB - 10; py > CY; py -= 18) {
        float topAtX = map(px, x0, x1, y0, y1);
        if (py > topAtX) ellipse(px, py, 5, 5);
      }
    }
  }
}

// =============================================================================
// BREACH LINE  (dashed magenta — breach rate among CE non-adopters)
// =============================================================================
void drawBreachLine() {
  stroke(C_BREACH);
  strokeWeight(isFull ? 6 : 7);
  for (int i = 0; i < N - 1; i++) {
    dashedLine(gx(i), yC(BRE[i]), gx(i + 1), yC(BRE[i + 1]), 28, 16);
  }
  noStroke();
  fill(C_BREACH);
  for (int i = 0; i < N; i++) {
    ellipse(gx(i), yC(BRE[i]), isFull ? 26 : 30, isFull ? 26 : 30);
  }
  noStroke();
}

// =============================================================================
// METHODOLOGY MARKERS  (dashed verticals at 2021 and 2024)
// =============================================================================
void drawMethodologyMarkers() {
  int[] methIdx = { 3, 6 };   // indices of 2021 and 2024
  strokeWeight(4);
  for (int idx : methIdx) {
    stroke(C_TEXT, 55);
    dashedLine(gx(idx), CY - 50, gx(idx), CB + 50, 22, 12);
  }
  noStroke();
}

// =============================================================================
// AXES + YEAR LABELS
// =============================================================================
void drawAxes() {
  stroke(C_TEXT);
  strokeWeight(4);
  line(CX, CY, CX, CB);
  line(CX, CB, CR, CB);
  noStroke();

  // X axis — year labels
  textAlign(CENTER, TOP);
  textSize(isFull ? 50 : 54);
  fill(C_TEXT);
  for (int i = 0; i < N; i++) {
    String lbl = str(YEARS[i]);
    if (YEARS[i] == 2021 || YEARS[i] == 2024) lbl += "*";
    text(lbl, gx(i), CB + 20);
  }

  // Y axis title
  pushMatrix();
  translate(CX - 280, CY + CH / 2);
  rotate(-HALF_PI);
  textAlign(CENTER, CENTER);
  textSize(isFull ? 44 : 48);
  fill(C_TEXT);
  text("% of organisations", 0, 0);
  popMatrix();

  // Methodology footnote
  textAlign(LEFT, TOP);
  textSize(isFull ? 34 : 38);
  fill(C_TEXT, 110);
  text("* methodology change — interpret with caution", CX, CB + 88);
}

// =============================================================================
// LEGEND
// =============================================================================
void drawLegend() {
  float ly  = isFull ? CY - 100 : CB + 190;
  float sw  = isFull ? 52 : 58;
  float sh  = isFull ? 32 : 36;
  float gap = 22;

  // Fixed x positions — spaced to prevent overlap
  float lx1 = CX + 40;
  float lx2 = CX + 1200;
  float lx3 = CX + 2100;

  textSize(isFull ? 42 : 46);
  textAlign(LEFT, CENTER);

  // 10 Steps swatch
  noStroke();
  fill(C_CTRL, 55);
  rect(lx1, ly, sw, sh);
  fill(C_TEXT);
  text("Implementing 10 Steps to Cyber Security", lx1 + sw + gap, ly + sh / 2);

  // CE swatch
  noStroke();
  fill(C_CTRL, 200);
  rect(lx2, ly, sw, sh);
  fill(C_TEXT);
  text("Cyber Essentials certified", lx2 + sw + gap, ly + sh / 2);

  // Breach swatch
  stroke(C_BREACH);
  strokeWeight(isFull ? 5 : 6);
  dashedLine(lx3, ly + sh / 2, lx3 + sw, ly + sh / 2, 14, 8);
  fill(C_BREACH);
  noStroke();
  ellipse(lx3 + sw / 2, ly + sh / 2, isFull ? 16 : 18, isFull ? 16 : 18);
  fill(C_TEXT);
  text("Breach rate among CE non-adopters", lx3 + sw + gap, ly + sh / 2);
}

// =============================================================================
// TITLE  (full version only)
// =============================================================================
void drawTitle() {
  textAlign(LEFT, TOP);
  fill(C_TEXT);
  textSize(96);
  text("Cyber Essentials adoption is falling —", CX, 36);
  text("and non-adopters continue to pay the price.", CX, 148);

  textSize(44);
  fill(C_TEXT, 130);
  text("Cyber Security Breaches Survey 2018–2025  |  Story 4 of 5: Technical Controls", CX, 270);

  textAlign(RIGHT, TOP);
  textSize(52);
  fill(C_TEXT);
  text("NODE9", 3508 - 80, 50);
}

// =============================================================================
// ANNOTATIONS  (full version only)
// =============================================================================
void drawAnnotations() {
  int last = N - 1;

  // CE callout — latest year
  float cx2025 = gx(last);
  float cy2025 = yC(CE[last]);
  textAlign(LEFT, BOTTOM);
  textSize(60);
  fill(C_CTRL);
  text(int(CE[last] * 100 + 0.5) + "% of UK organisations", cx2025 - 560, cy2025 - 24);
  textSize(46);
  text("have Cyber Essentials in 2025", cx2025 - 560, cy2025 + 30);

  // Breach callout — latest year
  float bx2025 = gx(last);
  float by2025 = yC(BRE[last]);
  textAlign(RIGHT, TOP);
  textSize(50);
  fill(C_BREACH);
  text(int(BRE[last] * 100 + 0.5) + "% breach rate among non-adopters", bx2025 - 20, by2025 + 16);

  // Protection gap label — centred in the shaded band, mid-chart
  int midI = N / 2;
  float gapMidY = (yC(STEPS[midI]) + yC(CE[midI])) / 2;
  textAlign(CENTER, CENTER);
  textSize(isFull ? 48 : 52);
  fill(C_BREACH, 180);
  text("Protection gap — frameworks adopted, certification not formalised", gx(midI), gapMidY);

  // Insight statement below chart
  textAlign(CENTER, TOP);
  textSize(50);
  fill(C_TEXT, 175);
  text(
    "Almost all organisations follow 10 Steps — but formal CE certification has halved since 2020.",
    CX + CW / 2, CB + 158
  );
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
    CX, 2480 - 44
  );
}

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
