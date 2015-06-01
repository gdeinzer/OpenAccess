package EPrints::Plugin::Screen::Report::OpenAccess::ConferenceItems;

use EPrints::Plugin::Screen::Report::OpenAccess;
our @ISA = ( 'EPrints::Plugin::Screen::Report::OpenAccess' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{report} = 'OpenAccess-conf-items';

	return $self;
}

sub filters
{
	my( $self ) = @_;

	my @filters = @{ $self->SUPER::filters || [] };

	push @filters, { meta_fields => [ "type" ], value => 'conference_item' };
	push @filters, { meta_fields => [ "date" ], value => '2015' };

	return \@filters;
}

1;
