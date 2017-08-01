use strict;
use warnings;
use List::Util qw(sum);
use Statistics::Basic qw(:all);

my $local_wps = shift;
my $output = shift;

open OUT,">$output" or die $!;

my @arr = ();
my $cursor = 0;
sub callPeak
{
    my $LWPS = shift;
    my $peak_start_index = -5;
    my $peak_end_index = 1;
    my $peak_middle_index = 0;
    my $n = 0;
    open IN,$LWPS or die $!;
    <IN>;
    while(<IN>)
    {
        $n ++;
        chomp;
        my @t = split /\t/,$_;
        if($t[1]<=0)
        {
            if($n - $cursor >5 && @arr > 0)
            {
                #call peak and report
                $peak_end_index = $cursor;
                my $region_len = $peak_end_index - $peak_start_index + 1;
                if($region_len >= 50 && $region_len <= 450)
                {
                    #unshift last 5 elements
                     for(my $j = 0;$j<5;$j++)
                     {
                         pop(@arr);
                     }
                    my $local_median = median(@arr);
                    my ($report_start,$report_middle,$report_end,$report_len) = &maxsum(\@arr, $local_median,$peak_start_index);
                    print OUT "$report_start\t$report_middle\t$report_end\t$report_len\n";
                }
                #re-do initiation
                $peak_start_index = -1;
                @arr = ();
            }else{
                push(@arr,$t[1]);
            }
        }else{
            push(@arr,$t[1]);
            $cursor = $n;
            if($peak_start_index == -1)
            {
                $peak_start_index = $n;
            }
        }
    }
    close IN;

}

sub maxsum
{
    my ($data,$median,$start) = @_;
    my $len = 0;
    my $max_i = 0;
    my $max_j = 0;
    my $sum = 0;
    my $maxsum = 0;
    my @index = ();
    my @forSum = ();
    my $middle = 0;

    for(my $x = 0;$x<@$data;$x++)
    {
        if($$data[$x] >= $median)
        {
            push(@index,$x);
            push(@forSum,$$data[$x]);
            if($x == (@$data - 1 ))
            {
                $sum = sum(@forSum);
                if($sum > $maxsum)
                {
                    $maxsum = $sum;
                    $max_i = $index[0];
                    $max_j = $index[-1];
                }
            }
        }elsif(@forSum>0){
            $sum = sum(@forSum);
            if($sum > $maxsum)
            {
                $maxsum = $sum;
                $max_i = $index[0];
                $max_j = $index[-1];
            }
            @index = ();
            @forSum = ();
        }
    }#for end
    $middle = int(($max_j - $max_i ) / 2 );
    $len = $max_j - $max_i + 1;
    $max_i += $start;
    $max_j += $start;
    $middle+= $max_i;
    return($max_i,$middle,$max_j,$len);
}

&callPeak($local_wps);
close OUT;
