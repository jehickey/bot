package Lexicon;

use strict;
use warnings;
use Glyph;
use Data::Dumper;


my %index = ();

sub new {
	my ($class) = @_;

	return bless {
		verbose => 0
	}, $class;
}



#Gets a copy of a listed symbol by name.
#Returns a safe copy of that glyph, or null if not found.
sub get {
	my ($class, $name) = @_;

	#is the request valid?
	if (!defined $name) {return 0;}						#No name was requested.
	if (ref $name eq "Glyph") {	$name = $name->{name};}		#
	
	#it's getting it by name, no matter how it was asked
	$name = lc $name;										#don't worry about much cleanup since dirty strings wouldn't be here

	#is it in the index?
	if (!exists $index{$name}) {return 0;}		#Nothing listed by that name.

	return $index{$name}->clone();				#return a copy of what's there
}

sub count {
	my ($class) = @_;
	return scalar keys %index;
}

sub clear {
	%index = ();
}

#Adds an entry to the Lexicon, tied to a parent (if any).
#Returns a safe copy of the symbol that was created.
sub add {
	my ($self, $glyph, $parent) = @_;
	if (!defined $glyph) {return error("Glyph required");}			#some symbolic information is required
	#if (!defined $parent) {$parent = 0;}
	if (ref $glyph ne "Glyph") {				#if what they sent isn't a glyph...
		$glyph = Glyph->new("$glyph");			#then we will make it a glyph.
	}
	$glyph = $glyph->clone();					#avoid interfering with the original

	#name validation and sanity check
	my $name = $glyph->{name};
	if ($name eq "") {return error("Name required");}				#glyph must be named
	
	#prevent duplication
	if ($self->get($name)) {return error("Already exists");	}

	#assign parentage and check validity (fail on reject)
	if (defined $parent) {
		my $parent_name = "$parent";
		if (ref $parent eq "Glyph") {$parent_name = $parent->{name};}		#we want to look up the parent by name
		$parent = $self->get($parent_name);									#use the version from the lexicon
		if (!$parent) {return error ("Invalid parent \"$parent_name\"");}
		$glyph->{parents} = [];
		push (@{$glyph->{parents}}, $parent->{name}, @{$parent->{parents}});
	}
	

	#assign it an id	

	#add this glyph to the lexicon index
	$index{$name} = $glyph;
	$self->debug("Adding $name to lexicon");

	return $glyph;
}


sub list {
	foreach my $name (keys %index) {
		my $glyph = bless $index{$name}, "Glyph";
		print "$glyph: " . $glyph->toString(0) . "\n";
	}
}


sub write {
	
}


sub error {
	my $message = shift || "";
	print "! Glyph: $message\n";
	return 0;
}

sub debug {
	my ($self, $message) = @_;
	if (!defined $self) {return 0;}
	if (!$self->{verbose}) {return 0;}
	$message = $message || "";
	print "* Glyph: $message\n";
	return 1;
}

1;
