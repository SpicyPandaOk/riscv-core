PROGRAM ?= assembly.asm

.PHONY: compare rtl rtl-run cpp cpp-run assemble clean-compare

assemble:
	python3 sw/assembler.py sw/$(PROGRAM)



compare: rtl-run cpp-run
	grep -E '^(x[0-9]+ =|mem\[)' /tmp/rtl_out.txt > /tmp/rtl_filtered.txt
	grep -E '^(x[0-9]+ =|mem\[)' /tmp/cpp_out.txt > /tmp/cpp_filtered.txt
	diff /tmp/rtl_filtered.txt /tmp/cpp_filtered.txt && echo "MATCH" || echo "MISMATCH"

rtl-run:
	$(MAKE) -C docs run PROGRAM=../sw/$(PROGRAM) > /tmp/rtl_out.txt

rtl:
	$(MAKE) -C docs run PROGRAM=../sw/$(PROGRAM)



cpp-run: assemble
	$(MAKE) -C sw/simulator
	./sw/simulator/simulator > /tmp/cpp_out.txt
cpp: assemble
	$(MAKE) -C sw/simulator 
	./sw/simulator/simulator


clean-compare:
	rm -f /tmp/rtl_out.txt /tmp/cpp_out.txt
