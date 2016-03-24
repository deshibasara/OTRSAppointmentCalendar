# --
# Copyright (C) 2001-2016 OTRS AG, http://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

# get Appointment object
my $CalendarObject    = $Kernel::OM->Get('Kernel::System::Calendar');
my $AppointmentObject = $Kernel::OM->Get('Kernel::System::Calendar::Appointment');

# get helper object
$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $UserID = 1;    # Use root

# This will be ok
my %Calendar1 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar',
    UserID       => $UserID,
);

$Self->True(
    $Calendar1{CalendarID},
    'CalendarCreate( CalendarName => "Test calendar", UserID => 1 ) - CalendarID',
);

# only required fields
my $AppointmentID1 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 'Timezone',
    UserID     => $UserID,
);

$Self->True(
    $AppointmentID1,
    'AppointmentCreate #1',
);

# No CalendarID
my $AppointmentID2 = $AppointmentObject->AppointmentCreate(
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 'Timezone',
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID2,
    'AppointmentCreate #2',
);

# No Title
my $AppointmentID3 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 'Timezone',
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID3,
    'AppointmentCreate #3',
);

# No StartTime
my $AppointmentID4 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 'Timezone',
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID4,
    'AppointmentCreate #4',
);

# No EndTime
my $AppointmentID5 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    TimezoneID => 'Timezone',
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID5,
    'AppointmentCreate #5',
);

# No TimezoneID
my $AppointmentID6 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    UserID     => $UserID,
);

$Self->False(
    $AppointmentID6,
    'AppointmentCreate #6',
);

# No UserID
my $AppointmentID7 = $AppointmentObject->AppointmentCreate(
    CalendarID => $Calendar1{CalendarID},
    Title      => 'Webinar',
    StartTime  => '2016-01-01 16:00:00',
    EndTime    => '2016-01-01 17:00:00',
    TimezoneID => 'Timezone',
);

$Self->False(
    $AppointmentID7,
    'AppointmentCreate #7',
);

my $AppointmentID8 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Title',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-01-01 16:00:00',
    EndTime             => '2016-01-01 17:00:00',
    AllDay              => 1,
    TimezoneID          => 'TimezoneID',
    RecurrenceFrequency => '1',
    RecurrenceCount     => '1',
    RecurrenceInterval  => '',
    RecurrenceUntil     => '',
    RecurrenceByMonth   => '',
    RecurrenceByDay     => '',
    UserID              => $UserID,
);

my @Appointments1 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 16:00:00',    # Try at this point of time (at this second)
    EndTime    => '2016-02-01 00:00:00',
);

$Self->Is(
    scalar @Appointments1,
    2,
    'AppointmentList() #1',
);

for my $Appointment (@Appointments1) {

    # Check if

    $Self->True(
        $Appointment->{ID},
        'ID present',
    );
    $Self->True(
        $Appointment->{CalendarID},
        'CalendarIDID present',
    );
    $Self->True(
        $Appointment->{UniqueID},
        'UniqueID present',
    );
    $Self->True(
        $Appointment->{Title},
        'Title present',
    );
    $Self->True(
        $Appointment->{StartTime},
        'StartTime present',
    );
    $Self->True(
        $Appointment->{EndTime},
        'EndTime present',
    );
}

# Before any appointment
my @Appointments2 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '1900-01-01 00:00:00',
    EndTime    => '2016-01-01 00:15:59',
);

$Self->Is(
    scalar @Appointments2,
    0,
    'AppointmentList() #2',
);

# After appointment
my @Appointments3 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-01-01 00:00:00',
    EndTime    => '2016-03-23 06:00:00'

        # 2016-03-23 06:00:00 2016-03-21 14:00:00  2016-03-23 05:00:00

);

# $Self->Is(
#     scalar @Appointments3,
#     0,
#     'AppointmentList() #3',
# );

# missing CalendarID
my @Appointments4 = $AppointmentObject->AppointmentList();
$Self->Is(
    scalar @Appointments4,
    0,
    'AppointmentList() #4',
);

# add recurring appointment once a day
my $AppointmentIDRec1 = $AppointmentObject->AppointmentCreate(
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Recurring appointment',
    Description         => 'Description',
    Location            => 'Germany',
    StartTime           => '2016-03-01 16:00:00',
    EndTime             => '2016-03-01 17:00:00',
    AllDay              => 1,
    TimezoneID          => 'TimezoneID',
    RecurrenceFrequency => '1',                       # each day
    RecurrenceCount     => '',
    RecurrenceInterval  => '',
    RecurrenceUntil     => '2016-03-06 00:00:00',
    RecurrenceByMonth   => '',
    RecurrenceByDay     => '',
    UserID              => $UserID,
);
$Self->True(
    $AppointmentIDRec1,
    'Recurring appointment #1 created',
);

# List recurring appointments
my @AppointmentsRec1 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-03-01 00:00:00',
    EndTime    => '2016-03-06 00:00:00',
);
$Self->Is(
    scalar @AppointmentsRec1,
    5,
    'AppointmentList() - # rec1 ok',
);

# update recurring appointment
my $SuccessRec1 = $AppointmentObject->AppointmentUpdate(
    AppointmentID       => $AppointmentIDRec1,
    CalendarID          => $Calendar1{CalendarID},
    Title               => 'Classes',
    Description         => 'Additional description',
    Location            => 'Germany',
    StartTime           => '2016-03-02 16:00:00',
    EndTime             => '2016-03-02 17:00:00',
    AllDay              => 1,
    TimezoneID          => 'Timezone',
    RecurrenceFrequency => '2',                        # each 2 days
    RecurrenceCount     => '',
    RecurrenceInterval  => '',
    RecurrenceUntil     => '2016-03-10 17:00:00',
    RecurrenceByMonth   => '',
    RecurrenceByDay     => '',
    UserID              => 1,
);
$Self->True(
    $SuccessRec1,
    'Updated rec #1',
);

# List recurring appointments
@AppointmentsRec1 = $AppointmentObject->AppointmentList(
    CalendarID => $Calendar1{CalendarID},
    StartTime  => '2016-03-01 00:00:00',
    EndTime    => '2016-03-06 00:00:00',
);
$Self->Is(
    scalar @AppointmentsRec1,
    2,
    'Recurring updated - current appointments count check',
);
$Self->Is(
    $AppointmentsRec1[0]->{StartTime},
    '2016-03-02 16:00:00',
    'Recurring updated - #1 start time',
);
$Self->Is(
    $AppointmentsRec1[0]->{EndTime},
    '2016-03-02 17:00:00',
    'Recurring updated - #1 end time',
);
$Self->Is(
    $AppointmentsRec1[1]->{StartTime},
    '2016-03-04 16:00:00',
    'Recurring updated - #1 start time',
);
$Self->Is(
    $AppointmentsRec1[1]->{EndTime},
    '2016-03-04 17:00:00',
    'Recurring updated - #1 end time',
);

my %AppointmentGet1 = $AppointmentObject->AppointmentGet(
    AppointmentID => $AppointmentID8,
);

$Self->Is(
    $AppointmentGet1{ID},
    $AppointmentID8,
    'AppointmentGet() - ID ok',
);
$Self->Is(
    $AppointmentGet1{CalendarID},
    $Calendar1{CalendarID},
    'AppointmentGet() - CalendarID ok',
);
$Self->True(
    $AppointmentGet1{UniqueID},
    'AppointmentGet() - UniqueID ok',
);
$Self->Is(
    $AppointmentGet1{Title},
    'Title',
    'AppointmentGet() - Title ok',
);
$Self->Is(
    $AppointmentGet1{Description},
    'Description',
    'AppointmentGet() - Description ok',
);
$Self->Is(
    $AppointmentGet1{Location},
    'Germany',
    'AppointmentGet() - Location ok',
);
$Self->Is(
    $AppointmentGet1{StartTime},
    '2016-01-01 16:00:00',
    'AppointmentGet() - StartTime ok',
);
$Self->Is(
    $AppointmentGet1{EndTime},
    '2016-01-01 17:00:00',
    'AppointmentGet() - EndTime ok',
);
$Self->Is(
    $AppointmentGet1{AllDay},
    1,
    'AppointmentGet() - AllDay ok',
);
$Self->Is(
    $AppointmentGet1{TimezoneID},
    'TimezoneID',
    'AppointmentGet() - TimezoneID ok',
);
$Self->Is(
    $AppointmentGet1{RecurrenceFrequency},
    1,
    'AppointmentGet() - RecurrenceFrequency ok',
);
$Self->Is(
    $AppointmentGet1{RecurrenceCount},
    1,
    'AppointmentGet() - RecurrenceCount ok',
);
$Self->True(
    $AppointmentGet1{CreateTime},
    'AppointmentGet() - CreateTime ok',
);
$Self->Is(
    $AppointmentGet1{CreateBy},
    $UserID,
    'AppointmentGet() - CreateBy ok',
);
$Self->True(
    $AppointmentGet1{ChangeTime},
    'AppointmentGet() - ChangeTime ok',
);
$Self->Is(
    $AppointmentGet1{ChangeBy},
    $UserID,
    'AppointmentGet() - ChangeBy ok',
);

my %AppointmentGet2 = $AppointmentObject->AppointmentGet();
$Self->False(
    $AppointmentGet2{AppointmentID},
    'AppointmentGet() - Missing AppointmentID',
);

my %Calendar2 = $CalendarObject->CalendarCreate(
    CalendarName => 'Test calendar 2',
    UserID       => $UserID,
);

my $Update1 = $AppointmentObject->AppointmentUpdate(
    AppointmentID       => $AppointmentID8,
    CalendarID          => $Calendar2{CalendarID},
    Title               => 'Webinar title',
    Description         => 'Description details',
    Location            => 'England',
    StartTime           => '2016-01-02 16:00:00',
    EndTime             => '2016-01-02 17:00:00',
    AllDay              => 0,
    TimezoneID          => 'Timezone',
    RecurrenceFrequency => '2',
    RecurrenceCount     => '2',
    UserID              => 1,
);
$Self->True(
    $Update1,
    'AppointmentUpdate() - #1',
);

my %AppointmentGet3 = $AppointmentObject->AppointmentGet(
    AppointmentID => $AppointmentID8,
);
$Self->Is(
    $AppointmentGet3{ID},
    $AppointmentID8,
    'AppointmentUpdate() - AppointmentID ok',
);
$Self->Is(
    $AppointmentGet3{CalendarID},
    $Calendar2{CalendarID},
    'AppointmentUpdate() - CalendarID ok',
);
$Self->True(
    $AppointmentGet3{UniqueID},
    'AppointmentUpdate() - UniqueID ok',
);
$Self->Is(
    $AppointmentGet3{Title},
    'Webinar title',
    'AppointmentUpdate() - Title ok',
);
$Self->Is(
    $AppointmentGet3{Description},
    'Description details',
    'AppointmentUpdate() - Description ok',
);
$Self->Is(
    $AppointmentGet3{Location},
    'England',
    'AppointmentUpdate() - Location ok',
);
$Self->Is(
    $AppointmentGet3{StartTime},
    '2016-01-02 16:00:00',
    'AppointmentUpdate() - StartTime ok',
);
$Self->Is(
    $AppointmentGet3{EndTime},
    '2016-01-02 17:00:00',
    'AppointmentUpdate() - EndTime ok',
);
$Self->False(
    $AppointmentGet3{AllDay},
    'AppointmentUpdate() - AllDay ok',
);
$Self->Is(
    $AppointmentGet3{TimezoneID},
    'Timezone',
    'AppointmentUpdate() - TimezoneID ok',
);
$Self->Is(
    $AppointmentGet3{RecurrenceFrequency},
    2,
    'AppointmentUpdate() - RecurrenceFrequency ok',
);
$Self->Is(
    $AppointmentGet3{RecurrenceCount},
    2,
    'AppointmentUpdate() - RecurrenceCount ok',
);
$Self->Is(
    $AppointmentGet3{CreateBy},
    $UserID,
    'AppointmentUpdate() - CreateBy ok',
);
$Self->Is(
    $AppointmentGet3{ChangeBy},
    $UserID,
    'AppointmentUpdate() - ChangeBy ok',
);

# missing AppointmentID
my $Update2 = $AppointmentObject->AppointmentUpdate(
    CalendarID => $Calendar2{CalendarID},
    Title      => 'Webinar title',
    StartTime  => '2016-01-02 16:00:00',
    EndTime    => '2016-01-03 17:00:00',
    TimezoneID => 'Timezone',
    UserID     => 1,
);
$Self->False(
    $Update2,
    'AppointmentUpdate() - #2 no AppointmentID',
);

# no CalendarID
my $Update3 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    Title         => 'Webinar title',
    StartTime     => '2016-01-02 16:00:00',
    EndTime       => '2016-01-03 17:00:00',
    TimezoneID    => 'Timezone',
    UserID        => 1,
);
$Self->False(
    $Update3,
    'AppointmentUpdate() - #3 no CalendarID',
);

# no title
my $Update4 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    StartTime     => '2016-01-02 16:00:00',
    EndTime       => '2016-01-03 17:00:00',
    TimezoneID    => 'Timezone',
    UserID        => 1,
);
$Self->False(
    $Update4,
    'AppointmentUpdate() - #4 no Title',
);

# no StartTime
my $Update5 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    Title         => 'Webinar title',
    EndTime       => '2016-01-03 17:00:00',
    TimezoneID    => 'Timezone',
    UserID        => 1,
);
$Self->False(
    $Update5,
    'AppointmentUpdate() - #5 no StartTime',
);

# no EndTime
my $Update6 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    Title         => 'Webinar title',
    StartTime     => '2016-01-02 16:00:00',
    TimezoneID    => 'Timezone',
    UserID        => 1,
);
$Self->False(
    $Update6,
    'AppointmentUpdate() - #6 no EndTime',
);

my $Update7 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    Title         => 'Webinar title',
    StartTime     => '2016-01-02 16:00:00',
    UserID        => 1,
);
$Self->False(
    $Update7,
    'AppointmentUpdate() - #7 no TimezoneID',
);

my $Update8 = $AppointmentObject->AppointmentUpdate(
    AppointmentID => $AppointmentID8,
    CalendarID    => $Calendar2{CalendarID},
    Title         => 'Webinar title',
    StartTime     => '2016-01-02 16:00:00',
    TimezoneID    => 'Timezone',
);
$Self->False(
    $Update8,
    'AppointmentUpdate() - #8 no UserID',
);

my $Delete1 = $AppointmentObject->AppointmentDelete(
    UserID => $UserID,
);
$Self->False(
    $Delete1,
    'AppointmentDelete() - #1 without AppointmentID',
);

my $Delete2 = $AppointmentObject->AppointmentDelete(
    AppointmentID => $AppointmentID8,
);
$Self->False(
    $Delete2,
    'AppointmentDelete() - #2 without UserID',
);

my $Delete3 = $AppointmentObject->AppointmentDelete(
    AppointmentID => $AppointmentID8,
    UserID        => $UserID,
);
$Self->True(
    $Delete3,
    'AppointmentDelete() - #3 OK',
);

my %AppointmentGet4 = $AppointmentObject->AppointmentGet(
    AppointmentID => $AppointmentID8,
    UserID        => $UserID,
);
$Self->False(
    $AppointmentGet4{ID},
    'AppointmentDelete() - #4 check if really deleted',
);

1;
