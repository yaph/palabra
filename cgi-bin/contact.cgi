#!/usr/bin/perl -wT
# Copyright 2003 Ramiro Gómez. All rights reserved!
# This program is offered without warranty of any kind. See the file LICENSE for redistribution terms.
use strict;
use lib qw(/var/www/lib/perl /home/groups/p/pa/palabra/lib);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Net::SMTP;
use Palabra;

$CGI::POST_MAX=1024*100;  # max 100 KBytes posts
$CGI::DISABLE_UPLOADS = 1;  # no uploads

my $q = CGI->new();
my $lang = $q->param('lang');

# locale settings
use locale;
use POSIX 'locale_h';
setlocale(LC_CTYPE, $lang); # or die "Invalid locale";
die "'$lang' is not accepted" unless $lang =~ m/^\w\w_\w\w$/;

my $p = Palabra->new( lang => $lang );
$p->{home_url} = sprintf( "index.cgi?lang=%s", $q->escape($lang) );

# HTML header information
my $author = 'Ramiro Gómez, ramiro@rahoo.de';
my $css = '/style/palabra.css';
my $home = 'palabra';

my @errors;
my %formdata;

# print top of the page
print $q->header(), $q->start_html( 
				    -title => $home,
				    -meta => { copyright => "copyright 2003 $author" },
				    -style=>{ src => $css }
				    ),
    $q->table( { -width => '100%', -class => 'top_bar' },
	       $q->Tr(
		      $q->td( { -class => 'left' }, $q->a( { -href => $p->{home_url} }, $p->{home} ), ' : ',  'Contact form' ), #  $q->td
		      $q->td( { -class => 'right' }, $p->display_look_up_form($p->{lang}) )
		      ) # $q->Tr
	       ); # $q->table
    
# main dispatch logic
if ( $q->param('name') ) {
    check_form();
    if (@errors) {
	print $q->ul( $q->li(\@errors) ), display_mail_form();
    } else {
	send_mail();
	print $q->p('Thank you. The following data has been sent:'), $q->ul( $q->li( $formdata{name} ), $q->li( $formdata{email} ), $q->li( $formdata{subject} ), $q->li( $formdata{message} ) );
    }
    
} else {
    print display_mail_form();
}

# print footer
print $p->html_footer();

# subroutines
sub display_mail_form {
    return $q->p( 'Please fill in all fields!'),
    $q->start_table( { width => '60%', cellpadding => '4%', style => 'table-layout:fixed' } ),
    $q->start_form(),
    $q->hidden( -name => 'lang', -value => $p->{lang} ),
    $q->Tr( $q->td('Name:'), $q->td( $q->textfield( { name => 'name',
						      size => 50,
						      maxlength => 100 }
						    )
				     )
	    ),
	$q->Tr( $q->td('Email:'), $q->td( $q->textfield( { name => 'email',
							   size => 50,
							   maxlength => 100 } 
							 )
					  )
		),
	$q->Tr( $q->td('Subject:'), $q->td( $q->textfield( { name => 'subject',
							     size => 50,
							     maxlength => 100 }
							   )
					    )
		),
	$q->Tr( $q->td('Message:'), $q->td( $q->textarea( { name => 'message',
							    rows => 10,
							    columns => 50 }
							  )
					    )
		),
	$q->Tr( $q->td( { -colspan => 2 }, $q->submit(),$q->reset() ) ),
	$q->end_form(), $q->end_table();
} # display_mail_form

sub check_form {
    my $name = $q->param('name');
    $name = $p->trim_ws($name);
    if ( !$name ) {
	push @errors, "No name given!";
    } else {
	$formdata{name} = $name;
    }

    my $email = $q->param('email');
    if ( ($email !~ m/^([\w\.-]+\@[\w.-]+[\w]+)$/) || (length($email) < 6) ) {
	push @errors, " E-mail-address '$email' is not accepted!";
    } else {
	$email = $1;
	$formdata{email} = $email;
    }
    
    my $subject = $q->param('subject');
    if ( $subject !~ m/^([\w.\s-]+)$/ ) {
	push @errors, "Subject '$subject' is empty or contains disallowed characters!";
    } else {
	$subject = $1;
	$formdata{subject} = $subject;
    }

    my $message = $q->param('message');
    if ( $message !~ m/^([\w\s\-\.,:!\?]+)$/ ) {
	push @errors, "Message '$message' is empty or contains disallowed characters!";
    } else {
	$message = $1;
	$formdata{message} = $message;
    }
} # check_form

sub send_mail {
    my $smtp = Net::SMTP->new('localhost');
    $smtp->mail($formdata{email});
    $smtp->recipient( 'ramiro@rahoo.de', { SkipBad => 1 } );
    $smtp->data();
    $smtp->datasend("From: $formdata{name} <$formdata{email}>\n");
    $smtp->datasend("To: ramiro\@rahoo.de\n");
    $smtp->datasend("Subject: $formdata{subject}\n");
    $smtp->datasend("\n");
    $smtp->datasend($formdata{message});
    my $success = $smtp->dataend();
    $smtp->quit();
    die "mail could not be sent" unless $success;
} # sub send_mail
