#include <iostream>
#include "clases/Saludador.hpp"

extern "C" {
    #include "clang/calculadora.h"
}

using namespace std;

int main(int argc, char *argv[])
{
    cout << "Probando Makefile para C y C++" << endl;
    Saludador *saluador = new Saludador(); 
    cout << saluador->saluda() << endl;
    cout << "función en C, calculadora [10 + 10]: " << suma(10,10) << endl;
    delete saluador;
    return 0;
}
