package EPrints::Plugin::Export::Report::CSV::OpenAccess;

use EPrints::Plugin::Export::Report::CSV;
our @ISA = ( "EPrints::Plugin::Export::Report::CSV" );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{name} = "Open Access";
	$self->{accept} = [ 'report/OpenAccess-articles', 'report/OpenAccess-conf-items' ];
	$self->{advertise} = 1;
	return $self;
}


1;
