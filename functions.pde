PVector reflect(PVector a, PVector b) {
  return a.rotate(2 * (b.heading() - a.heading()));
}

PVector multComplex(PVector a, PVector b) {
  return new PVector(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

PVector reciprocal(PVector v) {
  return new PVector(v.x / (v.x*v.x + v.y*v.y), -v.y / (v.x*v.x + v.y*v.y));
}

PVector square(PVector v) {
  return multComplex(v, v);
}

PVector power(PVector v, int n) {
  if (n == 1) return v;
  else return multComplex(v, power(v, n-1));
}

PVector divide(PVector v1, PVector v2) {
  return multComplex(v1, reciprocal(v2));
}

PVector expComplex(PVector v) {
  return new PVector(Math.exp(v.x)*Math.cos(v.y), Math.exp(v.x)*Math.sin(v.y));
}

PVector sinhComplex(PVector v) {
  return expComplex(v).sub(expComplex(v.mult(-1))).mult(.5);
}

PVector coshComplex(PVector v) {
  return expComplex(v).add(expComplex(v.mult(-1))).mult(.5);
}

PVector tanhComplex(PVector v) {
  return divide(sinhComplex(v), coshComplex(v));
}

PVector sinComplex(PVector v) {
  return new PVector(Math.sin(v.x)*Math.cosh(v.y), Math.cos(v.x)*Math.sinh(v.y));
}

PVector cosComplex(PVector v) {
  return new PVector(Math.cos(v.x)*Math.cosh(v.y), -1.0*Math.sin(v.x)*Math.sinh(v.y));
}

PVector tanComplex(PVector v) {
  return divide(sinComplex(v), cosComplex(v));
}

PVector cotComplex(PVector v) {
  return divide(cosComplex(v), sinComplex(v));
}

PVector natLog(PVector v) {
  return new PVector(Math.log(v.mag()), Math.atan2(v.y, v.x));
}

PVector powerComplex(PVector v1, PVector v2) {
  return expComplex(multComplex(v2, natLog(v1)));
}

double map(double n, double low1, double high1, double low2, double high2) {
  return low2 + ((high2 - low2) * (n - low1) / (high1 - low1));
}
