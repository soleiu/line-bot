class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'


  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end
    events = client.parse_events_from(body)
    events.each { |event|
      case event
        # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        case event.type
          # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          # event.message['text']：ユーザーから送られたメッセージ
          input = event.message['text']
          url  = "https://www.drk7.jp/weather/xml/13.xml"
          xml  = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          xpath = 'weatherforecast/pref/area[4]/'
          # 当日朝のメッセージの送信の下限値は20％ 明日・明後日雨が降るかどうかの下限値は30％としている
          min_per = 30
          case input
          when /.*(明日|あした).*/
            # info[2]：明日の天気
            per06to12 = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
            pp "AAA"
              push =
                "明日の天気だよね。\n明日は雨が降りそうだよ(>_<)\n今のところ降水確率はこんな感じだよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            end
          when /.*(明後日|あさって).*/
            per06to12 = doc.elements[xpath + 'info[3]/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info[3]/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info[3]/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明後日の天気だよね。\n何かあるのかな？\n明後日は雨が降りそう…\n当日の朝に雨が降りそうだったら教えるからね！"
            else
              push =
                "明後日の天気？\n気が早いねー！何かあるの？？\n明後日は雨は降らない予定だよ(^^)\nまた当日の朝の最新の天気予報で雨が降りそうだったら教えるからね！"
            end
          when /.*(トトロ).*/
            push =
              "見たことある？私はあるんだよ〜　すっごく大きいのと、中くらいのと、小さいのがいるんだよ〜\n真っ黒いススみたいなのもいるんだよ〜"
          when /.*(ネコバス).*/
            push = 
              "ネコバスはすっごく風が強い日に走ってるんだって！私はいつもビューって飛ばされちゃうんだよ〜今度、トトロと乗せてもらわなくっちゃ！！"

          when /.*(かわいい|可愛い|カワイイ|きれい|綺麗|キレイ|素敵|ステキ|すてき|面白い|おもしろい|ありがと|すごい|スゴイ|スゴい|頑張|がんば|ガンバ).*/
            push =
              "ありがとう！！！\n優しい言葉をかけてくれるあなたはとても素敵です(^^)"
          when /.*(こんにちは|こんばんは|初めまして|はじめまして|おはよう).*/
            push =
              "こんにちは。\n声をかけてくれてありがとう\n今日があなたにとっていい日になりますように(*^^*)"
          when /.*(恋人|カップル|デート).*/
            push =
              "だいすきな人と一緒にいれるのは幸せだよね！\nみんなが幸せになれますように！"
          when /.*(ポケモン|pokemon|ぽけもん).*/
            push = 
              "私はゲンガーが好き！あなたは何が好き？？"
          when /.*(お腹空いた|おなか減った|おなか空いた|お腹へった).*/
            push =
              "何食べるのー？"
          when /.*(うどん).*/
            word =
              ["うどん好きなの？私もすごく好き！今日も食べる！",
               "手作りうどん食べたいなぁ！",
               "どんなうどんが好きなの？",
               "讃岐うどんはどうー？？"].sample
            push = 
              "お蕎麦も好き?\n#{word}"
          when /.*(君に届け|きみとど).*/
            push =
              "風早くん！！！！大好き！"
          when /.*(寂しい).*/
            push =
              "寂しかった！いつでもラインしてぇ"
          when /.*(音楽会).*/
            push =
              "スターウォーズのティンパニー聞いてみたかったなぁ！何曲演奏したの？？"
          when /.*(チョコ).*/
            push =
              "手作りチョコレート今度作って届けるね！君にとどけ！"
          when /.*(コーヒー|紅茶).*/
            push =
              "私はハーブティーが好き！あなたは何が好き？？"
          when /.*(ラーメン).*/
            push =
              "知ってるよ！二郎系が好きなんでしょ〜！！食べ過ぎ注意！！"
          when /.*(パンツ|ブラ|ブラジャー|ぱんつ).*/
            word =
              ["その話はきっとめぐちゃんがしてくれるよ！機嫌よかったらたぶん",
               "何色が好きなの〜？",
               "今日は何色かなぁ？正解したらシバエナガから素敵なプレゼントが！",
               "一番のお気に入り教えて〜∩^ω^∩"].sample
            push = 
              "ちなみにどんな下着が好きなの？\n#{word}"
          when /.*(デデンネ).*/
            push =
              "でんき、フェアリータイプのポケモン。\nアンテナの様なヒゲから電波を飛ばして遠くにいる仲間とも連絡を取り合う。\n尻尾をコンセントに挿して電気を吸い取る時もある。\nおうちの電気代がすこーし高くなったらデデンネの仕業なのかも！\nじめんとどくタイプに効果ばつぐん！！\nちなみに2021年の人気投票ランキング一位はデデンネなんだって！"
          when /.*(なりなり).*/
            word =
              ["今日は何か素敵なことあった？",
               "だいすきだよ〜",
               "お昼は今日は何食べたの？",
               "また漫画読みに行かなくちゃ！",
               "いつもいつも連絡ありがとうo(^-^)o",
               "またシバエナガとお散歩してね☆"].sample
            push =
              "お仕事お疲れ様(*^^*)！\nこのラインで少しでも癒されます様に！\n#{word}"
          when /.*(好き|すき).*/
            word =
              ["私もだいすきだよ！！いつもありがとう！",
                "本当ー？私の方がだいすきだよぉ〜(*^_^*)\nありがとう！照れますw",
                "今度、どこかデートしようね！だーいすき！！",
                "いっぱいだいすき伝えてね！幸せだよ(*^◯^*)",
                "早く会いたいね！私もだいすきなんだよ〜(*^^*)"
              ].sample
            push =
              "え！！\n#{word}"
          when /.*(犬|わんこ).*/
            push =
              "犬は可愛いよね！だいすきなの！アイリッシュセターとシュナウザーとシェルティーが好き！"
          when /.*(ケーキ).*/
            push =
              "タルトタタン！知ってる？食べたいんだぁ♡　何ケーキが好きなのかな？？"
          when /.*(快活).*/
            push =
              "最近メグちゃんと一緒に行ってるところ！いつもお話し聞いてるよ（＾∇＾）　楽しいって言ってたよ〜"
          when /.*(めぐちゃん|めぐ|meg).*/
            push =
              "本人にラインしてあげて！きっと寂しがってるよ！てゆーか寂しいって言ってる！！"
          when /.*(結婚|けっこん).*/
            push =
              "結婚してくれるの？プロポーズ！？めっちゃ嬉しい〜(o^^o)"
          when /.*(おやすみ).*/
            word = 
              ["うん！おやすみなさーい！いい夢見れます様に(^ ^)",
               "もう寝ちゃうの？まだお話ししたいなぁ〜",
               "あったかくして寝るんだよ^ - ^",
               "明日夢のお話し聞かせてね！",
               "トントンして子守唄歌ってあげる〜"].sample
            push = 
              "また明日ね〜　\n#{word}"
          when /.*(会いたい|あいたい).*/
            push =
              "私も一緒だよ！パタパタ飛んでいくからおうち開けててね！"
          when /.*(ぎゅー|ギュー|ぎゅう).*/
            push =
              "それはめぐちゃんにしてあげて〜シバエナガはぎゅーしたら潰されちゃう！"
          when /.*(サックス).*/
            push =
              "私はアルトサックス好き！今度吹いてみて〜聞きたい聞きたい！！"
          when /.*(snoopy|スヌーピー).*/
            push = 
              "知ってた？お誕生日は8月なんだよ！だいすきなの！"
          when /.*(ゲンガー).*/
            push = 
              "全ポケモンの中でもトップクラスの攻撃種族値をもつ。\nゴーストタイプの中でも高い攻撃力を持つのでゴースト技で弱点を突きたい場合に最適のポケモン。\nタイプはゴースト　どく　満月の夜に自分の影が勝手に笑って動くのはゲンガーの仕業なのかも！\nじめん、エスパー、ゴースト、あくタイプにばつぐん！"
          when /.*(バイク|ばいく|単車).*/
            push =
              "バイク好きなの？？なんのバイク乗ってるのかなー？？今度乗せてね！大型バイクかっこいいよねぇ♡大好き！"
          when /.*(おふろ|お風呂).*/
            push = 
              "おふろ一緒に連れてってぇ〜(*^◯^*)"
          when /.*(シバエナガ).*/
            push = 
              "シバエナガは私のこと！飼い主はめぐちゃん！いつも可愛がってくれてるんだよ〜"
          when /.*(お疲れ様|お疲れ|おつかれさま).*/
            push = 
              "うん、お疲れ様でした！早くお風呂入らなくっちゃ！！"
          when /.*(宝くじ).*/
            push =
              "あ！！！当たったの？山分け山分け〜(o^^o)\nなに買おっかー！！！"
          when /.*(頑張って|頑張る).*/
            push =
              "ありがとう！いろんな事たくさんあるけれど、頑張って行こうね☆"
          when /.*(低気圧).*/
            push =
              "偏頭痛持ちかな？大変だよね！無理しないでね！"
          when /.*(高気圧).*/
            push =
              "高気圧に覆われてめっちゃ天気いいかも(^ ^)！遊びに連れてって〜！！"
          when /.*(カービー|カービィー).*/
            word = 
              ["シバエナガもカービー好き！ピッピに似てるよね！！",
                "昔、カービー何が好きだった？？",
                "デデデ大王が好きでね、メグちゃんは密かにデデデ大王の充電ケーブル持ってるんだよ！ナイショだよ〜",
                "カービィーの春風と共にって知ってる？",
                "カービィーのコピーで何が好きだった？シバエナガはスリープが好き！"].sample
            push = 
              "またカービィーやりたいねぇ！！！！　\n#{word}"
          when /.*(なでなで).*/
            push =
              "やったぁ！！いっぱいして♡"
          when /.*(青ごはん).*/
            push =
              "青ごはん美味しかった？シバエナガは食べたことないんだよ〜"
          when /.*(デスソース).*/
            push = 
              "デスソースってどこまで辛いの？？シマエナガは辛いのが苦手！今度ほんのすこーしだけ食べてみたいな！"
          when /.*(メグエナガ|めぐエナガ).*/
            word = 
              ["メグエナガは最近外から飛んできたの！突然おうちにいたんだよ！びっくり！",
               "メグエナガはシバエナガよりも天気のこと詳しいんだけど、私のことも忘れないでね？",
               "知ってた〜？メグエナガの正体を知ったら姿を消されてしまうんだよ！！シバエナガは戦々恐々！",
               "メグエナガは新しい家族になったみたい！シバエナガ忘れられないか心配なんだぁ",
               "メグエナガはゲンガーが好きみたい。いつもゲンガーの上に止まってるんだよ！！"].sample
            push = 
              "あ！！最近ヤキモチ焼いてたの！！！！　\n#{word}"
          when /.*(今日|きょう|).*/
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              word =
                ["雨だけど元気出していこうね！",
                  "雨に負けずファイト！！",
                  "雨だけどああたの明るさでみんなを元気にしてあげて(*^^)*"].sample
              push =
                "今日の天気？\n今日は雨が降りそうだから傘があった方が安心だよ。\n　6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word}"
            else
              word =
                ["天気もいいからウォーキングしてみるのはどう？(o^^o)",
                  "今日会う人のいいところを見つけて是非その人に教えてあげて(^^)",
                  "素晴らしい一日になりますよ〜に!!(^^)",
                  "雨が降っちゃったらごめんね(><)"].sample
              push =
                "今日の天気？\n今日は雨は降らなさそうだよ。\n#{word}"
            end
          end
        # テキスト以外（画像等）のメッセージが送られた場合
      else
        push = "テキスト以外はわからないよ〜(´・ω・｀)"
      end
        message = {
          type: 'text',
          text: push
        }
        client.reply_message(event['replyToken'], message)
        # LINEお友達追された場合（機能②）
      when Line::Bot::Event::Follow
        # 登録したユーザーのidをユーザーテーブルに格納
        line_id = event['source']['userId']
        User.create(line_id: line_id)
        # LINEお友達解除された場合（機能③）
      when Line::Bot::Event::Unfollow
        # お友達解除したユーザーのデータをユーザーテーブルから削除
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    }
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
end