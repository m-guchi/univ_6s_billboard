class RequestMethod
    @@method_list = [
        "OPTIONS",
        "GET",
        "HEAD",
        "POST",
        "PUT",
        "DELETE",
        "TRACE",
        "CONNECT"
    ]

    def initialize(method)
        @method = method
    end

    def method
        return @method
    end

    def valid?
        return @@method_list.include?(@method)
    end

end