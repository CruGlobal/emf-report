class AccountListStatsLoader
  def initialize(account_list_id:, token:, env:)
    @account_list_id = account_list_id
    @token = token
    @env = env.presence&.to_sym || :stage
  end

  def load_stats
    tags_data = tags_report
    json = {}
    json['data'] = tags_data['data'].map do |tag_data_row|
      data_range = "#{tag_data_row['attributes']['start_date']}..#{tag_data_row['attributes']['end_date']}"
      account_list_analytics(data_range)['data']
    end
    zip_tags_report(json, tags_data)
  end

  def load_account_list
    mpdx_rest_get("/api/v2/account_lists/#{@account_list_id}?fields[account_lists]=name")['data']
  end

  def load_account_lists
    json = mpdx_rest_get('/api/v2/user/account_list_coaches?include=account_list')
    @account_lists = json['included'].select { |h| h['type'] == 'account_lists' }
  end

  private

  def zip_tags_report(data, tags_report)
    data['data'].each do |data_row|
      data_row['attributes']['tags'] ||= {}
      end_date = data_row['attributes']['end_date'][0..9]
      tag_report_row = tags_report['data'].find { |r| r['attributes']['end_date'] == end_date }
      tag_report_row&.dig('attributes', 'tags')&.each do |tag|
        tag_name = tag['name']
        tag_count = tag['count']
        data_row['attributes']['tags'][tag_name] = tag_count
      end
    end
    data
  end

  def tags_report
    url = "/api/v2/reports/tag_histories?filter%5Baccount_list_id%5D=#{@account_list_id}&filter%5Bassociation%5D=tasks&filter%5Brange%5D=#{weeks}w"
    json = mpdx_rest_get(url)
    json['data'] = json['data'][0..(weeks - 1)]
    json
  end

  def account_list_analytics(date_range)
    account_list_analytics_endpoint = "/api/v2/account_lists/#{@account_list_id}/analytics?filter%5Bdate_range%5D=#{date_range}"
    mpdx_rest_get(account_list_analytics_endpoint)
  end

  def weeks
    5
  end

  def url_host
    if @env == :prod
      'https://api.mpdx.org'
    else
      'https://api.stage.mpdx.org'
    end
  end

  def mpdx_rest_get(url)
    url = url_host + url
    JSON.parse(RestClient.get(url, accept: "application/vnd.api+json", Authorization: auth_header, "content-type" => "application/vnd.api+json"))
  end

  def auth_header
    "Bearer #{@token}"
  end
end