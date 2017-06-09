require 'fluent/mixin/config_placeholders'
require 'fluent/mixin/rewrite_tag_name'

module Fluent
  class RecordSplitterOutput < Output
    Fluent::Plugin.register_output('record_splitter', self)

    config_param :tag, :string
    config_param :remove_prefix, :string, :default => nil
    config_param :add_prefix, :string, :default => nil
    config_param :split_key, :string
    config_param :keep_other_key, :bool, :default => false
    config_param :keep_keys, :array, :default => []
    config_param :remove_keys, :array, :default => []

    include SetTagKeyMixin
    include Fluent::Mixin::ConfigPlaceholders
    include Fluent::HandleTagNameMixin
    include Fluent::Mixin::RewriteTagName

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
      if not @tag and not @remove_prefix and not @add_prefix
        raise Fluent::ConfigError, "missing both of remove_prefix and add_prefix"
      end
      if @tag and (@remove_prefix or @add_prefix)
        raise Fluent::ConfigError, "both of tag and remove_prefix/add_prefix must not be specified"
      end
    end

    def emit(tag, es, chain)
      emit_tag = tag.dup
      es.each { |time, record|
        filter_record(emit_tag, time, record)
        if keep_other_key
          common = record.reject{|key, value| key == @split_key or @remove_keys.include?(key) }
        else
          common = record.select{|key, value| @keep_keys.include?(key) }
        end
        if record.key?(@split_key)
          record[@split_key].each{|v|
            v.merge!(common) unless common.empty?
            router.emit(emit_tag, time, v.merge(common))
          }
        end
      }
      chain.next
    end

  end
end
