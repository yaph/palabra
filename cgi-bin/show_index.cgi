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

# HTML header information
my $author = 'Ramiro Gómez, ramiro@rahoo.de';
my $css = '/style/palabra.css';
my $home = 'palabra';

my $lang = $q->param('lang');
my $letter = $q->param('letter');
my $start_pos = $q->param('start_pos');
my $page_size = 30;
my $max_rec = $q->param('max_rec');

my @nav_link; # array which holds navigational links
my $nav_link; # scalar to display navigational links
my $max_links = 20; # max namuber of page links shown

# regex for matching the first letter ignoring case
my $regex = '^[' .$letter . uc $letter . ']';

# check values
die "Entry '$letter' is not accepted" unless $letter =~ m/^[\w]?$/;
die "Entry '$lang' is not accepted" unless $lang =~ m/^[\w-]+$/;

my $p = Palabra->new( lang => $lang );
$p->{home_url} = sprintf( "index.cgi?lang=%s", $q->escape($lang) );

print $q->header(), $q->start_html( 
				    -title => $home,
				    -meta => { copyright => "copyright 2003 $author" },
				    -style=>{ src => $css }
				    ),
    $q->table( { -width => '100%', -class => 'top_bar' },
	       $q->Tr(
		      $q->td( { -class => 'left' }, $q->a( { -href => $p->{home_url} }, $p->{home} ), ' : ',  'Alphabetical index' ),
		      $q->td( { -class => 'right' }, $p->display_look_up_form($lang) )
		      )
	       ),
    $q->p( { -class => 'center' }, generate_alphabet() );

# if letter is chosen
if ($letter) { print $q->h2( $letter ), get_list(), $q->p( { -class => 'centersmall' }, $nav_link ) };

print $p->html_footer();

sub generate_alphabet  {
    return join " - ", map { 
	my $url = sprintf( "show_index.cgi?letter=%s;lang=%s", $q->escape($_), $q->escape($lang) );
	$q->a( { -href => $url }, $_ );
	} ('a'..'z');
} # sub generate_alphabet

sub get_list {
    my @list;
    my $dbh = $p->db_connect();
    
    # initially invoked get number of records matching letter
    if (!$start_pos) {
	$start_pos = 0;
	my $query = "SELECT COUNT(*) FROM $lang WHERE word REGEXP ?";
	$max_rec = $dbh->selectrow_array($query, undef, $regex);
	return "No words starting with $letter in this dictionary." unless $max_rec;
    }

    # generate links for navigating the listing
    if ($max_rec > $page_size) {
	
	# link to previous page
	if ($start_pos == 0) {
	    push @nav_link, 'previous';
	} else {
	    push @nav_link, generate_nav_link('previous', $start_pos - $page_size);
	}
	
	# links to individual pages
	my $num_pages = $max_rec / $page_size;
	
	if ($num_pages > $max_links) { # more than $max_links pages
	    my $min = ($start_pos - ($max_links / 2) * $page_size) / $page_size;
	    
	    if ($min < 0) {
		$max_links += $min;
		$min = 0;
	    }
	
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
	    
	} else { # less than $max_links pages
	    for (my $i = 0; $i < $max_rec; $i += $page_size) {
		my $page_num = int( $i / $page_size ) + 1;
		if ($start_pos == $i) { # don't link current page
		    push @nav_link, $page_num;
		} else {
		    push @nav_link, generate_nav_link($page_num, $i);
		}
	    }
	}
	
	# link to next page
	if ($start_pos + $page_size >= $max_rec) {
	    push @nav_link, 'next';
	} else {
	    push @nav_link, generate_nav_link('next', $start_pos + $page_size);
	}
	
	# put links in square brackets
	$nav_link = join " ", map { "[$_]" } @nav_link;
    }
    
    my $limit = "LIMIT $start_pos, $page_size";
    my $stmt = "SELECT * FROM $lang WHERE word REGEXP ? AND language = ? ORDER BY word $limit";
    my $sth = $dbh->prepare($stmt);
    $sth->execute($regex, $lang);
    while (my $ref = $sth->fetchrow_hashref()) {
	my $info = '';
	
	unless ($ref->{description}) {
	    $info = ' - <span class="small">No description yet</small>';
	}
	
	my  $url = sprintf( "look_up.cgi?id=%d;word=%s;lang=%s", $ref->{id}, $q->escape($ref->{word}), $q->escape($lang) );
	push @list, $q->a( { -href => $url }, $ref->{word} ) . $info;
    }
    $sth->finish();
    
    return $q->p( $q->em("Number of entries: $max_rec") ) . $q->ul( $q->li(\@list) );
} # sub get_list

sub generate_nav_link {
    my ($label, $start_pos) = @_;
    my $url = $q->url() . sprintf( "?lang=%s;letter=%s;max_rec=%d;start_pos=%d", $q->escape($lang), $q->escape($letter), $max_rec, $start_pos );
    return $q->a( { -href => $url }, $q->escapeHTML($label) );
} # sub generate_nav_link
__END__
* Show index: * show only words with descriptions
              * show only words without descriptions
