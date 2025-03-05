# --
# Copyright (C) 2020-2025 Ulrich Schwarz
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentTicketDeleteAllAttachments;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Ticket',
    'Kernel::System::Ticket::Article',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $TicketObject  = $Kernel::OM->Get('Kernel::System::Ticket');
    my $ArticleObject = $Kernel::OM->Get('Kernel::System::Ticket::Article');
    my $ConfigObject  = $Kernel::OM->Get('Kernel::Config');

    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');

    my $TicketID  = $ParamObject->GetParam( Param => 'TicketID' );
    my $ArticleID = $ParamObject->GetParam( Param => 'ArticleID' );


    # check needed stuff
    if ( !$TicketID ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No TicketID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    if ( !$ArticleID ) {
        return $LayoutObject->ErrorScreen(
            Message => 'No ArticleID is given!',
            Comment => 'Please contact the admin.',
        );
    }

    # actually do something:
    my $BackendObject = $ArticleObject->BackendForArticle( TicketID => $TicketID, ArticleID => $ArticleID );
    my %atts = $BackendObject->ArticleAttachmentIndex( ArticleID => $ArticleID );
    my $attCount = keys %atts;

    if ($attCount > 0){

    my $success = $BackendObject->ArticleDeleteAttachment(
        ArticleID => $ArticleID,
        UserID    => $Self->{UserID},
    );

    my $NoteID = $ArticleObject->ArticleCreate(
        ChannelName          => 'Internal',
        TicketID             => $Self->{TicketID},
        SenderType           => 'agent',
        Subject              => "${attCount} attachments deleted",
        Body                 => "${attCount} attachments to article ${ArticleID} were deleted.",
        From                 => $LayoutObject->{UserFullname},
        ContentType          => 'text/plain; charset=utf-8',
        HistoryType          => 'AddNote',
        HistoryComment       => 'Attachments were removed',
        IsVisibleForCustomer => '0',
        UserID               => $Self->{UserID},
    );
    }
    return $LayoutObject->Redirect( OP => "Action=AgentTicketZoom;TicketID=${TicketID};ArticleId=${ArticleID}" );
}


1;
