# This function contains methods
class Upload

	@@dictionary = {}
	CHUNK_SIZE = 64 * 1024 # in bytes

	# Try to store a temporary file, if validations pass a hash
	# containing an :id will be returned
	def self.store(tempfile)
		hash = Upload.hash_content(tempfile)
	    tempfile.close(false) # close file without deleting it
		@@dictionary[hash] = tempfile
		extra = {
			local_path: tempfile.path # TODO: TO BE REMOVED
		}
		{status: :ok, id: hash, extra: extra}
	end

	# Hash an open tempfile
	# Code taken from http://trac.opensubtitles.org/projects/opensubtitles/wiki/HashSourceCodes#Ruby
	def self.hash_content(tempfile)
		# Read 64 kbytes, divide up into 64 bits and add each
	    # to hash. Do for beginning and end of file.
	    hash = 0
	    filesize = tempfile.size
	    tempfile 
	    # Q = unsigned long long = 64 bit
	    tempfile.read(CHUNK_SIZE).unpack("Q*").each do |n|
	      hash = hash + n & 0xffffffffffffffff # to remain as 64 bit number
	    end

	    tempfile.seek([0, filesize - CHUNK_SIZE].max, IO::SEEK_SET)

	    # And again for the end of the file
	    tempfile.read(CHUNK_SIZE).unpack("Q*").each do |n|
	      hash = hash + n & 0xffffffffffffffff
	    end
	    hash
	end

	# Returns a Tempfile if found, nil otherwise
	def self.get(hash)
		@@dictionary[hash]
	end

	# Erasing the file is it is available
	def self.erase(hash)
		tempfile = @@dictionary.delete hash
		tempfile.close! unless tempfile.nil?
	end
end
