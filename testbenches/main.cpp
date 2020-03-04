#include "Vmain.h"
#include "verilated.h"

int main(int argc, char** argv, char** env) {
	Verilated::commandArgs(argc, argv);
	Vmain* top = new Vmain;
	top->
	while (!Verilated::gotFinish()) { top->eval(); }
	delete top;
	exit(0);
}