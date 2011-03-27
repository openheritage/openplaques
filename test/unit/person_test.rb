require 'test_helper'

class PersonTest < ActiveSupport::TestCase

  should validate_presence_of :name
  
#  should validate_uniqueness_of :wikipedia_url
#  should validate_uniqueness_of :dbpedia_uri  

  should have_many :plaques
  should have_many :roles
  should have_many :personal_roles
  should have_many :locations
  should have_many :verbs
  should have_many :personal_connections

  context "when creating a person" do

    setup { @person = Person.create(:name => "Jason Bourne")}

    should "set the index letter" do
      assert_equal "j", @person.index
    end
    
    teardown { @person.destroy }

  end

  context "when updating a person" do

    setup do
      @person = Person.create(:name => "Jason Bourne")
      @person.update_attributes(:name => "Simon Bourne")
    end

    should "update the index letter" do
      assert_equal "s", @person.index
    end
    
    teardown { @person.destroy }

  end


  should "validate uniqueness of DBpedia URI if not nil" do
    person = Person.new(:name => "Test", :dbpedia_uri => people(:winston_churchill).dbpedia_uri)
    assert !person.save
  end

  should "validate uniqueness of Wikipedia URL if not nil" do
    person = Person.new(:name => "Test", :wikipedia_url => people(:winston_churchill).wikipedia_url)
    assert !person.save
  end

  should "not require a Wikipedia URL" do
    person = Person.new(:name => "Test")
    assert person.save
  end
  
  def test_find_or_create_by_name_and_dates
    person = Person.find_or_create_by_name_and_dates("Mr Bob (1984-2009)")
    assert_equal "Mr Bob", person.name
    assert_equal "1984", person.born_on.year.to_s
    assert_equal "2009", person.died_on.year.to_s
  end
  
  def test_find_or_create_by_name_and_dates_with_single_name
    person = Person.find_or_create_by_name_and_dates("Madonna (1930-2004)")
    assert_equal "Madonna", person.name
    assert_equal "1930", person.born_on.year.to_s
    assert_equal "2004", person.died_on.year.to_s
  end
  
  def test_find_or_create_by_name_and_dates_and_roles_simple
    person = Person.find_or_create_by_name_and_dates_and_roles("Buzz Lightyear astronaut")
    assert_equal "Buzz Lightyear", person.name
    assert_equal "astronaut", person.roles.first.name
  end

  def test_find_or_create_by_name_and_dates_and_roles_with_dates
    person = Person.find_or_create_by_name_and_dates_and_roles("Buzz Lightyear (1984-2009) astronaut")
    assert_equal "Buzz Lightyear", person.name
    assert_equal "astronaut", person.roles.first.name
    assert_equal "1984", person.born_on.year.to_s
    assert_equal "2009", person.died_on.year.to_s    
  end

  def test_find_or_create_by_name_and_dates_and_roles_using_comma
    person = Person.find_or_create_by_name_and_dates_and_roles("Andreas Kalvos, Greek poet and patriot")
    assert_equal "Andreas Kalvos", person.name
    assert_equal "Greek poet", person.roles.first.name
    assert_equal "patriot", person.roles[1].name
  end

  def test_alphabetical_index
    Person.new(:name => "Boris Karloff").save
    person = Person.find_by_name("Boris Karloff")
    assert_equal "b", person.index
  end
  
  def test_create_person_with_middle_initial
    person = Person.find_or_create_by_name_and_dates_and_roles("George W. Bush")
    assert_equal "George W. Bush", person.name
  end
  
  def test_create_person_with_uncapitalised_name
    person = Person.find_or_create_by_name_and_dates_and_roles("Richard de Beers")
    assert_equal "Richard de Beers", person.name
  end
  
  def test_create_person_with_quoted_name
    person = Person.find_or_create_by_name_and_dates("Charles 'Elia' Lamb (1775-1834)")
    assert_equal "Charles 'Elia' Lamb", person.name
    assert_equal "1775", person.born_on.year.to_s
    assert_equal "1834", person.died_on.year.to_s
  end

  def test_create_person_with_hypenated_role
    person = Person.find_or_create_by_name_and_dates_and_roles("Ford Madox Brown (1821-1893) Pre-Raphaelite artist")
    assert_equal "Ford Madox Brown", person.name
    assert_equal "1821", person.born_on.year.to_s
    assert_equal "1893", person.died_on.year.to_s
    assert_equal 1, person.roles.size
    assert_equal "Pre-Raphaelite artist", person.roles.first.name
  end
  
  def test_create_person_with_quotes_name_2
    person = Person.find_or_create_by_name_and_dates_and_roles("Hablot Knight Browne alias 'Phiz' (1815-1882), illustrator of Dickens's novels")
    assert_equal "Hablot Knight Browne alias 'Phiz'", person.name
  end
  
  def test_create_person_with_quotes_at_beginning_of_name
    person = Person.find_or_create_by_name_and_dates_and_roles("'Father' Henry Willis (1821-1901), organ builder")
    assert_equal "'Father' Henry Willis", person.name
  end
  

end
