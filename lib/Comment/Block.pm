use strict;
use warnings;
package Comment::Block;
use Filter::Util::Call;

$Comment::Block::VERSION = "0.01";

#ABSTRACT: Comment::Block - Makes Block Comments Possible

sub import {
    my ($type) = @_;
    my (%context) = (
        _inBlock => 0,
        _filename => (caller)[1],
        _line_no => 0,
        _last_begin => 0,
    );
    filter_add(bless \%context);
}

sub error {
    my ($self) = shift;
    my ($message) = shift;
    my ($line_no) = shift || $self->{last_begin};
    die "Error: $message at $self->{_filename} line $line_no.\n"
}

sub warning {
    my ($self) = shift;
    my ($message) = shift;
    my ($line_no) = shift || $self->{last_begin};
    warn "Warning: $message at $self->{_filename} line $line_no.\n"   
}

sub filter {
    my ($self) = @_;
    my ($status);
    $status = filter_read();
    ++ $self->{LineNo};
    if ($status <= 0) {
       $self->error("EOF Reached with no Comment end.") if $self->{inBlock};
       return $status;
    }
    if ($self->{inBlock}) {
        if (/^\s*#\/\*\s*/ ) {
            $self->warn("Nested COMMENT START", $self->{line_no})
        } elsif (/^\s*#\*\/\s*/) {
            $self->{inBlock} = 0;
        }
        s/^/#/;
    } elsif ( /^\s*#\/\*\s*/ ) {
        $self->{inBlock} = 1;
        $self->{last_begin} = $self->{line_no};
    } elsif ( /^\s*#\*\/\s*/ ) {
        $self->error("Comment Start has no Comment End", $self->{line_no});
    }
    return $status;
}
1;
