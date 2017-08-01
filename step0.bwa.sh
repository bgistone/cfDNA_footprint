read1=$1
read2=$2
RG=$3
sample=$4
echo $RG
bwa aln /data/soft/GATK/ucsc.hg19.fasta $read1 -t 16 -f $sample.R1.sai
bwa aln /data/soft/GATK/ucsc.hg19.fasta $read2 -t 16 -f $sample.R2.sai
bwa sampe /data/soft/GATK/ucsc.hg19.fasta $sample.R1.sai $sample.R2.sai $read1 $read2 -f $sample.sam -r $RG
