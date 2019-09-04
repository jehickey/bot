package Glyph;

my @payload;


sub new {
	my ($class, $_name, $_parent) = @_;
	if (!defined $_name) {$_name="";}
	my $self = {
		id      => 0,							#the lexical id of this symbol, if any
		name    => lc $_name,					#the canonical name of this symbol
		parents => [],							#a list of names for each parent, in hierarchical order
		payload => []							#all symbols carried by this one - in no order
	};
	if (defined $_parent) {
		$_parent = "$_parent";					#stringify it
		push (@{$self->{parents}}, $_parent);
		}
	return bless $self, $class;
}


use overload '""' => \&toString;

#Is this symbol equal to another?
sub is {
	my ($a, $b) = @_;
	if (!defined $a || !defined $b) {return 0;}	#two values are required
	return "$a" eq "$b" ? 1 : 0;					#stringify and compare the result
}

#Is this symbol a member of a given parental group?
sub isa {
    my ($a, $b)	= @_;
    if (!defined $a) {return 0;}    	    	#this should never happen (unless someone gets cute with method	calls)
    if (!defined $b) {return 0;}    	    	#there must be another symbol (or it's automatically false)
	if ("$a" eq "$b") {return 1;}				#equality
	foreach my $parent (@{$a->{parents}}) {		#if it has parents, iterate through them
		if ("$b" eq $parent) {return 1;}		#exit on success
	}
	return 0;									#The test shows that $b is not the father.
}

#Does this symbol carry a specific subsymbol?
sub has {
	my ($self, $glyph) = @_;
	if ("$self" eq "$glyph") {return 1;}
	foreach my $g (@{$self->{payload}}) {
		if ("$g" eq "$glyph") {return 1;}
	}
    return 0;
}



sub add {
	my ($self, $glyph) = @_;
	if (!$glyph) {print "add: glyph required\n"; return 0;}
	
	#is it a glyph?
	if (ref $glyph ne "Glyph") {$glyph = Glyph->new("$glyph");}
	
	#for now just add it and don't worry about duplication or validity.
	push @{$self->{payload}}, $glyph;
	return 1;
}


sub remove {
}


sub clone {
	my ($self) = shift;
	my $clone = bless {%$self}, ref $self;
	return $clone;
}

sub toString {
	my ($self, $level) = @_;
	if (!defined $self) {return "";}
	if (!defined $level) {return $self->{name};}					#default behavior is to stringify itself by name
	if ($level>0) {return $self->{name}}
	my $str = "";
	$str .= "[";
	if (@{$self->{parents}}>0) {$str .= $self->{parents}[0] . ">";}
	if ($self->{name}) { $str .= $self->{name}; }

	foreach my $item (@{$self->{payload}}) {						#Display payload
		$str .= ":" . $item->toString($level+1);					#colon-delimited, and with less info shown
	}
	$str .= "]";
	return $str;
}





1;


