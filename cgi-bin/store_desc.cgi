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
my $q = CGI->new();

my $word_id = $q->param('word_id');
my $word = $q->param('word');
my $lang = $q->param('lang');
my $description = $q->param('description');

# check values
print $q->redirect('index.cgi') unless $word_id =~ m/^\d+$/;
print $q->redirect('index.cgi') unless $lang =~ m/^\w\w_\w\w$/;

my $p = Palabra->new( word => $word,
		      title => $word, 
		      lang => $lang );

$word = $p->trim_ws($word);
print $q->redirect('index.cgi') if $word eq '';

# connect to MySQL database
my $dbh = $p->db_connect();

# check description using HTML::Parser
$description = parse_html($description, $dbh);

# update information for word
$dbh->do("UPDATE $lang SET t = NOW(), description = ? WHERE word_id = ? AND word = ?", undef, $description, $word_id, $word );
$dbh->disconnect();

my $url = sprintf( "look_up.cgi?word_id=%d&lang=%s&word=%s", $word_id, $lang, $q->escape( $word ) ); 

# redirect to word
print $q->redirect( $url );

# parse descriptions
sub parse_html {
    my $text = shift;
    my $dbh = shift;
    
    my $ref_allowed_tags = $p->get_allowed_tags($dbh);
    
    use HTML::Parser;
    my $parser = HTML::Parser->new( api_version => 3,
				    start_h => [ \&start, "self, tagname, attr" ],
				    text_h => [ \&text, "self, dtext" ],
				    end_h   => [ \&end, "self, tagname" ],
				    comment_h => [""]
				    );

    $parser->{ref_allowed_tags} = $ref_allowed_tags;
#    $parser->ignore_elements( qw(object script style) );
    $parser->parse($text);
    $parser->eof();
    return $parser->{text};
} # sub parse_html

# Event handlers for HTML parser
sub start {
    my ($parser, $tag, $attr) = @_;
    map {
	if ($tag eq $_) {
	    my $at = join " ",  map { $_ . '="' . $attr->{$_} . '"' } keys %$attr;
	    $parser->{text} .= "<$tag $at>";
	    return;
	}
    } @{$parser->{ref_allowed_tags}};
} # sub start
    
sub text {
    my ($parser, $text) = @_;
    $parser->{text} .= $text;
} # sub text
    
sub end {
    my ($parser, $tag) = @_;
    map {
	if ($tag eq $_) {
	    $parser->{text} .= "</$tag>";
	    return;
	}
    } @{$parser->{ref_allowed_tags}};
} # sub end
