# New set publisher

push @{$c->{irstats2}->{sets}}, 
	{
                'name' => 'publisher', 
		'field' => 'publisher', 
		'groupings' => [ 'authors' ]
	},

;



# new report for oa costs

$c->{irstats2}->{report}{main_costs} = 
{

#        main_costs => {
		items => [
		{ plugin => 'ReportHeader' },
#		{
#			plugin => 'Google::PieChart',
#                       datatype => 'oa_type',
#                      datafilter => 'archive',
#                     options => {
#                            top => 'oa_type',
#				title_phrase => 'oa_type'
#                       }
#		},


# Report: number of paid article


		{
			plugin => 'Google::Graph',
			datatype => 'paid_articles',
			datafilter => 'archive',
			options => {
				date_resolution => 'month',
				graph_type => 'column',
				show_average => 1
			}
		},

# Amount of mney spent for OA-articles


		{
			plugin => 'Google::Graph',
			datatype => 'oa_total_cost',
			options => {
				date_resolution => 'month',
				graph_type => 'column',
				show_average => 1
			},
		},

# Distribution on subjects and publishers

		{
			plugin => 'Grid', options => { items => [

                	{
                        	plugin => 'Google::PieChart',
                        	datatype => 'paid_articles',
                        	datafilter => 'archive',
                        	options => {
                                	top => 'subjects',
					title_phrase => 'oa_subjects'
                        	}
                	},
			{
				plugin => 'Table',
				datatype => 'paid_articles',
                        	datafilter => 'archive',
				options => {
					title_phrase => 'oa_publisher',
					top => 'publisher',
				}
			},

			] 
			} 
		},

#  Top articles and authors


                {
                        plugin => 'Grid',
                        options => {
                                items => [
                                {
                                        plugin => 'Table',
                                        datatype => 'oa_total_cost',
                                        options => {
                                                limit => 10,
                                                top => 'eprint',
                                                title_phrase => 'top_oa_total_cost',
                                        },
                                },
                                {
                                        plugin => 'Table',
                                        datatype => 'oa_total_cost',
                                        options => {
                                                limit => 10,
                                                top => 'authors',
                                                title_phrase => 'top_oa_total_cost_authors'
                                        }
                                },]



                        },
                },




		],



		category => 'general',
#	},


};


# enable th processor modules

$c->{plugins}{"Stats::Processor::EPrint::TotalCosts"}{params}{disable} = 0;
$c->{plugins}{"Stats::Processor::EPrint::PaidArticles"}{params}{disable} = 0;
$c->{plugins}{"Stats::Processor::EPrint::OATypes"}{params}{disable} = 0;

