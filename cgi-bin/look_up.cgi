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

my $lang = $q->param('lang');
my $word = $q->param('word');

die "Entry '$lang' is not accepted" unless $lang =~ m/^\w\w_\w\w$/;

# new Palabra object
my $p = Palabra->new( word => $word,
		      title => $word,
		      lang => $lang);

$word = $p->trim_ws($word);
die "Entry '$word' is not accepted" if $word eq '';

# connect to MySQL database. Check if word exists, if not create new entry.
my $dbh = $p->db_connect();
my $stmt = "SELECT * FROM $lang WHERE word = ? AND lang = ?";
my $sth = $dbh->prepare($stmt);
$sth->execute($word, $lang);
my $ref = $sth->fetchrow_hashref();
$sth->finish();

# create new entry for word in corresponding language table
unless ($ref) {
    $dbh->do("INSERT INTO $lang (word,lang) VALUES(?,?)", undef, $word, $lang);
    
    # get info for display
    $stmt = "SELECT * FROM $lang WHERE word_id = LAST_INSERT_ID()";
    $sth = $dbh->prepare($stmt);
    $sth->execute();
    $ref = $sth->fetchrow_hashref();
    $sth->finish();
    }
$dbh->disconnect();

# stuff word_id into Palabra object needed for hidden field
$p->{word_id} = $ref->{word_id};

# print HTML page for word
print $p->html_header();
print $ref->{description} ? $ref->{description} : $p->display_edit_form();
print $p->html_footer();
