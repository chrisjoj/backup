class BackupFile
  attr_accessor :file_name, :file_digest, :file_path

  def initialize (file_name, file_digest, file_path)
    @file_name = file_name
    @file_path = file_path
    @file_digest = file_digest
  end

  def has_key?

  end
end