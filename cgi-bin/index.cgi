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

my $lang = $q->param('lang');
$lang = $q->http('Accept-language') unless $lang;
# change language name to a format accepted by locale
# the value of $q->http('Accept-language') may look like:
# en-us, en;q=0.50
$lang =~ s/^(\w\w)-(\w\w).*/$1_\U$2/;
$lang = 'en_US' unless $lang =~ /^\w\w_\w\w$/;

my $letter = $q->param('letter');
my $start_pos = $q->param('start_pos');
my $page_size = 15;
my $max_rec = $q->param('max_rec');

my @nav_link; # array which holds navigational links
my $nav_link; # scalar to display navigational links
my $max_links = 20; # max number of page links shown

my $p = Palabra->new( lang => $lang );
$p->error unless $letter =~ m/^[\w]?$/;
my $regex = '^[' .$letter . uc $letter . ']'; # match first letter ignore case

# connect to DB
my $dbh = $p->get_db_handle;
my $table = $p->get_table_prefix . $lang;

# get map of language codes and language names
my $ref_lang = $p->get_languages($dbh);

my $word_count = $dbh->selectrow_array("SELECT COUNT(*) FROM $table");
my $lang_name = $ref_lang->{$lang};

my $UI = $p->get_UI;
$p->set_HTML_title( $lang_name );
$p->set_word( $lang_name );
my $page = $q->p( $UI->{entry_total_msg} . ' ' . $word_count) . 
    $q->p( generate_alphabet() );

# if letter is chosen
if ($letter) { 
    my $word_list = get_list();
    $page .= $q->h4( $letter . " ($max_rec)" ) . $word_list . $q->p( $nav_link );
}
print $p->html_page($page);

sub generate_alphabet  {
    return join " - ", map { 
	my $url = sprintf( "show_index.cgi?letter=%s;lang=%s", $q->escape($_), $q->escape($lang) );
	$q->a( { -href => $url }, $_ );
    } ('a'..'z');
} # sub generate_alphabet

sub get_list {
    my @list;
    
    # initially invoked get number of records matching letter
    if (!$start_pos) {
	$start_pos = 0;
	my $query = "SELECT COUNT(*) FROM $table WHERE word REGEXP ?";
	$max_rec = $dbh->selectrow_array($query, undef, $regex);
	return $UI->{no_entries_msg} unless $max_rec;
    }

    # generate links for navigating the listing
    # link to previous page
    if ($start_pos == 0) {
	push @nav_link, $UI->{previous_l};
    } else {
	push @nav_link, generate_nav_link($UI->{previous_l}, $start_pos - $page_size);
    }
	
    my $num_pages = $max_rec / $page_size;
    
    # start position
    my $min = ($start_pos - ($max_links / 2) * $page_size) / $page_size;
    
    if ($min < 0) {
	$max_links += $min;
	$min = 0;
    }

    # links to individual pages
    my $count = 0;
    for (my $i = $min * $page_size; $i < $max_rec && $count < $max_links; $i += $page_size) {
	my $page_num = int( $i / $page_size ) + 1;
	$count++;
	if ($start_pos == $i) { # don't link current page
	    push @nav_link, $page_num;
	} else {
	    push @nav_link, generate_nav_link($page_num, $i);
	}
    }
	    
    # link to next page
    if ($start_pos + $page_size >= $max_rec) {
	push @nav_link, $UI->{next_l};
    } else {
	push @nav_link, generate_nav_link($UI->{next_l}, $start_pos + $page_size);
    }
    
    # put links in square brackets
    $nav_link = join " ", map { "[$_]" } @nav_link;
    
    my $limit = "LIMIT $start_pos, $page_size";
    my $stmt = "SELECT * FROM $table WHERE word REGEXP ? ORDER BY word $limit";
    my $sth = $dbh->prepare($stmt);
    $sth->execute($regex);
    while (my $ref = $sth->fetchrow_hashref) {
	my $info = '';
	
	unless ($ref->{description}) {
	    $info = ' - ' . $UI->{no_desc_msg};
	}
	
	my  $url = sprintf( "look_up.cgi?word_id=%d;word=%s;lang=%s", $ref->{word_id}, $q->escape($ref->{word}), $q->escape($lang) );
	push @list, $q->a( { -href => $url }, $ref->{word} ) . $info;
    }
    $sth->finish;
    
    return $q->ul( $q->li(\@list) );
} # sub get_list

sub generate_nav_link {
    my ($label, $start_pos) = @_;
    my $url = $q->url . sprintf( "?lang=%s;letter=%s;max_rec=%d;start_pos=%d", $q->escape($lang), $q->escape($letter), $max_rec, $start_pos );
    return $q->a( { -href => $url }, $q->escapeHTML($label) );
} # sub generate_nav_link
__END__
* Show index: * show only words with descriptions
              * show only words without descriptions
