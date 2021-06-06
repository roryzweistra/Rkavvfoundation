package Rkavvfoundation;
use Dancer2;

our $VERSION = '0.000001';

use DateTime;
use Data::Printer;
use Try::Tiny;
use Business::MollieAPI;

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

post '/donate' => sub {
    my $random          = session->id;
    my $payment_amount  = body_parameters->get( 'amount'    );
    my $interval        = body_parameters->get( 'interval'  );

    if ( $interval eq 'one_off' ) {
        my $api             = Business::MollieAPI->new(api_key => 'test_ztwebqmHfg2ShM9fr8eJfQcfvbrRUd' );
        my $mollie          = {
            'methods'   => $api->methods->all,
            'issuers'   => $api->issuers->all,
            'payment'   => $api->payments->create(
                'amount'      => $payment_amount,
                'redirectUrl' => 'https://www.rkavvfoundation.nl/boeken/bevestigen',
                'description' => "Donatie " . $random,
            ),
        };

        return redirect $mollie->{ 'payment' }->{ 'links' }->{ 'paymentUrl' };
    }


};

post '/rkavv-aanmelden' => sub {
    use Dancer2::Plugin::Email;

    my $text = "Naam: " . body_parameters->get( 'first_name' ) . ' ' . body_parameters->get( 'initial' ) . ' '
        . body_parameters->get( 'last_name' ) . "\n";

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
};

#------------------------------------------------------------------------------------------------------------------

1;
