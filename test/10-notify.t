use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

use Mojolicious::Lite;
use Mojolicious::Plugin::Alert;

# Set-up
app->secrets(['testing']) if $Mojolicious::VERSION > 4.63;
my $plugin = Mojolicious::Plugin::Alert->new;
$plugin->register(app, {});

is ref(app->alert([info => 'Working so far', 'Good News'])),
    'Mojolicious::Controller', 'ripe for chaining';

# Routes
get j => sub {
  my $c = shift;
  $c->render(json => {now => $c->alert, then => $c->alert(\'then')});
};

get info => sub {
  my $c = shift;
  $c->alert([info => 'Info0'])
    ->render(json => {now => $c->alert, then => $c->alert(\'then')});
};

get info_with_title => sub {
  my $c = shift;
  $c->alert([info => 'Info1', 'Title'])
    ->render(json => {now => $c->alert, then => $c->alert(\'then')});
};

get warning_with_redirect => sub {
  my $c = shift;
  $c->alert([warning => 'Bad things'])->redirect_to('/j');
};

get multi_redirect => sub {
  my $c = shift;
  $c->alert([danger => 'Bouncers'])->redirect_to('/warning_with_redirect');
};

# Tests
my $t = Test::Mojo->new;

$t->get_ok('/j')->status_is(200)->json_is({now => [], then => []});

$t->get_ok('/info')->status_is(200)
  ->json_is({now => [], then => [[info => 'Info0']]});

$t->get_ok('/info_with_title')->status_is(200)
  ->json_is({now => [[info => 'Info0']], then => [[info => 'Info1', 'Title']]});

$t->ua->max_redirects(2);
$t->get_ok('/warning_with_redirect')->status_is(200)
  ->json_is({now => [[info => 'Info1', 'Title'], [warning => 'Bad things']],
      then => []});

$t->get_ok('/info_with_title')->status_is(200)
  ->json_is({now => [], then => [[info => 'Info1', 'Title']]});
$t->get_ok('/multi_redirect')->status_is(200)
  ->json_is({now => [[info => 'Info1', 'Title'], [danger => 'Bouncers'],
      [warning => 'Bad things']], then => []});

done_testing;
