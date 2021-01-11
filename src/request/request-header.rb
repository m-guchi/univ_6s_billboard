class RequestHeader
    def initialize(header)
        @header = header
    end

    def has_content_length_key?()
        return @header.include?("content-length")
    end

    def content_length_valid?(message_body)
        unless has_content_length_key?
            return false
        end
        p message_body.length == @header["content-length"].to_i
        p message_body
        return message_body.length == @header["content-length"].to_i
    end
end