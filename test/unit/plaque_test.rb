require 'test_helper'

class PlaqueTest < ActiveSupport::TestCase

  should validate_presence_of :user

  should belong_to :location
  should belong_to :colour
  should belong_to :language
  should have_many :organisations
  should belong_to :user
  should belong_to :plaque_erected_year

  should have_one :area

  should have_many :personal_connections
  should have_many :photos

  context "#geolocated" do

    should "return only plaques with latitude and longitude" do
      assert_equal [plaques(:geolocated_plaque)], Plaque.geolocated
    end

  end

  context "#ungeolocated" do

    should "return only plaques without latitude or longitude" do
      # TODO: Find some way of making this test less brittle, as it currently relies on Fixtures.
      assert_equal [plaques(:jez_plaque), plaques(:churchill_daleks), plaques(:frankie_sheffield_plaque)], Plaque.ungeolocated
    end

  end

  def test_parse_simple_inscription
    plaque = Plaque.new(:inscription => "Frankie Roberto lived here.", :location => Location.find_or_create_by_name("Flat B4-7"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "Frankie Roberto", plaque.personal_connections.first.person.name
    assert_equal "Flat B4-7", plaque.personal_connections.first.location.name
  end

  def test_take_location_from_inscription
    plaque = Plaque.new(:inscription => "Frankie Roberto lived at Flat B4-7", :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "Frankie Roberto", plaque.personal_connections.first.person.name
    assert_equal "Flat B4-7", plaque.personal_connections.first.location.name
  end

  def test_two_verbs
    plaque = Plaque.new(:inscription => "Frankie Roberto lived and worked at Flat B4-7", :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 2, plaque.personal_connections.size
    assert_equal "Frankie Roberto", plaque.personal_connections.first.person.name
    assert_equal "Flat B4-7", plaque.personal_connections.first.location.name
    assert_equal "lived", plaque.personal_connections.first.verb.name
    assert_equal "Frankie Roberto", plaque.personal_connections[1].person.name
    assert_equal "Flat B4-7", plaque.personal_connections[1].location.name
    assert_equal "worked", plaque.personal_connections[1].verb.name
  end

  def test_personal_connection_dates
    plaque = Plaque.new(:inscription => "Frankie Roberto lived here 2001-2002", :location => Location.find_or_create_by_name("Flat 10"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "Frankie Roberto", plaque.personal_connections.first.person.name
    assert_equal "Flat 10", plaque.personal_connections.first.location.name
    assert_equal "lived", plaque.personal_connections.first.verb.name
    assert_equal "2001", plaque.personal_connections.first.started_at.year.to_s
    assert_equal "2002", plaque.personal_connections.first.ended_at.year.to_s
  end

  # This one doesn't pass yet.
  def failing_test_two_subjects
    plaque = Plaque.new(:inscription => "Frankie Roberto and Fiona Stewart lived at Flat B4-7", :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 2, plaque.personal_connections.size
    assert_equal "Frankie Roberto", plaque.personal_connections.first.person.name
    assert_equal "Flat B4-7", plaque.personal_connections.first.location.name
    assert_equal "lived", plaque.personal_connections.first.verb.name
    assert_equal 0, plaque.personal_connections.first.person.roles.size
    assert_equal "Fiona Stewart", plaque.personal_connections[1].person.name
    assert_equal "Flat B4-7", plaque.personal_connections[1].location.name
    assert_equal "lived", plaque.personal_connections[1].verb.name
    assert_equal 0, plaque.personal_connections[1].person.roles.size
  end

  def test_inscription_with_dates_and_roles
    plaque = Plaque.new(:inscription => "George Seferis (1900-1971), Greek Ambassador, poet and Nobel laureate, lived here 1957-1962.", :location => Location.find_or_create_by_name("51 Upper Brook Street, W1 Westminster"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "George Seferis", plaque.personal_connections.first.person.name
  end

  def test_name_with_uncapitalised_word
    plaque = Plaque.new(:inscription => "Thomas de Quincy (1785-1859) wrote 'Confessions of an English Opium Eater' in this house", :location => Location.find_or_create_by_name("Nowhere"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "Thomas de Quincy", plaque.personal_connections.first.person.name
  end

  def test_name_with_initial_initials
    plaque = Plaque.new(:inscription => "H. G. Wells (1866-1946), writer, lived and died here.", :location => Location.find_or_create_by_name("Nowhere"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 2, plaque.personal_connections.size
    assert_equal "H. G. Wells", plaque.personal_connections.first.person.name
    assert_equal "lived", plaque.personal_connections.first.verb.name
  end

  def test_name_with_title_suffix
    plaque = Plaque.new(:inscription => "F. E. Smith, Earl of Birkenhead (1872-1930), lawyer and statesman, lived here.", :location => Location.find_or_create_by_name("Nowhere"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "F. E. Smith, Earl of Birkenhead", plaque.personal_connections.first.person.name
  end

  def test_name_with_quote_marks
    plaque = Plaque.new(:inscription => "Charles 'Elia' Lamb (1775-1834), essayist, lived here.", :location => Location.find_or_create_by_name("Nowhere"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
  end

  def test_role_with_hypen
    plaque = Plaque.new(:inscription => "Ford Madox Brown (1821-1893), Pre-Raphaelite artist lived here", :location => Location.find_or_create_by_name("Nowhere"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "Ford Madox Brown", plaque.personal_connections.first.person.name
    assert_equal 1, plaque.personal_connections.first.person.roles.size
    assert_equal "Pre-Raphaelite artist", plaque.personal_connections.first.person.roles.first.name
  end

  def test_person_with_three_initials
    plaque = Plaque.new(:inscription => "J. W. M. Turner lived here", :location => Location.find_or_create_by_name("Nowhere"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "J. W. M. Turner", plaque.personal_connections.first.person.name
  end

  def test_person_with_quoted_alias_name
    plaque = Plaque.new(:inscription => "Hablot Knight Browne alias 'Phiz' (1815-1882), illustrator of Dickens's novels, lived here 1874-1880", :location => Location.find_or_create_by_name("Nowhere"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.size
    assert_equal "Hablot Knight Browne alias 'Phiz'", plaque.personal_connections.first.person.name
  end

  def test_create_person_with_quotes_at_beginning_of_name
    plaque = Plaque.new(:inscription => "'Father' Henry Willis (1821-1901), organ builder, lived here", :location => Location.find_or_create_by_name("Nowhere"), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    assert_equal "'Father' Henry Willis", plaque.personal_connections.first.person.name
  end

  def test_name_containing_of
    plaque = Plaque.new(:inscription => "Ada Countess of Lovelace (1815-1852), pioneer of computing lived here.", :location => locations(:innovation_centre), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal 1, plaque.personal_connections.first.person.roles.size
    assert_equal "pioneer of computing", plaque.personal_connections.first.person.roles.first.name
  end

  def test_name_containing_brackets_and_initials_with_no_space
    plaque = Plaque.new(:inscription => "G.A. Henty (George Alfred) (1832-1902), author, lived here.", :location => locations(:innovation_centre), :user => users(:aaron))
    plaque.save!
    plaque.parse_inscription
    plaque.reload
    assert_equal "G.A. Henty (George Alfred)", plaque.personal_connections.first.person.name
  end

end
