use 5.010_001;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::Alert',
  VERSION_FROM => 'lib/Mojolicious/Plugin/Alert.pm',
  ABSTRACT     => 'Plugin for UI alerts',
  AUTHOR       => 'Nic Sandfield <niczero@cpan.org>',
  LICENSE      => 'artistic_2',
  META_MERGE   => {
    requires  => {perl => 5.010001},
    resources => {
      bugtracker => 'https://github.com/niczero/mojolicious-plugin-alert/issues',
      license    => 'http://www.opensource.org/licenses/artistic-license-2.0',
      repository => 'https://github.com/niczero/mojolicious-plugin-alert'
    },
    no_index => {directory => ['test']}
  },
  BUILD_REQUIRES => {'Test::More' => 0},
  CONFIGURE_REQUIRES => {'ExtUtils::MakeMaker' => 6.3},
  PREREQ_PM => {Mojolicious => 5},
  test => {TESTS => 'test/*.t'}
);
