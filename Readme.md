# CoWin - Ruby
Command line tool written in Ruby to check vaccination slot availability using CoWin public APIs

## Usage
It checks for the available vaccine slot in the district provided in the args and plays a loud beep when a slot is available. Can be used with Raspberry pi and other SBCs.

## How to setup
1. Install sox for Beep
```bash
sudo apt install sox -y
```
OR
```bash
brew install sox
```
2. Clone project
```bash
git clone https://github.com/aman95/cowin-ruby.git
```
2. Run
```bash
ruby app.rb <phone_number> <district_id>
```

## TODO:
- Interactive listing of the Districts and States
- Figure-out the ways to bypass captcha for Appointment Schedule API :P