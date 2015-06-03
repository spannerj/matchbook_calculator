require './app.rb'
run Sinatra::Application

map "/favicon.ico" do
    run Rack::File.new("./public/favicon.ico")
end