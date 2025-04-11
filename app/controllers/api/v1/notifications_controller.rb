class Api::V1::NotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    if params[:validationToken]
      Rails.logger.info "Validation Token Received: #{params[:validationToken]}"
      render plain: params[:validationToken], status: 200
    else
      begin
        payload = JSON.parse(request.raw_post)
        Rails.logger.info "Received Webhook Notification:\n#{JSON.pretty_generate(payload)}"
      rescue JSON::ParserError => e
        Rails.logger.error " Failed to parse webhook JSON: #{e.message}"
        Rails.logger.error " Raw Payload: #{request.raw_post}"
      end

      head :ok
    end
  end
end
