class SearchController < ApplicationController

  layout 'layout'

  def index
    @current_node_icon = "/images/icons/male.png"
    if params[:search].include? " " then @search_terms = params[:search].split(" ") else @search_terms = params[:search] end
  end

end
