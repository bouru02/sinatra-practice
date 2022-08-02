# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'pg'

DB = 'memoapp'

configure do
  set :db, PG::Connection.new(dbname: DB)
end

before '/*' do
  @memo_db = settings.db
end

helpers do
  def escape(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @all_memos = @memo_db.exec('SELECT * FROM memo ORDER BY id;')
  erb :index
end

get '/memos/new' do
  erb :memo_new
end

post '/memos' do
  @memo_db.exec('INSERT INTO memo (title,content) VALUES ($1, $2);', [params[:title], params[:content]])
  redirect to('/')
end

get '/memos/:id' do
  @memo = @memo_db.exec('SELECT * FROM memo WHERE id = $1;', [params[:id]])[0]
  erb :memo
end

delete '/memos/:id' do
  @memo_db.exec('DELETE FROM memo WHERE id = $1;', [params[:id]])
  redirect to('/')
end

patch '/memos/:id' do
  @memo_db.exec('UPDATE memo SET title = $1, content = $2 WHERE id = $3;', [params[:title], params[:content], params[:id]])
  redirect to('/')
end

get '/memos/:id/edit' do
  @memo = get_the_memo(params[:id])
  erb :memo_edit
end
