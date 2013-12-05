#!/usr/bin/env perl

## Ensure that schema views are ignored

BEGIN {
  use Test::Most;
  plan skip_all => 'DBICM_TEST_VIEWS not set'
    unless $ENV{DBICM_TEST_VIEWS} || $ENV{AUTHOR_MODE};
}

use lib 't/lib';
use DBIx::Class::Migration;
use File::Spec::Functions 'catfile';
use File::Path 'rmtree';

## Create the migration object and set it up for test

ok(
  my $migration = DBIx::Class::Migration->new(schema_class=>'Local::Schema'),
  'created migration with schema_class');

isa_ok(
  my $schema = $migration->schema, 'Local::Schema',
  'got a reasonable looking schema');

## Create the deployment files

$migration->prepare;

ok(
  (my $target_dir = $migration->target_dir),
  'got a good target directory');

my $all_tables_conf = catfile($target_dir, 'fixtures','1','conf','all_tables.json');

ok -d catfile($target_dir, 'fixtures'), 'got fixtures';
ok -e $all_tables_conf, 'got the all_tables.json';

## Views ignored by 'prepare'
open my $all_tables_fh, $all_tables_conf or die "Cannot open: $!";
my $all_tables_json = do { local $/; <$all_tables_fh> };
ok( $all_tables_json !~ m/class.*ViewTest/, 'views ignored');

done_testing;

END {
  my $cleanup_dir = $migration->target_dir;
  rmtree catfile($cleanup_dir, 'migrations');
  rmtree catfile($cleanup_dir, 'fixtures');
  rmtree catfile($cleanup_dir, 'local-schema.db');
}
