require 'fileutils'
require 'parallel'

class Backup
  PATH       = "c:/users/lockerc/downloads"
  BACKUP_DIR = "c:/users/lockerc/downloads2/"

  attr_reader :listing

  def find_eligible_files(path)
    top_level_listing = Dir.entries(path)
    listing           = Array.new
    dirs              = Array.new
    top_level_listing.each { |i|
      if (i == "." || i == "..")
        next
      end
      if (File.directory?(path + "/" + i))
        dirs << i
      else
        listing << i
      end
    }
    @listing[path] = listing
    dirs.each { |i|
      find_eligible_files(path + "/" + i + "/")
    }
  end

  def copy_to_backup_dir(backup_dir)
    #@listing.keys.each { |dir|
    Parallel.each(@listing.keys, :in_threads => 5) { |dir|
      FileUtils.mkdir_p(backup_dir + strip_path(dir))
      #@listing[dir].each { |key|
      Parallel.each(@listing[dir], :in_threads => 5) { |key|
        from_file = dir + "/" + key
        to_file   = backup_dir + strip_path(dir) + key

        if File.readable?(from_file)
          FileUtils.copy(from_file, to_file)
        end
      }
    }
  end

  def backup(path, backup_dir)
    @listing = Hash.new
    find_eligible_files(path)
    copy_to_backup_dir(backup_dir)
    puts @listing.keys
  end

  def strip_path(path)
    short_path = path[PATH.length, path.length]
    short_path
  end

  if __FILE__ == $0
    x     = Backup.new
    start = Time.now
    x.backup(PATH, BACKUP_DIR)
    puts Time.now - start
  end
end