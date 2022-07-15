# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' # この行を追加。 sinatra-contrib はこのために必要
require 'erb'
require 'json'

before '/*' do
  @memo_db_path = 'json/db.json'
  @memo_db = JSON.parse(open(@memo_db_path).read)
  @all_memos = @memo_db['memos']
end

helpers do
  def get_the_memo(memo_id)
    @all_memos.each do |memo|
      return memo if memo['id'].to_s == memo_id.to_s
    end
  end

  def update_memos
    File.open(@memo_db_path, 'w') do |file|
      JSON.dump(@memo_db, file)
    end
  end

  def escape(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  erb :index
end

get '/form' do
  erb :form
end

post '/form' do
  new_memo_id = @all_memos.length + 1
  new_memo = { 'id' => new_memo_id, 'title' => escape(params[:title]), 'content' => escape(params[:content]) }
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
  new_memo = { 'id' => params[:id], 'title' => escape(params[:title]), 'content' => escape(params[:content]) }
  target_memo_index = params[:id].to_i - 1
  @all_memos[target_memo_index] = new_memo
  update_memos
  redirect to('/')
end

get '/memos/:id/edit' do
  @memo = get_the_memo(params[:id])
  erb :memo_edit
end
