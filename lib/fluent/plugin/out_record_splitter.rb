require 'fluent/mixin/config_placeholders'

module Fluent
  class RecordSplitterOutput < Output
    Fluent::Plugin.register_output('record_splitter', self)

    config_param :tag, :string
    config_param :split_key, :string
    config_param :keep_other_key, :bool, :default => false
    config_param :keep_keys, :array, :default => []
    config_param :remove_keys, :array, :default => []

    include SetTagKeyMixin
    include Fluent::Mixin::ConfigPlaceholders

    def configure(conf)
      super
      if not @keep_keys.empty? and not @remove_keys.empty?
        raise Fluent::ConfigError, 'Cannot set both keep_keys and remove_keys.'
      end
      if @keep_other_key and not @keep_keys.empty?
        raise Fluent::ConfigError, 'Cannot set keep_keys when keep_other_key is true.'
      end
      if not @keep_other_key and not @remove_keys.empty?
        raise Fluent::ConfigError, 'Cannot set remove_keys when keep_other_key is false.'
      end
    end

    def emit(tag, es, chain)
      es.each { |time, record|
        if keep_other_key
          common = record.reject{|key, value| key == @split_key or @remove_keys.include?(key) } 
        else
          common = record.select{|key, value| @keep_keys.include?(key) } 
        end
        record[@split_key].each{|v|
          v.merge!(common) unless common.empty?
          Engine.emit(@tag, time, v.merge(common))
        }
      }
      chain.next
    end

  end
end
