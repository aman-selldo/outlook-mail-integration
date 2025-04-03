class EmailsController < ApplicationController
  require 'net/http'
  require 'uri'
  require 'json'

  before_action :authenticate_user!

  def index
    if current_user&.token.present?
      @emails = fetch_emails
    else
      redirect_to root_path, alert: "Please sign in to view emails."
    end
  end

  def show
    email_id = params[:id]
    @email = fetch_email_details(email_id)
  end

  def profile_image
    uri = URI.parse("https://graph.microsoft.com/v1.0/me/photo/$value")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{current_user.token}"
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == "200"
      send_data response.body, type: response["content-type"], disposition: "inline"
    else
      redirect_to root_path, alert: "Could not fetch profile image."
    end
  end

  private

  def fetch_emails

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
      nil
    end
  end

  def fetch_email_details(email_id)
    uri = URI.parse("https://graph.microsoft.com/v1.0/me/messages/#{email_id}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{current_user.token}"
    request["Accept"] = "application/json"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.code == "200"
      JSON.parse(response.body)
    else
      nil
    end
  end

  def authenticate_user!
    redirect_to root_path, alert: "You must be signed in to view emails" unless current_user
  end
end
