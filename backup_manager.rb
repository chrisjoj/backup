require 'digest'
require 'mongo'
require_relative  'backup_file'
include Mongo

class BackupManager
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

  def record_checksums
    #digests = Hash.new
    @listing.keys.each { |dir|
      @listing[dir].each { | file |
        digest = Digest::MD5.hexdigest(File.open(dir + "/" + file).read)
        #puts "File " << (dir + "/" + file) << " : " << digest
        #digests[digest] == nil ? digests[digest] = [dir + "/" + file] : digests[digest] << (dir + "/" + file )
        file_data = { :file_name => file, :file_path => dir, :file_digest => digest }
        @backups.insert(file_data)
      }
    }
    puts digests.inspect
  end

  def run(path, backup_dir)
    db = Connection.new.db('backup')
    @backups = db.collection('file_hashes')
    @listing = Hash.new
    find_eligible_files(path)
    record_checksums
    puts @back.file_hashes.find()
  end

  if __FILE__ == $0
    x     = BackupManager.new
    start = Time.now
    x.run(PATH, BACKUP_DIR)
    puts Time.now - start
  end
end