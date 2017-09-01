require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def create_user
    post users_url, params: {
        email: "e@e.com",
        password: "password",
    }
    assert_equal 200, @response.status

    post auth_url, params: {
        email: "e@e.com",
        password: "password",
    }

    assert_equal 200, @response.status
    res = JSON.parse(@response.body)
    return res["token"]
  end


  def post_auth(url, params:{})
    if !@auth_token
      raise "auth token not set"
    end
    post url, params:params, headers: {"X-Auth" => @auth_token}
  end

  def get_auth(url, params:{})
    if !@auth_token
      raise "auth token not set"
    end  
    get url, params:params, headers: {"X-Auth" => @auth_token}
  end  
end
