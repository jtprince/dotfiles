u:Gem::Specification|["
1.8.5i"ZenTestU:Gem::Version["
4.6.1u:	Time���    "TZenTest provides 4 different tools: zentest, unit_diff, autotest, and multirubyU:Gem::Requirement[[[">=U; ["0U;[[["~>U; ["1.8"	ruby[o:Gem::Dependency
:@requirementU;[[["~>U; ["2.4:@prereleaseF:@version_requirements@ :
@name"minitest:
@type:developmento;
;	U;[[["~>U; ["	2.10;
F;@*;"hoe;;"zentest["ryand-ruby@zenspider.com"drbrain@segment7.net["Ryan Davis"Eric Hodel"qZenTest provides 4 different tools: zentest, unit_diff, autotest, and
multiruby.

ZenTest scans your target and unit-test code and writes your missing
code based on simple naming rules, enabling XP at a much quicker
pace. ZenTest only works with Ruby and Test::Unit. Nobody uses this
tool anymore but it is the package namesake, so it stays.

unit_diff is a command-line filter to diff expected results from
actual results and allow you to quickly see exactly what is wrong.
Do note that minitest 2.2+ provides an enhanced assert_equal obviating
the need for unit_diff

autotest is a continous testing facility meant to be used during
development. As soon as you save a file, autotest will run the
corresponding dependent tests.

multiruby runs anything you want on multiple versions of ruby. Great
for compatibility checking! Use multiruby_setup to manage your
installed versions.")https://github.com/seattlerb/zentest0@[ 