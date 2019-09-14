use strict;
use warnings;
use Test::More;
use Data::Dumper;


#new tests:
#instantiation - can the lex object be created
	#verbose off by default
	#verbose on after turning it on
	#can an entry be added to it? (count=0, add ok, count=1)
	#can a second entry be added to it? (count=1, add ok, count=2)
#can a second lexicon be created (count=0, add ok, count=1)
	#verbose is off (no carryover from other)
	#can the second be cleared without clearing the first (second count=0, first count=2)
	#clear the first (count=0)
	#verbose off (on first)

#hierarchy test (on a cleared lexicon)
	#add a root entry (returns ok)
	#get that entry (verify it's ok)
	#is() - does a correct is() return true?
	#is() - does an incorrect is() return false?
	




require_ok ('Lexicon');

my $lex = Lexicon->new();
ok (ref $lex eq "Lexicon", "Lexicon instantiates");
is ($lex->count(), 0,	 "Lexicon is empty (no defaults)");


#new entries
ok (!$lex->add(),		 "Lexicon rejects a parameterlesss call to add()");
is ($lex->count(), 0,	 "Lexicon is empty");
ok (!$lex->add(""),		 "Lexicon rejects an empty string");
is ($lex->count(), 0,	 "Lexicon is empty");
ok ($lex->add("animal"), "Lexicon accepts a valid new entry");
is ($lex->count(), 1,	 "Lexicon contains one entry");


ok (!$lex->add("animal"), "Lexicon rejected a duplicate item");
is ($lex->count(), 1,	  "Lexicon still contains one entry");
is ($lex->get("animal"), 'animal', "Root entry can be retrieved with get()");


ok ($lex->add("plant"),   "Lexicon accepts an unrelated root item");
is ($lex->count(), 2,	  "Lexicon contains two entries");
is ($lex->get("plant"), 'plant', "Second root entry can be retrieved with get()");


ok ($lex->add("chicken", "animal"),"Lexicon accepts a child of an existing parent");
ok (!$lex->add("quartz", "mineral"),"Lexicon rejects a child of a nonexistant parent");
is ($lex->count(), 3,	 "Lexicon contains 3 entries");


my $lex2 = Lexicon->new();
ok (ref $lex2 eq "Lexicon", "A second Lexicon instantiates");
$lex2->add("vehicle");
$lex2->add("car", "vehicle");
is ($lex2->get("car"), "vehicle", "Second Lexicon can retrieve new words");
is ($lex2->count(), 2, "Second Lexicon only has no cross-contamination");
is ($lex->count(),  3, "Original Lexicon has no cross-contamination");

$lex->clear();
is ($lex->count(), 0,	 "Lexicon has been cleared");

$lex->load();
ok ($lex->count() > 0, "Lexicon loaded with " . $lex->count() . " entries");
$lex->clear();

#a test lexicon - no relation to the real thing
$lex->add("animal");
$lex->add("vertebrate", "animal");
$lex->add("mammal", "vertebrate");
#$lex->add("canid", "mammal");
#$lex->add("dog", "canid");
#$lex->add("fox", "canid");
#$lex->add("jackal", "canid");
#$lex->add("coyote", "canid");
#$lex->add("felid", "mammal");
#$lex->add("cat", "felid");
#$lex->add("lion", "felid");
#$lex->add("tiger", "felid");
#$lex->add("jaguar", "felid");
#$lex->add("leopard", "felid");
#$lex->add("caracal", "felid");
$lex->add("primate", "mammal");
$lex->add("monkey", "primate");
#$lex->add("howler", "monkey");
#$lex->add("capuchin", "monkey");
#$lex->add("babboon", "monkey");
$lex->add("ape", "primate");
#$lex->add("chimpanzee", "ape");
#$lex->add("gorilla", "ape");
#$lex->add("orangutan", "ape");
$lex->add("human", "ape");


is ($lex->get(""), 		 '', 				"A bad request gives an empty string");
is ($lex->get("bleh"), 	 '', 				"A bad request gives an empty string");
is ($lex->get("animal"), "animal",          "Good root-level check");
is ($lex->get("human"),	 "ape",				"get() ok");
is ($lex->get("mammal"), "vertebrate",  	"get() ok");


is ($lex->is("human", "human")     ,1, "is() passes a true check (top level IS self)");
is ($lex->is("primate", "primate") ,1, "is() passes a true check (mid level IS self)");
is ($lex->is("animal", "animal")   ,1, "is() passes a true check (root level IS self)");
is ($lex->is()                     ,0, "is() rejects a parameterless check");
is ($lex->is("")                   ,0, "is() rejects a blank character check");
is ($lex->is("", "")               ,0, "is() rejects a double-blank check");
is ($lex->is("animal", "")         ,0, "is() rejects a check with blank parent");
is ($lex->is("", "animal")         ,0, "is() rejects a check with blank entry");
is ($lex->is("garbage", "garbage") ,0, "is() rejects equal but non-existant names");
is ($lex->is("human", "ape")       ,0, "is() rejects a not-quite-true check");
is ($lex->is("human", "yeti")      ,0, "is() rejects a check against a nonexistant parent");
is ($lex->is("yeti",  "ape")       ,0, "is() rejects a check for a nonexistant entry");

is ($lex->isa("human", "human")    ,1 ,"isa() passes a check for two equals");
is ($lex->isa("human", "ape")      ,1 ,"isa() passes a check for first-order membership");
is ($lex->isa("human", "primate")  ,1 ,"isa() passes a check for second-order membership");
is ($lex->isa("human", "animal")   ,1 ,"isa() passes a check for root-level membership");
is ($lex->isa("human", "monkey")   ,0 ,"isa() rejects a check for non-membership");
is ($lex->isa("ape", "human")      ,0 ,"isa() rejects a check for reversed membership");


#test handling of payloads
#payloads carry over to stored copy
#payloads in lexicon carry over to gotten glyphs
#culling of payloads X levels deep


done_testing();
