#!/bin/bash
# The (C) Krzysztof Paz for filesystem and disks testing on MacOS #
# Run script: ./scriptname NumberOfThreadsInParalel
# Run script: ./alltest.sh 9
# ---
#  required space est. = base 120GB + N(loops) * x(threads) * 10GB = eg.:
#  a) 120GB + 1 * 1 * 10GB = 120 + 10 = 130GB as min.
#  b) 120GB + 8 * 1 * 10GB = 120 + 80 = 200GB as basic
#  c) 120GB + 8 * 3 * 10GB = 120 + 240 = 360GB as std.
#  d) 120GB + 3 * 13 * 10GB = 120 + 390 = 510GB =~0.5TB
#  e) 120GB + 10 * 9 * 10GB = 120 + 900 = 1020GB =~ 1TB.
#  f) 120GB + 90 * 1 * 10GB = 120 + 900 = 1020GB =~ 1TB.
# --- etc. ---
clear
# Number of loops (N) for all threads repetitions:
N=10

# detect the specified param for number of paralel threads = x:
if [ $# -eq 0 ]
  then
    UserValue=3
 else
    UserValue=$1
fi

main () {
# Test starting time:
echo "------------------------------------------------"
echo "Filesystem workloads running with $UserValue thread(s)."
echo "------------------------------------------------"
date
echo "--------------------------------"

# A few small files for reading later on in loops:
sync; time sh -c "dd if=/dev/zero of=tzeros10GB.bin bs=1m count=10k && sync"
# sync; time sh -c "cat tzeros10GB.bin | tr '\0' '\377' > tones10GB.bin && sync" # good on linux but for Apple MacOS compat below:
# sync; time sh -c "dd if=/dev/zero ibs=1m count=10k | LC_ALL=C tr "\000" "\377" > tones10GB.bin && sync" # tr - a very slow on MAC, going with perl:
sync; time sh -c "LC_ALL=C perl -e 'printf "1" x 1073741 for 1..10000' > tones10GB.bin && sync"
# sync; time sh -c "perl -e 'srand(time() ^ $$); while (1) { print chr(int(rand() * 255)); }' | dd of=trandom10GB.bin bs=1m count=10k && sync"

# The one bigger file for write testing and clear caches before loops:
sync; time sh -c "dd if=/dev/zero of=tfile100GB.bin bs=1m count=100k && sync" &
# 	- clear disk cache (requires root/sudo privs) #
# sync; echo 1 > /proc/sys/vm/drop_caches; sync

# Then repeat everything below N times for good average on number of READs on 3rd process and concurrent writes in others:
x=1
while [ $x -le $N ]
do
  # Start the N user tasks in paralel processes
  for i in $(seq 1 $UserValue)
  do
    if [ $i -eq 3 ]
    then
	echo " > Loop $x - started thread no: $i with reading and writing few files < "
	sh -c "dd if=tzeros10GB.bin of=/dev/null" &
    	sh -c "dd if=/dev/zero of=tfile5GBa-$x-$i bs=1m count=5k" &
	sh -c "dd if=tfile100GB.bin of=/dev/null" &
    	sh -c "dd if=/dev/zero of=tfile5GBb-$x-$i bs=1m count=5k" &
	sh -c "dd if=tones10GB.bin of=/dev/null" &
    else
    	echo " > Loop $x - started thread no: $i just for writing a file < "
    	sh -c "dd if=/dev/zero of=tfile10GB-$x-$i bs=1m count=10k" &
    fi 
    sleep 1
  done
  wait
  x=$(( $x + 1 ))
  # sleep 1 second in main while loop, flush and clear disk cache (requires root/sudo privs) #
  sleep 1
  # sync; echo 1 > /proc/sys/vm/drop_caches; sync
done

sync
end=`date +%s`
runtime=$((end-start))
echo "--------------------------------"
date
echo "-----------------------------------"
echo "|=-> * Total runtime was about $runtime seconds *"
echo "------------------------------------------------"
}

# make sure no temp files on start
rm t*.bin 2> /dev/null 
rm tfile* 2> /dev/null 
sync

# start test
start=`date +%s`
time main
# time main | tee runme.log
# { time main >/dev/null; } 2>&1 | grep real
tsize=`du -sm | awk '{print $1}'`
echo " - Total data written to disks:   $tsize   MegaBytes"
tspeed=`expr 1 \* $tsize / $runtime`
# echo "...cleaning up..."
rm t*.bin 2> /dev/null 
rm tfile* 2> /dev/null 
echo "  ***  Calculated speed in test:  $tspeed MB/s  ***  "
sync
