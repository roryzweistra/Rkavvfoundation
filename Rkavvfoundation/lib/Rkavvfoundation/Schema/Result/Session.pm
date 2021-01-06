use utf8;
package Rkavvfoundation::Schema::Result::Session;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Directliner::Schema::Result::Session

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<session>

=cut

__PACKAGE__->table("session");

=head1 ACCESSORS

=head2 session_id

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 36

=head2 session_data

  data_type: 'text'
  is_nullable: 1

=head2 modified

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "session_id",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 36 },
  "session_data",
  { data_type => "text", is_nullable => 1 },
  "modified",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</session_id>

=back

=cut

__PACKAGE__->set_primary_key("session_id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-11-05 15:09:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FV8fviFcSvj/qOGI5rXpCQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
