require 'rubygems'
require 'json'

class Factual
  @@API_KEY = 'RQUDw0JQVzIygq4a72vJfVzExopz2c8CvOVsTTToIUGgphCOhbgttGAYfXv8eiMC'
  @@URL     = 'http://branch.honghao.sci/api/v2/sessions/get_token'

  def self.get_token(username)
    result = `curl -d api_key=#{@@API_KEY} -d unique_id=#{username} #{@@URL}`
    token  = JSON.parse(result)['string']
    return token
  end
end
