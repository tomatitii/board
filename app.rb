# coding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'active_record'

enable :sessions

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'userboard.db'
)

class Password < ActiveRecord::Base
end

class Message < ActiveRecord::Base
end

get '/' do
    @title = 'Choose Form Type'
    erb :index
end

get '/signup' do
    erb :signup
end

post '/register' do
    duplicate_user = Password.find_by(:user => params[:username])
    if duplicate_user
        @error_message = "このユーザーネームは既に使われています"
        erb :signup
    else
        @user = Password.new(:user => params[:username], :password => params[:password])
        if @user.save
            session[:user_id] = @user.id
            redirect "/board"
        else
            erb :signup
        end
    end
end

get '/login' do
    erb :index
end

post '/login' do
    @user = Password.find_by(:user => params[:username], :password => params[:password])
    if @user.nil?
        @error_message = "ログインできませんでした"
        return erb :index
    end
    session[:user_id] = @user.id
    redirect "/board"
end

post '/logout' do
    session.clear
    redirect '/'
end

get '/board' do
    if session[:user_id].nil?
        redirect '/'
    end
    user = Password.find_by(:id =>session[:user_id])
    @username = user.user
    @messages = Message.all
    erb :board
end

post '/board' do
    if session[:user_id].nil?
        redirect '/'
    end

    user = Password.find_by(:id =>session[:user_id])

    Message.create(
        :user => user.user,
        :message => params[:message],
        :date => Time.now
    )

    redirect '/board'
end
    