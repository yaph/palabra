#!/usr/bin/perl -wT
# Copyright 2003 Ramiro G�mez. All rights reserved!
# This program is offered without warranty of any kind. See the file LICENSE for redistribution terms.
use strict;
use lib qw(/srv/www/lib/perl /home/groups/p/pa/palabra/lib);
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

my $p = Palabra->new( word => $word,
		      title => $word, 
		      lang => $lang );

$description = $p->trim_ws($description);
my $dbh = $p->get_db_handle;
my $table = $p->get_table_prefix . $lang;

# check description using HTML::Parser
$description = parse_html($description, $dbh);

# update information for word
$dbh->do("UPDATE $table SET t = NOW(), description = ? WHERE word_id = ? AND word = ?", undef, $description, $word_id, $word );

my $url = sprintf( "look_up.cgi?word_id=%d&lang=%s&word=%s", $word_id, $lang, $q->escape( $word ) ); 

# redirect to word
print $q->redirect( $url );

# parse descriptions
sub parse_html {
    my $text = shift;
    my $ref_allowed_tags = $p->get_allowed_tags;
    
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
	    if ($tag eq 'a' && defined($attr->{href}) && $attr->{href} !~ /^look_up\.cgi/) {
		$attr->{href} = '';
	    }
	    my $at = join " ",  map { $_ . '="' . $attr->{$_} . '"' } keys %$attr;
	    if ($at) {
		$parser->{text} .= "<$tag $at>";
	    } else {
		$parser->{text} .= "<$tag>";
	    }
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
