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

my $word = $q->param('word');
my $lang = $q->param('lang');

# new Palabra object
my $p = Palabra->new( word => $word,
		      lang => $lang );
my $UI = $p->get_UI;
my $dbh = $p->get_db_handle;
my $title = '';

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
    $title = $p->set_HTML_title($UI->{add_word_b});
    my $page = display_add_word();
    print $p->html_page($page);
}

sub display_add_word {
    my $HTML = $q->p($UI->{add_word_msg}, $ref_lang->{$lang});
    $HTML .= $q->start_form( -action => 'add_word.cgi' );
    $HTML .= $q->hidden( -name => 'word', -value => $word );
    $HTML .= $q->hidden( -name => 'lang', -value => $lang );
    $HTML .= $q->hidden( -name => 'do', -value => 'add_word' );
    $HTML .= $q->textfield(
			   -name => 'word',
			   -size => 30,
			   -default => $word
			   );
    $HTML .= $q->submit( -value => $title );
    $HTML .= $q->end_form;
    return $HTML;
}
