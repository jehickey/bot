use strict;
use warnings;
use Test::More;
use Data::Dumper;

require_ok ('Glyph');
require_ok ('Lexicon');
require_ok ('Dictionary');

my $lex = Lexicon->new();
$lex->load();	#for this test we want the full lexicon
$Glyph::lex = $lex;


#testing dictionary lookups well requires a lot of glyph validation

my $dict = Dictionary->new($lex);
is (ref $dict, "Dictionary", "Dictionary instantiated");
is ($dict->get("test"), '', "Failed to retrieve nonexistant word");
#print Dumper $dict->get("test");
ok ($dict->add("test", "noun"), "Dictionary accepts new words");
is ($dict->count(), 1, "Dictionary has a single word in it");
print Dumper $dict->get("test");
is ($dict->get("test")->is("noun"), 1, "Definition responds with a typedef of noun");
is ($dict->get("test")->value(), "test", "Word's value is the word itself");
ok ($dict->get("test","noun")->is("noun"),    "Word can be found as a noun");
ok (!$dict->get("test","article")->isa("grammar"), "Word can't be found as an article");


my $dict2 = Dictionary->new($lex);
ok (ref $dict2 eq "Dictionary", "A second Dictionary instantiates");
ok ($dict2->add("test2", "verb"), "Second Dictionary accepts new words");
is ($dict2->get("test2"), "verb", "Word can be retrieved from Dictionary");
is ($dict2->get("test")->isa("grammar"), 0, "No cross contamination with the original Dictionary");
is ($dict->get("test2")->isa("grammar"), 0, "No cross contamination with the second Dictionary");
$dict2->add("test3", "verb");
is ($dict->count(),  1, "Original dictionary has only its defintion");
is ($dict2->count(), 2, "Second dictionary has only its two defintions");



ok ($dict->add("test", "verb"),       	 "Dictionary accepts multiple definitions for a word");
is ($dict->get("test")->type(),        	 "multiple", "Test now returns multiple definitions");
ok ($dict->get("test")->has("noun"),     "Multiple response contains a noun");
ok ($dict->get("test")->has("verb"),     "Multiple response contains a verb");
ok (!$dict->get("test")->has("pronoun"), "Multiple response does not contain a pronoun");


ok (!$dict->add("test", "verb"), "Dictionary rejects a repeat of the same definition");
ok ($dict->add("toast", "noun"), "Dictionary still allows a different word to be added");


#definitions with modifiers
ok ($dict->add("red", "adjective:color"), 	"Entry with modified definition accepted");
ok ($dict->get("red")->is("adjective"),		"Modified definition works in general lookup");
ok ($dict->get("red", "adjective")->is("adjective"),		"Modified definition works in specific lookup");
ok ($dict->get("red", "adjective")->value("red"),		"Modified definition works in specific lookup");
ok ($dict->add("red", "adjective:name"), 	"Entry with modified definition accepted");


#complex lookups
print Dumper $dict->get("verb>test");
is ($dict->get("verb>test")->type(),  "verb", "Complex word lookup A: pos>word");
is ($dict->get("noun>test")->type(),  "noun", "Complex word lookup B: pos>word");
is ($dict->get("verb>glark")->type(), "",     "Complex word lookup with bad word");
is ($dict->get("glorx>test")->type(), "",     "Complex word lookup with bad type");

#is ($dict->get("red:color")->type(), "verb", "Complex word lookup: pos>word");



#build a test dictionary
$dict->add("the", "definite");
$dict->add("a",   "indefinite");


done_testing();
