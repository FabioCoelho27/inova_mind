
class ApplicationController < ActionController::API
  
  SECRET = 'inova'
  ISSUER = 'Inovamind'

  def encode_token(username)
  
    payload = {
      exp: (Time.now + 10.minutes).to_i,
      iat: Time.now.to_i,
      iss: ISSUER,
      user: {
        username: username
      }
    }

    JWT.encode(payload, SECRET, 'HS256')
  end

  def decode_token
    header =  request.headers['Authorization']

    if header
      token = header.split(' ')[1]
      options = { algorithm: 'HS256', iss: ISSUER }

      begin
        return JWT.decode(token, SECRET, true, options)

      rescue JWT::ExpiredSignature
        forbidden('The token has expired.')
      rescue JWT::InvalidIssuerError
        forbidden('The token does not have a valid issuer.')
      rescue JWT::InvalidIatError
        forbidden('The token does not have a valid "issued at" time.')
      rescue JWT::DecodeError 
        unauthorized('A valid token must be passed.')
      end
    end
    nil
  end

  def logged_in?
    token = decode_token
    if token
      username = token[0]['user']['username']

      
      begin
        @user = User.find_by(username: username)
      rescue Mongoid::Errors::DocumentNotFound 
        @user = nil
      end
    end
  end



  def authenticate
    unauthorized("Invalid authentication header") unless logged_in?
  end

  def unauthorized(message = "Invalid username or password")
     
      begin
        render json: {error: message}, status: :unauthorized
      rescue AbstractController::DoubleRenderError
      end
  end

  def forbidden(message = "User not allowed")
    render json: {error: message}, status: :forbidden
  end

  def success(token)
    render json: {user: @user.username, token: token}
  end

  def user_already_exists(username)
    render json: {error: "#{username} already signed up"}, status: :bad_request
  end

end
