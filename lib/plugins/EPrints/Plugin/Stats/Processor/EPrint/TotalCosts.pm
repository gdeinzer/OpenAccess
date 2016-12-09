package EPrints::Plugin::Stats::Processor::EPrint::TotalCosts;

our @ISA = qw/ EPrints::Plugin::Stats::Processor /;

use strict;

sub new
{
	my( $class, %params ) = @_;
	my $self = $class->SUPER::new( %params );

#  provide the name of the datatype
	$self->{provides} = [ "oa_total_cost" ];

	$self->{disable} = 0;

	return $self;
}

sub process_record
{
	my ($self, $eprint ) = @_;

	my $epid = $eprint->get_id;
	return unless( defined $epid );

	my $status = $eprint->get_value( "eprint_status" );
	unless( defined $status ) 
	{
##		print STDERR "IRStats2: warning - status not set for eprint=".$eprint->get_id."\n";
		return;
	}

	return unless( $status eq 'archive' );

	my $datestamp = $eprint->get_value( "date" ) || $eprint->get_value( "datestamp" ) || $eprint->get_value( "lastmod" );
	my $date = $self->parse_datestamp( $self->{session}, $datestamp );

	my $year = $date->{year};
	my $month = $date->{month};
	my $day = $date->{day};

# get the cost count
	my $total_cost_count = $eprint->get_value( "oa_total_cost" );
#
# store the cost per eprint id
	if (defined $total_cost_count)
	{
		$self->{cache}->{"$year$month$day"}->{$epid}->{"oa_total_cost"} = $total_cost_count;
	}
}

1;

	

