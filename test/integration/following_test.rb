require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
   def setup
    @user  = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end
end
