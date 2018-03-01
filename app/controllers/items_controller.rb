class ItemsController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'csv'

  before_action :authenticate_user!

  def generate
    @user = current_user.email
  end

  def search

    body = params[:data]
    body = JSON.parse(body)
    org_url = body[0]
    pgnum = body[1]
    maxnum = body[2]
    cnum = body[3]

    user = current_user.email

    j = 0
    data = []
    charset = nil

    url = org_url + '&page=' + pgnum.to_s

    ua = CSV.read('app/others/User-Agent.csv', headers: false, col_sep: "\t")
    uanum = ua.length
    user_agent = ua[rand(uanum)][0]
    logger.debug("\n\nagent is ")
    logger.debug(user_agent)
    begin
      html = open(url, "User-Agent" => user_agent) do |f|
        charset = f.charset
        f.read # htmlを読み込んで変数htmlに渡す
      end
    rescue OpenURI::HTTPError => error
      response = error.io
      logger.debug("\nNo." + pgnum.to_s + "\n")
      logger.debug("error!!\n")
      logger.debug(error)
    end

    doc = Nokogiri::HTML.parse(html, charset)
    doc.css('li/@data-asin').each do |list|
      cnum += 1
      logger.debug(cnum)
      if cnum > maxnum then
        break;
      end
      data[j] = []
      data[j][0] = list.value

      j += 1
    end

    render json: data
  end

end
