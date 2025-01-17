use strict;
use warnings;
use Test::More;

require_ok ('Glyph');
require_ok ('Lexicon');

my $lex = Lexicon->new();
ok (ref $lex eq "Lexicon", "Lexicon instantiates");




#Verbose mode
is ($lex->{verbose}, 0, "Verbose off by default");
is ($lex->debug(),   0, "No verbose output");
$lex->{verbose} = 1;
is ($lex->debug(),   1, "Verbose output");
$lex->{verbose} = 0;	#turn it back off
is ($lex->count(), 0,	 "Lexicon is empty (no defaults)");

ok (!$lex->add(),		 		 "Lexicon rejects a parameterlesss call to add()");
ok ($lex->add()->has("error"),	 "null return has an error glyph associated with it");
ok (!$lex->add(""),		 		 "Lexicon rejects an empty string");

ok ($lex->add("animal"),  "Lexicon accepts new entries");
ok (!$lex->add("animal"), "Lexicon rejected a duplicate item");
ok ($lex->add("plant"),   "Lexicon accepts an unrelated root item");
ok ($lex->add("chicken", "animal"),"Lexicon accepts a child of an existing parent");
ok (!$lex->add("quartz", "mineral"),"Lexicon rejects a child of a nonexistant parent");
is ($lex->count(), 3,	 "Lexicon contains one entry");

my $lex2 = Lexicon->new();
ok (ref $lex2 eq "Lexicon", "A second Lexicon instantiates");
$lex2->add("vehicle");
$lex2->add("car", "vehicle");
is ($lex2->get("car")->parent(), "vehicle", "Second Lexicon can retrieve new words");
is ($lex2->count(), 2, "Second Lexicon only has no cross-contamination");
is ($lex->count(),  3, "Original Lexicon has no cross-contamination");

$lex->clear();
is ($lex->count(), 0,	 "Lexicon has been cleared");

$lex->load();
ok ($lex->count() > 0, "Lexicon loaded with " . $lex->count() . " glyphs");
$lex->clear();


$lex->add("animal");
$lex->add("vertebrate", "animal");
$lex->add("mammal", "vertebrate");
$lex->add("canid", "mammal");
$lex->add("dog", "canid");
$lex->add("fox", "canid");
$lex->add("jackal", "canid");
$lex->add("coyote", "canid");
$lex->add("felid", "mammal");
$lex->add("cat", "felid");
$lex->add("lion", "felid");
$lex->add("tiger", "felid");
$lex->add("jaguar", "felid");
$lex->add("leopard", "felid");
$lex->add("caracal", "felid");
$lex->add("primate", "mammal");
$lex->add("monkey", "primate");
$lex->add("howler", "monkey");
$lex->add("capuchin", "monkey");
$lex->add("babboon", "monkey");
$lex->add("ape", "primate");
$lex->add("chimpanzee", "ape");
$lex->add("gorilla", "ape");
$lex->add("orangutan", "ape");
$lex->add("human", "ape");


my $sym  = $lex->get("human");
is (ref $sym, "Glyph", "get() returns a glyph");
is ("$sym", "human", "get() returns the right glyph");
is_deeply ($sym->parents(), ['ape','primate','mammal','vertebrate','animal'], "get() result has the correct parentage");
my $sym2 = $lex->get("ape");
is ("$sym2", "ape", "get() returns the right glyph");
my $sym3 = $lex->get("felid");
is ("$sym3", "felid", "get() returns the right glyph");

if ($sym) {
	is ($sym->is("human")  ,1 ,"is() passes a true string check");
	is ($sym->is($sym)     ,1 ,"is() passes a true glyph check");
	is ($sym->is("ape")    ,0 ,"is() fails a false string check");
	is ($sym->is($sym2)    ,0 ,"is() fails a false symbol check");
	is ($sym->isa("ape")   ,1 ,"isa() passes a true string check");
	is ($sym->isa($sym2)   ,1 ,"isa() passes a true symbol check");
	is ($sym->isa("felid") ,0 ,"isa() fails a false name check");
	is ($sym->isa($sym3)   ,0 ,"isa() fails a false symbol check");
	is ($sym->isa("animal"),1 ,"isa() passes a root-level check");
}


#test handling of payloads
#payloads carry over to stored copy
#payloads in lexicon carry over to gotten glyphs
#culling of payloads X levels deep


done_testing();
