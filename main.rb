require "socket"
require 'logger'
require "csv"
require_relative "./src/router"
require_relative "./src/post_article"
require_relative "./src/http_status_code"
require_relative "./src/method_evaluation"

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
        message_body = Hash.new
        unless request_messages.join("\n") == ""
            request_messages.join("\n").split("&").each do |m|
                pair = m.split("=")
                message_body.store(pair[0], CGI.unescape(pair[1] || ""))
            end
        end

        unless message_body.empty?
            PostArticle.new(message_body["name"],message_body["article"])
        end

        method_evaluation = MethodEvaluation.new(method)

        if method_evaluation.is_valid
            router = Router.new(request_url, method)
            status_code, header_hash, body = router.routing
        else
            status_code = 501
        end

        # ステータスコードで表示内容を制御
        http_status_code = HttpStatusCode.new(status_code)
        unless http_status_code.is_success()
            header_hash.merge!(http_status_code.update_error_header_list())
            body = http_status_code.change_error_body() || body
        end

        # メソッドがHEADの場合はbody削除
        if method_evaluation.method == "HEAD"
            body = ""
        end

        # ヘッダーを展開
        header = header_hash.map{|key,value| [key + ": " + value]}.join("\n")


        response_messages = <<~EOHTTP
            HTTP/1.0 #{http_status_code.format_status_code}
            #{header}

            #{body}
        EOHTTP


        s.puts(response_messages)
        s.close
    end
end