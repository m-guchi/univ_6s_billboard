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
        @header = ""
        @body = ""
        method = @method.method
        if ["GET","HEAD","POST"].include?(method)
            if @paths.last.end_with?(".css")
                router_css()
            else
                case @paths[0]
                when "index"
                    @status_code = 200
                    @header = "Content-Type: text/html; charset=utf-8"
                    index_html = ERB.new(File.read(__dir__ + "/../templetes/index.html.erb"))
                    @csv = CSV.read(__dir__ + "/../data/text.csv")
                    @body = index_html.result(binding)
                else
                    @status_code = 404
                end
            end
        else
            @status_code = 405
        end
        return @status_code, @header, @body
    end

    def router_css
        file_path = __dir__ + "/../public/" + @paths.join("/")
        unless exist_file(file_path)
            @status_code = 404
            return 0
        end
        unless ["GET","HEAD"].include?(@method.method)
            @status_code = 405
            return 0
        end
        fetch_css_file(file_path)
    end

    def exist_file(file_path)
        return File.exist?(file_path)
    end
    private:exist_file

    def fetch_css_file(file_path)
        @status_code = 200
        @header = "Content-Type: text/css; charset=utf-8"
        @body = ERB.new(File.read(file_path)).result(binding)
    end
    private:fetch_css_file
end