#----------------------------------------------------------------------------+
#
#  Apache2::WebApp::Plugin::Session - Provides session handling methods
#
#  DESCRIPTION
#  An abstract class, which can be used to manage session data across
#  servers, from within a database, or local file using a consistent
#  interface.
#
#  AUTHOR
#  Marc S. Brooks <mbrooks@cpan.org>
#
#  This module is free software; you can redistribute it and/or
#  modify it under the same terms as Perl itself.
#
#----------------------------------------------------------------------------+

package Apache2::WebApp::Plugin::Session;

use strict;
use base 'Apache2::WebApp::Plugin';
use Params::Validate qw( :all );
use Switch;

our $VERSION = 0.01;

#~~~~~~~~~~~~~~~~~~~~~~~~~~[  OBJECT METHODS  ]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#----------------------------------------------------------------------------+
# create( \%controller, $name, \%data )
#
# Create a new session.

sub create {
    my $self = shift;
    $self->_init_new($_[0]);
    $self->{OBJECT}->create(@_);
}

#----------------------------------------------------------------------------+
# get( \%controller, $name, $id )
#
# Return session data as a hash reference.

sub get {
    my $self = shift;
    $self->_init_new($_[0]);
    $self->{OBJECT}->get(@_);
}

#----------------------------------------------------------------------------+
# delete( \%controller, $name )
#
# Delete an existing session.

sub delete {
    my $self = shift;
    $self->_init_new($_[0]);
    $self->{OBJECT}->delete(@_);
}

#----------------------------------------------------------------------------+
# update( \%controller, $name, \%data )
#
# Update existing session data.

sub update {
    my $self = shift;
    $self->_init_new($_[0]);
    $self->{OBJECT}->update(@_);
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~[  PRIVATE METHODS  ]~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#----------------------------------------------------------------------------+
# _init(\%params)
#
# Return a reference of $self to the caller.

sub _init {
    my ( $self, $params ) = @_;
    return $self;
}

#----------------------------------------------------------------------------+
# _init_new(\%controller)
#
# Based on config value for 'storage_type', include the correct sub-class.

sub _init_new {
    my ( $self, $c )
      = validate_pos( @_,
          { type => OBJECT  },
          { type => HASHREF }
          );

    my $package;

    switch ( $c->config->{session_storage_type} ) {
        case /file/      { $package = "Apache2::WebApp::Plugin::Session::File"      }
        case /memcached/ { $package = "Apache2::WebApp::Plugin::Session::Memcached" }
        case /mysql/     { $package = "Apache2::WebApp::Plugin::Session::MySQL"     }
        else {
            $self->error("Missing config value for 'storage_type'");
        }
    }

    unless ( $package->can('isa') ) {
        eval "require $package";

        $self->error("Failed to load package '$package': $@") if $@;
    }

    if ( $package->can('new') ) {
        $self->{OBJECT} = $package->new;
    }

    return $self;
}

1;

__END__

=head1 NAME

Apache2::WebApp::Plugin::Session - Provides session handling methods

=head1 SYNOPSIS

  my $obj = $c->plugin('Session')->method( ... );     # Apache2::WebApp::Plugin::Session->method()

    or

  $c->plugin('Session')->method( ... );

=head1 DESCRIPTION

An abstract class, which can be used to manage session data across servers,
from within a database, or local file using a consistent interface.

=head1 PREREQUISITES

This package is part of a larger distribution and was NOT intended to be used 
directly.  In order for this plugin to work properly, the following packages
must be installed:

  Apache2::WebApp
  Apache::Session
  Switch

=head1 INSTALLATION

From source:

  $ tar xfz Apache2-WebApp-Plugin-Session-0.X.X.tar.gz
  $ perl MakeFile.PL PREFIX=~/path/to/custom/dir LIB=~/path/to/custom/lib
  $ make
  $ make test     <--- Make sure you do this before contacting me
  $ make install

Perl one liner using CPAN.pm:

  perl -MCPAN -e 'install Apache2::WebApp::Plugin::Session'

Use of CPAN.pm in interactive mode:

  $> perl -MCPAN -e shell
  cpan> install Apache2::WebApp::Plugin::Session
  cpan> quit

Just like the manual installation of Perl modules, the user may need root access during
this process to insure write permission is allowed within the installation directory.

=head1 CONFIGURATION

Unless it already exists, add the following to your projects I<webapp.conf>

  [session]
  storage_type = file     # options - file | mysql | memcached

=head1 OBJECT METHODS

=head2 create

Create a new session.

  my $session_id = $c->plugin('Session')->create( $c, 'login',
      {
          username => 'foo',
          password => 'bar',
      }
    );

=head2 get

Return session data as a hash reference.

  my $data_ref = $c->plugin('Session')->get( $c, 'login' );

  print $data_ref->{username};     # foo is the value

=head2 update

Update existing session data.

  $c->plugin('Session')->update( $c, 'login',
      {
          last_login => localtime(time),
          remember   => 1,
      }
    );

=head2 delete

Delete an existing session.

  $c->plugin('Session')->delete( $c, 'login' );

=head1 SEE ALSO

L<Apache2::WebApp>, L<Apache2::WebApp::Plugin>, L<Apache::Session>

=head1 AUTHOR

Marc S. Brooks, E<lt>mbrooks@cpan.orgE<gt> - L<http://mbrooks.info>

=head1 COPYRIGHT

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut