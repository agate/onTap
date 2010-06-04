require 'rubygems'
require 'sinatra'
require 'sequel'

DB = Sequel.sqlite
DB.create_table :users do
  primary_key :id
  String      :username
  String      :password
  Boolean     :over_21
  Boolean     :terms_of_service
end

get '/' do
  @users = DB[:users]
  haml :index
end

get '/terms_of_service' do
  haml :terms_of_service
end

post '/signup' do
  @errors = verify

  if @errors.empty?
    DB[:users].insert(
      :username         => params[:username],
      :password         => params[:password],
      :over_21          => params[:over_21] == 'on',
      :terms_of_service => params[:terms_of_service] == 'on'
    )
    @users = DB[:users]
		haml :success, :layout => false
  else
    haml :signup, :layout => false
  end
end

# -------------------------------------
# verify methods
# -------------------------------------

def verify
  errors = {}
  if username_error = verify_username
    errors[:username] = username_error
  end
  if password_error = verify_password
    errors[:password] = password_error
  end
  if password_confirmation_error = verify_password_confirmation
    errors[:password_confirmation] = password_confirmation_error
  end
  if statements_error = verify_statements
    errors[:statements] = statements_error
  end
  return errors
end

def verify_username
  username = params[:username].to_s.strip

  if username.length == 0
    return 'Your username can not be blank'
  end

  if username.length < 6
    return 'Your username must be at least 6 characters long'
  end

  if DB[:users].filter(:username => username).count > 0
    return 'This username is taken'
  end

  return false
end

def verify_password
  password = params[:password].to_s.strip

  if password.length == 0
    return 'Your password can not be blank'
  end
  
  if password.length < 6
    return 'Your password must be at least 6 characters long'
  end

  return false
end

def verify_password_confirmation
  password              = params[:password].to_s.strip
  password_confirmation = params[:password_confirmation].to_s.strip

  if password != password_confirmation
    return 'Your passwords do not match'
  end

  return false
end

def verify_statements
  over_21          = params[:over_21].to_s == 'on',
  terms_of_service = params[:terms_of_service].to_s == 'on'

  if !over_21 || !terms_of_service
    return 'You must agree with both of the statements, above.'
  end

  return false
end
