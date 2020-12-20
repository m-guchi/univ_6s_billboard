class MethodEvaluation
    def initialize(method)
        @method = method
        @is_valid = check_is_valid(method)
    end

    def method()
        return @method
    end

    def is_valid()
        return @is_valid
    end

    def check_is_valid(method)
        method_list = [
            "OPTIONS",
            "GET",
            "HEAD",
            "POST",
            "PUT",
            "DELETE",
            "TRACE",
            "CONNECT"
        ]
        return method_list.include?(method)
    end
end