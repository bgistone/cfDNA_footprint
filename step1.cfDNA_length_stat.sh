sam=$1
samtools view -f 0x2 $sam -@ 16 | perl -lane 'if($F[8]>0){$len{$F[8]}++;$ids{$F[2]}=0;}END{foreach my $k(sort {$a<=>$b} keys %len){print "$k\t$len{$k}";} @ids=keys %id;print join("\t",@ids);}' > $sam\.cfDNA_length_distribution.txt
