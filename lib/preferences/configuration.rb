module Preferences
  class Configuration
    def initialize(*args, &block)
      options = args.extract_options!
      klass = args.shift
      keys = args

      raise ArgumentError unless klass

      @klass = klass
      @klass.class_attribute :default_settings, :setting_object_class_name
      @klass.default_settings = {}
      @klass.setting_object_class_name = options[:class_name] || 'Preferences::Preference'

      if block_given?
        yield(self)
      else
        keys.each do |k|
          key(k)
        end
      end

      raise ArgumentError.new('has_settings: No keys defined') if @klass.default_settings.blank?
    end

    def key(name, options={})
      raise ArgumentError.new("has_settings: Symbol expected, but got a #{name.class}") unless name.is_a?(Symbol)
      raise ArgumentError.new("has_settings: Option :defaults expected, but got #{options.keys.join(', ')}") unless options.blank? || (options.keys == [:defaults])
      @klass.default_settings[name] = (options[:defaults].with_indifferent_access || {}).stringify_keys.freeze
    end
  end
end
