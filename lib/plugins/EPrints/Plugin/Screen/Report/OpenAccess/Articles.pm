package EPrints::Plugin::Screen::Report::OpenAccess::Articles;

use EPrints::Plugin::Screen::Report::OpenAccess;
our @ISA = ( 'EPrints::Plugin::Screen::Report::OpenAccess' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{report} = 'OpenAccess-articles';

	return $self;
}

sub filters
{
	my( $self ) = @_;

	my @filters = @{ $self->SUPER::filters || [] };

	push @filters, { meta_fields => [ "type" ], value => 'article' };
	push @filters, { meta_fields => [ "date" ], value => '2015' };

	return \@filters;
}

1;
