# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentAppointmentEdit;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $Output;

    # get params
    my %GetParam;

    # get param object
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    for my $Key (
        qw(CalendarID AppointmentID Title Description Location
        StartYear StartMonth StartDay StartHour StartMinute
        EndYear EndMonth EndDay EndHour EndMinute
        )
        )
    {
        $GetParam{$Key} = $ParamObject->GetParam( Param => $Key );
    }

    # get needed objects
    my $ConfigObject      = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject      = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
    my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

    # check request
    if ( $Self->{Subaction} eq 'EditMask' ) {

        # start date string
        $Param{StartDateString} = $LayoutObject->BuildDateSelection(
            %GetParam,
            Prefix   => 'Start',
            Format   => 'DateInputFormatLong',
            Class    => $Param{Errors}->{DateInvalid},
            Validate => 1,
        );

        # end date string
        $Param{EndDateString} = $LayoutObject->BuildDateSelection(
            %GetParam,
            Prefix   => 'End',
            Format   => 'DateInputFormatLong',
            Class    => $Param{Errors}->{DateInvalid},
            Validate => 1,
        );

        # html mask output
        $LayoutObject->Block(
            Name => 'EditMask',
            Data => {
                %Param,
                %GetParam,
            },
        );

        my $Output .= $LayoutObject->Output(
            TemplateFile => 'AgentAppointmentEdit',
            Data         => {
                %Param,
                %GetParam,
            },
        );
        return $LayoutObject->Attachment(
            NoCache     => 1,
            ContentType => 'text/html',
            Charset     => $LayoutObject->{UserCharset},
            Content     => $Output,
            Type        => 'inline',
        );
    }

    elsif ( $Self->{Subaction} eq 'AddAppointment' ) {

        if ( $GetParam{CalendarID} ) {

            my $AppointmentID = $AppointmentObject->AppointmentCreate(
                %GetParam,
                StartTime => sprintf(
                    "%04d-%02d-%02d %02d:%02d:00",
                    $GetParam{StartYear}, $GetParam{StartMonth}, $GetParam{StartDay},
                    $GetParam{StartHour}, $GetParam{StartMinute}
                ),
                EndTime => sprintf(
                    "%04d-%02d-%02d %02d:%02d:00",
                    $GetParam{EndYear}, $GetParam{EndMonth}, $GetParam{EndDay},
                    $GetParam{EndHour}, $GetParam{EndMinute}
                ),
                TimezoneID => 'Europe/Belgrade',
                UserID     => $Self->{UserID},
            );

            # build JSON output
            my $JSON = '';
            if ($AppointmentID) {
                $JSON = $LayoutObject->JSONEncode(
                    Data => {
                        CalendarID    => $GetParam{CalendarID},
                        AppointmentID => $AppointmentID,
                    },
                );
            }

            # send JSON response
            return $LayoutObject->Attachment(
                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                Content     => $JSON,
                Type        => 'inline',
                NoCache     => 1,
            );
        }
    }

    elsif ( $Self->{Subaction} eq 'EditAppointment' ) {

        if ( $GetParam{CalendarID} && $GetParam{AppointmentID} ) {

            my $Success = $AppointmentObject->AppointmentUpdate(
                %GetParam,
                StartTime => sprintf(
                    "%04d-%02d-%02d %02d:%02d:00",
                    $GetParam{StartYear}, $GetParam{StartMonth}, $GetParam{StartDay},
                    $GetParam{StartHour}, $GetParam{StartMinute}
                ),
                EndTime => sprintf(
                    "%04d-%02d-%02d %02d:%02d:00",
                    $GetParam{EndYear}, $GetParam{EndMonth}, $GetParam{EndDay},
                    $GetParam{EndHour}, $GetParam{EndMinute}
                ),
                TimezoneID => 'Europe/Belgrade',
                UserID     => $Self->{UserID},
            );

            # build JSON output
            my $JSON = '';
            if ($Success) {
                $JSON = $LayoutObject->JSONEncode(
                    Data => {
                        Success => 1,
                    },
                );
            }

            # send JSON response
            return $LayoutObject->Attachment(
                ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
                Content     => $JSON,
                Type        => 'inline',
                NoCache     => 1,
            );
        }
    }

    return;
}

1;