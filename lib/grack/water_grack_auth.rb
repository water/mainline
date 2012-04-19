require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'
require 'rack/auth/basic'
require "colorize"
require File.expand_path("../../../config/environment", __FILE__)

class WaterGrackAuth < Rack::Auth::Basic

  def valid?(auth)
    # TODO, do actual checking here
    user, pass = auth.credentials[0,2]
    return true
  end

  #
  # @message String Message to be send to user 
  #
  def halt(message)
    $stderr.puts "Halt!: #{message}".red
  end

  def call(env)
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

    # @env = env
    # @req = Rack::Request.new(env) # TODO: do real auth request by uncommenting

    # TODO: the authorization stuff below
    # auth = Request.new(env)
    # return unauthorized unless auth.provided?
    # return bad_request unless auth.basic?
    # return unauthorized unless valid?(auth)

    # env['REMOTE_USER'] = auth.username
    return @app.call(env)
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

