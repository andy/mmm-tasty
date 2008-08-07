require File.dirname(__FILE__) + '/../test_helper'
require 'bookmarklet_controller'

# Re-raise errors caught by the controller.
class BookmarkletController; def rescue_action(e) raise e end; end

class BookmarkletControllerTest < Test::Unit::TestCase
  def setup
    @controller = BookmarkletController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
