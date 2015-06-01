# Open Access config file - enables plugins, adds new eprint fields, adds fields to be included in reports

# Enable open access plugins for reports
$c->{plugins}{"Screen::Report::OpenAccess"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::OpenAccess::Articles"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::OpenAccess::ConferenceItems"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV::OpenAccess"}{params}{disable} = 0;

# Enable the plugin for adding the open access stage to the workflow
$c->{plugins}{"Screen::EPMC::OpenAccess"}{params}{disable} = 0;

use EPrints::Utils;

#add new OA fields to eprint
push @{$c->{fields}->{eprint}},
{
	name => 'oa_article_ref',
	type => 'text',
	multiple => 0,
},

{
	name => 'oa_date_of_comp_deposit',
	type => 'date',
	multiple => 0,
},

{
	name => 'oa_est_cost',
	type => 'float',
	multiple => 0,
},

{
	name => 'oa_notes',
	type => 'longtext',
	multiple => 0,
},
{
	name => 'oa_type',
	type => 'set',
    	multiple => 0,
    	options => [qw(
		Green
		Gold
		No-OA-Option
		Outwith-Scope
		Pending
		No-Green-Option
		Other
	)],
},
{
	name => 'oa_pre_payment',
	type => 'set',
	options => [qw(
		Yes
		No
	)],
},
{
	name => 'oa_paid_date',
	type => 'date',
	multiple => 0,
},
{
	name => 'oa_charge',
	type => 'float',
	multiple => 0,
},
{
	name => 'oa_vat',
	type => 'float',
	multiple => 0,
},
{
	name => 'oa_total_cost',
	type => 'float',
	multiple => 0,
},
{
	name => 'oa_apc_fund',
	type => 'set',
    	multiple => 0,
    	options => [qw(
		COAF
		RCUK
		MRC-SPHSU
		Third-Party
		Gold-Other
	)],
},
{
	name => 'oa_transaction_number',
	type => 'int',
	multiple => 1,
},
{
	name => 'oa_finance_project',
	type => 'int',
	multiple => 0,
},
{
	name => 'oa_period',
	type => 'int',
	multiple => 0,
},
{
	name => 'oa_funder_ack',
	type => 'set',
	options => [qw(
		Yes
		No
	)],
	multiple => 0,
},
{
	name => 'oa_research_materials_ack',
	type => 'set',
	options => [qw(
		Yes
		No
	)],
	multiple => 0,
},
;

# Add fields to be returned in reports

# The headings used in the fields correspond to those in the Charities Open Access spreadsheet, where applicable
# Some source mappings - for example 'funding_funder_name' are University of Glasgow specific, but just change these to whatever is used locally
# e.g. EPrints out the box would just be 'funders'

my @example_fields = (
		{
			target => "EPrint ID",
			source => "eprint.eprintid",
			validate => "required",
		},
		{
			target => "Date of initial application by author",
			source => "eprint.datestamp",
			validate => "optional",
		},
		{
			target => "Submitted by",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $session = $plugin->{'session'}; 
					my $eprint = $objects->{eprint};
			        	my $userid = $eprint->get_value( 'userid' );
			                
                    	my $depositor_obj = new EPrints::DataObj::User($session, $userid);    #create a user object
               		my $name = $depositor_obj->get_value( 'name' ); 
               		my $str = EPrints::Utils::make_name_string($name);
                    
					return $str;      		
				},
			validate => "optional",
		},
		{
			target => "University dept.",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $val = $eprint->value('divisions');
					my $subject_ds = $plugin->repository->dataset('subject');
					my $names = [];
					
							foreach my $div_id (@{$val})
							{
								my $subject = $subject_ds->dataobj( $div_id );
					
								if ($subject)
								{
								push @{$names}, EPrints::Utils::tree_to_utf8($subject->render_description); #render_description returns a dom object
								}
								else
								{
								push @{$names}, $div_id; 
								}
							} 
						my $str = join(' ; ', @{$names});
						return $str;
				},
			validate => "optional",
	
		},
		{
			target => "Pubmed Central (PMC) ID",
			source => "eprint.pmcid",
			validate => "optional",
		},
		{
			target => "Pubmed ID",
			source => "eprint.pubmed_id",
			validate => "optional",
		},
		{
			target => "DOI",
			source => "eprint.id_number",
			validate => "optional",
		},
		{
			target => "Affiliated author", # this returns all the authors. Maybe need to just return host institutions?
			source => sub {	
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $creators = $eprint->value('creators');
					my $val = [];
						foreach my $creator (@{$creators})
						{
						push @{$val}, EPrints::Utils::make_name_string($creator->{name});
						}
					my $str = join(' ; ', @{$val});
                    
					my @arr = @{$val};
					return $arr[0]; # Just return the first author, return $str if you want them all
				},
			validate => "optional",
		},
		{
			target => "Publisher",
			source => "eprint.publisher",
			validate => "required",
		},
		{
			target => "Journal",
			source => "eprint.publication",
			validate => "required",
		},
		{
			target => "ISSN",
			source => "eprint.issn",
			validate => "optional",
		},
		{
			target => "Type of publication",
			source => "eprint.type",
			validate => "optional",
		},
		{
			target => "Article title",
			source => "eprint.title",
			validate => "required",
		},
		{
			target => "Date Accepted for Publication",
			source =>  sub {
				my( $plugin, $objects ) = @_;
				my $eprint = $objects->{eprint};
				return $eprint->value( 'rioxx2_dateAccepted' );
				},
			validate => "optional",
		
		},
		{
			target => "Fund that APC is paid from (1)", # COAF spreadhseet has 3 columns for this - so added these to keep the same format
			source => "eprint.oa_apc_fund",
			validate => "optional",
		},
		{
			target => "Fund that APC is paid from (2)",
			source => "",
			validate => "optional",
		},
		{
			target => "Fund that APC is paid from (3)",
			source => "",
			validate => "optional",
		},
		{
			target => "Funder of Research (1)",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $val = $eprint->value('funding_funder_name');
					my $str = join(' ; ', @{$val});
					my @arr = @{$val};
					return $arr[0];
				},
			validate => "optional",
		},
		{
			target => "Funder of Research (2)",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $val = $eprint->value('funding_funder_name');
					my $str = join(' ; ', @{$val});
					my @arr = @{$val};
					return $arr[1];
				},
			validate => "optional",
		},
		{
			target => "Funder of Research (3)",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $val = $eprint->value('funding_funder_name');
					my $str = join(' ; ', @{$val});
					my @arr = @{$val};
					return $arr[2];
				},
			validate => "optional",
		},
		{
			target => "Grant Number (1)",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $val = $eprint->value('funding_funder_code');
					my $str = join(' ; ', @{$val});
					my @arr = @{$val};
					return $arr[0];
				},
			validate => "optional",
		},
		{
			target => "Grant Number (2)",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $val = $eprint->value('funding_funder_code');
					my $str = join(' ; ', @{$val});
					my @arr = @{$val};
					return $arr[1];
				},
			validate => "optional",
		},
		{
			target => "Grant Number (3)",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $val = $eprint->value('funding_funder_code');
					my $str = join(' ; ', @{$val});
					my @arr = @{$val};
					return $arr[2];
				},
			validate => "optional",
		},
		{
			target => "Date of APC payment",
			source => 'eprint.oa_paid_date',
			validate => "optional",
		},
		{
			target => "APC paid (actual currency)including VAT if charged",
			source => '',
			validate => "optional",
		},
		{
			target => "Currency of APC",
			source => '',
			validate => "optional",
		},
		{
			target => "APC paid including VAT if charged",
			source => 'eprint.oa_total_cost',
			validate => "optional",
		},
		{
			target => "Additional costs",
			source => '',
			validate => "optional",
		},
		{
			target => "Discounts, memberships & pre-payment agreements",
			source => '',
			validate => "optional",
		},
		{
			target => "Amount of APC charged to COAF grant (include VAT if charged) in £",
			source => '',
			validate => "optional",
		},
		{
			target => "Licence",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
							
					my $val = [];
	
						
					foreach my $doc ( $eprint->get_all_documents() )
					{
						my $content = $doc->value('content');
						my $format = $doc->value('format');
						
						if ($format eq 'text')
						{
							if($content eq 'published' || $content eq 'accepted')
							{
							push @{$val}, $doc->value('license');
							}
						}
					
					
							
						my $str = join(' ; ', @{$val});
						return $str;
					}
				},
			validate => "optional",
		},
		{
			target => "Correct licence applied?",
			source => '',
			validate => "optional",
		},
		{
			target => "Problem-free open access publication?",
			source => '',
			validate => "optional",
		},
		{
			target => "Notes / Review",
			source => "eprint.oa_notes",
			validate => "optional",					
		},
		{
			target => "Research Materials Acknowledgement",
			source => 'eprint.oa_research_materials_ack',
			validate => "optional",
		},
		{
			target => "Funder Acknowledgement",
			source => 'eprint.oa_funder_ack',
			validate => "optional",
		},
		{
			target => "Type",
			source => "eprint.oa_type",
			validate => "required",		
		},
		{
			target => "Article Reference",
			source => "eprint.oa_article_ref",
			validate => "optional",	
		},
		{
			target => "Date of Compliant Deposit",
			source => "eprint.oa_date_of_comp_deposit",
			validate => "required",		
		},
		{
			target => "Pre Payment",
			source => "eprint.oa_pre_payment",
			validate => "optional",				
		},
		{
			target => "Estimated Cost (ex. vat)",
			source => "eprint.oa_est_cost",
			validate => "optional",				
		},
		{
			target => "Actual Cost (ex. vat)",
			source => "eprint.oa_charge",
			validate => "optional",				
		},
		{
			target => "VAT added",
			source => 'eprint.oa_vat',
			validate => "optional",
		},
		{
			target => "Transaction Number",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $val = $eprint->value('oa_transaction_number');
					my $str = join(' ; ', @{$val});
					return $str;
				},
			validate => "optional",
		},
		{
			target => "Finance Project",
			source => "eprint.oa_finance_project",
			validate => "optional",		
		},
);

$c->{reports}->{"OpenAccess-articles"}->{fields} = [ map { $_->{target} } @example_fields ];
$c->{reports}->{"OpenAccess-articles"}->{mappings} = { map { $_->{target} => $_->{source} } @example_fields };
$c->{reports}->{"OpenAccess-articles"}->{validate} = { map { $_->{target} => $_->{validate} } @example_fields };

$c->{reports}->{"OpenAccess-conf-items"}->{fields} = [ map { $_->{target} } @example_fields ];
$c->{reports}->{"OpenAccess-conf-items"}->{mappings} = { map { $_->{target} => $_->{source} } @example_fields };
$c->{reports}->{"OpenAccess-conf-items"}->{validate} = { map { $_->{target} => $_->{validate} } @example_fields };