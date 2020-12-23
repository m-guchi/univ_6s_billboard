require "socket"
require 'logger'
require "csv"
require_relative "./src/router"
require_relative "./src/post_article"
require_relative "./src/http_status_code"
require_relative "./src/method_evaluation"
require_relative "./src/request_message"

logger = Logger.new('log/request.log')
logger.level = Logger::DEBUG # ログレベル[UNKNOWN,FATAL,ERROR,WARN,INFO,DEBUG]

port = 8080 # ポート番号
ss = TCPServer.open(port)

p "connection: http://localhost:" + port.to_s

loop do
    Thread.start(ss.accept) do |s|
        # リクエストを受け取る
        max_request_char = 65536 # request取得可能最大長
        request_messages = s.readpartial(max_request_char).split(/\R/)
        logger.debug(request_messages)

        req_msg = RequestMessage.new(request_messages)
        method, request_url, http_version = req_msg.fetch_request_line
        message_header = req_msg.fetch_message_header
        message_body = req_msg.fetch_message_body

        # 投稿
        unless message_body.empty?
            PostArticle.new(message_body["name"],message_body["article"])
        end

        # メソッドの評価
        method_evaluation = MethodEvaluation.new(method)
        if method_evaluation.is_valid
            router = Router.new(request_url, method)
            status_code, header_hash, body = router.routing
        else
            status_code = 501
            header_hash = {}
            body = ""
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