#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Rkavvfoundation;

Rkavvfoundation->to_app;

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Rkavvfoundation;
use Plack::Builder;

builder {
    enable 'Deflater';
    Rkavvfoundation->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to mount several applications on different path

use Rkavvfoundation;
use Rkavvfoundation_admin;

use Plack::Builder;

builder {
    mount '/'      => Rkavvfoundation->to_app;
    mount '/admin'      => Rkavvfoundation_admin->to_app;
}

=end comment

=cut

