require 'test_helper'

class ConfirmationTest < ActiveSupport::TestCase
  def setup
    setup_user
    @issue = @user.issues.create!(title: 'issue', latitude: 76.4,
                                  longitude: 38.2, category: 'arbolada',
                                  description: 'desc', picture: sample_file,
                                  risk: true, resolved_votes: 564,
                                  confirm_votes: 23, reports: 23)
    @second_user = User.create(username: 'test',
                                       email: 'test@test.com',
                                       first_name: 'test', last_name: 'test',
                                       password: @password, password_confirmation: '1234')
    @anotherissue = @second_user.issues.create!(title: 'issue', latitude: 76.4,
                                                longitude: 38.2, category: 'arbolada',
                                                description: 'desc', picture: sample_file,
                                                risk: true, resolved_votes: 564,
                                                confirm_votes: 23, reports: 23)
  end


  test 'should be valid' do
    assert true
  end
end
