require 'sinatra/base'
require 'sinatra-websocket'
require 'em-websocket'
require 'em-websocket-client'
require 'mongo'
require 'json'
require 'slim'
require 'pry'
require 'better_errors'
require 'haml'
require 'sass'
require 'fetcher-mongoid-models'

Fetcher::Mongoid::Models::Db.new "config/database.yml"


class PostManager < Sinatra::Base

	set :views, "views"
	set :public_folder, "public"
	set :haml, :format => :html5
	set :port, 4567
	set :server, 'thin'
	set :sockets, []
	enable :sessions
	
	use BetterErrors::Middleware
	BetterErrors.application_root = File.expand_path("..", __FILE__)

	get '/style.css' do
		sass :style
	end

	get '/' do

		if !request.websocket?
    	haml :index
  	else
	    request.websocket do |ws|

	      ws.onopen do
	      	#client = EventMachine::WebSocketClient.connect "ws://localhost:8080/"
	        puts "Connection opened"
	        #client.callback do
	        #	client.send_msg "yepla"
	        #end
	        settings.sockets << ws
	      	#binding.pry
	      end

	      ws.onmessage do |msg|
	        binding.pry
	        puts msg
	        EM.next_tick { settings.sockets.each{ |s| s.send(msg) } }
	      end

	      ws.onclose do
	        warn("wetbsocket closed")
	        settings.sockets.delete(ws)
	      end

			end
    end
		
  end

end


