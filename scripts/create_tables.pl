#!/usr/bin/perl -w
use strict;
use lib qw(/var/www/lib/perl /home/groups/p/pa/palabra/lib);
use Palabra;

die "USAGE: $0 language_names\n" unless @ARGV;
my $file = shift;

my $p = Palabra->new();
my $dbh = $p->db_connect();
my $table_prefix = $p->get_table_prefix;

#create_categories();
create_allowed_tags();
create_languages();

$dbh->disconnect();

#sub create_categories {
#   my $categories = q{ (
#			 cat_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
#			 parent_id INTEGER UNSIGNED,
#			 cat_name VARCHAR(30),
#			 level SMALLINT,
#			 lang_code VARCHAR(5) NOT NULL,
#			 PRIMARY KEY (cat_id)
#			 ) };
#    $dbh->do( "DROP TABLE IF EXISTS categories" );
#    $dbh->do( "CREATE TABLE categories $categories" );
#}

sub create_allowed_tags {
    my @allowed_tags = qw(a dd dl dt em h1 h2 h3 h4 h5 h6 h7 li ol p pre strong table td tr ul);
    my $create_tags =  q{ (
			   id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			   tag VARCHAR(10) NOT NULL,
			   PRIMARY KEY (id),
			   UNIQUE KEY tag (tag)
			   ) };
    my $table = $table_prefix . 'allowed_tags';
    $dbh->do( "DROP TABLE IF EXISTS $table" );
    $dbh->do( "CREATE TABLE $table $create_tags" );
    map { $dbh->do( "INSERT INTO $table (tag) VALUES(?)", undef, $_ ) } @allowed_tags;
} # sub create_allowed_tags

sub create_languages {
    my $ref_lang = get_languages();
    
    my $create_languages = q{ (
			       id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			       lang_code VARCHAR(5) NOT NULL,
			       lang_name VARCHAR(255) NOT NULL,
			       PRIMARY KEY (id),
			       UNIQUE KEY lang_code (lang_code),
			       UNIQUE KEY lang_name (lang_name)
			       ) };
    my $table = $table_prefix . 'languages';
    $dbh->do( "DROP TABLE IF EXISTS $table" );
    $dbh->do( "CREATE TABLE $table $create_languages" );

    my $create_lang = q{ (
			  word_id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			  word VARCHAR(255) BINARY NOT NULL,
			  description TEXT,
			  looked_up INTEGER UNSIGNED,
			  t TIMESTAMP,
			  PRIMARY KEY (word_id),
			  UNIQUE KEY word (word)
			  ) };
    map {
	my $table = $table_prefix . $_;
	$dbh->do( "DROP TABLE IF EXISTS $table" );
	$dbh->do( "CREATE TABLE $table $create_lang" );
	$dbh->do( "INSERT INTO palabra_languages (lang_code, lang_name) VALUES(?, ?)", undef, $_, $ref_lang->{$_} );
    } keys %{$ref_lang};

    my $create_trans = q{ (
			   id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
			   word_id INTEGER NOT NULL,
			   lang VARCHAR(5) NOT NULL,
			   trans VARCHAR(255) BINARY NOT NULL,
			   PRIMARY KEY (id)
			   ) };
    
    map {
	my $table = $table_prefix . $_ . '_trans';
	$dbh->do( "DROP TABLE IF EXISTS $table" );
	$dbh->do( "CREATE TABLE $table $create_trans" );
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
