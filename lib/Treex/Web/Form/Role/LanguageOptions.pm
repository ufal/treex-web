package Treex::Web::Form::Role::LanguageOptions;

use HTML::FormHandler::Moose::Role;

sub language_options {
    my $self = shift;
    $self = $self->form if $self->isa('HTML::FormHandler::Field');
    return unless $self->schema;
    my $res = $self->schema->resultset('LanguageGroup')->search(undef, {
        order_by => { -asc => ['me.position', 'languages.position'] },
        join => { languages => 'language_group' },
        prefetch => [ 'languages' ],
    });
    my @options;
    while (my $group = $res->next) {
        push @options, {
            group => $group->name,
            options => [
                map { {value => $_->id, label => $_->name} } $group->languages
            ]
        };
    }
    return @options;
}

no HTML::FormHandler::Moose::Role;
1;
__END__

=head1 NAME

Treex::Web::Form::Role::LanguageOptions - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Form::Role::LanguageOptions;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Form::Role::LanguageOptions,

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
