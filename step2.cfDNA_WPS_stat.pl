use strict;
use warnings;
use Devel::Size qw(size total_size);

my $sam = shift;
my $chrlen = shift;
my $output = shift;
my $window = shift || 120;

#my %wps=();
my @wps=();
my %len = ();
my %done=();
my $current_chr="";
my $low_quality_filtered = 0;
my $low_quality_left = 0;
my $avilable_reads = 0;

open CL,$chrlen or die $!;
while(<CL>)
{
	chomp;
	my @a = split /\t/,$_;
#	for(my $i=0;$i<$a[1];$i++)
#	{
#		$wps[$i] = 0;
#	}
	$len{$a[0]} = $a[1];
}
close CL;
print STDERR "length loaded and inited\n";
open SAM,"samtools view -f 0x2  $sam|" or die $!;
#open SAM,$sam or die $!;
my $size = 0;
my $n = 0;
while(<SAM>)
{
	chomp;
	my @t = split "\t", $_;
	next if(($t[8]<=0 || $t[8]>1000) || !exists $len{$t[2]});
	my ($Edit_Dist) = $t[-1] =~ /NM:i:(\d+)/;

	if($t[4]<10)
	{
		if($Edit_Dist > 2)
		{
			$low_quality_filtered++;
			next;
		}else{
			$low_quality_left++;
		}
	}

	if(!exists $done{$t[2]}){
		&dump($current_chr);
		print STDERR "$len{$t[2]}\n";

#		@wps = split(//, 0 x $len{$t[2]});
		for(my $x=0;$x<$len{$t[2]};$x++)
		{
			$wps[$x] = 0;
		}
		print STDERR "$t[2] initing done\n";
		$done{$t[2]} = 'yes';
		$current_chr=$t[2];
	}
	$avilable_reads++;

	my $start_within = $t[3] - $window;
	my $end_within = $t[3] + $window;

	if($start_within < 0)
	{
		$start_within = 0;
	}
	if($end_within > $len{$t[2]})
	{
		$end_within = $len{$t[2]};
	}
	for(my $i=$start_within;$i<$end_within;$i++)
	{
		$wps[$i] -= 1;
	}
	$start_within = $t[3]+$t[8]-$window;
	$end_within = $t[3]+$t[8]+$window;
	if($start_within < 0)
	{
		$start_within = 0;
	}
	if($end_within>$len{$t[2]})
	{
		$end_within = $len{$t[2]};
	}

	for(my $k=$start_within;$k<$end_within;$k++)
	{
		$wps[$k] -= 1;
	}

	my $start_span = $t[3];
	my $end_span = 0;
	if($window>$t[8])
	{
		$end_span = -1;
	}else{
		$end_span = $t[3] + $t[8];
	}
	for(my $j=$start_span;$j<$end_span;$j++)
	{
		$wps[$j] += 1;
	}
#	print STDERR "$t[0]\t$t[2]\t$t[3]\t$t[8] .. $start_within\t$end_within\t-\t$start_span\t$end_span\t+\n";
#	$n++;
#	$size = size(\@t);
#	print STDERR "$n\t$size";
#	$size = size(\@wps);
#	print STDERR "\t$size";
#	$size = total_size(\%done);
#	print STDERR "\t$size\n";
}
close SAM;
&dump($current_chr);

sub dump{
	my $chr = shift;
	if($chr ne '')
	{
		open OO,">$output.$chr.wps.txt" or die $!;
#		print OO ">$chr\n";
#		print OO join(' ', @wps),"\n";
		for(my $i=0;$i<@wps;$i++)
		{

			print OO "$chr\t$i\t$wps[$i]\n";
		}
		@wps=();
		print STDERR "$chr WPS calculating done\n";
		close OO;
	}

}


print STDERR "$avilable_reads reads are avilable for WPS\n$low_quality_filtered low mapping score reads were FILTERED\n$low_quality_left low mapping score reads were still KEEPED\n";
