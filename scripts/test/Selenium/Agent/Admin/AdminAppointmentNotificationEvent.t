# --
# Copyright (C) 2001-2018 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

my $Selenium = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');

$Selenium->RunTest(
    sub {

        my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

        # Do not check RichText.
        $Helper->ConfigSettingChange(
            Valid => 1,
            Key   => 'Frontend::RichText',
            Value => 0
        );

        # Create test user and login.
        my $TestUserLogin = $Helper->TestUserCreate(
            Groups => ['admin'],
        ) || die "Did not get test user";

        $Selenium->Login(
            Type     => 'Agent',
            User     => $TestUserLogin,
            Password => $TestUserLogin,
        );

        my $ScriptAlias = $Kernel::OM->Get('Kernel::Config')->Get('ScriptAlias');

        # Navigate to AdminNotificationEvent screen.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AdminAppointmentNotificationEvent");

        # Check overview screen.
        $Selenium->find_element( "table",             'css' );
        $Selenium->find_element( "table thead tr th", 'css' );
        $Selenium->find_element( "table tbody tr td", 'css' );

        # Click "Add notification".
        $Selenium->find_element("//a[contains(\@href, \'Action=AdminAppointmentNotificationEvent;Subaction=Add' )]")
            ->VerifiedClick();

        # Check add NotificationEvent screen.
        for my $ID (
            qw(Name Comment ValidID Events en_Subject en_Body)
            )
        {
            my $Element = $Selenium->find_element( "#$ID", 'css' );
            $Element->is_enabled();
            $Element->is_displayed();
        }

        # Toggle Ticket filter widget.
        $Selenium->find_element("//a[contains(\@aria-controls, \'Core_UI_AutogeneratedID_1')]")->click();
        $Selenium->WaitFor(
            JavaScript =>
                "return \$('a[aria-controls*=\"Core_UI_AutogeneratedID_1\"]').attr('aria-expanded') === 'true';"
        );

        # Toggle Article filter (Only for ArticleCreate and ArticleSend event) widget.
        $Selenium->find_element("//a[contains(\@aria-controls, \'Core_UI_AutogeneratedID_2')]")->click();
        $Selenium->WaitFor(
            JavaScript =>
                "return \$('a[aria-controls*=\"Core_UI_AutogeneratedID_2\"]').attr('aria-expanded') === 'false';"
        );

        # Create test NotificationEvent.
        my $NotifEventRandomID = "NotificationEvent" . $Helper->GetRandomID();
        my $NotifEventText     = "Selenium NotificationEvent test";
        $Selenium->find_element( "#Name",    'css' )->send_keys($NotifEventRandomID);
        $Selenium->find_element( "#Comment", 'css' )->send_keys($NotifEventText);
        $Selenium->execute_script(
            "\$('#Events').val('AppointmentNotification').trigger('redraw.InputField').trigger('change');"
        );
        $Selenium->find_element( "#en_Subject", 'css' )->send_keys($NotifEventText);
        $Selenium->find_element( "#en_Body",    'css' )->send_keys($NotifEventText);

        # Check 'Additional recipient' length validation from Additional recipient email addresses (see bug#13936).
        my $FieldValue = "a" x 201;

        # Check TransportEmail checkbox if it is not checked.
        my $TransportEmailCheck = $Selenium->execute_script("return \$('#TransportEmail').prop('checked');");
        if ( !$TransportEmailCheck ) {
            $Selenium->execute_script("\$('#TransportEmail').prop('checked', true);");
            $Selenium->WaitFor( JavaScript => "return \$('#TransportEmail').prop('checked') === true;" );
        }
        $Selenium->find_element( "#RecipientEmail", 'css' )->send_keys($FieldValue);
        $Selenium->find_element("//button[\@type='submit']")->click();
        $Selenium->WaitFor( JavaScript => "return \$('#RecipientEmail.Error').length;" );

        $Self->True(
            $Selenium->execute_script("return \$('#RecipientEmail.Error').length;"),
            "Validation for 'Additional recipient' field is correct",
        );
        $Selenium->find_element( "#RecipientEmail", 'css' )->clear();

        # Set back TransportEmail checkbox if it was not checked.
        if ( !$TransportEmailCheck ) {
            $Selenium->execute_script("\$('#TransportEmail').prop('checked', false);");
            $Selenium->WaitFor( JavaScript => "return \$('#TransportEmail').prop('checked') === false;" );
        }

        $Selenium->find_element("//button[\@type='submit']")->VerifiedClick();

        # Check if test NotificationEvent show on AdminNotificationEvent screen.
        $Self->True(
            $Selenium->execute_script("return \$('.DataTable tr td a:contains($NotifEventRandomID)').length;"),
            "$NotifEventRandomID NotificaionEvent found on page",
        );

        # Check test NotificationEvent values.
        $Selenium->find_element( $NotifEventRandomID, 'link_text' )->VerifiedClick();

        $Self->Is(
            $Selenium->find_element( '#Name', 'css' )->get_value(),
            $NotifEventRandomID,
            "#Name stored value",
        );
        $Self->Is(
            $Selenium->find_element( '#Comment', 'css' )->get_value(),
            $NotifEventText,
            "#Comment stored value",
        );
        $Self->Is(
            $Selenium->find_element( '#en_Subject', 'css' )->get_value(),
            $NotifEventText,
            "#en_Subject stored value",
        );
        $Self->Is(
            $Selenium->find_element( '#en_Body', 'css' )->get_value(),
            $NotifEventText,
            "#en_Body stored value",
        );
        $Self->Is(
            $Selenium->find_element( '#ValidID', 'css' )->get_value(),
            1,
            "#ValidID stored value",
        );

        # Edit test NotificationEvent and set it to invalid.
        my $EditNotifEventText = "Selenium edited NotificationEvent test";

        # Toggle Article filter (Only for ArticleCreate and ArticleSend event) widget.
        $Selenium->find_element("//a[contains(\@aria-controls, \'Core_UI_AutogeneratedID_2')]")->click();
        $Selenium->WaitFor(
            JavaScript =>
                "return \$('a[aria-controls*=\"Core_UI_AutogeneratedID_2\"]').attr('aria-expanded') === 'false';"
        );

        $Selenium->find_element( "#Comment",    'css' )->clear();
        $Selenium->find_element( "#en_Body",    'css' )->clear();
        $Selenium->find_element( "#en_Body",    'css' )->send_keys($EditNotifEventText);
        $Selenium->find_element( "#en_Subject", 'css' )->clear();
        $Selenium->find_element( "#en_Subject", 'css' )->send_keys($EditNotifEventText);
        $Selenium->execute_script("\$('#ValidID').val('2').trigger('redraw.InputField').trigger('change');");
        $Selenium->find_element("//button[\@type='submit']")->VerifiedClick();

        $Selenium->WaitFor(
            JavaScript =>
                "return typeof(\$) === 'function' && \$('.DataTable tr td a:contains($NotifEventRandomID)').length;"
        );

        # Check edited NotifcationEvent values.
        $Selenium->find_element( $NotifEventRandomID, 'link_text' )->VerifiedClick();

        $Self->Is(
            $Selenium->find_element( '#Comment', 'css' )->get_value(),
            "",
            "#Comment updated value",
        );
        $Self->Is(
            $Selenium->find_element( '#en_Body', 'css' )->get_value(),
            $EditNotifEventText,
            "#en_Body updated value",
        );
        $Self->Is(
            $Selenium->find_element( '#ValidID', 'css' )->get_value(),
            2,
            "#ValidID updated value",
        );

        # Go back to AdminNotificationEvent overview screen.
        $Selenium->VerifiedGet("${ScriptAlias}index.pl?Action=AdminAppointmentNotificationEvent");

        # Check class of invalid NotificationEvent in the overview table.
        $Self->True(
            $Selenium->execute_script(
                "return \$('tr.Invalid td a:contains($NotifEventRandomID)').length;"
            ),
            "There is a class 'Invalid' for test NotificationEvent",
        );

        # Get NotificationEventID.
        my %NotifEventID = $Kernel::OM->Get('Kernel::System::NotificationEvent')->NotificationGet(
            Name => $NotifEventRandomID
        );

        # Click on delete icon.
        my $CheckConfirmJS = <<"JAVASCRIPT";
(function () {
    window.confirm = function (message) {
        return true;
    };
}());
JAVASCRIPT
        $Selenium->execute_script($CheckConfirmJS);

        # Delete test SLA with delete button.
        $Selenium->find_element("//a[contains(\@href, \'Subaction=Delete;ID=$NotifEventID{ID}' )]")->VerifiedClick();

        # Check if test NotificationEvent is deleted.
        $Self->False(
            $Selenium->execute_script(
                "return \$('tr.Invalid td a:contains($NotifEventRandomID)').length;"
            ),
            "Test NotificationEvent is deleted - $NotifEventRandomID",
        ) || die;
    }
);

1;
