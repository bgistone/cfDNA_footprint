#########################################################################
# File Name: step2.cfDNA_WPS_stat.sh
# Author: lxf
# mail: lixiaofeng@rrgenetech.com
# Created Time: 2017年03月16日 星期四 01时11分50秒
#########################################################################
#!/bin/bash
sample=$1
perl step2.cfDNA_WPS_stat.pl $sample.sam chr.len.txt $sample 120 >$sample.chrwps.log 2> $sample.chrwps.err
