#!/usr/bin/perl -wT
# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind. See the file LICENSE for redistribution terms.
use strict;
use lib qw(/var/www/lib/perl /home/groups/p/pa/palabra/lib);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Palabra;

$CGI::POST_MAX=1024*100;  # max 100 KBytes posts
$CGI::DISABLE_UPLOADS = 1;  # no uploads
my $q = CGI->new();

my $lang = $q->param('lang'); # set language
my $word = $q->param('word'); # word looked up

# locale settings
use locale;
use POSIX 'locale_h';
setlocale(LC_CTYPE, $lang);# or die "Invalid locale";
die "Entry '$lang' is not accepted" unless $lang =~ m/^\w\w_\w\w$/;

my $p = Palabra->new(word => $word, lang => $lang);
$word = $p->trim_ws($word);

# connect to MySQL database. Check if word exists, if not create new entry.
my $dbh = $p->db_connect();
my $stmt = "SELECT * FROM $lang WHERE word = ? AND language = ?";
my $sth = $dbh->prepare($stmt);
$sth->execute($word, $lang);
my $ref = $sth->fetchrow_hashref();
$sth->finish();

# create new entry for word in corresponding language table
unless ($ref) {
    $dbh->do("INSERT INTO $lang (word,language) VALUES(?,?)", undef, $word, $lang);
            
    # get info for display
    $stmt = "SELECT * FROM $lang WHERE id = LAST_INSERT_ID()";
    $sth = $dbh->prepare($stmt);
    $sth->execute();
    $ref = $sth->fetchrow_hashref();
    $sth->finish();
}
$dbh->disconnect();

# stuff info into Palabra Object
$p->{description} = $ref->{description};
$p->{id} = $ref->{id};

# print HTML page for word
print $p->html_header();
print $p->{description} ? $p->{description} : $p->display_edit_form();
print $p->html_footer();
