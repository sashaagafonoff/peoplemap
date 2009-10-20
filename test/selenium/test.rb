require 'fileutils'
require "selenium"
require "test/unit"
require File.dirname(__FILE__) + '/helpers/helpers.rb'

class NewTest < Test::Unit::TestCase
  def setup
    # delete test folders to clear old data (restart test server before running tests)
    FileUtils.rm_rf '../../db/lucene_test'
    FileUtils.rm_rf '../../db/neo4j_test'
    #
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      @selenium = Selenium::SeleniumDriver.new("localhost", 4444, "*firefox", "http://localhost:3001", 10000);
      @selenium.start
    end
    @selenium.set_context("test_new")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end
  
#  def test_clean_data # delete test folders to clear old data (restart test server before running tests)
#    FileUtils.rm_rf '../../db/lucene_test'
#    FileUtils.rm_rf '../../db/neo4j_test'
#  end
  
  def test_1_people 
    
    # populate with Person data
    @selenium.open "/people"
    wait

    @selenium.click "//*[@href='/people/new']"
    wait
    enter_new_person_data("Mr","Burt","Reynolds","Male","These are some notes")
    wait
    assert @selenium.is_text_present("Burt Reynolds")

    @selenium.open "/people/new"
    wait
    enter_new_person_data("Ms","Dolly","Parton","Female","These are some notes")
    wait
    assert @selenium.is_text_present("Dolly Parton")

    @selenium.open "/people/new"
    wait
    enter_new_person_data("Ms","Sheena","Easton","Female","These are some notes")
    wait
    assert @selenium.is_text_present("Sheena Easton")

    # basic link tests
    @selenium.open "/people"
    wait
    @selenium.click "//*[@href='/people/2']" # burt reynolds
    wait
    enter_link_data("3","is the boyfriend of","2009-08-02","2010-08-02","Here are some notes about this relationship")
    wait
    assert @selenium.is_text_present("Burt Reynolds is the boyfriend of Dolly Parton")
    
    # now check that link is picked up from end node
    @selenium.open "/people"
    wait
    @selenium.click "//*[@href='/people/3']" # Dolly Parton
    wait
    assert @selenium.is_text_present("Burt Reynolds is the boyfriend of Dolly Parton")

    # deeper linking
    @selenium.open "/people"
    wait
    @selenium.click "//*[@href='/people/4']" # Sheena Easton
    wait
    enter_link_data("2","is the girlfriend of","2009-08-02","2010-08-02","Here are some notes about this relationship")
    wait
    assert @selenium.is_text_present("Sheena Easton is the girlfriend of Burt Reynolds")
  end
  
  def test_2_organisations 
    
    # populate org data
    @selenium.open "/organisations"
    wait
    @selenium.click "//*[@href='/organisations/new']"
    wait
    enter_new_organisation_data("Records R Us","Private Sector","Terrorism","These are some notes") #5
    wait
    assert @selenium.is_text_present("Records R Us")

    @selenium.open "/organisations/new"
    wait
    enter_new_organisation_data("Big Brother","Government","Acrobatics","These are some notes") #6
    wait
    assert @selenium.is_text_present("Big Brother")

    # basic link tests
    @selenium.open "/organisations"
    wait
    @selenium.click "//*[@href='/organisations/5']" # Records R Us
    wait
    enter_link_data("6","is the competitor of","2009-08-02","2010-08-02","Here are some notes about this relationship")
    wait
    assert @selenium.is_text_present("Records R Us is the competitor of Big Brother")
    
    # now check that link is picked up from end node
    @selenium.open "/organisations"
    wait
    @selenium.click "//*[@href='/organisations/6']" # Big Brother
    wait
    assert @selenium.is_text_present("Records R Us is the competitor of Big Brother")
  end
  
  def test_3_locations 
    
    # populate loc data
    @selenium.open "/locations"
    wait
    
    @selenium.click "//*[@href='/locations/new']"
    wait # street_number,street_name,street_type,suburb,city,country,postcode,notes
    enter_new_location_data("12","Sullivan","Crescent","Wanniassa","Canberra","Australia","2709","These are some notes") #7
    wait
    assert @selenium.is_text_present("12 Sullivan Crescent")
    
    @selenium.open "/locations/new"
    wait
    enter_new_location_data("15","Earle","Street","Garran","Canberra","Australia","2309","These are some notes") #8
    wait
    assert @selenium.is_text_present("15 Earle Street")

    # basic link tests
    @selenium.open "/locations"
    wait
    @selenium.click "//*[@href='/locations/7']" # 12 Sullivan Crescent
    wait
    enter_link_data("8","is related to","2009-08-02","2010-08-02","Here are some notes about this relationship")
    wait
    assert @selenium.is_text_present("12 Sullivan Crescent Wanniassa is related to 15 Earle Street Garran")
    
    # now check that link is picked up from end node
    @selenium.open "/locations"
    wait
    @selenium.click "//*[@href='/locations/8']" # 15 Earle Street
    wait
    assert @selenium.is_text_present("12 Sullivan Crescent Wanniassa is related to 15 Earle Street Garran")
  end
  
  def test_4_events 
    
    # populate event data
    @selenium.open "/events"
    wait
    
    @selenium.click "//*[@href='/events/new']"
    wait # :title, :description, :event_type, :start_date, :end_date, :notes
    enter_new_event_data("Mega-Conference 2009","Super conference","Conference","2009-08-20","2009-08-20","These are some notes") #9
    wait
    assert @selenium.is_text_present("Mega-Conference 2009")
    
    @selenium.open "/events/new"
    wait
    enter_new_event_data("AFTER PARTY 2009","After-conference party for hangers on","Party","2009-08-20","2009-08-20","These are some notes") #10
    wait
    assert @selenium.is_text_present("AFTER PARTY 2009")

    # basic link tests
    @selenium.open "/events"
    wait
    @selenium.click "//*[@href='/events/9']" # Mega-Conference 2009
    wait
    enter_link_data("10","is related to","2009-08-02","2010-08-02","The after party for attendees of Mega-Conference 2009")
    wait
    assert @selenium.is_text_present("Mega-Conference 2009 is related to AFTER PARTY 2009")
    
    # now check that link is picked up from end node
    @selenium.open "/events"
    wait
    @selenium.click "//*[@href='/events/10']" # AFTER PARTY 2009
    wait
    assert @selenium.is_text_present("Mega-Conference 2009 is related to AFTER PARTY 2009")
  end
  
  def test_5_references 
    
    # populate reference data
    @selenium.open "/references"
    wait
    
    @selenium.click "//*[@href='/references/new']"
    wait # reference_type,ref_value,notes
    enter_new_reference_data("Email Address","groover@404.com.au","These are some notes") #11
    wait
    assert @selenium.is_text_present("groover@404.com.au")
    
    @selenium.open "/references/new"
    wait
    enter_new_reference_data("Home Phone Number","+612 6200 0200","These are some notes") #12
    wait
    assert @selenium.is_text_present("+612 6200 0200")

    # basic link tests
    @selenium.open "/references"
    wait
    @selenium.click "//*[@href='/references/11']" # 
    wait
    enter_link_data("12","is related to","2009-08-02","2010-08-02","Some relationship or other")
    wait
    assert @selenium.is_text_present("groover@404.com.au is related to +612 6200 0200")
    
    # now check that link is picked up from end node
    @selenium.open "/references"
    wait
    @selenium.click "//*[@href='/references/12']" # 
    wait
    assert @selenium.is_text_present("groover@404.com.au is related to +612 6200 0200")
  end

  def test_6_cross_linking
    @selenium.open "/people"
    wait
    @selenium.click "//*[@href='/people/2']" # Burt Reynolds
    wait
    enter_link_data("5","is the founder of","2009-08-02","2010-08-02","Here are some notes about this relationship")
    wait
    assert @selenium.is_text_present("Burt Reynolds is the founder of Records R Us")
    enter_link_data("7","has the home address of","2009-08-02","2010-08-02","Here are some notes about this relationship")
    wait
    assert @selenium.is_text_present("Burt Reynolds has the home address of 12 Sullivan Crescent Wanniassa")
    enter_link_data("9","is a participant in","2009-08-02","2010-08-02","Here are some notes about this relationship")
    wait
    assert @selenium.is_text_present("Burt Reynolds is a participant in Mega-Conference 2009")
    enter_link_data("11","has the email address of","2009-08-02","2010-08-02","Here are some notes about this relationship")
    wait
    assert @selenium.is_text_present("Burt Reynolds has the email address of groover@404.com.au")
  end
  
end