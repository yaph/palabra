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

my $id = $q->param('id'); # id of word to edit
my $word = $q->param('word'); # set language
my $lang = $q->param('lang'); # set language

# check values
die "'$id' is not accepted" unless $id =~ m/^\d+$/;
die "'$lang' is not accepted" unless $lang =~ m/^\w\w_\w\w$/;

my $p = Palabra->new(word => 'Edit description', lang => $lang);

# connect to MySQL database and get information for word.
my $dbh = $p->db_connect();
my $stmt = "SELECT * FROM $lang WHERE id = ? AND word = ? AND language = ?";
my $sth = $dbh->prepare($stmt);
$sth->execute($id, $word, $lang);
my $ref = $sth->fetchrow_hashref();
$sth->finish();
$dbh->disconnect;

# id doesn't exist
die "Don't play around with query string" unless $ref;

# stuff info into Palabra object
$p->{id} = $id;
$p->{word} = $word;
$p->{lang} = $lang;
$p->{description} = $ref->{description};

# print HTML edit page for word
print $p->html_header(), $p->display_edit_form(), $p->html_footer();
