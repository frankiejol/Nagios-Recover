package Nagios::Recover;

use warnings;
use strict;
use Carp;
use Cwd;
use Exporter 'import';
use YAML qw(LoadFile DumpFile);

use version; our $VERSION = qv('0.0.4');

our @EXPORT_OK = qw(recover fixed);

our $DIR = "/var/run/recover";

# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;


# Module implementation here

sub recover {
    my %data= @_;
    my ($dir) = ($data{dir} or $DIR);
    my $service = $data{service} or croak "Missing service => 'name'";
    my $fixed = $data{fixed};
    my $action  = $data{action};
    croak "Missing action => [action list ]"
                if !$fixed && !$action;

    my $status;
    my $file_status = "$dir/$service.status";
    if (!$fixed &&  -e $file_status ) {
        $status = LoadFile($file_status) or die "I can't open $file_status $! at".getcwd;
        return $status if !check_delay($data{delay}, $file_status);

        $status->{level}++;
        $status->{level}=1 if ( $status->{level} >  scalar @{$action} );
    }

    $status->{service} ||= $data{service};
    $status->{level} ||= 1;

    my $cmd = '<nothing>';
    my $out;

    if ($data{fixed}) {
        $status->{level} = 0;
    } else {

        $cmd= $data{action}->[$status->{level} - 1] 
                   or confess "Missing action for level $status->{level}"
                        . join "\n",@{$data{action}};

        open my $exec ,"-|",$cmd or die "$! $status->{level}";
        while (<$exec>) {
            $out.= $_;
        }
        close $exec;

    }

    DumpFile($file_status,$status) or die "I can't write status file '$file_status' $!";

    $status->{executed} = $cmd;
    $status->{out} = $out;
    return $status;
}

sub fixed {
    return recover(@_,fixed => 1);
}

sub check_delay {
    my ($delay,$file_status) = @_;
    return 1 if !$delay,;

    my @stat = stat($file_status);

    return 1 if time - $stat[9] >= $delay;

    return 0;
}


1; # Magic true value required at end of module
__END__

=head1 NAME

Nagios::Recover - Tries to recover a service executing a list of actions


=head1 VERSION

This document describes Nagios::Recover version 0.0.1


=head1 SYNOPSIS

    use Nagios::Recover qw(recover);

    my $status = recover(
         service => 'ftp',
          action => ["sudo /etc/init.d/ftp restart",
                    "sudo killall -9 ftpd",
                    "sudo /etc/init.d/ftp restart",
                    "sudo init 6"
         ]
    );

    print $status->{executed};
  
    $status = fixed( service => 'ftp');

=head1 DESCRIPTION

    It tries to recover a service in critical condition. A list of 
    actions  must be passed. It will try each one in order every time
    you run recover.
    When it reaches the last one it starts again.

=head1 INTERFACE 

=head2 recover

    my $status = recover (
            log => 'syslog', # default syslog, file if passed   [TODO]
          delay => 60,       # wait time between recovery actions,
                             #   default=0 ( no delay )
        service => $service, # service we are checking   [ MANDATORY ]
         action => [ "sudo /etc/init.d/sevice restart" # [ MANDATORY ]
                    ,"sudo killall -9 serviced"
                    ,"sudo /etc/init.d/service restart"
                    ,"sudo init 6"
                    ],
            dir => "/var/run/recover", # Default operational directory
    );

=head2 fixed

    my $status = recover (
        service => $service, # service we are checking   [ MANDATORY ]
            dir => "/var/run/recover", # Default operational directory
    );


=head2 $status

    $status is a hash with the result of the action issued:

    $status->{executed}; # What action was executed.
    $status->{level};    # Action level item. It increases each time
                         # recover is called.
    $status->{out};      # Stdout of action

=head1 DIAGNOSTICS


=over

=item Can't write to dir_lock file

=item Can't issue recover action

Mostly you haven't configured /etc/sudoers right

=back


=head1 CONFIGURATION AND ENVIRONMENT

Nagios::Recover requires no configuration files or environment variables.


=head1 DEPENDENCIES

=over

=item Nagios

=back

=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS


No bugs have been reported.


=head1 TODO

Logging. recover ( log => 'syslog', .... )
Should default to syslog or a file if specified.

=head1 AUTHOR

Francesc Guasch  C<< <frankie@etsetb.upc.edu> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2011, Francesc Guasch C<< <frankie@etsetb.upc.edu> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
