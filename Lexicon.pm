package Lexicon;

use strict;
use warnings;
use Glyph;
use JSON -convert_blessed_universally;
use File::Slurp;
use Data::Dumper;


my $lexfile = "lex.json";

sub new {
	my ($class) = @_;

	return bless {
		verbose => 0,
		index   => {}
	}, $class;
}



#Gets a copy of a listed symbol by name.
#Returns a safe copy of that glyph, or null if not found.
sub get {
	my ($self, $name) = @_;

	#is the request valid?
	if (!defined $name) {return Glyph->new();}					#No name was requested.
	if (ref $name eq "Glyph") {	$name = "$name";}		#it's getting it by name, no matter how it was asked
	$name = lc $name;										#don't worry about much cleanup since dirty strings wouldn't be here

	#is it in the index?
	if (!$self->{index}{$name}) {return Glyph->new();}		#Nothing listed by that name.

	return $self->{index}{$name}->clone();				#return a copy of what's there
}

sub count {
	my ($self) = @_;
	return scalar keys %{$self->{index}};
}

sub clear {
	my ($self) = @_;
	$self->{index} = {};
}


#Adds an entry to the Lexicon, tied to a parent (if any).
#Returns a safe copy of the symbol that was created.
sub add {
	my ($self, $glyph, $parent) = @_;
	if (!defined $glyph) {return error("Glyph required");}			#some symbolic information is required
	#if (!defined $parent) {$parent = 0;}
	if (ref $glyph ne "Glyph") {				#if what they sent isn't a glyph...
		$glyph = Glyph->new("$glyph");			#then we will make it a glyph.
	}
	$glyph = $glyph->clone();					#avoid interfering with the original

	#name validation and sanity check
	my $name = "$glyph";
	if ($name eq "") {return error("Name required");}				#glyph must be named
	
	#prevent duplication
	#print Dumper $self->get($name);
	if ($self->get($name)) {return error("\"$name\" already exists");	}

	#assign parentage and check validity (fail on reject)
	if ($parent) {
		my $parent_name = "$parent";
		$parent = $self->get($parent_name);									#use the version from the lexicon
		if (!$parent) {return error("Parent $parent does not exist");}
		$glyph->inherit($parent);
	}
	

	#assign it an id	

	#add this glyph to the lexicon index
	$self->{index}{$name} = $glyph;
	$self->debug("Adding $name to lexicon");

	return $glyph;
}


sub list {
	my ($self) = @_;
	foreach my $name (keys %{$self->{index}}) {
		my $glyph = $self->{index}{$name};#, "Glyph";
		if ($glyph)  {print "$glyph: " . $glyph->toString(0) . "\n";}
	}
}


sub load {
	my ($self) = @_;
	return $self->hardLoad();
	$self->clear();
	if (!-f $lexfile) {return error("Lex data file not found!");}
	my $str = read_file($lexfile);
	#print "\n$str\n\n";
	my $json = decode_json($str);
	$self->{index} = %$json;
	foreach my $key (keys %{$self->{index}}) {									#json objects decode as unblessed
		bless $self->{index}{$key}, "Glyph";								#blessings be upon this glyph
	}
}

sub save {
	my ($self) = @_;
	my $json = JSON->new->allow_nonref->convert_blessed;
	$json->pretty(1);
	my $str = $json->encode(\%{$self->{index}});

	open (my $file, ">", $lexfile);
	print $file $str . "\n";
	close $file;
	#print "\n$str\n\n";	
}


sub error {
	my $message = shift || "";
	print "! Lexicon: $message\n";
	my $error = Glyph->new("error");
	$error->{value} = $message;
	my $result = Glyph->new();
	$result->add($error);
	return $result;
}

sub debug {
	my ($self, $message) = @_;
	if (!defined $self) {return 0;}
	if (!$self->{verbose}) {return 0;}
	$message = $message || "";
	print "* Glyph: $message\n";
	return 1;
}



sub hardLoad {
	my ($self) = @_;
	$self->clear();
	
	#root level
	$self->add("grammar");
	$self->add("statement");
	$self->add("error");
	$self->add("person");
	$self->add("place");
	$self->add("thing");
	$self->add("quantity");
	$self->add("abstract");
	$self->add("command");
	$self->add("data");
	
	
	#data
	$self->add	("boolean",				"data");
	$self->add		("true",			"boolean");
	$self->add		("false",			"boolean");
	$self->add  ("text",				"data");
	$self->add  ("number",				"data");
	$self->add  	("integer",			"number");
	$self->add  	("real",			"number");
	$self->add  ("list", 				"data");
	
	
	#grammar
	$self->add	  ("word", 				"grammar");
	$self->add	  ("symbol", 			"grammar");
	$self->add	  ("subject", 			"grammar");
	$self->add	  ("predicate", 		"grammar");
	$self->add	  ("conditional", 		"grammar");
	$self->add	  ("punctuation", 		"grammar");
	$self->add	  ("part of speech", 	"grammar");
	

	#punctuation
	$self->add(",",					"punctuation");
	$self->add("'",					"punctuation");
	$self->add("\"",				"punctuation");
	$self->add("terminator",		"punctuation");
		$self->add("?",				"terminator");
		$self->add("!",				"terminator");
		$self->add(".",				"terminator");

	
	#parts of speech
	$self->add	  ("multiple", 			"part of speech");
	$self->add	  ("noun", 				"part of speech");
		$self->add("proper", 			"noun");
	$self->add	  ("verb", 				"part of speech");
	$self->add	  ("article", 			"part of speech");
		$self->add("definite", 			"article");
		$self->add("indefinite", 		"article");
	$self->add	  ("pronoun", 			"part of speech");
	$self->add	  ("adjective", 		"part of speech");
	$self->add	  ("adverb", 			"part of speech");
	$self->add	  ("preposition", 		"part of speech");
	$self->add	  ("conjunction", 		"part of speech");
	$self->add	  ("interjection", 		"part of speech");
	
	#gramatical elements
	$self->add  ("element", 							"grammar");
	$self->add	("plurality", 							"element");
	$self->add		("singular", 						"plurality");
	$self->add		("plural", 							"plurality");
	$self->add  ("gender", 								"element");
	$self->add		("male", 							"gender");
	$self->add		("female", 							"gender");
	$self->add		("neutral", 						"gender");
	$self->add  ("tense", 								"element");
	$self->add		("past", 							"tense");
	$self->add			("past simple",					"past");
	$self->add			("past progressive",			"past");
	$self->add			("past perfect",				"past");
	$self->add			("past perfect progressive",	"past");
	$self->add		("present", 						"tense");
	$self->add			("present simple",				"present");
	$self->add			("present progressive",			"present");
	$self->add			("present perfect",				"present");
	$self->add			("present perfect progressive",	"present");
	$self->add		("future", 							"tense");
	$self->add			("future simple",				"future");
	$self->add			("future progressive",			"future");
	$self->add			("future perfect",				"future");
	$self->add			("future perfect progressive",	"future");
}

1;
