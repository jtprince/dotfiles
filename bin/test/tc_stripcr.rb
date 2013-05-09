require 'load_bin_path'
require 'fileutils'
require 'test/unit'


FILE_DIR = "tfiles/"
CMD = "ruby -S stripcr.rb "
FILE1 = FILE_DIR + "file_with_unix_dos_newlines.txt"
FILE2 = FILE_DIR + "file_with_unix_dos_newlines.txt.tmp"
FILE_ANSW = FILE_DIR + "file_with_unix_dos_newlines.txt.stripped"


class Mine < Test::Unit::TestCase

  def file_contents(file)
    File.open(file) {|fh| fh.binmode.read } 
  end

  def test_normal
    assert_match(/usage/, `#{CMD}`, "simple access of instructions")  
    FileUtils.copy FILE1, FILE2
    assert_not_equal(file_contents(FILE_ANSW), file_contents(FILE2))
    assert(file_contents(FILE2) =~ /\r/, "carriage returns in unstripped file")
    system "#{CMD} #{FILE2}" 
    assert(file_contents(FILE2) !~ /\r/, "no carriage returns in stripped file")
    assert_equal(file_contents(FILE_ANSW), file_contents(FILE2))
    assert_equal(File.stat(FILE2).mode, File.stat(FILE_ANSW).mode, "new file has same mode as previous file")
    assert_equal(File.stat(FILE2).uid, File.stat(FILE_ANSW).uid, "new file has same uid as previous file")
    assert_equal(File.stat(FILE2).gid, File.stat(FILE_ANSW).gid, "new file has same gid as previous file")
    File.unlink(FILE2)
  end

end
