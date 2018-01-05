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

    check = Asin.find_by(user: user)

    j = 0
    data = []
    charset = nil

    url = org_url + '&page=' + pgnum.to_s

    ua = CSV.read('app/others/User-Agent.csv', headers: false, col_sep: "\t")
    uanum = ua.length

    #user_agent = "Mozilla/5.0 (Windows NT 6.1; rv:28.0) Gecko/20100101 Firefox/28.0"
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

      if check == nil then
        Asin.create(
          user: user,
          asin: list.value
        )
        check = Asin.find_by(user: user)
      else
        check2 = Asin.find_by(asin: list.value)
        if check2 == nil then
          Asin.create(
            user: user,
            asin: list.value
          )
        end
      end

      j += 1
    end

    render json: data
  end

end
