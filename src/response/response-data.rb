class ResponseData

    def initialize
        @status_code = 500
        clear_header_and_body()
    end

    def clear_header_and_body()
        @header_hash = Hash.new()
        @body = String.new()
    end

    def status_code
        return @status_code
    end

    def header_hash
        return @header_hash
    end

    def body
        return @body
    end

    def status_code=(status_code)
        @status_code = status_code
        if [400,411,501,505].include?(status_code)
            status_code_is_invalid(status_code)
        end
    end

    def header_hash=(header_hash)
        @header_hash = header_hash
    end

    def merge_header_hash(header_hash)
        @header_hash.merge!(header_hash)
    end

    def add_header(key, val)
        @header_hash[key] = val
    end

    def body=(body)
        @body = body
    end

    def status_code_is_invalid(status_code)
        @status_code = status_code
        clear_header_and_body()
    end
end