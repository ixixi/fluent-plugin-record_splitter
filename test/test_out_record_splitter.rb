require 'fluent/test'
require 'fluent/test/driver/output'
require 'test/unit'
require 'fluent/plugin/out_record_splitter'

class RecordSplitterOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %().freeze

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output
      .new(Fluent::Plugin::RecordSplitterOutput)
      .configure(conf)
  end

  def event_time
    Time.parse('2017-06-01 00:11:22 UTC').to_i
  end

  def test_split_default
    d = create_driver %(
      @type record_splitter
      tag foo.split
      split_key target_field
    )

    d.run(default_tag: 'test') do
      d.feed(event_time,
             'other' => 'foo',
             'target_field' => [{ 'k1' => 'v1' }, { 'k2' => 'v2' }])
    end

    assert_equal [
      ['foo.split', event_time, { 'k1' => 'v1' }],
      ['foo.split', event_time, { 'k2' => 'v2' }]
    ], d.events
  end

  def test_split_with_keep_other_key
    d = create_driver %(
      type record_splitter
      tag foo.split
      split_key target_field
      keep_other_key true
    )

    d.run(default_tag: 'test') do
      d.feed(event_time,
             'common' => 'c', 'general' => 'g', 'other' => 'foo',
             'target_field' => [{ 'k1' => 'v1' }, { 'k2' => 'v2' }])
    end

    assert_equal [
      ['foo.split', event_time,
       { 'common' => 'c', 'general' => 'g', 'other' => 'foo', 'k1' => 'v1' }],
      ['foo.split', event_time,
       { 'common' => 'c', 'general' => 'g', 'other' => 'foo', 'k2' => 'v2' }]
    ], d.events
  end

  def test_split_with_keep_other_key_and_remove_key
    d = create_driver %(
      type record_splitter
      tag foo.split
      split_key target_field
      keep_other_key true
      remove_keys ["general","other"]
    )

    d.run(default_tag: 'test') do
      d.feed(event_time,
             'common' => 'c', 'general' => 'g', 'other' => 'foo',
             'target_field' => [{ 'k1' => 'v1' }, { 'k2' => 'v2' }])
    end

    assert_equal [
      ['foo.split', event_time, { 'common' => 'c', 'k1' => 'v1' }],
      ['foo.split', event_time, { 'common' => 'c', 'k2' => 'v2' }]
    ], d.events
  end

  def test_split_with_keep_keys
    d = create_driver %(
      type record_splitter
      tag foo.split
      split_key target_field
      keep_keys ["common","general"]
    )

    d.run(default_tag: 'test') do
      d.feed(event_time,
             'common' => 'c', 'general' => 'g', 'other' => 'foo',
             'target_field' => [{ 'k1' => 'v1' }, { 'k2' => 'v2' }])
    end

    assert_equal [
      ['foo.split', event_time,
       { 'common' => 'c', 'general' => 'g', 'k1' => 'v1' }],
      ['foo.split', event_time,
       { 'common' => 'c', 'general' => 'g', 'k2' => 'v2' }]
    ], d.events
  end

  def test_tag_nochange
    d = create_driver %(
      type record_splitter
      split_key target_field
    )

    d.run(default_tag: 'test') do
      d.feed(event_time, 'target_field' => [{ 'k1' => 'v1' }])
    end

    d.events.each do |tag, _|
      assert_equal tag, 'test'
    end
  end

  def test_tag_change
    d = create_driver %(
      type record_splitter
      tag test.split
      split_key target_field
    )

    d.run(default_tag: 'test') do
      d.feed(event_time, 'target_field' => [{ 'k1' => 'v1' }])
    end

    d.events.each do |tag, _|
      assert_equal tag, 'test.split'
    end
  end

  def test_add_tag_suffix
    d = create_driver %(
      type record_splitter
      add_tag_suffix .split
      split_key target_field
    )

    d.run(default_tag: 'test') do
      d.feed(event_time, 'target_field' => [{ 'k1' => 'v1' }])
    end

    d.events.each do |tag, _|
      assert_equal tag, 'test.split'
    end
  end

  def test_add_tag_prefix
    d = create_driver %(
      type record_splitter
      add_tag_prefix split.
      split_key target_field
    )

    d.run(default_tag: 'test') do
      d.feed(event_time, 'target_field' => [{ 'k1' => 'v1' }])
    end

    d.events.each do |tag, _|
      assert_equal tag, 'split.test'
    end
  end
end
