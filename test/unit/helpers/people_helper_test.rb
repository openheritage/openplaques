#require 'test_helper'
require File.dirname(__FILE__) + '/../../test_helper'

include RolesHelper 
  
class PeopleHelperTest < ActionView::TestCase

  context "dated_role()" do
    
    context "for a role with no dates" do
      
      setup do
        
        @person = Person.create(:name => "Blah")
        @role = Role.create(:name => "role", :slug => "role")
        @personal_role = PersonalRole.new
        @personal_role.role = @role
        @personal_role.person = @person
        
      end
      
      teardown do
        @person.destroy
        @role.destroy
      end
      
      should "display the role" do
        
        assert_equal dated_role(@personal_role), "<a href=\"" + role_path(@role) + "\" class=\"role\">" + @role.name + "</a>"
        
      end
      
      
    end
    
    
  end


  context "roles_list()" do
    
    setup do 
      
      
    end
    
    context "for a person with multiple roles" do
      
      setup do
        @person = Person.create(:name => "Test")
      
        @role1 = Role.create(:name => "role1", :slug => "role_one")
        @role2 = Role.create(:name => "role2", :slug => "role_two")
        @role3 = Role.create(:name => "role3", :slug => "role_three")
        
        @person.roles = [@role1, @role2, @role3]
      end
      
      teardown do
        @person.destroy
        @role1.destroy
        @role2.destroy
        @role3.destroy
      end
      
      should "return a list of linked roles, separated by a comma" do
        
        expected = '<p class="roles"><a href="/roles/role_one" class="role">role1</a>, <a href="/roles/role_two" class="role">role2</a>, and <a href="/roles/role_three" class="role">role3</a></p>'
        
        assert_equal(expected, roles_list(@person))
        
        
      end
      
      
    end
    
    
  end
  

  context "wikipedia_url()" do

    context "for a Person with an explicit wikipedia_url set" do
      
      setup do 
        @wikipedia_url = "http://en.wikipedia.org/wiki/Sherlock_Holmes"
        @person = Person.new(:wikipedia_url => @wikipedia_url)        
      end
      
      should "return the value of the wikipedia_url attribute" do
        assert_equal(@wikipedia_url, wikipedia_url(@person))
      end
      
    end
    
    context "for a Person with a name but no wikipedia_url set" do
      
      setup do
        @person = Person.new(:name => "Sherlock Holmes")
      end
      
      should "return a guessed English language wikipedia url based on the name, with spaces replaced by underscores" do
        assert_equal("http://en.wikipedia.org/wiki/Sherlock_Holmes", wikipedia_url(@person))
      end
      
    end
    
    context "for a Person with a name prefixed with 'Captain' but no wikipedia_url set" do
      setup do
        @person = Person.new(:name => "Captain Frederick Marryat")
      end

      should "return a guessed English language wikipedia url based on the name, with the prefix removed and spaces replaced by underscores" do      
        assert_equal("http://en.wikipedia.org/wiki/Frederick_Marryat", wikipedia_url(@person))
      end
    end
  end

# Commenting out all of these tests as they're liable to change whenever the Wikipedia content changes, plus require
# network access.
# TODO: These could be re-implemented by using mocked responses (from Wikipedia).
#
=begin
  test "Wikipedia summary first para" do
    expecting = "Arthur Onslow (1 October 1691 – 17 February 1768) was an English politician. He set a record for length of service when repeatedly elected to serve as Speaker of the House of Commons, where he was known for his integrity."
    actual = wikipedia_summary("http://en.wikipedia.org/wiki/Arthur_Onslow")
    assert_equal(expecting, actual)
  end

  test "Wikipedia summary array" do
    expecting = "Onslow was born in Kensington, the elder son of Foot Onslow (died 1710) and his wife Susannah. He was educated at The Royal Grammar School, Guildford and Winchester College and matriculated at Wadham College, Oxford in 1708, although he took no degree. He was called to the bar at the Middle Temple in 1713, but had no great practice in law. When George I came to the throne, Onslow's uncle Sir Richard Onslow was appointed Chancellor of the Exchequer. Arthur became his private secretary. When Richard left office in 1715, Arthur obtained a place as receiver general of the Post Office. He became recorder of Guildford in 1719. As his Post Office position was not compatible with a parliamentary seat, he passed it on to his younger brother Richard when he entered Parliament in 1720 for Guildford.[1]"
    actual = wikipedia_summary_each("http://en.wikipedia.org/wiki/Arthur_Onslow", [2,3])
    assert_equal(expecting, actual)
  end

  test "Wikipedia summary array string" do
    expecting = "Onslow was born in Kensington, the elder son of Foot Onslow (died 1710) and his wife Susannah. He was educated at The Royal Grammar School, Guildford and Winchester College and matriculated at Wadham College, Oxford in 1708, although he took no degree. He was called to the bar at the Middle Temple in 1713, but had no great practice in law. When George I came to the throne, Onslow's uncle Sir Richard Onslow was appointed Chancellor of the Exchequer. Arthur became his private secretary. When Richard left office in 1715, Arthur obtained a place as receiver general of the Post Office. He became recorder of Guildford in 1719. As his Post Office position was not compatible with a parliamentary seat, he passed it on to his younger brother Richard when he entered Parliament in 1720 for Guildford.[1]"
    actual = wikipedia_summary_each("http://en.wikipedia.org/wiki/Arthur_Onslow", "[2,3]")
    assert_equal(expecting, actual)
  end

  test "Wikipedia summary single" do
    expecting = "When George I came to the throne, Onslow's uncle Sir Richard Onslow was appointed Chancellor of the Exchequer. Arthur became his private secretary. When Richard left office in 1715, Arthur obtained a place as receiver general of the Post Office. He became recorder of Guildford in 1719. As his Post Office position was not compatible with a parliamentary seat, he passed it on to his younger brother Richard when he entered Parliament in 1720 for Guildford.[1]"
    actual = wikipedia_summary_each("http://en.wikipedia.org/wiki/Arthur_Onslow", "3")
    assert_equal(expecting, actual)
  end

  test "Wikipedia summary single number" do
    expecting = "When George I came to the throne, Onslow's uncle Sir Richard Onslow was appointed Chancellor of the Exchequer. Arthur became his private secretary. When Richard left office in 1715, Arthur obtained a place as receiver general of the Post Office. He became recorder of Guildford in 1719. As his Post Office position was not compatible with a parliamentary seat, he passed it on to his younger brother Richard when he entered Parliament in 1720 for Guildford.[1]"
    actual = wikipedia_summary_each("http://en.wikipedia.org/wiki/Arthur_Onslow", 3)
    assert_equal(expecting, actual)
  end

  test "Wikipedia summary" do
    expecting = "Onslow was born in Kensington, the elder son of Foot Onslow (died 1710) and his wife Susannah. He was educated at The Royal Grammar School, Guildford and Winchester College and matriculated at Wadham College, Oxford in 1708, although he took no degree. He was called to the bar at the Middle Temple in 1713, but had no great practice in law. When George I came to the throne, Onslow's uncle Sir Richard Onslow was appointed Chancellor of the Exchequer. Arthur became his private secretary. When Richard left office in 1715, Arthur obtained a place as receiver general of the Post Office. He became recorder of Guildford in 1719. As his Post Office position was not compatible with a parliamentary seat, he passed it on to his younger brother Richard when he entered Parliament in 1720 for Guildford.[1]"
    actual = wikipedia_summary_each("http://en.wikipedia.org/wiki/Arthur_Onslow", "2,3")
    assert_equal(expecting, actual)
  end

=end
  
  context "dated_person" do
  
    context "when the person has birth and death dates" do

      should "display both dates" do

        birth_date = Date.parse("1970-05-05")
        death_date = Date.parse("1990-03-12")

        a_person = Person.new(:born_on => birth_date, :died_on => death_date)
        
        age = age(birth_date)

        expecting = "<span class=\"fn\" property=\"rdfs:label foaf:name vcard:fn\"></span> (<a href=\"/people/born_on/1970\" about=\"/people/#person\" class=\"bday\" content=\"1970\" datatype=\"xsd:date\" property=\"dbpprop:dateOfBirth vcard:bday\">1970</a>&#8202;–&#8202;<a href=\"/people/died_on/1990\" about=\"/people/#person\" content=\"1990\" datatype=\"xsd:date\" property=\"dbpprop:dateOfDeath\">1990</a>)"        
        actual = dated_person(a_person, {:links => :none})
        assert_equal(expecting, actual)
      end
      
    end

    context "when the person only has a birth date" do

      should "display only the birth date" do

        birth_date = Date.parse("1970-05-05")
        a_person = Person.new(:born_on => birth_date)
        
        age = age(birth_date)
        
        expecting = "<span class=\"fn\" property=\"rdfs:label foaf:name vcard:fn\"></span> (born <a href=\"/people/born_on/1970\" about=\"/people/#person\" class=\"bday\" content=\"1970\" datatype=\"xsd:date\" property=\"dbpprop:dateOfBirth vcard:bday\">1970</a><span property=\"foaf:age\" content=\"#{age}\" />)"
        actual = dated_person(a_person, {:links => :none})
        assert_equal(expecting, actual)
      end

    end
    
    context "when the person only has a death date" do
      
      should "display only the date of death" do

        a_person = Person.new
        a_person.died_on = "1970-01-01"

        expecting = "<span class=\"fn\" property=\"rdfs:label foaf:name vcard:fn\"></span> (died <a href=\"/people/died_on/1970\" about=\"/people/#person\" content=\"1970\" datatype=\"xsd:date\" property=\"dbpprop:dateOfDeath\">1970</a>)"

        actual = dated_person(a_person, {:links => :none})
        assert_equal(expecting, actual)
      end
      
    end
    
  end
  
  


end