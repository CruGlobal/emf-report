class MPDXLogin
  MPDXToken = Struct.new(:token, :expires_at)

  def self.login(okta_token)
    url = "#{url_host}/api/v2/user/authenticate"

    payload = {
      data: {
        type: "authenticate",
        attributes: {
          provider: "okta",
          access_token: okta_token
        }
      }
    }
    headers = {accept: "application/vnd.api+json", "content-type": "application/vnd.api+json"}
    resp = JSON.parse(RestClient.post(url, payload.to_json, headers))

    token = resp["data"]["attributes"]["json_web_token"]
    exp = OktaOauth.decode_jwt(token)["exp"].to_i
    MPDXToken.new(token, Time.at(exp))
  end

  def self.url_host
    if @env == :prod
      "https://api.mpdx.org"
    else
      "https://api.stage.mpdx.org"
    end
  end
end
