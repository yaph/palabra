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

# set language
my $lang = $q->param('lang');
($lang = $q->http('Accept-language') || 'en_US') unless $lang;

# change language name to a format accepted by locale
# the value of $q->http('Accept-language') may look like:
# en-us, en;q=0.50
$lang =~ s/^(\w\w)-(\w\w).*/$1_\U$2/;

# HTML header information
my $author = 'Ramiro Gómez, ramiro@rahoo.de';
my $css = '/style/palabra.css';
my $home = 'palabra';

my $p = Palabra->new(lang => $lang);

# start main sub
display_start_page();

############# subroutines ###############
sub display_start_page {
    print $q->header(), $q->start_html( 
					-title => $home,
					-meta => { copyright => "copyright 2003 $author" },
					-style=>{ src => $css }
					),
    $q->div( { -align => 'center', -valign => 'middle' }, $q->h2( $home ),
	     $p->display_look_up_form(),
	     ), # $q->div
    $p->html_footer();
}
