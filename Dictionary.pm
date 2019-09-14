package Dictionary;

use strict;
use warnings;
use JSON;
use File::Slurp;
use Data::Dumper;

use Glyph;
use Lexicon;


#on this one avoid any public {keys}
#just private data and public methods


my $lex;

sub new {
	my ($class, $lexicon) = @_;
	$lex = $lexicon;
	if (!$lex) {print "Dictionary warning: no lexicon!\n";}
	my $self = {
		index => []
	};

	return bless $self, "Dictionary";
}


#Retrieves a glyph representing a word's dictionary definition
#Always returns a valid glyph.  On failure it returns a blank glyph with the word's name on it
sub get {
	if (!$lex) {return;}

	my ($self, $word, $def, @traits) = @_;
	$word = _clean($word);
	$def  = _clean($def);
	if (!$word) {return Glyph->new();}
	
	#build an array of possible results
	#use that array to build final result
	
	my @results = ();
	#start with a generic definition
	foreach my $entry (@{$self->{index}}) {
		if ($word eq $entry->{word}) {										#word match!
			my $idef = $entry->{def};
			#if (ref $idef ne "Glyph") {print "NOT A GLYPH";}
			if ((!$def) || ("$idef" eq "$def")) {					#filter when searching by definition
				push (@results, $entry->{def});
			}
		}
	}
	

	if (!@results) 		{return Glyph->new();}									#no results found
	if (@results == 1)	{		#just one result
		my $entry = $lex->get($word);
		my $result = Glyph->new($results[0], $word);
		return $result;
	}

	my $result = Glyph->new("multiple", $word);
	foreach my $entry (@results) {
		$result->add($entry);
	}
	
	return $result;
}


#search the dictionary for the best match it can find for a given symbol
sub search {
	my ($self, $filter) = @_;
	if (!$filter) {return Glyph->new();}							#a filter is required
	if (ref $filter ne "Glyph") {$filter = Glyph->new($filter);}	#make sure it's a symbol
	my @results;
	foreach my $entry (@{$self->{index}}) {
		my $word = $entry->{word};
		my $def  = $entry->{def};
		#compare to filter
		if ($def eq $filter) {return new Glyph($def, $word);}
	}
	return Glyph->new();
}


sub add {
	my ($self, $word, $def) = @_;
	if (!$lex) {return 0;}
	$word = _clean($word);
	if (!defined $self)					{print "Must be called as an object\n";			return 0;}
	if (!$word)        					{print "Word required\n"; 						return 0;}
	if (!$lex->get($def))				{print "Valid definition required.\n";			return 0;}
	if (!$lex->isa($def, "grammar"))	{print "Definition must be a grammar type\n";	return 0;}
	if ($self->get($word, $def))		{print "Two defintions of the same type\n";		return 0;}
	push (@{$self->{index}}, {word=>$word, def=>$def});
	
}

sub count {
	my ($self) = @_;
	return @{$self->{index}};
}


sub list {
	my ($self, $filter) = @_;
	foreach my $entry (@{$self->{index}}) {
		my $word = $entry->{word};
		my $def  = 0;#$entry->{def}->toString(0) || 0;
		print "$word: $def\n";
	}
}


sub _clean {
	my ($word) = shift;
	if (!$word) {return "";}
	$word = "$word";				#stringify, just in case.
	$word =~ s/\s+/ /g;				#turn any double-spaces into single spaces
	$word =~ s/^\s+|\s+$//g;		#remove leading and ending whitespace
	return lc $word;
}


1;