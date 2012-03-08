# This function contains methods
class Upload

  @@dictionary = {}
  CHUNK_SIZE = 64 * 1024 # in bytes
  UPLOADS_FOLDER = File.join(Rails.root, "tmp/uploads")

  ### Functions to be used by others
  #######################################
  # Returns a path if found, nil otherwise
  def self.get(hash)
    return nil unless @@dictionary.member? hash
    hash_to_path(hash)
  end

  # Erasing the file is it is available
  def self.erase(hash)
    FileUtils.rm hash_to_path(hash) if @@dictionary.delete hash
  end

  ### Functions to be used by controller and model internals
  #######################################
  attr_reader :hash

  # The object created is of little importance, the hash will be
  # useful even after the objects lifetime
  def initialize(file)
    @file = file
    @hash = Upload.hash_content(file.tempfile)
    store_tempfile
    @@dictionary[hash] = true # fixme, @@dictionary is used as a set for now
  end

  def self.hash_to_path(hash)
    File.join(UPLOADS_FOLDER, hash)
  end

  def path
    Upload.hash_to_path(@hash)
  end

  def store_tempfile
    tempfile = @file.tempfile
    FileUtils.mkdir_p(UPLOADS_FOLDER) # TODO: should only call once
    tempfile.close(false) # close file without deleting it
    src = tempfile.path
    dest = path
    FileUtils.mv(src, dest)
    tempfile.unlink
  end

  # Hash an open tempfile
  # Code taken from http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes#Ruby
  def self.hash_content(tempfile)
    # Read 64 kbytes, divide up into 64 bits and add each
    # to hash. Do for beginning and end of file.
    filesize = tempfile.size
    hash = filesize
    # Q = unsigned long long = 64 bit
    tempfile.read(CHUNK_SIZE).unpack("Q*").each do |n|
      hash = hash + n & 0xffffffffffffffff # to remain as 64 bit number
    end

    tempfile.seek([0, filesize - CHUNK_SIZE].max, IO::SEEK_SET)

    # And again for the end of the file
    tempfile.read(CHUNK_SIZE).unpack("Q*").each do |n|
      hash = hash + n & 0xffffffffffffffff
    end
    hash.to_s
  end


end
