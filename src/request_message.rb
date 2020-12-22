class RequestMessage
    def initialize(request_messages)
        @messages = request_messages
        analyze_request_line()
        analyze_message_header()
        analyze_message_body()
    end

    def fetch_request_line
        return @method, @request_url, @http_version
    end

    def analyze_request_line
        loop do # 空行は無視(RFC2616 4.1)
            request_line = @messages.shift
            unless request_line == ""
                @method, @request_url, @http_version = request_line.split
                break
            end
        end
    end
    private:analyze_request_line

    def fetch_message_header
        return @message_header
    end

    def analyze_message_header
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
    private:analyze_message_header

    def fetch_message_body
        return @message_body
    end

    def analyze_message_body
        @message_body = Hash.new
        msg = @messages.join("\n")
        unless msg == ""
            msg.split("&").each do |m|
                key, val = m.split("=")
                @message_body.store(CGI.unescape(key || ""), CGI.unescape(val|| ""))
            end
        end
    end
    private:analyze_message_body
    
end