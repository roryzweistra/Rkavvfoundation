package Rkavvfoundation;
use Dancer2;

our $VERSION = '0.000001';

use DateTime;
use Data::Printer;
use Try::Tiny;
use Business::MollieAPI;
use Dancer2::Plugin::DBIC;

#------------------------------------------------------------------------------------------------------------------

hook 'before' => sub {

};

#------------------------------------------------------------------------------------------------------------------

get '/' => sub {
    return template 'index.tt', {}, { 'layout' => 'main.tt' };
};

get '/anbi' => sub {
    return template 'anbi.tt', {}, { 'layout' => 'main.tt' };
};

get '/avg' => sub {
    return template 'avg.tt', {}, { 'layout' => 'main.tt' };
};


get '/bedrijven' => sub {
    return template 'bedrijven.tt', {}, { 'layout' => 'main.tt' };
};

get '/belastingvoordeel' => sub {
    return template 'belastingvoordeel.tt', {}, { 'layout' => 'main.tt' };
};

get '/beleidsplan' => sub {
    return template 'beleidsplan.tt', {}, { 'layout' => 'main.tt' };
};

get '/bestuur' => sub {
    return template 'bestuur.tt', {}, { 'layout' => 'main.tt' };
};

get '/contact' => sub {
    return template 'contact.tt', {}, { 'layout' => 'main.tt' };
};

get '/cookies' => sub {
    return template 'cookies.tt', {}, { 'layout' => 'main.tt' };
};

get '/copyright' => sub {
    return template 'copyright.tt', {}, { 'layout' => 'main.tt' };
};

get '/disclaimer' => sub {
    return template 'disclaimer.tt', {}, { 'layout' => 'main.tt' };
};

get '/nalaten' => sub {
    return template 'nalaten.tt', {}, { 'layout' => 'main.tt' };
};

get '/nieuwsbrief' => sub {
    return template 'nieuwsbrief.tt', {}, { 'layout' => 'main.tt' };
};

get '/particulieren' => sub {
    return template 'particulieren.tt', {}, { 'layout' => 'main.tt' };
};

get '/projecten' => sub {
    return template 'projecten.tt', {}, { 'layout' => 'main.tt' };
};

get '/resultaten' => sub {
    return template 'resultaten.tt', {}, { 'layout' => 'main.tt' };
};

get '/start-een-actie' => sub {
    return template 'start_een_actie.tt', {}, { 'layout' => 'main.tt' };
};

get '/sponsorship' => sub {
    return template 'sponsorship.tt', {}, { 'layout' => 'main.tt' };
};

get '/voordelig-schenken' => sub {
    return template 'voordelig_schenken.tt', {}, { 'layout' => 'main.tt' };
};

post '/doneren' => sub {
    my $random          = session->id;
    my $payment_amount  = body_parameters->get( 'amount'    );
    my $interval        = body_parameters->get( 'interval'  );
    my $api_key         = 'live_HnGJD4wuRmumbJfpjVGfUKpprSuPCy';

    if ( $interval eq 'one_off' ) {
        my $api             = Business::MollieAPI->new( api_key => $api_key );
        my $mollie          = {
            'methods'   => $api->methods->all,
            'issuers'   => $api->issuers->all,
            'payment'   => $api->payments->create(
                'amount'        => $payment_amount,
                'description'   => "Donatie " . $random,
                'redirectUrl'   => 'https://www.rkavvfoundation.nl/doneren/bevestigen',
                'webhookUrl'    => 'https://www.rkavvfoundation.nl/doneren/verwerken',
            ),
        };

        #return redirect $mollie->{ 'payment' }->{ 'links' }->{ 'paymentUrl' }, 303;
        return redirect $mollie->{ 'payment' }->{ 'links' }->{ 'paymentUrl' };
    }
    else {
        my $data    = {};

        # Create customer in Mollie account.
        my $header          = [
            'Content-Type'  => 'application/json; charset=UTF-8',
            'Authorization' => 'Bearer ' . $api_key,
        ];

    	my $user_data = {
    		'payment_amount'      => $payment_amount,
    		'payment_interval'    => $interval,
    	};

        my $user = schema( 'RKAVV' )->resultset( 'Signup' )->create( $user_data );

    	if ( ! $user->in_storage ) {
            $user->insert;
   	}

        my $mollie_values   = {
            'metadata'  => {
                'session_id'    => $random,
            },
        };

        my $url             = 'https://api.mollie.com/v2/customers';
        my $encoded_data    = encode_json( $mollie_values );
        my $r               = HTTP::Request->new( 'POST', $url, $header, $encoded_data );
        my $lwp             = LWP::UserAgent->new;
        my $response        = $lwp->request( $r );
        my $mollie_customer = from_json( $response->content );

        if ( $mollie_customer ) {
            $user->mollie_customer_id( $mollie_customer->{ 'id' } );
            $user->update;

    	    # Create first payment.
            $url = 'https://api.mollie.com/v2/payments';

            my $payment_values = {
               'amount'	=> {
                   'currency'	=> 'EUR',
                    'value'		=> sprintf( "%.2f", $payment_amount ),
                },
                'customerId'        => $user->mollie_customer_id,
                'sequenceType'      => 'first',
                'description'   	=> 'RKAVV Foundation donatie',
                'redirectUrl'  	    => 'https://www.rkavvfoundation.nl/doneren/bevestigen',
                'webhookUrl'  	    => 'https://www.rkavvfoundation.nl/doneren/verwerken',
            };

            $encoded_data       = encode_json( $payment_values );
            $r                  = HTTP::Request->new( 'POST', $url, $header, $encoded_data );
            $response           = $lwp->request( $r );
            my $mollie_payment  = from_json( $response->content );

            if ( $mollie_payment ) {
                $user->mollie_payment_id( $mollie_payment->{ 'id' } );
                $user->update;

           	    return redirect $mollie_payment->{ '_links' }->{ 'checkout' }->{ 'href' };

            }
	    }
    }

};

get '/doneren/bevestigen' => sub {
    return template 'doneren_bevestigen.tt', {}, { 'layout' => 'main.tt' };
};

post '/doneren/verwerken' => sub {
    my $api_key 	= 'live_HnGJD4wuRmumbJfpjVGfUKpprSuPCy';
    my $payment_id	= body_parameters->get( 'id' );

    my $user = schema( 'RKAVV' )->resultset( 'Signup' )->search(
        {
            'me.mollie_payment_id' => $payment_id,
        }
    )->first;

    my $header          = [
    	'Content-Type'  => 'application/json; charset=UTF-8',
        'Authorization' => 'Bearer ' . $api_key,
    ];


    if ( $user ) {
        my $header          = [
            'Content-Type'  => 'application/json; charset=UTF-8',
            'Authorization' => 'Bearer ' . $api_key,
        ];

        my $url = 'https://api.mollie.com/v2/payments/' . $payment_id;

        my $lwp             = LWP::UserAgent->new;
        my $r               = HTTP::Request->new( 'GET', $url, $header );
        my $response        = $lwp->request( $r );
        my $mollie_mandate  = from_json( $response->content );

        if ( $mollie_mandate ) {
            $user->mollie_mandate_id( $mollie_mandate->{ 'mandateId' }  );
            $user->mollie_mandate_type( $mollie_mandate->{ 'method' }   );
            $user->mollie_payment_status( $mollie_mandate->{ 'status' } );
            $user->update;
        }
    }

    if ( $user && $user->payment_interval ) {
        my $start_date = DateTime->now;

        if ( $user->payment_interval eq 'monthly' ) {
            $start_date->add( 'months' => 1 );
        }
        elsif ( $user->payment_interval eq 'quarterly' ) {
            $start_date->add( 'months' => 3 );
        }
        elsif ( $user->payment_interval eq 'yearly' ) {
            $start_date->add( 'months' => 12 );
        }

        my $subscription_url    = 'https://api.mollie.com/v2/customers/' . $user->mollie_customer_id . '/subscriptions';

        my $interval_value = '1 month';

        if ( $user->payment_interval eq  'yearly' ) {
            $interval_value = '12 months';
        }
        elsif ( $user->payment_interval eq 'quarterly' ) {
            $interval_value = '3 months';
        }

        my $payment_values = {
            'amount'	=> {
                'currency'	=> 'EUR',
                'value'		=> sprintf( "%.2f", $user->payment_amount ),
            },
            'description'   	=> 'Uw donatie aan RKAVV Foundation',
            'interval'          => $interval_value,
            'startDate'         => $start_date->ymd,
            'webhookUrl'  	    => 'https://www.rkavvfoundation.nl/doneren/bevestigen',
        };

        my $encoded_data        = encode_json( $payment_values );
        my $r                   = HTTP::Request->new( 'POST', $subscription_url, $header, $encoded_data );
        my $lwp                 = LWP::UserAgent->new;
        my $response            = $lwp->request( $r );
        my $mollie_subscription = from_json( $response->content );
        p $mollie_subscription;

    }

    status 200;
    return 'OK';
};

#------------------------------------------------------------------------------------------------------------------

1;
