require 'slack-ruby-bot'
require 'httparty'
require 'pry'
require 'date'
require 'slack-ruby-client'


class WeatherBot < SlackRubyBot::Bot

  ENV['SLACK_API_TOKEN'] = 'your_slack_api_token'
  KEY = 'your_darksky_api_token'
  LATITUDE = 42.3601
  LONGITUDE = -71.0589

  BASE_URL = "https://api.darksky.net/forecast/#{KEY}/#{LATITUDE},#{LONGITUDE}"

  class << self
    #getter method for response
    def response
      @response
    end

    #makes api get request to darksky
    def load_response
      @response = HTTParty.get(BASE_URL)
      if @response.success?
        @response
      else
        raise @response.response
      end
    end

    #loads today's weather
    def today
      today_in_secs = response["daily"]["data"][0]["time"]
      {
        summary: response["daily"]["data"][0]["summary"],
        date: Time.at(today_in_secs).to_datetime,
        weather: response["daily"]["data"][0]["temperatureHigh"],
      }
    end

    #loads tomorrow's weather
    def tomorrow
      tomorrow_in_secs = response["daily"]["data"][2]["time"]
      {
        summary: response["daily"]["data"][2]["summary"],
        date: Time.at(tomorrow_in_secs).to_datetime,
        weather: response["daily"]["data"][2]["temperatureHigh"],
        rain: response["daily"]["data"][2]["precipProbability"],
      }
    end

    #Extra feature that measures chance of rain
    def bring_umbrella
      tomorrow[:rain] > 1 ? 'Bring an Umbrella' : 'Nah, You good'
    end
  end

  load_response

  Slack.configure do |config|
    config.token = ENV['SLACK_API_TOKEN']
    raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
  end

  #List of commands for slackbot
  command 'List' do |client, data|
    client.say(channel: data.channel, text: "Weather Now, Weather Tomorrow, Bring Umbrella?" )
  end

  command 'Weather Now' do |client, data|
    client.say(channel: data.channel, text: "Temperature of #{today[:weather]}F with #{today[:summary]}" )
  end

  command 'Weather Tomorrow' do |client, data|
    client.say(channel: data.channel, text: "Temperature of #{tomorrow[:weather]}F with #{tomorrow[:summary]}" )
  end

  command 'Bring Umbrella?' do |client, data|
    client.say(channel: data.channel, text: bring_umbrella )
  end

  #Automatically alerts entire channel if weather difference is great than 10 degrees
  if (today[:weather] - tomorrow[:weather]).abs > 10 && Time.now.strftime("%H").to_i < 12 #morning hours
    text = "Big Weather Change!"
    client = Slack::Web::Client.new
    client.auth_test
    client.chat_postMessage(channel: '#rachel-interview-room', text: "<!channel> #{text}", as_user: true)
  end

  client = Slack::Web::Client.new
  client.auth_test
  client.chat_postMessage(channel: '#rachel-interview-room', text: "Enter '@rachelm-bot List' to see all commands", as_user: true)

end

SlackRubyBot::Client.logger.level = Logger::WARN
