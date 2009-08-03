require 'FileUtils'
require "selenium"
require "test/unit"
require File.dirname(__FILE__) + '/helpers/helpers.rb'

class NewTest < Test::Unit::TestCase
  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleniumDriver.new("localhost", 4444, "*firefox", "http://localhost:3003", 10000);
      @selenium.start
    end
    @selenium.set_context("test_new")
  end

  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
  def test_clean_data # delete test folders to clear old data (restart test server before running tests)
    FileUtils.rm_rf '../../db/lucene_test'
    FileUtils.rm_rf '../../db/neo4j_test'
  end

  def test_data_people
    @selenium.open "/people"
    medium_wait
    @selenium.click "//html/body/p/a[@href='/people/new']"
    medium_wait
    enter_new_person_data("Mr","Burt","Reynolds","Male","These are some notes")
    @selenium.click "person_submit"
    medium_wait
    assert @selenium.is_text_present("Burt Reynolds")
    @selenium.open "/people/new"
    medium_wait
    enter_new_person_data("Ms","Dolly","Parton","Female","These are some notes")
    @selenium.click "person_submit"
    medium_wait
    assert @selenium.is_text_present("Dolly Parton")
    @selenium.open "/people/new"
    medium_wait
    enter_new_person_data("Ms","Sheena","Easton","Female","These are some notes")
    @selenium.click "person_submit"
    medium_wait
    assert @selenium.is_text_present("Sheena Easton")
  end
  
  def test_link_people
    @selenium.open "/people"
    medium_wait
    @selenium.click "//*[@href='/people/2']" # burt reynolds
    medium_wait
    enter_link_data("3","Friend","2009-08-02","2010-08-02","Here are some notes about this relationship")
    assert @selenium.is_text_present("Burt Reynolds is the friend of Dolly Parton")
    enter_link_data("3","Boy/Girlfriend","2009-08-02","2010-08-02","Here are some notes about this relationship")
    assert @selenium.is_text_present("Burt Reynolds is the boyfriend of Dolly Parton")
    @selenium.open "/people"
    medium_wait
    @selenium.click "//*[@href='/people/3']" # Dolly Parton
    medium_wait
    assert @selenium.is_text_present("Burt Reynolds is the boyfriend of Dolly Parton")
  end

  def test_link_people_deeper
    @selenium.open "/people"
    medium_wait
    @selenium.click "//*[@href='/people/4']" # Sheena Easton
    medium_wait
    enter_link_data("2","Boy/Girlfriend","2009-08-02","2010-08-02","Here are some notes about this relationship")
    assert @selenium.is_text_present("Sheena Easton is the girlfriend of Burt Reynolds")
    assert @selenium.is_text_present("Burt Reynolds is the boyfriend of Dolly Parton")
   end
end