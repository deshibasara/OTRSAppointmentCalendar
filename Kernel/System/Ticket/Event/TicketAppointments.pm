# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::TicketAppointments;

use strict;
use warnings;

use Kernel::System::AsynchronousExecutor;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Calendar',
    'Kernel::System::DynamicField',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(Data Event Config)) {
        if ( !$Param{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_!"
            );
            return;
        }
    }
    for (qw(TicketID)) {
        if ( !$Param{Data}->{$_} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $_ in Data!"
            );
            return;
        }
    }

    # loop protection: only execute this handler once for each ticket
    return
        if $Kernel::OM->Get('Kernel::System::Ticket')->{'_TicketAppointments::AlreadyProcessed'}
        ->{ $Param{Data}->{TicketID} }++;

    # handle ticket appointments in an asynchronous call
    return Kernel::System::AsynchronousExecutor->AsyncCall(
        ObjectName     => 'Kernel::System::Calendar',
        FunctionName   => 'TicketAppointments',
        FunctionParams => {
            TicketID => $Param{Data}->{TicketID},
        },
    );
}

1;