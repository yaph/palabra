# Copyright 2003 - 2005 Ramiro Gómez.
# This program is offered without warranty of any kind.
# See the file LICENSE for redistribution terms.
package Palabra;
use strict;
use CGI;
use lib qw(/srv/www/lib/perl);
use Database qw(db_connect);

use vars qw($VERSION);
$VERSION = '0.8';

my $q = CGI->new;

################ Configuration START ###################
my $UI_file_dir = '/srv/www/palabra/UI/';
my $JavaScript = '/js/js-lib.js';
my $css = '/style/palabra.css';
################ Configuration END #####################

my %defaults = (
		title => 'Palabra',
		lang => 'en_US',
		word => '',
		script => '',
		nav_links => 0,
		table_prefix => 'palabra_'
		);

sub new {
    my $class = shift;
    my %args = (%defaults, @_);
    my $self = bless { %args }, $class;
    $self->check_input;
    $self->set_UI;
    $self->{dbh} = db_connect;
    return $self;
}

sub check_input {
    my $self = shift;
    while (my ($name, $input) = each %$self) {
	if ( $input ) {
	    $input = $self->trim_ws($input);
	    $self->{$name} = $input;
	    if ( $name eq 'word' && $input eq '' ) {
		$self->error;
	    } elsif ( $name eq 'lang' && $input !~ m/^\w\w_\w\w$/ ) {
		$self->error;
	    } elsif ( $name eq 'word_id' && $input !~ m/^\d+$/ ) {
		$self->error;
	    } elsif ( $name eq 'tr_lang' && $input !~ m/^\w\w_\w\w$/ ) {
		$self->error;
	    }
	}
    }
}

# set UI strings according to chosen language
sub set_UI {
    my $self = shift;
    my $UI_file = $UI_file_dir . $self->{lang};
    open UI, $UI_file or $self->error;
    while (<UI>) {
	chomp;
	next if /^\s*#/;
	next if /^\s+$/;
	my ($UI_entry, $UI_string) = split /=/, $_, 2;
	$UI_entry = $self->trim_ws($UI_entry);
	$UI_string = $self->trim_ws($UI_string);
	$self->{UI}->{$UI_entry} = $UI_string;
    }
    close UI or $self->error;
} # sub set_UI

# return database handle
sub get_db_handle {
    return (shift)->{dbh};
}

# return UI strings as a hashref
sub get_UI {
    return (shift)->{UI};
}

sub get_lang { 
    return (shift)->{lang};
}

sub get_HTML_title {
    return (shift)->{title};
}

sub get_table_prefix {
    return (shift)->{table_prefix};
}

sub set_HTML_title {
    my $self = shift;
    my $title = shift;
    $self->{title} = $title;
    return $title;
}

sub set_word {
    my $self = shift;
    my $word = shift;
    $self->{word} = $word;
    return $word;
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
    my $word_id = $self->{word_id};
    my $contact_url = sprintf( "contact.cgi?lang=%s", $q->escape($lang) );

    my ($edit_link, $tr_link);
    if ($self->{nav_links}) {
	# links
	my $edit_url = sprintf( "edit_word.cgi?word_id=%d;word=%s;lang=%s",
				$word_id, $q->escape($word), $q->escape($lang) );
	$edit_link =  $q->a( { -href => $edit_url,
			       -title => $UI->{edit_desc_l}, }, 
			     $q->img( { src => "/pics/edit.png",
					alt => $UI->{edit_desc_l},
					style => "margin-left:5px" } ) );
	my $tr_url = sprintf( "translate.cgi?word_id=%d;word=%s;lang=%s",
			      $word_id, $q->escape($word), $q->escape($lang) );
	$tr_link = $q->a( { -href => $tr_url,
			    -title => $UI->{trans_l} },
			  $q->img( { src => "/pics/translate.png",
				     alt => $UI->{trans_l},
				     style => "margin-left:5px" } ) );
	# determine which link not to show
	if ($script eq 'edit_word.cgi') {
	    $edit_link = $UI->{edit_desc_l};
	    
	} elsif ($script eq 'translate.cgi') {
	    $tr_link = $UI->{trans_l};
	}
    }
    
    # HTML page
    my $box_body;
    my $HTML = $q->header;
    $HTML .= $q->start_html(
			    -title => $self->{title},
			    -style => { src => $css },
			    -script => { src => $JavaScript }
			    );
    $HTML .= $q->div( { -id => 'top_bar' }, $home_link );
    $HTML .= $q->start_table( { -id => 'main_table',
				-summary => 'main layout table' } );
    $HTML .= $q->start_Tr;
    $HTML .= $q->start_td( { -id => 'left_column' } );

    $HTML .= $self->display_box( header => $UI->{look_up_b},
				 body => $self->display_look_up_form );

    $HTML .= $self->display_box( header => $UI->{project_h},
				 body => $q->a( { -href => 'https://sourceforge.net/cvs/?group_id=83614' },
						'CVS' ) . $q->br .
				 $q->a( { -href => $contact_url },
						$UI->{contact_l} ) . $q->br .
				 $q->a( { -href => '/palabra/README.html' }, 
					$UI->{doc_l} ) . $q->br .
				 $q->a( { -href => 'https://sourceforge.net/projects/palabra/' },
					$UI->{project_info_l} )
				 );
    $HTML .= $q->end_td;

    $HTML .= $q->start_td( { -id => 'center_column' } );
    $HTML .= $q->span( { class => "tab" }, $self->{title} );

    if ($self->{nav_links}) {
	$HTML .= $edit_link . $tr_link;
	$HTML .= $q->img( { src => "/pics/printer.png",
			    alt => "printer icon",
			    style => "margin-left:5px" } );
    }

    $HTML .= $q->div( { -id => 'main_content' }, $html_page );
    $HTML .= $q->end_td;

    $HTML .= $q->start_td( { -id => 'right_column' } );

    if ($self->{nav_links}) {
	my @trans = $self->get_translations( dbh => $dbh,
					     word_id => $word_id,
					     lang => $lang );
	if (@trans) {
	    $box_body = join $q->br, @trans;
	    $HTML .= $self->display_box( header => $UI->{trans_msg},
					 body => $box_body );
	}
    }
    
    my @last_edited = $self->get_last_edited( dbh => $dbh,
					      lang => $lang );
    if (@last_edited) {
	$box_body = join $q->br, @last_edited;
	$HTML .= $self->display_box( header => $UI->{recent_h},
				     body => $box_body );
    }
    $HTML .= $q->end_td;
    $HTML .= $q->end_Tr;
    $HTML .= $q->end_table;
    
    $HTML .= $q->div( { id => 'copyright' },
		      '&copy; Copyright 2003-2004 ' .
		      $q->a( { -href => "http://www.ramiro.org/" }, 'Ramiro Gómez') . '. ' . $q->br . 
		      'All rights reserved.'
		      );
    $HTML .= $q->end_html;
    return $HTML;
} # html_page

# returns error message
sub error {
    my $self = shift;
    my $UI = $self->get_UI;
    print $self->html_page( $q->h1($UI->{error_h}) . 
			    $q->p($UI->{error_msg}) .
			    $q->a( { -href => 'javascript:history.back()' }, 
				   $UI->{error_back_l} ) 
			    );
    exit 1;
}

# returns look up form
sub display_look_up_form {
    my $self = shift;
    my $UI = $self->get_UI;
    my $dbh = $self->get_db_handle;
    my $ref_lang = $self->get_languages($dbh);

    my $HTML = $q->start_form( -action => 'look_up.cgi',
			       -method => 'GET' );
    $HTML .= $q->popup_menu(
			    -name => 'lang',
			    -values => [ sort keys %{$ref_lang} ],
			    -labels => $ref_lang,
			    -style => 'width:100px;',
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
	    my $url = sprintf( "look_up.cgi?lang=%s;word=%s", $q->escape($lang), '######' );
	    my $a_href = qq{href="$url"};
	    '&lt;' . $q->a( { -href => "javascript:insert_tags('<$_ $a_href>', '</$_>', '######');" }, $_ ) . '&gt;';
	} else {
	    '&lt;' . $q->a( { -href => "javascript:insert_tags('<$_>', '</$_>', '######');" }, $_ ) . '&gt;';
	}
    } @{$ref_allowed_tags};
    my $HTML = $q->start_form( -action => 'store_desc.cgi',
			       -name => 'edit_desc',
			       );
    $HTML .= $q->hidden( -name => 'word_id', -value => $word_id );
    $HTML .= $q->hidden( -name => 'word', -value => $word );
    $HTML .= $q->hidden( -name => 'lang', -value => $lang );
    $HTML .= $q->p($info );
    $HTML .= $q->textarea(
			  -name => 'description',
			  -rows => 23,
			  -columns => 80,
			  -value => $description
			  );
    $HTML .= $q->p( $q->submit(-value => $UI->{store_desc_b}));
    $HTML .= $q->end_form;
    return $HTML;
} # sub display_edit_form

# return box for left or right column
sub display_box {
    my $self = shift;
    my %args = @_;
    my $header = $args{'header'};
    my $body = $args{'body'};

    my $HTML = $q->table( { summary => "box header",
			    class => "box_header",
			    width => "100%" },
			  $q->Tr(
				 $q->td( { class => "box_header_left" },
					 $header ),
#				 $q->td( { class => "box_header_right" },
#					 $q->a( { href => "javascript:toggle(\"$header\");" },
#						$q->img( { src => "/pics/uparrow.png",
#							   alt => "toggle menu",
#							   onclick => "javascript:flip_arrow(this);" } )
#						)
#					 )
				 )
			  );
    $HTML .= $q->div( { class => 'box',
			id => $header,
			style => "display:block;" },
		      $body );
    return $HTML;
}


# returns a reference to an array of allowed tags
sub get_allowed_tags {
    my $self = shift;
    my $dbh = $self->get_db_handle;
    my $table = $self->get_table_prefix . 'allowed_tags';
    my $stmt = "SELECT tag FROM $table";
    return $dbh->selectcol_arrayref( $stmt, { Columns=>[1] } );
}

sub get_languages { 
    my $self = shift;
    my $dbh = shift;
    my %lang;
    my $table = $self->get_table_prefix . 'languages';
    my $stmt = "SELECT lang_code, lang_name FROM $table";
    my $sth = $dbh->prepare($stmt);
    $sth->execute;
    while ( my $row = $sth->fetchrow_hashref ) {
	$lang{$row->{lang_code}} = $row->{lang_name};
    }
    $sth->finish;
    return \%lang;
} # sub get_languages

# get link list of translations
sub get_translations { 
    my $self = shift;
    my %args = @_;
    my $dbh = $args{'dbh'};
    my $word_id = $args{'word_id'};
    my $lang = $args{'lang'};
    my $tr_table= $self->get_table_prefix . $lang . '_trans';
    my $UI = $self->get_UI;
    my $ref_lang = $self->get_languages($dbh);

    $word_id = $dbh->quote($word_id);
    my $stmt = "SELECT trans, lang FROM $tr_table WHERE word_id = $word_id ORDER BY lang, trans";
    my $sth = $dbh->prepare($stmt);
    $sth->execute();

    my @HTML;
    while ( my $ref = $sth->fetchrow_hashref() ) {
	my $trans = $ref->{trans};
	my $lang = $ref->{lang};
	my $lang_name = $ref_lang->{$lang};
	my $url = sprintf( "look_up.cgi?word=%s&lang=%s", $q->escape( $trans ), $lang  ); 
	push @HTML, $lang_name .': ' . $q->a( { -href => $url }, $trans );
    }
    $sth->finish;
    
    unless (@HTML) {
	return;
    }

    return @HTML;
} # sub get_translations

# get link list of last edited words
sub get_last_edited { 
    my $self = shift;
    my %args = @_;
    my $dbh = $args{'dbh'};
    my $lang = $args{'lang'};
    my $table = $self->get_table_prefix . $lang;
    my $UI = $self->get_UI;
    my $stmt = "SELECT word_id, word, description FROM $table WHERE description NOT LIKE '' ORDER BY t DESC LIMIT 5";
    my $sth = $dbh->prepare($stmt);
    $sth->execute();

    my @HTML;
    while ( my $ref = $sth->fetchrow_hashref() ) {
	my $word = $ref->{word};
	my $url = sprintf("look_up.cgi?word_id=%d;word=%s;lang=%s", 
			  $q->escape($ref->{word_id}), $q->escape($word), $q->escape($lang));
	push @HTML, $q->a( { -href => $url }, $word );
    }
    $sth->finish;
    
    unless (@HTML) {
	return;
    }

    return @HTML;
} # sub get_last_edited

# Add a new word to language table. Returns word_id
sub add_word {
    my $self = shift;
    my %args = @_;
    my $dbh = $args{'dbh'};
    my $word = $args{'word'};
    my $lang = $args{'lang'};
    my $table = $self->get_table_prefix . $lang;
    # Check if word exists, if not create new entry.
    my $stmt = "SELECT * FROM $table WHERE word = ?";
    my $sth = $dbh->prepare($stmt);
    $sth->execute($word);
    my $ref = $sth->fetchrow_hashref;
    $sth->finish;

    # create new entry for word in corresponding language table
    unless ($ref) {
	$dbh->do("INSERT INTO $table (word) VALUES(?)", undef, $word);
    
	# get info for display
	$stmt = "SELECT * FROM $table WHERE word_id = LAST_INSERT_ID()";
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

1; # return true
