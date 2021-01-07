class ControllerBase
    

    @@mime_type_list = {
        ".html" => "text/html",
        ".css" => "text/css",
        ".js" => "text/javascript",
        ".json" => "application/json",
    }

    def initialize(method, param, message_body)
        @@header_hash = Hash.new
        @@body = ""
        @@valid_method_list = ["GET","HEAD"]
        @@method = method
        @@param = param
        @@message_body = message_body
    end

    def status_code
        return valid_method?() ? 200 : 405
    end

    def valid_method?
        return @@valid_method_list.include?(@@method)
    end

    def set_method_allow
        unless valid_method?()
            @@header_hash.store("Allow", @@valid_method_list.join(", "))
        end
    end

    def set_mime_type(extension)
        mime_type = @@mime_type_list[extension]
        @@header_hash.store("Content-Type" , mime_type + "; charset=UTF-8")
    end
end