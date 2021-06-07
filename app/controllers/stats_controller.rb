class StatsController < ApplicationController
  def index
    @account_lists = loader.load_account_lists
  end

  def weekly
    @account_list = loader.load_account_list
    @data = loader.load_stats(:weekly)
    @table = AccountListStatsTable.new(@data).table(:weekly)
    render :show
  end

  def monthly
    @account_list = loader.load_account_list
    @data = loader.load_stats(:monthly)
    @table = AccountListStatsTable.new(@data).table(:monthly)
    render :show
  end

  private

  def loader
    @loader ||= AccountListStatsLoader.new(account_list_id: params[:stat_id],
                                           token: params[:token],
                                           env: params[:env])
  end
end
