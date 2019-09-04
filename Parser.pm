package Parser;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use Word;

my %_input  = (original => '', processed => '');
my @_words   = [ ];

sub input  { return \%_input; }
sub words  { return @_words; }
sub wordcount {return scalar @_words;}


sub new {
	my $class = shift;
	my $input = shift;
    my $self  = {};
    bless ( $self, $class );
	if ($input) { process($input); }
    return $self;
}


sub process {
	my $self  = shift;
    my $input = shift;
	chomp ($input);

    $_input{original} = $input;

	#strip out any character we don't allow

	#process input to clean up punctuation (by spacing each symbol out)
	$input =~ s/[\.,]+/ $& /g;

	#break processed input up into words
	my @_wordsRaw = ($input =~ /[\w'-\.,]+/g);
	$_input{processed} = $input;

	#build list of Word objects
	undef (@_words);
	for my $word (@_wordsRaw) {
		push @_words, define($word);	#this won't work once words with multiple meanings are allowed
	}

	GrammarRules();

    return @_words;
	}


sub define {
	my $wordText = shift;
	my $word = Word->new($wordText);;
	my $def = GetLexEntry($wordText);
	if ($def != 0) {
		#print "   Found " . $def->{text} .  ": " . $def->{pos} . "\n";
        $word->{'id'}   = $def->{'id'};
        $word->{'seen'} = $def->{'seen'};
        $word->{'pos'}  = $def->{'pos'};
		$word->{'posName'} = $def->{'label'};
	}

    return $word;	#should return an array (with 0 elements for empty, 1 for single, >1 for multiple)
}


sub GrammarRules {
    #group certain classes of words (should use a rule list)
    for (my $i=0;  $i<=$#_words; $i++) {
#       print "]]] " . $_words[$i]{text} . "\n";

        #if ARTICLE join next noun
       	if ($_words[$i]{pos} == 7) {
            #find next noun
			my $next = FindNext($i, 1);
			if ($next > -1) {
				Insert ($i, $next);
            }
        } 

	#if preposition join prev verb
        if ($_words[$i]{pos} == 8) {
            #find previous verb
            for (my $ii = $i; $ii>=0; $ii--) {
                if ($_words[$ii]{pos} == 2) { #verb!
                    $_words[$ii]->AddModifier($_words[$i]);     #add source to target
                    splice ( @_words, $i, 1);                   #kill off original
                }
            }
		}
	}
}

sub Insert {
	my $target = shift;
	my $dest   = shift;
	if ((!defined $target) || ($target < 0)) {return 0;}
    if ((!defined $dest)   || ($dest < 0)) {return 0;}

    $_words[$dest]->AddModifier($_words[$target]);   	 		 #add target word to destination word's modifiers
    splice ( @_words, $target, 1);                   			#kill off original
}

#given a starting index location (non-inclusive), searches forward for the next word of $type
#returns index of found word (or undef for none)
sub FindNext {
	#my $self = shift;
	my $from = shift;
	my $type = shift;

	#range and value checking
    if ($from < 0) {$from = 0;}							#if before the start, move to start
    if ($from >= $#_words) {return -1;}					#can't search if already at the end
    if (!$type) {
		print "   * No type given\n";
		return -1;
	}

	#tests: 
	#findnext from -1, 0, 1, last-1, last, last+1

    for (my $i=$from+1; $i<=$#_words; $i++) {
    	if ($_words[$i]{pos} == $type) {return $i;}
	}
    return -1;											#failure, return nothing


}




sub GetDB {
	my $dsn = "DBI:mysql:database=perl_parser;host=oxygen.ehickey.com;port=3306";
	my $user = "ehickey";
	my $password = "b00byhatch";
	my $db = DBI->connect($dsn, $user, $password);
	return $db;
}


sub GetLexEntry {
	my $word = lc shift;
	my $db = GetDB();
	my $sth = $db->prepare("SELECT lex.id, lex.seen, lex.pos, pos.label FROM perl_parser.lexicon lex
		inner join perl_parser.pos pos on pos.id = lex.pos
		where lex.word = '$word' group by lex.word order by lex.seen desc");
	$sth->execute();
    #print "Word: $word\n";
	#print "Rows: " . $sth->rows . "\n";
	my $result = 0;
	if ($sth->rows > 0) {
		my $ref = $sth->fetchrow_hashref();
	    #my $id   = $ref->{'id'};
	    #my $seen = $ref->{'seen'};
	    #my $pos  = $ref->{'pos'};
	    #print "Row: ID:$id, Seen:$seen, Pos:$pos\n";
		$result = $ref;
	}
	$sth->finish;
	#$db->close();
	return $result;
}



1;
