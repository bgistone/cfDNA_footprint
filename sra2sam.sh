#time fastq-dump --split-3 SRR2129995.sra -F &
#time sam-dump SRR2130050.sra -1 --output-buffer-size 10000000 | samtools view -bS - > SRR2130050.2.bam
time sam-dump SRR2130051.sra -1 --output-buffer-size 10000000 | samtools view -bS - > SRR2130051.bam
