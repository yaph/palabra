#!/usr/bin/perl -wT
# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind. See the file LICENSE for redistribution terms.
use strict;
use lib qw(/srv/www/lib/perl /home/groups/p/pa/palabra/lib);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Palabra;

$CGI::POST_MAX=1024*100;
$CGI::DISABLE_UPLOADS = 1;
my $q = CGI->new;

my $word_id = $q->param('word_id');
my $word = $q->param('word');
my $lang = $q->param('lang');

my $script = $q->url( -relative => 1 );

# new Palabra object
my $p = Palabra->new( word_id => $word_id,
		      word => $word,
		      lang => $lang,
		      script => $script );
$p->error unless $word;
$p->error unless $word_id;
$p->error unless $lang;

my $table = $p->get_table_prefix . $lang;
my $UI = $p->get_UI;
$p->set_HTML_title($UI->{edit_desc_l});

# connect to MySQL database and get information for word.
my $dbh = $p->get_db_handle;
my $stmt = "SELECT * FROM $table WHERE word_id = ? AND word = ?";
my $sth = $dbh->prepare($stmt);
$sth->execute($word_id, $word);
my $ref = $sth->fetchrow_hashref;
$sth->finish;

# word_id doesn't exist
$p->error unless $ref;

# date and time
my ($y, $m, $d, $h, $min, $s) = unpack("A4A2A2A2A2A2", $ref->{t});

my $url = sprintf( "look_up.cgi?word=%s&lang=%s", $q->escape( $word ), $lang  ); 
my $link = $q->a( { -href => $url }, $word );
my $page = $link . $q->p( $UI->{last_edit_msg} . " $d.$m.$y $h:$min:$s" ) .
    $p->display_edit_form( word_id => $word_id,
			   word => $word,
			   lang => $lang,
			   description => $ref->{description} );
print $p->html_page($page);
