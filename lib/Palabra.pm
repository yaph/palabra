# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind. See the file LICENSE for redistribution terms.
package Palabra;
use strict;
use CGI;
use DBI;

use vars qw($VERSION);
$VERSION = '1.17';

my $q = CGI->new();

################ Configuration START ###################
my $host_name = "localhost";
my $db_name = "palabra";
my $db_user = "palabra";
my $db_pass = "pass";
my $dsn = "DBI:mysql:host=$host_name;database=$db_name";
################ Configuration END #####################

############### Constructor START ######################
my %palabra_defaults = (
			home => 'palabra',
			home_url => 'index.cgi',
			author => 'Ramiro Gómez',
			css => '/style/palabra.css',
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
    $self->{edit_url} = sprintf( "edit_word.cgi?id=%d;word=%s;lang=%s", $self->{id}, $q->escape($self->{word}), $q->escape($self->{lang}) );
    $self->{index_url} = sprintf( "show_index.cgi?lang=%s", $q->escape($self->{lang}) );
    $self->{home_url} = sprintf( "index.cgi?lang=%s", $q->escape($self->{lang}) );
    my $title = $self->{home} . ' : '. $self->{word};
    return $q->header(), $q->start_html(
					-title => $title,
					-meta => { copyright => "copyright 2003 $self->{author}" },
					-style => { src => $self->{css} }
				       ),
    $q->table( { -width => '100%', -class => 'top_bar' },
	       $q->Tr(
		      $q->td( { 
			  -class => 'left' }, $q->a( { -href => $self->{home_url} }, $self->{home} ), ' : ',  $self->{word},
			      $q->br(),
			      $q->span( { class => 'bottomsmall' },
					'[' . $q->a( { -href => $self->{edit_url} }, 'Edit description' ) . ']',
					'[' . $q->a( { -href => $self->{index_url} }, 'Show index' ) . ']',
				#	$q->a( { -href => $self->{home_url} }, 'translations' ),
				#	$q->a( { -href => $self->{home_url} }, 'synonyms' )
					)
			      ),
		      $q->td( { -class => 'right' }, $self->display_look_up_form($self->{lang}) )
		      )
	       );
} # sub html_header

# Print standard HTML-footer
sub html_footer {
    my $self = shift;
    $self->{about_url} = sprintf( "about.cgi?lang=%s", $q->escape($self->{lang}) );
    $self->{contact_url} = sprintf( "contact.cgi?lang=%s", $q->escape($self->{lang}) );

    return $q->hr(), $q->div( { -class => 'centersmall' },
			      '[', $q->a( { -href => $self->{about_url} }, 'about' ), ']',
			      '[', $q->a( { -href => $self->{contact_url} }, 'contact' ), ']',
			      '[', $q->a( { -href => 'https://sourceforge.net/cvs/?group_id=83614' }, 'cvs' ), ']',
			      '[', $q->a( { -href => 'https://sourceforge.net/projects/palabra/' }, 'project info' ), ']', $q->br(),
			      '&copy; Copyright 2003 ' . $self->{author} . '. All rights reserved!'
			      ),
				  # sf.net logo
				  $q->a( { -href => 'http://sourceforge.net' }, $q->img( { -src => 'http://sourceforge.net/sflogo.php?group_id=83614&amp;type=1',
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

    # get allowed tags
    my $dbh = $self->db_connect();
    my $ref_allowed_tags = $self->get_allowed_tags($dbh);
    $dbh->disconnect;

    my $info =<<EOF;
Please use <a href="http://www.scots-online.org/airticles/phonetics.htm">HTML-entities</a> for IPA characters in phonetic transcriptions. You may use the following HTML tags in descriptions of meaning:
EOF
    
    $info .= join ", ", map { '&lt;' . $_ . '&gt;' } @{$ref_allowed_tags};
    $info .= ' - ' . $q->a ( { -href => "http://www.w3.org/TR/html401/index/elements.html" }, 'See Index of Elements' );
  
    return $q->h4('Edit description:' ),
    $q->start_form( -action => 'store_desc.cgi' ),
    $q->hidden( -name => 'id', -value => $self->{id} ),
    $q->hidden( -name => 'word', -value => $self->{word} ),
    $q->hidden( -name => 'lang', -value => $self->{lang} ),
    $q->p( { -class => 'small' }, $info ),
    $q->p ( $q->textarea(
			 -name => 'description',
			 -rows => 16,
			 -columns => 120,
			 -value => $self->{description}
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
