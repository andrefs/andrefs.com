#!/usr/bin/env perl
use Dancer;
use papercut;

use Plack::Builder;
my $app = sub {
    my $env = shift;

    my $request = Dancer::Request->new( env => $env );
    Dancer->dance($request);
};

builder {
	enable_if { $_[0]->{REMOTE_ADDR} eq '127.0.0.1' } 
		"Plack::Middleware::ReverseProxy";
	enable_if { $ENV{STARMAN_DEBUG} }
	 'Debug', panels => [qw/Parameters Dancer::Version Dancer::Settings Memory/];
	$app;
}
