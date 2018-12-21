require "minitest/autorun"
require 'test_helper'

class UtilsTest < Minitest::Test
  def test_search_args_string
    assert_equal '"test string"', KatelloAttachSubscription::Utils.search_args('test string')
  end

  def test_search_args_hash
    assert_equal 'name="some product"', KatelloAttachSubscription::Utils.search_args({'name' => 'some product'})
  end

  def test_search_args_hash_with_symbols
    assert_equal 'name="some product"', KatelloAttachSubscription::Utils.search_args(name: 'some product')
  end

  def test_search_args_hash_with_many
    assert_equal 'name="some product" and something="else"', KatelloAttachSubscription::Utils.search_args(name: 'some product', something: 'else')
  end

  def test_search_args_array
    assert_equal 'something and else', KatelloAttachSubscription::Utils.search_args(['something', 'else', nil])
  end
end
