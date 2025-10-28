FactoryBot.define do
  factory :doorkeeper_application, class: 'Doorkeeper::Application' do
    name { 'Test Application' }
  end

  factory :doorkeeper_access_token, class: 'Doorkeeper::AccessToken' do
    application factory: :doorkeeper_application
    resource_owner_id { create(:user).id }
    expires_in { 2.hours }
    scopes { '' }
  end
end
