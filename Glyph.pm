package Glyph;

#use strict;
use warnings;
use Storable;
use Data::Dumper;

use overload 
	'""' => \&toString,
	'==' => \&isEqual,
	'!=' => \&isNotEqual;

my $last_id = 0;

sub new {
	my ($class, $_name, $_parent) = @_;
	if (!defined $_name) {$_name="";}
	
	my @payload;
	my @parents;
	#see if this is a compound name
	if ($_name =~ /[>:]+/g) {
		#my $g = Glyph->new();
		my @seg = split (':', $_name);
		#print "@seg\n";
		for (my $i=0; $i<@seg; $i++) {
			my @seg = split (">", $seg[$i]);
			my $name = "";
			my $parent = "";
			if (@seg == 1) {$name = $seg[0];  $parent = "";}
			if (@seg == 2) {$name = $seg[1];  $parent = $seg[0];}
			if ($i == 0) {
				$_name = $name;
				if ($parent) {@parents = ($parent)};
			} else {
				push (@payload, Glyph->new($name, $parent));
			}
		}
		$_parent="";
	}
	
	
	$last_id++;
	my $self = {
		id      => $last_id,					#the lexical id of this symbol, if any
		name    => lc $_name,					#the canonical name of this symbol
		value   => '',							#the value, if any, that this symbol carries
		parents => [@parents],					#a list of names for each parent, in hierarchical order
		payload => [@payload]					#all symbols carried by this one - in no order
	};
	if ($_parent) {								#we don't do null parents
		$_parent = "$_parent";					#stringify it
		push (@{$self->{parents}}, $_parent);
		}
	return bless $self, $class;
}






#Is this symbol equal to another?
sub is {
	my ($a, $b) = @_;
	if (!defined $a) {return 0;}				#one value is required
    if (!defined $b) {return $a->parent();}   	#if they don't give a parameter, just echo back the type
	return "$a" eq "$b" ? 1 : 0;				#stringify and compare the result
}

#Is this symbol a member of a given parental group?
sub isa {
    my ($a, $b)	= @_;
    if (!defined $a) {return 0;}    	    	#this should never happen (unless someone gets cute with method	calls)
    if (!defined $b) {return $a->parent();}   	#if they don't give a parameter, just echo back the type
	if ("$a" eq "$b") {return 1;}				#equality
	foreach my $parent (@{$a->{parents}}) {		#if it has parents, iterate through them
		if ("$b" eq $parent) {return 1;}		#exit on success
	}
	return 0;									#The test shows that $b is not the father.
}

#Does this symbol carry a specific subsymbol?
sub has {
	my ($self, $glyph) = @_;
	if ("$glyph" eq "") {return Glyph->new();}
	if ("$self" eq "$glyph") {return $self->clone();}
	foreach my $g (@{$self->{payload}}) {
		if ("$g" eq "$glyph") {return $g->clone();}
	}
    return Glyph->new();
}

#Does this symbol carry anything related to this symbol?
sub hasa {
	my ($self, $glyph) = @_;
	if ("$glyph" eq "") {return Glyph->new();}
	if ("$self" eq "$glyph") {return $self->clone();}
	foreach my $g (@{$self->{payload}}) {
		if ($g->isa("$glyph")) {return $g->clone();}
	}
    return Glyph->new();
}


sub payload {
	my ($self) = @_;
	return $self->{payload};
}


#gets or sets the top parent
#changing parent will overwrite all parents
#always returns a parent, even when editing
sub parent {
	my ($self, $parent) = @_;
	if ($parent) {
		if (ref $parent eq "Glyph") {
		
		}
	}
	
	if (@{$self->{parents}} == 0) {return '';}
	return $self->{parents}[0];
}


#gets or sets the parent list
#changing parent will overwrite all parents
#always returns a list of parents, even when editing
sub parents {
	my ($self, $parents) = @_;
	if ($parents) {
	}
	#if (@{$self->{parents}} == 0) {return;}
	return $self->{parents};
}



sub inherit {
	my ($self, $parent) = @_;
		if (!$parent) {return 0;}									#parent cannot be null
		if (ref $parent eq "Glyph") {								#if the parent is a glyph (and not a name)
			#$self->{parents} = ();									#clear any existing parentage
			#print Dumper $self;
			#print Dumper $self->{parents};
			#print Dumper $parent->{parents};
			push (@{$self->{parents}}, @{$parent->{parents}});		#inherit parents
			#import payload from parent
		}

		splice (@{$self->{parents}}, 0, 0, "$parent");						#inherit the inherited glyph as the closest parent

	}


sub add {
	my ($self, $glyph) = @_;
	if (!$glyph) {print "add: glyph required\n"; return 0;}
	
	#is it a glyph?
	if (ref $glyph ne "Glyph") {$glyph = Glyph->new("$glyph");}
	
	#for now just add it and don't worry about duplication or validity.
	push @{$self->{payload}}, $glyph->clone();
	return 1;
}


sub remove {
}

#given a valid ancestor of this glyph, will convert this glyph into that ancestor
sub trim {
	my ($self, $ancestor) = @_;
	#if (!$self->isa($ancestor)) {return 0;}
	#if (@{$self->{parents}} == 0) {return 0;}			#no parents - irreducable
	for (my $i=0; $i<@{$self->{parents}}; $i++) {
		if ($self->{parents}[$i] eq "$ancestor") {
			if ($i == 0) {return 1;}					#it's already the first parent - already trimmed
			$self->{name} = $self->{parents}[$i-1];		#switch to the parent one level up from the ancestor
			splice (@{$self->{parents}}, 0, $i);
			return 1;
		}
	}
	return 0;
#	$self->{name} = "$ancestor";
	#print Dumper $self;
}


#Creates a copy of itself as a child (inheriting creator as a parent)
#must return a Glyph no matter what
sub spawn {
	my ($self, $newname) = @_;
	if (!$newname) {$newname = "";}
	my $spawn = $self->clone();
	if ("$spawn" eq "") {return $spawn;}					#if it doesn't have a name, just copy it as-is
	if ($spawn->parent() ne "$spawn") {						#use current name as a new parent (unless they're already the same)
		if ($spawn->parent() ) {							#null doesn't pass anything on and is never a parent
		splice (@{$spawn->{parents}}, 0, 0, "$spawn");		#insert the old name into the parent list
		}
	}
	$spawn->{name} = $newname;								#now give it a new name
	#print Dumper $spawn;
	return $spawn;
}


sub clone {
	my ($self) = shift;
	return Storable::dclone($self);
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

sub fromString {
	my ($self, $str) = @_;
	if (!$str) {return Glyph->new();}
	
}

sub isEqual {
	my ($a, $b) = @_;
	return ("$a" eq "$b");
}

sub isNotEqual {
	my ($a, $b) = @_;
	return ("$a" ne "$b");
}


1;


