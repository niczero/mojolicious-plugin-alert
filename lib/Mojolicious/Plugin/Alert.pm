package Mojolicious::Plugin::Alert;
use Mojolicious::Plugin -base;

our $VERSION = 0.011;

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

sub register {
  my ($self, $app, $param) = @_;
  $param ||= {};

  push @{$app->renderer->paths}, catdir dirname(__FILE__), 'Alert', 'templates'
    unless $param->{no_template_dir};

  $app->helper(alert => sub {
    my $c = shift;
    my $alert = @_ && (ref $_[-1] eq 'ARRAY' || ref $_[-1] eq 'HASH') ? pop
        : undef;
    my $now = shift;
    my $key = $alert && $now   ? 'flash'      # ->alert(now => [...])
        :     $alert           ? 'new_flash'  # ->alert([...])
        : ref $now eq 'SCALAR' ? 'new_flash'  # ->alert(\'then')
        :                        'flash';     # ->alert or ->alert('now')
    my $alerts = ($c->session->{$key} ||= {})->{alerts} ||= [];
    return $alerts unless $alert;
    if (not defined $now and ($now // 0) < 0) {
      unshift @$alerts, $alert;
    }
    else {
      push @$alerts, $alert;
    }
    return $c;
  });

  $app->hook(after_dispatch => sub {
    my ($c) = @_;
    return unless $c->res->is_status_class(300);    # redirects
    my $alerts = $c->alert(\'then');                # future alerts
    unshift @$alerts, $_ for reverse @{$c->alert};  # preserve ordering
  });
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Alert - UI alerts (set/get) for your app

=head1 SYNOPSIS

In your C<startup>:

  $self->plugin('Alert');

In your controller:

  if ($error) {
    $self->alert([danger => 'Record could not be modified.', 'Read-only']);
    return $self->redirect_to(...);
  }
  else {
    $self->alert(now => [success => 'Record updated.', 'Done']);
    $self->alert(now => [warning => 'Line-endings were converted.']);
    return $self->render;
  }

In your template:

  %== include 'alert'

=head1 DESCRIPTION

This plugin is very focused on a simple, consistent, minimal pattern for
queueing and dequeueing UI alerts.  Although templates are provided to get you
started, the plugin itself is entirely agnostic about how alerts are rendered.
It is simply a micro API on top of the Mojolicious mechanism for
L<Mojolicious::Controller/flash> messages.

Take a look at the templates in the C<templates> directory as a starting point
for creating your own template to include in your pages.  (And consider
contributing template examples for sharing.)

=head1 HELPER

This plugin adds a single helper to your app, with two modes of invocation:
creation and retrieval.

=head2 Create a then alert

A 'then' alert is one to be rendered as part of the following response,
typically after a redirect.

  $c->alert([$level => 'My message', 'Optional Title']);

Add an alert record to the 'then' list.  This is ideal if you are redirecting
the client to another page/controller.  After the redirect, this alert will be
on the 'now' list.  (See file C<test/10-alert.t> to see this in action.)

Level can be one of success, info, warning, danger, debug.  In reality it can be
anything you like since you are in complete control of the alerts that are
queued and how they are interpreted when dequeued.

For that matter, the alert itself can be a hashref, just so long as it is
serialisable.  This is the main driver for the plugin being output-agnostic; a
custom hashref means you can easily support additional data, such as a link to
documentation explaining the problem.

=head2 Create a now alert

A 'now' alert is one to be rendered as part of the current response.

  $c->alert(now => [$level => 'My message', 'Optional Title']);

Add an alert record to the 'now' list.  This is ideal if you are rendering from
the current controller.

=head2 Retrieve the list of now alerts

  my $alerts = $c->alert;
  my $alerts = $c->alert('now');

Get an arrayref of alert records on the 'now' list.  The parameter should be a
truthy scalar or nothing.

  use const Level => 0;
  say $_->[Level] for @{$c->alert};

None of this is tied to templates, of course.  The same mechanism can be used,
for example, when gathering notices for a JSON response.

  $c->render(json => {data => $payload, alerts => $c->alert});

=head2 Retrieve the list of then alerts

  my $then_alerts = $c->alert(\'then');

Get arrayref (possibly 'undef') of alert records on the 'then' list.  The
parameter should be a ref to a scalar.

It is pretty unlikely you will need to access then alerts; that case is mostly
there for testing/debugging.

=head1 HOOK

The plugin sets an L<Mojolicious/after_dispatch> hook.  This takes care of the
case of multiple redirects by ensuring that any alerts that would otherwise be
lost by the redirect are deferred correctly, preserving creation order.

=head1 SEE ALSO

L<Mojolicious::Plugin::BootstrapAlerts>, L<Mojolicious::Plugin::Notifications>.

=cut

.alert {
  margin-bottom: 12px;
  padding-left: 12px;
}
