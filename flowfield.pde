final float CURVE_COUNT = 10000, RESOLUTION = 0.001; //<>//
final float STEP_COUNT = 1000, STEP_LENGTH = 1;
final float NOISE_SCALE_X = .005, NOISE_SCALE_Y = .005, NOISE_FALLOFF = .25;
final float CURVE_TIGHTNESS = 1, STROKE_WEIGHT = .1;
final float MARGIN = .5;
final int OCTAVE_COUNT = 16;
int NOISE_SEED = 5;
final boolean FIXED_SEED = false;
int res;
float leftx, rightx, topy, boty, cols, rows;
PVector[][] grid;
float defaultAngle;


void setup() {
  size(1000, 1000);
  background(255);
  noFill();
  curveTightness(CURVE_TIGHTNESS);
  noiseDetail(OCTAVE_COUNT, NOISE_FALLOFF);
  if (FIXED_SEED) {
    noiseSeed(NOISE_SEED);
  }

  //build empty grid according to screen size, margin, resolution
  leftx = int(width * -MARGIN);
  rightx = int(width * (1 + MARGIN));
  topy = int(height * -MARGIN);
  boty = int(height * (1 + MARGIN));
  res = int(width * RESOLUTION);
  cols = (rightx - leftx) / res;
  rows = (boty - topy) / res;
  
  int tx = int(cols);
  int ty = int(rows);
  grid = new PVector[tx][ty]; //<>//
}

void draw() {
  noLoop(); //static image
  background(255);

  //generate new noise seed every draw()
  if (!FIXED_SEED) {
    NOISE_SEED = int(random(MAX_INT));
    noiseSeed(NOISE_SEED);
  }

  for (int col = 0; col < cols; col++) {
    for (int row = 0; row < rows; row++) {
      float scaledx = col * NOISE_SCALE_X;
      float scaledy = row * NOISE_SCALE_Y;

      float noiseVal = noise(scaledx, scaledy);

      float angle = map(noiseVal, 0.0, 1.0, 0.0, TWO_PI);
      float bx = leftx + (col * (rightx - leftx)/cols);
      float by = topy + (row * (boty - topy)/rows);
      grid[col][row] = new PVector(bx, by, angle);
    }
  }

  //loop through grid assigning angles to z values
  //for (int col = 0; col < cols; col++) {
  //  for (int row = 0; row < rows; row++) {
  //    float bx = leftx + (col * (rightx - leftx)/cols);
  //    float by = topy + (row * (boty - topy)/rows);
  //    grid[col][row] = new PVector(bx, by, defaultAngle);
  //  }
  //}

  //visualize grid vectors
  //for (int col = 0; col < cols; col++) {
  //  for (int row = 0; row < rows; row++) {
  //    float bx = grid[col][row].x;
  //    float by = grid[col][row].y;
  //    PVector angle = PVector.fromAngle(grid[col][row].z).mult(10);
  //    circle(bx,by,5);
  //    line(bx,by,bx+angle.x, by+angle.y);
  //  }
  //}

  //draw CURVE_COUNT curves with random starts within grid bounds
  for (int count = 0; count < CURVE_COUNT; count++) {
    drawCurve(random(leftx, rightx), random(topy, boty), STEP_LENGTH, int(STEP_COUNT));
  }
}

void drawCurve(float startx, float starty, float step, int steps) {
  float t = STROKE_WEIGHT;

  float x = startx;
  float y = starty;

  beginShape();


  for (int n = 0; n < steps; n++) {
    curveVertex(x, y);

    float ax = x - leftx;
    float ay = y - topy;

    int col = int(ax/res);
    int row = int(ay/res);

    if (col < 0 || col >= cols || row < 0 || row >= rows) {
      break;
    }

    float  angle = grid[col][row].z;

    float dx = step * cos(angle);
    float dy = step * sin(angle);

    x += dx;
    y += dy;
    t += .01;
  }
  endShape();
}

void keyPressed() {
  if (keyCode == UP) {
    String serial = String.valueOf(CURVE_COUNT).concat(String.valueOf(res)).concat(String.valueOf(STEP_COUNT)).concat(String.valueOf(NOISE_SEED));
    saveFrame("[absolute file path]" + serial + "-#####.png");
  } else {
    redraw();
  }
}
