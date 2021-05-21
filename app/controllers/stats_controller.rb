class StatsController < ApplicationController
  def index
    fetch_account_lists
  end

  def show
    load_data_for(account_list_param)
  end

  private

  def fetch_account_lists
    RestClient
  end
end
