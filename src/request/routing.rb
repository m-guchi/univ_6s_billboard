class Routing

    def initialize(method, path, param, message_body)
        @method = method
        @path = path
        @param = param
        @message_body = message_body
        @extension = File.extname(@path.last)
        @status_code = 500
        @header_hash = Hash.new()
        @body = ""
        @mime_type_list = {
            ".html" => "text/html",
            ".css" => "text/css",
            ".js" => "text/javascript",
            ".json" => "application/json",
        }
        routing()
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

    def routing()
        if @extension == "" || !@mime_type_list.include?(@extension)
            routing_rb()
            if @status_code == 404
                @path[-1] += ".html"
                @extension = ".html"
                routing_public()
            end
        else
            routing_public()
        end
    end
    private:routing

    def routing_rb()
        controller_file_path = "./src/controller/" + @path.join("/") + ".rb"
        if File.exist?(controller_file_path)
            require controller_file_path
            _controller = Object.const_get(@path.map(&:capitalize).join("")).new(@method, @param, @message_body)
            @status_code = _controller.status_code
            @header_hash = _controller.header_hash || Hash.new
            @body = _controller.body || ""
        else
            @status_code = 404
        end
    end
    private:routing_rb

    def routing_public()
        file_path = "./public/" + @path.join("/")
        unless File.exist?(file_path)
            @status_code = 404
            return 0
        end
        unless ["GET","HEAD"].include?(@method)
            @status_code = 405
            @header_hash.store("Allow","GET, HEAD")
            return 0
        end
        @status_code = 200
        @header_hash.store("Content-Type", @mime_type_list[@extension] + "; charset=UTF-8")
        @body = ERB.new(File.read(file_path)).result(binding)
    end
end