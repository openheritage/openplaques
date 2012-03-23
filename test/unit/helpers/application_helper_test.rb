require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  context "alternate_link_to" do

    context "when specifying the format as XML" do

      setup do
        @link = alternate_link_to("text", "/homepage.xml", :xml)
      end


      should 'include "alternate"' do
        assert_match /alternate/, @link
      end

      should 'include type="application/xml"' do
        assert_match /type=\"application\/xml\"/, @link
      end


    end


  end

end
