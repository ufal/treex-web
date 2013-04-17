package Treex::Web::DB::Validation;

use strict;
use warnings;

use base qw/DBIx::Class/;
use Validation::Class::Simple;
use namespace::autoclean;

__PACKAGE__->load_components( qw/ResultSourceProxy/ );

__PACKAGE__->mk_group_accessors('inherited', qw/
                                                   validation_fields
                                                   validation_config
                                               /);

sub _build_validation_rules {
    my $self = shift;

    my $cols = $self->columns_info;
    my %fields = ();

    for my $col (keys %$cols) {
        my $info = $cols->{$col};
        if (exists $info->{validate} && ref $info->{validate} eq 'HASH') {
            $fields{$col} = $info->{validate};
        }
    }

    my %additional_fields = %{$self->validation_fields||{}};
    my %config = %{$self->validation_config||{}};

    my $rules = Validation::Class::Simple->new(
        fields => {
            %additional_fields,
            %fields,
        },
        ignore_failure => 1, # do not throw errors if validation fails
        ignore_unknown => 1, # do not throw errors if unknown directives are found
        report_failure => 1, # register errors if "method validations" fail
        report_unknown => 1, # register errors if "unknown directives" are found
        %config
    );

    $rules->stash('db', $self);
    $self->{_validation_rules} = $rules;
}

sub validation_rules {
    my $self = shift;
    $self->_build_validation_rules unless $self->{_validation_rules};
    return $self->{_validation_rules};
}

sub set_params { shift->validation_rules->set_params(@_) }

sub validate {
    my $self = shift;

    my $rules = $self->validation_rules;

    $self->{_validation_errors} = undef;

    if ($rules->validate(@_)) {
        $self->set_columns($rules->params);
        return 1;
    }
    use Data::Dumper;
    print STDERR Dumper($rules->errors_to_string);

    my @errors = $rules->get_errors;
    $self->{_validation_errors} = \@errors;
    return 0;
}

sub validation_errors { shift->{_validation_errors} }

1;
__END__

=head1 NAME

Treex::Web::DB::Validation - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::DB::Validation;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::DB::Validation,

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Michal Sedlak, E<lt>sedlakmichal@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
