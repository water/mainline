module ExistenceOfCommitHashValidation
  #
  # Does the given commit {commit_hash} exist?
  #
  def existence_of_commit_hash
    path = repository.try(:full_repository_path) if repository
    Dir.chdir(path) do
      unless system "git rev-list HEAD..#{commit_hash}"
        errors[:commit_hash] << "does not exist"
      end
    end if path and File.exists?(path)
  end
end