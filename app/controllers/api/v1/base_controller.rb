module Api
  module V1
    class BaseController < ApplicationController
      include Pagy::Backend
      
      before_action :doorkeeper_authorize!

      skip_before_action :verify_authenticity_token

      respond_to :json

      def current_user
        return unless doorkeeper_token

        @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
      end
    end
  end
end
