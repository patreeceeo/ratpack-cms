require 'rubygems'
require 'sinatra'
require 'haml'

# Helpers
require './lib/render_partial'

USERNAME="frank"
PASSWORD="admin"

# Set Sinatra variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public_folder, 'public'
set :haml, {:format => :html5} # default Haml format is :xhtml

App = {}
App[:title] = "RatPack, a CMS with class."

enable :sessions
#use Rack::Session::Pool, :expire_after => 2592000
# This seems to be needed to get tests to run.
session ||= {}

def init_session
  if session[:admin].nil?
    puts "admin not logged in\n"
    session[:admin] = {}
    session[:admin][:logged_in] = false
  end
end

def login(username, password) 
  if username == USERNAME and password == PASSWORD
    puts "admin logged in\n"
    session[:admin][:logged_in] = true
  else
    false
  end
end

def logout(username)
  session[:admin][:logged_in] = false
  puts "admin logged out\n"
end

def logged_in?(username)
  session[:admin][:logged_in]
end
#end

before do
  init_session
end

# Application routes
get '/' do
  haml :index, :layout => :'layouts/application'
end

get '/login' do
  haml :login, :layout => :'layouts/application'
end

post '/login' do
  if login(params[:username], params[:password])
    redirect to('/admin')
  else 
    redirect to('/login')
  end
end

get '/logout' do
  logout(USERNAME);
  haml :logout, :layout => :'layouts/application'
end

before '/admin*' do
  if not logged_in?(USERNAME)
    puts "attempt to get /admin when admin not logged in\n"
    redirect to("/login")
  end
end

get '/admin' do
  haml :'admin/index', :layout => :"layouts/admin"
end

get '/admin/:page' do
  page = params[:page]
  haml :"admin/#{page}", :layout => :"layouts/admin"
end

post '/admin/meta' do
  params.each_pair do |key, value|
    puts "Setting '#{key}' to '#{value}'"
    App[:"#{key}"] = value
  end
  redirect to("/admin/meta")
end
