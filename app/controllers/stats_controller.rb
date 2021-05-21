class StatsController < ApplicationController
  def index
    fetch_account_lists
  end

  def show
    load_data_for(params[:id])
    @table = AccountListStats.new(load_data_for(params[:id])).table
  end

  private

  def load_data_for(account_list_id)
    activity_results_endpoint = "https://api.stage.mpdx.org/api/v2/tasks/analytics?filter%5Baccount_list_id%5D=#{account_list_id}"
    json = {}
    analytics = account_list_analytics(account_list_id, '2021-05-16..2021-05-22')['data']
    json['data'] = [analytics, analytics, analytics, analytics, analytics]
    json['data'][0]['attributes']['appointments']['completed'] = 1
    @data = zip_tags_report(json, tags_report(account_list_id))
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

  def fetch_account_lists
    RestClient.log = 'stdout'
    json = RestClient.get('https://api.stage.mpdx.org/api/v2/user/account_list_coaches?include=account_list', accept: "application/vnd.api+json", Authorization: auth_header, "content-type" => "application/vnd.api+json" )
    json = JSON.parse(json)
    @account_lists = json['included'].select { |h| h['type'] == 'account_lists' }
  end

  def auth_header
    "Bearer asdf"
  end

  def tags_report(account_list_id)
    url = "https://api.stage.mpdx.org/api/v2/reports/tag_histories?filter%5Baccount_list_id%5D=#{account_list_id}&filter%5Bassociation%5D=tasks&filter%5Brange%5D=5w"
    mpdx_rest_get(url)
  end

  def account_list_analytics(account_list_id, date_range)
    account_list_analytics_endpoint = "https://api.stage.mpdx.org/api/v2/account_lists/#{account_list_id}/analytics?filter%5Bdate_range%5D=#{date_range}"
    mpdx_rest_get(account_list_analytics_endpoint)
  end

  def mpdx_rest_get(url)
    JSON.parse(RestClient.get(url, accept: "application/vnd.api+json", Authorization: auth_header, "content-type" => "application/vnd.api+json"))
  end
end
