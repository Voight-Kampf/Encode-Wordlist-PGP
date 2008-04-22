package Encode::Wordlist::PGP;

use warnings;
use strict;

our $VERSION = '1.1';

use base qw(Exporter);
our @EXPORT_OK = qw(pgp_wordlist_encode pgp_wordlist_decode);
our %EXPORT_TAGS = ( "all" => \@EXPORT_OK );

use Carp qw(croak);

my @wordlist;

@{$wordlist[0]} = qw(
	aardvark absurd accrue acme adrift adult afflict ahead aimless Algol
	allow alone ammo ancient apple artist assume Athens atlas Aztec
	baboon backfield backward banjo beaming bedlamp beehive beeswax befriend
	Belfast	berserk billiard bison blackjack blockade blowtorch bluebird
	bombast bookshelf brackish breadline breakup brickyard briefcase Burbank
	button buzzard cement chairlift chatter	checkup chisel choking chopper
	Christmas clamshell classic classroom cleanup clockwork cobra commence
	concert cowbell crackdown cranky crowfoot crucial crumpled crusade cubic
	dashboard deadbolt deckhand dogsled dragnet drainage dreadful drifter
	dropper drumbeat drunken Dupont dwelling eating edict egghead eightball
	endorse endow enlist erase escape exceed eyeglass eyetooth facial fallout
	flagpole flatfoot flytrap fracture framework freedom frighten gazelle
	Geiger glitter glucose goggles goldfish gremlin guidance hamlet highchair
	hockey indoors indulge inverse involve island jawbone keyboard kickoff
	kiwi klaxon locale lockup merit minnow miser Mohawk mural music necklace
	Neptune newborn nightbird Oakland obtuse offload optic orca payday peachy
	pheasant physique playhouse Pluto preclude prefer preshrunk printer
	prowler pupil puppy python quadrant quiver quota ragtime ratchet rebirth
	reform regain reindeer rematch repay retouch revenge reward rhythm
	ribcage ringbolt robust rocker ruffled sailboat sawdust scallion scenic
	scorecard Scotland seabird select sentence shadow shamrock showgirl
	skullcap skydive slingshot slowdown snapline snapshot snowcap snowslide
	solo southward soybean spaniel spearhead spellbind spheroid spigot
	spindle spyglass stagehand stagnate stairway standard stapler steamship
	sterling stockman stopwatch stormy sugar surmount suspense sweatband
	swelter tactics talon tapeworm tempest tiger tissue tonic topmost
	tracker transit trauma treadmill Trojan trouble tumor tunnel tycoon uncut
	unearth unwind uproot upset upshot vapor village virus Vulcan waffle
	wallet watchword wayside willow woodlark Zulu
);

@{$wordlist[1]} = qw(
	adroitness adviser aftermath aggregate alkali almighty amulet amusement
	antenna applicant Apollo armistice article asteroid Atlantic atmosphere
	autopsy Babylon backwater barbecue belowground bifocals bodyguard
	bookseller borderline bottomless Bradbury bravado Brazilian breakaway
	Burlington businessman butterfat Camelot candidate cannonball Capricorn
	caravan caretaker celebrate cellulose certify chambermaid Cherokee
	Chicago clergyman coherence combustion commando company component
	concurrent confidence conformist congregate consensus consulting
	corporate corrosion councilman crossover crucifix cumbersome customer
	Dakota decadence December decimal designing detector detergent determine
	dictator dinosaur direction disable disbelief disruptive distortion
	document embezzle enchanting enrollment enterprise equation equipment
	escapade Eskimo everyday examine existence exodus fascinate filament
	finicky forever fortitude frequency gadgetry Galveston getaway glossary
	gossamer graduate gravity guitarist hamburger Hamilton handiwork
	hazardous headwaters hemisphere hesitate hideaway holiness hurricane
	hydraulic impartial impetus inception indigo inertia infancy inferno
	informant insincere insurgent integrate intention inventive Istanbul
	Jamaica Jupiter leprosy letterhead liberty maritime matchmaker maverick
	Medusa megaton microscope microwave midsummer millionaire miracle
	misnomer molasses molecule Montana monument mosquito narrative nebula
	newsletter Norwegian October Ohio onlooker opulent Orlando outfielder
	Pacific pandemic Pandora paperweight paragon paragraph paramount
	passenger pedigree Pegasus penetrate perceptive performance pharmacy
	phonetic photograph pioneer pocketful politeness positive potato
	processor provincial proximate puberty publisher pyramid quantity
	racketeer rebellion recipe recover repellent replica reproduce resistor
	responsive retraction retrieval retrospect revenue revival revolver
	sandalwood sardonic Saturday savagery scavenger sensation sociable
	souvenir specialist speculate stethoscope stupendous supportive
	surrender suspicious sympathy tambourine telephone therapist tobacco
	tolerance tomorrow torpedo tradition travesty trombonist truncated
	typewriter ultimate undaunted underfoot unicorn unify universe unravel
	upcoming vacancy vagabond vertigo Virginia visitor vocalist voyager
	warranty Waterloo whimsical Wichita Wilmington Wyoming yesteryear Yucatan
);

# create word => value mappings
my $index;

for ( 0 .. $#{$wordlist[0]} ) {
		$index->{lc @{$wordlist[0]}[$_] } = {
			value     => $_,
			syllables => 2,
		};
}

for ( 0 .. $#{$wordlist[1]} ) {
		$index->{lc @{$wordlist[1]}[$_] } = {
			value     => $_,
			syllables => 3,
		};
}

sub pgp_wordlist_encode {
	my $string = uc(shift);
	
	$string =~ tr/ -//d; # strip separators
	
	croak "illegal characters in string to encode" if $string !~ /^[A-F0-9]+$/;
	croak "string doesn't contain an even number of characters" if length($string) % 2;
	
	my @digits = unpack("(a2)*", $string); # split into two-character hex bytes

	my @words;
	
	foreach my $position (0 .. $#digits) {
	    push @words, $wordlist[$position % 2][hex($digits[$position])];
	}

	return @words;
}

sub pgp_wordlist_decode {
	my $string = shift;

	$string =~ tr/-\n\r/   /;
	$string =~ s/\s+/ /g;
	
	if ($string !~ m/^[\sa-zA-Z]+$/) {
			croak "illegal characters in string to decode";
	}
	
	my @digits;
	
	my $count = 0;
	
	foreach my $word (split / /, $string) {
			my $key = lc($word);
			croak qq("$word" is not in the PGP wordlist) unless $index->{$key};

			# see ALGORITHM in docs below
			if ($count % 2) {
					croak qq("$word" has two syllables when three were expected) if $index->{$key}{syllables} == 2;
			} else {
					croak qq("$word" has three syllables when two were expected) if $index->{$key}{syllables} == 3;
			}

			push @digits, sprintf("%02X", $index->{$key}{value});
			
			$count++;
	}
	
	@digits;
	
}

1;

__END__

=head1 NAME

Encode::Wordlist::PGP - encode/decode hex values using the PGP Word List

=head1 DESCRIPTION

The PGP Word List is a list of words for conveying data bytes in a clear
unambiguous way via a voice channel. They are analogous in purpose to the NATO
phonetic alphabet used by pilots, except a longer list of words is used, each
word corresponding to one of the 256 unique numeric byte values. This module
provides functions to convert between those byte values and words.

=head1 ALGORITHM

The list of words is actually two lists, each containing 256 phonetically
distinct words, in which each word represents a different byte value between 0
and 255. Two lists are used because reading aloud long random sequences of
human words usually risks three kinds of errors: transposition of two
consecutive words, duplicate words, or omitted words. To detect all three
kinds of errors, the two lists are used alternately for the even-offset
bytes (including zero) and the odd-offset bytes in the byte sequence. Each byte
value is actually represented by two different words, depending on whether that
byte appears at an even or an odd offset from the beginning of the byte
sequence. The two lists are readily distinguished by the number of syllables;
the even list has words of two syllables, the odd list has three.

=head1 SYNOPSIS

    use Encode::Wordlist::PGP qw(:all); # pgp_wordlist_encode(), pgp_wordlist_decode()
    
    my $fingerprint = "4155 9711 308F 2A21 B9D5  072D 6219 58AF CB50 B5F9"; # this is the author's GPG fingerprint
    
    print join(" ", pgp_wordlist_encode($fingerprint));
    
    my $text_version = qq(cranky equipment preshrunk Babylon chairlift
    midsummer brickyard Camelot sentence specialist ahead clergyman flagpole
    bottomless endorse pharmacy spheroid embezzle scorecard Waterloo);

    print pgp_wordlist_decode($text_version);
    
=head1 METHODS

=head2 pgp_wordlist_encode

    print join(" ", pgp_wordlist_encode($fingerprint));
    # prints something like "cranky equipment preshrunk Babylon chairlift midsummer brickyard Camelot [...]"

Takes a string, which may only contain the letters A-F, the digits 0-9, spaces,
and hyphens. Case-insensitive. Any spaces and hyphens (used to separate bytes
for human readability) will be stripped out before processing. Returns an
array of words. Hex bytes in the input must contain two digits each; method will
die if the input string contains an odd number of characters.

=head2 pgp_wordlist_decode

   print pgp_wordlist_decode($text_version);
   # prints something like "41559711308F2A21B9D5072D621958AFCB50B5F9"
   
Takes a string, which may only contain letters, spaces, hyphens, C<\r> and 
C<\n>. Case-insensitive. Hyphens and C<\r> and C<\n> will be converted to
spaces before processing; the number of spaces between each word does not
matter. Will die if a non-wordlist word is encountered, or a word has the
wrong number of syllables for its position (see ALGORITHM, above).

=head1 AUTHOR

Earle Martin <hex@cpan.org>

=head1 COPYRIGHT

This code is free software and is licensed under the same terms as the latest
released version of Perl itself. You may redistribute it and/or modify it
according to those conditions.

The encoding method in this module is derived from "fingerprint.pl" by Josh 
Larios (L<http://staff.washington.edu/jdlarios/fingerprint_pl.txt>).

Portions of this documentation are taken from the Wikipedia article "PGP word
list" (revision used available at L<http://xrl.us/pgpwordlist204668808>). This
documentation is licensed under the GNU Free Documentation License 
(L<http://www.gnu.org/copyleft/fdl.html>).

The word list itself is copyrighted under a copyright owned by PGP Corporation,
and licensed by them under the GNU Free Documentation License.

=head1 SEE ALSO

=over 4

=item * L<http://en.wikipedia.org/wiki/PGP_word_list>

=item * L<GnuPG::Fingerprint>

=item * L<Digest::BubbleBabble> - a similar concept for message digests

=item * L<Lingua::Alphabet::Phonetic>

=back

=cut