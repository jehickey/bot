use strict;
use warnings;
use Test::More;
use Data::Dumper;

require_ok ('Toolkit');

is_deeply ([parse("alpha")], 					['alpha',''], 								"Simple");
is_deeply ([parse("alpha>beta")], 				['alpha','beta'], 							"Compound");
is_deeply ([parse("alpha:gamma")], 				['alpha','','gamma',''], 					"Segmented Simple");
is_deeply ([parse("alpha>beta:gamma>delta")], 	['alpha','beta','gamma','delta'], 			"Segmented Compound");
is_deeply ([parse("alpha:beta:gamma")], 		['alpha','','beta','','gamma',''], 			"Lots of segments");
is_deeply ([parse("alpha>a:beta:gamma>delta")],	['alpha','a','beta','','gamma','delta'],	"Mix of segments and compounds");

done_testing();