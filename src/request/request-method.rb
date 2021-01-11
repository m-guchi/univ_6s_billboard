class RequestMethod
    

    def initialize(method)
        @method = method
        @method_list = [
            "OPTIONS",
            "GET",
            "HEAD",
            "POST",
            "PUT",
            "DELETE",
            "TRACE",
            "CONNECT"
        ]
    end

    def method
        return @method
    end

    def valid?
        return @method_list.include?(@method)
    end

end