use 5.010001;
use strict;
use warnings;

package Type::FromSah;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use Data::Sah qw( gen_validator );
use Type::Tiny;

use Exporter::Shiny qw( sah2type );

sub sah2type {
	my ( $schema, %opts ) = @_;
	
	my $coderef = gen_validator( $schema );
	my $source  = gen_validator( $schema, { source => 1 } );
	
	return 'Type::Tiny'->new(
		_data_sah  => $schema,
		constraint => sub { @_ = $_; goto $coderef },
		inlined    => sub {
			my $varname = pop;
			( my $src = $source )
				=~ s/sub \{/local \@_ = ($varname); eval \{/;
			$src;
		},
		constraint_generator => sub {
			my @params = @_;
			my $new_schema = [ @$schema, @params ];
			my $child = sah2type( $new_schema, parameters => \@params );
			$child->check(undef); # force type checks to compile BEFORE parent
			$child->{parent} = $Type::Tiny::parameterize_type;
			return $child;
		},
		%opts,
	);
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Type::FromSah - create an efficient Type::Tiny type constraint from a Data::Sah schema

=head1 SYNOPSIS

  package My::Types {
    use Type::Library -base;
    use Type::FromSah qw( sah2type );
    
    __PACKAGE__->add_type(
      sah2type( [ "int", min => 1, max => 10 ], name => 'SmallInt' )
    );
  }
  
  use MyTypes qw(SmallInt);
  
  SmallInt->assert_valid( 7 );

=head1 DESCRIPTION

=head2 Functions

This module exports one function.

=head3 C<< sah2type( $schema, %options ) >>

Takes a L<Data::Sah> schema (which should be an arrayref), and generates
a L<Type::Tiny> type constraint object for it. Additional key-value pairs
will be passed to the Type::Tiny constructor.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Type-FromSah>.

=head1 SEE ALSO

L<Data::Sah>, L<Type::Tiny>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2022 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

