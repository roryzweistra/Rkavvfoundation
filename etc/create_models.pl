use DBIx::Class::Schema::Loader qw / make_schema_at /;

my $db = 'rkavv';
my $username = 'root';
my $passwd = 'rorgasme1';

make_schema_at(
	'RKAVV::Schema', {
		use_namespaces => 1,
		dump_directory => '/var/www/dancer2/Rkavvfoundation/Rkavvfoundation/lib',
		#dump_directory => '/Users/roryzweistra/Dev/Rkavvfoundation/Rkavvfoundation/lib',
	}, [
		"dbi:mysql:dbname=$db", $username, $passwd
	]
);
