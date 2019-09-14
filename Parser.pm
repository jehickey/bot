package Parser;

use strict;
use warnings;
use Data::Dumper;

use Glyph;
use Lexicon;
use Dictionary;

my $lex;
my $dict;

sub new {
	my ($class, $lexicon, $dictionary) = @_;
	$lex = $lexicon;
	$dict = $dictionary;
	my $self = bless {
		
	}, $class;
	return $self;
}


sub parse {
	my ($self, $input) = @_;
	my @words = _explode_input($input);
	my @glyphs = ();
	
	#define the words into a set of glyphs
	foreach my $word (@words) {
		my $glyph = $dict->get($word);
		#print $glyph->toString(0) . " ";
		if ($glyph) {push (@glyphs, $glyph);}
	}
	print "DEFINED:   @glyphs \n";
	
	#deal with items with multiple definitions (where possible)
	
	#associate articles with their nouns
	#go through looking for articles
		#on seeing one, search forward for a noun
		#assign it to the noun (and remove it)
		
	for (my $i=0; $i<@glyphs; $i++) {
		my $glyph = $glyphs[$i];

		if ($glyph->isa("article")) {
			if (my $noun = _find_next_symbol("noun", $i, @glyphs)) {
				#$glyph->trim("article");						#break it down into the type of article it is
				$noun->add($glyph);
				splice @glyphs, $i, 1;
				$i--;	#compensate for loss of element
			}
		}
		
		if ($glyph->isa("adjective")) {
			if (my $noun = _find_next_symbol("noun", $i, @glyphs)) {
				$glyph->trim("adjective");						#break it down into the type of adjective it is
				$noun->add($glyph);
				splice @glyphs, $i, 1;
				$i--;	#compensate for loss of element
			}
		}
		
		if ($glyph->isa("terminator")) {						#saw a sentance terminator
			if ($i == @glyphs-1) {								#at the end of the sentence
				splice (@glyphs, $i, 1);						#remove it
				$i--;
			}
		}
		
	}
	#print Dumper @glyphs;
	return @glyphs;
}


sub deparse {
	my ($self, @input) = @_;
	my @result = @input;
	#print "deparsing:\n";
	for (my $i=0;  $i<@result;  $i++) {
		my $glyph = $result[$i];
		if ($glyph->isa("noun")) {
			#needs to be a while (), and has to remove the article from the noun (pop)
			if (my $article = $glyph->pop("article")) {	#needs to remove the article
				my $word = $dict->search($article);
				#it needs to incorporate the results, not become them
				if (!$word) {return Glyph->new("unknown", $word->toString(0));}
				splice (@result, $i, 0, $word);				#prepend it to noun
				$i++;
			}
			#get a list of any adjectives it has
			my @adjectives;
			while (my $adj = $glyph->pop("adjective")) {
				push(@adjectives, $adj);
			}
			print "Adjectives: @adjectives\n";
			
			#sort and priorities the list by properties and imposed limits
			
			foreach my $adjective (@adjectives) {
				splice (@result, $i, 0, $adjective);
				$i++;
			}
			
			
		}
		if ($glyph->isa("verb")) {
		
		}
	}
	my $output = "";
	foreach my $word (@result) {
		if ($output) {$output .= " ";}
		$output .= ($word->value()) ? $word->value() : $word->type();
	}
	return $output;
}



#given an array of glyphs to search, a type of glyph to search for, and a starting point
#returns the next matching symbol (or nothing)
sub _find_next_symbol {
	my ($match, $start, @glyphs) = @_;
	if (!$start) {$start=0;}						#lower limit for searching is 0
	if (!@glyphs) {return 0;}
	for (my $i=$start; $i<@glyphs; $i++) {
		my $glyph = $glyphs[$i];
		if ($glyph->isa($match)) {
			return $glyph;
		}
	}
	return 0;
	
}


#break a string down into an array of strings for each word and punctuation.
sub _explode_input {
    my $input = shift;
	if (!$input) {return ();}
	chomp ($input);

    #$_input{original} = $input;

	#strip out any character we don't allow

	#process input to clean up punctuation (by spacing each symbol out)
	$input =~ s/[\.,]+/ $& /g;

	#break processed input up into words
	my @list = ($input =~ /[\w'-\.,]+/g);
    return @list;
	}
	
	
	
1;
