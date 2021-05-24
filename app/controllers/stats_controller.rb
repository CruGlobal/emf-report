class StatsController < ApplicationController
  def index
    fetch_account_lists
  end

  def show
    fetch_account_list(params[:id])
    @table = AccountListStatsTable.new(load_data_for(params[:id])).table
  end

  private

  def load_data_for(account_list_id)
    activity_results_endpoint = "https://api.stage.mpdx.org/api/v2/tasks/analytics?filter%5Baccount_list_id%5D=#{account_list_id}"
    json = {}
    tags_data = tags_report(account_list_id)
    json['data'] = tags_data['data'].map do |tag_data_row|
      p data_range = "#{tag_data_row['attributes']['start_date']}..#{tag_data_row['attributes']['end_date']}"
      account_list_analytics(account_list_id, data_range)['data']
    end
    @data = zip_tags_report(json, tags_data)
  end

  def zip_tags_report(data, tags_report)
    data['data'].each do |data_row|
      data_row['attributes']['tags'] ||= {}
      end_date = data_row['attributes']['end_date'][0..9]
      tag_report_row = tags_report['data'].find { |r| r['attributes']['end_date'] == end_date }
      tag_report_row['attributes']['tags'].each do |tag|
        tag_name = tag['name']
        tag_count = tag['count']
        data_row['attributes']['tags'][tag_name] = tag_count
      end
    end
    data
  end

  def fetch_account_list(account_list_id)
    @account_list = mpdx_rest_get("https://api.stage.mpdx.org/api/v2/account_lists/#{account_list_id}?fields[account_lists]=name")['data']
  end

  def fetch_account_lists
    json = mpdx_rest_get('https://api.stage.mpdx.org/api/v2/user/account_list_coaches?include=account_list')
    @account_lists = json['included'].select { |h| h['type'] == 'account_lists' }
  end

  def auth_header
    "Bearer #{params[:token]}"
  end

  def tags_report(account_list_id)
    weeks = 5
    url = "https://api.stage.mpdx.org/api/v2/reports/tag_histories?filter%5Baccount_list_id%5D=#{account_list_id}&filter%5Bassociation%5D=tasks&filter%5Brange%5D=#{weeks}w"
    json = mpdx_rest_get(url)
    json['data'] = json['data'][0..(weeks - 1)]
    json
  end

  def account_list_analytics(account_list_id, date_range)
    account_list_analytics_endpoint = "https://api.stage.mpdx.org/api/v2/account_lists/#{account_list_id}/analytics?filter%5Bdate_range%5D=#{date_range}"
    mpdx_rest_get(account_list_analytics_endpoint)
  end

  def mpdx_rest_get(url)
    JSON.parse(RestClient.get(url, accept: "application/vnd.api+json", Authorization: auth_header, "content-type" => "application/vnd.api+json"))
  end
end
