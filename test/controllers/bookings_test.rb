require 'test_helper'

class BookingsControllerTest < ActionDispatch::IntegrationTest

  test "create and list basic" do

    user = User.new
    user.save!

    car1 = Car.new
    car1.save!

    now = Time.now

    booking(
      car1.id,
      now,
      now + 0.5*h, 
    )
    
    booking(
      car1.id,
      now + 1*h,
      now + 1.5*h, 
    )

    get bookings_url

    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 2, res.length

    res.sort_by! { |obj| obj['starts_at'] }
    
    assert_equal user.id, res[0]["user_id"]
    assert_equal car1.id, res[0]["car_id"]
    assert_equal timestr(now), res[0]["starts_at"]
    assert_equal timestr(now + 0.5*h), res[0]["ends_at"]

    assert_equal timestr(now + 1*h), res[1]["starts_at"]
  end

  test "create invalid requests" do

    user = User.new
    user.save!
    car1 = Car.new
    car1.save!

    now = Time.now

    post bookings_url, params: {
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 400, @response.status
    res = JSON.parse(@response.body)
    assert_equal res["error"], "invalid_request"

    post bookings_url, params: {
      car_id: "jfsjh87232",
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 400, @response.status
    res = JSON.parse(@response.body)
    assert_equal res["error"], "invalid_request"

  end

  test "do not allow booking same car twice" do

    user = User.new
    user.save!
    car1 = Car.new
    car1.save!

    now = Time.now

    post bookings_url, params: {
      car_id: car1.id,
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 200, @response.status

    post bookings_url, params: {
      car_id: car1.id,
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 403, @response.status    
    res = JSON.parse(@response.body)
    assert_equal res["error"], "double_booked"
    
  end

  test "do not allow booking deactivated cars" do 
    user = User.new
    user.save!
    car1 = Car.new
    car1.active = false
    car1.save!

    now = Time.now

    post bookings_url, params: {
      car_id: car1.id,
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 403, @response.status
    res = JSON.parse(@response.body)
    assert_equal res["error"], "car_deactivated"
    
  end

  def h
    60 * 60  
  end

  def booking(car_id, starts_at, ends_at)
    post bookings_url, params: {
      car_id: car_id,
      starts_at: timestr(starts_at),
      ends_at: timestr(ends_at), 
    }
    assert_equal 200, @response.status
  end

  def timestr(time)
    time.utc.to_datetime.rfc3339(3).gsub("+00:00", "Z")
  end

  test "filtering the list of bookings by car id" do
    user = User.new
    user.save!

    car1 = Car.new
    car1.save!
    car2 = Car.new
    car2.save!

    now = Time.now

    booking(car1.id, now, now + 0.5*h)
    booking(car1.id, now + 1*h, now + 1.5*h)
    booking(car2.id, now, now + 0.5*h)

    get (bookings_url+"?car_id="+car2.id.to_s)

    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 1, res.length
    
    assert_equal user.id, res[0]["user_id"]
    assert_equal car2.id, res[0]["car_id"]
    assert_equal timestr(now), res[0]["starts_at"]
    assert_equal timestr(now + 0.5*h), res[0]["ends_at"]
  end
end

