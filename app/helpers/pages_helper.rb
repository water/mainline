# encoding: utf-8

module PagesHelper
  include CommitsHelper
  
  def wikize(content)
    content = wiki_link(content)
    # rd = RDiscount.new(content, :smart, :generate_toc)
    rd = MarkupRenderer.new(content, :markdown => [:smart, :generate_toc])
    content = content_tag(:div, rd.to_html, :class => "page-content")
    toc_content = rd.markdown.toc_content
    if !toc_content.blank?
      toc = content_tag(:div, toc_content, :class => "toc")
    else
      toc = ""
    end
    content_tag(:div, toc + sanitize(content), :class => "page wiki-page")
  end
  
  unless defined?(BRACKETED_WIKI_WORD)  
    BRACKETED_WIKI_WORD = /\[\[([A-Za-z0-9_\-]+)\]\]/
  end
  
  def wiki_link(content)
    content.gsub(BRACKETED_WIKI_WORD) do |page_link|
      if bracketed_name = Regexp.last_match.captures.first
        page_link = bracketed_name
      end
      link_to(page_link, project_page_path(@project, page_link), 
                :class => "todo missing_or_existing")
    end
  end
  
  def edit_link(page)
    link_to(t("views.common.edit")+" "+t("views.pages.page"), 
          edit_project_page_path(@project, page.title))
  end
  
  def page_node_name(node)
    h(node.name.split(".", 2).first)
  end  
end
