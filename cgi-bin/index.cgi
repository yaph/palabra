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

# set language
my $lang = $q->param('lang');
$lang = $q->http('Accept-language') unless $lang;

# change language name to a format accepted by locale
# the value of $q->http('Accept-language') may look like:
# en-us, en;q=0.50
$lang =~ s/^(\w\w)-(\w\w).*/$1_\U$2/;
$lang = 'en_US' unless $lang =~ /^\w\w_\w\w$/;

# new Palabra object
my $p = Palabra->new(lang => $lang);

print $q->header, $q->start_html( 
				  -title => $p->{title},
				  -style=>{ src => $p->{css} }
				  ),
    $q->div( { -align => 'center', -valign => 'middle' }, $q->h2( $p->{title} ),
	     $p->display_look_up_form,
	     ),
    $p->html_footer;
