require "erb"
require "csv"
require "cgi/util"
require_relative "./url_analysys"
require_relative "./method_evaluation"

class Router
    def initialize(url, method)
        @url = url
        url_analysys = UrlAnalysis.new(url)
        @paths = url_analysys.paths
        @params = url_analysys.params
        @method = MethodEvaluation.new(method)
    end

    def routing
        @header = {}
        @body = ""
        if @paths.last.end_with?(".css")
            router_css()
        else
            router_html()
        end
        return @status_code, @header, @body
    end

    def router_html
        need_csv = (@paths.join("/") == "index")
        file_path = __dir__ + "/../templetes/" + @paths.join("/") + ".html.erb"
        unless exist_file(file_path)
            @status_code = 404
            return 0
        end
        unless ["GET","HEAD","POST"].include?(@method.method)
            @status_code = 405
            @header.store("Allow","GET, HEAD, POST")
            return 0
        end
        controller_html(file_path, need_csv)
    end

    def controller_html(file_path, need_csv)
        @status_code = 200
        @header.store("Content-Type","text/html; charset=utf-8")
        html = ERB.new(File.read(file_path))
        if need_csv
            @csv = CSV.read(__dir__ + "/../data/text.csv")
        end
        @body = html.result(binding)
    end
    private:controller_html

    def router_css
        file_path = __dir__ + "/../public/" + @paths.join("/")
        unless exist_file(file_path)
            @status_code = 404
            return 0
        end
        unless ["GET","HEAD"].include?(@method.method)
            @status_code = 405
            @header.store("Allow","GET, HEAD")
            return 0
        end
        fetch_css_file(file_path)
    end
    private:router_css

    def exist_file(file_path)
        return File.exist?(file_path)
    end
    private:exist_file

    def fetch_css_file(file_path)
        @status_code = 200
        @header.store("Content-Type","text/css; charset=utf-8")
        @body = ERB.new(File.read(file_path)).result(binding)
    end
    private:fetch_css_file
end