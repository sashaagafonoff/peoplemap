  def enter_link_data(id,link_category,start_date,end_date,notes)
    @selenium.select "//*[@id='" + id + "']/form/select[@id='link_category']", link_category
    @selenium.type "//*[@id='" + id + "']/form/input[@id='start_date']", start_date
    @selenium.type "//*[@id='" + id + "']/form/input[@id='end_date']", end_date
    @selenium.type "//*[@id='" + id + "']/form/input[@id='notes']", notes
    @selenium.click "//*[@id='" + id + "']/form/input[@name='commit']"
    wait
  end

  # :title, :first_name, :middle_names, :surname, :maternal_name, :date_of_birth, :classification, :sex, :notes
  def enter_new_person_data(title,first_name,surname,sex, notes)
    @selenium.select "person_title", title
    @selenium.type "person_first_name", first_name
    @selenium.type "person_surname", surname
    @selenium.select "person_sex", sex
    @selenium.type "person_notes", notes
    
    @selenium.click "person_submit"
    wait
  end

  # :name, :sector, :industry, :notes
  def enter_new_organisation_data(name,sector,industry, notes)
    @selenium.type "organisation_name", name
    @selenium.select "organisation_sector", sector
    @selenium.select "organisation_industry", industry
    @selenium.type "organisation_notes", notes
    
    @selenium.click "organisation_submit"
    wait
  end

  # :apt_office_floor_number, :street_number, :street_name, :street_type, :suburb, :city, :country, :postcode, :notes
  def enter_new_location_data(street_number,street_name,street_type,suburb,city,country,postcode,notes)
    @selenium.type "location_street_number", street_number
    @selenium.type "location_street_name", street_name
    @selenium.select "location_street_type", street_type
    @selenium.type "location_suburb", suburb
    @selenium.type "location_city", city
    @selenium.select "location_country", country
    @selenium.type "location_postcode", postcode
    @selenium.type "location_notes", notes

    @selenium.click "location_submit"
    wait
  end
  
  # :title, :description, :event_type, :start_date, :end_date, :notes
  def enter_new_event_data(title,description,event_type,start_date,end_date,notes)
    @selenium.type "event_title", title
    @selenium.type "event_description", description
    @selenium.select "event_event_type", event_type
    @selenium.type "event_start_date", start_date
    @selenium.type "event_end_date", end_date
    @selenium.type "event_notes", notes

    @selenium.click "event_submit"
    wait
  end

  # :reference_type,ref_value,notes
  def enter_new_reference_data(reference_type,ref_value,notes)
    @selenium.select "reference_reference_type", reference_type
    @selenium.type "reference_ref_value", ref_value
    @selenium.type "reference_notes", notes

    @selenium.click "reference_submit"
    wait
  end

  def wait
    @selenium.wait_for_page_to_load "25000"
  end