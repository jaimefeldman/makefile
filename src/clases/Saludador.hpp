#pragma once

#include <string>

using namespace std;

class Saludador
{
public:
    Saludador() = default;
    string saluda();

private:
    uint8_t edad {0};
};

