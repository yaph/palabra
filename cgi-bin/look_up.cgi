#!/usr/bin/perl -wT
# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind. See the file LICENSE for redistribution terms.
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

# new Palabra object
my $p = Palabra->new( word => $word,
		      title => $word,
		      lang => $lang);

$word = $p->trim_ws($word);
print $q->redirect('index.cgi') if $word eq '';

# connect to MySQL database. Check if word exists, if not create new entry.
my $dbh = $p->db_connect;
my $stmt = "SELECT * FROM $lang WHERE word = ?";
my $sth = $dbh->prepare($stmt);
$sth->execute($word);
my $ref = $sth->fetchrow_hashref;
$sth->finish;

# create new entry for word in corresponding language table
unless ($ref) {
    # redirect to add word form
    my $url = sprintf( "add_word.cgi?word=%s;lang=%s", $q->escape( $word ), $lang ); 
    print $q->redirect( $url );
}
$dbh->disconnect;

# stuff word_id into palabra object
# !!! todo: write an accessor method !!!
$p->set_word_id( $ref->{word_id} );
my $desc = $ref->{description} || $p->{UI}->{no_desc_msg};

# print page
print $p->html_header, $desc, $p->html_footer;
