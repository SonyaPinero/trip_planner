require 'httparty'
require 'cgi'
require 'pry'

class TripPlanner
  attr_reader :user, :forecast, :recommendation

  def initialize

  end

  def plan
    @user = create_user

    @forecast = retrieve_forecast
    unless @forecast
      puts "City not found..."
      return nil
    end

    @recommendation = create_recommendation

    display_recommendation
  end

  def display_recommendation
    puts @user

    puts "You'll need the following clothes: "
    @recommendation[:clothes].each do |piece|
      puts "- #{piece}"
    end
    puts "And the following accessories: "
    @recommendation[:accessories].each do |piece|
      puts "- #{piece}"
    end
  end

  # def save_recommendation
  # end

  def create_user
    print "Your name > "
    name = gets.chomp

    print "Trip Destination (e.g. Binghamton, NY) > "
    destination = gets.chomp

    print "Trip Duration (in days) > "
    duration = gets.chomp.to_i

    return User.new(name, destination, duration)
  end

  def retrieve_forecast
    result = call_api

    return parse_result(call_api)
  end

  def call_api
    options = "?q=#{CGI::escape(@user.destination)}&" +
              "" +
              "units=imperial&" +
              "cnt=#{@user.duration}"

    url = "http://api.openweathermap.org/" +
          "data/2.5/forecast/daily#{options}"

    HTTParty.get(url)
  end

  def parse_result(result)
    Pry.start(binding)
    return nil if result["404"]

    stripped_results = result["list"].map do |day|
      {
        min_temp:  day["temp"]["min"],
        max_temp:  day["temp"]["max"],
        condition: day["weather"][0]["main"]
      }
    end

    weather_array = stripped_results.map do |info|
      Weather.new(info[:min_temp], info[:max_temp], info[:condition])
    end
  end

  def create_recommendation
    return {
      clothes: collect_clothes,
      accessories: collect_accessories
    }
  end

  def collect_clothes
    @forecast.map do |weather|
      weather.appropriate_clothing
    end.flatten.uniq
  end

  def collect_accessories
    @forecast.map do |weather|
      weather.appropriate_accessories
    end.flatten.uniq
  end
end

class Weather
  attr_reader :min_temp, :max_temp, :condition

  CLOTHES = [
    {
      min_temp: -50, max_temp: 20,
      recommendation: [
        "insulated parka", "long underwear", "fleece-lined jeans",
        "mittens", "knit hat", "chunky scarf"
      ]
    },
    {
      min_temp: 20, max_temp: 40,
      recommendation: [
        "down jacket", "sweater", "corduroy pants",
        "wool cap", "gloves"
      ]
    },
    {
      min_temp: 40, max_temp: 70,
      recommendation: [
        "sport coat", "cardigan", "slacks"
      ]
    },
    {
      min_temp: 70, max_temp: 120,
      recommendation: [
        "shorts", "short sleeve shirt"
      ]
    }
  ]

  ACCESSORIES = [
    {
      condition: "Rain",
      recommendation: [
        "galoshes", "umbrella"
      ]
    },
    {
      condition: "Clouds",
      recommendation: [
        "galoshes", "umbrella"
      ]
    },
    {
      condition: "Clear",
      recommendation: [
        "sun glasses", "visor"
      ]
    },
    {
      condition: "Snow",
      recommendation: [
        "chunky scarf", "knit hat"
      ]
    }
  ]

  def initialize(min_temp, max_temp, condition)
    @min_temp = min_temp
    @max_temp = max_temp
    @condition = condition
  end

  def to_s
    "#{@condition}, temperature between #{@min_temp} and #{@max_temp}."
  end

  def self.clothing_for(temp)
    entry = CLOTHES.find do |entry|
      entry[:min_temp] <= temp && temp < entry[:max_temp]
    end

    entry[:recommendation]
  end

  def self.accessories_for(condition)
    entry = ACCESSORIES.find do |entry|
      entry[:condition] == condition
    end

    entry[:recommendation]
  end

  def appropriate_clothing
    Weather.clothing_for(@min_temp) + Weather.clothing_for(@max_temp)
  end

  def appropriate_accessories
    Weather.accessories_for(@condition)
  end
end

class User
  attr_reader :name, :destination, :duration

  def initialize(name, destination, duration)
    @name = name
    @destination = destination
    @duration = duration
  end

  def to_s
    "#{@name}, you are going to #{@destination} for #{@duration} days."
  end
end

trip_planner = TripPlanner.new
trip_planner.plan
