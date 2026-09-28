RTL  = ../../rtl
SRCS = $(RTL)/alu.sv tb.sv

run: obj_dir/Vtb
	./obj_dir/Vtb

obj_dir/Vtb: $(SRCS)
	verilator --binary --assert -j 0 -Wall --top-module tb $(SRCS)

clean:
	rm -rf obj_dir

.PHONY: run clean
