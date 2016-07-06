module ControllerIntegrationTestHelper
  USER_NAME = 'dummy'
  PASSWORD = 'password'

  def authenticate_session!
    @user = Scalarm::Database::Model::ScalarmUser.new(login: USER_NAME)
    @user.password = PASSWORD
    @user.save

    ApplicationController.any_instance.stubs(:authenticate)
    ApplicationController.any_instance.stubs(:current_user).returns(@user)
  end
end
