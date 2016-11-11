use Mojo::Base -strict;
use Test::More;

my $package = 'Mojolicious::Plugin::Alert';
use_ok $package;
my $version = "$Mojolicious::Plugin::Alert::VERSION";
diag "Testing $package $version, Perl $], $^X";

done_testing;
