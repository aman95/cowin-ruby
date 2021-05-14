class Utils
  def self.current_date
    Time.now.strftime("%d-%m-%Y")
  end

  def self.log(message)
    puts "#{Time.now} #{message}"
  end

  def self.play_beep
    system('play -nq -t alsa synth 1 sine 2200')
  end
end