module SetupHelper
  def teardown
    Repository.all.each do |r|
      unless r.full_repository_path =~ /^\/$/
        `rm -rf #{r.full_repository_path}`
      end
    end
  end
end