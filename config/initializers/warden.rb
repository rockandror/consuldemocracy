Warden::Manager.after_authentication do |user, auth, opts|
  login = auth.request.params.dig("user", "login")
  ActivityLog.create!(activity: "login", result: "ok", payload: login)
end

Warden::Manager.before_failure do |env, opts|
  request = Rack::Request.new(env)
  login = request.params.dig("user", "login")

  ActivityLog.create!(activity: "login", result: "error", payload: login)
  user = User.find_by(username: login) || User.find_by(email: login)
  if user&.failed_attempts == Setting["login_attempts_before_lock"].to_i
    ActivityLog.create!(activity: "login", result: "blocked", payload: login)
  end
end
