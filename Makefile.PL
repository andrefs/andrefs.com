use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'papercut',
    AUTHOR              => q{Andre Santos <andrefs@cpan.org>},
    VERSION_FROM        => 'lib/papercut.pm',
    ABSTRACT            => 'YOUR APPLICATION ABSTRACT',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' 										=> 0,
        'YAML'       										=> 0,
        'Dancer'     										=> 1.3095,
		'Dancer::Plugin::Auth::RBAC' 						=> 0,
		'Dancer::Plugin::Auth::RBAC::Credentials::DBIC' 	=> 0,
		'Dancer::Plugin::DBIC' 								=> 0,
		'Dancer::Plugin::FlashNote' 						=> 0,
		'Template'											=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'papercut-*' },
);
