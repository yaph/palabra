#!/usr/bin/perl -wT
# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind.
# See the file LICENSE for redistribution terms.
use strict;
use lib qw(/var/www/lib/perl /home/groups/p/pa/palabra/lib);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Net::SMTP;
use Palabra;

$CGI::POST_MAX=1024*100;
$CGI::DISABLE_UPLOADS = 1;

my $q = CGI->new;
my $lang = $q->param('lang');

# check value
print $q->redirect('index.cgi') unless $lang =~ m/^\w\w_\w\w$/;

# new Palabra object
my $p = Palabra->new( lang => $lang );
my $UI = $p->get_UI;
$p->set_HTML_title($UI->{contact_l});
$p->{word} = $UI->{contact_l};

my @errors;
my %formdata;

# main dispatch logic
if ( scalar( $q->param ) > 1 ) {
    check_form();
    if (@errors) {
	my $page = $q->ul( $q->li(\@errors) ) . display_mail_form();
	print $p->html_page($page);
    } else {
	send_mail();
	my $page = $q->p( $UI->{mail_sent_msg} );
	$page .= $q->ul( $q->li( $formdata{name} ),
			 $q->li( $formdata{email} ),
			 $q->li( $formdata{subject} ),
			 $q->li( $formdata{message} ) 
			 );
	print $p->html_page($page);
    }
} else {
    my $page = display_mail_form();
    print $p->html_page($page);
}

# subroutines
sub display_mail_form {
    my $HTML = $q->p( $UI->{mail_inst_msg} );
    $HTML .= $q->start_table( { width => '40%', cellpadding => '2%', style => 'table-layout:fixed' } );
    $HTML .= $q->start_form;
    $HTML .= $q->hidden( -name => 'lang', -value => $lang );
    $HTML .= $q->Tr( $q->td( $UI->{name_f}), 
		     $q->td( $q->textfield( { name => 'name',
					      size => 50,
					      maxlength => 100 }
					    )
			     )
		     );
    $HTML .= $q->Tr( $q->td($UI->{email_f}),
		     $q->td( $q->textfield( { name => 'email',
					      size => 50,
					      maxlength => 100 } 
					    )
			     )
		     );
    $HTML .= $q->Tr( $q->td($UI->{subject_f}),
		     $q->td( $q->textfield( { name => 'subject',
					      size => 50,
					      maxlength => 100 }
					    )
					    )
		     );
    $HTML .= $q->Tr( $q->td($UI->{msg_f}),
		     $q->td( $q->textarea( { name => 'message',
					     rows => 10,
					     columns => 50 }
					   )
			     )
		     );
    $HTML .= $q->Tr( $q->td, $q->td( $q->submit( -value => $UI->{send_mail_b} ), 
				     $q->reset( -value => $UI->{reset_b} ) ) 
		     );
    $HTML .= $q->end_form, $q->end_table;
    return $HTML;
} # display_mail_form

sub check_form {
    my $name = $q->param('name');
    $name = $p->trim_ws($name);
    if ( !$name ) {
	push @errors, $UI->{no_name_msg};
    } else {
	$formdata{name} = $name;
    }

    my $email = $q->param('email');
    if ( ($email !~ m/^([\w\.-]+\@[\w.-]+[\w]+)$/) || (length($email) < 6) ) {
	push @errors, $UI->{no_mail_msg};
    } else {
	$email = $1;
	$formdata{email} = $email;
    }
    
    my $subject = $q->param('subject');
    if ( $subject !~ m/^([\w.\s-]+)$/ ) {
	push @errors, $UI->{no_subject_msg};
    } else {
	$subject = $1;
	$formdata{subject} = $subject;
    }

    my $message = $q->param('message');
    if ( $message !~ m/^([\w\s\-\.,:!\?]+)$/ ) {
	push @errors, $UI->{no_message_msg};
    } else {
	$message = $1;
	$formdata{message} = $message;
    }
} # check_form

sub send_mail {
    my $smtp = Net::SMTP->new('localhost');
    $smtp->mail($formdata{email});
    $smtp->recipient( 'ramiro@rahoo.de', { SkipBad => 1 } );
    $smtp->data;
    $smtp->datasend("From: $formdata{name} <$formdata{email}>\n");
    $smtp->datasend("To: web\@ramiro.org\n");
    $smtp->datasend("Subject: $formdata{subject}\n");
    $smtp->datasend("\n");
    $smtp->datasend($formdata{message});
    my $success = $smtp->dataend;
    $smtp->quit;
    die "mail could not be sent" unless $success;
} # sub send_mail
