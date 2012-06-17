package papercut;
use strict; use warnings;
use Dancer ':syntax';
load_app 'papercut::blog';
use Data::Dump qw/pp dump/;
#load_app 'papercut::deploy';

our $VERSION = '0.1';

hook after_file_render => sub {
	session appname => config->{appname};
	session menu 	=> config->{appmenu};
};

before_template sub {
    my $tokens = shift;
    $tokens->{'css_url'} = request->base . 'css/style.css';
    $tokens->{'root_url'} = uri_for('/');
    $tokens->{'login_url'} = uri_for('/blog/login');
    $tokens->{'logout_url'} = uri_for('/blog/logout');
};


get '/' => sub {
	
    template 'home.tt';
};



true;



