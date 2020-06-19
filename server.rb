#!/usr/bin/env ruby

require 'sinatra'
require 'json'

def generate_activation_code(size = 22)
  charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
  (0...size).map{ charset.to_a[rand(charset.size)] }.join
end

set :bind, "0.0.0.0"
set :port, "8182"

master_key = generate_activation_code()
puts "Temporary Master Key for this Session: #{master_key}"

post '/submit' do
    if params.has_key? "key"
        if params[:key] == master_key
            # Authed
            puts "we auth!"
            open('/tmp/hashpipe', 'a') do |f|
                f.puts params[:hash]
            end
        end
    end    
end