#!/usr/bin/perl -wT
# Copyright 2003 Ramiro Gómez.
# This program is offered without warranty of any kind.
# See the file LICENSE for redistribution terms.
use strict;
use lib qw(/var/www/lib/perl /home/groups/p/pa/palabra/lib);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Palabra;

$CGI::POST_MAX=1024*100;
$CGI::DISABLE_UPLOADS = 1;
my $q = CGI->new;

my $lang = $q->param('lang');
my $word = $q->param('word');

print $q->redirect('index.cgi') unless $lang =~ m/^\w\w_\w\w$/;

my $p = Palabra->new( word => $word,
		      title => $word,
		      lang => $lang);

$word = $p->trim_ws($word);
print $q->redirect('index.cgi') if $word eq '';

# Check if word exists.
my $dbh = $p->get_db_handle;
my $stmt = "SELECT * FROM $lang WHERE word = ?";
my $sth = $dbh->prepare($stmt);
$sth->execute($word);
my $ref = $sth->fetchrow_hashref;
$sth->finish;

unless ($ref) { # no entry so redirect to add word form
    my $url = sprintf( "add_word.cgi?word=%s;lang=%s", $q->escape( $word ), $lang ); 
    print $q->redirect( $url );
}

$p->set_nav_links;
$p->set_word_id( $ref->{word_id} );
my $UI = $p->get_UI;
my $page = $ref->{description} || $UI->{no_desc_msg};
print $p->html_page($page);
