u:Gem::Specificationp[I"1.8.24:ETiI"sinatra-synchrony; TU:Gem::Version[I"
0.3.2; TIu:	Time@�    :@_zoneI"UTC; TI"cBootstraps Sinatra with EM-Synchrony code, make TCPSocket EM-aware, provides support for tests; TU:Gem::Requirement[[[I">=; TU;[I"0; TU;	[[[I">=; TU;[I"
1.3.4; TI"	ruby; F[o:Gem::Dependency
:
@nameI"sinatra; T:@requirementU;	[[[I"~>; TU;[I"1.0; T:
@type:runtime:@prereleaseF:@version_requirementsU;	[[[I"~>; TU;[I"1.0; To;

;I"rack-fiber_pool; T;U;	[[[I"~>; TU;[I"0.9; T;;;F;U;	[[[I"~>; TU;[I"0.9; To;

;I"eventmachine; T;U;	[[[I"~>; TU;[I"1.0.0.beta.4; T[I"<; TU;[I"1.0.0.beta.100; T;;;F;U;	[[[I"~>; TU;[I"1.0.0.beta.4; T[I"<; TU;[I"1.0.0.beta.100; To;

;I"em-http-request; T;U;	[[[I"~>; TU;[I"1.0; T;;;F;U;	[[[I"~>; TU;[I"1.0; To;

;I"em-synchrony; T;U;	[[[I"~>; TU;[I"
1.0.1; T;;;F;U;	[[[I"~>; TU;[I"
1.0.1; To;

;I"em-resolv-replace; T;U;	[[[I"~>; TU;[I"1.1; T;;;F;U;	[[[I"~>; TU;[I"1.1; To;

;I"	rake; T;U;	[[[I">=; TU;[I"0; T;:development;F;U;	[[[I">=; TU;[I"0; To;

;I"rack-test; T;U;	[[[I"~>; TU;[I"0.5; T;;;F;U;	[[[I"~>; TU;[I"0.5; To;

;I"
wrong; T;U;	[[[I"~>; TU;[I"0.5; T;;;F;U;	[[[I"~>; TU;[I"0.5; To;

;I"minitest; T;U;	[[[I">=; TU;[I"0; T;;;F;U;	[[[I">=; TU;[I"0; TI"sinatra-synchrony; T[I"kyledrake@gmail.com; T[I"Kyle Drake; TI"Bootstraps in code required to take advantage of EventMachine/EM-Synchrony's concurrency enhancements for slow IO. Patches TCPSocket, which makes anything based on it EM-aware (including RestClient). Includes patch for tests. Requires Fibers (Ruby 1.9, JRuby and Rubinius in 1.9 mode); TI"3https://github.com/kyledrake/sinatra-synchrony; TT@[ 