u:Gem::Specification[[I"1.8.12:ETiI"ZenTest; TU:Gem::Version[I"
4.8.0; TIu:	Time��    :@_zoneI"UTC; TI"TZenTest provides 4 different tools: zentest, unit_diff, autotest, and multiruby; TU:Gem::Requirement[[[I">=; TU;[I"0; TU;	[[[I"~>; TU;[I"1.8; TI"	ruby; F[o:Gem::Dependency
:
@nameI"minitest; T:@requirementU;	[[[I"~>; TU;[I"	2.12; T:
@type:development:@prereleaseF:@version_requirements@"o;

;I"	rdoc; T;U;	[[[I"~>; TU;[I"	3.10; T;;;F;@,o;

;I"hoe; T;U;	[[[I"~>; TU;[I"3.0; T;;;F;@6I"zentest; T[I"ryand-ruby@zenspider.com; TI"drbrain@segment7.net; T[I"Ryan Davis; TI"Eric Hodel; TI"�ZenTest provides 4 different tools: zentest, unit_diff, autotest, and
multiruby.

zentest scans your target and unit-test code and writes your missing
code based on simple naming rules, enabling XP at a much quicker pace.
zentest only works with Ruby and Minitest or Test::Unit. There is
enough evidence to show that this is still proving useful to users, so
it stays.

unit_diff is a command-line filter to diff expected results from
actual results and allow you to quickly see exactly what is wrong.
Do note that minitest 2.2+ provides an enhanced assert_equal obviating
the need for unit_diff

autotest is a continous testing facility meant to be used during
development. As soon as you save a file, autotest will run the
corresponding dependent tests.

multiruby runs anything you want on multiple versions of ruby. Great
for compatibility checking! Use multiruby_setup to manage your
installed versions.; TI")https://github.com/seattlerb/zentest; TT@[ 