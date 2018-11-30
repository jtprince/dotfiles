#!/usr/bin/env -S ruby -W0
# we turn off warnings because we are chdir'ing inside a chdir block and ruby
# is not happy about that, even though it allows it.
# see usage block way down below for usage

def basename_dir
  File.basename(Dir.pwd)
end

def move_up_dir
  Dir.chdir("../")
end

def pwd_is_src_dir?
  basename_dir == 'src'
end

def pwd_is_action_wrapper_dir?
  basename_dir.start_with?("_")
end

# assumes you are in src dir
def get_directory_above_src()
  Dir.pwd.split('/')[-2]
end

def in_specific_action_dir?
  pwd_is_action_wrapper_dir? || pwd_is_src_dir?
end

def get_path_and_move_above_it
  move_up_dir if pwd_is_src_dir?
  path = basename_dir
  move_up_dir
  path
end

def display_created_zip_files(zip_files)
  if zip_files.size > 0
    border = -> { puts "=" * 70 }
    border.()
    puts "CREATED!"
    border.()
    puts zip_files.join("\n")
  end
end

# Whatever conditions for a valid src dir
POTENTIAL_SRC_PROBLEMS = [
  {
    condition: -> { !pwd_is_src_dir? },
    message: "Couldn't find the src directory! (cd into it or give arg!)",
  },
  {
    condition: -> { Dir["_*.json"].size > 1 },
    message: "Multiple feed definition files!",
  },
  {
    condition: -> { Dir["_*.json"].size == 0 },
    message: "Missing feed definition file!",
  },
  {
    condition: -> { Dir["_*.json"].first.sub('.json', '') != File.absolute_path(Dir["_*.json"].first).split("/")[-3]},
    message: "Feed definition file must match the enclosing folder name!",
  },

]

# Assumes in the action wrapper dir
def make_zip_file
  action_dir = basename_dir
  begin
    Dir.chdir("src") rescue "Missing the 'src' directory!"

    POTENTIAL_SRC_PROBLEMS.each do |potential_problem|
      raise potential_problem[:message] if potential_problem[:condition].()
    end

    zip_filename =  "#{get_directory_above_src}.zip"

    # only zips up files under git control
    `zip #{zip_filename} \`git ls-files . | tr '\n' ' '\``

    full_zipfilename = File.join(Dir.pwd, zip_filename)
    `mv #{full_zipfilename} ../`

    parts = full_zipfilename.split('/')
    new_filename = parts.reverse.reject {|part| part == 'src' }.reverse.join("/")
    new_filename
  rescue Exception => exc
    # Control the output of any error messages here
    puts "==> Error in #{action_dir} #{exc}"
    nil
  end
end

def ensure_paths(provided_paths)
  if provided_paths.size == 0
    if in_specific_action_dir?
      [get_path_and_move_above_it]
    else
      action_dirs = Dir["_*"].select {|fn| File.directory?(fn) }
      if action_dirs.size == 0
        raise "No action dirs found!  Are you close to your action dirs beginning with '_'?"
      end
      action_dirs
    end
  else
    provided_paths
  end
end

if ["-h", "--help"].include?(ARGV[0])
  progname = File.basename(__FILE__)
  puts "usage: #{progname} [path] [...]"
  puts
  puts "zips up src dirs meeting conditions"
  puts "    and displays any errors and files generated"
  puts
  puts "valid usage:"
  puts
  puts "# inside top level action directory, an action directory, or a src dir"
  puts "# will do the right thing (zip up the dir or dirs in scope)"
  puts "    #{progname}"
  puts
  puts "# can also provide paths to action dirs (e.g.)"
  puts "    #{progname} _my_action_dir _another_action_dir"
  exit
end

paths = ARGV.to_a.dup

paths_ensured = ensure_paths(paths)

zip_files = paths_ensured.map do |path|
  Dir.chdir(path) { make_zip_file }
end.compact

display_created_zip_files(zip_files)
