package Treex::Web::Form::Role::LanguageOptions;

use HTML::FormHandler::Moose::Role;

=head1 NAME

Treex::Web::Form::Role::LanguageOptions - Add lanugage check for the forms

=head1 METHODS

=head2 language_options

Returns all possible languages from the database

=cut

sub language_options {
    my $self = shift;
    $self = $self->form if $self->isa('HTML::FormHandler::Field');
    return unless $self->schema;
    my $res = $self->schema->resultset('Language')->search(undef, {
        order_by => { -asc => ['me.position'] },
    });
    my @options;
    while (my $lang = $res->next) {
        push @options, {
            value => $lang->id,
            label => $lang->name
        };
    }
    return @options;
}

no HTML::FormHandler::Moose::Role;
1;
__END__

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
