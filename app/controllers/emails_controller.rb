class EmailsController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user&.token.present?
      @emails = fetch_emails_from_outlook
    else
      redirect_to root_path, alert: "Please sign in to view emails."
    end
  end

  private

  def fetch_emails_from_outlook
    require 'net/http'
    require 'uri'
    require 'json'

    uri = URI.parse("https://graph.microsoft.com/v1.0/me/mailfolders/inbox/messages")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{current_user.token}"
    request["Accept"] = "application/json"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == "200"
      JSON.parse(response.body)["value"]
    else
      []
    end
  end

  def authenticate_user!
    redirect_to root_path, alert: "You must be signed in to view emails" unless current_user
  end
end
