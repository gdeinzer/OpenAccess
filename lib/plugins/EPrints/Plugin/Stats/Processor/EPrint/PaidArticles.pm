package EPrints::Plugin::Stats::Processor::EPrint::PaidArticles;

our @ISA = qw/ EPrints::Plugin::Stats::Processor /;

use strict;

# Processor::EPrint::PaidArticles
#
# Processed the number of paid Articles over time. Provides the 'eprint_deposits' datatype.
# 

sub new
{
        my( $class, %params ) = @_;
	my $self = $class->SUPER::new( %params );

	$self->{provides} = [ "paid_articles" ];

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

        my $cost = $eprint->get_value( "oa_total_cost" );
 	unless( defined $cost and $cost>0 ) 
	{
##		print STDERR "\nstatus not set for eprint=".$eprint->get_id;
		return;
	}



	my $datestamp = $eprint->get_value( "date" ) || $eprint->get_value( "datestamp" ) || $eprint->get_value( "lastmod" );

	my $date = $self->parse_datestamp( $self->{session}, $datestamp );

	my $year = $date->{year};
	my $month = $date->{month};
	my $day = $date->{day};

	$self->{cache}->{"$year$month$day"}->{$epid}->{$status}++;
}


1;
