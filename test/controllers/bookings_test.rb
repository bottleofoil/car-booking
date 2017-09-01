require 'test_helper'

class BookingsControllerTest < ActionDispatch::IntegrationTest

  test "create and list basic" do

    @auth_token = create_user

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

    get_auth bookings_url

    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 2, res.length

    res.sort_by! { |obj| obj['starts_at'] }
    
    assert_equal car1.id, res[0]["car_id"]
    assert_equal timestr(now), res[0]["starts_at"]
    assert_equal timestr(now + 0.5*h), res[0]["ends_at"]

    assert_equal timestr(now + 1*h), res[1]["starts_at"]
  end

  test "allow creating bookings back to back" do

    @auth_token = create_user

    car1 = Car.new
    car1.save!

    now = Time.now

    booking(
      car1.id,
      now,
      now + 1*h, 
    )
    
    booking(
      car1.id,
      now + 1*h,
      now + 2*h, 
    )

  end

  test "create invalid requests" do

    @auth_token = create_user

    car1 = Car.new
    car1.save!

    now = Time.now

    post_auth bookings_url, params: {
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 400, @response.status
    res = JSON.parse(@response.body)
    assert_equal res["error"], "invalid_request"

    post_auth bookings_url, params: {
      car_id: "jfsjh87232",
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 400, @response.status
    res = JSON.parse(@response.body)
    assert_equal res["error"], "invalid_request"

    post_auth bookings_url, params: {
      car_id: car1.id,
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 400, @response.status
    res = JSON.parse(@response.body)
    assert_equal res["error"], "invalid_request"

    post_auth bookings_url, params: {
      car_id: car1.id,
      starts_at: "asdasdasd",
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 400, @response.status
    res = JSON.parse(@response.body)
    assert_equal res["error"], "invalid_request"    
  end

  test "do not allow booking same car twice" do

    @auth_token = create_user

    car1 = Car.new
    car1.save!

    now = Time.now

    post_auth bookings_url, params: {
      car_id: car1.id,
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 200, @response.status

    post_auth bookings_url, params: {
      car_id: car1.id,
      starts_at: timestr(now),
      ends_at: timestr(now + 0.5*h), 
    }
    assert_equal 403, @response.status    
    res = JSON.parse(@response.body)
    assert_equal res["error"], "double_booked"
    
  end

  test "do not allow booking deactivated cars" do 

    @auth_token = create_user

    car1 = Car.new
    car1.active = false
    car1.save!

    now = Time.now

    post_auth bookings_url, params: {
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
    post_auth bookings_url, params: {
      car_id: car_id,
      starts_at: timestr(starts_at),
      ends_at: timestr(ends_at), 
    }
    assert_equal 200, @response.status
    res = JSON.parse(@response.body)
    return res["id"]
  end

  def timestr(time)
    time.utc.to_datetime.rfc3339(3).gsub("+00:00", "Z")
  end

  test "prevent user from seeing bookings of other users" do 
    user1 = create_user
    user2 = create_user("user2@e.com")
    @auth_token = user1

    car1 = Car.new
    car1.save!

    now = Time.now

    booking(car1.id, now, now + 0.5*h)
    assert_equal 200, @response.status

    @auth_token = user2
    get_auth bookings_url

    res = JSON.parse(@response.body)

    assert_equal 200, @response.status
    assert_equal 0, res.length
  end

  test "filtering the list of bookings by car id" do
    @auth_token = create_user

    car1 = Car.new
    car1.save!
    car2 = Car.new
    car2.save!

    now = Time.now

    booking(car1.id, now, now + 0.5*h)
    booking(car1.id, now + 1*h, now + 1.5*h)
    booking(car2.id, now, now + 0.5*h)

    get_auth (bookings_url+"?car_id="+car2.id.to_s)

    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 1, res.length
    
    assert_equal car2.id, res[0]["car_id"]
    assert_equal timestr(now), res[0]["starts_at"]
    assert_equal timestr(now + 0.5*h), res[0]["ends_at"]
  end

  test "filtering the list of bookings by upcoming and current" do
    @auth_token = create_user

    car1 = Car.new
    car1.save!
    car2 = Car.new
    car2.save!

    now = Time.now

    booking(car1.id, now - 2*h, now - 1*h)
    booking(car1.id, now, now + 1*h)
    booking(car1.id, now + 1.5*h, now + 2*h)

    get_auth (bookings_url+"?filter=current")
    
    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 1, res.length

    assert_equal timestr(now), res[0]["starts_at"]
    assert_equal timestr(now + 1*h), res[0]["ends_at"]

    get_auth (bookings_url+"?filter=upcoming")
    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 1, res.length

    assert_equal timestr(now + 1.5*h), res[0]["starts_at"]
    assert_equal timestr(now + 2*h), res[0]["ends_at"]

  end

  test "filtering the list of bookings by both upcoming,current and car id" do
    @auth_token = create_user

    car1 = Car.new
    car1.save!
    car2 = Car.new
    car2.save!

    now = Time.now

    booking(car1.id, now - 2*h, now - 1*h)
    booking(car1.id, now, now + 1*h)
    booking(car1.id, now + 1.5*h, now + 2*h)
    booking(car2.id, now - 2*h, now - 1*h)
    booking(car2.id, now, now + 1*h)
    booking(car2.id, now + 1.5*h, now + 2*h)

    get_auth (bookings_url+"?filter=current&car_id="+car2.id.to_s)
    
    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 1, res.length

    assert_equal car2.id, res[0]["car_id"]
    assert_equal timestr(now), res[0]["starts_at"]
    assert_equal timestr(now + 1*h), res[0]["ends_at"]   
  end

  test "filtering the list of bookings by started, ended" do
    @auth_token = create_user

    user = User.take

    car1 = Car.new
    car1.save!

    now = Time.now

    b1 = Booking.new
    b1.user_id = user.id
    b1.car_id = car1.id
    b1.starts_at = now 
    b1.ends_at = now + 1*h
    b1.save!

    b2 = Booking.new
    b2.user_id = user.id
    b2.car_id = car1.id
    b2.starts_at = now + 1*h
    b2.ends_at = now + 2*h
    b2.status = "started"
    b2.save!

    b3 = Booking.new
    b3.user_id = user.id
    b3.car_id = car1.id
    b3.starts_at = now + 2*h
    b3.ends_at = now + 3*h
    b3.status = "completed"
    b3.save!    

    now = Time.now

    get_auth bookings_url

    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 3, res.length

    res.sort_by! { |obj| obj['starts_at'] }    
    assert_equal "started", res[1]["status"], "status is printed as text"

    get_auth bookings_url + "?filter=started"

    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 1, res.length
    assert_equal "started", res[0]["status"]

    get_auth bookings_url + "?filter=completed"

    res = JSON.parse(@response.body)
    assert_equal 200, @response.status
    assert_equal 1, res.length
    assert_equal "completed", res[0]["status"]    

  end

  test "allow starting and ending bookings" do

    @auth_token = create_user

    car1 = Car.new
    car1.save!
    car2 = Car.new
    car2.save!
    car3 = Car.new
    car3.save!

    now = Time.now

    b1 = booking(car1.id, now - 2*h, now - 0.5*h)
    b2 = booking(car1.id, now - h/6, now + 1*h)
    b3 = booking(car2.id, now + h/6, now + 1*h)
    b4 = booking(car3.id, now + 0.5*h, now + 1*h)

    post_auth bookings_url + "/" + b1.to_s + "/start"
    assert_equal 400, @response.status, "starting too late"
    post_auth bookings_url + "/" + b2.to_s + "/start"
    assert_equal 200, @response.status, "starting on time"
    post_auth bookings_url + "/" + b3.to_s + "/start"
    assert_equal 200, @response.status, "starting on time"
    post_auth bookings_url + "/" + b4.to_s + "/start"
    assert_equal 400, @response.status, "starting too early"
    
  end

  test "only allow the user who created the booking to modify them" do 
    user1 = create_user
    user2 = create_user("e2@e.com")
   
    car1 = Car.new
    car1.save!
    now = Time.now
    @auth_token = user1
    b1 = booking(car1.id, now - h/6, now + 1*h)

    @auth_token = user2
    post_auth bookings_url + "/" + b1.to_s + "/start"

    res = JSON.parse(@response.body)
    assert_equal 403, @response.status
    assert_equal "not_owned", res["error"]   

    @auth_token = user1
    post_auth bookings_url + "/" + b1.to_s + "/start"
    res = JSON.parse(@response.body)
    assert_equal 200, @response.status

  end

  test "do not allow starting the same booking twice or ending unstarted" do

    @auth_token = create_user

    car1 = Car.new
    car1.save!

    now = Time.now

    b1 = booking(car1.id, now, now + 0.5*h)
    post_auth bookings_url + "/" + b1.to_s + "/end"
    assert_equal 400, @response.status, "ending not started"

    post_auth bookings_url + "/" + b1.to_s + "/start"
    assert_equal 200, @response.status, "start normal" 

    post_auth bookings_url + "/" + b1.to_s + "/start"
    assert_equal 400, @response.status, "starting started"

    post_auth bookings_url + "/" + b1.to_s + "/end"
    assert_equal 200, @response.status, "regular ending"        
    post_auth bookings_url + "/" + b1.to_s + "/end"
    assert_equal 400, @response.status, "ending ended"        

  end

end

