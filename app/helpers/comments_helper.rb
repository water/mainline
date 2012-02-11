# encoding: utf-8

module CommentsHelper
  include DiffHelper
  def comment_block(comment, &block)
    block_options = {:class => "comment", :"gts:comment-id" => comment.to_param}
    if comment.applies_to_line_numbers?
      block_options[:class] << " inline"
      block_options[:"data-diff-path"] = comment.path
      block_options[:"data-last-line-in-diff"] = comment.last_line_number
      block_options[:"data-sha-range"] = comment.sha1
      block_options[:"data-merge-request-version"] = comment.target.version if comment.respond_to?(:version)
    end
    output = content_tag(:div, capture(&block), block_options)
    concat(output)
  end
end
