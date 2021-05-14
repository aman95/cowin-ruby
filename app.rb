require './lib/cowin'
require './lib/utils'

def check_for_centers(client, district_id)
  # Getting list of centers
  centers = client.centers_by_district(district_id, Utils.current_date)
  centers.each do |center|
    center['sessions'].each do |session|
      if session['available_capacity'] > 0
        Utils.log('===============================================================================')
        Utils.log(JSON.generate(session))
        Utils.play_beep
        Utils.log('===============================================================================')
      end
    end
  end
end

def check_for_sessions(client, district_id)
  # Getting list of sessions
  sessions = client.sessions_by_district(district_id, Utils.current_date)
  sessions.each do |session|
    if session['available_capacity'] > 0
      Utils.log('===============================================================================')
      Utils.log(JSON.generate(session))
      Utils.play_beep
      Utils.log('===============================================================================')
    end
  end
end

phone_number = ARGV[1] || ENV['COWIN_PHONE_NUMBER']
district_id = '188' # Haryana -> Gurgaon

cowin_client = CoWin.new(phone_number)

session_check_thread = Thread.new do
  1.upto(100) do |idx|
    Utils.log("Checking for sessions #{idx}")
    check_for_sessions(cowin_client, district_id)
    sleep(1)
  end
end

center_check_thread = Thread.new do
  1.upto(100) do |idx|
    Utils.log("Checking for centers #{idx}")
    check_for_centers(cowin_client, district_id)
    sleep(1)
  end
end

session_check_thread.join
center_check_thread.join