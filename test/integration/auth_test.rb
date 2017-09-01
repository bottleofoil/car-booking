require 'test_helper'

class AuthIntegrationTest < ActionDispatch::IntegrationTest

  test "create user, login, create a booking" do

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
    token = res["token"]

    car1 = Car.new
    car1.save!

    now = Time.now

    post bookings_url, params: {
      car_id: car1.id,
      starts_at: timestr(now),
      ends_at: timestr(now + 60*60), 
    }, headers: {"X-Auth" => token}

    assert_equal 200, @response.status

    user = User.take
    assert_equal Booking.take["user_id"], user.id
    assert_equal "e@e.com", user.email

  end

  test "auth is required to see list of bookings" do
      get bookings_url
      assert_equal 403, @response.status
  end

  def timestr(time)
    time.utc.to_datetime.rfc3339(3).gsub("+00:00", "Z")
  end


end

