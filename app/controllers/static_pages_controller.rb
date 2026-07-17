class StaticPagesController < ApplicationController
  allow_unauthenticated_access only: %i[ about ]

  # GET /about
  def about
  end
end
