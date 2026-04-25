#!/usr/bin/env ruby

require 'optparse'

parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} 'equation' ..."
  op.separator "'" + %q{2NH4+ 3ATP^4- <-> urea + 4P_{i}^2- + 2H+} + "'"
  op.separator "see mchem package for details"
  op.on("-l", "--list", "show required latex packages")
end
parser.parse!

if ARGV.size == 0
  puts parser
  exit
end

PREAMBLE = %q{
\documentclass[letterpaper,10pt]{article}
\usepackage{fontspec}
\newcommand{\eq}[1]{\ensuremath{\mathrm{#1}}}
\usepackage[version=3]{mhchem}
\usepackage[landscape,margin=0.5in]{geometry}
% \listfiles   % <- use to see what files are needed (check log file!)
}

def document(lines)
  [PREAMBLE, %q{\begin{document}}, lines, %q{\end{document}}].join("\n")
end

def ce(text)
  "\\ce{#{text}}"
end

lines = ARGV.map do |equation|
  ce(equation) + %q{ \\\\}
end

puts document(lines.join("\n"))

puts "(need to automate this last stuff!!!)"
puts "latexmk -pdf -xelatex <ce.tex>"
puts "latexmk -pdf -xelatex -c <ce.tex>"

# \ce{2NH4+ + HCO3- + 3ATP^4- + H2O -> urea + 2ADP^3- + 4P_{i}^2- + AMP^2- + 2H+}
