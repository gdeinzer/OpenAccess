package EPrints::Plugin::Stats::Processor::EPrint::OATypes;

our @ISA = qw/ EPrints::Plugin::Stats::Processor /;

use strict;

# Processor::EPrint::OATypes
#
# Processed the number of entries for different types of OA over time. 
# 

sub new
{
        my( $class, %params ) = @_;
	my $self = $class->SUPER::new( %params );

	$self->{provides} = [ "oa_type" ];

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
##		print STDERR "\nstatus not set for eprint=".$eprint->get_id;
		return;
	}

        my $oatype = $eprint->get_value( "oa_type" );
 	unless( defined $oatype ) 
	{
##		print STDERR "\nstatus not set for eprint=".$eprint->get_id;
		return;
	}



	my $datestamp = $eprint->get_value( "datestamp" ) || $eprint->get_value( "lastmod" );

	my $date = $self->parse_datestamp( $self->{session}, $datestamp );

	my $year = $date->{year};
	my $month = $date->{month};
	my $day = $date->{day};

	$self->{cache}->{"$year$month$day"}->{$epid}->{$status}++;
}


1;


