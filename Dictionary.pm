package Dictionary;

use strict;
use warnings;
use JSON;
use File::Slurp;
use Data::Dumper;

use Glyph;
use Lexicon;


#changes:
#the index is now a hash, with individual entries compressed into one glyph
#entries in the index are now a glyph
	#the glyph represents all entries for that name contains all sub-entries
	#subentries are glyphs that match the type for a dictionary entry
		#individual information is stored as their own payload




my $lex;

sub new {
	my ($class, $lexicon) = @_;
	$lex = $lexicon;
	if (!$lex) {print "Dictionary warning: no lexicon!\n";}
	my $self = {
		index => [],
		list  => new Glyph("list")
	};

	return bless $self, "Dictionary";
}


#Retrieves a glyph representing a word's dictionary definition
#Always returns a valid glyph.  On failure it returns a blank glyph with the word's name on it
sub get2 {
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


sub get {
	if (!$lex) {return;}
	my ($self, $word, $def) = @_;
	$word = _clean($word);
	$def  = _clean($def);
	if (!$word) {return Glyph->new();}								#no word given for this request

	
	if ($word =~ /[:>]+/g) {										#complex name
		($def, $word, my %mods) = main::parse($word);
	}

	my $entry = $self->{list}{$word};
	if (!$entry) {return Glyph->new();}								#no entry for this word

	
	my @matches = ();
	foreach my $sub (@{$entry->{payload}}) {
		if (!$def || $sub->is($def)) {
			push (@matches, $sub);
		}
	}
	
	my $result = Glyph->new("",$word);
	if (@matches == 0) {return $result;}
	if (@matches == 1) {
		return $matches[0];
		}
	$result->type("multiple");
	foreach my $match (@matches) {
		$result->add($match);
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
		if ($def eq $filter) {return Glyph->new($def, $word);}
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
	#if (!$lex->isa($def, "grammar"))	{print "Definition must be a grammar type\n";	return 0;}
	if ($self->get($word, $def))		{print "Two defintions of the same type\n";		return 0;}
	push (@{$self->{index}}, {word=>$word, def=>$def});
		
	
	if (!$self->{list}{$word}) {								#if this is the first entry for that word
		$self->{list}{$word} = Glyph->new("list", $word);		#create a list glyph for it
	}
	
	my $glyph = Glyph->new($def, $word);						#this is the glyph for this particular entry
	$self->{list}{$word}->add($glyph);
	#print ">>>>>>$def>$word\n";  print Dumper $glyph;
	
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