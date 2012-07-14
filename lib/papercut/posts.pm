package papercut::posts;
use strict; use warnings;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::Auth::RBAC;
use Dancer::Plugin::Auth::RBAC::Credentials::DBIC;
use Dancer::Plugin::FlashNote;
use Dancer::Plugin::Feed;
use Data::Dump qw/pp/;
use Try::Tiny;

prefix '/posts';

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
			link 	=> prefix . "/". $post->id,
		}
	}

    template 'posts/list.tt', {
        'add_entry_url' => uri_for('/posts/new'),
        'entries' => $entries,
    };
};

get qr{/(\d+)} => sub {
	my ($post_id) = splat;
	my $papercut_schema = schema 'papercut';
	my $post = $papercut_schema->resultset('Post')->find(
		{ id => $post_id},
		{ columns => [qw/id title text author/ ] },
	);
	template 'posts/view.tt', {
		post => $post,
	}
};

get '/new' => sub {
   # if ( not session('logged_in') ) {
   #     	flash error 	=> 'You need to be logged in!';
   #  	redirect uri_for('/login');
   # }
   # else {
      	template 'posts/new.tt';
   # }
};

post '/new' => sub {
    if ( not session('logged_in') ) {
       	flash error 	=> 'You need to be logged in!';
    	redirect uri_for('/login');
    }

	my $schema = schema 'papercut';
	my $rs = $schema->resultset('Post')->create({
		title => params->{'title'}, 
		text =>  params->{'text'},
		author => session 'login',
	});

	flash success => 'New entry posted!';
    redirect uri_for(prefix);
};

get '/feed/:format' => sub {
	my $papercut_schema = schema 'papercut';
	my $rs = $papercut_schema->resultset('Post')->search(undef, {
		columns 	=> [qw/id title text author/ ],
		order_by	=> { -desc => qw/id/ },
	});

	my $entries = [];
	while( my $post = $rs->next){
		push @$entries,{
			title 	=> $post->title,
			content	=> $post->text,
			author 	=> $post->author->name,
			link    => uri_for(prefix) . '/' .$post->id,
			# issued
		}
	}
	my $feed;
	try {
		$feed = create_feed(
			format  => params->{format},
			title   => 'my great feed',
			entries => $entries,
		);
	}
	catch {
		my ($exception) = @_;
		if ( $exception->does('FeedInvalidFormat') ){flash error => 'Invalid feed format! Choose atom or rss.'; 		}
		elsif ( $exception->does('FeedNoFormat') ) 	{flash error => 'You need to specify a feed format: atom or rss!'; 	}
		else 										{flash error => 'Something went wrong when creating the feed.'; 	}
		redirect uri_for(prefix);
	};
	return $feed;
};


true;