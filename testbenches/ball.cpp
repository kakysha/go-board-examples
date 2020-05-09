#include "Vball.h"
#include "verilated.h"
#include "TESTBENCH.h"
#include "vga/vgasim.h"

int main(int argc, char** argv, char** env) {
	Gtk::Main	main_instance(argc, argv);
	VGAWIN m_vga;

	Verilated::commandArgs(argc, argv);
	auto tb = new TESTBENCH<Vball>();
	auto m = tb->m;

	m->i_enabled = 1;
	for (int n = 0; n < 60; n++) {
		for (int row = 0; row < 30; row++) {
			for (int col = 0; col < 40; col++) {
				for (int clock = 0; clock < 350; clock++) {
					m->i_col = col;
					m->i_row = row;
					tb->tick();
				}
			}
		}
	}

	Gtk::Main::run(m_vga);

	delete tb;
}