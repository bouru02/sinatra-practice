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
  @memo_db = setting.db
  @all_memos = @memo_db.exec('SELECT * FROM memo ORDER BY created_at;')
end

def get_the_memo(memo_id)
  @all_memos.find { |memo| memo['id'].to_s == memo_id.to_s }
end

def update_memos
  File.open(@memo_db_path, 'w') do |file|
    JSON.dump(@memo_db, file)
  end
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
  new_memo_id = @all_memos.length + 1
  new_memo = { id: new_memo_id, title: params[:title], content: params[:content] }
  @all_memos.push(new_memo)
  update_memos
  redirect to('/')
end

get '/memos/:id' do
  @memo = get_the_memo(params[:id])
  erb :memo
end

delete '/memos/:id' do
  @all_memos.delete_if do |memo|
    memo['id'].to_s == params[:id]
  end
  update_memos
  redirect to('/')
end

patch '/memos/:id' do
  new_memo = { id: params[:id], title: params[:title], content: params[:content] }
  target_memo_index = params[:id].to_i - 1
  @all_memos[target_memo_index] = new_memo
  update_memos
  redirect to('/')
end

get '/memos/:id/edit' do
  @memo = get_the_memo(params[:id])
  erb :memo_edit
end
