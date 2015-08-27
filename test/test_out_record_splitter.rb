require 'fluent/test'
require 'fluent/plugin/out_record_splitter'


class RecordSplitterOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    type record_splitter
    tag foo.splitted
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::RecordSplitterOutput, tag='test_tag').configure(conf)
  end

  def test_split_default
    d = create_driver %[
      type record_splitter
      tag foo.splitted
      split_key target_field
    ]

    d.run do
      d.emit('other'=>'foo','target_field' => [{'k1'=>'v1'},{'k2'=>'v2'}])
    end

    assert_equal [
      {'k1'=>'v1'},
      {'k2'=>'v2'},
    ], d.records
  end


  def test_split_with_keep_other_key
    d = create_driver %[
      type record_splitter
      tag foo.splitted
      split_key target_field
      keep_other_key true
    ]

    d.run do
      d.emit('common'=>'c','general'=>'g','other'=>'foo','target_field' => [{'k1'=>'v1'},{'k2'=>'v2'}])
    end

    assert_equal [
      {'common'=>'c','general'=>'g','other'=>'foo','k1'=>'v1'},
      {'common'=>'c','general'=>'g','other'=>'foo','k2'=>'v2'},
    ], d.records
  end

  def test_split_with_keep_other_key_and_remove_key
    d = create_driver %[
      type record_splitter
      tag foo.splitted
      split_key target_field
      keep_other_key true
      remove_keys ["general","other"]
    ]

    d.run do
      d.emit('common'=>'c','general'=>'g','other'=>'foo','target_field' => [{'k1'=>'v1'},{'k2'=>'v2'}])
    end

    assert_equal [
      {'common'=>'c','k1'=>'v1'},
      {'common'=>'c','k2'=>'v2'},
    ], d.records
  end

  def test_split_with_keep_keys
    d = create_driver %[
      type record_splitter
      tag foo.splitted
      split_key target_field
      keep_keys ["common","general"]
    ]

    d.run do
      d.emit('common'=>'c','general'=>'g','other'=>'foo','target_field' => [{'k1'=>'v1'},{'k2'=>'v2'}])
    end

    assert_equal [
      {'common'=>'c','general'=>'g','k1'=>'v1'},
      {'common'=>'c','general'=>'g','k2'=>'v2'},
    ], d.records
  end

end
