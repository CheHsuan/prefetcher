reset
set xlabel "RUN"
set ylabel "Execution Time(usec)"
set title "Matrix Transpose"
set term png enhanced font 'Consolas,10'
set output 'runtime.png'

plot "result.txt" using 1 with linespoints title "sse prefetch", \
     "result.txt" using 2 with linespoints title "sse prefetch omp", \
     "result.txt" using 3 with linespoints title "sse", \
     "result.txt" using 4 with linespoints title "sse omp", \
     "result.txt" using 5 with linespoints title "naive", \
     "result.txt" using 6 with linespoints title "naive omp"
