require 'fluent/plugin/output'
require 'fluent/mixin'
require 'fluent/mixin/config_placeholders'
require 'fluent/mixin/rewrite_tag_name'

module Fluent
  module Plugin
    class RecordSplitterOutput < Output
      Fluent::Plugin.register_output('record_splitter', self)

      config_param :tag, :string, default: nil
      config_param :split_key, :string
      config_param :keep_other_key, :bool, default: false
      config_param :keep_keys, :array, default: []
      config_param :remove_keys, :array, default: []

      include SetTagKeyMixin
      include Fluent::Mixin::ConfigPlaceholders
      include HandleTagNameMixin
      include Fluent::Mixin::RewriteTagName

      helpers :event_emitter

      def multi_workers_ready?
        true
      end

      def configure(conf)
        super
        if !@keep_keys.empty? && !@remove_keys.empty?
          raise Fluent::ConfigError, 'Cannot set both keep_keys and remove_keys.'
        end
        if @keep_other_key && !@keep_keys.empty?
          raise Fluent::ConfigError, 'Cannot set keep_keys when keep_other_key is true.'
        end
        if !@keep_other_key && !@remove_keys.empty?
          raise Fluent::ConfigError, 'Cannot set remove_keys when keep_other_key is false.'
        end
      end

      def process(tag, es)
        emit_tag = tag.dup

        es.each do |time, record|
          filter_record(emit_tag, time, record)

          if @keep_other_key
            common = record.reject do |key, _value|
              key == @split_key ||
                @remove_keys.include?(key)
            end
          else
            common = record.select { |key, _value| @keep_keys.include?(key) }
          end

          next unless record.key?(@split_key)

          record[@split_key].each do |v|
            v.merge!(common) unless common.empty?
            router.emit(emit_tag, time, v)
          end
        end
      end
    end
  end
end
