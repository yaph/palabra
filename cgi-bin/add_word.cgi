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

my $word = $q->param('word');
my $lang = $q->param('lang');

# check value
print $q->redirect('index.cgi') unless $lang =~ m/^\w\w_\w\w$/;

# new Palabra object
my $p = Palabra->new( word => $word,
		      lang => $lang );
$word = $p->trim_ws($word);
print $q->redirect('index.cgi') if $word eq '';

my $dbh = $p->db_connect;

# get language hash reference
my $ref_lang = $p->get_languages($dbh);

if ( defined( $q->param('do') ) && $q->param('do') eq 'add_word' ) {
    my $word_id = $p->add_word( dbh => $dbh,
				word => $word,
				lang => $lang );
    my $url = sprintf("edit_word.cgi?word_id=%d;word=%s;lang=%s", 
		      $q->escape($word_id), $q->escape($word), $q->escape($lang));
    print $q->redirect($url);
} else {
    print display_add_word();
}

sub display_add_word {
    # HTML header information
    my $css = '/style/palabra.css';
    my $home = 'Palabra';
    my $title = $p->{UI}->{add_word_b};
    my $home_url = sprintf( "index.cgi?lang=%s", $q->escape($lang) );
    return $q->header(), $q->start_html( 
					 -title => $title,
					 -style=>{ src => $css }
					 ),
    $q->table( { -width => '100%', -class => 'navbar' },
	       $q->Tr(
		      $q->td( { -class => 'left' },
			      $q->a( { -href => $home_url }, $home ), ' : ', $title,
			      ),
		      $q->td( { -class => 'right' }, $p->display_look_up_form($lang) )
		      )
	       ),
		   $q->h4('Add entry to: ', $ref_lang->{$lang}),
		   $q->start_form( -action => 'add_word.cgi' ),
		   $q->hidden( -name => 'word', -value => $word ),
		   $q->hidden( -name => 'lang', -value => $lang ),
		   $q->hidden( -name => 'do', -value => 'add_word' ),
		   $q->p ( $q->textfield(
					 -name => 'word',
					 -size => 30,
					 -default => $word
					 ),
			   $q->submit( -value => $title )
			   ),
			   $q->end_form,
			   $p->html_footer;
}
