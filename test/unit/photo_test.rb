require 'test_helper'

class PhotoTest < ActiveSupport::TestCase

  should validate_presence_of(:plaque)
  should validate_presence_of(:file_url)
  should validate_presence_of(:licence)

  should belong_to :plaque
  should belong_to :licence

  context "when photo is associated with a plaque that has a user" do

    setup do
      plaque = Plaque.new(:user => users(:frankieroberto))
      @photo = Photo.new(:plaque => plaque)
      @licence = licences(:ccby )
    end

    context "when photo has accept_cc_by_licence" do
  
      setup { @photo.accept_cc_by_licence = true }
  
      context "when the photo is saved" do
        
        setup { @photo.save }
        
        should "set the licence as CC-BY" do          
          assert_equal(@licence, @photo.licence)
        end
        
        should "set the photographer as the name of the user who created the plaque" do
          assert_equal(users(:frankieroberto).name, @photo.photographer)
        end
      
      end
      
    end
    
  end
      
      

  context "when initializing a Photo with a photo_url" do

    context "when the photo_url is a Flickr photo page" do
      setup do
        @photo_url = "http://www.flickr.com/photos/frankieroberto/5565844922/"
        @photo = Photo.new(:photo_url => @photo_url)
      end
    
      should "assign the url as the photo url" do
        assert_equal(@photo_url, @photo.url)        
      end
      
    end    

    
    context "when the photo_url is not recognised" do
      setup do
        @photo_url = "http://www.test.com/image.jpg"
        @photo = Photo.new(:photo_url => @photo_url)
      end
    
      should "assign the file_url as the photo url" do
        assert_equal(@photo_url, @photo.file_url)
      end
    end    

  end


end
