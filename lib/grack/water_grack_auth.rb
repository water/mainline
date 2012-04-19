require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'
require 'rack/auth/basic'
require "colorize"
require File.expand_path("../../../config/environment", __FILE__)

class WaterGrackAuth < Rack::Auth::Basic

  #
  # @lhg LabHasGroup
  # @return Boolean Does the user exists 
  #   and can one push to the given repository
  #
  def authorized?(lab_has_group)
    return false unless current_user
    return lab_has_group.
      lab_group.
      students.
      map(&:user).
      include?(current_user)
  end

  #
  # @message String Message to be send to user 
  #
  def halt(message)
    $stderr.puts "Halt!: #{message}".red
  end

  def call(env)
    @env = env

    path_info = env["PATH_INFO"]

    values = {}
    path_info.scan(%r{\w+/\d+}) do |match| 
      res = match.split("/")
      values.merge!(res.first.to_sym => res.last.to_i)
    end

    # values => {:courses=>1, :lab_groups=>3, :labs=>1}
    # The code below should use all 3 of the pattern matched values.
    lab = Lab.
      includes({
        lab_has_groups: :repository
      }).
      where("labs.given_course_id = ?", values[:courses]).
      find_by_number(values[:labs])

    unless lab
      halt("Lab not found")
      return bad_request
    end

    unless lhg = lab.lab_has_groups.first
      halt("Lab has group not found")
      return bad_request
    end

    unless repository = lhg.repository
      halt("Repository not found")
      return bad_request
    end

    env["PATH_INFO"] = path_info.gsub(/^.*\.git/, repository.hashed_path + ".git")

    @req = Rack::Request.new(env)

    return unauthorized unless auth.provided?
    return bad_request unless auth.basic?
    return unauthorized unless authorized?(lhg)

    # env['REMOTE_USER'] = auth.username
    before = submit_commits_for(repository) if pushed?
    status = @app.call(env)
    after = submit_commits_for(repository) if pushed?

    if pushed?# and before != after
      after.each do |hash|
      # (after - before).each do |hash|
        submission = Submission.create({
          lab_has_group: lhg,
          commit_hash: hash
        })

        if submission.id
          puts hash.green
        end
      end
    end

    return status
  end

  #
  # @return User
  #
  def current_user
    login, password = auth.credentials[0,2]
    User.authenticate(login, password)
  end

  #
  # @return Boolean
  #
  def pushed?
    true #!! @env["REQUEST_PATH"].match(/git-receive-pack/)
  end

  #
  # @return Array<String> A list of commit hashes
  #
  def submit_commits_for(repository)
    Dir.chdir(repository.full_repository_path) do
      `git log master --grep "#submit" --format="%H"`.split("\n")
    end
  end

  def auth
    Request.new(@env)
  end

  # Could be useful
  # TODO: Remove unless neccesary
  def get_project
    paths = ["(.*?)/git-upload-pack$", "(.*?)/git-receive-pack$", "(.*?)/info/refs$", "(.*?)/HEAD$", "(.*?)/objects" ]

    paths.each {|re|
      if m = Regexp.new(re).match(@req.path)
        projPath = m[1];
        dir  = projPath.gsub(/^.*\//, "")
        identifier = dir.gsub(/\.git$/, "")
        return (identifier == '' ? nil : identifier)
      end
    }

    return nil
  end

end

