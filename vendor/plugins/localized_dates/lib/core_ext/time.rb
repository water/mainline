::Time.class_eval do
  def to_formatted_s(format = :default)
    formats = ::Time::DATE_FORMATS
    formatter = formats[format]

    unless formatter
      formatters = I18n.translate(:'time.formats', :raise => true) rescue {}
      formatter  = formatters[format]
    end

    format_to_localize = formatter.respond_to?(:call) ? formatter.call(self) : formatter
    I18n.localize(self, :format => format_to_localize)
  end
  alias_method :to_s, :to_formatted_s
end

class Object
  def def_if_not_defined(const, value)
    mod = self.is_a?(Module) ? self : self.class
    mod.const_set(const, value) unless mod.const_defined?(const)
  end

  def redef_without_warning(const, value)
    mod = self.is_a?(Module) ? self : self.class
    mod.send(:remove_const, const) if mod.const_defined?(const)
    mod.const_set(const, value)
  end
end

::Time.redef_without_warning :DATE_FORMATS, {
  :db           => "%Y-%m-%d %H:%M:%S",
  :number       => "%Y%m%d%H%M%S",
  :rfc822       => "%a, %d %b %Y %H:%M:%S %z"
}