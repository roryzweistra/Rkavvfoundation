use utf8;
package RKAVV::Schema::Result::Signup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

RKAVV::Schema::Result::Signup

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<signup>

=cut

__PACKAGE__->table("signup");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 mollie_customer_id

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 mollie_mandate_id

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 mollie_mandate_type

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 mollie_mandate_status

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 mollie_payment_id

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 mollie_payment_status

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 interval

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 gender

  data_type: 'varchar'
  is_nullable: 1
  size: 1

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 initials

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 birthdate

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 nationality

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 postcode

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 15

=head2 number

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 address

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 place

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 250

=head2 telephone

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 category

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 person_1_first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 person_1_initials

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 person_1_last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 person_1_telephone

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 person_1_email

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 person_2_first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 person_2_initials

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 person_2_last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 person_2_telephone

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 person_2_email

  data_type: 'varchar'
  is_nullable: 1
  size: 250

=head2 former_player

  data_type: 'integer'
  is_nullable: 1

=head2 id_type

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 id_number

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 intake

  data_type: 'integer'
  is_nullable: 1

=head2 consent_info

  data_type: 'integer'
  is_nullable: 1

=head2 consent_pay

  data_type: 'integer'
  is_nullable: 1

=head2 consent_match

  data_type: 'integer'
  is_nullable: 1

=head2 consent_media

  data_type: 'integer'
  is_nullable: 1

=head2 consent_volunteer

  data_type: 'integer'
  is_nullable: 1

=head2 payment_term

  data_type: 'integer'
  is_nullable: 1

=head2 account_iban

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 account_name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 account_place

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "mollie_customer_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "mollie_mandate_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "mollie_mandate_type",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "mollie_mandate_status",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "mollie_payment_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "mollie_payment_status",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "interval",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "gender",
  { data_type => "varchar", is_nullable => 1, size => 1 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "initials",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "birthdate",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "nationality",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "postcode",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 15 },
  "number",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "address",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "place",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 250 },
  "telephone",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "category",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "person_1_first_name",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "person_1_initials",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "person_1_last_name",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "person_1_telephone",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "person_1_email",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "person_2_first_name",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "person_2_initials",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "person_2_last_name",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "person_2_telephone",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "person_2_email",
  { data_type => "varchar", is_nullable => 1, size => 250 },
  "former_player",
  { data_type => "integer", is_nullable => 1 },
  "id_type",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "id_number",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "intake",
  { data_type => "integer", is_nullable => 1 },
  "consent_info",
  { data_type => "integer", is_nullable => 1 },
  "consent_pay",
  { data_type => "integer", is_nullable => 1 },
  "consent_match",
  { data_type => "integer", is_nullable => 1 },
  "consent_media",
  { data_type => "integer", is_nullable => 1 },
  "consent_volunteer",
  { data_type => "integer", is_nullable => 1 },
  "payment_term",
  { data_type => "integer", is_nullable => 1 },
  "account_iban",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "account_name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "account_place",
  { data_type => "varchar", is_nullable => 1, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-07-15 07:57:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tvQLqL6enMrr2Cp6eUl57w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
