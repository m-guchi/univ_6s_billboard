class UrlAnalysis

    def initialize(url)
        path, param = split_url(url)
        @paths = split_path(path)
        @params = param ? split_param(param) : nil
    end

    def paths()
        return @paths
    end

    def params()
        return @params
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
            path[0]=""
        end
        paths = path.split("/")
        return paths ? paths : nil
    end
    private:split_path

    def split_param(param)
        params = Hash.new
        param.split("&").each do |p|
            pair = p.split("=")
            params.store(pair[0], CGI.unescape(pair[1] || ""))
        end
    end
    private:split_param
end