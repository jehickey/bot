package Word;

use warnings;
use strict;
use Data::Dumper;

my @_modifiers;
sub modifiers {
	return @_modifiers;
	}

sub new {
	my $class = shift;
    my $text  = shift;			#grab the text of the word, if provided
	my $self  = {
		text    => $text,
		pos     => 0,
		posName => '',
	  	seen    => 0,
		properties => {}
	};
	bless ($self, $class);
	return $self;
}

sub AddModifier {
	my $self = shift;
	my $mod  = shift;
	if (!$mod) {print "No modifier!\n"; return;}
	push @{$self->{'modifiers'}}, $mod;
}

sub Dump {
	my $self = shift;
    print ">>> " . $self->{'text'} . " <<<\n";
	while (my ($k,$v) = each %$self) {
		if ($v) {print "   $k = $v\n";}
			else {print "   $k\n";}
		}
	foreach my $word (@{$self->{modifiers}}) {
#		if ($word) {
			print "      MOD: \"" . $word->{'text'} . "\" (" . $word->{'posName'} . ")\n";
#		}
	}
}


1;

#word text (original as seen in input)
#metrics
	#first-letter capitalized?
	#entire word capitalized?
	#part of speech (id)
	#part of speech (label)

