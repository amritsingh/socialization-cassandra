require File.expand_path(File.dirname(__FILE__))+'/test_helper'

class StringTest < Minitest::Test
  context "#deep_const_get" do
    should "return a class" do
      assert_equal Socialization, "Socialization".deep_const_get
      assert_equal Socialization::CassandraStores, "Socialization::CassandraStores".deep_const_get
      assert_equal Socialization::CassandraStores::Follow, "Socialization::CassandraStores::Follow".deep_const_get

      assert_raises(NameError) { "Foo::Bar".deep_const_get }
    end
  end
end
