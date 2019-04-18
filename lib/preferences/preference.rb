module Preferences
  class Preference < ActiveRecord::Base

    belongs_to :owner, :polymorphic => true

    validates_presence_of :key
    validates_presence_of :owner_type
    
    validate :value_type_hash
    validate :known_key
    
    def value_type_hash
      errors.add(:value, "invalid value") unless value.is_a? Hash
    end

    def known_key
      errors.add(:key, "`#{key}` is not defined!") unless key.present? && owner.default_settings[key.to_sym]
    end

    REGEX_SETTER = /\A([a-z]\w+)=\Z/i
    REGEX_GETTER = /\A([a-z]\w+)\Z/i

    def respond_to?(method_name, include_priv=false)
      super || method_name.to_s =~ REGEX_SETTER || setting?(method_name)
    end

    def method_missing(method_name, *args, &block)
      if block_given?
        super
      else
        if attribute_names.include?(method_name.to_s.sub('=',''))
          super
        elsif method_name.to_s =~ REGEX_SETTER && args.size == 1
          set_value($1, args.first) 
        elsif method_name.to_s =~ REGEX_GETTER && args.size == 0
          get_value($1)
        else
          super
        end
      end
    end


  private
    def get_value(k)
      value[k.to_s].presence || owner.default_settings[key.to_sym][k.to_s]
    end

    def set_value(k, v)
      return if v.eql?(value[k]) || value[k].blank? && v.eql?(owner.default_settings[key.to_sym][k.to_s])
      v.nil? ? self.value.delete(k) : self.value.merge!(k => v)
    end

    def setting?(method_name)
      owner.default_settings[key.to_sym].keys.include?(method_name.to_s)
    end
  end
end
