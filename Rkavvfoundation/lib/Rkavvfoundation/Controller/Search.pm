package Rkavvfoundation::Controller::Search;
use Dancer2 appname => 'Rkavvfoundation';

our $VERSION = '0.000001';

use HTTP::Request;
use LWP::UserAgent;
use Data::Printer;
use XML::Hash::XS;

#------------------------------------------------------------------------------------------------------------------

prefix '/search' => sub {
    post '/'        => \&search;
    get '/'         => \&search;
    get '/holiday' => \&search_holiday;
};

#------------------------------------------------------------------------------------------------------------------

sub search {
    #my $url = 'https://www.ryact.nl/qenner/search/';
    my $url = 'http://localhost:5001/qenner/search/';

    my $search_data = session( 'search_data' );

    my $parameters = {
        'day_range'         => $search_data->{ 'day_range'                  },
        #'destination'       => $search_data->{ 'destination'                },
        'osi_code'          => query_parameters->get( 'osi_code'            ),
        'start_date'        => $search_data->{ 'start_date'                 }->{ 'default' },
        'transport_type'    => $search_data->{ 'transport_type'             },
        'party'             => $search_data->{ 'party'                      },
        'pax_amount'        => $search_data->{ 'pax_amount'                 },
        'room_assignment'   => $search_data->{ 'room_assignment'            },
    };

    if ( query_parameters->get( 'place_id' ) ) {
        $parameters->{ 'place_id' } = query_parameters->get( 'place_id' );
    }

    if ( query_parameters->get( 'transport_type' ) ) {
        $parameters->{ 'transport_type' } = query_parameters->get( 'transport_type' );
    }

    if ( body_parameters->get( 'destination' ) ) {
        $parameters->{ 'destination' } = body_parameters->get( 'destination' );
    }

    my $values = {
        'data' => $parameters,
    };

    my $header          = [ 'Content-Type' => 'application/json; charset=UTF-8' ];
    my $encoded_data    = encode_json( $values );
    my $r               = HTTP::Request->new('POST', $url, $header, $encoded_data);
    my $lwp             = LWP::UserAgent->new;
    my $response        = $lwp->request( $r );

    my $json            = from_json( $response->content );

    my $data            = {
        'resultset' => $json->{ 'search' }->{ 'searchResults' },
        'page'      => $json->{ 'page' },
    };

    p $data;

    return template "search.tt", { 'data' => $data }, { 'layout' => 'main.tt' };
};

#------------------------------------------------------------------------------------------------------------------

sub search_holiday {
    my $url = 'https://www.ryact.nl/qenner/search/get-accommodation-info';

    if ( query_parameters->get( 'osi_code' ) ) {
        $url .= '?osi_code=' . query_parameters->get( 'osi_code' );
    }

    my $r           = HTTP::Request->new( 'GET', $url );
    my $lwp         = LWP::UserAgent->new;
    my $response    = $lwp->request( $r );
    my $json        = from_json( $response->content );
    my $data        = {};

    foreach my $acco (  @{ $json->{ 'accommodationInfoObjects' } } ) {
        if ( !$acco->{ 'xmlDescription' } ) {
            next;
        }

        $data = $acco;

        $data->{ 'xml_content' } = xml2hash $acco->{ 'xmlDescription' };

        last;
    }

    p $data->{ 'xml_content' };

    my $price_url       = 'https://www.ryact.nl/qenner/search/get-prices';

    my $search_data     = session( 'search_data' );

    my $parameters = {
        'day_range'         => $search_data->{ 'day_range'                  },
        'osi_code'          => query_parameters->get( 'osi_code'            ),
        'start_date'        => $search_data->{ 'start_date'                 }->{ 'default' },
        'transport_type'    => $search_data->{ 'transport_type'             },
        'party'             => $search_data->{ 'party'                      },
        'pax_amount'        => $search_data->{ 'pax_amount'                 },
        'room_assignment'   => $search_data->{ 'room_assignment'            },
    };

    my $json = {
        'data' => $parameters,
    };

    my $header          = [ 'Content-Type' => 'application/json; charset=UTF-8' ];
    my $encoded_data    = encode_json( $json );
    my $price_r         = HTTP::Request->new('POST', $price_url, $header, $encoded_data);
    my $price_response  = $lwp->request( $price_r );
    my $price_json      = from_json( $price_response->content );

    $data->{ 'prices' } = $price_json;

    my $cheapest_data   = {};
    my $id              = qr{};
    my $lowest_seen     = qr{};

    # Loop through operators
    foreach my $to ( @{ $data->{ 'prices' }->{ 'accommodations' } } ) {
        # Loop through price options.
        foreach my $option ( @{ $to->{ 'options' } } ) {
            # Loop through dates.
            foreach my $date ( @{ $option->{ 'dates' } } ) {
                if ( !$lowest_seen || $lowest_seen > $date->{ 'price' } ) {
                    $lowest_seen = $date->{ 'price' };
                    $id = $to->{ 'id' };
                }
            }
        }
    }

    # We have the lowest price, get the option data.
    foreach my $to ( @{ $data->{ 'prices' }->{ 'accommodations' } } ) {
        # Skip if not lowest id.
        if ( $to->{ 'id' } != $id ) {
            next;
        }
        else {
            # Loop through price options.
            foreach my $option ( @{ $to->{ 'options' } } ) {
                # Loop through dates.
                foreach my $date ( @{ $option->{ 'dates' } } ) {
                    if ( $date->{ 'price' } != $lowest_seen ) {
                        next;
                    }
                    else {
                        my $year    = substr $date->{ 'startDate' }, 0, 4;
                        my $month   = substr $date->{ 'startDate' }, 3, 2;
                        my $day     = substr $date->{ 'startDate' }, -2;

                        $cheapest_data = {
                            'id'                => $to->{ 'id'                          },
                            'price'             => $date->{ 'price'                     },
                            'human_price'       => substr( $date->{ 'price' }, 0, -2    ),
                            'start_date'        => $date->{ 'startDate'                 },
                            'start_date_human'  => "$day-$month-$year",
                            'board_type'        => $option->{ 'boardType'               },
                            'night_count'       => $option->{ 'nightCount'              },
                            'arrival_airport'   => $option->{ 'arrivalAirport'          },
                            'departure_airport' => $option->{ 'departureAirport'        },
                            'transport_type'    => $option->{ 'transportType'           },
                        };

                    }
                }
            }
        }
    }

    # Get cheapest
    $data->{ 'cheapest' } = $cheapest_data;
    $data->{ 'calender' } = _create_price_calender( $price_json );

    #p $data;

    return template "holiday.tt", { 'data' => $data }, { 'layout' => 'main.tt' };
};

#------------------------------------------------------------------------------------------------------------------

sub _create_price_calender {
    my $json        = shift;
    my $calender    = {};

    # Loop through tour operators
    foreach my $to ( @{ $json->{ 'accommodations' } } ) {

        # Loop through price options.
        foreach my $option ( @{ $to->{ 'options' } } ) {

            # Loop through dates.
            foreach my $date ( @{ $option->{ 'dates' } } ) {

                my $departure = 'car';
                if ( $option->{ 'departureAirport' } ) {
                    $departure = $option->{ 'departureAirport' };
                }

                $calender->{ 'date' }->{ $date->{ 'startDate' } }->{
                'night' }->{
                $option->{ 'nightCount' } }->{
                'board' }->{
                $option->{ 'boardType' } }->{
                'airport' }->{
                $departure }->{
                'tour_operator' }->{
                $to->{ 'tourOperator' } } = {
                    'id'                    => $to->{ 'id'                          },
                    'price'                 => $date->{ 'price'                     },
                    'human_price'           => substr( $date->{ 'price' }, 0, -2    ),
                    'tour_operator'         => $to->{ 'tourOperator'                },
                    'tour_operator_name'    => $to->{ 'tourOperatorName'            },
                    'arrival_airport'       => $option->{ 'arrivalAirport'          },
                    'departure_airport'     => $option->{ 'departureAirport'        },
                    'transport_type'        => $option->{ 'transportType'           },
                };
            }
        }
    }

    # Set extra data for easier use in templates.
    foreach my $date ( keys %{ $calender->{ 'date' } } ) {

        if ( ! exists $calender->{ 'date' }->{ $date }->{ 'human_date' } ) {
            my $year    = substr $date, 0, 4;
            my $month   = substr $date, 3, 2;
            my $day     = substr $date, -2;
            $calender->{ 'date' }->{ $date }->{ 'human_date' } = "$day-$month-$year";
        }

        foreach my $night ( keys %{ $calender->{ 'date' }->{ $date }->{ 'night' } } ) {

            if ( ! exists $calender->{ 'date' }->{ $date }->{ 'night' }->{ $night }->{ 'days' } ) {
                my $day = int( $night + 1 );
                $calender->{ 'date' }->{ $date }->{ 'night' }->{ $night }->{ 'days' } = $day;
                $calender->{ 'available_days' }->{ $day } = 1;
            }
        }
    }

    # Make sure all available_days exists for all date rows for proper calender markup.
    foreach my $day ( keys %{ $calender->{ 'available_days' } } ) {
        my $night = $day - 1;
        foreach my $date ( keys %{ $calender->{ 'date' } } ) {

            if ( ! exists $calender->{ 'date' }->{ $date }->{ 'night' }->{ $night } ) {
                $calender->{ 'date' }->{ $date }->{ 'night' }->{ $night } = 1;
            }
        }
    }

    return $calender;
};

#------------------------------------------------------------------------------------------------------------------


1;
