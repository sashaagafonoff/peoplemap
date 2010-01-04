class WelcomeController < ApplicationController

  around_filter :neo_tx
  layout 'layout', :except => [:graphml]

  def index
    @current_node_icon = "/images/icons/male.png"
  end

end
