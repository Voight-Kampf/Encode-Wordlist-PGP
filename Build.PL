#!/usr/bin/perl

use warnings;
use strict;

use Module::Build;

my $mb = Module::Build->new(
	'module_name' => 'Encode::Wordlist::PGP',
	'license'     => 'perl',
	'requires'    => {
		'perl'    => '5.8.0', # unpack "()" grouping - see Miscellaneous Changes in perl58delta.
	},
	create_makefile_pl => 'passthrough',
);

$mb->create_build_script;
