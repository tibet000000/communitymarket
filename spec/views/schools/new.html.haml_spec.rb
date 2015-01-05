require 'rails_helper'

RSpec.describe "schools/new", :type => :view do
  before(:each) do
    assign(:school, School.new(
      :name => "MyString",
      :location => "MyString"
    ))
  end

  it "renders new school form" do
    render

    assert_select "form[action=?][method=?]", schools_path, "post" do

      assert_select "input#school_name[name=?]", "school[name]"

      assert_select "input#school_location[name=?]", "school[location]"
    end
  end
end
