require 'sinatra'
require 'sequel'

err = nil
begin
  DB = Sequel.sqlite
  DB.create_table :users do
    primary_key :id
    String      :username
    String      :password
    Boolean     :over_21
    Boolean     :terms_of_service
  end
rescue Exception => e
  err = e.inspect
end

get '/' do
  @eeee = err
  haml :index
end

# standard
get '/standard' do
  @users = DB[:users]
  haml :'standard/index', :layout => :'standard/layout'
end
get '/standard/terms_of_service' do
  haml :'standard/terms_of_service', :layout => :'standard/layout'
end
get '/standard/signup' do
  haml :'standard/signup', :layout => :'standard/layout'
end
post '/standard/signup' do
  @errors = verify

  if @errors.empty?
    DB[:users].insert(
      :username         => params[:username],
      :password         => params[:password],
      :over_21          => params[:over_21] == 'on',
      :terms_of_service => params[:terms_of_service] == 'on'
    )
    redirect '/standard'
  else
    haml :'standard/signup', :layout => :'standard/layout'
  end
end

# iui
get '/iui' do
  @users = DB[:users]
  haml :'iui/index', :layout => :'iui/layout'
end

get '/iui/terms_of_service' do
  haml :'iui/index', :layout => :'iui/layout'
end

post '/iui/signup' do
  @errors = verify

  if @errors.empty?
    DB[:users].insert(
      :username         => params[:username],
      :password         => params[:password],
      :over_21          => params[:over_21] == 'on',
      :terms_of_service => params[:terms_of_service] == 'on'
    )
    @users = DB[:users]
    haml :'iui/success', :layout => false
  else
    haml :'iui/signup', :layout => false
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
  username = params[:username].strip

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
  password = params[:password].strip

  if password.length == 0
    return 'Your password can not be blank'
  end
  
  if password.length < 6
    return 'Your password must be at least 6 characters long'
  end

  return false
end

def verify_password_confirmation
  password              = params[:password].strip
  password_confirmation = params[:password_confirmation].strip

  if password != password_confirmation
    return 'Your passwords do not match'
  end

  return false
end

def verify_statements
  over_21          = params[:over_21] == 'on',
  terms_of_service = params[:terms_of_service] == 'on'

  if !over_21 || !terms_of_service
    return 'You must agree with both of the statements, above.'
  end

  return false
end
