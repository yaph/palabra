# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind.
# See the file LICENSE for redistribution terms.
package Palabra;
use strict;
use CGI;
use DBI;

use vars qw($VERSION);
$VERSION = '1.20';

my $q = CGI->new();

################ Configuration START ###################
my $host_name = "localhost";#"mysql.sourceforge.net";
my $db_name = "palabra";
my $db_user = "palabra";
my $db_pass = "palabra";
my $dsn = "DBI:mysql:host=$host_name;database=$db_name";
################ Configuration END #####################

############### Constructor START ######################
my %palabra_defaults = (
			author => 'Ramiro Gómez',
			css => '/style/palabra.css',
			title => 'Palabra',
			lang => 'en_US',
			word => ''
			);

sub new {
    my $class = shift;
    my %args = (%palabra_defaults, @_);
    my $self = { %args };
    return bless $self, $class;
} # sub new
############### Construtcor END ########################

################ Subroutines START #####################
# Connect to MySQL server
sub db_connect {
    my $self = shift;
    return( DBI->connect( $dsn, $db_user, $db_pass, { PrintError => 0, RaiseError => 1 } ) );
} # sub db_connect

# Print standard HTML-header
sub html_header {
    my $self = shift;
    my $script = $self->{script};

    # links in navbar
    my $edit_url = sprintf( "edit_word.cgi?word_id=%d;word=%s;lang=%s",
				$self->{word_id}, $q->escape($self->{word}), $q->escape($self->{lang}) );
    my $edit_link =  '[' . $q->a( { -href => $edit_url }, 'Edit description' ) . ']';

    my $tr_url = sprintf( "translate.cgi?word_id=%d;word=%s;lang=%s",
			  $self->{word_id}, $q->escape($self->{word}), $q->escape($self->{lang}) );
    my $tr_link = '[' . $q->a( { -href => $tr_url }, 'Translations' ) . ']';

    # determine which link not to show in navbar
    if ($script eq 'edit_word.cgi') {
	$edit_link = 'Edit description';

    } elsif ($script eq 'translate.cgi') {
	$tr_link = 'Translations';
    }

    # always show this links
    my $index_url = sprintf( "show_index.cgi?lang=%s", $q->escape($self->{lang}) );
    my $index_link = '[' . $q->a( { -href => $index_url }, 'Show index' ) . ']';
    
    # link to home page
    my $home_url = sprintf( "index.cgi?lang=%s", $q->escape($self->{lang}) );
    my $home_link = $q->a( { -href => $home_url }, 'Palabra' );

    return $q->header(), $q->start_html(
					-title => $self->{title},
					-meta => { copyright => "copyright 2003 $self->{author}" },
					-style => { src => $self->{css} }
				       ),
    $q->table( { -width => '100%', -class => 'navbar' },
	       $q->Tr(
		      $q->td( { -class => 'left' }, 
			      $home_link, ' : ',  $self->{word},
			      $q->br(), $edit_link, $index_link, $tr_link
			      ),
		      $q->td( { -class => 'right' }, $self->display_look_up_form($self->{lang}) )
		      )
	       );
} # sub html_header

# Print standard HTML-footer
sub html_footer {
    my $self = shift;
    my $contact_url = sprintf( "contact.cgi?lang=%s", $q->escape($self->{lang}) );

    return $q->div( { -class => 'centersmall' },
		    '[', $q->a( { -href => $contact_url }, 'Contact' ), ']',
		    '[', $q->a( { -href => 'https://sourceforge.net/cvs/?group_id=83614' }, 'CVS' ), ']',
		    '[', $q->a( { -href => 'http://www.ramiro.org/palabra/README.html' }, 'Docs' ), ']',
		    '[', $q->a( { -href => 'http://www.ramiro.org/download/palabra.tgz' }, 'Download' ), ']',
		    '[', $q->a( { -href => 'https://sourceforge.net/projects/palabra/' }, 'Project info' ), ']',
		    $q->br(), '&copy; Copyright 2003 ' . $self->{author} . '. All rights reserved!'
		    ),
			# sf.net logo
			$q->a( { -href => 'http://sourceforge.net' },
			       $q->img( { -src => 'http://sourceforge.net/sflogo.php?group_id=83614&amp;type=1',
					  -width => 88,
					  -height => 31,
					  -alt => 'SourceForge.net Logo'
					  }
					)
			       ),
			       $q->end_html();
} # html_footer

sub display_look_up_form {
    my $self = shift;
    
    my $dbh = $self->db_connect();
    my $ref_lang = $self->get_languages($dbh);
    $dbh->disconnect();

    return $q->start_form( -action => 'look_up.cgi', -method => 'GET' ),
    $q->popup_menu(
		   -name => 'lang',
		   -values => [ sort keys %{$ref_lang} ],
		   -labels => $ref_lang,
		   -default => $self->{lang}
		   ),
		   $q->textfield(
				 -name => 'word',
				 -override => 1,
				 -size => 20,
				 -maxlength => 80
				 ),
				 $q->submit( -value => 'Look up' ),
				 $q->end_form();
} # sub display_look_up_form


sub display_edit_form {
    my $self = shift;
    my %args = @_;
    my $word_id = $args{word_id};
    my $word = $args{word};
    my $lang = $args{lang};
    my $description = $args{description};

    # get allowed tags
    my $dbh = $self->db_connect();
    my $ref_allowed_tags = $self->get_allowed_tags($dbh);
    $dbh->disconnect;

    my $info =<<EOF;
Please use <a href="http://www.phon.ucl.ac.uk/home/wells/ipa-unicode.htm">HTML-entities</a> 
for IPA characters in phonetic transcriptions. You may use the following HTML tags in descriptions of meaning:
EOF
    
    $info .= join ", ", map { '&lt;' . $_ . '&gt;' } @{$ref_allowed_tags};
    $info .= ' - ' . $q->a ( { -href => "http://www.w3.org/TR/html401/index/elements.html" }, 'See Index of Elements' );
  
    return $q->h4('Edit description:' ),
    $q->start_form( -action => 'store_desc.cgi' ),
    $q->hidden( -name => 'word_id', -value => $word_id ),
    $q->hidden( -name => 'word', -value => $word ),
    $q->hidden( -name => 'lang', -value => $lang ),
    $q->p( { -class => 'small' }, $info ),
    $q->p ( $q->textarea(
			 -name => 'description',
			 -rows => 16,
			 -columns => 120,
			 -value => $description
			 )
	    ),
	$q->p( $q->submit( -value => 'Store description' ) ),
	$q->end_form();
} # sub display_edit_form

# gets db-handle and returns a reference to an array of allowed tags
sub get_allowed_tags {
    my $self = shift;
    my $dbh = shift;
    my $stmt = "SELECT tag FROM allowed_tags";
    return $dbh->selectcol_arrayref( $stmt, { Columns=>[1] } );
} # get_allowed_tags

sub get_languages { 
    my $self = shift;
    my $dbh = shift;
    my %lang;
    my $stmt = "SELECT lang_code, lang_name FROM languages";
    my $sth = $dbh->prepare($stmt);
    $sth->execute();
    
    while ( my $row = $sth->fetchrow_hashref() ) {
	$lang{$row->{lang_code}} = $row->{lang_name};
    }
    $sth->finish();
    return \%lang;
} # sub get_languages

# Trim leading and trailing whitespace from string.
# Convert undef to the empty string and thus suppress warnings for undefined.
sub trim_ws {
    my $self = shift;
    my $string = shift;
    return "" if !defined $string;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
} # sub trim_ws
################ Subroutines END #####################

1; # return true
