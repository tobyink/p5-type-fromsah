=pod

=encoding utf-8

=head1 PURPOSE

Check that Type::FromSah sets a C<type_default>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

use strict;
use warnings;
use Test::More;

use Type::FromSah -all;

my $Int1 = sah2type( [ 'int*' ], name => 'Int1' );
my $Int2 = sah2type( [ 'int*', default => 42 ], name => 'Int2' );

ok !$Int1->type_default;
ok  $Int2->type_default;
is( $Int2->type_default->(), 42 );

done_testing;

