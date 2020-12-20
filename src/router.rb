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
        method = @method.method
        if method == "GET" || method == "HEAD" || method == "POST"
            if @paths.last.end_with?(".css")
                return router_css(@paths)
            else
                case @paths[0]
                when "index"
                    status_code = 200
                    header = "Content-Type: text/html; charset=utf-8"
                    index_html = ERB.new(File.read(__dir__ + "/../templetes/index.html.erb"))
                    @csv = CSV.read(__dir__ + "/../data/text.csv")
                    body = index_html.result(binding)
                else
                    status_code = 404
                end
            end
        else
            status_code = 405
        end
        return status_code, header, body
    end

    # CSSファイルのルーティング
    def router_css(paths)
        path = paths.join("/")
        file_path = __dir__ + "/../public/" + path
        if File.exist?(file_path)
            status_code = 200
            header = "Content-Type: text/css; charset=utf-8"
            body = ERB.new(File.read(file_path)).result(binding)
        else
            status_code = 404
        end
        return status_code, header, body
    end
    private:router_css
end