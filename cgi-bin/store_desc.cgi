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

my $id = $q->param('id'); # id of word to edit
my $word = $q->param('word'); # set language
my $lang = $q->param('lang'); # set language
my $description = $q->param('description');

# check values
die "'$id' is not accepted" unless $id =~ m/^\d+$/;
die "'$lang' is not accepted" unless $lang =~ m/^\w\w_\w\w$/;

my $p = Palabra->new(word => $word, lang => $lang);

# connect to MySQL database
my $dbh = $p->db_connect();

# check description using HTML::Parser
$description = parse_html($description, $dbh);

# update information for word
$dbh->do("UPDATE $lang SET description = ? WHERE id = ? AND word = ?", undef, $description, $id, $word );
$dbh->disconnect();

# stuff info into Palabra Object
$p->{description} = $description;
$p->{id} = $id;

# print HTML page for word
print $p->html_header(),
    $p->{description},
    $p->html_footer();

# parse descriptions
sub parse_html {
    my $text = shift;
    my $dbh = shift;
    
    my $ref_allowed_tags = $p->get_allowed_tags($dbh);
    
    use HTML::Parser;
    my $parser = HTML::Parser->new( api_version => 3,
				    start_h => [ \&start, "self, tagname" ],
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
    my ($parser, $tag) = @_;
    map {
	if ($tag eq $_) {
	    $parser->{text} .= "<$tag>";
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
