# Copyright 2004 Ramiro Gómez.
# This program is offered without warranty of any kind.
# See the file LICENSE for redistribution terms.
package Database;
use 5.008;
use strict;
use warnings;
use DBI;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw( db_connect );
our $VERSION = '1.1';

my $host_name = "localhost";#"mysql.sourceforge.net";
my $db_name = "palabra";
my $db_user = "palabra";
my $db_pass = "palabra";
my $dsn = "DBI:mysql:host=$host_name;database=$db_name";

sub db_connect {
    return( DBI->connect( $dsn, $db_user, $db_pass, { PrintError => 0, RaiseError => 1 } ) );
}

1;
__END__

=head1 NAME

Database

=head1 SYNOPSIS

  use Database qw(db_connect);
  my $dbh = db_connect;

=head1 DESCRIPTION

Modul for connecting to the database.
Exports function that returns database handle

=head1 SEE ALSO

L<DBI>

=head1 AUTHOR

Ramiro Gómez, web@ramiro.org

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Ramiro Gómez

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
