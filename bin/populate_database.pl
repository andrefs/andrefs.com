# populate_database.pl
package PaperCut::Schema;
use base qw(DBIx::Class::Schema::Loader);
package main;

my $dbfile = $ARGV[0] // 'papercut.db';
my $schema = PaperCut::Schema->connect("dbi:SQLite:dbname=$dbfile");
$schema->populate( Users => [
	{
		name 		=> 'Commander Adama',
		login		=> 'adama',
		password	=> 'nocylons',
		roles		=> [
						{ rolename => 'guest' },
						{ rolename => 'admin' },
						{ rolename => 'user'  },
						],
	},
	{
		name 		=> 'Captain Apollo',
		login		=> 'apollo',
		password	=> 'viper',
		roles		=> [
						{ rolename => 'guest' },
						{ rolename => 'user'  },
						],
	}
]);

my @post_list= (
  [ 'First post',  '<p>This is the text of the first  post</p>',    'adama'  , [1,2] ],
  [ 'Second post', '<p>This is the text of the second post</p>',    'adama'  , []    ],
  [ 'Third post',  '<p>This is the text of the third  post</p>',    'apollo' , []    ],
  [ 'Fourth post', '<p>This is the text of the fourth post</p>',    'apollo' , []    ],
  );

$schema->populate( Tags => [
	{ name => 'tagone' },
	{ name => 'tagtwo' },
]);

# transform author names into ids
$_->[2] = $schema->resultset('Users')->find({ login => $_->[2] })->id foreach (@post_list);
$schema->populate('Posts', [
  [ 'title', 'text', 'author', 'tags' ],
  @post_list,
]);
