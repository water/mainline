# encoding: utf-8

module Gitorious
  module Diff
    class InlineTableCallback < BaseCallback
      def self.with_comments(comments, template)
        table_callback = new
        table_callback.comments = comments
        table_callback.template = template
        table_callback
      end
      attr_accessor :template

      def comments=(comments)
        @comment_callback = CommentCallback.new(comments)
      end
      
      def addline(line)
        %Q{<tr data-line-num-tuple="#{line.offsets.join('-')}"
               class="changes line-#{line.new_number}">} +
        render_comment_count(line) +
        %Q{<td class="line-numbers commentable"></td>} +
        %Q{<td class="line-numbers commentable">#{line.new_number}</td>} +
        %Q{<td class="code ins">} +
        %Q{#{render_line(line)}</td></tr>}
      end
      
      def remline(line)
        %Q{<tr data-line-num-tuple="#{line.offsets.join('-')}"
               class="changes line-#{line.old_number}">} +
        render_comment_count(line) +
        %Q{<td class="line-numbers commentable">#{line.old_number}</td>} +
        %Q{<td class="line-numbers commentable"></td>} +
        %Q{<td class="code del">} +
        %Q{#{render_line(line)}</td></tr>}
      end

      # FIXME: We don't use this one for inline diffs (?)
      def modline(line)
        %Q{<tr class="changes line">} +
        render_comment_count(line) +
        %Q{<td class="line-numbers commentable">#{line.old_number}</td>} + 
        %Q{<td class="line-numbers commentable">#{line.new_number}</td>} + 
        %Q{<td class="code unchanged mod">#{render_line(line)}</td></tr>}
      end
      
      def unmodline(line)
        %Q{<tr class="changes unmod">} +
        render_comment_count(line) +
        %Q{<td class="line-numbers">#{line.old_number}</td>} + 
        %Q{<td class="line-numbers">#{line.new_number}</td>} + 
        %Q{<td class="code unchanged unmod">#{render_line(line)}</td></tr>}
      end
      
      def sepline(line)
        %Q{<tr class="changes hunk-sep">} +
        render_comment_count(line) +
        %Q{<td class="line-numbers line-num-cut">&hellip;</td>} + 
        %Q{<td class="line-numbers line-num-cut">&hellip;</td>} + 
        %Q{<td class="code cut-line"></td></tr>}
      end
      
      def nonewlineline(line)
        %Q{<tr class="changes">} +
        render_comment_count(line) +
        %Q{<td class="line-numbers">#{line.old_number}</td>} + 
        %Q{<td class="line-numbers">#{line.new_number}</td>} + 
        %Q{<td class="code mod unmod">#{render_line(line)}</td></tr>}
      end

      protected
      def render_comment_count(line)
        if @comment_callback
          @comment_callback.count(line)
        else
          ""
        end
      end

      def render_comments_for(line)
        return "" unless @comment_callback
        return "" if @comment_callback.comment_count_ending_on_line(line).zero?
        %Q{<div class="diff-comments"
                id="diff-inline-comments-for-#{line.offsets.join('-')}">} +
          @comment_callback.render_for(line, template) +
          "</div>"
      end

      def render_line(line)
        '<span class="diff-content">' + super + '</span>' + render_comments_for(line)
      end
    end
  end
end
