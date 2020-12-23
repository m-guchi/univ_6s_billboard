class Routing
    @@status_code = 500
    @@header_hash = {}
    @@body = ""

    @@mime_type_list = {
        ".html" => "text/html",
        ".css" => "text/css",
        ".js" => "text/javascript",
        ".json" => "application/json",
    }

    def initialize(method, path)
        @method = method
        @path = path
        extension = File.extname(@path.last)
        if extension == "" || !@@mime_type_list.include?(extension)
            routing_rb()
        else
            routing_public(extension)
        end
    end

    def status_code
        return @@status_code
    end

    def header_hash
        return @@header_hash
    end

    def body
        return @@body
    end

    def routing_rb
        need_csv = (@path.join("/") == "index")
        file_path = __dir__ + "/../../templetes/" + @path.join("/") + ".html.erb"
        unless File.exist?(file_path)
            @@status_code = 404
            return 0
        end
        unless ["GET","HEAD","POST"].include?(@method)
            @@status_code = 405
            @@header_hash.store("Allow","GET, HEAD, POST")
            return 0
        end
        @@status_code = 200
        @@header_hash.store("Content-Type","text/html; charset=utf-8")
        html = ERB.new(File.read(file_path))
        if need_csv
            @csv = CSV.read(__dir__ + "/../../data/text.csv")
        end
        @@body = html.result(binding)
    end
    private:routing_rb

    def routing_public(extension)
        file_path = __dir__ + "/../../public/" + @path.join("/")
        unless File.exist?(file_path)
            @@status_code = 404
            return 0
        end
        unless ["GET","HEAD"].include?(@method)
            @@status_code = 405
            @@header_hash.store("Allow","GET, HEAD")
            return 0
        end
        @@status_code = 200
        @@header_hash.store("Content-Type", @@mime_type_list[extension] + "; charset=utf-8")
        @@body = ERB.new(File.read(file_path)).result(binding)
    end
end