require File.dirname(__FILE__) + "/../app.rb"
require "rack/test"
require "mongoid"

set :environment, :test
enable :sessions
ENV['RACK_ENV'] = 'test'

def app
  Sinatra::Application
end


describe "Admin Login/Logout Feature" do
  include Rack::Test::Methods

  it "should let you login when you use the right credentials" do
    post "/login", params = {:username => USERNAME, :password => PASSWORD} 
    follow_redirect!
    last_response.body.should include("loginstatus='logged in'");
  end

  it "should not let you login with wrong username" do
    post "/login", params = {:username => "bogus#{USERNAME}", :password => PASSWORD} 
    follow_redirect!
    last_response.body.should include("loginstatus='logged out'");
  end
  
  it "should not let you login with wrong password" do
    post "/login", params = {:username => USERNAME, :password => "bogus#{PASSWORD}"} 
    follow_redirect!
    last_response.body.should include("loginstatus='logged out'");
  end

  it "should not let you access the admin index page when logged out." do
    get "/admin"
    follow_redirect!
    last_response.body.should include("loginstatus='logged out'");
  end

  it "should not let you access an admin page when logged out." do
    get "/admin/meta"
    follow_redirect!
    last_response.body.should include("loginstatus='logged out'");
  end

  it "should log you out when you try to log out." do
    post "/login", params = {:username => USERNAME, :password => PASSWORD} 
    get "/logout"
    last_response.body.should include("loginstatus='logged out'");
  end
end

describe "Admin Pages" do
  include Rack::Test::Methods

  before :each do
    puts "logging in our tester"
    post "/login", params = {username: USERNAME, password: PASSWORD}
  end

  it "should let you update page titles" do
    random_title = "dsjhf8sdf[dfhjdfs437dbabah"
    post "/admin/meta", params = {:title => random_title}
    follow_redirect!
    get "/"
    last_response.body.should include("<title>#{random_title}</title>")
  end 

  it "should let you create pages" do
    puts "trying to create a page"
    post "admin/publishing/pages", params = {:action => :create, name: "test_page", path: ""}
    last_response.should be_ok
  end

#  it "should let you create pages" do
#    puts "trying to create a page"
#    post "admin/publishing/pages", params = {:action => :create, name: "test_page", path: ""}
#    get "/test_page"
#    last_response.should be_ok
#  end

end
