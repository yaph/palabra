# Copyright 2003 Ramiro Gómez.
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
my $UI_file_dir = '/var/www/palabra/UI/'; #/home/groups/p/pa/palabra/lib
################ Configuration END #####################

############### Constructor START ######################
my %palabra_defaults = (
			css => '/style/palabra.css',
			title => 'Palabra',
			lang => 'en_US',
			word => '',
			script => '',
			JavaScript => '',
			nav_links => 0,
			);

sub new {
    my $class = shift;
    my %args = (%palabra_defaults, @_);
    my $self = bless { %args }, $class;
    $self->set_UI;
    $self->{dbh} = $self->db_connect;
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

# Connect to MySQL server
sub db_connect {
    my $self = shift;
    return( DBI->connect( $dsn, $db_user, $db_pass, { PrintError => 0, RaiseError => 1 } ) );
}

# accessor methods
# return database handle
sub get_db_handle {
    return (shift)->{dbh};
}

# return UI strinsg as a hashref
sub get_UI {
    return (shift)->{UI};
}

sub get_lang { 
    return (shift)->{lang};
}

sub get_css {
    return (shift)->{css};
}

sub get_HTML_title {
    return (shift)->{title};
}

sub set_HTML_title {
    my $self = shift;
    my $title = shift;
    $self->{title} = $title;
    return $title;
}

sub set_nav_links {
    (shift)->{nav_links} = 1;
}

sub set_word_id {
    my $self = shift;
    my $word_id = shift;
    $self->{word_id} = $word_id;
    return $word_id;
}

sub set_JavaScript {
    my $self = shift;
    my $script = shift;
    $self->{JavaScript} = $script;
    return $script;
}

# returns HTML page
sub html_page {
    my $self = shift;
    my $html_page = shift;
    my $script = $self->{script} || '';
    my $UI = $self->get_UI;
    my $home_url = sprintf( "index.cgi?lang=%s", $q->escape($self->{lang}) );
    my $home_link = $q->a( { -href => $home_url }, 'Palabra' );
    my $dbh = $self->get_db_handle;
    my $word = $self->{word};
    my $lang = $self->{lang};

    # HTML page
    my $HTML = $q->header;
    $HTML .= $q->start_html(
			    -title => $self->{title},
			    -style => { src => $self->{css} },
			    -script => $self->{JavaScript}
			    );
    $HTML .= $q->table( { -width => '100%', -class => 'navbar' },
			$q->Tr(
			       $q->td( { -class => 'left' }, $home_link, ' : ',  $word ),
			       $q->td( { -class => 'right' }, $self->display_look_up_form($lang) )
			       )
			);
    $HTML .= $q->start_table( { -width => '100%' } );
    
    my $translations = '';
    if ($self->{nav_links}) {
	my $word_id = $self->{word_id};
	# links in navbar
	my $edit_url = sprintf( "edit_word.cgi?word_id=%d;word=%s;lang=%s",
				$word_id, $q->escape($word), $q->escape($lang) );
	my $edit_link =  '[' . $q->a( { -href => $edit_url }, $UI->{edit_desc_l} ) . ']';
	my $tr_url = sprintf( "translate.cgi?word_id=%d;word=%s;lang=%s",
			      $word_id, $q->escape($word), $q->escape($lang) );
	my $tr_link = '[' . $q->a( { -href => $tr_url }, $UI->{trans_l} ) . ']';
	# determine which link not to show in navbar
	if ($script eq 'edit_word.cgi') {
	    $edit_link = $UI->{edit_desc_l};
	    
	} elsif ($script eq 'translate.cgi') {
	    $tr_link = $UI->{trans_l};
	}
     	my $index_url = sprintf( "show_index.cgi?lang=%s", $q->escape($lang) );
	my $index_link = '[' . $q->a( { -href => $index_url }, $UI->{show_index_l} ) . ']';
	$HTML .= $q->Tr( $q->td( { -colspan => 2, -class => 'left' }, $edit_link, $index_link, $tr_link) );

	$translations .= $q->h4($UI->{trans_msg});
	$translations .= $q->div( { -class => 'small' },
				  $self->get_translations( dbh => $dbh,
							   word_id => $word_id,
							   lang => $lang )
				  );
	}
    
    $HTML .= $q->Tr( $q->td( { -width => '70%' }, $html_page ),
		     $q->td( { -width => '5%' }, ''),
		     $q->td( { -width => '25%' }, $translations ) );
    $HTML .= $q->end_table . $self->html_footer;
    return $HTML;
} # html_page

# Print standard HTML-footer
sub html_footer {
    my $self = shift;
    my $dbh = $self->get_db_handle;
    my $UI = $self->get_UI;
    my $contact_url = sprintf( "contact.cgi?lang=%s", $q->escape($self->{lang}) );
    
    my $HTML = $q->div( { -class => 'centersmall' },
			'[' . $q->a( { -href => $contact_url }, $UI->{contact_l} ) . ']' .
			'[' . $q->a( { -href => 'https://sourceforge.net/cvs/?group_id=83614' }, 'CVS' ). ']' .
			'[' . $q->a( { -href => 'http://www.ramiro.org/palabra/README.html' }, $UI->{doc_l} ) . ']' .
			'[' . $q->a( { -href => 'https://sourceforge.net/projects/palabra/' }, $UI->{project_info_l} ) . ']' .
			$q->br . '&copy; Copyright 2003-2004' . $q->a( { -href => "http://www.ramiro.org/" }, 'Ramiro Gómez') . '.'
			);
    # sf.net logo
    $HTML .= $q->a( { -href => 'http://sourceforge.net' },
		    $q->img( { -src => 'http://sourceforge.net/sflogo.php?group_id=83614&amp;type=1',
			       -width => 88,
			       -height => 31,
			       -alt => 'SourceForge.net Logo'
			       }
			     )
		    ) . $q->end_html;
    $dbh->disconnect;
    return $HTML;
} # html_footer

# returns look up form
sub display_look_up_form {
    my $self = shift;
    my $UI = $self->get_UI;
    my $dbh = $self->get_db_handle;
    my $ref_lang = $self->get_languages($dbh);

    my $HTML = $q->start_form( -action => 'look_up.cgi', -method => 'GET' );
    $HTML .= $q->popup_menu(
			    -name => 'lang',
			    -values => [ sort keys %{$ref_lang} ],
			    -labels => $ref_lang,
			    -default => $self->{lang}
			    );
    $HTML .= $q->textfield(
			   -name => 'word',
			   -override => 1,
			   -size => 20,
			   -maxlength => 80,
			   );
    $HTML .= $q->submit( -value => $UI->{look_up_b} );
    $HTML .= $q->end_form;
    return $HTML;
} # sub display_look_up_form

# returns edit form
sub display_edit_form {
    my $self = shift;
    my %args = @_;
    my $word_id = $args{word_id};
    my $word = $args{word};
    my $lang = $args{lang};
    my $description = $args{description};
    my $UI = $self->get_UI;

    # get allowed tags
    my $dbh = $self->get_db_handle;
    my $ref_allowed_tags = $self->get_allowed_tags;
    my $info = $UI->{edit_desc_msg} . $q->br;
    
    $info .= join ", ", map {
	if ($_ eq 'a') {
	    my $url = sprintf( "look_up.cgi?lang=%s;word=%s", $q->escape($lang), '' );
	    my $a_href = qq{href="$url"};
	    '&lt;' . $q->a( { -href => "#add_tag",
			      -onClick => "add_tag('<$_ $a_href></$_>')" }, $_ ) . '&gt;';
	} else {
	    '&lt;' .  $q->a( { -href => "#add_tag",
			       -onClick => "add_tag('<$_></$_>')" }, $_ ) . '&gt;';
	}
    } @{$ref_allowed_tags};
    my $HTML = $q->start_form( -action => 'store_desc.cgi',
			       -name => 'edit_desc',
			       );
    $HTML .= $q->hidden( -name => 'word_id', -value => $word_id );
    $HTML .= $q->hidden( -name => 'word', -value => $word );
    $HTML .= $q->hidden( -name => 'lang', -value => $lang );
    $HTML .= $q->p( { -class => 'small' }, $info );
    $HTML .= $q->textarea(
			  -name => 'description',
			  -rows => 15,
			  -columns => 90,
			  -value => $description
			  );
    $HTML .= $q->p( $q->submit(-value => $UI->{store_desc_b}));
    $HTML .= $q->end_form;
    return $HTML;
} # sub display_edit_form

# returns a reference to an array of allowed tags
sub get_allowed_tags {
    my $self = shift;
    my $dbh = $self->get_db_handle;
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

# get HTML list of translations
sub get_translations { 
    my $self = shift;
    my %args = @_;
    my $dbh = $args{'dbh'};
    my $word_id = $args{'word_id'};
    my $lang = $args{'lang'};
    my $tr_table= $lang . '_trans';
    my $UI = $self->get_UI;
    my $ref_lang = $self->get_languages($dbh);

    $word_id = $dbh->quote($word_id);
    my $stmt = "SELECT trans, lang FROM $tr_table WHERE word_id = $word_id ORDER BY lang, trans";
    my $sth = $dbh->prepare($stmt);
    $sth->execute();

    my $HTML = '';
    while ( my $ref = $sth->fetchrow_hashref() ) {
	my $trans = $ref->{trans};
	my $lang = $ref->{lang};
	my $lang_name = $ref_lang->{$lang};
	my $url = sprintf( "look_up.cgi?word=%s&lang=%s", $q->escape( $trans ), $lang  ); 
	$HTML .= $lang_name .': ' . $q->a( { -href => $url }, $trans ) . $q->br;
    }
    $sth->finish;
    
    unless ($HTML) {
	$HTML .= $UI->{no_trans_msg};
    }
    return $HTML;
} # sub get_translations

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
