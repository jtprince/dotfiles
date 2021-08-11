#!/usr/bin/env ruby

require 'mspire/mzml'


def get_spectrum_summary(spectrum)
  mzs = spectrum.mzs
  intensities = spectrum.intensities

  {
    "rt (sec)": spectrum.retention_time,
    "first_pair": [mzs[0], intensities[0]],
    "last_pair": [mzs[-1], intensities[-1]],
  }
end

def get_spectrum_summaries(mzml_file)
  summaries = Mspire::Mzml.foreach(mzml_file).map do |spectrum|
    get_spectrum_summary(spectrum)
  end
end


if __FILE__ == $0
  mzml_file = ARGV[0]
  start_time = Time.now
  summaries = get_spectrum_summaries(mzml_file)
  elapsed = Time.now - start_time
  puts "Internal elapsed: #{elapsed}"
  puts "spectrum  0: ", summaries[0]
  puts "spectrum -1: ", summaries[-1]
end
