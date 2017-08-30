# Ruby on Rails interview exercise #2

Thanks for taking the time to complete this exercise. We're excited that you're considering joining our amazing team.

The goal of this exercise is to create a simple application that will allow API clients to signup and to create bookings for existing vehicles.

We will appreciate if you will go with Rails 4 or 5, but it doesn't matter which database you are going to use (if you don’t have any preference go with MySQL). Please don’t use Rails scaffolding and gems outside of typical Rails stack if you don’t have to.

To start with the exercise please create repository in Git and follow the instructions below.

When you're done, please link your contact person to your repository at GitHub or Bitbucket, or submit your solution compressed and attached to an email.

## Description 

Each user has an email, a password and can have one of these states "active" or "inactive". Email and password are provided by the API client during the signup process. Afterwards, the email and the password are used in order to authenticate an active user.

Each user should be able to have one or more bookings. Each booking belongs to a vehicle and holds the start time and the end time.

Each vehicle can be deactivated.

**The application should have these API endpoints implemented:**
* User signup 
* Authentication
* Booking creation
    * it shouldn't be possible to book a vehicle if it is already booked for the specific time frame or vehicle is deactivated
* List of bookings
    * it should be possible to filter: upcoming, current, started, ended bookings and filter bookings by vehicle_id
* Endpoint to start a booking
    * it shouldn't be possible to start a booking earlier than 15 minutes
    * it shouldn't be possible to start a booking if start time has more than 15 minutes overdue
* Endpoint to end a booking
    * it shouldn't be possible to end a booking without starting it first

## General Notes

* Please apply RESTful API design
* All API requests and responses should use JSON for Content-Type
* API should accept serialized JSON on PUT/PATCH/POST request bodies
* API should always return appropriate HTTP status codes
* API when it is necessary should provide useful error messages in a consumable format (validation error case, exception or any other situation when API client might need it)
* Please implement token-based API authentication taking in count user state
* Users should be authorized to create bookings, view, start and end own bookings
* Please don't trust client input and keep security in mind
* Please feel free to apply all good practices that you might have on your mind ;-)

## Bonus points

* Please implement API versioning 
* Please implement self expiring authentication tokens (tokens should expire in 14 days) 
* Please write brief documentation for API endpoints that were implemented

## Areas of Concern

We will be grading your code on a number of different criteria, but here are some things to keep in mind.

    1.    We prefer readable code over clever code
    2.    We will be inspecting your commits independently
    3.    We like explanations in commits for why things were changed
    4.    We like separation of concerns (data, presentation, controls)
    5.    We really like tests, preferably written in RSpec

## Tips & Hints

* Demonstration of best practices
* SOLID principles
* Design patterns
* PORO
* TDD