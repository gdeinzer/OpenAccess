# additional fields to table eprint
push @{$c->{fields}->{eprint}},

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
	type => 'namedset',
    	set_name => "oa_type",
    	multiple => 0,
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
	type => 'text',
	multiple => 0,
        sql_index => 0,
},

{
	name => 'oa_orig_currency',
	type => 'compound',
	fields => [
	                          {
	                            sub_name => 'value',
	                            type => 'float',
	                            input_boxes => 1,
	                            multiple => 0,
	                            sql_index => 0,
	                          },
	                          {
	                            sub_name => 'type',
	                            type => 'set',
	                            options => [qw(
				    		GBP
						EUR
						USD
						)],
	                            input_boxes => 1,
	                            multiple => 0,
	                            sql_index => 0,
	                          }
	                    ],
        multiple => 0,
},

{
	name => 'oa_vat',
	type => 'text',
	multiple => 0,
        sql_index => 0,
},
{
	name => 'oa_total_cost',
	type => 'text',
	multiple => 0,
        sql_index => 0,
},
{
	name => 'oa_apc_fund',
	type => 'namedset',
    	set_name => "apc_fund",
	multiple => 0,
        sql_index => 0,
},
{
	name => 'oa_transaction_number',
	type => 'int',
	multiple => 1,
	input_boxes => 2,
},
{
	name => 'oa_period',
	type => 'int',
	multiple => 0,
        sql_index => 0,
},
{
	name => 'oa_finance_project',
	type => 'text',
	multiple => 0,
    	sql_index => 0,
},
{
	name => 'oa_funder_ack',
	type => 'set',
	options => [qw(
		Yes
		No
        	Partial
	)],
	multiple => 0,
        sql_index => 0,
},
{
	name => 'oa_research_materials_ack',
	type => 'set',
	options => [qw(
		Yes
		No
	)],
	multiple => 0,
        sql_index => 0,
},
{
       	name => 'oa_invoice',
       	type => 'compound',
       	multiple => 1,
       	fields => [
                          {
                            sub_name => 'cost',
                            type => 'float',
                            input_boxes => 1,
                            multiple => 0,
                          },
                          {
                            sub_name => 'number',
                            type => 'text',
                            input_boxes => 1,
                            multiple => 0,
                          }
                    ],
        input_boxes => 1,
},
{
	name => 'oa_cost_recovery',
	type => 'boolean',
    	required => 0,
    	multiple => 0,
        sql_index => 0,
},
{
	name => 'oa_sent_to_aa',
	type => 'boolean',
    	required => 0,
    	multiple => 0,
        sql_index => 0,
},
;

# add fields to be returned in reports
# there are extra columns here that are not stored in eprints 
# but are placeholders for coaf reporting
my @example_fields = (
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
			target => "University department",
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
			target => "Affiliated author",
			source => sub {	
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $creators = $eprint->value('creators');
					my $val = [];
						foreach my $creator (@{$creators})
						{
							my $guid = $creator->{guid}; #check if Glasgow author, i.e. has a guid
							if(defined $guid)
							{
							push @{$val}, EPrints::Utils::make_name_string($creator->{name});
							}
						}
					my $str = join(' ; ', @{$val});
                    			return $str;
					#my @arr = @{$val};
					#return $arr[0]; # Just return the first author
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
			target => "Type of Publication",
			source => "eprint.type",
			validate => "optional",
		},
		{
			target => "Article title",
			source => "eprint.title",
			validate => "required",
		},
		{
			target => "Date of Publication",
			source => sub {
					my( $plugin, $objects ) = @_;
					my $eprint = $objects->{eprint};
					my $date_type = $eprint->value('date_type');
					my $date = $eprint->value('date');
					if ($date_type == 'publication')
					{
						return $date;
					}
				},
			validate => "required",
		},
		{
			target => "Fund that APC is paid from (1)",
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
			target => "Grant ID (1)",
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
			target => "Grant ID (2)",
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
			target => "Grant ID (3)",
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
			target => "APC paid (actual currency) including VAT if charged",
			source => '',
			validate => "optional",
		},
		{
			target => "APC paid (actual currency) excluding VAT",
			source => '',
			validate => "optional",
		},
		{
			target => "VAT (actual currency)",
			source => '',
			validate => "optional",
		},
		{
			target => "Currency of APC",
			source => '',
			validate => "optional",
		},
		{
			target => "APC paid (£) including VAT if charged",
			source => 'eprint.oa_total_cost',
			validate => "optional",
		},
		{
			target => "APC paid (£) excluding VAT",
			source => 'eprint.oa_charge',
			validate => "optional",
		},
		{
			target => "VAT (£)",
			source => 'eprint.oa_vat',
			validate => "optional",
		},
		{
			target => "Additional publication costs",
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
			target => "Amount of APC charged to RCUK OA fund (include VAT if charged) in £",
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
                     }
							
					my $str = join(' ; ', @{$val});
					return $str;
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
			target => "Notes",
			source => "eprint.oa_notes",
			validate => "optional",					
		},
		{
			target => "EPrint ID",
			source => "eprint.eprintid",
			validate => "required",
		},
        	{
			target => "Full Text Status",
			source => "eprint.full_text_status",
			validate => "optional",
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
			target => "Paid Date",
			source => 'eprint.oa_paid_date',
			validate => "optional",
		},
		{
			target => "Estimated Cost (ex. vat)",
			source => "eprint.oa_est_cost",
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
        	{
			target => "Date Type",
			source => "eprint.date_type",
			validate => "optional",
		},
        	{
			target => "Published Online",
			source => "eprint.published_online",
			validate => "optional",
		},
		{
			target => "Period",
			source => "eprint.oa_period",
			validate => "optional",
		},
);

# Enable OA workflow plugin
$c->{plugins}{"Screen::EPMC::OpenAccess"}{params}{disable} = 0;


# Reports
$c->{plugins}{"Screen::Report::OpenAccess"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::OpenAccess::Articles"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV::OpenAccess"}{params}{disable} = 0;


$c->{reports}->{"OpenAccess-articles"}->{fields} = [ map { $_->{target} } @example_fields ];
$c->{reports}->{"OpenAccess-articles"}->{mappings} = { map { $_->{target} => $_->{source} } @example_fields };
$c->{reports}->{"OpenAccess-articles"}->{validate} = { map { $_->{target} => $_->{validate} } @example_fields };