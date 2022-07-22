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
  @all_memos = @memo_db.exec('SELECT * FROM memo ORDER BY id;')
end

def get_the_memo(memo_id)
  @all_memos.find { |memo| memo['id'].to_s == memo_id.to_s }
end

helpers do
  def escape(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  erb :index
end

get '/memos/new' do
  erb :memo_new
end

post '/memos' do
  @memo_db.exec('INSERT into memo (title,content) values ($1, $2);', [params[:title], params[:content]])
  redirect to('/')
end

get '/memos/:id' do
  @memo = get_the_memo(params[:id])
  erb :memo
end

delete '/memos/:id' do
  @memo_db.exec('DELETE from memo WHERE id = $1;', [params[:id]])
  redirect to('/')
end

patch '/memos/:id' do
  p @memo
  new_memo = { id: params[:id], title: params[:title], content: params[:content] }
  @memo_db.exec('UPDATE memo SET title = $2, content = $3 WHERE id = $1;', new_memo.values)
  redirect to('/')
end

get '/memos/:id/edit' do
  @memo = get_the_memo(params[:id])
  erb :memo_edit
end
