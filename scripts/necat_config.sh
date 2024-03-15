
Reads=$1
OutDir=$2

Prefix=$(basename "$Reads" .fastq.gz)

mkdir -p "$OutDir/$Prefix"

realpath "$Reads" > "$OutDir/$Prefix"/read_list.txt
necat config "$OutDir/$Prefix"/"$Prefix"_config.txt

