class BatchController < ApplicationController

  layout 'layout'

  def index
  end

  def load_lots
    # load_batch_data
    i=2 # general counter (node creation starts with id 2
    c=2 # start with node 2, then switch to 3, then 4, etc
    n=0 # hook 15 nodes onto the current node (id=c)
    while (i<151) do
      @person = Person.new
      @person.update(:title=>"Mr",:first_name=>i.to_s+"a",:surname=>"",:date_of_birth=>"2010-01-01",:sex=>"Male",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
      if (i>2) then
        if (n>14) then
          c=c+1 # increment c to the next id
          n=0   # reset 15X counter
        end
        @target = Neo4j.load(c)
        rel = @person.person_to_person.new(@target)
        rel.name = "person_to_person_friend"
        rel.start_date = "2010-01-01"
        rel.end_date = ""
        rel.notes = "created by batch loader"
      end
      i=i+1
      n=n+1
    end
  end

  def load_simpsons
    @person = Person.new # 2
    @person.update(:title=>"Mr",:first_name=>"Homer",:surname=>"Simpson",:date_of_birth=>"1965-01-01",:sex=>"Male",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new # 3
    @person.update(:title=>"Master",:first_name=>"Bart",:surname=>"Simpson",:date_of_birth=>"1995-01-01",:sex=>"Male",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new # 4
    @person.update(:title=>"Mrs",:first_name=>"Marge",:surname=>"Simpson",:date_of_birth=>"1965-01-01",:sex=>"Female",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new #5
    @person.update(:title=>"Miss",:first_name=>"Lisa",:surname=>"Simpson",:date_of_birth=>"1997-01-01",:sex=>"Female",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #6
    @person.update(:title=>"Miss",:first_name=>"Maggie",:surname=>"Simpson",:date_of_birth=>"1999-01-01",:sex=>"Female",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #7
    @person.update(:title=>"Mr",:first_name=>"Montgomery",:surname=>"Burns",:date_of_birth=>"1935-01-01",:sex=>"Male",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #8
    @person.update(:title=>"Ms",:first_name=>"Jacqueline",:surname=>"Bouvier",:date_of_birth=>"1935-01-01",:sex=>"Female",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #9
    @person.update(:title=>"Ms",:first_name=>"Patty",:surname=>"Bouvier",:date_of_birth=>"1965-01-01",:sex=>"Female",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #10
    @person.update(:title=>"Ms",:first_name=>"Selma",:surname=>"Bouvier",:date_of_birth=>"1965-01-01",:sex=>"Female",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #11
    @person.update(:title=>"Mr",:first_name=>"Ned",:surname=>"Flanders",:date_of_birth=>"1965-01-01",:sex=>"Male",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #12
    @person.update(:title=>"Mrs",:first_name=>"Maude",:surname=>"Flanders",:date_of_birth=>"1965-01-01",:sex=>"Female",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #13
    @person.update(:title=>"Master",:first_name=>"Rod",:surname=>"Flanders",:date_of_birth=>"1995-01-01",:sex=>"Male",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #14
    @person.update(:title=>"Master",:first_name=>"Todd",:surname=>"Flanders",:date_of_birth=>"1999-01-01",:sex=>"Male",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #15
    @person.update(:title=>"Miss",:first_name=>"Jessica",:surname=>"Lovejoy",:date_of_birth=>"1995-01-01",:sex=>"Female",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")
    @person = Person.new  #16
    @person.update(:title=>"Reverend",:first_name=>"Timothy",:surname=>"Lovejoy",:date_of_birth=>"1945-01-01",:sex=>"Male",:facebook_uid=>"",:twitter_screen_name=>"",:notes=>"created by batch process")

    linker(:origin_id=>2,:origin_type=>"person",:target_id=>3,:target_type=>"person",:link_category=>"person_to_person_father",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>2,:origin_type=>"person",:target_id=>4,:target_type=>"person",:link_category=>"person_to_person_husband",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>2,:origin_type=>"person",:target_id=>5,:target_type=>"person",:link_category=>"person_to_person_father",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>2,:origin_type=>"person",:target_id=>6,:target_type=>"person",:link_category=>"person_to_person_father",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>4,:origin_type=>"person",:target_id=>3,:target_type=>"person",:link_category=>"person_to_person_mother",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>4,:origin_type=>"person",:target_id=>5,:target_type=>"person",:link_category=>"person_to_person_mother",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>4,:origin_type=>"person",:target_id=>6,:target_type=>"person",:link_category=>"person_to_person_mother",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>4,:origin_type=>"person",:target_id=>8,:target_type=>"person",:link_category=>"person_to_person_daughter",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>4,:origin_type=>"person",:target_id=>9,:target_type=>"person",:link_category=>"person_to_person_sister",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>4,:origin_type=>"person",:target_id=>10,:target_type=>"person",:link_category=>"person_to_person_sister",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>9,:origin_type=>"person",:target_id=>10,:target_type=>"person",:link_category=>"person_to_person_sister",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>11,:origin_type=>"person",:target_id=>12,:target_type=>"person",:link_category=>"person_to_person_husband",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>11,:origin_type=>"person",:target_id=>13,:target_type=>"person",:link_category=>"person_to_person_father",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>11,:origin_type=>"person",:target_id=>14,:target_type=>"person",:link_category=>"person_to_person_father",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>15,:origin_type=>"person",:target_id=>3,:target_type=>"person",:link_category=>"person_to_person_girlfriend",:start_date=>"2005-01-01",:end_date=>"2005-01-05",:notes=>"created by batch process")

    @organisation = Organisation.new #17
    @organisation.update(:name=>"Springfield Nuclear Power Plant", :sector=>"Private Sector", :industry=>"Energy", :notes=>"created by batch process")
    @organisation = Organisation.new #18
    @organisation.update(:name=>"Springfield Elementary School", :sector=>"Education", :industry=>"school", :notes=>"created by batch process")
    @organisation = Organisation.new #19
    @organisation.update(:name=>"Krusty the Clown Show", :sector=>"Private Sector", :industry=>"Television Show", :notes=>"created by batch process")
    @organisation = Organisation.new #20
    @organisation.update(:name=>"First Church of Springfield", :sector=>"Non-Profit", :industry=>"Church", :notes=>"created by batch process")

    linker(:origin_id=>2,:origin_type=>"person",:target_id=>17,:target_type=>"organisation",:link_category=>"person_to_organisation_employee",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>7,:origin_type=>"person",:target_id=>17,:target_type=>"organisation",:link_category=>"person_to_organisation_CEO",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>3,:origin_type=>"person",:target_id=>18,:target_type=>"organisation",:link_category=>"person_to_organisation_student",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>3,:origin_type=>"person",:target_id=>19,:target_type=>"organisation",:link_category=>"person_to_organisation_supporter",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")
    linker(:origin_id=>20,:origin_type=>"organisation",:target_id=>16,:target_type=>"person",:link_category=>"organisation_to_person_employer",:start_date=>"1995-01-01",:end_date=>"",:notes=>"created by batch process")


  end

  private
  def neo_tx
    Neo4j::Transaction.new
    @object = Neo4j.load(params[:id]) if params[:id]
    yield
    Neo4j::Transaction.finish
  end
end