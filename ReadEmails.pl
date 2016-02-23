#!/usr/bin/perl
use strict;
use warnings;

# required modules
use Net::IMAP::Simple;
use Email::Simple;
use Email::Valid;
use Email::Address;
use IO::Socket::SSL;

# fill in your details here
my $username = 'info@emailaddress.com';
my $password = 'ABCDFEFG';
my $mailhost = 'imap.gmail.com';
my $mailport = 993;
my $mailssl = 1;
my $mailbox = 'SHelfinger/Send Failed';

my $saveFile = 0;
my $filename = 'bounced-email.txt';

# Connect
my $imap = Net::IMAP::Simple->new(
    $mailhost,
    port    => $mailport,
    use_ssl => $mailssl,
) || die "Unable to connect to IMAP: $Net::IMAP::Simple::errstr\n";

# Log in
if ( !$imap->login( $username, $password ) ) {
    print STDERR "Login failed: " . $imap->errstr . "\n";
    exit(64);
}

# Look in the the INBOX
my $nm = $imap->select($mailbox) or die "IMAP Select Error: $!";

# How many messages are there?
my ($unseen, $recent, $num_messages) = $imap->status();
print "unseen: $unseen, recent: $recent, total: $num_messages\n\n";


## Iterate through unseen messages
for ( my $i = 1 ; $i <= $nm ; $i++ ) {
    if ( $imap->seen($i) ) {
        next;
    }
    else {
		if ($saveFile) { open FILE, ">$filename" or die $!; }
    	my $es = Email::Simple->new( join '', @{ $imap->get($i) } );
		my $text = $es->body;
		foreach my $addr (Email::Address->parse($text)) {
			if ($saveFile) { print FILE $addr->address, "\n"; }
			else { print $addr->address; }
		}
		if ($saveFile) { close FILE; }
    }
}

# Disconnect
$imap->quit;

exit;
