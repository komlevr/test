class CertsController < ApplicationController
require 'uri'
  protect_from_forgery with: :null_session

  def index
    all = Cert.all
    if all.nil?
      render staatus: 404, json: all
    else
      render status: 200, json: all
    end
  end
  def create
    if params[:domain].empty?
      render status: 409, json: "Пусто"
      return
    end
    if Cert.exists?(:domain => params[:domain]) 
      render status: 409, json: "Сертификат уже создан"
      return
    else
      new = Cert.create(domain: params[:domain])
      if new.save
        CheckStatWorker.perform_async(params[:domain], new.id)
        render status: 201, json: new
      else
        render status: 409, json: "ошибка"
        return
      end
    end
  end
  def get_host(addr)
    host = URI.parse( addr )
    if host.host[0..3] = 'www.'
      @addr = host.host[4..-1]
    else
      @addr = host.host
    end
  end
end
