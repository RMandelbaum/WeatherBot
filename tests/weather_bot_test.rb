require "./lib/weather_bot.rb"
require 'minitest/autorun'
require "pry"

class WeatherBotTest < Minitest::Test

  def test_load_response_returns_success
    response = WeatherBot.load_response
    assert response.success?
  end

  def test_response_returns_response
    response = WeatherBot.response
    assert response != nil
  end

  def test_today_returns_weather
    response = WeatherBot.response
    today_in_secs = response["daily"]["data"][0]["time"]

    expected_result = {
      summary: response["daily"]["data"][0]["summary"],
      date: Time.at(today_in_secs).to_datetime,
      weather: response["daily"]["data"][0]["temperatureHigh"],
    }

    result = WeatherBot.today

    assert_equal expected_result, result
  end

  def test_tomorrow_returns_weather
    response = WeatherBot.response
    tomorrow_in_secs = response["daily"]["data"][2]["time"]

    expected_result = {
      summary: response["daily"]["data"][2]["summary"],
      date: Time.at(tomorrow_in_secs).to_datetime,
      weather: response["daily"]["data"][2]["temperatureHigh"],
      rain: response["daily"]["data"][2]["precipProbability"],
    }

    result = WeatherBot.tomorrow

    assert_equal expected_result, result
  end
end
