#!/usr/bin/perl -wT
# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind.
# See the file LICENSE for redistribution terms.
use strict;
use lib qw(/var/www/lib/perl /home/groups/p/pa/palabra/lib);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Palabra;

$CGI::POST_MAX=1024*100;
$CGI::DISABLE_UPLOADS = 1;
my $q = CGI->new();

my $word_id = $q->param('word_id');
my $word = $q->param('word');
my $lang = $q->param('lang');
my $trans = $q->param('trans');
my $tr_lang = $q->param('tr_lang');

my $script = $q->url( -relative => 1 );

# new Palabra object
my $p = Palabra->new( word_id => $word_id,
		      word => $word,
		      lang => $lang, 
		      tr_lang => $tr_lang,
		      script => $script );
my $UI = $p->get_UI;
$p->set_HTML_title($UI->{trans_l}); 

my $dbh = $p->get_db_handle;
# translation table
my $tr_table= $p->get_table_prefix . $lang . '_trans';

# get language hash reference
my $ref_lang = $p->get_languages($dbh);

if ( defined( $q->param('do') ) && $q->param('do') eq 'add_trans' ) { # add a translation
    # check whether translation was supplied
    $trans = $p->trim_ws($trans);
    $p->error if ($trans eq '');

    # test whether specified translation already exists
    my $stmt = "SELECT * FROM $tr_table WHERE word_id = ? AND trans = ? AND lang = ?";
    my $sth = $dbh->prepare($stmt);
    $sth->execute($word_id, $trans, $tr_lang);
    my $a_ref = $sth->fetchrow_arrayref();

    unless (defined($a_ref)) {
	# translation does not exist, thus insert a new row into translation table
	$dbh->do( "INSERT INTO $tr_table SET word_id = ?, lang = ?, trans = ?", undef, $word_id, $tr_lang, $trans );
	
	# add translation link from target to source
	$tr_table =~ s/^\w\w_\w\w/$tr_lang/;
	my $orig_trans = $trans;
	my $orig_source_lang = $lang;
	my $orig_target_lang = $tr_lang;
	
	# get word_id of original translation
	my $word_id = $p->add_word( dbh => $dbh,
				    word => $orig_trans,
				    lang => $orig_target_lang );
	$dbh->do( "INSERT IGNORE INTO $tr_table SET word_id = ?, lang = ?, trans = ?", undef, $word_id, $orig_source_lang, $word );
    }
    
    # redirect after insert, to avoid reload problem
    my $url = sprintf( "translate.cgi?word_id=%d;word=%s;lang=%s", $word_id, $q->escape( $word ), $lang ); 
    print $q->redirect( $url );
} else {
    $p->set_nav_links;
    my $page .= display_add_trans();
    print $p->html_page($page);
}

sub display_add_trans {
    delete $ref_lang->{$lang}; # delete source lang from hash
    my $url = sprintf( "look_up.cgi?word=%s&lang=%s", $q->escape( $word ), $lang  ); 
    my $link = $q->a( { -href => $url }, $word );
    my $HTML = $q->p($UI->{add_trans_msg} . ' ' . $link) . $q->start_form();
    $HTML .= $q->popup_menu(
			    -name => 'tr_lang',
			    -values => [ sort keys %{$ref_lang} ],
			    -labels => $ref_lang,
			    -default => $lang
			    );
    $HTML .= $q->textfield(
			   -name => 'trans',
			   -override => 1,
			   -size => 20,
			   -maxlength => 80
			   );
    $HTML .= $q->hidden( -name => 'do', -value => 'add_trans' );
    $HTML .= $q->hidden( -name => 'word', -value => $word );
    $HTML .= $q->hidden( -name => 'word_id', -value => $word_id );
    $HTML .= $q->hidden( -name => 'lang', -value => $lang );
    $HTML .= $q->submit( -value => $UI->{add_trans_b} );
    $HTML .= $q->end_form();
    return $HTML;
} # sub display_add_trans
