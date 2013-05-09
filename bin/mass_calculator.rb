#!/usr/bin/env ruby

require 'pry'

begin
  require 'mspire/molecular_formula'
rescue LoadError
  $LOAD_PATH << ENV['HOME'] + '/dev/mspire/lib'
  require 'mspire/molecular_formula'
end

require 'mspire/mass/aa'
require 'mspire/isotope/distribution'

include Mspire
MF = MolecularFormula
MONO = Mass::AA::MONO
AVG = Mass::AA::AVG

puts "MF = MolecularFormula"
puts "MONO/AVG = Mass::AA::MONO/AVG"
puts "MF.from_aaseq"
puts "MF['C2H5', +1]"
puts "formula.isotope_distribution"

binding.pry

