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
			if (ref $idef ne "Glyph") {print "NOT A GLYPH";}
			if ((!$def) || ("$idef" eq "$def")) {					#filter when searching by definition
				push (@results, $lex->get($entry->{def}));
			}
		}
	}
	

	if (!@results) 		{return Glyph->new($word);}					#no results found
	if (@results == 1)	{											#just one result
		return $results[0]->spawn($word);
	}

	my $result = $lex->get("multiple")->spawn($word);
	foreach my $entry (@results) {
		$result->add($entry);
	}
	
	return $result;
}


#search the dictionary for the best match it can find for a given symbol
sub search {
	my ($self, $filter) = @_;
	if (!$filter) {$filter = Glyph->new();}	
	
	foreach my $entry (@{$self->{index}}) {
		#compare to filter
		
	}
}


sub add {
	my ($self, $word, $def) = @_;
	if (!$lex) {return 0;}
	$word = _clean($word);
	if (!defined $self) {print "Must be called as an object\n"; return 0;}
	if (!$word) {print "Defined word required\n"; return 0;}
	if (!defined $def)  {print "Definition required\n"; return 0;}
	$def = $lex->get($def);
	if (!$def)  {print "Definition required\n"; return 0;}
	if ($self->get($word, "$def")->isa("grammar")) {return 0;}
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
		my $def  = $entry->{def}->toString(0);
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