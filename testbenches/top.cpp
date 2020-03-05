#include "Vtop.h"
#include "verilated.h"

int main(int argc, char** argv, char** env) {
	Verilated::commandArgs(argc, argv);
	Vtop* top = new Vtop;
	//top->
	while (!Verilated::gotFinish()) { top->eval(); }
	delete top;
	exit(0);
}