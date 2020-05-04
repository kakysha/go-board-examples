#include "Vball.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

const int PERIOD = (1000 / 25); // 1000 / MHz, ns for one clock cycle
VerilatedVcdC* tfp;
unsigned int tickcount = 0;

Vball* tb;

void tick() {
	++tickcount;
	tb->eval();
	tb->i_clk = 1;
	tb->eval();
	tfp->dump(tickcount * PERIOD - PERIOD / 2);
	tb->i_clk = 0;
	tb->eval();
	tfp->dump(tickcount * PERIOD);
	tfp->flush();
}

int main(int argc, char** argv, char** env) {
	Verilated::commandArgs(argc, argv);
	tb = new Vball();
	Verilated::traceEverOn(true);
	tfp = new VerilatedVcdC();
	tb->trace(tfp, 99);
	tfp->open("trace.vcd");

	tb->i_enabled = 1;
	for (int n = 0; n < 60; n++)
		for (int row = 0; row < 30; row++)
			for (int col = 0; col < 40; col++)
				for (int clock = 0; clock < 35; clock++) {
					tb->i_col = col;
					tb->i_row = row;
					tick();
				}


	tfp->close();
	tb->final();
	delete tb;
	exit(0);
}