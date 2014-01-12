require './pedometer.rb'
require 'test/unit'
require 'rack/test'

class PedometerTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_metrics
    get '/metrics', :data => "0.123,-0.123,5;", :user => {:stride => 90, :rate => 4}

    assert_equal 200, last_response.status
    assert_equal '{"steps":1,"distance":90.0,"time":"0.25 seconds"}', last_response.body
  end

  def test_metrics_no_params
    get '/metrics'

    expected = 'Bad Input. Ensure accelerometer or gravity data is properly formatted.'
    assert_equal 400, last_response.status
    assert_equal expected, last_response.body
  end

  def test_metrics_no_user_param
    get '/metrics', :data => "0.123,-0.123,5;"

    assert_equal 200, last_response.status
    assert_equal '{"steps":1,"distance":74.0,"time":"0.2 seconds"}', last_response.body
  end

  def test_metrics_no_data_param
    get '/metrics', :user => {:stride => 90, :rate => 4}

    expected = 'Bad Input. Ensure accelerometer or gravity data is properly formatted.'
    assert_equal 400, last_response.status
    assert_equal expected, last_response.body
  end  

  def test_metrics_bad_data_param
    get '/metrics', :data => 'bad data', :user => {:stride => 90, :rate => 4}

    expected = 'Bad Input. Ensure accelerometer or gravity data is properly formatted.'
    assert_equal 400, last_response.status
    assert_equal expected, last_response.body
  end

  def test_metrics_bad_user_param
    get '/metrics', :data => "0.123,-0.123,5;", :user => 'bad user'

    assert_equal 200, last_response.status
    assert_equal '{"steps":1,"distance":74.0,"time":"0.2 seconds"}', last_response.body
  end

  # -- Real Data Tests ------------------------------------------------------

  # TODO: This data set is a good example of filtering through steps that are too "quick"
  def test_gravity_walking_10_steps_1
    get '/metrics', :data => File.read('test/data/walking-10-g-1.txt'), :user => {:stride => 90, :rate => 100}

    assert_equal 200, last_response.status
    assert_equal '{"steps":9,"distance":810.0,"time":"10.37 seconds"}', last_response.body
  end

  def test_gravity_walking_10_steps_2
    get '/metrics', :data => File.read('test/data/walking-10-g-2.txt'), :user => {:stride => 90, :rate => 100}

    assert_equal 200, last_response.status
    assert_equal '{"steps":8,"distance":720.0,"time":"9.81 seconds"}', last_response.body
  end

  def test_gravity_jogging_10_steps_1
    get '/metrics', :data => File.read('test/data/jogging-10-g-1.txt'), :user => {:stride => 90, :rate => 100}

    assert_equal 200, last_response.status
    assert_equal '{"steps":10,"distance":900.0,"time":"9.39 seconds"}', last_response.body
  end

  def test_gravity_jogging_10_steps_2
    get '/metrics', :data => File.read('test/data/jogging-10-g-2.txt'), :user => {:stride => 90, :rate => 100}

    assert_equal 200, last_response.status
    assert_equal '{"steps":11,"distance":990.0,"time":"9.48 seconds"}', last_response.body
  end

  def test_gravity_purse_10_steps_1
    get '/metrics', :data => File.read('test/data/purse-10-g-1.txt'), :user => {:stride => 90, :rate => 100}

    assert_equal 200, last_response.status
    assert_equal '{"steps":9,"distance":810.0,"time":"9.31 seconds"}', last_response.body
  end

  def test_gravity_purse_10_steps_2
    get '/metrics', :data => File.read('test/data/purse-10-g-2.txt'), :user => {:stride => 90, :rate => 100}

    assert_equal 200, last_response.status
    assert_equal '{"steps":10,"distance":900.0,"time":"10.54 seconds"}', last_response.body
  end

end