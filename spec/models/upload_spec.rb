require 'fakefs/spec_helpers'

describe Upload do
  include FakeFS::SpecHelpers

  # TODO: split out in many tests
  it "stores file and calcs correct hash" do
    Dir.mkdir "/tmp"
    file = File.open("/tmp/my_file", "w+")
    file.write "hello678" # Must be at least 8 characters
    file.rewind
    
    u = Upload.new (file)
    u.hash.should_not == "0"
    File.exists?("/tmp/my_file").should be_true # Should not delete file

    path = Upload.get(u.hash)
    File.exists?(path).should be_true

    Upload.erase(u.hash)
    Upload.get(u.hash).should be_nil
    File.exists?(path).should be_false
  end

  # TODO: test the hashing (and it's reverse functionality)
end
 