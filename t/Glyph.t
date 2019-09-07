use strict;
use warnings;
use Test::More;
use Data::Dumper;

require_ok ('Glyph');

#instantiation tests
subtest instantiation => sub {
	my $g = Glyph->new();
	ok (ref $g eq "Glyph",  "Empty glyph instantiates");
	is ("$g", "", 			"Glyph stringies into its (empty) name");
	my $id1 = $g->{id};
	ok ($id1 > 0, "ID \"$id1\" assigned at creation");
	is ($g->is(),  '', "Empty glyph \"is\" nothing");
	is ($g->isa(), '', "Empty glyph \"isa\" nothing");

	my $apple = Glyph->new("apple");
	$apple->{parents} = ['fruit'];
	is ("$apple", "apple", "Name set properly and in all-lowercase");
	my $id2 = $apple->{id};
	ok ($id2 > 0, "ID \"$id2\" assigned at creation");
	is ($id2 - $id1, 1, "Second id is one higher than the first.");
	is ($apple->is(),  "fruit", "Glyph is() returns parent");
	is ($apple->isa(), "fruit", "Glyph isa() returns parent");
};


subtest complexnames => sub {
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
	my $alpha = Glyph->new("alpha");
	my $beta  = Glyph->new("beta");

	ok (!($null), "null is not true");
	ok (!$null,   "!null is true");
	ok ($alpha,   "alpha is true");
	ok (!!$alpha, "!alpha is false");

	is ($null  == $null2, 1 ,"$null  == $null2");
	is ($alpha == $alpha, 1 ,"$alpha == $alpha");
	is ($alpha == $beta,  '' ,"$alpha == $beta");
	is ($alpha == $null,  '' ,"$alpha == $null");

	is ($null  != $null2, '' ,"$null  != $null2");
	is ($alpha != $alpha, '' ,"$alpha != $alpha");
	is ($alpha != $beta,  1 ,"$alpha != $beta");
	is ($alpha != $null,  1 ,"$alpha != $null");	
};


subtest payload => sub {
	my $apple = Glyph->new("apple");
	my $rotten = Glyph->new("rotten");
	is ($apple->add($rotten),1, "Glyph accepts payload");
	my $apple3 = $apple->clone();		#cloned after we added something to it
	is ($apple->has($rotten),  1, "Check for true modifier by reference");
	is ($apple->has("rotten"), 1, "Check for true modifier by name");
	#is ($apple2->has("rotten"), 0, "Changes to one symbol do not impact a copy");
	is ($apple3->has("rotten"), 1, "Modifiers carry over during copy");
};

#verify glyph parentage works
subtest parentage => sub {
	my $name = "thing";
	my @parents = ('a','b','c');

	my $g = Glyph->new($name);
	@{$g->{parents}} = (@parents);
	
	is_deeply(\@{$g->{parents}}, \@parents, "Parentage checks out");

	ok (!$g->trim("x"), "Trimming to an invalid parent is rejected");
	is ("$g", "thing",  "Invalid trim has no effect");

	for (my $i=0; $i<@parents; $i++) {
		$g = Glyph->new($name);
		@{$g->{parents}} = (@parents);
		ok ($g->isa($parents[$i]),		"Level $i parent works as a comparison");
		ok ($g->trim($parents[$i]),		"Level $i trim accepted");
		if ($i==0) {
			is ("$g", $name,			"Level $i trim has no effect");
		} else {
			is ("$g", $parents[$i-1],	"Level $i trim reverts to proper parent");
		}
	}
};


#verify everything copies over and there is no cross-contamination
subtest cloning => sub {
	my $name = "original";
	my @parents = ('a','b','c');
	my $property1 = "prop1";
	my $property2 = "prop2";
	my $property3 = "prop3";

	my $original = Glyph->new($name);
	@{$original->{parents}} = @parents;
	$original->add($property1);
	my $copy = $original->clone();

	#Copying of modifiers
	$original->add($property2);
	$copy->add($property3);
	ok ($copy->has($property1),		 "Original modifier is present in copy");
	ok (!$copy->has($property2),	 "Additions to original do not impact copy");
	ok (!$original->has($property3), "Additions to copy do not impact original");

	#copying of parents
	is_deeply(\@{$copy->{parents}}, \@parents, "Parentage was copied");
	$copy->trim($parents[1]);
	is_deeply(\@{$original->{parents}}, \@parents, "Changes to copy did not impact original's parents");
	is_deeply(\@{$copy->{parents}}, ['b','c'], "Changes to copy did impact copy");
	
};


#verify arrays and hashes copy cleanly during clone




#trim - trim a symbol back

#try each operation using a series of bad symbol names


done_testing();
