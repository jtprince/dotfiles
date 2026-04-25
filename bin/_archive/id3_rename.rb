#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require 'optparse'
require 'find'

begin ; require 'id3lib'
rescue LoadError
  puts( (ast = "*" * 50), "sudo apt-get install libid3-dev", "gem install id3lib-ruby", ast, $! ) || exit
end

GENRE_CODES = YAML.load(DATA)

MAX_LENGTHS = { title: 30, album: 30, artist: 30, comment: 28 }

def display(tag, tags_to_show, as_yaml=false)
  if as_yaml
    hash = OrderedHash.new
    tags_to_show.each do |field|
      hash[field] = tag.send(field.to_sym)
    end
    puts hash.to_yaml
  else
    tags = tags_to_show.map do |field|
      value = tag.send(field.to_sym)
      "#{field}: \"#{tag.send(field.to_sym)}\""
    end
    puts tags.join(" ")
  end
end

## Conductor should be part of album!!!!  e.g,  'Mass in B Minor - JEG'
##                                        e.g,  'Mass in B Minor - Herreweghe'

$VERBOSE = nil
opt = {}

STANDARD_TAGS = %w(track title artist album year genre comment)

OPT_CHECK_DEFAULT_NUM_TAGS = 1
opt[:string_delimiter] = '-'
opt[:album_conductor_delim] = ' - '
opt[:delimiter] = '_?-_?'
opt[:order] = %w(track title artist album)
opt[:order_classical] = %w(track title album conductor composer)
opt[:replacements] = []
opt[:version] = 2
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [OPTIONS] topdir ..."
  op.separator "** if only '%' is given, then uses auto generated value from track name"
  op.separator " %n=track  %r=artist  %a=album  %t=title  %y=year  (use current values)"
  op.separator " (no recursive definitions currently)"
  op.separator "%%n=track %%r=artist %%a=album %%t=title %%y=year  (use calculated values)"
  op.on("-v", "--version <1|2>", Integer, "use version 1 or 2[default]") {|v| opt[:version] = v }
  op.on("-d", "--delimiter <regexp>", "change file delimiter from default: #{opt[:delimiter]}") {|v| opt[:delimiter] = v }
  op.on("-t", "--title <title>", "set title") {|v| opt[:title] = v }
  op.on("-a", "--album <album>", "set album") {|v| opt[:album] = v }
  op.on("-r", "--artist <artist>", "set artist") {|v| opt[:artist] = v }
  op.on("-y", "--year <year>", "set year") {|v| opt[:year] = v }
  op.on("-n", "--track <Int>", "set track number; AUTO|ALPHA") {|v|
    case v
    when /%|AUTO|ALPHA/
      opt[:track] = v
    else
      opt[:track] = v.to_i
    end
  }
  op.on("--track-fn", "transfers track tag to filename (renames file)") {|v| opt[:track_fn] = v }
  op.on("-g", "--genre <Int>", Integer, "set genre code (classical: 32)") {|v| opt[:genre] = v }
  op.on("-c", "--comment <string>", "comments") {|v| opt[:comment] = v }
  op.on("--genre-codes", "prints genre codes and exits") {|v| opt[:genre_codes] = v }
  op.on("--dry", "a dry run (no changes)") {|v| opt[:dry] = v; $VERBOSE = 3 }
  op.on("-o", "--order <comma_array>", Array, "#{opt[:order].join(',')}",
                                              "if 'c', #{opt[:order_classical].join(',')}",
                                              "artist = composer; album = 'album - conductor'") {|v|
    if v == ['c']
      opt[:order] = opt[:order_classical]
    else
      opt[:order] = v
    end
  }

  op.on("--delete", "deletes tags") {|v| opt[:delete] = v }
  op.on("--v2-to-v1", "transfers applicable v2 tags to v1") {|v| opt[:v2_to_v1] = v }
  op.on("--v1-to-v2", "transfers applicable v1 tags to v2") {|v| opt[:v1_to_v2] = v }
  op.on("--replace <from,to>", Array, "replaces <from> to <to> (multiple) for auto purposes") {|v| opt[:replacements].push v }
  op.on("--mesh <index,length>", Array, "start and length of parts to merge") {|v| opt[:mesh] = v.map{|num| num.to_i} }
  op.on("--view", "see id3 tags and exit") {|v| opt[:view] = v }
  op.on("--view-yaml", "outputs the id3 tags as yaml and exits") {|v| opt[:view_yaml] = v }
  op.on("--check [N]", "warns if file has less than N tags") do |v|
    if v.is_a?(String)
      opt[:check] = v.to_i
    else
      opt[:check] = OPT_CHECK_DEFAULT_NUM_TAGS
    end
  end
  op.on("--verbose", "messages") { $VERBOSE = 3 }
  # NEED TO IMPLEMENT THIS:
  # op.on("--renumber-files", "renames file track numbers 1 -> 01 & exits", "[this is a file renaming operation]") {|v| opt[:renumber_files] = v }
end

opts.parse!

if opt[:genre_codes]
  GENRE_CODES.sort.each do |k,v|
    puts "#{k}: #{v}"
  end
  exit
end

if ARGV.size == 0
  puts opts.to_s
  exit
end





case opt[:version]
when 1 then version_const = ID3Lib::V1
when 2 then version_const = ID3Lib::V2
end


if opt[:version] == 1
  too_long = []
  MAX_LENGTHS.each do |k,mx|
    if opt[k] && opt[k].length > mx
      too_long << [k,mx, opt[k], opt[k].size]
    end
  end
  if too_long.size > 0
    p too_long
    abort "Those entries are too long!!!"
  end
end



dirs = ARGV.to_a

files = []
Find.find(*dirs) do |path|
  if !FileTest.directory?(path) && path =~ /\.mp3$/i
    files.push path
  end
end
files.sort! unless opt[:track] == 'AUTO'

if opt[:renumber_files]
  files.each do |path|
    if path =~ /^\d-/
      newname = "0" + path
      FileUtils.mv path, newname
    end
  end
  exit
end

if opt[:view] || opt[:view_yaml]
  files.each do |path|
    tag = ID3Lib::Tag.new(path, version_const)
    display(tag, STANDARD_TAGS, opt[:view_yaml])
  end
  exit
end


if opt[:check]
  few_tags = files.select do |path|
    tag = ID3Lib::Tag.new(path, version_const)
    vals = STANDARD_TAGS.map {|t| tag.send(t.to_sym) }
    vals.compact.size < opt[:check]
  end
  if few_tags.size > 0
    puts "files with < #{opt[:check]} tags:"
    puts few_tags.join("\n")
  else
    puts "all files have >= #{opt[:check]} tags!"
  end
end

## pre test to confirm same number of suggested stuff:
parts_sizes = Hash.new {|h,k| h[k] = [] }
files.each do |path|
  parts_sizes = Hash.new {|h,k| h[k] = [] }
  basename = File.basename(path)
  if opt[:replacements].size > 0
    opt[:replacements].each do |pair|
      (from, to) = pair
      basename.gsub!(Regexp.new(Regexp.escape(from)), to)
    end
  end
  parts_sizes[basename.gsub('_', ' ').sub(/\.mp3/i, '').split(Regexp.new(opt[:delimiter])).size].push( path )
end

if parts_sizes.size > 1
  #keys = parts_sizes.keys.sort.reverse
  keys = parts_sizes.keys.sort
  #keys.shift
  keys.each do |key|
    parts_sizes[key].each do |guy|
      puts "#{key}: #{guy}"
    end
  end
  abort "EXITING!"
end


files.each_with_index do |path, index|
  basename = File.basename(path)
  if opt[:replacements].size > 0
    opt[:replacements].each do |pair|
      (from, to) = pair
      basename.gsub!(Regexp.new(Regexp.escape(from)), to)
    end
  end
  parts = basename.gsub('_', ' ').sub(/\.mp3/i, '').split(Regexp.new(opt[:delimiter]))
  if opt[:mesh]
    (start,length) = opt[:mesh]
    parts[start] = parts[start,length].join(opt[:string_delimiter])
    (start+length-1).downto(start+1) do |i|
      parts.delete_at(i)
    end
  end

  default_vals = {}
  opt[:order].zip(parts) do |order,part|
    if part && order
      default_vals[order] = part[0..30]
    end
  end

  # transform classical stuff into normal
  if default_vals.include?('composer')
    default_vals['artist'] = default_vals.delete("composer")
  end
  if default_vals.include?('conductor')
    default_vals['album'] = [default_vals['album'], default_vals.delete('conductor')].join(opt[:album_conductor_delim])
  end
  if default_vals.include?('track')
    if default_vals['track'] =~ /[^\d]/
      default_vals['track'] = (index + 1).to_s
    end
  end

  original_tag = ID3Lib::Tag.new(path, version_const)
  tag = ID3Lib::Tag.new(path, version_const)
  tag_to_transfer = if opt[:v2_to_v1]
                      ID3Lib::Tag.new(path, ID3Lib::V2)
                    elsif opt[:v1_to_v2]
                      ID3Lib::Tag.new(path, ID3Lib::V1)
                    end
    %w(track album artist title genre year comment).each do |guy|
      guy_sym = guy.to_sym
      if opt.key? guy_sym
        to_set =
          if opt[guy_sym] == '%'
            default_vals[guy]
          elsif guy_sym == :track && opt[:track][0,1] == 'A'
            index + 1
          else
            opt[guy_sym]
          end
        # casting
        to_set =
          case guy
          when 'track'
            to_set.to_i
          when 'genre'
            "(#{to_set})"
          else
            to_set
          end
        tag.send("#{guy}=".to_sym, to_set)
      elsif tag_to_transfer
        tag.send("#{guy}=".to_sym, tag_to_transfer.send(guy.to_sym))
      end
    end

    ## replace the %n %t %r %a %y tags
    # These use the current values
    #replace_special_chars(tag, tag)

    ## replace the %%n %%t %%r %%a %%y tags
    # These use the original values
    #replace_special_chars(tag, original_tag)

    display(tag, STANDARD_TAGS) if $VERBOSE
    if opt[:dry]
      if opt[:delete]
        puts "would strip tag!" if $VERBOSE
      end
      puts "[dry run]"
    else
      tag.update!
      if opt[:delete]
        ID3Lib::Tag.new(path, version_const).strip!
        puts "stripped tag!" if $VERBOSE
      end
    end
end

#CURRENT = %w{n t r a y}

#def replace_special_chars(to_replace, replace_from)
#end


__END__
---
{ 0: Blues, 1: Classic Rock, 2: Country, 3: Dance, 4: Disco, 5: Funk, 6: Grunge, 7: Hip-Hop, 8: Jazz, 9: Metal, 10: New Age, 11: Oldies, 12: Other, 13: Pop, 14: R&B, 15: Rap, 16: Reggae, 17: Rock, 18: Techno, 19: Industrial, 20: Alternative, 21: Ska, 22: Death Metal, 23: Pranks, 24: Soundtrack, 25: Euro-Techno, 26: Ambient, 27: Trip-Hop, 28: Vocal, 29: Jazz+Funk, 30: Fusion, 31: Trance, 32: Classical, 33: Instrumental, 34: Acid, 35: House, 36: Game, 37: Sound Clip, 38: Gospel, 39: Noise, 40: AlternRock, 41: Bass, 42: Soul, 43: Punk, 44: Space, 45: Meditative, 46: Instrumental Pop, 47: Instrumental Rock, 48: Ethnic, 49: Gothic, 50: Darkwave, 51: Techno-Industrial, 52: Electronic, 53: Pop-Folk, 54: Eurodance, 55: Dream, 56: Southern Rock, 57: Comedy, 58: Cult, 59: Gangsta, 60: Top 40, 61: Christian Rap, 62: Pop/Funk, 63: Jungle, 64: Native American, 65: Cabaret, 66: New Wave, 67: Psychadelic, 68: Rave, 69: Showtunes, 70: Trailer, 71: Lo-Fi, 72: Tribal, 73: Acid Punk, 74: Acid Jazz, 75: Polka, 76: Retro, 77: Musical, 78: Rock & Roll, 79: Hard Rock, 80: Folk, 81: Folk-Rock, 82: National Folk, 83: Swing, 84: Fast Fusion, 85: Bebob, 86: Latin, 87: Revival, 88: Celtic, 89: Bluegrass, 90: Avantgarde, 91: Gothic Rock, 92: Progressive Rock, 93: Psychedelic Rock, 94: Symphonic Rock, 95: Slow Rock, 96: Big Band, 97: Chorus, 98: Easy Listening, 99: Acoustic, 100: Humour, 101: Speech, 102: Chanson, 103: Opera, 104: Chamber Music, 105: Sonata, 106: Symphony, 107: Booty Bass, 108: Primus, 109: Porn Groove, 110: Satire, 111: Slow Jam, 112: Club, 113: Tango, 114: Samba, 115: Folklore, 116: Ballad, 117: Power Ballad, 118: Rhythmic Soul, 119: Freestyle, 120: Duet, 121: Punk Rock, 122: Drum Solo, 123: A capella, 124: Euro-House, 125: Dance Hall }
---
