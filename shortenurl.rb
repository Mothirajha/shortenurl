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
  field :count, type: Integer
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
    url = Url.new
    url.long_url = params[:long_url]
    url.create_shorten_url
    url.save
  end
  @url = Url.all
  erb :home
end
