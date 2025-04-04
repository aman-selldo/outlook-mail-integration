require 'net/http'
require 'uri'
require 'json'

class EmailsController < ApplicationController

  before_action :authenticate_user!

  def index
    if current_user&.token.present?
      @emails = fetch_emails
    else
      redirect_to root_path, alert: "Please sign in to view emails."
    end
  end

  def new
    @email = {}
  end

  def send_email
    recipient = params[:to]
    subject = params[:subject]
    body = params[:body]

    if recipient.blank? || subject.blank? || body.blank?
      redirect_to new_email_path, alert: "All fields are required."
      return
    end
  
    uri = URI.parse("https://graph.microsoft.com/v1.0/me/sendMail")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{current_user.token}"
    request["Content-Type"] = "application/json"
  
    email_data = {
      message: {
        subject: subject,
        body: {
          contentType: "HTML",
          content: body
        },
        toRecipients: [
          {
            emailAddress: {
              address: recipient
            }
          }
        ]
      }
    }
  
    request.body = email_data.to_json
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    if response.code.to_i == 202 || response.code.to_i == 200
      redirect_to emails_path, notice: "Email sent successfully!"
    else
      error_message = "Failed to send email. Code: #{response.code}, Message: #{response.body}"
      Rails.logger.error error_message
      redirect_to new_email_path, alert: error_message
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

    uri = URI.parse("https://graph.microsoft.com/v1.0/me/mailfolders/inbox/messages?$top=50")
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
