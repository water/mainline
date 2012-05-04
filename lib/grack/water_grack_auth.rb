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

    # /courses/1/labs/2 => {:courses=>1, :labs=>2}
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

# TODO: fix query, it should not pick first, rather based on credentials
    unless lhg = lab.lab_has_groups.first
      halt("Lab has group not found")
      return bad_request
    end

    unless repository = lhg.repository
      halt("Repository not found")
      return bad_request
    end

    env["PATH_INFO"] = path_info.gsub(/^.*\.git/, "/" + repository.hashed_path + ".git")

    @req = Rack::Request.new(env)

    return unauthorized unless auth.provided?
    return bad_request unless auth.basic?
    return unauthorized unless authorized?(lhg)

    # env['REMOTE_USER'] = auth.username
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

