#!/usr/bin/perl -w
use XML::Parser;
use URI::Escape;
use lib qw(/srv/www/lib/perl /home/groups/p/pa/palabra/lib);
use Palabra;
use constant MAX_COUNT => 3000;

die "Usage $0 xmlfile\n" unless @ARGV;
my $xml_source = shift;
my $count = 0;
my $lang = 'en_US';
my $jargon = {};
my $p = Palabra->new;
my $parser = XML::Parser->new;
$parser->setHandlers(
		     Start => \&start_h,
		     End   => \&end_h,
		     Char  => \&char_h
		     );
$parser->parsefile( $xml_source );

my $dbh = $p->db_connect;
map {
    my $word = $p->trim_ws($jargon->{$_}{'term'});
    my $desc .= "<h2>$word</h2>";
    defined($jargon->{$_}{'ipa'}) &&
	($desc .= '<p style="font-family:monospace;">' . $jargon->{$_}{'ipa'} . '</p>');
    defined($jargon->{$_}{'def'}) &&
	($desc .= "<pre>" . $jargon->{$_}{'def'} . "</pre>");
    $dbh->do("INSERT IGNORE INTO $lang (word,description) VALUES(?,?)", undef, $word, $desc);
} sort keys %$jargon;
$dbh->disconnect;

sub start_h {
    my ($expat, $element, %attr) = @_;
    if ($element eq "glossentry") {
	$expat->finish if ++$count > MAX_COUNT;
	$jargon->{'curr_entry'} = $attr{'id'};
    } elsif ($element eq "emphasis") {
	$jargon->{'curr_attr'} = $attr{'role'};
    }
}

sub char_h {
    my ($expat, $text) = @_;
    if ($expat->within_element('glossentry')) {
	my $entry = $jargon->{'curr_entry'};
	if ($expat->within_element('glossterm') && !defined($jargon->{$entry}{'term'})) {
	    $jargon->{$entry}{'term'} = $text;
	} elsif ($expat->within_element('glossterm') && defined($jargon->{$entry}{'term'})) {
	    $text = $p->trim_ws($text);
	    $jargon->{$entry}{'def'} .= '<a href="' . 
		sprintf( "look_up.cgi?lang=%s;word=%s", uri_escape($lang), uri_escape($text) ) . '">' . $text . '</a>';
	} elsif ($expat->within_element('emphasis')) {
	    if (defined($jargon->{'curr_attr'}) &&
		$jargon->{'curr_attr'} eq 'pronunciation') {
		$jargon->{$entry}{'ipa'} = $text;
	    }
	} elsif ($expat->within_element('glossdef')) {
	    $jargon->{$entry}{'def'} .= $text;
	}
    }
}

sub end_h {
    my ($expat, $element) = @_;
    if ($element eq "glossentry") {
	$jargon->{'curr_entry'} = undef;
    } elsif ($element eq "emphasis") {
	$jargon->{'curr_attr'} = undef;
    }
}
