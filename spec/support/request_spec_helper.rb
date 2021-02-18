module RequestSpecHelper
  def json
    JSON.parse(response.body)
  end

  def login
    allow_any_instance_of(ApplicationController).to receive(:logged_in?).and_return(true)
  end

  def stub_user(current_user)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end
end
