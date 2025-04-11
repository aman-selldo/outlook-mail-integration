# app/controllers/api/v1/notifications_controller.rb
class Api::V1::NotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.info "📩 Incoming webhook notification:"
    Rails.logger.info request.raw_post
    puts "📩 Incoming webhook notification:\n#{request.raw_post}"

    render plain: "Received", status: :ok
  end
end
