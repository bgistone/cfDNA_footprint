#########################################################################
# File Name: step2.cfDNA_WPS_stat.sh
# Author: lxf
# mail: lixiaofeng@rrgenetech.com
# Created Time: 2017年03月16日 星期四 01时11分50秒
#########################################################################
#!/bin/bash

read1=$1
read2=$2
RG=$3
sample=$4
echo bwa aln with $RG ......
time bwa aln /data/soft/GATK/ucsc.hg19.fasta $read1 -t 16 -f $sample.R1.sai
time bwa aln /data/soft/GATK/ucsc.hg19.fasta $read2 -t 16 -f $sample.R2.sai
time bwa sampe /data/soft/GATK/ucsc.hg19.fasta $sample.R1.sai $sample.R2.sai $read1 $read2 -f $sample.sam -r $RG
echo done
echo ' '
echo calculate WPS for $sample ......
time perl step2.cfDNA_WPS_stat.pl $sample.sam /data/pipeline/cfDNA_footprint/hg19.chr.len $sample 120 >$sample.chrwps.log 2> $sample.chrwps.err
echo done 
echo ' ' 
echo smoothing ......
time python step3.cfDNA_WPS_smooth.py -i $sample.wps.txt -o $sample.adjusted.wps.txt -w 1000 -p 500 -s 21
echo done
echo ' ' 
echo call peak ......
time perl step4.cfDNA_peak.pl $sample.adjusted.wps.txt $sample.adjusted.wps.peak.txt
echo done
