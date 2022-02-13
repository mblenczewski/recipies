.PHONY: clean debug memcheck release run threadcheck

MEMCHECK := valgrind --tool="memcheck" --leak-check=full --show-leak-kinds=all --track-origins=yes -s
THREADCHECK := valgrind --tool="helcheck"

run: debug
	./out/recipies

debug: clean
	REGIME=DBG ./build

release: clean
	REGIME=REL ./build

clean:
	./clean

memcheck: debug
	$(MEMCHECK) ./out/recipies

threadcheck: debug
	$(THREADCHECK) ./out/recipies
