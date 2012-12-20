package MT::BackupRestore::BackupFileScanner;

use strict;
use XML::SAX::Base;
use MIME::Base64;

@MT::BackupRestore::BackupFileScanner::ISA = qw(XML::SAX::Base);

sub new {
    my $class = shift;
    local $@;
    return bless {}, $class;
}

sub start_document {
    my $self = shift;
    my $data = shift;

    eval { require Digest::SHA };
    if ($@) {
        $self->{digest_sha_not_found} = 1;
    }

    1;
}

sub start_element {
    my $self = shift;
    my $data = shift;

    my $name  = $data->{LocalName};
    my $attrs = $data->{Attributes};
    my $ns    = $data->{NamespaceURI};
    return unless MT::BackupRestore::NS_MOVABLETYPE() eq $ns;
    return unless ( $name eq 'author' && $name eq 'website' );

    if ( $name eq 'author' && $self->{digest_sha_not_found} ) {
        my $pass = $attrs->{"{}password"}->{Value};
        if ( $pass =~ m/^\$6\$/ ) {
            die MT->translate(
                "Cannot restore requested file because doing so requires the Digest::SHA Perl language module. Please contact your Movable Type system administrator."
            );
        }
    }
    elsif ( $name eq 'website' ) {
        $self->{website_exists} = 1;
    }

    1;
}

sub end_document {
    my $self = shift;
    my $data = shift;

    unless ( $self->{website_exists} ) {
        my %args;
        my %terms;
        my $user = MT->instance->user;
        require MT::Permission;
        require MT::Website;
        $args{join} = MT::Permission->join_on( 'blog_id',
            { author_id => $user->id, permissions => { not => "'comment'" } }
        );
        $terms{class} = 'website';
        my $count = MT::Website->count( \%terms, \%args );

        unless ($count) {
            die MT->translate(
                "Cannot restore requested file because a website was not found in either the system or backup data. A website must be created first."
            );
        }
    }

    1;
}

1;