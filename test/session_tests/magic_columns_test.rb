require File.dirname(__FILE__) + '/../test_helper.rb'

module SessionTests
  class MagicColumnsTest < ActiveSupport::TestCase
    def test_last_request_at_threshold_config
      UserSession.last_request_at_threshold = 2.minutes
      assert_equal 2.minutes, UserSession.last_request_at_threshold
    
      UserSession.last_request_at_threshold 0
      assert_equal 0, UserSession.last_request_at_threshold
    end
    
    def test_after_persisting_set_last_request_at
      ben = users(:ben)
      set_cookie_for(ben)
      old_last_request_at = ben.last_request_at
      assert UserSession.find
      ben.reload
      assert ben.last_request_at != old_last_request_at
    end
    
    def test_valide_increase_failed_login_count
      ben = users(:ben)
      old_failed_login_count = ben.failed_login_count
      assert !UserSession.create(:login => ben.login, :password => "wrong")
      ben.reload
      assert_equal old_failed_login_count + 1, ben.failed_login_count
    end
    
    def test_before_save_update_info
      ben = users(:ben)
      
      # increase failed login count
      assert !UserSession.create(:login => ben.login, :password => "wrong")
      ben.reload
      
      # grab old values
      old_login_count = ben.login_count
      old_failed_login_count = ben.failed_login_count
      old_last_login_at = ben.last_login_at
      old_current_login_at = ben.current_login_at
      old_last_login_ip = ben.last_login_ip
      old_current_login_ip = ben.current_login_ip
      
      assert UserSession.create(ben)
      
      assert_equal old_login_count + 1, ben.login_count
      assert_equal old_failed_login_count - 1, ben.failed_login_count
      assert_equal old_current_login_at, ben.last_login_at
      assert ben.current_login_at != old_current_login_at
      assert_equal old_current_login_ip, ben.last_login_ip
      assert_equal "1.1.1.1", ben.current_login_ip
    end
  end
end