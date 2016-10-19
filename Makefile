CFLAGS = -msse2 --std gnu99 -O0 -Wall -fopenmp
exec = main bench sse_only sse_prefetch pfdist

GIT_HOOKS := .git/hooks/pre-commit

all: $(GIT_HOOKS) main.c
	$(CC) $(CFLAGS) -DVERIFY -o main main.c

bench:
	$(CC) $(CFLAGS) -DBENCH -o $@ main.c

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

plot: bench
	echo "echo 1 > /proc/sys/vm/drop_caches" | sudo sh
	sudo perf stat -r 100 -e cache-misses -e cache-references -e instructions -e cycles ./bench > result.txt
	gnuplot plot/exec.gp

sse_only: $(GIT_HOOKS) sse_prefetch_benchmark.c
	$(CC) $(CFLAGS) -o $@ sse_prefetch_benchmark.c

sse_prefetch: $(GIT_HOOKS) sse_prefetch_benchmark.c
	$(CC) $(CFLAGS) -DSSE_PREFETCH -o $@ sse_prefetch_benchmark.c

prefetch_perf: sse_only sse_prefetch
	sudo perf stat -r 10 -e cache-misses -e cache-references -e instructions -e cycles ./sse_only
	sudo perf stat -r 10 -e cache-misses -e cache-references -e instructions -e cycles ./sse_prefetch

pfdist: $(GIT_HOOKS) main.c
	$(CC) $(CFLAGS) -DPREFETCH_BENCH -o $@ main.c

gencsv: pfdist
	printf "Prefetch Distance,Time\n" > result.csv
	for i in `seq 0 8 200`; do\
	    echo "echo 1 > /proc/sys/vm/drop_caches" | sudo sh; \
	    ./pfdist $$i >> result.csv; \
	done

array = 0 8 16 160 200
pfdist_perf: pfdist
	for i in $(array); do \
	    echo "echo 1 > /proc/sys/vm/drop_caches" | sudo sh; \
	    sudo perf stat -r 10 -e cache-misses -e cache-references -e instructions -e cycles ./pfdist $$i; \
	done

clean:
	$(RM) $(exec) result.txt *.png *.csv
