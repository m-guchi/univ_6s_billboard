class RequestMessagesSplit
    def initialize(request_messages)
        @messages = request_messages
        analysis_request_line()
        analysis_message_header()
        analysis_message_body()
    end

    def request_line
        return @method, @request_url, @http_version
    end
    
    def message_header
        return @message_header
    end

    def message_body
        return @message_body
    end

    def analysis_request_line
        loop do # 空行は無視(RFC2616 4.1)
            request_line = @messages.shift
            unless request_line == ""
                @method, @request_url, @http_version = request_line.split
                break
            end
        end
    end
    private:analysis_request_line

    def analysis_message_header
        @message_header = Hash.new
        loop do # 空行or最後までmessage_header(RFC2616 4.1)
            msg = @messages.shift
            if msg == "" || msg == nil
                break
            end
            key, val = msg.split(":",2)
            @message_header.store(key.downcase, val.lstrip)
        end
    end
    private:analysis_message_header

    def analysis_message_body
        @message_body = Hash.new
        msg = @messages.join("\n")
        unless msg == ""
            msg.split("&").each do |m|
                key, val = m.split("=")
                @message_body.store(CGI.unescape(key || ""), CGI.unescape(val|| ""))
            end
        end
    end
    private:analysis_message_body
end
