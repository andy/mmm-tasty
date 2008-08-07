require File.dirname(__FILE__) + '/../test_helper'
require 'settings_sidebar_controller'

# Re-raise errors caught by the controller.
class SettingsSidebarController; def rescue_action(e) raise e end; end

class SettingsSidebarControllerTest < Test::Unit::TestCase
  def setup
    @controller = SettingsSidebarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
