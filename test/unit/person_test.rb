require 'test_helper'

around_filter :neo_tx

class PersonTest < Test::Unit::TestCase

  context "Add a person" do
    setup do
      # property :title, :first_name, :middle_names, :surname, :maternal_name, :date_of_birth, :classification, :sex, :notes
      @object = Person.new
      @object.first_name = "Homer"
      @object.surname = "Simpson"
      @object.sex = "Male"
    end

    should "create a new person node" do
      assert_equal 'Homer', @object.first_name
    end
  end
end
