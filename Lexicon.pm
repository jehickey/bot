package Lexicon;

use strict;
use warnings;
use JSON;
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


#Gets the definition of a lexicon entry by name.
#Returns the entry, or 0 for failure
sub get {
	my ($self, $name) = @_;

	#is the request valid?
	if (!$name) {return "";}								#No name was requested.
	$name = lc "$name";										#don't worry about much cleanup since dirty strings wouldn't be here

	#is it in the index?
	if (!exists $self->{index}{$name}) {return "";}			#Nothing listed by that name.
	#if ($self->{index}{$name} eq "") {return '0';}			#this entry exists but has no parent (root)
	return $self->{index}{$name};							#return a copy of what's there
}

sub is {
	my ($self, $a, $b) = @_;
	if (!$a || !$b) {return 0;}
	if (!exists $self->{index}{$a})	{return 0;}				#reject if either item doesn't exist
	if (!exists $self->{index}{$b}) {return 0;}				#reject if either item doesn't exist
	return (lc($a) eq lc($b)) ? 1 : 0;						#return true if both have the exact same name
}


sub isa {
	my ($self, $a, $b) = @_;
	#print "]$a\n";
	#print ">$b\n";
	if (!$a || !$b) {return 0;}
	if (!exists $self->{index}{$a}) {return 0;}					#reject if either item doesn't exist
	if (!exists $self->{index}{$b}) {return 0;}					#reject if either item doesn't exist
	
	foreach my $ancestor ($self->parents($a)) {
		if ($b eq $ancestor) { return 1; }
	}
	
#	if (lc($a) eq lc($b))		{return 1;}					#if they're they same that's an immediate true
	#print "hi!\n";
#	foreach my $item (%{$self->{index}}) {				#see if $b is anywhere in $a's family
		#print ">>> $b $item\n";
#		if ($b eq "".$self->{index}{$item}) {return 1;}
#	}
	return 0;												#still here?  They're not related.
}

#is this a peer?
sub islike {
	my ($self, $a, $b) = @_;
	return 0;
}


sub parents {
	my ($self, $type) = @_;
	if (!$type) {return [];}
	if (!exists $self->{index}{$type}) {return [];}
	my @results;
	while ($type) {
		push (@results, $type);
		my $parent = $self->{index}{$type};
		$type = ($parent eq $type) ? "" : $parent;						#if the parent is the same as the type, we're at root level and should stop.
	}
	return @results;
	}


sub count {
	my ($self) = @_;
	return scalar keys %{$self->{index}};
}

sub clear {
	my ($self) = @_;
	$self->{index} = {};
}

sub verbose {
	my ($self, $value) = @_;
	if (!$value)    {$value=0;}
	if ($value > 1) {$value=1;}
	$self->{verbose} = $value;
}


#Adds an entry to the Lexicon, tied to a parent (if any).
#Returns a safe copy of the symbol that was created.
sub add {
	my ($self, $name, $parent) = @_;
	if (!$name) {return error("Adding blank entry");}														#entry must be named
	$name   = lc $name;
	$parent = lc $parent;
	if (exists $self->{index}{$name}) {return error("Entry $name already exists");}						#no duplicates
	if ($parent && $parent ne $name && !exists $self->{index}{$parent}) {return error("Parent $parent does not exist");}		#parent must exist
	
	if (!$parent) {$parent = $name;}																		#root level entries are their own parent

	#add this entry to the lexicon index
	$self->{index}{$name} = $parent;
	#if ($parent) {	push (@{$self->{index}{$name}}, $parent);}
	#if ($parent) {	push (@{$self->{index}{$name}}, @{$self->{index}{$parent}});}


	#verify the name doesn't exist
	#verify the parent (if any) does exist
	



	$self->debug("Adding $name to lexicon");

	return 1;
}


#returns true if something exists by that name
sub _exists {
	my ($self, $name) = @_;
	if ($name) { return ( exists $self->{index}{$name} ); }
	return 0;
}

sub _parent_exists {
	my ($self, $name) = @_;
	if (!$name) { return 0; }
	foreach my $child (@{$self->{index}}) {
		if ($self->{index}{$child} eq "$name") {return 1;}
	}
	return 0;
}




sub list {
	my ($self) = @_;
	my @result;
	foreach my $entry (keys %{$self->{index}}) {
		#push (@result, @{$self->{index}{$entry}});
		print join (':', @{$self->{index}{$entry}}) . "\n";
	}
	#print Dumper(@result);
	return @result;
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
	return 0;
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
	$self->add	("grammar");
	$self->add	("statement");
	$self->add	("error");
	$self->add	("person");
	$self->add	("place");
	$self->add	("thing");
	$self->add	("quantity");
	$self->add	("abstract");
	$self->add	("command");
	$self->add	("data");
	
	
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
	$self->add  ("word", 				"grammar");
	$self->add  ("symbol", 				"grammar");
	$self->add  ("subject", 			"grammar");
	$self->add  ("predicate", 			"grammar");
	$self->add  ("conditional", 		"grammar");
	$self->add  ("punctuation", 		"grammar");
	$self->add  ("part of speech", 		"grammar");
	

	#punctuation
	$self->add(",",					"punctuation");
	$self->add("'",					"punctuation");
	$self->add("\"",				"punctuation");
	$self->add("terminator",		"punctuation");
		$self->add("?",				"terminator");
		$self->add("!",				"terminator");
		$self->add(".",				"terminator");

	
	#parts of speech
	$self->add	("multiple", 			"part of speech");
	$self->add	("unknown",				"part of speech");
	$self->add	("noun", 				"part of speech");
	$self->add		("proper", 			"noun");
	$self->add	("verb", 				"part of speech");
	$self->add	("article", 			"part of speech");
	$self->add		("definite", 		"article");
	$self->add		("indefinite", 		"article");
	$self->add	("pronoun", 			"part of speech");
	$self->add		("posessive",		"pronoun");
	$self->add	("adjective", 			"part of speech");
	$self->add	("adverb", 				"part of speech");
	$self->add	("preposition", 		"part of speech");
	$self->add	("conjunction", 		"part of speech");
	$self->add	("interjection", 		"part of speech");
	
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
