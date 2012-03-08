# This function contains methods
class Upload

  @@dictionary = {} # TODO: Either use this or get rid of it!
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
  # Input argument should be a file
  def initialize(file)
    @file = file
    @hash = Upload.hash_content(@file)
    store_file!
    @@dictionary[hash] = true # fixme, @@dictionary is used as a set for now
  end

  def self.hash_to_path(hash)
    File.join(UPLOADS_FOLDER, hash)
  end

  # Path to where the file will be stored
  def stored_path
    Upload.hash_to_path(@hash)
  end

  def store_file!
    FileUtils.mkdir_p(UPLOADS_FOLDER) # TODO: should only call once
    src = @file.path
    dest = stored_path
    FileUtils.cp(src, dest)
  end

  # Hash an open file, will also close file
  # Code taken from http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes#Ruby
  def self.hash_content(file)
    # Read 64 kbytes, divide up into 64 bits and add each
    # to hash. Do for beginning and end of file.
    filesize = file.size
    hash =  startValue(0) # fixme, deliberate failure, should be filesize
    # Q = unsigned long long = 64 bit
    file.read(CHUNK_SIZE).unpack("Q*").each do |n|
      hash = op(hash, n)
    end

    file.seek([0, filesize - CHUNK_SIZE].max, IO::SEEK_SET)

    # And again for the end of the file
    file.read(CHUNK_SIZE).unpack("Q*").each do |n|
      hash = op(hash, n)
    end
    file.close # close file
    hash.to_s
  end

  private

  # Functions used in the hashing algorithm
  #########################################

  def self.startValue(x)
    x
  end

  def self.op(x, y)
    x + y & 0xffffffffffffffff # to remain as 64 bit number
  end

end
