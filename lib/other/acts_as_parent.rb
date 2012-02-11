class Object
  def self.acts_as_parent
    acts_as_citier(ignore_view_prefix: true)
    belongs_to :user
    define_method(:method_missing) do |meth, *args, &blk|
      klass = self.class.superclass    
      if klass.column_names.include?(meth.to_s)
        send(klass.to_s.underscore).try(meth, *args, &blk)
      else
        super(meth, *args, &blk)
      end
    end
  end
end

# ActiveRecord::Base.send(:include, ActsAsParent)