#!/usr/bin/env ruby

require 'optparse'

def run(cmd)
  puts cmd
  STDOUT.flush
  system cmd
end

opt = {
  :scripture => false,
  :converter => "ocrad",
  :run_imagemagick => false,
  :blur => 3,
  :threshold => 65,
  :dpi => 300,
}

opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <file>.pdf ..."
  op.separator "outputs: <file>.txt"
  op.on("-c", "--converter <#{opt[:converter]}>", "ocrad|gocr|tesseract") {|v| opt[:converter] = v }
  op.separator ""
  # incompatible with --im at the moment  
  op.on("--scripture", "use settings for scanned scripture (tesseract)") {|v| opt[:scripture] = v ; opt[:converter] = 'tesseract' }
  op.on("--im", "run imagemagick (despeckle/blur/threshold)") {|v| opt[:run_imagemagick] = v }
  op.on("-b", "--blur <#{opt[:blur]}>", "blur width") {|v| opt[:blur] = v }
  op.on("-t", "--threshold <#{opt[:threshold]}>", "b/w thresholding") {|v| opt[:threshold] = v }
  op.on("-d", "--dpi <#{opt[:dpi]}>", "dpi of the original scan") {|v| opt[:dpi] = v }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

num_included = []
ARGV.each do |file|
  to_unlink = []
  base = file.chomp(File.extname(file))
  basetxt = base + ".txt"
  run "pdfimages #{file} #{base}"
  glob = base + "-*" + ".p*m"
  image_files = Dir[glob].sort
  to_unlink.push(*image_files)
  newimages = 
    if opt[:run_imagemagick]
      newimages = image_files.map do |image_file|
        base_image_file = image_file.chomp(File.extname(image_file))
        new_image_file = base_image_file + ".cleaned.pbm"
        run "convert -threshold #{opt[:threshold]}% -blur #{opt[:blur]} -despeckle -density #{opt[:dpi]}X#{opt[:dpi]} #{image_file} #{new_image_file}"
        new_image_file
      end
    elsif opt[:scripture]
      # remove the little google digital mark
      (real_images, digital_marks) = image_files.partition {|f| File.size(f) > 29000 }
      digital_marks.each {|f| puts "removing digital mark file: #{f}" ; File.unlink(f) }
      real_images
    else
      image_files
    end
  to_unlink.push(*newimages)
  text = 
    case opt[:converter]
    when /ocrad|gocr/
      newimages.map do |image|
      `#{opt[:converter]} #{image}`
      end.join("\n")
    when 'tesseract'
      tif_files = newimages.map {|f| tif = f.sub(/\.p\wm/,'.tif') ; `convert #{f} #{tif}` ; tif }
      txt_files = tif_files.map {|tif| base = tif.chomp(File.extname(tif)) ; `tesseract #{tif} #{base}` ; base + ".txt" }
      to_unlink.push(*tif_files).push(*txt_files)
      txt_files.map {|f| IO.read(f) }.join("\n")
    end
  File.open(basetxt,'wb') {|out| out.print text }
  to_unlink.each {|v| File.unlink(v) if File.exist?(v) } 
end
