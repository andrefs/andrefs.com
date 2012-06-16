package dancer_bootstrap_fontawesome_template;
use strict; use warnings;
use Dancer ':syntax';
# use Cwd;
# use Sys::Hostname;
# use Data::Dump qw/dump/;

use Dancer::Plugin::DBIC;
use Dancer::Plugin::Auth::RBAC;
use Dancer::Plugin::Auth::RBAC::Credentials::DBIC;
use Dancer::Plugin::DebugDump;
use File::Spec;
use File::Slurp;
use Template;
use Data::Dumper;

our $VERSION = '0.1';

my $flash;

sub set_flash {
	my $message = shift; 
    $flash = $message;
}

sub get_flash {
    my $msg = $flash;
    $flash = "";
    return $msg;
}

before_template sub {
    my $tokens = shift;
    $tokens->{'css_url'} = request->base . 'css/style.css';
    $tokens->{'root_url'} = uri_for('/');
    $tokens->{'login_url'} = uri_for('/login');
    $tokens->{'logout_url'} = uri_for('/logout');
};

get '/' => sub {
	my $papercut_schema = schema 'papercut';
	my $rs = $papercut_schema->resultset('Post')->search(undef, {
		columns 	=> [qw/id title text author/ ],
		order_by	=> { -desc => qw/id/ },
	});

	my $entries = [];
	while( my $post = $rs->next){
		push @$entries,{
			title 	=> $post->title,
			text  	=> $post->text,
			author 	=> $post->author->name,
			id		=> $post->id,
		}
	}

    template 'show_entries.tt', {
        'msg' => get_flash(),
        'add_entry_url' => uri_for('/add'),
        'entries' => $entries,
    };
};

post '/add' => sub {
    if ( not session('logged_in') ) {
        send_error("Not logged in", 401);
    }

	my $schema = schema 'papercut';
	my $rs = $schema->resultset('Post')->create({
		title => params->{'title'}, 
		text =>  params->{'text'},
		author => session 'login',
	});

    set_flash('New entry posted!');
    redirect '/';
};

any ['get', 'post'] => '/login' => sub {
    my $err;
	my $schema = schema 'papercut';

    if ( request->method() eq "POST" ) {
        # process form input
		my $auth = auth(params->{login},params->{password});
		set_flash(Dumper($auth));
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
            set_flash('You are logged in.');
            redirect '/';
        }
    }

    # display login form
    template 'login.tt', {
        'err' => $err,
    };

};

get '/logout' => sub {
    session->destroy;
    set_flash('You are logged out.');
    redirect '/';
};

true;


# get '/deploy' => sub {
#     template 'deployment_wizard', {
# 		directory => getcwd(),
# 		hostname  => hostname(),
# 		proxy_port=> 8000,
# 		cgi_type  => "fast",
# 		fast_static_files => 1,
# 	};
# };
# 
# #The user clicked "updated", generate new Apache/lighttpd/nginx stubs
# post '/deploy' => sub {
#     my $project_dir = param('input_project_directory') || "";
#     my $hostname = param('input_hostname') || "" ;
#     my $proxy_port = param('input_proxy_port') || "";
#     my $cgi_type = param('input_cgi_type') || "fast";
#     my $fast_static_files = param('input_fast_static_files') || 0;
# 
#     template 'deployment_wizard', {
# 		directory => $project_dir,
# 		hostname  => $hostname,
# 		proxy_port=> $proxy_port,
# 		cgi_type  => $cgi_type,
# 		fast_static_files => $fast_static_files,
# 	};
# };

true;
