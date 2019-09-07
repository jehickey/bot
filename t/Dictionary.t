use strict;
use warnings;
use Test::More;
use Data::Dumper;

require_ok ('Glyph');
require_ok ('Lexicon');
require_ok ('Dictionary');

my $lex = Lexicon->new();
$lex->load();	#for this test we want the full lexicon

#testing dictionary lookups well requires a lot of glyph validation

my $dict = Dictionary->new($lex);
is (ref $dict, "Dictionary", "Dictionary instantiated");


is ($dict->get("test")->isa("grammar"), 0, "Failed to retrieve nonexistant word");
ok ($dict->add("test", "noun"), "Dictionary accepts new words");
is ($dict->count(), 1, "Dictionary has a single word in it");


is ($dict->get("test")->parent(), "noun", "New word retrieved from dictionary");
ok ($dict->get("test","noun")->isa("noun"),    "Word can be found as a noun");
ok (!$dict->get("test","verb")->parent(), "Word can't be found as a verb");


my $dict2 = Dictionary->new($lex);
ok (ref $dict2 eq "Dictionary", "A second Dictionary instantiates");
ok ($dict2->add("test2", "verb"), "Second Dictionary accepts new words");
is ($dict2->get("test2")->parent(), "verb", "Word can be retrieved from Dictionary");
is ($dict2->get("test")->isa("grammar"), 0, "No cross contamination with the original Dictionary");
is ($dict->get("test2")->isa("grammar"), 0, "No cross contamination with the second Dictionary");
$dict2->add("test3", "verb");
is ($dict->count(),  1, "Original dictionary has only its defintion");
is ($dict2->count(), 2, "Second dictionary has only its two defintions");



ok ($dict->add("test", "verb"), "Dictionary accepts multiple definitions for a word");
is ($dict->get("test")->parent(),        "multiple", "Test now returns multiple definitions");
ok ($dict->get("test")->has("noun"),     "Multiple response contains a noun");
ok ($dict->get("test")->has("verb"),     "Multiple response contains a verb");
ok (!$dict->get("test")->has("pronoun"), "Multiple response does not contain a pronoun");


ok (!$dict->add("test", "verb"), "Dictionary rejects a repeat of the same definition");
ok ($dict->add("toast", "noun"), "Dictionary still allows a different word to be added");





#build a test dictionary
$dict->add("the", "definite");
$dict->add("a",   "indefinite");


done_testing();
