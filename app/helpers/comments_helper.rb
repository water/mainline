# encoding: utf-8

module CommentsHelper
  def nested_comments(comments)
   # debugger
   # 1+1
    comments.map do |comment, sub_comments|
      render(comment) + content_tag(:div, nested_comments(sub_comments), :class => "nested_comments")
    end.join.html_safe
  end
end
