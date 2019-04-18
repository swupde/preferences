module Preferences
  module Base
    def self.included(base)
      base.class_eval do
        has_many :preferences, as: :owner, autosave: true, dependent: :delete_all, class_name: self.setting_object_class_name

        def settings(key)
          raise ArgumentError unless key.is_a?(Symbol)
          raise ArgumentError.new("Unknown key: #{key}") unless self.class.default_settings[key]

          preferences.find { |s| s.key.eql?(key.to_s) } || preferences.build(key: key)
        end

        def settings=(value)
          raise ArgumentError unless value.nil?
          
          preferences.each(&:mark_for_destruction)
        end

        def settings?(key=nil)
          if key.nil?
            preferences.any? { |p| !p.marked_for_destruction? && p.value.present? }
          else
            settings(key).value.present?
          end
        end

      end
    end
  end
end
