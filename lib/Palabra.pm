# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind.
# See the file LICENSE for redistribution terms.
package Palabra;
use strict;
use CGI;
use DBI;

use vars qw($VERSION);
$VERSION = '1.3';

my $q = CGI->new;

################ Configuration START ###################
my $host_name = "localhost";#"mysql.sourceforge.net";
my $db_name = "palabra";
my $db_user = "palabra";
my $db_pass = "palabra";
my $dsn = "DBI:mysql:host=$host_name;database=$db_name";
my $UI_file_dir = '/var/www/palabra/UI/';
my $JS_dir = '/var/www/palabra/js/';
################ Configuration END #####################

############### Constructor START ######################
my %palabra_defaults = (
			css => '/style/palabra.css',
			title => 'Palabra',
			lang => 'en_US',
			word => '',
			script => ''
			);

sub new {
    my $class = shift;
    my %args = (%palabra_defaults, @_);
    my $self = bless { %args }, $class;
    $self->set_UI;
    return $self;
} # sub new
############### Construtcor END ########################

################ Subroutines START #####################

# set UI strings according to chosen language
sub set_UI {
    my $self = shift;
    my $UI_file = $UI_file_dir . $self->{lang};
    open UI, $UI_file or die "Can't open $UI_file: $!";
    while (<UI>) {
	chomp;
	next if /^\s*#/;
	next if /^\s+$/;
	my ($UI_entry, $UI_string) = split /=/, $_, 2;
	$UI_entry = $self->trim_ws($UI_entry);
	$UI_string = $self->trim_ws($UI_string);
	$self->{UI}->{$UI_entry} = $UI_string;
    }
    close UI or die "Can't close $UI_file: $!";
} # sub set_UI

sub set_HTML_title {
    my $self = shift;
    my $title = shift;
    $self->{title} = $title;
    return $title;
}

sub set_word_id {
    my $self = shift;
    my $word_id = shift;
    $self->{word_id} = $word_id;
    return $word_id;
}

# set JavaScript
sub set_script {
    my $self = shift;
    my $script = shift;
    $self->{script} = $script;
    return $script;
}

# Connect to MySQL server
sub db_connect {
    my $self = shift;
    return( DBI->connect( $dsn, $db_user, $db_pass, { PrintError => 0, RaiseError => 1 } ) );
}

# Print standard HTML-header
sub html_header {
    my $self = shift;
    my $script = $self->{script} || '';

    # links in navbar
    my $edit_url = sprintf( "edit_word.cgi?word_id=%d;word=%s;lang=%s",
				$self->{word_id}, $q->escape($self->{word}), $q->escape($self->{lang}) );
    my $edit_link =  '[' . $q->a( { -href => $edit_url }, $self->{UI}->{edit_desc_l} ) . ']';

    my $tr_url = sprintf( "translate.cgi?word_id=%d;word=%s;lang=%s",
			  $self->{word_id}, $q->escape($self->{word}), $q->escape($self->{lang}) );
    my $tr_link = '[' . $q->a( { -href => $tr_url }, $self->{UI}->{trans_l} ) . ']';

    # determine which link not to show in navbar
    if ($script eq 'edit_word.cgi') {
	$edit_link = $self->{UI}->{edit_desc_l};

    } elsif ($script eq 'translate.cgi') {
	$tr_link = $self->{UI}->{trans_l};
    }

    # always show this links
    my $index_url = sprintf( "show_index.cgi?lang=%s", $q->escape($self->{lang}) );
    my $index_link = '[' . $q->a( { -href => $index_url }, $self->{UI}->{show_index_l} ) . ']';
    
    # link to home page
    my $home_url = sprintf( "index.cgi?lang=%s", $q->escape($self->{lang}) );
    my $home_link = $q->a( { -href => $home_url }, 'Palabra' );

    return $q->header, $q->start_html(
				      -title => $self->{title},
				      -style => { src => $self->{css} },
				      -script => $self->{script}
				      ),
    $q->table( { -width => '100%', -class => 'navbar' },
	       $q->Tr(
		      $q->td( { -class => 'left' }, $home_link, ' : ',  $self->{word} ),
		      $q->td( { -class => 'right' }, $self->display_look_up_form($self->{lang}) )
		      )
	       ),
		   $q->p($edit_link, $index_link, $tr_link);
} # sub html_header

# Print standard HTML-footer
sub html_footer {
    my $self = shift;
    my $contact_url = sprintf( "contact.cgi?lang=%s", $q->escape($self->{lang}) );
    
    return $q->div( { -class => 'centersmall' },
		    '[', $q->a( { -href => $contact_url }, $self->{UI}->{contact_l} ), ']',
		    '[', $q->a( { -href => 'https://sourceforge.net/cvs/?group_id=83614' }, 'CVS' ), ']',
		    '[', $q->a( { -href => 'http://www.ramiro.org/palabra/README.html' }, $self->{UI}->{doc_l} ), ']',
		    '[', $q->a( { -href => 'https://sourceforge.net/projects/palabra/' }, $self->{UI}->{project_info_l} ), ']',
		    $q->br, '&copy; Copyright 2003-2004', $q->a( { -href => "http://www.ramiro.org/" }, 'Ramiro Gómez' ), '.'	   
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
			       $q->end_html;
} # html_footer

sub display_look_up_form {
    my $self = shift;
    
    my $dbh = $self->db_connect;
    my $ref_lang = $self->get_languages($dbh);
    $dbh->disconnect;

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
				 $q->submit( -value => $self->{UI}->{look_up_b} ),
				 $q->end_form;
} # sub display_look_up_form


sub display_edit_form {
    my $self = shift;
    my %args = @_;
    my $word_id = $args{word_id};
    my $word = $args{word};
    my $lang = $args{lang};
    my $description = $args{description};

    # get allowed tags
    my $dbh = $self->db_connect;
    my $ref_allowed_tags = $self->get_allowed_tags($dbh);
    $dbh->disconnect;
    my $info = $self->{UI}->{edit_desc_msg} . $q->br;
    $info .= join ", ", map { '&lt;' . $q->a( { -href => "#add_tag",
						-onClick => "add_tag('<$_></$_>')" }, $_ ) . '&gt;' } @{$ref_allowed_tags};
    return $q->start_form( -action => 'store_desc.cgi',
			   -name => 'edit_desc' ),
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
	$q->p( $q->submit( -value => $self->{UI}->{store_desc_b} ) ),
	$q->end_form;
} # sub display_edit_form

# gets db-handle and returns a reference to an array of allowed tags
sub get_allowed_tags {
    my $self = shift;
    my $dbh = shift;
    my $stmt = "SELECT tag FROM allowed_tags";
    return $dbh->selectcol_arrayref( $stmt, { Columns=>[1] } );
}

sub get_languages { 
    my $self = shift;
    my $dbh = shift;
    my %lang;
    my $stmt = "SELECT lang_code, lang_name FROM languages";
    my $sth = $dbh->prepare($stmt);
    $sth->execute;
    
    while ( my $row = $sth->fetchrow_hashref ) {
	$lang{$row->{lang_code}} = $row->{lang_name};
    }
    $sth->finish;
    return \%lang;
} # sub get_languages

sub get_lang { 
    return (shift)->{lang};
}

# Add a new word to language table. Returns word_id
sub add_word {
    my $self = shift;
    my %args = @_;
    my $dbh = $args{'dbh'};
    my $word = $args{'word'};
    my $lang = $args{'lang'};

    # Check if word exists, if not create new entry.
    my $stmt = "SELECT * FROM $ lang WHERE word = ?";
    my $sth = $dbh->prepare($stmt);
    $sth->execute($word);
    my $ref = $sth->fetchrow_hashref;
    $sth->finish;

    # create new entry for word in corresponding language table
    unless ($ref) {
	$dbh->do("INSERT INTO $lang (word) VALUES(?)", undef, $word);
    
	# get info for display
	$stmt = "SELECT * FROM $lang WHERE word_id = LAST_INSERT_ID()";
	$sth = $dbh->prepare($stmt);
	$sth->execute;
	$ref = $sth->fetchrow_hashref;
	$sth->finish;
    }
    return $ref->{word_id};
} # sub add_word

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
