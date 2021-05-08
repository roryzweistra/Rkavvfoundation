package Rkavvfoundation;
use Dancer2;

our $VERSION = '0.000001';

use DateTime;
use Data::Printer;

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
    return template 'sponsorship.tt', {}, { 'layout' => 'main.tt' };
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
    return template 'start_eeen_actie.tt', {}, { 'layout' => 'main.tt' };
};

get '/sponsorship' => sub {
    return template 'sponsorship.tt', {}, { 'layout' => 'main.tt' };
};

get '/voordelig-schenken' => sub {
    return template 'voordelig_schenken.tt', {}, { 'layout' => 'main.tt' };
};

#------------------------------------------------------------------------------------------------------------------

1;
