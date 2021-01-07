require "socket"
require 'logger'
require 'time'
# require "csv"
require_relative "./src/request/request-messages-split"
require_relative "./src/request/request-method"
require_relative "./src/request/request-url"
require_relative "./src/request/routing"
# require_relative "./src/router"
require_relative "./src/http_status_code"

request_logger = Logger.new('log/request.log')
request_logger.level = Logger::DEBUG # ログレベル[UNKNOWN,FATAL,ERROR,WARN,INFO,DEBUG]
response_logger = Logger.new('log/response.log')
response_logger.level = Logger::DEBUG # ログレベル[UNKNOWN,FATAL,ERROR,WARN,INFO,DEBUG]

port = 8080 # ポート番号
ss = TCPServer.open(port)

p "connection: http://localhost:" + port.to_s

loop do
    Thread.start(ss.accept) do |s|
        # リクエストを受け取る
        max_request_char = 65536 # request取得可能最大長
        request_messages = s.readpartial(max_request_char).split(/\R/)
        request_logger.debug(request_messages)

        _request_message = RequestMessagesSplit.new(request_messages)
        method, request_url, http_version = _request_message.request_line
        # message_header = _request_message.message_header
        message_body = _request_message.message_body

        # ヘッダーの評価
        _method = RequestMethod.new(method)
        _request_url = RequestURL.new(request_url)
        
        if _method.valid?
            _routing = Routing.new(_method.method, _request_url.path, _request_url.param, message_body)
            status_code = _routing.status_code
            header_hash = _routing.header_hash
            header_hash.store("Date",Time.now.httpdate)
            body = _routing.body
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
        if _method.method == "HEAD"
            body = ""
        end

        response_headers = Array.new
        response_headers.push("HTTP/1.0 "+http_status_code.format_status_code)

        # ヘッダーを展開
        header_hash.each do |key,value|
            response_headers.push(key + ": " + value)
        end

        response_header = response_headers.join("\n")

        response_messages = <<~EORQMSG
            #{response_header}

            #{body}
        EORQMSG

        response_logger.debug(response_headers)
        s.puts(response_messages)
        s.close
    end
end