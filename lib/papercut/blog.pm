package papercut::blog;
use strict; use warnings;
use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::Auth::RBAC;
use Dancer::Plugin::Auth::RBAC::Credentials::DBIC;
use Dancer::Plugin::FlashNote;
use Dancer::Plugin::Feed;
use Data::Dump qw/pp/;
use Try::Tiny;

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
   if ( not session('logged_in') ) {
       	flash error 	=> 'You need to be logged in!';
    	redirect uri_for('/login');
   }
   else {
      	template 'newpost.tt';
   }
};

post '/add' => sub {
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
			# link
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
