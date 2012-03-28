require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'
require 'rack/auth/basic'

require File.expand_path("../../config/environment", __FILE__)

class WaterGrackAuth < Rack::Auth::Basic

  def valid?(auth)
    # TODO, do actual checking here
    user, pass = auth.credentials[0,2]
    return true
  end

  def call(env)
    path_info = env["PATH_INFO"]
    res = path_info.scan(%r{/\d+/}).map { |x| x[1..-2].to_i }
    p res

    # The code below should use all 3 of the pattern matched values.
    course_id, lab_group_id, lab_id = res
    lab = Lab.find(lab_id)
    lhg = lab.lab_has_groups.first
    repo = lhg.repository

    env["PATH_INFO"] = path_info.gsub(/^.*\.git/, repo.hashed_path + ".git")

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

