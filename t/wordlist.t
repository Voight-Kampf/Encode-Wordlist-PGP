#!/usr/bin/perl

use warnings;
use strict;

use Test::More tests => 9;

BEGIN { use_ok("Encode::Wordlist::PGP", qw(:all)); }

my $fingerprint = "4155 9711 308F 2A21 B9D5  072D 6219 58AF CB50 B5F9"; # with separators
my $raw_fingerprint = $fingerprint;
$raw_fingerprint =~ s/ //g;

my $text_version = "cranky equipment preshrunk Babylon chairlift midsummer brickyard Camelot sentence specialist ahead clergyman flagpole bottomless endorse pharmacy spheroid embezzle scorecard Waterloo";

my $test_text = join ' ', pgp_wordlist_encode($fingerprint);

is($test_text,  $text_version, "encode()");

eval {
	pgp_wordlist_encode("dodgy string!");
};

like($@, qr/illegal characters in string to encode/, "catch illegal encode input");

eval {
	pgp_wordlist_encode("12345");
};

like($@, qr/doesn't contain an even number/, "catch bad encode input length");

is(join("", pgp_wordlist_decode($text_version)), $raw_fingerprint,  "decode()");

eval {
	pgp_wordlist_decode("dodgy string!");
};

like($@, qr/illegal characters in string to decode/, "catch illegal decode input");

eval {
	pgp_wordlist_decode("stopwatch microwave showgirl hamburger bleargh");
};

like($@, qr/"bleargh" is not in the PGP wordlist/, "catch unknown word in input");

eval {
	pgp_wordlist_decode("cowbell Bradbury gremlin Algol");
};

like ($@, qr/"Algol" has two syllables when three were expected/, "word order 1");

eval {
	pgp_wordlist_decode("Zulu replica dinosaur spaniel");
};

like($@, qr/"dinosaur" has three syllables when two were expected/, "word order 2");