require "open-uri"
require 'json'
require "uri"
require "net/http"
require 'dotenv'
require 'date'

puts "I've attached the API Seeds File !! "
## get the first access token
def get_initial_token
  client_id_key = ENV["MEETUP_KEY"].to_s

  url = URI("https://secure.meetup.com/oauth2/authorize?client_id=#{client_id_key}&response_type=anonymous_code&redirect_uri=https://www.love-lumina.me/")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["Content-Type"] = "application/json"
  request["Accept"] = "application/json"
  request["Cookie"] =
    "MEETUP_AFFIL=affil=meetup; MEETUP_BROWSER_ID=\"id=756c9fe0-0bca-4112-bc41-1685ef9f6f92\"; MEETUP_CSRF=239ce87b-ac9b-453e-9d79-2688da4f5d1a; MEETUP_MEMBER=\"id=154567222&status=4&timestamp=1614245261&bs=0&tz=Australia%2FMelbourne&zip=meetup2&country=au&city=Melbourne&state=&lat=-37.81&lon=144.96&ql=false&s=038211a2f0cfead5522e9fd3a51cf56f4a482535&scope=ALL\"; MEETUP_SEGMENT=member; MEETUP_TRACK=id=5e0859a6-c334-4f2b-bd73-818934553be7&l=1&s=a7bf3696ab6fe266da7143de4cb39f9fc2698c45; SIFT_SESSION_ID=256ba851-27e3-49b6-bcb7-31155a4bbb81"

  response = https.request(request)

  result = JSON.parse(response.body)
  p result&.key?("code") ? puts("--- Passed step one initial token") : puts("--- step 1 FAILED..")
  return result["code"]
end

## add token to get outh token
def request_access_token
  client_id_key = ENV["MEETUP_KEY"].to_s
  code = get_initial_token

  url = URI("https://secure.meetup.com/oauth2/access?client_id=#{client_id_key}&client_secret=2t60t96pgsldve4b392q4lnavo&grant_type=anonymous_code&redirect_uri=https://www.love-lumina.me/&code=#{code}")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request["Content-Type"] = "application/json"
  request["Accept"] = "application/json"
  request["Cookie"] =
    "MEETUP_AFFIL=affil=meetup; MEETUP_BROWSER_ID=\"id=756c9fe0-0bca-4112-bc41-1685ef9f6f92\"; MEETUP_CSRF=239ce87b-ac9b-453e-9d79-2688da4f5d1a; MEETUP_MEMBER=\"id=154567222&status=4&timestamp=1614245261&bs=0&tz=Australia%2FMelbourne&zip=meetup2&country=au&city=Melbourne&state=&lat=-37.81&lon=144.96&ql=false&s=038211a2f0cfead5522e9fd3a51cf56f4a482535&scope=ALL\"; MEETUP_SEGMENT=member; MEETUP_TRACK=id=5e0859a6-c334-4f2b-bd73-818934553be7&l=1&s=a7bf3696ab6fe266da7143de4cb39f9fc2698c45; SIFT_SESSION_ID=256ba851-27e3-49b6-bcb7-31155a4bbb81"

  response = https.request(request)
  result = JSON.parse(response.body)
  p result&.key?("access_token") ? puts("--- Passed step two access token") : puts("--- step 2 FAILED..")
  # {"access_token"=>"xxx", "refresh_token"=>"xxx", "member"=>{"country"=>"au", "city"=>"Melbourne", "name"=>"prereg_member_312483285115459", "lon"=>144.96689, "id"=>3272384992, "state"=>"07", "lat"=>-37.815903}, "token_type"=>"bearer", "expires_in"=>3600}
  return result
end

# call get access token

def request_oauth_token
  user_email = ENV["MEETUP_EMAIL"]
  user_pass = ENV["MEETUP_PASS"]
  bearer = request_access_token["access_token"]

  url = URI("https://api.meetup.com/sessions?&email=#{user_email}&password=#{user_pass}")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request["Accept"] = "application/json"
  request["Authorization"] = "Bearer #{bearer}"
  request["Cookie"] = "MEETUP_AFFIL=affil=meetup; MEETUP_BROWSER_ID=\"id=8f29c91f-3033-4eda-a298-190fc2071d55\"; MEETUP_CSRF=dbccdafc-8e61-4007-9a5a-4c92c81dbdc5; MEETUP_MEMBER=\"id=154567222&status=4&timestamp=1614293651&bs=0&tz=Australia%2FMelbourne&zip=meetup2&country=au&city=Melbourne&state=&lat=-37.81&lon=144.96&ql=false&s=802d872fc49dd2c821523298ccdec801cad92d53&scope=ALL\"; MEETUP_TRACK=id=c258a329-f366-4a5f-87d4-f915b81c1970&l=0&s=dca38f8fd2e9b0dfec685350632da5d7d316c9d3; SIFT_SESSION_ID=20670450-2624-4174-a947-cce0ab741e54"

  response = https.request(request)
  result = JSON.parse(response.body)
  p result&.key?("oauth_token") ? puts("--- Passed step three oauth_token") : puts("--- step 3 FAILED..")
  return result
  # {"oauth_token"=>"xxx", "oauth_token_secret"=>"xxx", "refresh_token"=>"xxx", "expires_in"=>3600, "member"=>{"id"=>381717, "name"=>"someguy", "email"=>"email", "status"=>"active", "joined"=>1404391594000, "city"=>"Melbourne", "country"=>"au", "localized_country_name"=>"Australia", "lat"=>-37.81, "lon"=>144.96, "photo"=>{"id"=>303641096, "highres_link"=>"https://secure.meetupstatic.com/photos/member/a/0/8/8/highres_303641096.jpeg", "photo_link"=>"https://secure.meetupstatic.com/photos/member/a/0/8/8/member_303641096.jpeg", "thumb_link"=>"https://secure.meetupstatic.com/photos/member/a/0/8/8/thumb_303641096.jpeg", "type"=>"member", "base_url"=>"https://secure.meetupstatic.com"}, "is_pro_admin"=>true}}
end

# get the auth token

def meetup_events_finder(options = {})
  cert_meetup_api # oauth setup
  # token from above
  bearer = request_oauth_token["oauth_token"]
  lon = options[:longitude]
  lat = options[:latitude]
  cat = options[:category] # text category field
  # radius smart or kms
  # order best or time

  p url = URI("https://api.meetup.com/find/upcoming_events?lon=#{lon}&page=20&radius=smart&lat=#{lat}&order=best&text=#{cat}&fields=featured_photo")
  # original below
  # p url = URI("https://api.meetup.com/find/upcoming_events?lon=145&page=20&radius=10&lat=#{lat}")

  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(url)
  request["Authorization"] = "Bearer #{bearer}"
  request["Cookie"] = "MEETUP_AFFIL=affil=meetup; MEETUP_BROWSER_ID=\"id=8f29c91f-3033-4eda-a298-190fc2071d55\"; MEETUP_CSRF=dbccdafc-8e61-4007-9a5a-4c92c81dbdc5; MEETUP_MEMBER=\"id=154567222&status=4&timestamp=1614293651&bs=0&tz=Australia%2FMelbourne&zip=meetup2&country=au&city=Melbourne&state=&lat=-37.81&lon=144.96&ql=false&s=802d872fc49dd2c821523298ccdec801cad92d53&scope=ALL\"; MEETUP_TRACK=id=5e0859a6-c334-4f2b-bd73-818934553be7&l=1&s=a7bf3696ab6fe266da7143de4cb39f9fc2698c45; SIFT_SESSION_ID=20670450-2624-4174-a947-cce0ab741e54"

  response = https.request(request)
  result = JSON.parse(response.body) # result hash
  result[:meetup_cat] = cat
  # pp result["events"]
  return result
end

def cert_meetup_api
  # cascades all of above below not needed

  # get_initial_token # 1
  # request_access_token # 2
  # request_oauth_token # 3
end

meetup_events_finder({ latitude: "-37.81", longitude: "144.96", category: "food" })

## create the Events ##
def meetup_event_spooler(options = {})
  # Time.at(seconds_since_epoch_integer).to_datetime
  ## hash it up
  options["events"]
    .binding.pry
  make_me = Event.create( # change to create! later
    # add category to event
    name: options["name"],
    date: options["local_date"],
    venue_name: options["venue"]["name"],
    address: options["venue"]["address_1"],
    description: options["description"],
    meetup_link: options["link"],
    organiser: options["group"]["name"],
    attendees: options["yes_rsvp_count"],
    user_id: options[],
    longitude: options["venue"]["lon"],
    latitude: options["venue"]["lat"],
    category: options[:meetup_cat],
    meetup_event_id: options["id"],
    meetup_update: options["updated"]
  )
end

## spool up events ..
meetup_event_spooler(meetup_events_finder({ latitude: "-37.81", longitude: "144.96", category: "food" }))
