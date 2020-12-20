require "socket"
require 'logger'
require "csv"
require_relative "./src/router"

logger = Logger.new('log/request.log')
logger.level = Logger::DEBUG # ログレベル[UNKNOWN,FATAL,ERROR,WARN,INFO,DEBUG]

port = 8080 # ポート番号
ss = TCPServer.open(port)

loop do
    Thread.start(ss.accept) do |s|
        # リクエストを受け取る
        max_length = 4096 # データの最大長
        request_messages = s.readpartial(max_length).split(/\R/)
        logger.debug(request_messages)

        # リクエストを解釈
        # リクエストライン
        method, request_url, http_version = request_messages.shift.split
        # メッセージヘッダ
        message_header = Hash.new
        loop do
            msg = request_messages.shift
            if msg == "" || msg == nil
                break
            end
            key, val = msg.split(": ",2)
            message_header.store(key,val)
        end
        # メッセージボディ
        message_body = request_messages.join("")
        
        unless message_body == ""
            bodys = Hash.new
            message_body.split("&").each do |m|
                pair = m.split("=")
                bodys.store(pair[0], CGI.unescape(pair[1]==nil ? "" : pair[1]))
            end
            week_list = ["日","月","火","水","木","金","土"]
            time = Time.now.strftime("%Y/%m/%d") + "(" + week_list[Time.now.strftime("%w").to_i] + ") " + Time.now.strftime("%T")
            name = bodys["name"]!="" ? bodys["name"] : "名無しさん"
            no = CSV.read(__dir__ + "/data/text.csv").empty? ? 0 : CSV.read(__dir__ + "/data/text.csv").last[0].to_i+1
            CSV.open(__dir__ + "/data/text.csv","a") do |csv|
                csv << [no,time,name,bodys["article"].gsub(/\R/, "\n")]
            end
        end

        router = Router.new(request_url)
        status, header, body = router.routing

        response_messages = <<~EOHTTP
            HTTP/1.0 #{status}
            #{header}

            #{body}
        EOHTTP


        s.puts(response_messages)
        s.close
    end
end