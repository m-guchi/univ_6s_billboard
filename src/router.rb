require "erb"
require "csv"
require "cgi/util"
require_relative "./http_status_code"

class Router
    def initialize(url)
        @paths, @params = url_interpretation(url)
    end

    # URLをpathとparamに分解してそれぞれ解釈
    def url_interpretation(url)
        path, param = split_url(url)
        paths = split_path(path)
        params = param ? split_param(param) : nil
        return paths, params
    end
    private:url_interpretation

    def routing
        paths = @paths
        params = @params

        if paths.last.end_with?(".css")
            status_code, header, body = router_css(paths)
        else
            case paths[0]
            when "index"
                status_code = 200
                header = "Content-Type: text/html; charset=utf-8"
                index_html = ERB.new(File.read(__dir__ + "/../templetes/index.html.erb"))
                @csv = CSV.read(__dir__ + "/../data/text.csv")
                body = index_html.result(binding)
            else
                status_code = 404
                header = ""
                body = ""
            end
        end

        http_status_code = HttpStatusCode.new()
        unless status = http_status_code.status_format(status_code)
            status = http_status_code.status_format(500)
            header = "Content-Type: text/html; charset=utf-8"
            body = "サーバーエラーが発生しました。<br>サーバーの問題でお探しのページを表示できません。<br>再度時間をおいてアクセスしてください。"
        end
        return status, header, body
    end

    def router_css(paths)
        path = paths.join("/")
        file_path = __dir__ + "/../public/" + path
        if File.exist?(file_path)
            status_code = 200
            header = "Content-Type: text/css; charset=utf-8"
            body = ERB.new(File.read(file_path)).result(binding)
        else
            status_code = 404
            header = ""
            body = ""
        end
        return status_code, header, body
    end
    private:router_css

    def split_url(url)
        path, param = url.split("?")
        return path, param
    end
    private:split_url

    def split_path(path)
        if path.slice(0) == "/"
            path[0]=""
        end
        if path == ""
            return ["index"]
        end
        paths = path.split("/")
        return paths ? paths : nil
    end
    private:split_path

    def split_param(param)
        params = Hash.new
        param.split("&").each do |p|
            pair = p.split("=")
            params.store(pair[0], CGI.unescape(pair[1]==nil ? "" : pair[1]))
        end
    end
    private:split_param
end