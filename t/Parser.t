use strict;
use warnings;
use Test::More;

require_ok ('Glyph');
require_ok ('Lexicon');
require_ok ('Dictionary');
require_ok ('Parser');

my $lex = Lexicon->new();
$lex->load();	#for this test we want the full lexicon
$Glyph::lex = $lex;






done_testing();
