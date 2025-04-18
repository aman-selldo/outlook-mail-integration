Rails.application.config.middleware.use OmniAuth::Builder do
  provider :microsoft_graph, 
    ENV['MICROSOFT_CLIENT_ID'],
    ENV['MICROSOFT_CLIENT_SECRET'],
    {
      # scope: "openid email profile",
      scope: "openid email profile Mail.Read Mail.Send User.Read offline_access",
      provider_ignores_state: true,  
      # redirect_uri: "http://localhost:3000/auth/microsoft_graph/callback"
      redirect_uri: "https://8ba3-219-91-158-194.ngrok-free.app/auth/microsoft_graph/callback"
    }
end

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true