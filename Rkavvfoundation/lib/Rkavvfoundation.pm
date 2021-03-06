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

get '/rkavv-aanmelden' => sub {
    return template 'rkavv_aanmelden.tt', {}, { 'layout' => 'main.tt' };
};

post '/doneren' => sub {
    my $random          = session->id;
    my $payment_amount  = body_parameters->get( 'amount'    );
    my $interval        = body_parameters->get( 'interval'  );
    my $api_key         = 'test_ztwebqmHfg2ShM9fr8eJfQcfvbrRUd';

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

        return redirect $mollie->{ 'payment' }->{ 'links' }->{ 'paymentUrl' }, 303;
    }
    else {
        my $data    = {};

        # Create customer in Mollie account.
        my $header          = [
            'Content-Type'  => 'application/json; charset=UTF-8',
            'Authorization' => 'Bearer ' . $api_key,
        ];

	    my $user = schema( 'RKAVV' )->resultset( 'Signup' )->create( {
            'payment_amount'	=> $payment_amount,
            'interval'          => $interval,
	    });

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
                    'value'		=> $payment_amount,
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

            return redirect $mollie_payment->{ '_links' }->{ 'checkout' }->{ 'href' }, 303;

        }

    }

};

get '/doneren/bevestigen' => sub {
    return template 'doneren_bevestigen.tt', {}, { 'layout' => 'main.tt' };
};

post '/doneren/verwerken' => sub {
    my $api_key 	= 'test_ztwebqmHfg2ShM9fr8eJfQcfvbrRUd';
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

        my $url = 'https://api.mollie.com/v2/payments/' . $payment_id . '?testmode=true';

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

    if ( $user && $user->interval ) {
        my $start_date = DateTime->now;

        if ( $user->interval eq 'monthly' ) {
            $start_date->add( 'months' => 1 );
        }
        elsif ( $user->interval eq 'quarterly' ) {
            $start_date->add( 'months' => 3 );
        }
        elsif ( $user->interval eq 'yearly' ) {
            $start_date->add( 'months' => 12 );
        }

        my $subscription_url    = 'https://api.mollie.com/v2/customers/' . $user->mollie_customer_id . '/subscriptions';

        my $interval_value = '1 month';

        if ( $user->interval eq  'yearly' ) {
            $interval_value = '12 months';
        }
        elsif ( $user->interval eq 'quarterly' ) {
            $interval_value = '3 months';
        }

        my $payment_values = {
            'amount'	=> {
                'currency'	=> 'EUR',
                'value'		=> $user->payment_amount,
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

post '/rkavv-aanmelden' => sub {
    # CREATE TABLE `signup` (
    #   `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
    #   `mollie_customer_id` varchar(20) DEFAULT NULL,
    #   `mollie_mandate_id` varchar(20) DEFAULT NULL,
    #   `mollie_mandate_type` varchar(20) DEFAULT NULL,
    #   `mollie_mandate_status` varchar(20) DEFAULT NULL,
    #   `gender` varchar(1) DEFAULT NULL,
    #   `first_name` varchar(250) DEFAULT NULL,
    #   `initials` varchar(10) DEFAULT NULL,
    #   `last_name` varchar(250) DEFAULT NULL,
    #   `birthdate` date DEFAULT NULL,
    #   `nationality` varchar(250) DEFAULT NULL,
    #   `postcode` varchar(15) DEFAULT '',
    #   `number` varchar(10) DEFAULT NULL,
    #   `place` varchar(250) DEFAULT '',
    #   `telephone` varchar(20) DEFAULT NULL,
    #   `email` varchar(250) DEFAULT NULL,
    #   `category` varchar(10) DEFAULT NULL,
    #   `person_1_first_name` varchar(250) DEFAULT NULL,
    #   `person_1_initials` varchar(10) DEFAULT NULL,
    #   `person_1_last_name` varchar(250) DEFAULT NULL,
    #   `person_1_telephone` varchar(20) DEFAULT NULL,
    #   `person_1_email` varchar(250) DEFAULT NULL,
    #   `person_2_first_name` varchar(250) DEFAULT NULL,
    #   `person_2_initials` varchar(10) DEFAULT NULL,
    #   `person_2_last_name` varchar(250) DEFAULT NULL,
    #   `person_2_telephone` varchar(20) DEFAULT NULL,
    #   `person_2_email` varchar(250) DEFAULT NULL,
    #   `former_player` int(1) DEFAULT NULL,
    #   `id_type` varchar(20) DEFAULT NULL,
    #   `id_number` varchar(30) DEFAULT NULL,
    #   `intake` int(1) DEFAULT NULL,
    #   `consent_info` int(1) DEFAULT NULL,
    #   `consent_pay` int(1) DEFAULT NULL,
    #   `consent_match` int(1) DEFAULT NULL,
    #   `consent_media` int(1) DEFAULT NULL,
    #   `consent_volunteer` int(1) DEFAULT NULL,
    #   `payment_term` int(1) DEFAULT NULL,
    #   `account_iban` varchar(30) DEFAULT NULL,
    #   `account_name` varchar(50) DEFAULT NULL,
    #   `account_place` varchar(50) DEFAULT NULL,
    #   PRIMARY KEY (`id`)
    # ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    my @allowed = qw |
        id
        mollie_customer_id
        mollie_mandate_id
        mollie_mandate_type
        mollie_mandate_status
        gender
        first_name
        initials
        last_name
        nationality
        postcode
        number
        address
        place
        telephone
        email
        category
        person_1_first_name
        person_1_initials
        person_1_last_name
        person_1_telephone
        person_1_email
        person_2_first_name
        person_2_initials
        person_2_last_name
        person_2_telephone
        person_2_email
        former_player
        id_type
        id_number
        intake
        consent_info
        consent_pay
        consent_match
        consent_media
        consent_volunteer
        payment_term
        account_iban
        account_name
        account_place
    |;

    my $api_key = 'test_fj4WhFGbVtDfSUaxeGPUyweqT9Jz63';
    my $data    = {};

    foreach my $key ( @allowed ) {
        $data->{ $key } = body_parameters->get( $key );
    }

	use Data::Printer;
	p $data;

    # Create record in db.
    my $user = schema( 'RKAVV' )->resultset( 'Signup' )->create( $data );

    if ( ! $user->in_storage ) {
        $user->insert;
    }

    # Create customer in Mollie account.
    my $header          = [
        'Content-Type'  => 'application/json; charset=UTF-8',
        'Authorization' => 'Bearer ' . $api_key,
    ];

    my $customer_email = $data->{ 'email' };
    if ( $data->{ 'person_1_email' } ) {
        $customer_email = $data->{ 'person_1_email' };
    }
    elsif ( $data->{ 'person_2_email' } ) {
        $customer_email = $data->{ 'person_2_email' };
    }

    my $mollie_values   = {
        'name'  => $data->{ 'account_name' },
        'email' => $customer_email,
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
                'value'		=> '0.01',
            },
            'customerId'        => $user->mollie_customer_id,
            'sequenceType'      => 'first',
            'description'   	=> 'RKAVV incasso machtiging',
            'redirectUrl'  	    => 'https://www.rkavvfoundation.nl',
            'webhookUrl'  	    => 'https://www.rkavvfoundation.nl/rkavv-aanmelden-verwerken',
        };

        $encoded_data       = encode_json( $payment_values );
        $r                  = HTTP::Request->new( 'POST', $url, $header, $encoded_data );
        $response           = $lwp->request( $r );
        my $mollie_payment  = from_json( $response->content );
        $user->mollie_payment_id( $mollie_payment->{ 'id' } );
        $user->mollie_payment_status( 'open' );
        $user->update;

        p $mollie_payment;

	return redirect $mollie_payment->{ '_links' }->{ 'checkout' }->{ 'href' }, 303;

    }
};

post 'rkavv-aanmelden-verwerken' => sub {
    my $payment_id = body_parameters->get( 'id' );

    my $user = schema( 'RKAVV' )->resultset( 'Signup' )->search(
        {
            'me.mollie_payment_id' => $payment_id,
        }
    )->first;

    if ( $user ) {
	 my $api_key = 'test_fj4WhFGbVtDfSUaxeGPUyweqT9Jz63';
        my $header          = [
            'Content-Type'  => 'application/json; charset=UTF-8',
            'Authorization' => 'Bearer ' . $api_key,
        ];

        my $url = 'https://api.mollie.com/v2/payments/' . $payment_id . '?testmode=true';


        # my $mandate_values = {
        #     'method'            => 'directdebit',
        #     'consumerName'      => $user->account_name,
        #     'consumerAccount'   => $user->account_iban,
        #     'mandateReference'  => 'Rkavv-signup-' . $user->id,
        # };

        #$encoded_data       = encode_json( $mandate_values );
    my $lwp             = LWP::UserAgent->new;
        my $r                  = HTTP::Request->new( 'GET', $url, $header );
        my $response           = $lwp->request( $r );
        my $mollie_mandate      = from_json( $response->content );

        if ( $mollie_mandate ) {
            $user->mollie_mandate_id( $mollie_mandate->{ 'mandateId' }  );
            $user->mollie_mandate_type( $mollie_mandate->{ 'method' }   );
            $user->mollie_payment_status( $mollie_mandate->{ 'status' } );
            $user->update;
        }

        use Dancer2::Plugin::Email;

        my $text = "Naam: " . $user->first_name . ' ' . $user->last_name . "\n";

        try {
            set layout => '';
            email {
                from    => 'rory@ryuu.nl',
                to      => 'rory@ryuu.nl',
                #to      => 'rory@ryuu.nl',
                subject => "Aanmelding",
                body    => $text,
                type    => 'text',
            };
        }
        catch {
            debug "Could not send email: $_";
        };

	status 200;
        return 'OK';
    }

};

#------------------------------------------------------------------------------------------------------------------

1;
