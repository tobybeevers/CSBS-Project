// =============================================================================
// Story 3 — Policy, Management & Breach Pathway (Sankey Diagram)
// Node9 Consulting | CSBS Infographic Series
// Canvas: A4 landscape, 3508 × 2480 px @ 300 dpi
//
// Saves both versions in one run:
//   story3_pathway_full.png  — title, chart, annotations, footer
//   story3_pathway_chart.png — chart and labels only
//
// Data source: outputs/tables/story3_pathway_analysis.csv
// =============================================================================

// --- Colour palette (IBM colour-blind safe) ---
final color BG       = #FAFAFA;
final color C_NOPOL  = #CCCCCC;   // No policy — neutral grey
final color C_POL    = #785EF0;   // Policy / Managed — purple
final color C_SAFE   = #648FFF;   // Not breached — blue
final color C_BREACH = #DC267F;   // Breached — magenta
final color C_TEXT   = #1A1A2E;   // Text / axes

// --- Node proportions (from story3_pathway_analysis.csv, weighted) ---
// Column 1 — Policy status
final float P_NOPOL  = 0.6143;   // No formal policy
final float P_HASPOL = 0.3857;   // Has a formal policy

// Column 2 — Management activity
final float P_NOTMGD = 0.6340;   // Not actively managed
final float P_MGD    = 0.3660;   // Actively managed

// Column 3 — Breach outcome
final float P_SAFE_N = 0.5918;   // No breach
final float P_BRE_N  = 0.4082;   // Experienced a breach

// --- Flow proportions: Column 1 → Column 2 ---
final float F_NP_NM = 0.4818;    // NoPol → NotMgd  (largest single group)
final float F_NP_M  = 0.1325;    // NoPol → Mgd
final float F_HP_NM = 0.1522;    // HasPol → NotMgd
final float F_HP_M  = 0.2335;    // HasPol → Mgd

// --- Flow proportions: Column 2 → Column 3 ---
final float F_NM_S  = 0.4113;    // NotMgd → Not Breached
final float F_NM_B  = 0.2227;    // NotMgd → Breached
final float F_M_S   = 0.1805;    // Mgd → Not Breached
final float F_M_B   = 0.1855;    // Mgd → Breached

// --- Node width ---
final int NW = 100;

// --- Layout variables (set per version) ---
int   CY, CB, CH;
float GAP;
float C1X, C2X, C3X;
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
  drawFlows();
  drawNodes();
  drawColumnHeaders();
  drawNodeLabels();
  drawTitle();
  drawAnnotations();
  drawFooter();
  save("../../outputs/figures/processing.org outputs/story3_pathway_full.png");
  println("Saved: story3_pathway_full.png");

  // --- Chart-only version ---
  setupChart();
  background(BG);
  drawFlows();
  drawNodes();
  drawColumnHeaders();
  drawNodeLabels();
  save("../../outputs/figures/processing.org outputs/story3_pathway_chart.png");
  println("Saved: story3_pathway_chart.png");

  exit();
}

// =============================================================================
// LAYOUT SETUP
// =============================================================================
void setupFull() {
  isFull = true;
  CY = 490; CH = 1750; CB = CY + CH;
  GAP = 50;
  C1X = 620; C2X = 1694; C3X = 2700;
}

void setupChart() {
  isFull = false;
  CY = 180; CH = 2160; CB = CY + CH;
  GAP = 60;
  C1X = 620; C2X = 1694; C3X = 2700;
}

// Effective chart height available for nodes (total minus the gap between nodes)
float eff() { return CH - GAP; }

// =============================================================================
// NODE GEOMETRY HELPERS
// =============================================================================
float nopol_y()  { return CY; }
float nopol_h()  { return P_NOPOL  * eff(); }
float haspol_y() { return CY + nopol_h() + GAP; }
float haspol_h() { return P_HASPOL * eff(); }

float notmgd_y() { return CY; }
float notmgd_h() { return P_NOTMGD * eff(); }
float mgd_y()    { return CY + notmgd_h() + GAP; }
float mgd_h()    { return P_MGD    * eff(); }

float safe_y()   { return CY; }
float safe_h()   { return P_SAFE_N * eff(); }
float bre_y()    { return CY + safe_h() + GAP; }
float bre_h()    { return P_BRE_N  * eff(); }

// =============================================================================
// NODES
// =============================================================================
void drawNodes() {
  noStroke();

  // Col 1 — Policy status
  fill(C_NOPOL);
  rect(C1X, nopol_y(), NW, nopol_h());
  fill(C_POL);
  rect(C1X, haspol_y(), NW, haspol_h());

  // Col 2 — Management activity (Not Managed at ~30% opacity)
  fill(red(C_POL), green(C_POL), blue(C_POL), 80);
  rect(C2X, notmgd_y(), NW, notmgd_h());
  fill(C_POL);
  rect(C2X, mgd_y(), NW, mgd_h());

  // Col 3 — Breach outcome
  fill(C_SAFE);
  rect(C3X, safe_y(), NW, safe_h());
  fill(C_BREACH);
  rect(C3X, bre_y(), NW, bre_h());
}

// =============================================================================
// FLOWS  (filled bezier strips connecting nodes)
// Drawing order: all Col1→Col2 flows, then all Col2→Col3 flows.
// Within each source node, flows to the topmost destination come first
// so crossing flows are minimised.
// =============================================================================
void drawFlows() {
  noStroke();
  float e   = eff();
  float m12 = (C1X + NW + C2X) / 2.0;   // bezier midpoint between col1 and col2
  float m23 = (C2X + NW + C3X) / 2.0;   // bezier midpoint between col2 and col3

  // --- Outgoing cursors (right edge of source nodes) ---
  float np_out = nopol_y();
  float hp_out = haspol_y();
  // --- Incoming cursors (left edge of destination nodes) ---
  float nm_in  = notmgd_y();
  float m_in   = mgd_y();

  float h;

  // NoPol → NotMgd  (grey → grey, 48% of all orgs — the dominant pathway)
  h = F_NP_NM * e;
  drawFlow(C1X+NW, np_out, np_out+h, C2X, nm_in, nm_in+h, m12, C_NOPOL, 120);
  np_out += h; nm_in += h;

  // HasPol → NotMgd  (purple → grey — policy exists but not acted on)
  h = F_HP_NM * e;
  drawFlow(C1X+NW, hp_out, hp_out+h, C2X, nm_in, nm_in+h, m12,
           lerpColor(C_POL, C_NOPOL, 0.5), 120);
  hp_out += h; nm_in += h;

  // NoPol → Mgd  (grey → purple)
  h = F_NP_M * e;
  drawFlow(C1X+NW, np_out, np_out+h, C2X, m_in, m_in+h, m12,
           lerpColor(C_NOPOL, C_POL, 0.5), 120);
  np_out += h; m_in += h;

  // HasPol → Mgd  (purple → purple — the best-practice pathway)
  h = F_HP_M * e;
  drawFlow(C1X+NW, hp_out, hp_out+h, C2X, m_in, m_in+h, m12, C_POL, 120);
  // cursors consumed

  // --- Col2 → Col3 flows ---
  float nm_out = notmgd_y();
  float m_out  = mgd_y();
  float s_in   = safe_y();
  float b_in   = bre_y();

  // NotMgd → Not Breached
  h = F_NM_S * e;
  drawFlow(C2X+NW, nm_out, nm_out+h, C3X, s_in, s_in+h, m23, C_SAFE, 120);
  nm_out += h; s_in += h;

  // Mgd → Not Breached
  h = F_M_S * e;
  drawFlow(C2X+NW, m_out, m_out+h, C3X, s_in, s_in+h, m23, C_SAFE, 120);
  m_out += h; s_in += h;

  // NotMgd → Breached  (widest high-risk flow)
  h = F_NM_B * e;
  drawFlow(C2X+NW, nm_out, nm_out+h, C3X, b_in, b_in+h, m23, C_BREACH, 120);
  nm_out += h; b_in += h;

  // Mgd → Breached
  h = F_M_B * e;
  drawFlow(C2X+NW, m_out, m_out+h, C3X, b_in, b_in+h, m23, C_BREACH, 120);
}

// Draws a single Sankey flow as a filled bezier quadrilateral.
// (sx,sy1/sy2) = top/bottom at source right edge
// (dx,dy1/dy2) = top/bottom at destination left edge
// midX = horizontal bezier control point
void drawFlow(float sx, float sy1, float sy2,
              float dx, float dy1, float dy2,
              float midX, color c, int alpha) {
  fill(red(c), green(c), blue(c), alpha);
  beginShape();
  vertex(sx, sy1);
  bezierVertex(midX, sy1, midX, dy1, dx, dy1);
  vertex(dx, dy2);
  bezierVertex(midX, dy2, midX, sy2, sx, sy2);
  endShape(CLOSE);
}

// =============================================================================
// COLUMN HEADERS
// =============================================================================
void drawColumnHeaders() {
  textAlign(CENTER, BOTTOM);
  fill(C_TEXT);
  textSize(isFull ? 50 : 56);

  text("Policy status",       C1X + NW / 2, CY - 20);
  text("Management activity", C2X + NW / 2, CY - 20);
  text("Breach outcome",      C3X + NW / 2, CY - 20);
}

// =============================================================================
// NODE LABELS
// =============================================================================
void drawNodeLabels() {
  float ts      = isFull ? 46 : 50;
  float ts_pct  = isFull ? 56 : 62;
  float pct_gap = isFull ? 58 : 64;

  // --- Col 1: labels to the LEFT ---
  textAlign(RIGHT, CENTER);

  // NoPol
  float mid = nopol_y() + nopol_h() / 2;
  textSize(ts);
  fill(C_TEXT);
  text("No formal policy", C1X - 24, mid - pct_gap / 2);
  textSize(ts_pct);
  fill(C_NOPOL);
  text(nf(P_NOPOL * 100, 0, 1) + "%", C1X - 24, mid + pct_gap / 2);

  // HasPol
  mid = haspol_y() + haspol_h() / 2;
  textSize(ts);
  fill(C_TEXT);
  text("Has a formal policy", C1X - 24, mid - pct_gap / 2);
  textSize(ts_pct);
  fill(C_POL);
  text(nf(P_HASPOL * 100, 0, 1) + "%", C1X - 24, mid + pct_gap / 2);

  // --- Col 2: rotated labels inside node bars ---
  textAlign(CENTER, CENTER);

  // Not Managed (dim node — dark text for contrast)
  pushMatrix();
  translate(C2X + NW / 2, notmgd_y() + notmgd_h() / 2);
  rotate(-HALF_PI);
  textSize(isFull ? 40 : 44);
  fill(C_TEXT, 200);
  text("Not actively managed", 0, 0);
  popMatrix();

  // Managed (solid purple node — white text)
  pushMatrix();
  translate(C2X + NW / 2, mgd_y() + mgd_h() / 2);
  rotate(-HALF_PI);
  textSize(isFull ? 40 : 44);
  fill(255, 230);
  text("Actively managed", 0, 0);
  popMatrix();

  // --- Col 3: labels to the RIGHT ---
  textAlign(LEFT, CENTER);

  // Not Breached
  mid = safe_y() + safe_h() / 2;
  textSize(ts);
  fill(C_TEXT);
  text("No breach", C3X + NW + 24, mid - pct_gap / 2);
  textSize(ts_pct);
  fill(C_SAFE);
  text(nf(P_SAFE_N * 100, 0, 1) + "%", C3X + NW + 24, mid + pct_gap / 2);

  // Breached
  mid = bre_y() + bre_h() / 2;
  textSize(ts);
  fill(C_TEXT);
  text("Experienced a breach", C3X + NW + 24, mid - pct_gap / 2);
  textSize(ts_pct);
  fill(C_BREACH);
  text(nf(P_BRE_N * 100, 0, 1) + "%", C3X + NW + 24, mid + pct_gap / 2);
}

// =============================================================================
// TITLE  (full version only)
// =============================================================================
void drawTitle() {
  textAlign(LEFT, TOP);
  fill(C_TEXT);
  textSize(92);
  text("Having a policy isn't enough —", 200, 36);
  text("it's what you do with it that matters.", 200, 148);

  textSize(44);
  fill(C_TEXT, 130);
  text("Cyber Security Breaches Survey 2018–2025  |  Story 3 of 5: Policy & Management", 200, 270);

  textAlign(RIGHT, TOP);
  textSize(52);
  fill(C_TEXT);
  text("NODE9", 3508 - 80, 50);
}

// =============================================================================
// ANNOTATIONS  (full version only)
// =============================================================================
void drawAnnotations() {
  float e    = eff();
  float m23  = (C2X + NW + C3X) / 2.0;

  // Label the widest breach flow (NotMgd → Breached)
  // That flow starts at nm_out after NotMgd→Safe, which is notmgd_y + F_NM_S*e
  float flow_top = notmgd_y() + F_NM_S * e;
  float flow_bot = flow_top + F_NM_B * e;
  float flow_mid = (flow_top + flow_bot) / 2;

  textAlign(CENTER, BOTTOM);
  textSize(46);
  fill(C_BREACH);
  text("Highest risk: no policy, not managed", m23, flow_mid - 14);

  // Insight below chart
  textAlign(CENTER, TOP);
  textSize(50);
  fill(C_TEXT, 175);
  text(
    "61% of organisations have no formal policy — and most aren't actively managing cyber security at all.",
    3508 / 2, CB + 50
  );

  // How to read note
  textAlign(LEFT, TOP);
  textSize(38);
  fill(C_TEXT, 110);
  text("Wider flow = more organisations following that pathway.", C1X, CB + 50);
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
