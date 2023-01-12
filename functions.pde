/*********************************************************************************

This tab has functions that do various mathematical functions to complex numbers.
Feel free to add / modify these as you see fit.

For some single-valued functions, I have also added a Lambda representation for
the nested functions.

*********************************************************************************/

//reflects the first input across the second input
PVector reflect(PVector a, PVector b) {
  return a.rotate(2 * (b.heading() - a.heading()));
}

//multiplies two complex numbers together
PVector multComplex(PVector a, PVector b) {
  return new PVector(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

//finds the reciprocal of a complex number v (1/v)
PVector reciprocal(PVector v) {
  return new PVector(v.x / (v.x*v.x + v.y*v.y), -v.y / (v.x*v.x + v.y*v.y));
}

//finds the square of a complex number v
PVector square(PVector v) {
  return multComplex(v, v);
}
VectorLambda squareLambda = v -> square(v);

//raises a complex number v to an integer power n (uses recursion, is faster than the general implementation)
PVector power(PVector v, int n) {
  if (n == 1) return v;
  else return multComplex(v, power(v, n-1));
}

//divides complex v1 by complex v2
PVector divide(PVector v1, PVector v2) {
  return multComplex(v1, reciprocal(v2));
}

//returns e^v, where v is complex
PVector expComplex(PVector v) {
  return new PVector(Math.exp(v.x)*Math.cos(v.y), Math.exp(v.x)*Math.sin(v.y));
}
VectorLambda expLambda = v -> expComplex(v);

//returns hyperbolic sine (sinh) of complex number v
PVector sinhComplex(PVector v) {
  return expComplex(v).sub(expComplex(v.mult(-1))).mult(.5);
}
VectorLambda sinhLambda = v -> sinhComplex(v);

//returns hyperbolic cosine (cosh) of complex number v
PVector coshComplex(PVector v) {
  return expComplex(v).add(expComplex(v.mult(-1))).mult(.5);
}
VectorLambda coshLambda = v -> coshComplex(v);

//returns hyperbolic tangent (tanh) of complex number v
PVector tanhComplex(PVector v) {
  return divide(sinhComplex(v), coshComplex(v));
}
VectorLambda tanhLambda = v -> tanhComplex(v);

//returns sine of complex number v
PVector sinComplex(PVector v) {
  return new PVector(Math.sin(v.x)*Math.cosh(v.y), Math.cos(v.x)*Math.sinh(v.y));
}
VectorLambda sinLambda = v -> sinComplex(v);

//returns cosine of complex number v
PVector cosComplex(PVector v) {
  return new PVector(Math.cos(v.x)*Math.cosh(v.y), -1.0*Math.sin(v.x)*Math.sinh(v.y));
}
VectorLambda cosLambda = v -> cosComplex(v);

//returns tangent of complex number v
PVector tanComplex(PVector v) {
  return divide(sinComplex(v), cosComplex(v));
}
VectorLambda tanLambda = v -> tanComplex(v);

//returns cotangent of complex number v
PVector cotComplex(PVector v) {
  return divide(cosComplex(v), sinComplex(v));
}
VectorLambda cotLambda = v -> cotComplex(v);

//returns the natural log (principal value) of complex number v
PVector natLog(PVector v) {
  return new PVector(Math.log(v.mag()), Math.atan2(v.y, v.x));
}
VectorLambda natLogLambda = v -> natLog(v);

//returns a complex number v1 to the power of another complex number v2
PVector powerComplex(PVector v1, PVector v2) {
  return expComplex(multComplex(v2, natLog(v1)));
}

//returns the result of a function f evaluated on v nested num times, e.g. sin(sin(sin(x))) for nestFunction(v, sinLambda, 2)
PVector nestFunction(PVector v, VectorLambda f, int num) {
  if (num == 0) return f.run(v);
  else return f.run(nestFunction(v, f, num - 1));
}

//returns nested functions using the pattern f(x), f(f(x)*x), f(f(f(x)*x)*x), and so forth
//USE LAMBDA representation of function for f, and number of nests for num
PVector nestMultFunction(PVector v, VectorLambda f, int num) {
  if (num == 0) return f.run(v);
  else return f.run(multComplex(nestMultFunction(v, f, num - 1), v));
}

//helper override of the map functions to work with doubles instead of floats
double map(double n, double low1, double high1, double low2, double high2) {
  return low2 + ((high2 - low2) * (n - low1) / (high1 - low1));
}

//interface that allows for lambda representations of single-valued functions
interface VectorLambda {
  PVector run(PVector v);
}
