import java.awt.Rectangle;

interface Transform {
  void transform();
  void tick();
  LineSegment draw();
}

interface Speedable extends Transform {
  float getSpeed();
  void setSpeed(float speed);
}

interface Positionable extends Transform {
  PVector getPos();
  void setPos(PVector pos);
}

interface Colorable extends Transform {
  int col = 255;
  void setColor(float r, float g, float b, float a);
  void setColor(int col);
}

class Pen implements Positionable, Colorable {
  PVector pos;
  PVector lastPos;
  int col;
  public Pen(PVector offset, int col) {
    this.pos = offset;
    this.col = col;
  }
  public void transform() {
    //translate(offset.x, offset.y);
  }
  void tick() {

  }
  public void setColor(float r, float g, float b, float a) {
    this.col = color(r*255,g*255,b*255,a*255);
  }
  public void setColor(int c) {
    this.col = c;
  }
  public void setPos(PVector pos) {
    this.pos = pos;
  }
  public PVector getPos() {
    return this.pos;
  }
  public LineSegment draw() {
    PVector p = new PVector(modelX(pos.x, pos.y, 0), modelY(pos.x, pos.y, 0));
    if (lastPos == null) {
      lastPos = p;
    }
    LineSegment res = new LineSegment(
      lastPos.x, lastPos.y,
      p.x, p.y, col);
    lastPos = p;
    return res;
  }
}

class Anchor implements Positionable {
  PVector pos;
  public Anchor(PVector disp) {
    this.pos = disp;
  }
  public LineSegment draw() {
    return null;
  }
  public void transform() {
    translate(pos.x, pos.y);
  }
  public void setPos(PVector pos) {
    this.pos = pos;
  }
  public PVector getPos() {
    return this.pos;
  }
  void tick() {

  }
}

class Translator implements Positionable {
  PVector pos;
  PVector vel;
  Rectangle bounds;
  public Translator(PVector disp, PVector vel, Rectangle bounds) {
    this.pos = disp;
    this.vel = vel;
    this.bounds = bounds;
  }
  public Translator(PVector velocity) {
    this(new PVector(0,0), velocity, new Rectangle(0,0,640,640));
  }
  public void setPos(PVector pos) {
    this.pos = pos;
  }
  public PVector getPos() {
    return this.pos;
  }
  void tick() {
    pos.add(vel);
    if (bounds.width + bounds.x < pos.x || bounds.x > pos.x) {
      vel.x *= -1;
    } else if (bounds.height + bounds.y < pos.y || bounds.y > pos.y) {
      vel.y *= -1;
    }
  }
  
  public void transform() {
    translate(pos.x, pos.y);
  }
  public LineSegment draw() {
    //rect(bounds.x, bounds.y, bounds.w, bounds.h);
    return null;
  }
}

class Rotator implements Speedable, Positionable {
  float defl = 0;
  public float speed;
  PVector pos;
  public Rotator(float speed) {
    this(new PVector(0,0), speed);
  }
  public Rotator(PVector center, float speed) {
    this.pos = center;
    this.speed = speed;
  }
  public LineSegment draw() {
    return null;
  }
  void tick() {
    defl += speed;
  }
  public void transform() {
    translate(pos.x, pos.y);
    rotate(defl);
  }
  public void setPos(PVector pos) {
    this.pos = pos;
  }
  public PVector getPos() {
    return this.pos;
  }
  public float getSpeed() {
    return this.speed;
  }
  public void setSpeed(float speed) {
    this.speed = speed;
  }
}

class Path implements Speedable {
  RingBuffer<PVector> points = new RingBuffer<PVector>();
  public float speed;
  float lerp = 0;
  PVector origin;
  PVector lastPoint;
  PVector target;
  int count = 0;
  public Path(float speed) {
    this.speed = speed;
  }
  public Path point(PVector p) {
    if (lastPoint == null) lastPoint = p;
    points.add(p);
    return this;
  }
  public Path point(float x, float y) {
    PVector p = new PVector(x,y);
    return point(p);
  }
  public LineSegment draw() {
    return null;
  }
  void tick() {
    if (points.size() < 1) return;
    if (lastPoint == null) {
      lastPoint = points.moveNext();
      origin = lastPoint;
    }
    if (target == null) {
      target = points.moveNext();
    }
    if (PVector.dist(lastPoint, target) < speed) {
      //we've arrived
      lastPoint = target;
      origin = target;
      target = points.moveNext();
      count = 0;
    } else {
      float d = PVector.dist(origin, target);
      float step = speed / d * count;
      lastPoint = PVector.lerp(origin, target, step);
      count++;
    }
  }
  public void transform() {
    translate(lastPoint.x, lastPoint.y);
  }
  public float getSpeed() {
    return this.speed;
  }
  public void setSpeed(float speed) {
    this.speed = speed;
  }
}

class RingBuffer<T> {
  ArrayList<T> content = new ArrayList<T>();
  int idx = -1;
  public void add(T i) {
    content.add(i);
  }
  public T moveNext() {
    idx++;
    idx %= content.size();
    return content.get(idx);
  }

  public int size() {
    return content.size();
  }
  public T peekLast() {
    int last = idx - 1;
    if (last < 0) last = content.size() - 1;
    return content.get(last);
  }
}

class Ellipse implements Speedable, Positionable {
  float major, minor, x, y;
  public float speed;
  int dir = 1;
  PVector pos;
  public Ellipse(PVector center, float major, float minor, float speed) {
    this.pos = center;
    this.major = major;
    this.minor = minor;
    this.speed = speed;
    this.x = 0.00;
  }
  public LineSegment draw() {
    return null;
  }
  void tick() {
    x += speed * dir;
    if (x >= major || x <= -major) {
       dir *= -1;
       x = constrain(x, -major, major);
    }
    if (major != 0) {
      y = minor / major * sqrt(major * major - x * x) ;
    }
  }
  public void transform() {
    translate(pos.x, pos.y);
    translate(x, y * dir);
  }
  public void setPos(PVector pos) {
    this.pos = pos;
  }
  public PVector getPos() {
    return this.pos;
  }
  public float getSpeed() {
    return this.speed;
  }
  public void setSpeed(float speed) {
    this.speed = speed;
  }
}

class SinTranslator implements Speedable, Positionable{
  float scaleX, scaleY, tick;
  public float speed;
  PVector pos;
  public SinTranslator(PVector center, float scaleX, float scaleY, float speed) {
    this.scaleX = scaleX;
    this.scaleY = scaleY;
    this.speed = speed;
    this.pos = center;
  }

  void tick() {
    tick += speed;
  }

  public LineSegment draw() { return null; }
  public void transform() {
    translate(pos.x + sin(tick) * scaleX, pos.y + cos(tick) * scaleY);
  }
  public void setPos(PVector pos) {
    this.pos = pos;
  }
  public PVector getPos() {
    return this.pos;
  }
  public float getSpeed() {
    return this.speed;
  }
  public void setSpeed(float speed) {
    this.speed = speed;
  }
}