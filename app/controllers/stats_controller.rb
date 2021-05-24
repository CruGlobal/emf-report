class StatsController < ApplicationController
  def index
    @account_lists = loader.load_account_list
  end

  def show
    @account_list = loader.load_account_list
    @data = loader.load_stats
    @table = AccountListStatsTable.new(@data).table
  end

  private

  def loader
    @loader ||= AccountListStatsLoader.new(account_list_id: params[:id], token: params[:token], env: params[:env])
  end
end
