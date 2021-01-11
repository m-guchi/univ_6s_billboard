require "socket"
require 'logger'
require 'time'
require_relative "./src/request/request-messages-split"
require_relative "./src/request/request-method"
require_relative "./src/request/request-http-version"
require_relative "./src/request/request-url"
require_relative "./src/request/request-header"
require_relative "./src/request/routing"
require_relative "./src/response/response-data"
require_relative "./src/response/http-status-code"

# ログレベル[UNKNOWN,FATAL,ERROR,WARN,INFO,DEBUG]
request_logger = Logger.new('log/request.log')
request_logger.level = Logger::DEBUG
response_logger = Logger.new('log/response.log')
response_logger.level = Logger::DEBUG

port = 8080 # ポート番号
ss = TCPServer.open(port)

can_accept_http_version = 1.0 # 対応するHTTPバージョン

p "connection: http://localhost:" + port.to_s

loop do
    Thread.start(ss.accept) do |s|
        # リクエストを受け取る
        max_request_char = 65536 # request取得可能最大長
        request_messages = s.readpartial(max_request_char).split(/\R/)
        request_logger.debug(request_messages)

        _response_data = ResponseData.new()

        begin
            _request_message = RequestMessagesSplit.new(request_messages)
            unless _request_message.valid?
                _response_data.status_code = 400
                raise
            end
            method, request_url, http_version = _request_message.request_line
            _method = RequestMethod.new(method)
            _request_url = RequestURL.new(request_url)
            _http_version = RequestHttpVersion.new(http_version, can_accept_http_version)
            _request_header = RequestHeader.new(_request_message.message_header)

            # データの取得
            unless _method.valid?
                _response_data.status_code = 501
                raise
            end

            unless _http_version.support?
                _response_data.status_code = 505
                raise
            end

            # content-lengthの評価(RFC2616 4.4)
            unless _request_message.row_message_body==""
                if _request_header.has_content_length_key?
                    unless _request_header.content_length_valid?(_request_message.row_message_body)
                        _response_data.status_code = 400
                        raise
                    end
                else
                    _response_data.status_code = 411
                    raise
                end
            end


            _routing = Routing.new(_method.method, _request_url.path, _request_url.param, _request_message.message_body)
            _response_data.status_code = _routing.status_code
            _response_data.header_hash = _routing.header_hash
            _response_data.add_header("Date", Time.now.httpdate)
            _response_data.body = _routing.body

        rescue => exception
            p exception
        end
        
        # エラーページを表示
        _http_status_code = HttpStatusCode.new(_response_data.status_code)
        if _http_status_code.error?()
            _response_data.header_hash = _http_status_code.error_page_header_hash()
            _response_data.body = _http_status_code.error_page_body()
        end

        # メソッドがHEADの場合はbody削除
        unless _response_data.status_code == 400 # _methodの未定義を防止
            if _method.method == "HEAD"
                _response_data.body = ""
            end
        end

        response_headers = Array.new()
        http_version = "HTTP/" + can_accept_http_version.to_s
        response_headers.push(http_version + " " + _http_status_code.format_status_code)

        # ヘッダーを展開
        _response_data.header_hash.each do |key,value|
            response_headers.push(key + ": " + value)
        end

        response_header = response_headers.join("\n")

        if [204,304].include?(_http_status_code.status_code)
            response_messages = <<~EORMSG
                #{response_header}

            EORMSG
        else
            response_messages = <<~EORMSG
                #{response_header}

                #{_response_data.body}
            EORMSG
        end

        response_logger.debug(response_headers)
        s.puts(response_messages)
        s.close
    end
end