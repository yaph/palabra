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

my $word_id = $q->param('word_id');
my $word = $q->param('word');
my $lang = $q->param('lang');

# check values
die "'$word_id' is not accepted" unless $word_id =~ m/^\d+$/;
die "'$lang' is not accepted" unless $lang =~ m/^\w\w_\w\w$/;

my $script = $q->url( -relative => 1 );

# new Palabra object
my $p = Palabra->new( word_id => $word_id,
		      word => $word,
		      title => 'Edit description',
		      lang => $lang,
		      script => $script );

$word = $p->trim_ws($word);
die "Entry '$word' is not accepted" if $word eq '';

# connect to MySQL database and get information for word.
my $dbh = $p->db_connect();
my $stmt = "SELECT * FROM $lang WHERE word_id = ? AND word = ? AND lang = ?";
my $sth = $dbh->prepare($stmt);
$sth->execute($word_id, $word, $lang);
my $ref = $sth->fetchrow_hashref();
$sth->finish();
$dbh->disconnect;

# word_id doesn't exist
die "Don't play around with query string" unless $ref;

# date and time
my ($y, $m, $d, $h, $min, $s) = unpack("A4A2A2A2A2A2", $ref->{t});

# print HTML edit page for word
print $p->html_header(),
    $q->p( "Last edited: $d.$m.$y $h:$min:$s" ),
    $p->display_edit_form( word_id => $word_id,
			   word => $word,
			   lang => $lang,
			   description => $ref->{description} ),
    $p->html_footer();
