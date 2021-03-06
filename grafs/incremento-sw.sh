#!/bin/bash

# Graficar la longitud de las negociaciones
# NOTA:
#      gnuplot <<- EOF
#         Aqui poner cualquier archivo de gnuplot remplazando $ por \$
#      EOF

#!/bin/bash

# infocorrida.txt
# Num_tot_agentes $nagen
# Num_tot_pruebas $fin
# Num_de_pruebas $it
# Num_tot_estrategias $stnum
# Num_det_estrategia $st


# Generar datos
#nagen=$(head -n 1 ./0/infocorrida.txt |tail -n 1 | awk '{print $2}')
#pruebas=$(head -n 2 ./0/infocorrida.txt |tail -n 1 | awk '{print $2}')
#it=$(head -n 3 ./0/infocorrida.txt |tail -n 1 | awk '{print $2}')
#stnum=$(head -n 4 ./0/infocorrida.txt |tail -n 1 | awk '{print $2}')
#st=$(head -n 5 ./0/infocorrida.txt |tail -n 1 | awk '{print $2}')

path=$1
cd $path

echo "Estoy en: "$PWD


# Generar datos
file=incremento-sw
rm -f $file.txt

cd SCN000
ind=$(head -n 1 ./agente0 |tail -n 1 | wc -w)
cd ..
echo "ind vale: "$ind;

#cd ../salida
for e in *; do
	cd $e
	nagen=$(ls agente* | wc -l);
	swis=0;
	swfs=0;


	for (( itag=1; itag<$nagen; itag=itag+1 ))
	do
		swi=$(head -n 1 "agente"$itag | awk -v myvar="$ind" '{print $myvar}');
		swf=$(tail -n 1 "agente"$itag | awk -v myvar="$ind" '{print $myvar}');
		swis=$((swis + swi));
		swfs=$((swfs + swf));
	done;
	cd ..
	echo "scale=2;100*$swfs/$swis" | bc >> "../grafs/"$file.txt
done

cd ../grafs
# Graficar
min_max_prom=$(awk 'NR == 1 { max=$1; min=$1; sum=0 } { if ($1>max) max=$1; if ($1<min) min=$1; sum+=$1;} END {printf "%d %d %.2f", min, max, sum/NR}' $file.txt)
min=$(echo $min_max_prom | awk '{print $1}')
max=$(echo $min_max_prom | awk '{print $2}')
prom=$(echo $min_max_prom | awk '{print $3}')
echo min $min, max $max, prom $prom

gnuplot <<- EOF
        set key box
        set title  "Incremento del Beneficio Social(%), Estrategia $st"
        set xlabel "Incremento"
        set ylabel "Cantidad de negociaciones"
        set palette gray
#         n=20 #number of intervals
#         width=($max-0.9*$min)/n #interval width
        width=25
      	set yrange [0:40]
	set parametric
   	set dummy t
    	set trange [0:40]
      	set xrange [$min-0.5*width:$max+0.5*width]
     	set terminal png
#   	set terminal postscript eps monochrome enhanced font 'Helvetica,20'
        set key font ",20"
        set boxwidth width*0.8
        set style fill solid 0.5
        set tics out nomirror
        set output "$file.png"
	bin(x,width)=width*floor(x/width)
 	plot '$file.txt' u (bin(\$1,width)):(1.0) smooth freq with boxes lw 3 lt rgb "black" title "Estrategia $st",\
      	      $prom,t lt 2 lc rgb "black" lw 1 title "Mean $prom"
EOF
