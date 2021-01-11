class RequestHttpVersion
    def initialize(http_version, can_accept_http_version)
        @c_http_version_num = analysis_http_version(http_version)
        @s_http_version_num = can_accept_http_version
    end

    def support?
        # clientのHTTPverより大きいverは送信不可(RFC2616 3.1)
        return @c_http_version_num >= @s_http_version_num
    end

    def analysis_http_version(c_http_version)
        return  c_http_version.delete("HTTP/").to_f
    end
    private:analysis_http_version
end

