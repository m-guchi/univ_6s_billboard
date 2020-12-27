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

    def initialize(method, path, message_body)
        @method = method
        @path = path
        @message_body = message_body
        extension = File.extname(@path.last)
        if extension == "" || !@@mime_type_list.include?(extension)
            routing_rb(message_body)
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

    def routing_rb(message_body)
        controller_file_path = "./src/controller/" + @path.join("/") + ".rb"
        if File.exist?(controller_file_path)
            require controller_file_path
            _controller = Object.const_get(@path.last.capitalize).new(@method, message_body)
            @@status_code = _controller.status_code
            @@header_hash = _controller.header_hash
            @@body = _controller.body
        else
            @@status_code = 404
        end
    end
    private:routing_rb

    def routing_public(extension)
        file_path = "./public/" + @path.join("/")
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
        @@header_hash.store("Content-Type", @@mime_type_list[extension] + "; charset=UTF-8")
        @@body = ERB.new(File.read(file_path)).result(binding)
    end
end