#!/usr/bin/perl -w
use strict;
use lib qw(/var/www/lib/perl /home/groups/p/pa/palabra/lib);
use Palabra;

die "USAGE: $0 language_names\n" unless @ARGV;
my $file = shift;

my $p = Palabra->new();
my $dbh = $p->db_connect();

create_allowed_tags();
create_languages();

$dbh->disconnect();

sub create_allowed_tags {
    my @allowed_tags = qw(dd dl dt em h1 h2 h3 h4 h5 h6 h7 li ol p strong table td tr ul);
    my $create_tags =  q{ (
			   id int(11) NOT NULL auto_increment,
			   tag varchar(10) NOT NULL,
			   PRIMARY KEY (id),
			   UNIQUE KEY tag (tag)
			   ) };
    
    $dbh->do( "DROP TABLE IF EXISTS allowed_tags" );
    $dbh->do( "CREATE TABLE allowed_tags $create_tags" );
    map { $dbh->do( "INSERT INTO allowed_tags (tag) VALUES(?)", undef, $_ ) } @allowed_tags;
} # sub create_allowed_tags

sub create_languages {
    my $ref_lang = get_languages();
    
    my $create_languages = q{ (
			       id int(11) NOT NULL auto_increment,
			       lang_code varchar(5) NOT NULL,
			       lang_name varchar(255) NOT NULL,
			       PRIMARY KEY (id),
			       UNIQUE KEY lang_code (lang_code),
			       UNIQUE KEY lang_name (lang_name)
			       ) };
    
    $dbh->do( "DROP TABLE IF EXISTS languages" );
    $dbh->do( "CREATE TABLE languages $create_languages" );

    my $create_lang = q{ (
			  word_id int(11) NOT NULL auto_increment,
			  word varchar(255) binary NOT NULL,
			  lang varchar(255) NOT NULL,
			  description text,
			  t timestamp,
			  PRIMARY KEY (word_id),
			  UNIQUE KEY word (word)
			  ) };
    map {
	$dbh->do( "DROP TABLE IF EXISTS $_" );
	$dbh->do( "CREATE TABLE $_ $create_lang" );
	$dbh->do( "INSERT INTO languages (lang_code, lang_name) VALUES(?, ?)", undef, $_, $ref_lang->{$_} );
    } keys %{$ref_lang};

    my $create_trans = q{ (
			   id int(11) NOT NULL auto_increment,
			   word_id int(11) NOT NULL,
			   lang varchar(5) NOT NULL,
			   trans varchar(255) binary NOT NULL,
			   PRIMARY KEY (id)
			   ) };
    
    map {
	$dbh->do( "DROP TABLE IF EXISTS ${_}_trans" );
	$dbh->do( "CREATE TABLE ${_}_trans $create_trans" );
    } keys %{$ref_lang};
} # sub create_languages

sub get_languages {
    my %lang;
    open IN, $file or die $!;
    while (<IN>) {
	chomp;
	my($key, $val) = split / /, $_, 2;
	$lang{$key} = $val;
    }
    return \%lang;
} # sub get_languages

__END__
Todo
* add alphabet
