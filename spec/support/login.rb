module LoginHelper
  def login_as(role)
    visit new_sessions_path
    fill_in "email", with: role.user.email
    fill_in "password", with: role.user.password
    click_button "Log in"
  end
end
