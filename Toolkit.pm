package Toolkit;

#this is a static package, not an instantiated one.

sub main::parse {
	my ($str) = @_;
	if (!$str) {return "";}
	
	my $value;
	my $modifiers;

	my @results;
	foreach my $segment (split(':', $str)) {
		my ($typ, $val) = split('>', $segment);
		if (!defined $val) {$val = '';}
		push (@results, $typ, $val);
	}
	
#	if (@seg > 1) {									#multiple segments
#		$type = $seg[0];							#the first segment is the new value
#		splice (@seg, 0, 1);						#remove it from the array
#	}
	#if it was just 1, then nothing had to be done
	
	
#	($type, $value) = split('>', $type);
#	if (!defined $value) {$value = '';}
	
#	if ($type =~ /[>:]+/g) {				#does it contain any formatting characters?
#		my @seg = split (':', $type);
#		for (my $i=0; $i<@seg; $i++) {
#			my @seg = split (">", $seg[$i]);
#			my $typ = $seg[0];
#			my $val = (@seg == 2) ? $seg[1] : "";
#			if ($i==0) {
#				$type  = $typ;
#				$value = $val;
#			} else {
#				push (@payload, Glyph->new($typ, $val));
#			}
#		}
#	}
	
#	return ($type, $value);
	return @results;
}





1;