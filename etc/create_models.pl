use DBIx::Class::Schema::Loader qw / make_schema_at /;

my $db = 'rkavv';
my $username = 'root';
my $passwd = '';

make_schema_at(
	'RKAVV::Schema', {
		use_namespaces => 1,
		dump_directory => '/Users/roryzweistra/Dev/Rkavvfoundation/Rkavvfoundation/lib',
	}, [
		"dbi:mysql:dbname=$db", $username, $passwd
	]
);
