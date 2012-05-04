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

# We want to do auth things first
    @req = Rack::Request.new(env)

    return unauthorized unless auth.provided?
    return bad_request unless auth.basic?

    path_info = env["PATH_INFO"]
    values = {}
    # /courses/1/lab_groups/3/labs/2 => {:courses=>1, :labs=>2, :lab_groups=>3}
    path_info.scan(%r{\w+/\d+}) do |match|
      res = match.split("/")
      values.merge!(res.first.to_sym => res.last.to_i)
    end

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

    lab_group = LabGroup.
      where("lab_groups.given_course_id = ?", values[:courses]).
      find_by_number(values[:lab_groups])

    unless lab_group
      halt("Lab group not found")
      return bad_request
    end

# TODO: Fix most inefficient query ever
    lab_has_groups = lab_group.lab_has_groups & lab.lab_has_groups
    lab_has_group = lab_has_groups.first

    unless lab_has_group 
      halt("Lab has group not found")
      return bad_request
    end

    unless repository = lab_has_group.repository
      halt("Repository not found")
      return bad_request
    end

    env["PATH_INFO"] = path_info.gsub(/^.*\.git/, "/" + repository.hashed_path + ".git")

    return unauthorized unless authorized?(lab_has_group)

    @app.call(env)
  end

  #
  # @return User
  #
  def current_user
    login, password = auth.credentials[0,2]
    User.authenticate(login, password)
  end

  def auth
    Request.new(@env)
  end

end

