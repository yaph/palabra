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

# check values
die "Entry '$letter' is not accepted" unless $letter =~ m/^[\w]?$/;
die "Entry '$lang' is not accepted" unless $lang =~ m/^[\w-]+$/;

my $p = Palabra->new( lang => $lang);
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
if ($letter) { print $q->h2( $letter ), get_list() };

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
    my $stmt = "SELECT * FROM $lang WHERE word REGEXP ? AND language = ? ORDER BY word";
    my $sth = $dbh->prepare($stmt);
    $sth->execute('^[' .$letter . uc $letter . ']', $lang);
    while (my $ref = $sth->fetchrow_hashref()) {
	my $info = '';
	
	unless ($ref->{description}) {
	    $info = ' - <span class="small">No description yet</small>';
	}
	
	my  $url = sprintf( "look_up.cgi?id=%d;word=%s;lang=%s", $ref->{id}, $q->escape($ref->{word}), $q->escape($lang) );
	push @list, $q->a( { -href => $url }, $ref->{word} ) . $info;
    }
    $sth->finish();
    
    return $q->ul( $q->li(\@list) );
} # sub get_list

__END__
* Show index: * show only words with descriptions
              * show only words without descriptions
              * show 20 entries
