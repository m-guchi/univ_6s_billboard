class HttpStatusCode
    def status_format(code)
        status_list = {
            200 => "OK",
            204 => "No Content",
            301 => "Moved Permanently",
            302 => "Found",
            401 => "Unauthorized",
            403 => "Forbidden",
            404 => "Not Found",
            500 => "Internal Server Error",
        }
        status = status_list[code]
        return status ? code.to_s + " " + status : nil
    end
end