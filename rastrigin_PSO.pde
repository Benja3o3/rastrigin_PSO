// PSO de acuerdo a Talbi (p.247 ss)

PImage surf; // imagen que entrega el fitness
int DIM = 2;

// ===============================================================
int puntos = 100;
Particle[] fl; // arreglo de partículas
float d = 15; // radio del círculo, solo para despliegue
float gbestx, gbesty, gbest=1000; // posición y fitness del mejor global
float gbestxm,gbestym;
float w = 500; // inercia: baja (~50): explotación, alta (~5000): exploración (2000 ok)
float C1 = 30, C2 =  10; // learning factors (C1: own, C2: social) (ok)
int evals = 0, evals_to_best = 0; //número de evaluaciones, sólo para despliegue
float maxv = 3; // max velocidad (modulo)

class Particle{
  float x, y, fit; // current position(x-vector)  and fitness (x-fitness)
  float px, py, pfit; // position (p-vector) and fitness (p-fitness) of best solution found by particle so far
  float vx, vy; //vector de avance (v-vector)
  float evalx, evaly;
  
  // ---------------------------- Constructor
  Particle(){
    x = random (width); y = random(height);
    println("x ",x," y ",y);
    vx = random(-1,1) ; vy = random(-1,1);
    pfit = 1000; fit = 1000; //asumiendo que no hay valores menores a -1 en la función de evaluación
  }
  
  // ---------------------------- Evalúa partícula
  float Eval(){
    evalx = (x - 300)/100;
    evaly = (y - 300)/100; //recibe imagen que define función de fitness
    evals++;
    // color c=surf.get(int(x),int(y)); // obtiene color de la imagen en posición (x,y)
    fit = rastrigin(evalx,evaly);
    // fit = red(c); //evalúa por el valor de la componente roja de la imagen
    if(fit < pfit){ // actualiza local best si es mejor
      pfit = fit;
      px = x; 
      py = y;
    }
    if (fit < gbest){ // actualiza global best
      gbest = fit;
      gbestx = x;
      gbesty = y;
      evals_to_best = evals;
      println(str(gbest));
      println(evalx,evaly);
    };
    return fit; //retorna la componente roja
  }
  
  // ------------------------------ mueve la partícula
  void move(){
    //actualiza velocidad (fórmula con factores de aprendizaje C1 y C2)
    //vx = vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    //vy = vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    //actualiza velocidad (fórmula con inercia, p.250)
    vx = w * vx + random(0,1)*(px - x) + random(0,1)*(gbestx - x);
    vy = w * vy + random(0,1)*(py - y) + random(0,1)*(gbesty - y);
    //actualiza velocidad (fórmula mezclada)
    //vx = w * vx + random(0,1)*C1*(px - x) + random(0,1)*C2*(gbestx - x);
    //vy = w * vy + random(0,1)*C1*(py - y) + random(0,1)*C2*(gbesty - y);
    // trunca velocidad a maxv
    float modu = sqrt(vx*vx + vy*vy);
    if (modu > maxv){
      vx = vx/modu*maxv;
      vy = vy/modu*maxv;
    }
    // update position
    x = x + vx;
    y = y + vy;
    // rebota en murallas
    if (x > width || x < 0) vx = - vx;
    if (y > height || y < 0) vy = - vy;
  }
  
  // ------------------------------ despliega partícula
  void display(){
    fill(255,0,0);
    ellipse (x,y,d,d);
    // dibuja vector
  }
} //fin de la definición de la clase Particle

float rastrigin(float x,float y){
  float sum = 10*DIM;
  sum += pow(x, 2) - 10*cos(2*PI*x);
  sum += pow(y, 2) - 10*cos(2*PI*y);
  return sum; 
}

// dibuja punto azul en la mejor posición y despliega números
void despliegaBest(){
  fill(255,255,255);
  ellipse(gbestx,gbesty,d,d);
  PFont f = createFont("Arial",16,true);
  fill(0,0,0);
  textFont(f,15);
  text("Best fitness: "+str(gbest)+"\nEvals to best: "+str(evals_to_best)+"\nEvals: "+str(evals),10,920);
}

// ===============================================================

void setup(){  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //size(1440,720); //setea width y height
  //surf = loadImage("marscyl2.jpg");
  size(1000,1000); //setea width y height (de acuerdo al tamaño de la imagen)
  surf = createImage(1000, 1000, RGB);
  surf.loadPixels();
  for (int i = 0; i < 1000; i++) {
    for (int j = 0; j < 1000; j++){
      float val = rastrigin((i-300)/100.0,(j-300)/100.0);
      surf.pixels[i*1000+j] = color(0,val*3,255-(val*3));
    } 
  }
  surf.updatePixels();
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  smooth();
  // crea arreglo de objetos partículas
  fl = new Particle[puntos];
  for(int i =0;i<puntos;i++)
    fl[i] = new Particle();
}

void draw(){
  // background(255,255,255);
  image(surf,0,0);
  //despliega mapa, posiciones  y otros
  dibujarPlano();
  for(int i = 0;i<puntos;i++){
    fl[i].display();
  }
  //mueve puntos
  for(int i = 0;i<puntos;i++){
    fl[i].move();
    fl[i].Eval();
  }
  despliegaBest();
}

void dibujarPlano(){
  stroke(0);
  strokeWeight(2);
  line(0,300,1000,300);
  line(300,0,300,1000);
  for (int i = 0; i < 10; i++){
    line(i*100,297,i*100,303);
    line(297,i*100,303,i*100);
  }
}
