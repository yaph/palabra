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

my $word_id = $q->param('word_id');
my $word = $q->param('word');
my $lang = $q->param('lang');

my $script = $q->url( -relative => 1 );

# new Palabra object
my $p = Palabra->new( word_id => $word_id,
		      word => $word,
		      lang => $lang,
		      script => $script );
my $UI = $p->get_UI;
$p->set_HTML_title($UI->{edit_desc_l});

# connect to MySQL database and get information for word.
my $dbh = $p->get_db_handle;
my $stmt = "SELECT * FROM $lang WHERE word_id = ? AND word = ?";
my $sth = $dbh->prepare($stmt);
$sth->execute($word_id, $word);
my $ref = $sth->fetchrow_hashref;
$sth->finish;

# word_id doesn't exist
$p->error unless $ref;

# date and time
my ($y, $m, $d, $h, $min, $s) = unpack("A4A2A2A2A2A2", $ref->{t});

# JavaScript code
my $JavaScript = qq<
    function add_tag(tag) {
	window.document.edit_desc.description.value += tag;
    }
>;
$p->set_JavaScript($JavaScript);
$p->set_nav_links;

my $page = $q->p( $UI->{last_edit_msg} . " $d.$m.$y $h:$min:$s" ) .
    $p->display_edit_form( word_id => $word_id,
			   word => $word,
			   lang => $lang,
			   description => $ref->{description} );
print $p->html_page($page);
