require 'test_helper'
require_relative 'gathering_spec_helper'

include GatheringSpecHelper

describe GatheringUseCase do
  describe "create" do    
    def valid_attributes
      {
        :name => "Jane and John Doe Wedding",
        :description => "Jane and John Doe symbolically join their lives in the summer of 2013",
        :location => "Anywhere, USA"
      }
    end
    def new_user
      Factory.create(:user)
    end
  
    it "successfully creates and persists a new Gathering" do
      user = new_user
      response = use_gathering(:atts => valid_attributes, :user => user).create
      #puts response.errors
      response.ok?.must_equal(true)
      gathering = response.gathering
      gathering.id.wont_be_nil
      gathering.name.must_equal(valid_attributes[:name])
      gathering.description.must_equal(valid_attributes[:description])
      gathering.location.must_equal(valid_attributes[:location])
    end
    
    it "successfully creates and persists a new Gathering User as owner when creating a new Gathering" do
      user = new_user
      response = use_gathering(:atts => valid_attributes, :user => user).create
      response.ok?.must_equal(true)
      GatheringUser.find_by_gathering_and_user(response.gathering.id, user.id).wont_be_nil
    end
    
    it "returns errors if the create Gathering request is not valid" do
      user = new_user
      response = use_gathering(:atts => valid_attributes.merge(:name => ""), :user => user).create
      response.ok?.must_equal(false)
      response.errors.must_include(:gathering_name)
      response = use_gathering(:atts => valid_attributes.merge(:description => ""), :user => user).create
      response.ok?.must_equal(false)
      response.errors.must_include(:gathering_description)
      response = use_gathering(:atts => valid_attributes.merge(:location => ""), :user => user).create
      response.ok?.must_equal(true)
      response.errors.must_be_empty
      # Tests for non-persisted user
      response = use_gathering(:atts => valid_attributes, :user => User.new).create
      response.ok?.must_equal(false)
      response.errors.must_include(:record_not_found)
      response.errors[:record_not_found].item.must_equal(:user)
      user.destroy      
      response = use_gathering(:atts => valid_attributes, :user => user).create
      response.ok?.must_equal(false)
      response.errors.must_include(:record_not_found)
      response.errors[:record_not_found].item.must_equal(:user)
    end
    
    it "returns errors if creating Gathering with a duplicate name" do
      user = new_user
      gathering_orig = use_gathering(:atts => valid_attributes, :user => user).create.gathering
      response = use_gathering(:atts => valid_attributes.merge(:name => gathering_orig.name), :user => user).create
      response.ok?.must_equal(false)
      response.errors.must_include(:gathering_name)
    end
  end
end
