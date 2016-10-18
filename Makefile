CFLAGS = -msse2 --std gnu99 -O0 -Wall

GIT_HOOKS := .git/hooks/pre-commit

all: $(GIT_HOOKS) main.c
	$(CC) $(CFLAGS) -DVERIFY -o main main.c

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

bench: $(GIT_HOOKS) main.c
	$(CC) $(CFLAGS) -DBENCH -o $@ main.c

perf: bench
	echo "echo 1 > /proc/sys/vm/drop_caches" | sudo sh
	sudo perf stat -r 100 -e cache-misses -e cache-references -e instructions -e cycles ./bench > result.txt
	gnuplot plot/exec.gp

prefetch: $(GIT_HOOKS) main.c
	$(CC) $(CFLAGS) -DPREFETCH_BENCH -o $@ main.c

gencsv: prefetch
	./prefetch > result.csv       

clean:
	$(RM) main bench prefetch result.txt *.png *.csv
