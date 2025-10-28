require 'rails_helper'

RSpec.describe 'API Rate Limiting', type: :request do
  # https://www.rubybiscuit.fr/p/proteger-sans-ralentir-tests-optimises
  before(:all) do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  after(:all) do
    Rack::Attack.enabled = false
  end

  before(:each) do
    Rack::Attack.cache.store.clear # Avoid tests overlaps
  end

  # https://stackoverflow.com/questions/60764500/invalid-access-token-when-using-rspec-request-specs-to-authorize-a-request
  let(:user) { create(:user) }
  let(:application) { create(:doorkeeper_application) }
  let(:token) { create(:doorkeeper_access_token) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/books' do
    context 'when exceeding rate limit' do
      it 'returns 429 after limit is reached' do
        # Make requests up to the limit (adjust based on your config)
        100.times do
          get '/api/v1/books', headers: headers
          expect(response).to have_http_status(:ok)
        end

        # Next request should be rate limited
        get '/api/v1/books', headers: headers
        expect(response).to have_http_status(:too_many_requests)
      end
    end

    context 'when within rate limit' do
      it 'allows requests' do
        5.times do
          get '/api/v1/books', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe 'Login rate limiting' do
    it 'throttles excessive login attempts' do
      # Attempt login 5 times (adjust based on your config)
      5.times do
        post '/api/v1/oauth/token', params: {
          grant_type: 'password',
          email: user.email,
          password: 'wrong_password',
          client_id: application.uid,
          client_secret: application.secret
        }
      end

      # 6th attempt should be rate limited
      post '/api/v1/oauth/token', params: {
        grant_type: 'password',
        email: user.email,
        password: user.password,
        client_id: application.uid,
        client_secret: application.secret
      }

      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
