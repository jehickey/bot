use strict;
use warnings;
use Test::More;

require_ok ('Glyph');

#instantiation tests
my $g = Glyph->new();
ok (ref $g eq "Glyph", "Empty glyph instantiates");
is ($g->{name}, "",  "Empty glyph has undefined name");
is ($g->{name}, "$g", "Glyph stringies into its name");

my $apple = Glyph->new("apple");
is ("$apple", "apple", "Name set properly and in all-lowercase");
is ($apple->{id}, 0, "No ID assigned at creation");
my $apple2 = $apple->clone();		#cloned before we added anything to it

my $rotten = Glyph->new("rotten");
is ($apple->add($rotten),1, "Glyph accepts payload");
my $apple3 = $apple->clone();		#cloned after we added something to it
is ($apple->has($rotten),  1, "Check for true modifier by reference");
is ($apple->has("rotten"), 1, "Check for true modifier by name");
#is ($apple2->has("rotten"), 0, "Changes to one symbol do not impact a copy");
is ($apple3->has("rotten"), 1, "Modifiers carry over during copy");


#test setting parentage at creation
#no duplicates payloads - adding a duplucate merges their payloads (if any)


done_testing();