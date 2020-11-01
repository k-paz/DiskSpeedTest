# DiskSpeedTest
Commandline script with parametrized loops and concurrent processes mostly writing and some reading with temp files for real performance assesment on filesystem and disk.
-
Crucially - put the scripts in their own/clean directory without any other files in it in order to have proper calculation for the speed estimation.
---

Example usage:

# - linux small/225GB - (single process) - 
./lnxtest.sh 1
# - linux std/420GB - (three processes) -
./lnxtest.sh 3
# - linux big/1TB - (nine processes) -
./lnxtest.sh 9

# - MacOS small/225GB - 
./mactest.sh 1
# - MacOS std/420GB - 
./mactest.sh 3
# - MacOS big/1TB - 
./mactest.sh 9

---
For a result you would be getting something like:
-------------------------------
Sun Nov  2 13:47:31 CET 2020
-----------------------------------
|=-> * Total runtime was about 99 seconds *
------------------------------------------------
real	1m38.379s
user	0m4.860s
sys	0m55.691s
 - Total data written to disks:   225385   MegaBytes
  ***  Calculated speed in test:  2276 MB/s  ***  
---

Have fun.
