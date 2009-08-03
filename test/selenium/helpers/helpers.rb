  def enter_new_person_data(title,first_name,surname,sex, notes)
    @selenium.select "person_title", title
    @selenium.type "person_first_name", first_name
    @selenium.type "person_surname", surname
    @selenium.select "person_sex", sex
    @selenium.type "person_notes", notes
  end

  def enter_link_data(id,link_category,start_date,end_date,notes)
    @selenium.select "//*[@id='" + id + "']/td/form/select[@id='link_category']", link_category
    @selenium.type "//*[@id='" + id + "']/td/form/input[@id='start_date']", start_date
    @selenium.type "//*[@id='" + id + "']/td/form/input[@id='end_date']", end_date
    @selenium.type "//*[@id='" + id + "']/td/form/input[@id='notes']", notes
    @selenium.click "//*[@id='" + id + "']/td/form/input[@name='commit']"
    medium_wait
  end

  def medium_wait
    @selenium.wait_for_page_to_load "30000"
  end