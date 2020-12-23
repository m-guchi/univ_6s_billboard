class RequestURL
    def initialize(url)
        path, param = split_url(url)
        @path = split_path(path)
        @param = param ? split_param(param) : nil
    end

    def path
        return @path
    end

    def param
        return @param
    end

    def split_url(url)
        path, param = url.split("?")
        return path, param
    end
    private:split_url

    def split_path(path)
        if path == ""
            path = "/"
        end
        if path.end_with?("/")
            path += "index"
        end
        if path.slice(0) == "/"
            path[0] = ""
        end
        paths = path.split("/")
        return paths || nil
    end
    private:split_path

    def split_param(param)
        params = Hash.new
        param.split("&").each do |p|
            pair = p.split("=")
            params.store(pair[0], CGI.unescape(pair[1] || ""))
        end
        return params
    end
    private:split_path
end