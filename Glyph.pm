package Glyph;

#did: replaced "name" with "type" - all tests pass


#use strict;
use warnings;
use Storable;
use Data::Dumper;

use overload 
	'""' => \&toString,		#display the type as a string
	'==' => \&isEqual,
	'!=' => \&isNotEqual,
	'eq' => \&isEqual;

my $last_id = 0;
our $lex;

#rule: avoid cloning a new glyph unless necessary


#replace "name" with "type" and limit access to it
#add value

sub new {
	my ($class, $type, $value) = @_;
	if (!defined $type) {$type="";}
	my @payload;
	my @parents;
	
	#see if this is a compound type
	if ($type =~ /[>:]+/g) {				#does it contain any formatting characters?
		my @seg = split (':', $type);
		for (my $i=0; $i<@seg; $i++) {
			my @seg = split (">", $seg[$i]);
			my $typ = $seg[0];
			my $val = (@seg == 2) ? $seg[1] : "";
			if ($i==0) {
				$type  = $typ;
				$value = $val;
			} else {
				push (@payload, Glyph->new($typ, $val));
			}
		}
	}


	#validate the type string (may contain extra info)
	if (!$lex->get($type)) {$type="";}
	
	
	$last_id++;
	my $self = {
		id      => $last_id,					#the lexical id of this symbol, if any
		type    => lc $type,					#the canonical name of this symbol
		value   => $value,						#the value, if any, that this symbol carries
#		parents => [@parents],					#a list of names for each parent, in hierarchical order
		payload => [@payload]					#all symbols carried by this one - in no order
	};
	return bless $self, $class;
}






#Is this symbol equal to another?
sub is {
	my ($a, $b) = @_;
	print "??? $a $b\n";
	return $lex->is($a, $b);
}

#Is this symbol a member of a given parental group?
sub isa {
    my ($a, $b)	= @_;
	return $lex->isa($a, $b);
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


sub value {
	my ($self, $value) = @_;
	if (defined $value) {$self->{value} = $value;}
	return $self->{value};
}


sub list {
	my ($self, $filter) = @_;
	if (!$filter) {return $self->{payload};}
	my @result;
	foreach my $item (@{$self->{payload}}) {
		if ($item->isa($filter)) {push (@result, $item);}
	}
	return @result;
}


sub pop {
	my ($self, $filter) = @_;
	my $result = Glyph->new();
	if ($self->count() == 0) {return $result;}
	if (!$filter) {
		$result = $self->{payload}[0];
		splice (@{$self->{payload}}, 0, 1);
		return $result;
	}
	for (my $i=0; $i<$self->count(); $i++) {
		$glyph = $self->{payload}[$i];
		if ($glyph->isa($filter)) {
			splice (@{$self->{payload}}, $i, 1);
			return $glyph;
			}
	}
	return $result;
}


sub type {
	my ($self, $new_type) = @_;
	if ($new_type) {$self->{type} = "$new_type"};			#assign new type (and stringify in case it's a glyph)
	return $self->{type};
}

sub count {
	my ($self) = @_;
	return scalar @{$self->{payload}};
}

#gets or sets the top parent
#changing parent will overwrite all parents
#always returns a parent, even when editing
sub parent {
	my ($self) = @_;
	return $lex->get($self->{type});
}


#gets the parent list for this glyph
sub parents {
	my ($self) = @_;
	return @{$lex->parents($self->{type})};
}



sub inherit {
	my ($self, $parent) = @_;
		if (!$parent) {return 0;}									#parent cannot be null
		if (ref $parent eq "Glyph") {								#if the parent is a glyph (and not a name)
			#$self->{parents} = ();									#clear any existing parentage
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
	if (!$ancestor) {$ancestor = $lex->get("$self");}	#if no ancestor is given, default to immediate parent
	if (!$self->isa($ancestor)) {return 0;}				#must be a valid parent of this type
	$self->type($ancestor);
	return 1;
}


#Creates a copy of itself as a child (inheriting creator as a parent)
#must return a Glyph no matter what
sub spawn {
	my ($self, $newtype) = @_;
	if (!$newtype) {$newtype = "";}
	my $spawn = $self->clone();
	if ("$spawn" eq "") {return $spawn;}					#if it doesn't have a name, just copy it as-is
	if ($spawn->parent() ne "$spawn") {						#use current name as a new parent (unless they're already the same)
		if ($spawn->parent() ) {							#null doesn't pass anything on and is never a parent
		splice (@{$spawn->{parents}}, 0, 0, "$spawn");		#insert the old name into the parent list
		}
	}
	$spawn->{type} = $newname;								#now give it a new name
	return $spawn;
}


sub clone {
	my ($self) = shift;
	return Storable::dclone($self);
}

sub toString {
	my ($self, $level) = @_;
	if (!defined $self) {return "";}
	if (!defined $level) {
#		if ($self->{value}) {return $self->{value};}				#return the value if they have one
		return $self->{type};}										#default behavior is to stringify itself by name
	if ($level>0) {return $self->{type}}
	my $str = "";
#	$str .= "[";
	if ($self->{type}) { $str .= $self->{type}; }
	if ($self->{value}) { $str .= ">" . $self->{value}; }

	foreach my $item (@{$self->{payload}}) {						#Display payload
		$str .= ":" . $item->toString($level+1);					#colon-delimited, and with less info shown
	}
#	$str .= "]";
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


