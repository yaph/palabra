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
die "'$lang' is not accepted" unless $lang =~ m/^\w\w_\w\w$/;

my $p = Palabra->new( lang => $lang );
$p->{home_url} = sprintf( "index.cgi?lang=%s", $q->escape($lang) );

# HTML header information
my $author = 'Ramiro Gómez, ramiro@rahoo.de';
my $css = '/style/palabra.css';
my $home = 'palabra';

my @todo = ( 'Phrases', 'I18N', 'locale settings', 'Documentation', 'synonymity (must be the same language as the one currently set)', 'translation (languages must be different)' );
my @requirements = ( 'A web server', 'MySQL', 'Perl 5.008 or higher', 'Perl Modules: CGI, CGI::Carp, DBI, DBD::mysql, HTML::Parser, Net::SMTP');


print $q->header(), $q->start_html( 
				    -title => $home,
				    -meta => { copyright => "copyright 2003 $author" },
				    -style=>{ src => $css }
				    ),
    $q->table( { -width => '100%', -class => 'top_bar' },
	       $q->Tr(
		      $q->td( { -class => 'left' }, $q->a( { -href => $p->{home_url} }, $p->{home} ), ' : ',  'About palabra' ),
		      $q->td( { -class => 'right' }, $p->display_look_up_form($p->{lang}) )
		      ) # $q->Tr
	       ), # $q->table
    $q->h2( 'palabra ' . $Palabra::VERSION ),
    $q->p('Copyright 2003 Ramiro Gómez. All rights reserved!'),
    $q->p('This program is offered without warranty of any kind. See the file LICENSE for redistribution terms.'),
    
    $q->h2( 'Summary' ),
    $q->p('Palabra is a web-based dictionary that lets users edit and modify the descriptions of the entries. It is written in Perl and uses a MySQL database. During the look up process words are added to the database unless they already exist. Entries are case-sensitive and not censored. All users can edit and modify descriptions of the chosen word. Descriptions may contain certain HTML-Tags to structure the content. Disallowed tags are stripped.'),
    
    $q->h2( 'Todo' ),
    $q->ul( $q->li(\@todo) ),
    
    $q->h2( 'Requirements' ),
    $q->ul( $q->li(\@requirements) ),

    $p->html_footer();
