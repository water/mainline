# encoding: utf-8

module BlobsHelper
  include RepositoriesHelper
  include TreesHelper
  
  unless defined?(ASCII_MIME_TYPES_EXCEPTIONS)
    HIGHLIGHTER_TO_EXT = {
      "list"  => /\.(lisp|cl|l|mud|el|clj)$/,
      "hs"    => /\.hs$/,
      "css"   => /\.css$/,
      "lua"   => /\.lua$/,
      "ml"    => /\.(ml|mli)$/,
      "proto" => /\.proto$/,
      "sql"   => /\.(sql|ddl|dml)$/,
      "vb"    => /\.vb$/,
      "wiki"  => /\.(mediawiki|wikipedia|wiki)$/,
    }
    
    ASCII_MIME_TYPES_EXCEPTIONS = [ /^text/ ]
  end
    
  def textual?(blob)
    !binary?(blob)
  end
  
  def binary?(blob)
    blob.binary?
  end
  
  def image?(blob)
    blob.mime_type =~ /^image/
  end
  
  def highlightable?(blob)
    if File.extname(blob.name) == ""
      return false
    end
    if %w[.txt .textile .md .rdoc .markdown].include?(File.extname(blob.name))
      return false
    end
    true
  end
  
  def language_of_file(filename)
    if lang_tuple = HIGHLIGHTER_TO_EXT.find{|lang, matcher| filename =~ matcher }
      return lang_tuple.first
    end
  end
  
  def pygmentize(args)
    options = { :encoding => 'utf-8' }
    begin
      logger.fatal(args[:filename])
      Pygments.highlight args[:data], :filename => args[:filename], :options => options
    rescue
      logger.fatal("Shit went down")
      Pygments.highlight args[:data], :lexer => :text, :options => options
    end
  end
  
  # TODO PROBABLY NOT USED RIGHT NOW
  def render_highlighted(text, filename, code_theme_class = nil)
    out = []
    lang_class = "lang" + File.extname(filename).sub('.', '-')
    out << %Q{<table id="codeblob" class="highlighted #{lang_class}">}
    text.to_s.split("\n").each_with_index do |line, count|
      lineno = count + 1
      out << %Q{<tr id="line#{lineno}">}
      out << %Q{<td class="line-numbers"><a href="#line#{lineno}" name="line#{lineno}">#{lineno}</a></td>} 
      code_classes = "code"
      code_classes << " #{code_theme_class}" if code_theme_class
      ext = File.extname(filename).sub(/^\./, '')
      out << %Q{<td class="#{code_classes}"><pre class="prettyprint lang-#{ext}">#{h(line)}</pre></td>}
      out << "</tr>"
    end
    out << "</table>"
    out.join("\n")
  end
  
  def markdown_if_markdown(text, filename)
    if markdown?(filename)
      markdown(text)
    else
      text
    end
  end
  
  def markdown? (string)
    APP_CONFIG["markdown_file_extensions"].include?(File.extname(string))
  end

  def too_big_to_render?(size)
    size > 350.kilobytes
  end
end
