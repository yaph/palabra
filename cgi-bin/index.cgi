#!/usr/bin/perl -wT
# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind. See the file LICENSE for redistribution terms.
use strict;
use lib qw(/srv/www/lib/perl /home/groups/p/pa/palabra/lib);
use CGI;
use Palabra;
use BrowseEntries qw(browse_entries);

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
my $hit_total = $q->param('hit_total');

my $num_entries = 20;
my $max_links = 16; # max number of page links shown
my $nav_link; # scalar to display navigational links

my $p = Palabra->new( lang => $lang );
$p->error unless $letter =~ m/^[\w]?$/;

# connect to DB
my $dbh = $p->get_db_handle;
my $regex = $dbh->quote('^[' .$letter . uc $letter . ']'); # match first letter ignore case
my $table = $p->get_table_prefix . $lang;

# get map of language codes and language names
my $ref_lang = $p->get_languages($dbh);
my $lang_name = $ref_lang->{$lang};

my $UI = $p->get_UI;
$p->set_HTML_title( $lang_name );
$p->set_word( $lang_name );
my $word_count = $dbh->selectrow_array("SELECT COUNT(*) FROM $table");    
my $page = $q->p( $UI->{entry_total_msg} . ' ' . $word_count);
$page .= $q->div( { class => 'center' }, generate_alphabet() );

my $stmt = "SELECT * FROM $table WHERE word REGEXP $regex ORDER BY word";
# if letter is chosen
if ($letter) {
    my ($entries, $nav_link, $hit_total) = browse_entries (
							   dbh => $dbh,                 # database handle
							   table => $table,             # name of db table
							   stmt => $stmt,               # SQL statement
							   columns => [],               # db table columns that will be displayed
							   action => '',                # script to be invoked
							   start_pos => $start_pos,     # start position
							   num_entries => $num_entries, # number of entries to show
							   max_links => $max_links,     # max number of navigational links
							   hit_total => $hit_total,     # total number of hits
							   lang => $lang,
							   letter => $letter
							   );
   unless ($entries) { 
       $page .= $UI->{no_entries_msg};
   } else {
       $page .= $q->h4( $letter . " ($hit_total)" ) . $entries . $q->p( $nav_link );
   }
}

print $p->html_page($page);

sub generate_alphabet  {
    return join " - ", map { 
	my $url = sprintf( "index.cgi?letter=%s;lang=%s", $q->escape($_), $q->escape($lang) );
	$q->a( { -href => $url }, $_ );
    } ('a'..'z');
} # sub generate_alphabet

__END__
* show only words with descriptions
* show only words without descriptions
