# encoding: utf-8

module Gitorious
  module Diff
    class BaseCallback < ::Diff::Renderer::Base
      def headerline(line); end
      def new_line; end
      
      protected
        def escape(text)
          text.to_s.gsub('&', '&amp;').
            gsub('<', '&lt;').
            gsub('>', '&gt;').
            gsub('"', '&#34;')
        end
        
        def render_line(line)
          if line.inline_changes?
            prefix, changed, postfix = line.segments.map{|segment| escape(segment) }
            %Q{#{prefix}<span class="idiff">#{changed}</span>#{postfix}}
          else
            escape(line)
          end
        end
    end
  end
end