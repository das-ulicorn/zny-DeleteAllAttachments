# --
# Copyright (C) 2020-2025 Ulrich Schwarz
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Output::HTML::ArticleAction::DeleteAllAttachments;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub CheckAccess {
    my ( $Self, %Param ) = @_;

    # Check needed stuff.
    for my $Needed (qw(Ticket Article ChannelName UserID)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    # check if current user is owner or responsible
    if (
        $Param{UserID} == $Param{Ticket}->{OwnerID}
        || (
            $ConfigObject->Get('Ticket::Responsible')
            && $Param{UserID} == $Param{Ticket}->{ResponsibleID}
        )
        )
    {
        return 1;
    }

    return 0;
}

sub GetConfig {
    my ( $Self, %Param ) = @_;

    # Check needed stuff.
    for my $Needed (qw(Ticket Article)) {
        if ( !$Param{$Needed} ) {
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $Link
        = "Action=AgentTicketDeleteAllAttachments;TicketID=$Param{Ticket}->{TicketID};ArticleID=$Param{Article}->{ArticleID}";


    # set important menu item
    my %MenuItem = (
        ItemType    => 'Link',
        Description => Translatable('Delete all attachments irrevocably'),
        Name        => Translatable('Delete attachments'),
        Link        => $Link,
    );

    return ( \%MenuItem );
}

1;
