use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
				 module_name         => 'badminton_ladder',
				 dist_author         => 'Andy Brown <setitesuk@gmail.com>',
				 dist_version        => do { my ($r) = q$Revision: 3976 $ =~ /(\d+)/smx; $r; },
				 dist_abstract       => q[clearpress app which runs a badminton ladder website],
				 license             => 'perl',
				 requires            => {
							 'English'                   => '1.01',
							 'Carp'                      => '1.02',
							 'DBI'                       => '1.51',
							 'Config::IniFiles'          => '2.38',
							 'Readonly'                  => '1.03',
							 'DBD::mysql'                => '4.007',
							},
				 build_requires      => {
							 'Test::Distribution'  => '0',
							 'Test::Perl::Critic'  => '0',
							 'Test::More'          => '0.8',
							 'Test::Trap'          => '0.1.1',
							},
				 build_recommends    => {
							},
				 create_makefile_pl  => 'passthrough',
				 script_files        => [qw()],
				);

$builder->create_build_script();
