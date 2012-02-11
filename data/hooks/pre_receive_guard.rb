# encoding: utf-8


require "open-uri"
require 'cgi'

module Gitorious
  module SSH  
    class PreReceiveGuard
      # env is a Hash representing ENV
      def initialize(env, git_spec)
        @env  = env.dup
        @query_url = @env['GITORIOUS_WRITABLE_BY_URL']
        @git_spec   = git_spec
      end
      attr_reader :git_spec

      # extract the target, eg. refs/heads/master
      def git_target
        @git_spec.split(/\s/, 3).last.chomp
      end
      
      def local_connection?
        !@env.include? 'SSH_ORIGINAL_COMMAND'
      end

      def merge_request_update?
        git_target =~ /^refs\/merge-requests\/\d+$/
      end

      def authentication_url
        @query_url + "&git_path=#{CGI.escape(git_target)}"
      end
  
      def allow_push?
        return true if local_connection?
        result = get_via_http(authentication_url)
        return result == 'true'
      end

      def deny_force_pushes?
        return false if local_connection?
        return false if merge_request_update?
        @env['GITORIOUS_DENY_FORCE_PUSHES'] == "true"
      end
      
      def get_via_http(url)
        open(url).read
      end

      def gitorious_says(msg)
        $stderr.puts
        $stderr.puts "== Gitorious: " + ("=" * 59)
        $stderr.puts msg
        $stderr.puts "="*72
        $stderr.puts
      end

      def null_sha?(sha)
        sha == "0000000000000000000000000000000000000000"
      end

      def deny_merge_request_update_with_sha?(sha)
        return null_sha?(sha) && merge_request_update? && !local_connection?
      end
    end
  end
end
