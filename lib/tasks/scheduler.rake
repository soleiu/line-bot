desc "This task is called by the Heroku scheduler add-on"
task :updata_feed => :environment do
  require 'line/bot' #gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  client ||=Line::Bot::Client.new {|config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }

  #使用したxmlデータ(毎日朝6時更新):以下URLを入力すれば見ること
  url = "https://www.drk7.jp/weather/xml/13.xml"
  #xmlデータを利用しやすい様に整形
  xml = open(url).read.toutf8
  doc = REXML::Docment.new(xml)
  # パスの共通部分を変数化(area[4]は東京地方を指定)
  xpath = 'weatherforecast/pref/area[4]/info/rainfallchance/'
  #6時〜12時の降水確率（以下同様）
  per06to12 = doc.elements[xpath + 'period[2]'].text
  per12to18 = doc.elements[xpath + 'period[3]'].text
  per18to24 = doc.elements[xpath + 'period[4]'].text
  #メッセージを発信しる降水確率の下限値の設定
  min_per = 20
  if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
    word1 =
    ["おはよう♡",
     "よく眠れた？",
     "早起きしてえらいね！",
     "いつもよりも起きるの遅くない？"].samle
    word2 = 
    ["気をつけて行ってらっしゃい♡",
    "良い1日になりますよーに！",
    "雨だけど今日もがんばってね〜(^_^)",
    "良いことがあります様に！"].sample 
  #降水確率によってメッセージを変更する値の設定
  mid_per = 50
  if per06to12.to_i >= mid_per || per12to18.to_i >= mid_per || per18to24.to_i >=mid_per
    word3 = "今日は雨が降りそうだから傘を忘れないでね！"
  else   
    word3 = "今日は雨が降るかもしれないから折り畳み傘があると安心かも(o^^o)"
  end
  push =
      "#{word1}\n#{word3}\n降水確率はこんな感じだよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word2}"
    # メッセージの発信先idを配列で渡す必要があるため、userテーブルよりpluck関数を使ってidを配列で取得
    user_ids = User.all.pluck(:line_id)
    message = {
      type: 'text',
      text: push
    }
    response = client.multicast(user_ids, message)
  end
  "OK"
end