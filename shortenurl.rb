require 'sinatra'
require 'mongoid'
require 'rubygems'
require 'pry'

configure do
  Mongoid.load!("./mongoid.yml")
end

class Url
  include Mongoid::Document

  field :long_url, type: String
  field :short_url, type: String
  field :count, type: Integer, default: 0
  before_save :create_shorten_url

  def create_shorten_url
    alpha = ('a'..'z').to_a
    numeric = (0..9).to_a
    begin
      self.short_url = alpha.zip(numeric).flatten.compact.uniq.sample(6).join # or whatever you chose like UUID tools
    end while self.class.where(short_url: short_url).exists?
  end
end

get '/' do
  @url = Url.all
  erb :home
end

post '/' do
  if params[:long_url]
    long_url = params[:long_url].strip
    if Url.where(long_url: long_url).count > 0
      redirect '/'
    else
      url = Url.new
      url.long_url = long_url
      url.create_shorten_url
      url.save
    end
  end
  @url = Url.all
  erb :home
end

get '/:unique_key' do
  if params[:unique_key]
    url = Url.find_by(short_url: params[:unique_key])
    if url
      url.count = url.count + 1
      url.save
      redirect url.long_url
    else
      redirect '/'
    end
  end
end
