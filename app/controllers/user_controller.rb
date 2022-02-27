class UserController < ApplicationController
  
  include BCrypt

  def signup
    
    return user_already_exists(params[:username]) if user_exists?  

    # Gets and creates user from params 
    if create_user
      # Generate JWT token
      token = encode_token(@user.username)
      success(token)
    else
      unauthorized(@user.errors)
    end
  end


  def login
    begin
      @user = User.find_by(username: params[:username])

      # Hashes and checks the password with bcrypt
      if Password.new(@user.password) == params[:password]
        token = encode_token(@user.username)
        success(token)
      else
        unauthorized()
      end
    rescue Mongoid::Errors::DocumentNotFound 
        unauthorized()
    end
  end

  private

  def create_user
    @user = User.new(params.permit(:username, :password))
    
    if @user.valid?
      @user.password = Password.create(@user.password)
      @user.save
      return true
    end
    false
  end
  
  def user_exists?
    begin
      User.find_by(username: params[:username])
      true
    rescue Mongoid::Errors::DocumentNotFound 
      false 
    end 
  end

end