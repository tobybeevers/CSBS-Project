// =============================================================================
// Story 2 — Board Priority by Organisation Size, 2018 vs 2025
// Node9 Consulting | CSBS Infographic Series
// Canvas: A4 landscape, 3508 × 2480 px @ 300 dpi
//
// Saves both versions in one run:
//   story2_board_priority_full.png  — title, chart, annotations, footer
//   story2_board_priority_chart.png — chart, axes, legend only
//
// Data source: outputs/tables/story2_board_priority_by_size.csv
// =============================================================================

// --- Colour palette (IBM colour-blind safe) ---
final color BG      = #FAFAFA;
final color C_MICRO  = #DC267F;   // Micro  — magenta
final color C_SMALL  = #FE6100;   // Small  — orange
final color C_MEDIUM = #648FFF;   // Medium — blue
final color C_LARGE  = #785EF0;   // Large  — purple
final color C_TEXT   = #1A1A2E;
final color C_GRID   = #CCCCCC;

// --- Data (story2_board_priority_by_size.csv — board_priority_pct) ---
// 2018 values
final float[] VAL_2018 = { 0.7219, 0.8021, 0.9129, 0.9202 };
// 2025 values
final float[] VAL_2025 = { 0.6999, 0.8492, 0.9195, 0.9767 };
// Change in percentage points
final float[] CHANGE   = { -2.2,   +4.7,   +0.7,   +5.7   };
// Labels and size order
final String[] LABELS  = { "Micro", "Small", "Medium", "Large" };
final color[]  COLORS  = { C_MICRO, C_SMALL, C_MEDIUM, C_LARGE };
// Approximate avg sample size 2018+2025 per band (for line thickness)
final int[] SAMPLES    = { 835, 457, 338, 220 };
final int N = 4;

// Y axis range (truncated to show slope differences clearly)
final float Y_MIN = 0.55;   // 55%
final float Y_MAX = 1.00;   // 100%

// --- Layout variables (set per version) ---
int   CY, CB, CH;
float AXIS_L, AXIS_R;
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
  drawYAxis();
  drawSlopes();
  drawAxisLabels();
  drawTitle();
  drawLegend();
  drawAnnotations();
  drawFooter();
  save("../../outputs/figures/processing.org outputs/story2_board_priority_full.png");
  println("Saved: story2_board_priority_full.png");

  // --- Chart-only version ---
  setupChart();
  background(BG);
  drawYAxis();
  drawSlopes();
  drawAxisLabels();
  drawLegend();
  save("../../outputs/figures/processing.org outputs/story2_board_priority_chart.png");
  println("Saved: story2_board_priority_chart.png");

  exit();
}

// =============================================================================
// LAYOUT SETUP
// =============================================================================
void setupFull() {
  isFull = true;
  CY     = 460;
  CH     = 1680;
  CB     = CY + CH;
  AXIS_L = 1020;
  AXIS_R = 2488;
}

void setupChart() {
  isFull = false;
  CY     = 140;
  CH     = 2080;
  CB     = CY + CH;
  AXIS_L = 420;
  AXIS_R = 2900;
}

// =============================================================================
// Y AXIS LINES + TICK MARKS
// =============================================================================
void drawYAxis() {
  stroke(C_TEXT);
  strokeWeight(4);
  line(AXIS_L, CY, AXIS_L, CB);   // 2018 axis
  line(AXIS_R, CY, AXIS_R, CB);   // 2025 axis
  noStroke();

  // Tick marks and % labels on left axis
  textSize(isFull ? 42 : 46);
  textAlign(RIGHT, CENTER);
  fill(C_TEXT, 160);
  for (int pct = 60; pct <= 100; pct += 10) {
    float y = yS(pct / 100.0);
    stroke(C_GRID);
    strokeWeight(1);
    line(AXIS_L - 14, y, AXIS_L, y);
    noStroke();
    text(pct + "%", AXIS_L - 22, y);
  }

  // Axis break marker at bottom of left axis (indicates truncated scale)
  stroke(C_TEXT);
  strokeWeight(3);
  float bx = AXIS_L;
  float by = CB + 30;
  line(bx - 20, by - 12, bx + 20, by + 12);
  line(bx - 20, by,      bx + 20, by + 24);
  noStroke();
}

// =============================================================================
// SLOPE LINES + ENDPOINT DOTS
// =============================================================================
void drawSlopes() {
  int minS = 220;
  int maxS = 835;

  for (int i = 0; i < N; i++) {
    float y18 = yS(VAL_2018[i]);
    float y25 = yS(VAL_2025[i]);
    color c   = COLORS[i];

    // Line — thickness proportional to sample size
    float sw = map(SAMPLES[i], minS, maxS, 4, 14);
    stroke(c);
    strokeWeight(sw);
    line(AXIS_L, y18, AXIS_R, y25);

    // Endpoint dots
    noStroke();
    fill(c);
    float dotR = isFull ? 28 : 32;
    ellipse(AXIS_L, y18, dotR, dotR);
    ellipse(AXIS_R, y25, dotR, dotR);

    // Pattern fill on dots (accessibility dual encoding)
    drawDotPattern(AXIS_L, y18, dotR, i);
    drawDotPattern(AXIS_R, y25, dotR, i);

    // Labels inside the axes, rotated along the slope line
    float labelSize = isFull ? 46 : 50;
    textSize(labelSize);
    float angle = atan2(y25 - y18, AXIS_R - AXIS_L);
    float lOff  = dotR / 2 + 20;   // horizontal inset from each axis

    // Left label: band name + 2018 % — just inside left axis
    float lx  = AXIS_L + lOff;
    float ly  = y18 + lOff * tan(angle);
    fill(c);
    pushMatrix();
    translate(lx, ly);
    rotate(angle);
    textAlign(LEFT, BOTTOM);
    text(LABELS[i] + "  " + nf(VAL_2018[i] * 100, 0, 1) + "%", 0, -10);
    popMatrix();

    // Right label: 2025 % + change — just inside right axis
    String changeLbl = CHANGE[i] > 0 ? "+" + nf(CHANGE[i], 0, 1) + "pp" : nf(CHANGE[i], 0, 1) + "pp";
    float rx  = AXIS_R - lOff;
    float ry  = y25 - lOff * tan(-angle);
    pushMatrix();
    translate(rx, ry);
    rotate(angle);
    textAlign(RIGHT, BOTTOM);
    text(nf(VAL_2025[i] * 100, 0, 1) + "%  (" + changeLbl + ")", 0, -10);
    popMatrix();
  }
  noStroke();
}

// =============================================================================
// AXIS YEAR LABELS + FOOTNOTE
// =============================================================================
void drawAxisLabels() {
  textAlign(CENTER, BOTTOM);
  fill(C_TEXT);
  textSize(isFull ? 60 : 66);
  text("2018", AXIS_L, CY - 20);
  text("2025", AXIS_R, CY - 20);

  // Y axis title (left)
  pushMatrix();
  translate(AXIS_L - 280, CY + CH / 2);
  rotate(-HALF_PI);
  textAlign(CENTER, CENTER);
  textSize(isFull ? 44 : 48);
  fill(C_TEXT);
  text("% treating cyber security as a board priority", 0, 0);
  popMatrix();

  // Truncated axis note
  textSize(isFull ? 34 : 36);
  fill(C_TEXT, 120);
  if (isFull) { textAlign(LEFT, TOP);  text("Note: Y axis starts at 55% to show differences clearly.", AXIS_L, CB + 50); }
  else        { textAlign(RIGHT, TOP); text("Note: Y axis starts at 55% to show differences clearly.", AXIS_R, CB + 50); }

  // Causation caveat
  textSize(isFull ? 34 : 36);
  fill(C_TEXT, 120);
  if (isFull) { textAlign(LEFT, TOP);  text("Association only — does not imply causation.", AXIS_L, CB + 96); }
  else        { textAlign(RIGHT, TOP); text("Association only — does not imply causation.", AXIS_R, CB + 100); }
}

// =============================================================================
// TITLE  (full version only)
// =============================================================================
void drawTitle() {
  textAlign(LEFT, TOP);
  fill(C_TEXT);
  textSize(96);
  text("Do organisations that treat cyber security as a board priority", 200, 36);
  text("see different outcomes?", 200, 148);

  textSize(44);
  fill(C_TEXT, 130);
  text("Cyber Security Breaches Survey 2018–2025  |  Story 2 of 5: Governance Priority", 200, 270);

  textAlign(RIGHT, TOP);
  textSize(52);
  fill(C_TEXT);
  text("NODE9", 3508 - 80, 50);
}

// =============================================================================
// LEGEND
// =============================================================================
void drawLegend() {
  // Legend sits inside the chart at ~62% level, two columns (Micro/Small | Medium/Large)
  float lx1  = AXIS_L + 60;
  float lx2  = AXIS_L + (AXIS_R - AXIS_L) * 0.52;
  float ly1  = yS(0.625);
  float rGap = isFull ? 110 : 130;
  float dotR = 30;

  String[] szLbl = { "Micro  (<10 employees)", "Small  (10–49 employees)",
                     "Medium  (50–249 employees)", "Large  (250+ employees)" };
  float[]  lxArr = { lx1, lx1, lx2, lx2 };
  float[]  lyArr = { ly1, ly1 + rGap, ly1, ly1 + rGap };

  textSize(isFull ? 42 : 46);
  textAlign(LEFT, CENTER);

  for (int i = 0; i < N; i++) {
    noStroke();
    fill(COLORS[i]);
    ellipse(lxArr[i] + dotR / 2, lyArr[i], dotR, dotR);
    drawDotPattern(lxArr[i] + dotR / 2, lyArr[i], dotR, i);
    fill(C_TEXT);
    text(szLbl[i], lxArr[i] + dotR + 14, lyArr[i]);
  }
  noStroke();

  // In-chart note explaining line thickness — sits below legend block
  textSize(isFull ? 34 : 38);
  fill(C_TEXT, 110);
  textAlign(LEFT, TOP);
  text("Thicker lines indicate a larger survey sample  (Micro n ≈ 835  ·  Small n ≈ 457  ·  Medium n ≈ 338  ·  Large n ≈ 220)",
       lx1, ly1 + rGap + (isFull ? 60 : 72));
}

// =============================================================================
// ANNOTATIONS  (full version only)
// =============================================================================
void drawAnnotations() {
  // Most progress — Large (+5.7pp)
  float y25L = yS(VAL_2025[3]);
  float y18L = yS(VAL_2018[3]);
  textAlign(CENTER, CENTER);
  textSize(52);
  fill(C_LARGE);
  text("Most progress  ↑ +5.7pp", AXIS_L + (AXIS_R - AXIS_L) / 2, (y18L + y25L) / 2 - 60);

  // Micro declined — flag it
  float y25M = yS(VAL_2025[0]);
  float y18M = yS(VAL_2018[0]);
  textSize(48);
  fill(C_MICRO);
  text("Micro orgs: priority fell  ↓ −2.2pp", AXIS_L + (AXIS_R - AXIS_L) / 2, (y18M + y25M) / 2 + 60);

  // Insight statement below chart
  textAlign(CENTER, TOP);
  textSize(52);
  fill(C_TEXT, 175);
  text("Large organisations made the most progress — but micro organisations are going backwards.",
       AXIS_L + (AXIS_R - AXIS_L) / 2, CB + 158);
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

// =============================================================================
// PATTERN FILL ON DOTS  (dual encoding per org size)
// =============================================================================
void drawDotPattern(float cx, float cy, float d, int sizeIdx) {
  float r = d / 2;
  color c = lerpColor(COLORS[sizeIdx], color(255), 0.5);
  stroke(c, 180);
  strokeWeight(1.8);

  if (sizeIdx == 0) {
    // Micro — diagonal ////
    for (float off = -d; off < d * 2; off += 6) {
      float[] pts = circleLineClip(cx, cy, r, cx + off, cy + r, cx + off + d, cy - r);
      if (pts != null) line(pts[0], pts[1], pts[2], pts[3]);
    }
  } else if (sizeIdx == 1) {
    // Small — dots ....
    noStroke();
    fill(c, 180);
    for (float px = cx - r + 5; px < cx + r; px += 7) {
      for (float py = cy - r + 5; py < cy + r; py += 7) {
        if (dist(px, py, cx, cy) < r - 2) ellipse(px, py, 3, 3);
      }
    }
    stroke(c, 180);
    strokeWeight(1.8);
    noFill();
  } else if (sizeIdx == 2) {
    // Medium — crosshatch ####
    for (float off = -d; off < d; off += 7) {
      float[] h = circleLineClip(cx, cy, r, cx - r, cy + off, cx + r, cy + off);
      if (h != null) line(h[0], h[1], h[2], h[3]);
      float[] v = circleLineClip(cx, cy, r, cx + off, cy - r, cx + off, cy + r);
      if (v != null) line(v[0], v[1], v[2], v[3]);
    }
  } else {
    // Large — horizontal ----
    for (float off = -r + 4; off < r; off += 7) {
      float[] h = circleLineClip(cx, cy, r, cx - r, cy + off, cx + r, cy + off);
      if (h != null) line(h[0], h[1], h[2], h[3]);
    }
  }
  noStroke();
}

// Clip a line to a circle, return clipped endpoints or null if no intersection
float[] circleLineClip(float cx, float cy, float r, float x1, float y1, float x2, float y2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float fx = x1 - cx;
  float fy = y1 - cy;
  float a  = dx*dx + dy*dy;
  float b  = 2 * (fx*dx + fy*dy);
  float c  = fx*fx + fy*fy - r*r;
  float disc = b*b - 4*a*c;
  if (disc < 0) return null;
  float sq = sqrt(disc);
  float t0 = (-b - sq) / (2*a);
  float t1 = (-b + sq) / (2*a);
  t0 = max(t0, 0); t1 = min(t1, 1);
  if (t0 > t1) return null;
  return new float[]{ x1 + t0*dx, y1 + t0*dy, x1 + t1*dx, y1 + t1*dy };
}

// =============================================================================
// COORDINATE HELPER
// =============================================================================
float yS(float v) {
  // Map proportion v to Y coordinate within [Y_MIN, Y_MAX] range
  return CB - ((v - Y_MIN) / (Y_MAX - Y_MIN)) * CH;
}

// =============================================================================
// DASHED LINE UTILITY
// =============================================================================
void dashedLine(float x1, float y1, float x2, float y2, float dash, float gap) {
  float dx  = x2 - x1;
  float dy  = y2 - y1;
  float len = sqrt(dx*dx + dy*dy);
  dx /= len; dy /= len;
  float pos = 0;
  boolean on = true;
  while (pos < len) {
    float seg = on ? dash : gap;
    float end = min(pos + seg, len);
    if (on) line(x1 + dx*pos, y1 + dy*pos, x1 + dx*end, y1 + dy*end);
    pos = end;
    on  = !on;
  }
}
