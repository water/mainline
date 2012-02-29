# encoding: utf-8

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include TagsHelper
  include UsersHelper
  include BreadcrumbsHelper

  GREETINGS = ["Hello", "Hi", "Greetings", "Howdy", "Heya", "G'day"]

  def random_greeting
    GREETINGS[rand(GREETINGS.length)]
  end

  def help_box(style = :side, icon = :help, options = {}, &block)
    out = %Q{<div id="#{options.delete(:id)}" style="#{options.delete(:style)}"
                  class="help-box #{style} #{icon} round-5">
               <div class="icon #{icon}"></div>}
    out << with_output_buffer(&block)
    out << "</div>"
    out.html_safe
  end

  def pull_box(title, options = {}, &block)
    css_class = options.delete(:class)
    out = %Q{<div class="pull-box-container #{css_class}">}
    out << %Q{<div class="pull-box-header"><h3>#{title}</h3></div>} if title
    out << %Q{<div class="pull-box-content">}
    out << with_output_buffer(&block)
    out << "</div></div>"
    out.html_safe
  end

  def dialog_box(title, options = {}, &block)
    css_class = options.delete(:class)
    out = %Q{<div class="dialog-box #{css_class}">}
    out << %Q{<h3 class="round-top-5 dialog-box-header">#{title}</h3>} if title
    out << %Q{<div class="dialog-box-content">}
    out << with_output_buffer(&block)
    out << "</div></div>"
    out.html_safe
  end

  def markdown(text, options = [:smart])
    renderer = MarkupRenderer.new(text, :markdown => options)
    renderer.to_html
  end

  def render_markdown(text, *options)
    # RDiscount < 1.4 doesn't support the :auto_link, use Rails' instead
    auto_link = options.delete(:auto_link)
    markdown_options = [:smart] + options
    markdownized_text = markdown(text, markdown_options)
    if auto_link
      markdownized_text = auto_link(markdownized_text, :urls)
    end
    sanitize(markdownized_text)
  end


  def default_css_tag_sizes
    %w(tag_size_1 tag_size_2 tag_size_3 tag_size_4)
  end

  def linked_tag_list_as_sentence(tags)
    tags.map do |tag|
      link_to(h(tag.name), search_path(:q => "category:#{h(tag.name)}"))
    end.to_sentence
  end

  def build_notice_for(object, options = {})
    out =  %Q{<div class="being_constructed round-10">}
    out <<  %Q{<div class="being_constructed_content round-10">}
    out << %Q{  <p>#{I18n.t( "application_helper.notice_for", :class_name => object.class.name.humanize.downcase)}</p>}
    if options.delete(:include_refresh_link)
      out << %Q{<p class="spin hint"><a href="#{url_for()}">Click to refresh</a></p>}
    else
      out << %Q{<p class="spin">#{image_tag("spinner.gif")}</p>}
    end
    out << %Q{  <p class="hint">If this message persist beyond what's reasonable, feel free to #{link_to("contact us", contact_path)}</p>}
    out << %Q{</div></div>}
    out
  end

  def render_if_ready(object, options = {})
    if object.respond_to?(:ready?) && object.ready?
      yield
    else
      concat(build_notice_for(object, options).html_safe)
    end
  end

  def selected_if_current_page(url_options, slack = false)
    if slack
      if controller.request.request_uri.index(CGI.escapeHTML(url_for(url_options))) == 0
        "selected"
      end
    else
      "selected" if current_page?(url_options)
    end
  end

  def submenu_selected_class_if_current?(section)
    case section
    when :overview
     if %w[projects].include?(controller.controller_name )
       return "selected"
     end
    when :repositories
      if %w[repositories trees logs commits comitters
            blobs committers].include?(controller.controller_name )
        return "selected"
      end
    when :pages
      if %w[pages].include?(controller.controller_name )
        return "selected"
      end
    end
  end

  def link_to_with_selected(name, options = {}, html_options = nil)
    html_options = current_page?(options) ? {:class => "selected"} : nil
    link_to(name, options = {}, html_options)
  end

  def syntax_themes_css
    out = []
    if @load_syntax_themes
      # %w[ active4d all_hallows_eve amy blackboard brilliance_black brilliance_dull
      #     cobalt dawn eiffel espresso_libre idle iplastic lazy mac_classic
      #     magicwb_amiga pastels_on_dark slush_poppies spacecadet sunburst
      #     twilight zenburnesque
      # ].each do |syntax|
      #   out << stylesheet_link_tag("syntax_themes/#{syntax}")
      # end
      return stylesheet_link_tag("syntax_themes/idle")
    end
    out.join("\n")
  end

  def base_url(full_url)
    URI.parse(full_url).host
  end

  def gravatar_url_for(email, options = {})
    options.reverse_merge!(:default => "images/default_face.gif")
    port_string = [443, 80].include?(request.port) ? "" : ":#{request.port}"
    "http://www.gravatar.com/avatar.php?gravatar_id=" +
    (email.nil? ? "" : Digest::MD5.hexdigest(email)) + "&amp;default=" +
      u("http://#{GitoriousConfig['gitorious_host']}#{port_string}" +
      "/#{options.delete(:default)}") +
    options.map { |k,v| "&amp;#{k}=#{v}" }.join
  end

  # For a User object, return either his/her avatar or the gravatar for her email address
  # Options
  # - Pass on :size for the height+width of the image in pixels
  # - Pass on :version for a named version/style of the avatar
  def avatar(user, options={})
    if user.avatar?
      avatar_style = options.delete(:version) || :thumb
      image_options = { :alt => 'avatar'}.merge(:width => options[:size], :height => options[:size])
      image_tag(user.avatar.url(avatar_style), image_options)
    else
      gravatar(user.email, options)
    end
  end

  # Returns an avatar from an email address (for instance from a commit) where we don't have an actual User object
  def avatar_from_email(email, options={})
    return if email.blank?
    avatar_style = options.delete(:version) || :thumb
    image = User.find_avatar_for_email(email, avatar_style)
    if image == :nil
      gravatar(email, options)
    else
      image_options = { :alt => 'avatar'}.merge(:width => options[:size], :height => options[:size])
      image_tag(image, image_options)
    end
  end

  def gravatar(email, options = {})
    size = options[:size]
    image_options = { :alt => "avatar" }
    if size
      image_options.merge!(:width => size, :height => size)
    end
    image_tag(gravatar_url_for(email, options), image_options)
  end

  def gravatar_frame(email, options = {})
    extra_css_class = options[:style] ? " gravatar_#{options[:style]}" : ""
    %{<div class="gravatar#{extra_css_class}">#{gravatar(email, options)}</div>}
  end

  def flashes
    flash.map do |type, content|
      content_tag(:div, content_tag(:p, content), :class => "flash_message #{type}")
    end.join("\n").html_safe
  end

  def commit_graph_tag(repository, ref = "master")
  end

  def commit_graph_by_author_tag(repository, ref = "master")
  end

  def action_and_body_for_event(event)
    target = event.target
    if target.nil?
      return ["", "", ""]
    end
    # These are defined in event_rendering_helper.rb:
    action, body, category = self.send("render_event_#{Action::css_class(event.action)}", event)

    body = sanitize(body, :tags => %w[a em i strong b])
    [action, body, category]
  end

  def link_to_remote_if(condition, name, options, html_options = {})
    if condition
      link_to_remote(name, options, html_options)
    else
      content_tag(:span, name)
    end
  end

  def render_readme(repository)
    possibilities = []
    repository.git.git.ls_tree({:name_only => true}, "master").each do |line|
      possibilities << line[0, line.length-1] if line =~ /README.*/
    end

    return "" if possibilities.empty?
    text = repository.git.git.show({}, "master:#{possibilities.first}")
    markdown(text) rescue simple_format(sanitize(text))
  end

  def render_markdown_help
    render :partial => '/site/markdown_help'
  end

  def file_path(repository, filename, head = "master")
    project_repository_blob_path(repository.project, repository, branch_with_tree(head, filename))
  end

  def link_to_help_toggle(dom_id, style = :image)
    if style == :image
      link_to_function(image_tag("help_grey.png", {
        :alt => t("application_helper.more_info")
      }), "$('##{dom_id}').toggle()", :class => "more_info")
    else
      %Q{<span class="hint">(} +
      link_to_function("?", "$('##{dom_id}').toggle()", :class => "more_info") +
      ")</span>"
    end

  end

  FILE_EXTN_MAPPINGS = {
    '.cpp' => 'cplusplus-file',
    '.c' => 'c-file',
    '.h' => 'header-file',
    '.java' => 'java-file',
    '.sh' => 'exec-file',
    '.exe'  => 'exec-file',
    '.rb' => 'ruby-file',
    '.png' => 'image-file',
    '.jpg' => 'image-file',
    '.gif' => 'image-file',
    'jpeg' => 'image-file',
    '.zip' => 'compressed-file',
    '.gz' => 'compressed-file'}

  def class_for_filename(filename)
    return FILE_EXTN_MAPPINGS[File.extname(filename)] || 'file'
  end

  def render_download_links(project, repository, head, options={})
    links = []
    exceptions = Array(options[:except])
    unless exceptions.include?(:source_tree)
      links << content_tag(:li, link_to("Source tree",
                  tree_path(head)), :class => "tree")
    end

    head = desplat_path(head) if head.is_a?(Array)

    if head =~ /^[a-z0-9]{40}$/ # it looks like a SHA1
      head = head[0..7]
    end

    {
      'tar.gz' => 'tar',
      # 'zip' => 'zip',
    }.each do |extension, url_key|
      archive_path = self.send("project_repository_archive_#{url_key}_path", project, repository, head)
      link_html = link_to("Download #{head} as #{extension}", archive_path,
                                  :onclick => "Gitorious.DownloadChecker.checkURL('#{archive_path}?format=js', 'archive-box-#{head}');return false",
                                  :class => "download-link")
      link_callback_box = content_tag(:div, "", :class => "archive-download-box round-5 shadow-2",
        :id => "archive-box-#{head}", :style => "display:none;")
      links << content_tag(:li, link_html+link_callback_box, :class => extension.split('.').last)
    end

    if options.delete(:only_list_items)
      links.join("\n")
    else
      css_classes = options[:class] || "meta"
      content_tag(:ul, links.join("\n"), :class => "links #{css_classes}")
    end
  end

  def paragraphs_with_more(text, identifier)
    return if text.blank?
    first, rest = text.split("</p>", 2)
    if rest.blank?
      first + "</p>"
    else
      %Q{#{first}
        <a href="#more"
           onclick="$('#description-rest-#{identifier}').toggle(); $(this).hide()">more&hellip;</a></p>
        <div id="description-rest-#{identifier}" style="display:none;">#{rest}</div>}
    end
  end

  def markdown_hint
    t("views.common.format_using_markdown",
      :markdown => %(<a href="http://daringfireball.net/projects/markdown/">Markdown</a>)).html_safe
  end

  def current_site
    controller.current_site
  end

  def new_polymorphic_comment_path(parent, comment)
    if parent
      repo_owner_path(@repository, [@project, @repository, parent, comment])
    else
      repo_owner_path(@repository, [@project, @repository, comment])
    end
  end

  def force_utf8(str)
    if str.respond_to?(:force_encoding)
      str.force_encoding("UTF-8")
      if str.valid_encoding?
        str
      else
        str.encode("binary", :invalid => :replace, :undef => :replace).encode("utf-8")
      end
    else
      str.mb_chars
    end

  end

  # Creates a CSS styled <button>.
  #
  #  <%= styled_button :big, "Create user" %>
  #  <%= styled_button :medium, "Do something!", :class => "foo", :id => "bar" %>
  def styled_button(size_identifier, label, options = {})
    options.reverse_merge!(:type => "submit", :class => size_identifier.to_s)
    content_tag(:button, %{<span>#{label}</span>}, options)
  end

  # Similar to styled_button, but creates a link_to <a>, not a <button>.
  #
  #  <%= button_link :big, "Sign up", new_user_path %>
  def button_link(size_identifier, label, url, options = {})
    options[:class] = "#{size_identifier} button_link"
    link_to(%{<span>#{label}</span>}, url, options)
  end

  # Array => HTML list. The option hash is applied to the <ul> tag.
  #
  #  <%= list(items) {|i| i.title } %>
  #  <%= list(items, :class => "foo") {|i| link_to i, foo_path }
  def list(items, options = {})
    list_items = items.map {|i| %{<li>#{block_given? ? yield(i) : i}</li>} }.join("\n")
    content_tag(:ul, list_items, options)
  end

  def summary_box(title, content, image)
    %{
      <div class="summary_box">
        <div class="summary_box_image">
          #{image}
        </div>

        <div class="summary_box_content">
          <strong>#{title}</strong>
          #{content}
        </div>

        <div class="clear"></div>
      </div>
    }
  end

  def project_summary_box(project)
    summary_box link_to(project.title, project),
      truncate(project.descriptions_first_paragraph, 80),
      glossy_homepage_avatar(default_avatar)
  end

  def team_summary_box(team)
    text = list([
      "Created: #{team.created_at.strftime("%B #{team.created_at.strftime("%d").to_i.ordinalize} %Y")}",
      "Total activities: #{team.event_count}"
    ], :class => "simple")

    summary_box link_to(team.name, group_path(team)),
      text,
      glossy_homepage_avatar(team.avatar? ? image_tag(team.avatar.url(:thumb), :width => 30, :height => 30) : default_avatar)

  end

  def user_summary_box(user)
    text = text = list([
      "Projects: #{user.projects.count}",
      "Total activities: #{user.events.count}"
    ], :class => "simple")

    summary_box link_to(user.login, user),
      text,
      glossy_homepage_avatar_for_user(user)
  end

  def glossy_homepage_avatar(avatar)
    content_tag(:div, avatar + "<span></span>", :class => "glossy_avatar_wrapper")
  end

  def glossy_homepage_avatar_for_user(user)
    glossy_homepage_avatar(avatar(user, :size => 30, :default => "images/icon_default.png"))
  end

  def default_avatar
    image_tag("icon_default.png", :width => 30, :height => 30)
  end

  def secure_login_url
    if SslRequirement.disable_ssl_check?
      sessions_path
    else
      sessions_url(:protocol => "https", :host => SslRequirement.ssl_host)
    end
  end



  # The javascripts to be included in all layouts
  def include_javascripts
    javascript_include_tag "jquery.core", "jquery.autocomplete", "jquery.cookie",
      "color_picker", "ui.core","ui.selectable", "jquery.scrollto", "jquery.timeago",
      "core_extensions", "jquery.expander", "jquery.cycle.all.min",
      "jquery.gitorious_extensions",
      "notification_center", "diff_browser", "messages",
      "application", "live_search", "repository_search", :cache => true
  end

  # inserts a <wbr> tag somewhere in the middle of +str+
  def wbr_middle(str)
    half_size = str.length / 2
    str.to_s[0..half_size-1] + "<wbr />" + str[half_size..-1]
  end

  def time_ago(time, options = {})
    return unless time
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601))
  end

  def white_button_link_to(label, url, options = {})
    size = options.delete(:size) || "small"
    css_classes = ["white-button", "#{size}-button"]
    if extra_class = options.delete(:class)
      css_classes << extra_class
    end
    content_tag(:div, link_to(label, url, :class => "round-10"),
        :id => options.delete(:id), :class => css_classes.flatten.join(" "))
  end

  def link_button_link_to(label, url, options = {})
    size = options.delete(:size) || "small"
    css_classes = ["button", "#{size}-button"]
    if extra_class = options.delete(:class)
      css_classes << extra_class
    end
    content_tag(:div, link_to(label, url, :class => ""),
        :id => options.delete(:id), :class => css_classes.flatten.join(" "))
  end
  
  def render_pagination_links(collection, options = {})
    default_options = {
      :prev_label => "Previous",
      :next_label => "Next",
      :container => "True"
    }
    will_paginate(collection, options.merge(default_options))
  end

  def dashboard_path
    root_url(:host => GitoriousConfig["gitorious_host"], :protocol => "http")
  end

  def git_or_ssh_url_checked(repository, currently)
    if logged_in?
      if currently == :git && !repository.writable_by?(current_user)
        return 'checked="checked"'
      elsif currently == :ssh && repository.writable_by?(current_user)
        return 'checked="checked"'
      else
        return ""
      end
    else
      return currently == :git ? 'checked="checked"' : ""
    end
  end
end
