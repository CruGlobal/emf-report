class StatsController < ApplicationController
  before_action :ensure_mpdx_active

  def index
    @user_account_lists = loader.load_user_ccount_lists
    @coaching_account_lists = loader.load_coaching_ccount_lists
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

  def group_score_card
    @data = {}
    params[:stat_ids] = JSON.parse(params[:stat_ids]) if params[:stat_ids].instance_of?(String)

    params[:stat_ids].each do |stat_id|
      params[:stat_id] = stat_id
      name = loader.load_account_list["attributes"]["name"]
      target_date = params[:target_date].to_date
      @data[name] = loader.load_stats(:group, target_date)
    end
    @table = AccountListGroupStatsTable.new(@data).table(:group)
  end


  private

  def loader
    @loader = AccountListStatsLoader.new(account_list_id: params[:stat_id],
                                           token: session[:mpdx_token],
                                           env: params[:env])
  end

  def ensure_mpdx_active
    return if session[:mpdx_expires_at].to_i > DateTime.now.to_i
    if session[:okta_expires_at].to_i < 30.seconds.from_now.to_i
      redirect_to login_url
      return false
    end
    token = MPDXLogin.login(session[:okta_access_token])
    session[:mpdx_token] = token.token
    session[:mpdx_expires_at] = token.expires_at.to_i
  end
end
