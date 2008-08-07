require File.dirname(__FILE__) + '/../test_helper'
require 'publish_controller'

# Re-raise errors caught by the controller.
class PublishController; def rescue_action(e) raise e end; end

class PublishControllerTest < Test::Unit::TestCase
  def setup
    @controller = PublishController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
