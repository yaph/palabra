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
my $trans = $q->param('trans');
my $tr_lang = $q->param('tr_lang');

# check values
die "'$word_id' is not accepted" unless $word_id =~ m/^\d+$/;
die "'$lang' is not accepted" unless $lang =~ m/^\w\w_\w\w$/;
die "'$tr_lang' is not accepted" unless ( !defined($tr_lang) || $tr_lang =~ m/^\w\w_\w\w$/ );

my $script = $q->url( -relative => 1 );

# new Palabra object
my $p = Palabra->new( word_id => $word_id,
		      word => $word,
		      title => 'Translations', 
		      lang => $lang, 
		      tr_lang => $tr_lang,
		      script => $script );

my $dbh = $p->db_connect();
# translation table
my $t = $lang . '_trans';

# get language hash reference
my $ref_lang = $p->get_languages($dbh);

if ( defined( $q->param('do') ) && $q->param('do') eq 'add_trans' ) { # add a translation
    # check whether translation was supplied
    $trans = $p->trim_ws($trans);
    die "Entry '$trans' is not accepted" if ($trans eq '');

    # test whether specified translation already exists
    my $stmt = "SELECT * FROM $t WHERE word_id = ? AND trans = ?";
    my $sth = $dbh->prepare($stmt);
    $sth->execute($word_id, $trans);
    my $a_ref = $sth->fetchrow_arrayref();

    unless (defined($a_ref)) {
	# translation does not exist, thus insert a new row into translation table
	$dbh->do( "INSERT INTO $t SET word_id = ?, lang = ?, trans = ?", undef, $word_id, $tr_lang, $trans );
    }

    # redirlect after insert, to avoid reload problem
    my $url = sprintf( "translate.cgi?word_id=%d;word=%s;lang=%s", $word_id, $q->escape( $word ), $lang ); 
    print $q->redirect( $url );
} else { # show translation if available
    print $p->html_header();

    # get translation from DB
    $word_id = $dbh->quote($word_id);
    my $stmt = "SELECT trans, lang FROM $t WHERE word_id = $word_id ORDER BY lang, trans";
    my $sth = $dbh->prepare($stmt);
    $sth->execute();
    my $count;

    while ( my $ref = $sth->fetchrow_hashref() ) {
	my $trans = $ref->{trans};
	my $lang = $ref->{lang};
	my $lang_name = $ref_lang->{$lang};
	my $url = sprintf( "look_up.cgi?word=%s&lang=%s", $q->escape( $trans ), $lang  ); 
	print $q->p( $q->a( { -href => $url }, $trans ), ' - ', $q->small( $lang_name ) );
	$count++;
    }
    $sth->finish();
    $dbh->disconnect;
    
    $count || print $q->p('No translations were found.');
    
    print display_add_trans();
}

print $p->html_footer();

sub display_add_trans {
    delete $ref_lang->{$lang}; # delete source lang from hash
    return $q->h3('Add a translation:'),
    $q->start_form(),
    $q->popup_menu(
		   -name => 'tr_lang',
		   -values => [ sort keys %{$ref_lang} ],
		   -labels => $ref_lang,
		   -default => $lang
		   ),
		   $q->textfield(
				 -name => 'trans',
				 -override => 1,
				 -size => 20,
				 -maxlength => 80
				 ),
				 $q->hidden( -name => 'do', -value => 'add_trans' ),
				 $q->hidden( -name => 'word', -value => $word ),
				 $q->hidden( -name => 'word_id', -value => $word_id ),
				 $q->hidden( -name => 'lang', -value => $lang ),
				 $q->submit( -value => 'Add Translation' ),
				 $q->end_form();
} # sub display_add_trans
