/*
Guodong Rong and Tiow-Seng Tan. 2006. Jump flooding in GPU with applications to Voronoi diagram and distance transform.
 In Proceedings of the 2006 symposium on Interactive 3D graphics and games (I3D '06).
 ACM, New York, NY, USA, 109-116.
 DOI: https://doi.org/10.1145/1111411.1111431
 */
import java.util.*;

class Pos {
  int x, y;

  Pos(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

class JF {
  float[][][]   positions;
  float[][] distances;
  int[][]   labels;

  JF(int w, int h) {
    positions = new float[w][h][2];
    distances = new float[w][h];
    labels = new int[w][h];
  }
}

void stepJF(JF source, JF target, int step) {
  final int w = source.positions.length;
  final int h = source.positions[1].length;

  Pos[] p = new Pos[8];
  for (int i = 0; i < p.length; i++) {
    p[i] = new Pos(0, 0);
  }

  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      // bottomLeft
      p[0].x = x-step; 
      p[0].y = y+step;
      // bottom
      p[1].x = x; 
      p[1].y = y+step;
      // bottom rigt
      p[2].x = x+step; 
      p[2].y = y+step;
      // right
      p[3].x = x+step; 
      p[3].y = y;
      // top right
      p[4].x = x+step; 
      p[4].y = y-step;
      // top
      p[5].x = x; 
      p[5].y = y-step;
      // top left
      p[6].x = x-step; 
      p[6].y = y-step;
      // left
      p[7].x = x-step; 
      p[7].y = y;

      int nLabel = source.labels[x][y];
      float nd = source.distances[x][y];
      float[] nseedPos = source.positions[x][y];

      for (int i = 0; i < 8; i++) {
        if (p[i].x >= 0 && p[i].x < w && p[i].y >= 0 && p[i].y < h) {
          int inLabel = source.labels[p[i].x][p[i].y];
          //float inDistance = source.distances[p[i].x][p[i].y];
          float[] seedPos = source.positions[p[i].x][p[i].y];

          // if you see a seed closer to (i, j) than one you’ve seen before, you store its color and location.
          // Also if you visit a non-seed that’s seen a nearby seed which is closer than one you’ve seen before
          // - you store that seed’s color and location.
          if (inLabel >= 0) {
            float d = sqrt(pow(seedPos[0]-x, 2)+pow(seedPos[1]-y, 2));
            if (d < nd) {
              // a seed that is closer
              nLabel = inLabel;
              nd = d;
              nseedPos = seedPos;
            }
          }
        }
      }

      target.labels[x][y] = nLabel;
      target.distances[x][y] = nd;
      target.positions[x][y] = nseedPos;
    }
  }
}

int[][] computeDiagram(int w, int h, Vector<Pos> points) {
  JF source = new JF(w, h), target = new JF(w, h);


  // init the JFA data structures
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      source.positions[x][y][0] = -1;
      source.positions[x][y][1] = -1;
      source.distances[x][y] = Float.MAX_VALUE;
      source.labels[x][y] = -1;
    }
  }
  int label = 0;
  for (Pos p : points) {
    source.positions[p.x][p.y][0] = p.x+0.5f;
    source.positions[p.x][p.y][1] = p.y+0.5f;
    source.distances[p.x][p.y] = 0.f;
    source.labels[p.x][p.y] = label++;
  }

  // step 
  int mStep = (int)pow(2, ceil(log(max(w, h)) / log(2)));
  int mod = 0;
  for (int step = mStep; step > 0; step /= 2, mod++) {
    if ((mod % 2) == 0) {
      stepJF(source, target, step);
    } else {
      stepJF(target, source, step);
    }
  }
  int[][] diagram = ((mod % 2) == 0) ? source.labels : target.labels;

  final int nLabels = points.size();
  color[] colors = new color[nLabels];
  for (int i = 0; i < nLabels; i++) {
    colors[i] = color(random(0, 255), random(0, 255), random(0, 255));
  }
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) { 
      set(x, y, colors[diagram[x][y]]);
    }
  }

  return diagram;
}

void setup() {
  size(1280, 1280);
}

void draw() {
  Vector<Pos> points = new Vector<Pos>(200);
  for (int i = 0; i < 200; i++) {
    points.add(i, new Pos((int)random(0, width-1), (int)random(0, height-1)));
  }
  computeDiagram(width, height, points);
  
  stroke(255);
  fill(255);
  smooth();
  strokeWeight(5);
  for (Pos p : points) {
    point(p.x, p.y);
  }
}