# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader' # この行を追加。 sinatra-contrib はこのために必要
require 'erb'
require 'pg'

DB = 'memoapp'

configure do
  set :db, PG::Connection.new(dbname: DB)
end

before '/*' do
  @memo_db = setting.db
  @all_memos = @mymemo_db.exec('SELECT * FROM memo ORDER BY created_at;')
end

helpers do
end

get '/hello/*' do |name|
  "hello #{name}. how are you?"
end

get '/' do
  erb :index
end

get '/form' do
  erb :form
end
