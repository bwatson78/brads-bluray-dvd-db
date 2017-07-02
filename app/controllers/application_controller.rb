require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "brads db is secure"
  end

  get '/' do
    if is_logged_in?
      redirect to '/movies'
    else
      erb :index
    end
  end

  get '/movies' do
    if is_logged_in?
      @movies = current_user.movies.order(:name)
        erb :'users/show'
    else
      redirect to '/login'
    end
  end

  get '/movies/new' do
    if is_logged_in?
      erb :'movies/create_movie'
    else
      redirect to '/login'
    end
  end

  get '/movies/:id' do
    if is_logged_in?
      @movie = Movie.find_by_id(params[:id])
      if @movie.user_id == current_user.id
        erb :'/movies/show_movie'
      else
        redirect to '/movies'
      end
    else
      redirect to '/login'
    end
  end

  get '/movies/:id/edit' do
    if is_logged_in?
      @movie = Movie.find_by_id(params[:id])
      if @movie.user_id == current_user.id
        erb :'movies/edit_movie'
      else
        redirect to '/movies'
      end
    else
      redirect to '/login'
    end
  end

  post '/movies' do
    if params[:movie].detect {|i| i == nil} || params[:movie].detect {|i| i == ""} || params[:movie][:year_released].to_i < 1900 || params[:movie][:year_released].to_i > Time.now.year
      redirect to '/movies/new'
    else
      if is_logged_in?
        @movie = current_user.movies.create(params[:movie])
        if !params["actor"]["name"].empty?
          @movie.actors << Actor.find_or_create_by(name: params["actor"]["name"])
        end
        if !params["actor_2"]["name"].empty?
          @movie.actors << Actor.find_or_create_by(name: params["actor_2"]["name"])
        end
        @movie.save
        redirect("/movies/#{@movie.id}")
      else
        redirect to '/login'
      end
    end
  end

  patch '/movies/:id' do
    if params[:movie].detect {|i| i == nil} || params[:movie].detect {|i| i == ""} || params[:movie][:year_released].to_i < 1900 || params[:movie][:year_released].to_i > Time.now.year
      redirect to "/movies/#{params[:id]}/edit"
    else
      if is_logged_in?
        @movie = Movie.find(params[:id])
        @movie.update(params[:movie])
        if !params["actor"]["name"].empty?
          @movie.actors << Actor.create(name: params["actor"]["name"])
        end
        if !params["actor_2"]["name"].empty?
          @movie.actors << Actor.create(name: params["actor_2"]["name"])
        end
        @movie.save
        redirect("/movies/#{@movie.id}")
      else
        redirect to '/login'
      end
    end
  end

  delete '/movies/:id/delete' do

    if is_logged_in?
      @movie = Movie.find_by_id(params[:id])
      if @movie.user_id == current_user.id
        @movie.delete
        redirect to '/movies'
      else
        redirect to '/movies'
      end
    else
      redirect to '/login'
    end
  end

  get '/signup' do
    if !is_logged_in?
      erb :'/users/create_user'
    else
      redirect to '/movies'
    end
  end

  post '/signup' do
    if is_logged_in?
      redirect '/movies'
    else
      if !params[:username].empty? && !params[:email].empty? && !params[:password].empty?
        @user = User.new(:username=> params[:username], :email => params[:email], :password => params[:password])
        if @user.save
          session[:user_id] = @user.id
          redirect '/movies'
        else
          redirect to '/signup'
        end
      else
        redirect to '/signup'
      end
    end
  end

  get '/login' do
    if !is_logged_in?
      erb :'users/login'
    else
      redirect to '/movies'
    end
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
     session[:user_id] = @user.id
     redirect to '/movies'
    else
     redirect to '/login'
    end
  end

  get '/logout' do
    if is_logged_in?
      session.destroy
      redirect to '/'
    else
      redirect to '/'
    end
  end

  helpers do

    def is_logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end
end
