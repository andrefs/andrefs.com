package papercut;
use strict; use warnings;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::Auth::RBAC;
use Dancer::Plugin::Auth::RBAC::Credentials::DBIC;
use Dancer::Plugin::FlashNote;
use Data::Dump qw/pp dump/;

load_app 'papercut::blog';
#load_app 'papercut::deploy';

our $VERSION = '0.1';

hook before_template => sub {
	session appname 	=> config->{appname};
	session menu 		=> config->{appmenu};
	session powered_by 	=> config->{powered_by};

    my $tokens = shift;
    $tokens->{'css_url'} 	= request->base . 'css/style.css';
    $tokens->{'root_url'} 	= uri_for('/');
    $tokens->{'login_url'} 	= uri_for('/login');
    $tokens->{'logout_url'} = uri_for('/logout');
};


get '/' => sub {
    template 'home.tt';
};

any ['get', 'post'] => '/login' => sub {
    my $err;
	my $schema = schema 'papercut';

    if ( request->method() eq "POST" ) {
        # process form input
		my $auth = auth(params->{login},params->{password});
		flash error => pp $auth;
		if(!authd()){
            $err = "Invalid username or password";
        }
        else {
            session 'logged_in' => true;
			my $login = $schema->resultset('User')->find({
				login => params->{'login'}
			},{
				columns => [qw/id/]
			})->id;
            session 'login' => $login;
            flash ok => 'You are logged in.';
            redirect uri_for(prefix);
        }
    }

    # display login form
    template 'login.tt', {
        'err' => $err,
    };
};


get '/logout' => sub {
    session->destroy;
    flash ok => 'You are logged out.';
    redirect uri_for(prefix);
};


true;



