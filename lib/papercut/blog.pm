package papercut::blog;
use strict; use warnings;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::Auth::RBAC;
use Dancer::Plugin::Auth::RBAC::Credentials::DBIC;
use Dancer::Plugin::FlashNote;
use Data::Dump qw/pp/;

prefix '/blog';



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

    template 'blog.tt', {
        'add_entry_url' => uri_for('/blog/add'),
        'entries' => $entries,
    };
};

get '/add' => sub {
   # if ( not session('logged_in') ) {
   #     send_error("Not logged in", 401);
   # }

	template 'newpost.tt';
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

	flash ok => 'New entry posted!';
    redirect uri_for(prefix);
};


true;
