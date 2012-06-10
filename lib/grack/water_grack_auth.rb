require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'
require 'rack/auth/basic'
require "colorize"
require File.expand_path("../../../config/environment", __FILE__)

class WaterGrackAuth < Rack::Auth::Basic

  #
  # @message String Message to be send to user 
  #
  def halt(message)
    $stderr.puts "Halt!: #{message}".red
  end

  def call(env)
    auth = Request.new(env)

    # We want to do auth things first
    return unauthorized unless auth.provided?
    return bad_request unless auth.basic?

    # /courses/1/lab_groups/3/labs/2 => {:courses=>1, :labs=>2, :lab_groups=>3}
    params = Hash[env["PATH_INFO"].scan(%r{\w+/\d+}).map { |x| x.split("/") }]

    given_course_id, lab_number, lab_group_number = params.values_at("courses",
                                                                     "labs",
                                                                     "lab_groups")

    given_course = GivenCourse.find(given_course_id)

    lab = Lab.find_by_given_course_id_and_number(given_course_id, lab_number)

    unless lab
      halt("Lab not found")
      return bad_request
    end

    lab_group = LabGroup.find_by_given_course_id_and_number(given_course_id,
                                                            lab_group_number)

    unless lab_group
      halt("Lab group not found")
      return bad_request
    end

    lab_has_group = LabHasGroup.find_by_lab_group_id_and_lab_id(lab_group.id,
                                                                lab.id)

    unless lab_has_group 
      halt("Lab has group not found")
      return bad_request
    end

    unless repository = lab_has_group.repository
      halt("Repository not found")
      return bad_request
    end

    login, password = auth.credentials[0,2]
    user = User.authenticate(login, password)

    authorized_as_student = lab_group.
                              students.
                              map(&:user).
                              include?(user)
    authorized_as_assistant = given_course.
                                assistants.
                                map(&:user).
                                include?(user)

    return unauthorized unless authorized_as_student or authorized_as_assistant

    #TODO: Implement so assistants don't have write permissions

    env["PATH_INFO"].gsub!(/^.*\.git/, "/" + repository.hashed_path + ".git")
    @app.call(env)
  end

end
