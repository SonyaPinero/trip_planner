require 'httparty'
require 'cgi'
require 'pry'

class TripPlanner
  attr_reader :user, :forecast, :recommendation
  
  def initialize
    # Should be empty, you'll create and store @user, @forecast and @recommendation elsewhere
  end
  
  def plan
    @user = self.create_user 
    @forecast = self.retrieve_forecast
    @recommendation = self.create_recommendation

  end
  
  def display_recommendation
    puts "Our recommendation is #{@recommendation}."
  end
  #

  def save_recommendation
    puts "Would you like to save this to the disk?"

    yes_no = gets().chomp()

    if yes_no == "yes"
      @disk.push(@recommendation)
    end
  
  end

  def create_user

  # provide the interface asking for name,  and duration
    puts ("What is your name?")
    user_name = gets.chomp()

    @name = user_name

    puts ("Where do you wish to go?")
    user_destination = gets().chomp()

    @destination = user_destination

    puts ("How long do you wish to stay?")
    user_duration = gets().chomp().to_i

    @duration = user_duration

    # then, create and store the User object
    @user = User.new(@name, @destination, @duration)
  end
    
  def call_api
    @destination = CGI.escape(@destination)
    @weather_info = HTTParty.get("http://api.openweathermap.org/data/2.5/forecast/daily?q=#{@destination}&mode=json&units=imperial&cnt=#{@duration}")
  end

  def parse_result

    @forecast_array = []
    
    index = 0
    while index < (@duration)
    min_temp = @weather_info["list"][index]["temp"]["min"]
    max_temp = @weather_info["list"][index]["temp"]["max"]
    condition = @weather_info["list"][index]["weather"][0]["description"]
    @forecast_array << Weather.new(min_temp, max_temp, condition)
    index += 1
    end
    
    return @forecast_array

  end

def retrieve_forecast
  self.call_api
  self.parse_result

  @forecast_array.each do |day|
    day.min_temp 
    puts "The day's min temp is #{day.min_temp}"
  end 

  @forecast_array.each do |day|
    day.max_temp 
    puts "The day's max temp is #{day.max_temp}"
  end 

  @forecast_array.each do |day|
    day.condition 
    puts "The day's condition is #{day.condition}"
  end 

# index = 0 
# while index < (@duration)
#   @forecast[index][0]
#   puts "The day's min temp is #{@forecast[index][0]}"
#   @forecast[index][1]
#   "The day's min temp is #{@forecast[index][1]}"
#   @forecast[index][2]
#   puts "Here is a brief description: #{@forecast[index][2]}"
#   puts "---------"
#   index += 1
end
  
  
  def collect_clothes

  recommended_clothes = @forecast_array.map do |day|
      day.appropriate_clothing
    end

  return puts (recommended_clothes)

  end

  def collect_accessories

  recommended_acessories = @forecast_array.map do |day|
      day.appropriate_accessories
    end

  return puts (recommended_acessories)
  
  end
    
  def create_recommendation
    
    self.collect_clothes
    self.collect_accessories

  end

end

class Weather
  attr_accessor :min_temp, :max_temp, :condition
  
  # given any temp, we want to search CLOTHES for the hash
  # where min_temp <= temp and temp <= max_temp... then get
  # the recommendation for that temp.
  CLOTHES = [
    {
      min_temp: -50, 
      max_temp: 0,
      recommendation: [
        "insulated parka", "long underwear", "fleece-lined jeans",
        "mittens", "knit hat", "chunky scarf"
      ]
    },
    {min_temp: 1, 
      max_temp: 50,
      recommendation: [
        "medium jacket", "medium sweather" ]
    },
    {min_temp: 51, 
      max_temp: 100,
      recommendation: [
        "shorts", "short sleeves" ]
      }
    ]

  ACCESSORIES = [
    {
      condition: "Rainy",
      recommendation: [
        "galoshes", "umbrella"]
    },
    
    {condition: "Snowy",
      recommendation: ["cap", "gloves"]
    },

    {condition: "Hot",
      recommendation: ["sunblock", "sunglasses"]
    }
  ]
  
  
def initialize(min_temp, max_temp, condition)
  @min_temp = min_temp
  @max_temp = max_temp
  @condition = condition
    
  end

  def self.clothing_for(temp)

    @clothing_array = [] 

    @clothing_array = CLOTHES.select do |temperature|
      temp.between?(temperature[:min_temp],temperature[:max_temp])
    end

    @clothing_array.map! do |object|
      object[:recommendation] 
    end

    return @clothing_array

  end
    
    # if  temp.between?(-50,0)
    #   @clothing_array << (CLOTHES[0][:recommendation])

    # elsif temp.between?(1,50)
    #   @clothing_array << (CLOTHES[1][:recommendation])

    # else temp.between?(51,100)
    #   @clothing_array << (CLOTHES[2][:recommendation])
    # end

  def self.accessories_for(condition)

    @accessories_array = []

    @accessories_array = ACCESSORIES.select do |object|
      object[:condition] == condition 
    end
   
    @accessories_array.map! do |object|
      object[:recommendation]
    end

    return @accessories_array

  end
  
  def appropriate_clothing

    appropriate_clothing = []

    appropriate_clothing  << Weather.clothing_for(@min_temp)
  
    appropriate_clothing << Weather.clothing_for(@max_temp)

    return appropriate_clothing.uniq
  
  end
  
  def appropriate_accessories

    appropriate_accessories = []

    appropriate_accessories << Weather.accessories_for(@condition)

    return appropriate_accessories

  end

end

class User
  attr_reader :name, :destination, :duration
  
  def initialize(name, destination, duration)
    @name = name
    @destination = destination
    @duration = duration
  end

end

trip_planner = TripPlanner.new
Pry.start(binding)


trip_planner.plan

