require "uri"
require "net/http"
require "json"
require "digest"

class CoWin
  attr_accessor :authorization_token

  API_ENDPOINT = 'https://cdn-api.co-vin.in/api'.freeze
  DEFAULT_OTP_SECRET = 'U2FsdGVkX18sN0rUULN3gGoMxI5k8yLUYg7Vtx6fy9q1hIlZ9Z9oONVWWT+r/rWlKofYj0XVmHUIcp9zvrM+zQ=='.freeze
  USER_AGENT = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'.freeze

  def initialize(phone_number, otp_secret = nil)
    @otp_secret = otp_secret || DEFAULT_OTP_SECRET
    @phone_number = phone_number
    @otp_txn_id = nil
    @authorization_token = nil
  end

  def generate_otp
    url = "#{API_ENDPOINT}/v2/auth/generateMobileOTP"
    params = {
      mobile: @phone_number,
      secret: @otp_secret,
    }
    response = http_post(url, params, auth: false)
    if response['txnId']
      @otp_txn_id = response['txnId']
    else
      puts "[ERROR] OTP response failure"
    end
  end

  def confirm_otp(otp)
    puts "[ERROR] OTP txn Id is not present, please call generate_otp first" and return false if @otp_txn_id.nil?
    otp_hash = Digest::SHA256.hexdigest otp.to_s
    url = "#{API_ENDPOINT}/v2/auth/confirmOTP"
    params = {
      otp: otp_hash,
      txnId: @otp_txn_id,
    }
    response = http_post(url, params, auth: false)
    if response['token']
      @authorization_token = response['token']
      return true
    end
    puts "[ERROR] confirmOTP response failure"
    false
  end

  def centers_by_district(district_id, date)
    url = "#{API_ENDPOINT}/v2/appointment/sessions/public/calendarByDistrict?district_id=#{district_id}&date=#{date}"
    response = http_get(url, auth: false)
    return response['centers'] unless response['centers'].nil?

    puts "[ERROR] CentersByDistrict response failure"
    nil
  end

  def sessions_by_district(district_id, date)
    url = "#{API_ENDPOINT}/v2/appointment/sessions/public/findByDistrict?district_id=#{district_id}&date=#{date}"
    response = http_get(url, auth: false)
    return response['sessions'] unless response['sessions'].nil?

    puts "[ERROR] SessionsByDistrict response failure"
    nil
  end

  private

  def http_get(http_url, auth: false)
    url = URI(http_url)

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["User-Agent"] = USER_AGENT
    request["Authorization"] = "Bearer #{@authorization_token}" if auth

    response = https.request(request)
    response_body = response.read_body
    extract_response_json(response_body)
  end

  def http_post(http_url, body, auth: false)
    url = URI(http_url)

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = 'application/json'
    request["User-Agent"] = USER_AGENT
    request["Authorization"] = "Bearer #{@authorization_token}" if auth
    request.body = JSON.generate(body)

    response = https.request(request)
    response_body = response.read_body
    extract_response_json(response_body)
  end

  def extract_response_json(response_body)
    response_json = {}
    begin
      response_json = JSON.parse(response_body)
    rescue => e
      puts "[ERROR] #{e.message}"
    end
    response_json
  end
end
