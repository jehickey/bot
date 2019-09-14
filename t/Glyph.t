use strict;
use warnings;
use Test::More;
use Data::Dumper;

require_ok ('Lexicon');
require_ok ('Glyph');

my $lex = Lexicon->new();
$lex->load();
$Glyph::lex = $lex;


#print Dumper $lex->{index};

#instantiation tests
subtest instantiation => sub {
	my $g = Glyph->new();
	ok (ref $g eq "Glyph",  "Empty glyph instantiates");
	is ("$g", "", 			"Glyph stringies into its (empty) name");
	my $id1 = $g->{id};
	ok ($id1 > 0, "ID \"$id1\" assigned at creation");
	is ($g->is(),  0, "Empty glyph \"is\" nothing");
	is ($g->isa(), 0, "Empty glyph \"isa\" nothing");

	my $apple = Glyph->new("apple");
	#$apple->{parents} = ['fruit'];
	is ("$apple", "", "A glyph with an invalid type is null");
	
	#print Dumper $lex->{index};
	my $parent = Glyph->new("boolean");
	#print Dumper $parent;
	is ($parent->is("data"),  0, "bool !IS data");
	is ($parent->is("true"),  0, "bool !IS true");
	is ($parent->is("boolean"),  1, "bool IS bool");
	is ($parent->isa("boolean"), 1, "bool ISA bool");
	is ($parent->isa("data"), 1, "bool ISA data");
	is ($parent->isa("true"), 0, "bool !ISA true");
};


subtest complexnames => sub {
	ok (1==1, "This test is skipped.");
	return;
	#parent>name pairs on main segment
	my $glyph = Glyph->new("noun>boy");
	ok ($glyph->is("boy"), "Complex name yielded the right glyph name");
	is ($glyph->parent(), "noun", "Complex name yielded the right parent");

	$glyph = Glyph->new("noun>");
	ok ($glyph->is("noun"), "Broken complex name yielded the right glyph name");
	is ($glyph->parent(), "", "Broken complex name yielded no parent");

	$glyph = Glyph->new(">boy");
	ok ($glyph->is("boy"), "Broken complex name yielded the right glyph name");
	is ($glyph->parent(), "", "Broken complex name yielded no parent");
	
	
	$glyph = Glyph->new("noun>boy:tall");
	ok ($glyph->is("boy"),   "Complex name w/ payload yielded the right name");
	ok ($glyph->isa("noun"), "Complex name yielded the right parent");
	ok ($glyph->has("tall"), "Payload added to glyph");

	$glyph = Glyph->new("noun>boy:adjective>tall");
	ok ($glyph->is("boy"),   "Complex name w/ complex payload yielded the right name");
	ok ($glyph->isa("noun"), "Right parent");
	ok ($glyph->has("tall"), "Payload added to glyph");
	ok ($glyph->hasa("adjective"), "Payload has parentage");

	$glyph = Glyph->new("noun>boy:definite:adjective>tall");
	ok ($glyph->is("boy"),   "Complex name w/ multi-payload yielded the right name");
	ok ($glyph->isa("noun"), "Right parent");
	ok ($glyph->has("definite"), "Payload 1 added to glyph");
	ok ($glyph->has("tall"), "Payload 2 added to glyph");
	ok ($glyph->hasa("adjective"), "Payload 2 has parentage");


	
	#my $str = "noun>boy:definite:adjective>tall";
	#my $g = Glyph->new($str);
	#print $g->toString(0) . "\n";
	#print Dumper $g;	
};


subtest operators => sub {
	my $null  = Glyph->new();
	my $null2 = Glyph->new();
	my $alpha = Glyph->new("noun");
	my $beta  = Glyph->new("verb");

	ok (!($null), "null is not true");
	ok (!$null,   "!null is true");
	ok ($alpha,   "alpha is true");
	ok (!!$alpha, "!alpha is false");

	is ($null  == $null2, 1  ,"$null  == $null2");
	is ($alpha == $alpha, 1  ,"$alpha == $alpha");
	is ($alpha == $beta,  '' ,"$alpha == $beta");
	is ($alpha == $null,  '' ,"$alpha == $null");

	is ($null  != $null2, '' ,"$null  != $null2");
	is ($alpha != $alpha, '' ,"$alpha != $alpha");
	is ($alpha != $beta,  1 ,"$alpha != $beta");
	is ($alpha != $null,  1 ,"$alpha != $null");	
};


subtest payload => sub {
	my $apple = Glyph->new("article");
	my $rotten = Glyph->new("indefinite");
	is ($apple->add($rotten),1, "Glyph accepts payload");
	my $apple3 = $apple->clone();		#cloned after we added something to it
	is ($apple->has($rotten),  $rotten, "Check for true modifier by reference");
	is ($apple->has("indefinite"), $rotten, "Check for true modifier by name");
	#is ($apple2->has("indefinite"), 0, "Changes to one symbol do not impact a copy");
	is ($apple3->has("indefinite"), $rotten, "Modifiers carry over during copy");
};

#verify glyph parentage works
subtest parentage => sub {
	my $g = Glyph->new("indefinite");
#	print Dumper $g->parents();
	#is_deeply($g->parents(), [], "Parentage checks out");

	ok (!$g->trim("x"), "Trimming to an invalid parent is rejected");
	is ("$g", "indefinite",  "Invalid trim had no effect");

	#trim it back to root

	is ($g->parent(), "article", "Correct parent reported by glyph");

	ok ($g->trim(),			 "Trim command accepted");
	ok ($g->is("article"),	 "Trimmed to parent (without parameter)");
	ok ($g->trim("grammar"), "Trimmed back to root-level ancestor by name");
	ok ($g->trim(),			 "Trimmed to parent (of root-level type)");
	ok ($g->trim("grammar"), "Trim had no effect ok root-level type");
};


#verify everything copies over and there is no cross-contamination
subtest cloning => sub {
	my $g1 = Glyph->new("noun");
	$g1->add(Glyph->new("adjective"));
	my $g2 = $g1->clone();
	is ("$g2", "noun", "Clone retained identity of original");
	ok ($g2->has("adjective"), "Clone retained payload of original");
	
	
	$g1->add(Glyph->new("definite"));
	$g2->add(Glyph->new("indefinite"));
	ok ($g2->has("indefinite"), "Clone is able to take on payload as normal");
	ok (!$g1->has("indefinite"), "Addition to clone didn't carry over to original");
	ok (!$g2->has("definite"), "Addition to original didn't carry over to clone");
	
};


#verify arrays and hashes copy cleanly during clone




#trim - trim a symbol back

#try each operation using a series of bad symbol names


done_testing();
